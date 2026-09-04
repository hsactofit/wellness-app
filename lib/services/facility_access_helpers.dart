import 'facility_booking_service.dart';

/// Prevents repeated camera frames from opening more than one member-code
/// dialog while the first QR check-in is still being resolved.
class QrCheckinGate {
  bool _active = false;

  bool tryBegin() {
    if (_active) return false;
    _active = true;
    return true;
  }

  void end() => _active = false;
}

bool isUpcomingBooking(MemberBooking booking, {DateTime? now}) =>
    booking.status == 'booked' &&
    booking.slot.endsAt.isAfter(now ?? DateTime.now());

List<MemberBooking> upcomingBookings(
  List<MemberBooking> bookings, {
  DateTime? now,
}) =>
    bookings.where((booking) => isUpcomingBooking(booking, now: now)).toList();

/// A checked-in booking moves to history immediately, even while its reserved
/// hour is still in progress. An unattended booking moves there once the hour
/// has finished; the lifecycle worker eventually turns it into `no_show`.
bool isPreviousBooking(MemberBooking booking, {DateTime? now}) =>
    booking.status != 'cancelled' &&
    (booking.status == 'checked_in' ||
        booking.status == 'completed' ||
        !booking.slot.endsAt.isAfter(now ?? DateTime.now()));

List<MemberBooking> previousBookings(
  List<MemberBooking> bookings, {
  DateTime? now,
}) =>
    bookings.where((booking) => isPreviousBooking(booking, now: now)).toList();

class BookingHistoryStatus {
  const BookingHistoryStatus({required this.label, required this.attended});

  final String label;
  final bool attended;
}

/// Maps the server-authoritative lifecycle state to the concise member-facing
/// status used beside a past slot. A booked slot that has already ended is
/// temporarily treated as absent until the worker records its `no_show`.
BookingHistoryStatus? bookingHistoryStatus(
  MemberBooking booking, {
  DateTime? now,
}) {
  if (!isPreviousBooking(booking, now: now)) return null;
  switch (booking.status) {
    case 'completed':
      return const BookingHistoryStatus(label: 'Done', attended: true);
    case 'checked_in':
      return const BookingHistoryStatus(label: 'Attended', attended: true);
    case 'booked':
    case 'no_show':
      return const BookingHistoryStatus(label: 'Absent', attended: false);
  }
  return null;
}

bool isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Facility booking dates are calendar dates from the API, not instants.
MemberBooking? bookingOnDay(List<MemberBooking> bookings, DateTime day) {
  for (final booking in bookings.where(
    (booking) => booking.status == 'booked',
  )) {
    if (isSameCalendarDay(booking.bookingDate, day)) return booking;
  }
  return null;
}

bool isAlreadyBookedMessage(String message) {
  final normalized = message.toLowerCase();
  return normalized.contains('already have a booking') ||
      normalized.contains('already have the booking');
}

String facilityDayKey(DateTime day, {int page = 1}) =>
    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}:$page';
