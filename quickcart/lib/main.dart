import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'constants/app_colors.dart';
import 'providers/app_state_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuickCartBootstrap());
}

class QuickCartBootstrap extends StatefulWidget {
  const QuickCartBootstrap({super.key});

  @override
  State<QuickCartBootstrap> createState() => _QuickCartBootstrapState();
}

class _QuickCartBootstrapState extends State<QuickCartBootstrap> {
  late final Future<void> _firebaseInit;

  @override
  void initState() {
    super.initState();
    _firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _firebaseInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return ChangeNotifierProvider(
            create: (_) => AppStateProvider(),
            child: const QuickCartApp(),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: AppColors.primaryDark,
            body: Center(
              child: snapshot.hasError
                  ? _StartupError(error: snapshot.error.toString())
                  : const CircularProgressIndicator(color: AppColors.accent),
            ),
          ),
        );
      },
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.accent, size: 44),
          const SizedBox(height: 12),
          const Text(
            'Firebase did not start',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
