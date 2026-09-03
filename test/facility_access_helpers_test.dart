import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/services/facility_access_helpers.dart';
import 'package:wellnessconnect/services/facility_booking_service.dart';

MemberBooking _booking({
  required String id,
  required String status,
  required DateTime day,
}) {
  return MemberBooking(
    id: id,
    facilityId: 'fac-1',
    facilityName: 'Medifit Indiranagar',
    facilityCode: 'BLR1',
    slot: FacilitySlot(
      id: 'slot-$id',
      facilityId: 'fac-1',
      startsAt: day.add(const Duration(hours: 10)),
      endsAt: day.add(const Duration(hours: 11)),
      capacity: 10,
      booked: 1,
      remaining: 9,
    ),
    bookingDate: day,
    status: status,
    capacityOverride: false,
  );
}

void main() {
  final day = DateTime(2026, 9, 3);

  test('upcoming bookings hide cancelled and completed visits', () {
    final bookings = [
      _booking(id: '1', status: 'booked', day: day),
      _booking(id: '2', status: 'cancelled', day: day),
      _booking(
        id: '3',
        status: 'completed',
        day: day.add(const Duration(days: 1)),
      ),
    ];

    expect(upcomingBookings(bookings).map((item) => item.id), ['1']);
  });

  test('same-day booking is detected before another API round-trip', () {
    final existing = _booking(id: '1', status: 'booked', day: day);
    expect(bookingOnDay([existing], day)?.id, '1');
    expect(bookingOnDay([existing], day.add(const Duration(days: 1))), isNull);
  });

  test('already-booked API wording is recognized immediately', () {
    expect(
      isAlreadyBookedMessage('You already have a booking on this day'),
      isTrue,
    );
    expect(isAlreadyBookedMessage('This slot is full'), isFalse);
  });
}
