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

  test('QR check-in gate allows only one member-code dialog at a time', () {
    final gate = QrCheckinGate();

    expect(gate.tryBegin(), isTrue);
    expect(gate.tryBegin(), isFalse);
    gate.end();
    expect(gate.tryBegin(), isTrue);
  });

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

    expect(upcomingBookings(bookings, now: day).map((item) => item.id), ['1']);
  });

  test('upcoming bookings hide an expired booked slot', () {
    final booking = _booking(id: '1', status: 'booked', day: day);

    expect(
      upcomingBookings([booking], now: day.add(const Duration(hours: 12))),
      isEmpty,
    );
  });

  test(
    'previous bookings retain completed, attended, and absent slot states',
    () {
      final completed = _booking(id: '1', status: 'completed', day: day);
      final attended = _booking(id: '2', status: 'checked_in', day: day);
      final absent = _booking(id: '3', status: 'no_show', day: day);
      final pendingWorker = _booking(id: '4', status: 'booked', day: day);
      final cancelled = _booking(id: '5', status: 'cancelled', day: day);
      final now = day.add(const Duration(hours: 12));

      expect(
        previousBookings([
          completed,
          attended,
          absent,
          pendingWorker,
          cancelled,
        ], now: now).map((item) => item.id),
        ['1', '2', '3', '4'],
      );
      expect(bookingHistoryStatus(completed, now: now)?.label, 'Done');
      expect(bookingHistoryStatus(completed, now: now)?.attended, isTrue);
      expect(bookingHistoryStatus(attended, now: now)?.label, 'Attended');
      expect(bookingHistoryStatus(absent, now: now)?.label, 'Absent');
      expect(bookingHistoryStatus(absent, now: now)?.attended, isFalse);
      expect(bookingHistoryStatus(pendingWorker, now: now)?.label, 'Absent');
    },
  );

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

  test('facility page reads the server-provided same-day cutoff', () {
    final facility = EligibleFacility.fromJson({
      'id': 'fac-1',
      'code': 'BLR1',
      'name': 'Medifit Indiranagar',
      'city': 'Bengaluru',
      'timezone': 'Asia/Kolkata',
      'previously_visited': false,
      'recommended': false,
      'available_slots': 0,
      'total_slots': 0,
      'booking_closed': true,
      'multi_facility': false,
      'slots': [],
    });

    expect(facility.bookingClosed, isTrue);
  });
}
