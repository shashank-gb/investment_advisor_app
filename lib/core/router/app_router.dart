import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/funds/presentation/fund_detail_screen.dart';
import '../../features/goals/domain/goal_models.dart';
import '../../features/goals/presentation/screens/goal_funds_screen.dart';
import '../../features/goals/presentation/screens/goal_selection_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/portfolio/presentation/portfolio_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/watchlist/presentation/watchlist_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (isLoading) return null;

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/funds/:id',
        builder: (context, state) {
          final fundId = state.pathParameters['id']!;
          return FundDetailScreen(fundId: fundId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'goals',
                    builder: (context, state) => const GoalSelectionScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final goalId = state.pathParameters['id']!;
                          final extra = state.extra as ({InvestmentGoal goal, String risk})?;
                          return GoalFundsScreen(
                            goalId: goalId,
                            risk: extra?.risk ?? 'MEDIUM',
                            goal: extra?.goal,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/portfolio',
                builder: (context, state) => const PortfolioScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/watchlist',
                builder: (context, state) => const WatchlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
