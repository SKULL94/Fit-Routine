import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../enums/workout_type.dart';
import '../../models/workout/workout.dart';

part 'workout_provider.g.dart';

@Riverpod(keepAlive: true)
class WorkoutNotifier extends _$WorkoutNotifier {
  final _uuid = const Uuid();

  @override
  List<Workout> build() {
    return [];
  }

  void addWorkout(
      String name, double weight, int reps, int sets, WorkoutType type) {
    state = [
      ...state,
      Workout(
        id: _uuid.v4(),
        name: name,
        weight: weight,
        reps: reps,
        sets: sets,
        isCompleted: false,
        type: type,
        createdAt: DateTime.now(),
        completedAt: null,
      ),
    ];
  }

  void toggleWorkoutStatus(String id) {
    state = [
      for (final workout in state)
        if (workout.id == id)
          workout.copyWith(
            isCompleted: !workout.isCompleted,
            completedAt: workout.isCompleted ? null : DateTime.now(),
          )
        else
          workout,
    ];
  }

  void removeWorkout(String id) {
    state = state.where((workout) => workout.id != id).toList();
  }
}
