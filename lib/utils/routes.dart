import 'package:flutter/material.dart';
import 'package:tifawt/screens/admin/manage_users_screen.dart';
import 'package:tifawt/screens/auth/delete_account_screen.dart';

import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/proverb_details_screen.dart';
import '../screens/home/favorites_screen.dart';
import '../screens/home/bookmarks_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/add_proverb_screen.dart';
import '../screens/admin/manage_categories_screen.dart';
import '../screens/admin/manage_proverbs_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/settings/rate_app_screen.dart';
import '../screens/settings/feedback_screen.dart';
import '../screens/settings/terms_service_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';
import '../screens/settings/help_center_screen.dart';

import 'constants.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppConstants.splashRoute: (context) => const SplashScreen(),
      AppConstants.loginRoute: (context) => const LoginScreen(),
      AppConstants.signupRoute: (context) => const SignupScreen(),
      AppConstants.forgotPasswordRoute:
          (context) => const ForgotPasswordScreen(),
      AppConstants.homeRoute: (context) => const HomeScreen(),
      AppConstants.proverbDetailsRoute:
          (context) => const ProverbDetailsScreen(),
      AppConstants.favoritesRoute: (context) => const FavoritesScreen(),
      AppConstants.bookmarksRoute: (context) => const BookmarksScreen(),
      AppConstants.profileRoute: (context) => const ProfileScreen(),
      AppConstants.settingsRoute: (context) => const SettingsScreen(),
      AppConstants.adminDashboardRoute: (context) => const AdminDashboard(),
      AppConstants.addProverbRoute: (context) => const AddProverbScreen(),
      AppConstants.manageCategoriesRoute:
          (context) => const ManageCategoriesScreen(),
      AppConstants.manageProverbsRoute:
          (context) => const ManageProverbsScreen(),
      AppConstants.manageUsersRoute: (context) => const ManageUsersScreen(),
      AppConstants.changePasswordRoute:
          (context) => const ChangePasswordScreen(),
      AppConstants.rateAppRoute: (context) => const RateAppScreen(),
      AppConstants.feedbackRoute: (context) => const FeedbackScreen(),
      AppConstants.termsServiceRoute: (context) => const TermsServiceScreen(),
      AppConstants.privacyPolicyRoute: (context) => const PrivacyPolicyScreen(),
      AppConstants.helpCenterRoute: (context) => const HelpCenterScreen(),
      AppConstants.deleteAccountRoute: (context) => const DeleteAccountScreen(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Handle route parameters
    switch (settings.name) {
      case AppConstants.proverbDetailsRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final proverbId = args?['proverbId'] as String?;
        return MaterialPageRoute(
          builder: (context) => ProverbDetailsScreen(proverbId: proverbId),
        );

      case AppConstants.editProverbRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final proverbId = args?['proverbId'] as String?;
        return MaterialPageRoute(
          builder: (context) => AddProverbScreen(proverbId: proverbId),
        );

      default:
        // Get route from the routes map
        if (getRoutes().containsKey(settings.name)) {
          return MaterialPageRoute(
            builder: getRoutes()[settings.name]!,
            settings: settings,
          );
        }

        // If route is not found, redirect to home
        return MaterialPageRoute(builder: (context) => const HomeScreen());
    }
  }
}
