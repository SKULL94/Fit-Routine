import 'dart:async' show FutureOr;

import 'package:fit_routine_app/core/configs/router-configs/route_names.dart';
import 'package:fit_routine_app/providers/auth/auth_provider.dart';
import 'package:fit_routine_app/providers/onboarding/onboarding_provider.dart';
import 'package:fit_routine_app/screens/main_screen.dart';
import 'package:fit_routine_app/screens/onboarding_screen.dart';
import 'package:fit_routine_app/screens/profile_screen.dart';
import 'package:fit_routine_app/screens/sign_in_screen.dart';
import 'package:fit_routine_app/screens/sign_up_screen.dart';
import 'package:fit_routine_app/screens/workout_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
part 'redirection.dart';

final routeProvider = Provider((ref) {
  return GoRouter(
      initialLocation: "/workout-list",
      errorBuilder: (context, state) {
        return const Scaffold(
          body: Center(
            child: Text("Page not found"),
          ),
        );
      },
      redirect: (context, state) {
        final redirect = handleRedirect(context, state, ref);
        return redirect;
      },
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
            name: RouteNames.onboarding,
            path: "/onboarding",
            builder: (context, state) => const OnboardingScreen()),
        GoRoute(
            name: RouteNames.signUp,
            path: "/sign-up",
            builder: (context, state) => const SignUpScreen()),
        GoRoute(
            name: RouteNames.signIn,
            path: "/sign-in",
            builder: (context, state) => const SignInScreen()),
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainScreen(
                navigationShell: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                    name: RouteNames.workoutList,
                    path: "/workout-list",
                    builder: (context, state) => const WorkoutListScreen()),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                    name: RouteNames.profile,
                    path: "/profile",
                    builder: (context, state) => const ProfileScreen()),
              ])
            ])
      ]);
});
