import 'facility_booking_service.dart';

bool isUpcomingBooking(MemberBooking booking, {DateTime? now}) =>
    booking.status == 'booked' &&
    booking.slot.endsAt.isAfter(now ?? DateTime.now());

List<MemberBooking> upcomingBookings(
  List<MemberBooking> bookings, {
  DateTime? now,
}) =>
    bookings.where((booking) => isUpcomingBooking(booking, now: now)).toList();

/// A booking is history once its reserved hour has finished.  The lifecycle
/// worker eventually turns an unattended booking into `no_show`, but this
/// local boundary means the member never loses sight of the visit while that
/// asynchronous update is still pending.
bool isPreviousBooking(MemberBooking booking, {DateTime? now}) =>
    booking.status != 'cancelled' &&
    !booking.slot.endsAt.isAfter(now ?? DateTime.now());

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
