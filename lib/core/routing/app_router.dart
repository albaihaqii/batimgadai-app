import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/verification_screen.dart';
import '../../features/auth/presentation/pin_screen.dart';
import '../../features/auth/presentation/terms_screen.dart';
import '../../features/auth/presentation/verify_account_screen.dart';
import '../../features/auth/presentation/verify_success_screen.dart';
import '../../features/main/presentation/main_screen.dart'; // <-- Panggil MainScreen di sini
import '../../features/loan/presentation/loan_screen.dart';
import '../../features/loan/presentation/loan_detail_screen.dart';
import '../../features/loan/domain/loan_model.dart';
import '../../features/profile/presentation/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/verification',
      name: 'verification',
      builder: (context, state) {
        final phone = state.extra as String;
        return VerificationScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/pin',
      name: 'pin',
      builder: (context, state) {
        if (state.extra is Map<String, dynamic>) {
          final args = state.extra as Map<String, dynamic>;
          return PinScreen(
            mode: args['mode'] as PinMode,
            createdPin: args['createdPin'] as String?,
          );
        } else if (state.extra == 'create') {
          return const PinScreen(mode: PinMode.create);
        }
        return const PinScreen(mode: PinMode.create);
      },
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/verify-account',
      name: 'verifyAccount',
      builder: (context, state) => const VerifyAccountScreen(),
    ),
    GoRoute(
      path: '/verify-success',
      name: 'verifySuccess',
      builder: (context, state) => const VerifySuccessScreen(),
    ),
    // ── Route Beranda (Diganti ke MainScreen) ──
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/loan',
      name: 'loan',
      builder: (context, state) => const LoanScreen(),
    ),
    // ── Route Rincian Barang (Halaman 2) ──
    GoRoute(
      path: '/loan-detail',
      name: 'loanDetail',
      builder: (context, state) {
        final loanItem = state.extra as LoanItem;
        return LoanDetailScreen(loan: loanItem);
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
