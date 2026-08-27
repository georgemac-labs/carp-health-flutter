import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';

import '../support/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthDataPoint parsing', () {
    test('parses numeric health data points', () {
      final point = HealthDataPoint.fromHealthDataPoint(
        HealthDataType.HEART_RATE,
        HealthFixtures.numericPoint(),
        null,
      );

      expect(point.type, HealthDataType.HEART_RATE);
      expect(point.value, isA<NumericHealthValue>());
      final value = point.value as NumericHealthValue;
      expect(value.numericValue, 72);
    });

    test('parses workout health data points', () {
      final point = HealthDataPoint.fromHealthDataPoint(
        HealthDataType.WORKOUT,
        HealthFixtures.workoutPoint(),
        HealthDataUnit.NO_UNIT.name,
      );

      expect(point.type, HealthDataType.WORKOUT);
      expect(point.value, isA<WorkoutHealthValue>());
      final value = point.value as WorkoutHealthValue;
      expect(value.workoutActivityType, HealthWorkoutActivityType.RUNNING);
      expect(value.totalEnergyBurned, 200);
      expect(value.totalDistance, 5000);
    });

    test('parses workout route health data points', () {
      final point = HealthDataPoint.fromHealthDataPoint(
        HealthDataType.WORKOUT_ROUTE,
        HealthFixtures.workoutRoutePoint(),
        HealthDataUnit.NO_UNIT.name,
      );

      expect(point.type, HealthDataType.WORKOUT_ROUTE);
      expect(point.value, isA<WorkoutRouteHealthValue>());
      final value = point.value as WorkoutRouteHealthValue;
      expect(value.locations, hasLength(1));
      expect(value.workoutUuid, 'workout-uuid-1');
      expect(value.locations.first.latitude, 37.3349);
    });

    test('round-trips CardioSnap metric enums and units through JSON', () {
      for (final type in [
        HealthDataType.RUNNING_SPEED,
        HealthDataType.CYCLING_SPEED,
        HealthDataType.ROWING_SPEED,
        HealthDataType.RUNNING_POWER,
        HealthDataType.CYCLING_POWER,
        HealthDataType.POWER,
        HealthDataType.CYCLING_CADENCE,
        HealthDataType.DISTANCE_ROWING,
      ]) {
        final point = HealthDataPoint(
          uuid: 'uuid-${type.name}',
          value: NumericHealthValue(numericValue: 1),
          type: type,
          unit: dataTypeToUnit[type]!,
          dateFrom: HealthFixtures.start,
          dateTo: HealthFixtures.end,
          sourcePlatform: HealthPlatformType.appleHealth,
          sourceDeviceId: 'device-id',
          sourceId: 'source-id',
          sourceName: 'source-name',
        );

        final restored = HealthDataPoint.fromJson(point.toJson());
        expect(restored.type, type);
        expect(restored.unit, dataTypeToUnit[type]);
      }
    });

    test('declares truthful platform coverage and default units', () {
      expect(
        dataTypeKeysIOS,
        containsAll([
          HealthDataType.RUNNING_SPEED,
          HealthDataType.CYCLING_SPEED,
          HealthDataType.ROWING_SPEED,
          HealthDataType.RUNNING_POWER,
          HealthDataType.CYCLING_POWER,
          HealthDataType.CYCLING_CADENCE,
          HealthDataType.DISTANCE_ROWING,
        ]),
      );
      expect(dataTypeKeysIOS, isNot(contains(HealthDataType.POWER)));
      expect(
        dataTypeKeysAndroid,
        containsAll([
          HealthDataType.SPEED,
          HealthDataType.POWER,
          HealthDataType.CYCLING_CADENCE,
          HealthDataType.DISTANCE_DELTA,
        ]),
      );
      expect(dataTypeKeysAndroid, isNot(contains(HealthDataType.RUNNING_SPEED)));
      expect(dataTypeKeysAndroid, isNot(contains(HealthDataType.CYCLING_POWER)));
      expect(dataTypeKeysAndroid, isNot(contains(HealthDataType.DISTANCE_ROWING)));
      expect(dataTypeToUnit[HealthDataType.POWER], HealthDataUnit.WATT);
      expect(dataTypeToUnit[HealthDataType.CYCLING_CADENCE], HealthDataUnit.REVOLUTIONS_PER_MINUTE);
      expect(dataTypeToUnit[HealthDataType.ROWING_SPEED], HealthDataUnit.METER_PER_SECOND);
      expect(dataTypeToUnit[HealthDataType.DISTANCE_ROWING], HealthDataUnit.METER);
    });
  });
}
