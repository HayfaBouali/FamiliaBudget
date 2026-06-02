import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Vérifier si l'utilisateur est déjà connecté
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    // Vérifier le token sauvegardé
    await context.read<AuthProvider>().checkAuth();

    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          // Cercle décoratif haut droite
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Cercle décoratif bas gauche
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Cercle décoratif bas droite
          Positioned(
            bottom: 80,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Contenu principal
          FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(54, 54),
                          painter: _ChartLogoPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nom app
                    const Text(
                      'FamiliaBudget',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gérez votre budget en famille',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Loader points
                    _DotsLoader(),
                  ],
                ),
              ),
            ),
          ),

         
        ],
      ),
    );
  }
}

// Logo graphique
class _ChartLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final paintLight = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final paintMid = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const r = Radius.circular(3);

    canvas.drawRRect(
      RRect.fromLTRBR(0, size.height * 0.58, size.width * 0.18,
          size.height, r),
      paintLight,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(size.width * 0.22, size.height * 0.38,
          size.width * 0.40, size.height, r),
      paintMid,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(size.width * 0.44, size.height * 0.46,
          size.width * 0.62, size.height, r),
      paintMid,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(size.width * 0.66, size.height * 0.20,
          size.width * 0.84, size.height, r),
      paintWhite,
    );

    final path = Path()
      ..moveTo(size.width * 0.09, size.height * 0.54)
      ..lineTo(size.width * 0.31, size.height * 0.33)
      ..lineTo(size.width * 0.53, size.height * 0.40)
      ..lineTo(size.width * 0.75, size.height * 0.16);

    canvas.drawPath(path, paintLine);
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.16),
      3.5,
      paintWhite,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Loader 3 points animés
class _DotsLoader extends StatefulWidget {
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
            final opacity =
                (0.3 + 0.7 * (1 - (t * 2 - 1).abs())).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == 0 ? 10 : 7,
              height: i == 0 ? 10 : 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}