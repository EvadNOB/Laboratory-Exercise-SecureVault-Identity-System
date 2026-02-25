import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/security_service.dart';
import 'services/session_service.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/profile_view.dart';
import 'views/forgot_password_view.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only if not already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, continue
    print('Firebase init note: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: 'SecureVault',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: themeViewModel.themeMode,
            home: const AppStartupPage(),
            routes: {
              '/login': (context) => const LoginView(),
              '/register': (context) => const RegisterView(),
              '/profile': (context) => const ProfileView(),
              '/dashboard': (context) => const ProfileView(),
              '/forgot-password': (context) => const ForgotPasswordView(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(builder: (context) => const LoginView());
            },
          );
        },
      ),
    );
  }
}

class AppStartupPage extends StatefulWidget {
  const AppStartupPage({Key? key}) : super(key: key);

  @override
  State<AppStartupPage> createState() => _AppStartupPageState();
}

class _AppStartupPageState extends State<AppStartupPage> {
  final _authService = AuthService();
  final _biometricService = BiometricService();
  final _securityService = SecurityService();
  final _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Small delay to ensure widget is fully mounted
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check for root/jailbreak
    final isDeviceRooted = await _securityService.isDeviceRooted();
    if (isDeviceRooted && mounted) {
      _showSecurityWarning();
    }

    // Check if user has valid token
    final hasToken = await _authService.hasValidToken();

    if (!mounted) return;

    if (hasToken) {
      // User is authenticated, check biometric
      final isBiometricEnabled = await _biometricService.isBiometricEnabled();

      if (isBiometricEnabled && mounted) {
        // Try biometric authentication
        final biometricAuth = await _biometricService.authenticateUser(
          reason: 'Authenticate to access your secure account',
        );

        if (biometricAuth && mounted) {
          _navigationToProfile();
        } else if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else if (mounted) {
        _navigationToProfile();
      }
    } else if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigationToProfile() {
    // Start session timer
    _sessionService.startSession(() {
      // Session timeout callback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });

    Navigator.of(context).pushReplacementNamed('/profile');
  }

  void _showSecurityWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Security Warning'),
            ],
          ),
          content: const Text(
            'This device appears to be rooted or jailbroken. '
            'This compromises the security of your sensitive information. '
            'Continue at your own risk.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.lock, size: 50, color: Colors.deepPurple),
            ),
            const SizedBox(height: 24),
            const Text(
              'SecureVault',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
