class AppConstants {
  // App info
  static const String appName = 'Welcome to Tifawt';
  static const String appVersion = '1.0.0';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String proverbsCollection = 'proverbs';
  static const String categoriesCollection = 'categories';

  // SharedPreferences keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';

  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';
  static const String proverbDetailsRoute = '/proverb-details';
  static const String favoritesRoute = '/favorites';
  static const String bookmarksRoute = '/bookmarks';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String adminDashboardRoute = '/admin-dashboard';
  static const String addProverbRoute = '/add-proverb';
  static const String editProverbRoute = '/edit-proverb';
  static const String manageCategoriesRoute = '/manage-categories';
  static const String manageProverbsRoute = '/manage-proverbs';
  static const String manageUsersRoute = '/manage-users';

  // Animation durations
  static const int splashDuration = 2000; // milliseconds

  // Placeholder images
  static const String placeholderImageUrl = 'assets/images/placeholder.jpg';
  static const String defaultAvatarUrl = 'assets/images/default_avatar.png';

  // Error messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String authErrorMessage =
      'Authentication failed. Please try again.';

  // Success messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String signupSuccessMessage = 'Account created successfully!';
  static const String resetPasswordSuccessMessage =
      'Password reset email sent!';
  static const String profileUpdateSuccessMessage =
      'Profile updated successfully!';
  static const String passwordChangeSuccessMessage =
      'Password changed successfully!';

  // Validation messages
  static const String emptyFieldError = 'This field cannot be empty';
  static const String invalidEmailError = 'Please enter a valid email';
  static const String shortPasswordError =
      'Password must be at least 6 characters';
  static const String passwordMismatchError = 'Passwords do not match';

  // Bottom navigation bar items
  static const int homeNavIndex = 0;
  static const int favoritesNavIndex = 1;
  static const int bookmarksNavIndex = 2;
  static const int profileNavIndex = 3;
}
