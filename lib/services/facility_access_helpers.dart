import 'facility_booking_service.dart';

bool isUpcomingBooking(MemberBooking booking, {DateTime? now}) =>
    booking.status == 'booked' &&
    booking.slot.endsAt.isAfter(now ?? DateTime.now());

List<MemberBooking> upcomingBookings(
  List<MemberBooking> bookings, {
  DateTime? now,
}) =>
    bookings.where((booking) => isUpcomingBooking(booking, now: now)).toList();

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
