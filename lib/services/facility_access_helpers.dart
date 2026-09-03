import 'facility_booking_service.dart';

bool isUpcomingBooking(MemberBooking booking) => booking.status == 'booked';

List<MemberBooking> upcomingBookings(List<MemberBooking> bookings) =>
    bookings.where(isUpcomingBooking).toList();

bool isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Facility booking dates are calendar dates from the API, not instants.
MemberBooking? bookingOnDay(List<MemberBooking> bookings, DateTime day) {
  for (final booking in upcomingBookings(bookings)) {
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
