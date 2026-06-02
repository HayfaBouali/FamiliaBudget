import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithGoogle();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header violet
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 70, bottom: 32),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(44, 44),
                      painter: _ChartLogoPainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bienvenue à nouveau !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Formulaire
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'exemple@email.com',
                      hintStyle: TextStyle(color: AppTheme.textGrey),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mot de passe
                  const Text(
                    'Mot de passe',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: const TextStyle(color: AppTheme.textGrey),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.textGrey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textGrey,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ),

                  // Message erreur
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.error, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: AppTheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Bouton connexion
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Se connecter'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFE0E4F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ou',
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE0E4F0))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bouton Google
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: auth.isLoading ? null : _loginWithGoogle,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE0E4F0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CustomPaint(
                              painter: _GoogleLogoPainter(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Continuer avec Google',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lien inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas de compte ? ',
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Logo graphique barres
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
      RRect.fromLTRBR(0, size.height * 0.58, size.width * 0.18, size.height, r),
      paintLight,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(size.width * 0.22, size.height * 0.38, size.width * 0.40, size.height, r),
      paintMid,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(size.width * 0.44, size.height * 0.46, size.width * 0.62, size.height, r),
      paintMid,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(size.width * 0.66, size.height * 0.20, size.width * 0.84, size.height, r),
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

// Logo Google
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    final paintGreen = Paint()..color = const Color(0xFF34A853);
    final paintBlue = Paint()..color = const Color(0xFF4285F4);

    canvas.drawArc(rect, 3.14, 1.57, true, paintRed);
    canvas.drawArc(rect, 4.71, 1.57, true, paintYellow);
    canvas.drawArc(rect, 0, 1.1, true, paintGreen);
    canvas.drawArc(rect, 1.1, 2.04, true, paintBlue);

    // Trou blanc
    canvas.drawCircle(center, radius * 0.58, Paint()..color = Colors.white);

    // Barre bleue
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.38,
        size.width * 0.5,
        size.height * 0.24,
      ),
      paintBlue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}