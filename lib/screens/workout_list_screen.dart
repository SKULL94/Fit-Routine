import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/workout_type.dart';
import '../providers/quote/quote_provider.dart';
import '../providers/workout/workout_provider.dart';
import '../widgets/workout_calendar_graph.dart';
import '../widgets/workout_form_dialog.dart';
import 'sign_in_screen.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const SizedBox.shrink(),
          toolbarHeight: 224,
          flexibleSpace: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 56.0, left: 16.0, right: 16.0),
                child: Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final quote = ref.watch(getQuoteProvider);
                        ref.listen(getQuoteProvider, (prev, next) {
                          next.maybeWhen(
                              data: (data) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('New quote: ${data.quote}'),
                                ));
                              },
                              orElse: () {});
                        });
                        return quote.maybeWhen(
                          data: (data) {
                            return Column(
                              children: [
                                Text(
                                  '"${data.quote}"',
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      ref.invalidate(getQuoteProvider);
                                    },
                                    child: const Text("Refresh"))
                              ],
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        );
                      },
                    ),
                    const WorkoutCalendarGraph(),
                  ],
                ),
              ),
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: TabBar(
              tabs: [
                Tab(text: 'Upper Body'),
                Tab(text: 'Lower Body'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _WorkoutList(type: WorkoutType.upperBody),
            _WorkoutList(type: WorkoutType.lowerBody),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddWorkoutDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WorkoutFormDialog(),
    );
  }
}

class _WorkoutList extends ConsumerWidget {
  final WorkoutType type;

  const _WorkoutList({required this.type});

  @override
  Widget build(BuildContext context, ref) {
    final unfilteredWorkout = ref.watch(workoutNotifierProvider);
    final workouts =
        unfilteredWorkout.where((workout) => workout.type == type).toList();
    if (workouts.isEmpty) {
      return const Center(child: Text("No workout data"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          child: ListTile(
            enabled: false,
            title: Text(
              workout.name,
              style: TextStyle(
                decoration: workout.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: workout.isCompleted ? Colors.grey : Colors.white,
              ),
            ),
            subtitle: Text(
              '${workout.sets} sets of ${workout.reps} reps at ${workout.weight} kg',
              style: TextStyle(
                decoration: workout.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: workout.isCompleted ? Colors.grey : Colors.white,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                    value: workout.isCompleted,
                    onChanged: (_) {
                      ref
                          .read(workoutNotifierProvider.notifier)
                          .toggleWorkoutStatus(workout.id);
                    }),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref
                          .read(workoutNotifierProvider.notifier)
                          .removeWorkout(workout.id);
                    }),
              ],
            ),
          ),
        );
      },
    );
  }
}
