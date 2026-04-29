import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// Fullscreen overlay shown when the app lock is triggered.
/// Authenticates via biometrics or device credential (PIN/pattern/password).
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _auth = LocalAuthentication();
  bool _authenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _authenticating = true;
      _errorMessage = null;
    });
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Déverrouillez pour accéder à la bibliothèque',
      );
      if (authenticated && mounted) {
        widget.onUnlocked();
      } else if (mounted) {
        setState(() => _errorMessage = 'Authentification échouée. Réessayez.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erreur : ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 24),
              const Text(
                'Bibliothèque BD',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Déverrouillez pour continuer'),
              const SizedBox(height: 32),
              if (_authenticating)
                const CircularProgressIndicator()
              else ...[
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Déverrouiller'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
