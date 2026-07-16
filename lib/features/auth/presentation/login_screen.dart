import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shifting_wallah_driver/app/router.dart';
import 'package:shifting_wallah_driver/features/auth/data/driver_auth_repository.dart';
import 'package:shifting_wallah_driver/features/auth/providers/driver_auth_provider.dart';
import 'package:shifting_wallah_driver/shared/widgets/responsive_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(driverAuthProvider.notifier);
    setState(() {
      _emailError = notifier.validateEmail(_emailController.text);
      _passwordError = notifier.validatePassword(_passwordController.text);
    });
    if (_emailError != null || _passwordError != null) return;

    await notifier.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(driverAuthProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is AsyncLoading && mounted) context.goToHome();
        },
        error: (error, _) {
          final message = error is DriverAuthException
              ? error.message
              : error.toString();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });

    final authState = ref.watch(driverAuthProvider);
    final isLoading = authState.isLoading;

    return ResponsiveScaffold(
      title: 'Login',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Driver Login', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _emailError,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            enabled: !isLoading,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _passwordError,
            ),
            onSubmitted: (_) => isLoading ? null : _submit(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Login'),
          ),
        ],
      ),
    );
  }
}
