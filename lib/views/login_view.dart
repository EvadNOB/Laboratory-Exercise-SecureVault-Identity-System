import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_vault/viewmodels/auth_viewmodel.dart';
import 'package:secure_vault/utils/validators.dart';
import 'package:secure_vault/views/widgets/custom_button.dart';
import 'package:secure_vault/views/widgets/custom_textfield.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureVault'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthViewModel>(
            builder: (context, authViewModel, _) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Welcome Back',
                      style: ThemeData.light().textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign in to your secure account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email),
                      validator: Validators.validateEmail,
                      hintText: 'Enter your email',
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                      hintText: 'Enter your password',
                    ),
                    const SizedBox(height: 30),
                    if (authViewModel.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: authViewModel.isLocked
                              ? Colors.red.shade100
                              : (authViewModel.errorMessage!.contains(
                                      'successful',
                                    )
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authViewModel.errorMessage!,
                          style: TextStyle(
                            color: authViewModel.isLocked
                                ? Colors.red.shade700
                                : (authViewModel.errorMessage!.contains(
                                        'successful',
                                      )
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Sign In',
                      isLoading: authViewModel.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await authViewModel.login(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                          if (success && mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/profile',
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      text: 'Sign In with Google',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      isLoading: authViewModel.isLoading,
                      onPressed: () async {
                        final success = await authViewModel.googleLogin();
                        if (success && mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/profile',
                            (route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      text: 'Sign In with Facebook',
                      backgroundColor: const Color(0xFF1877F2),
                      textColor: Colors.white,
                      isLoading: authViewModel.isLoading,
                      onPressed: () async {
                        final success = await authViewModel.facebookLogin();
                        if (success && mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/profile',
                            (route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Fingerprint Sign-In Button
                    FutureBuilder<bool>(
                      future: authViewModel.isBiometricAvailable(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data == true) {
                          return Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        'or',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: authViewModel.isLoading
                                    ? null
                                    : () async {
                                        final success =
                                            await authViewModel
                                                .biometricSignIn();
                                        if (success && mounted) {
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                            '/profile',
                                            (route) => false,
                                          );
                                        }
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: authViewModel.isLoading
                                        ? Colors.grey.shade100
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.fingerprint,
                                        color: authViewModel.isLoading
                                            ? Colors.grey
                                            : Colors.deepPurple,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Sign In with Fingerprint',
                                        style: TextStyle(
                                          color: authViewModel.isLoading
                                              ? Colors.grey
                                              : Colors.deepPurple,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          child: const Text(
                            'Register here',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/forgot-password');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
