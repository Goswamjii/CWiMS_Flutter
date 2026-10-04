import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;
import 'auth_service.dart';
import '../dashboard/dashboard_screen.dart';

enum AuthState { login, signup, success }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthState _state = AuthState.signup;

  void _toLogin() => setState(() => _state = AuthState.login);
  void _toSignup() => setState(() => _state = AuthState.signup);
  void _toSuccess() => setState(() => _state = AuthState.success);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _state == AuthState.login ? const Color(0xFF071D3B) : const Color(0xFFF4F8FC),
      body: Stack(
        children: [
          // Background Waves for Signup/Success
          if (_state != AuthState.login)
            const Positioned.fill(child: _BackgroundWaves()),
          
          SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildCurrentPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_state) {
      case AuthState.login:
        return LoginPage(key: const ValueKey('login'), onSignup: _toSignup);
      case AuthState.signup:
        return SignupPage(key: const ValueKey('signup'), onLogin: _toLogin, onSuccess: _toSuccess);
      case AuthState.success:
        return SuccessPage(key: const ValueKey('success'), onDone: _toLogin);
    }
  }
}

/* =========================================================
                         SIGNUP PAGE
   ========================================================= */

class SignupPage extends ConsumerStatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSuccess;
  const SignupPage({super.key, required this.onLogin, required this.onSuccess});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  String selectedRole = 'Provider/ISP';
  bool isLoading = false;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await ref.read(authServiceProvider).signup(
            fullName: fullNameController.text.trim(),
            email: emailController.text.trim(),
            mobile: mobileController.text.trim(),
            password: passwordController.text,
            role: selectedRole,
          );

      if (mounted) {
        widget.onSuccess();
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map ? e.response?.data['message'] : e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text(message ?? 'Signup failed'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SignupHeader(),
          
          // Form Card
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x15000000),
                  blurRadius: 30,
                  offset: Offset(0, -10),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(26, 35, 26, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create Your Account',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF102D55))),
                  const SizedBox(height: 6),
                  const Text('Join CWiMS and manage your network efficiently.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF526B8C), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 35),
                  
                  AuthField(
                    controller: fullNameController,
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 15),
                  AuthField(
                    controller: mobileController,
                    icon: Icons.phone_outlined,
                    label: 'Mobile Number',
                    hint: 'Enter your mobile number',
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 15),
                  AuthField(
                    controller: emailController,
                    icon: Icons.mail_outline,
                    label: 'Email',
                    hint: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Invalid email' : null,
                  ),
                  const SizedBox(height: 15),
                  AuthField(
                    controller: passwordController,
                    icon: Icons.lock_outline,
                    label: 'Password',
                    hint: 'Create a strong password',
                    obscureText: obscurePassword,
                    validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF16345E), size: 22),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  const Text('Select Role',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF16345E))),
                  const SizedBox(height: 15),
                  
                  Row(
                    children: [
                      RoleButton(
                          title: 'Provider/ISP',
                          icon: Icons.apartment,
                          selected: selectedRole == 'Provider/ISP',
                          onTap: () => setState(() => selectedRole = 'Provider/ISP')),
                      const SizedBox(width: 12),
                      RoleButton(
                          title: 'Technician',
                          icon: Icons.build_outlined,
                          selected: selectedRole == 'Technician',
                          onTap: () => setState(() => selectedRole = 'Technician')),
                      const SizedBox(width: 12),
                      RoleButton(
                          title: 'User',
                          icon: Icons.person_outline,
                          selected: selectedRole == 'User',
                          onTap: () => setState(() => selectedRole = 'User')),
                    ],
                  ),
                  
                  const SizedBox(height: 45),
                  
                  isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF1554A2)))
                      : PrimaryButton(text: 'Sign Up', icon: Icons.arrow_forward, onPressed: _handleSignup),
                  
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(fontSize: 15, color: Color(0xFF526B8C), fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: widget.onLogin,
                        child: const Text('Login',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1554A2))),
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

/* =========================================================
                         LOGIN PAGE
   ========================================================= */

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onSignup;
  const LoginPage({super.key, required this.onSignup});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = true;
  bool isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final response = await ref.read(authServiceProvider).login(
            email: loginController.text.trim(),
            password: passwordController.text,
          );

      if (mounted && response.statusCode == 200) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map ? e.response?.data['message'] : e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(behavior: SnackBarBehavior.floating, backgroundColor: Colors.redAccent, content: Text(message ?? 'Login failed')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const LoginHeader(),
          
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 50, 28, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome Back',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF102D55))),
                  const SizedBox(height: 8),
                  const Text('Login to your CWiMS account',
                      style: TextStyle(fontSize: 15, color: Color(0xFF526B8C), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 45),
                  
                  AuthField(
                    controller: loginController,
                    icon: Icons.person_outline,
                    label: 'Mobile Number / Email',
                    hint: 'Enter your mobile or email',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  AuthField(
                    controller: passwordController,
                    icon: Icons.lock_outline,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: obscurePassword,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF16345E), size: 22),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => rememberMe = !rememberMe),
                        child: Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (v) => setState(() => rememberMe = v!),
                              activeColor: const Color(0xFF1554A2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            const Text('Remember Me',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF17365F))),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text('Forgot Password?',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1554A2))),
                    ],
                  ),
                  
                  const SizedBox(height: 45),
                  
                  isLoading
                      ? const Center(
                          child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFF1554A2)),
                            SizedBox(height: 15),
                            Text('Logging In...',
                                style: TextStyle(color: Color(0xFF1554A2), fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ))
                      : PrimaryButton(text: 'Login', icon: Icons.arrow_forward, onPressed: _handleLogin),
                  
                  const SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(fontSize: 15, color: Color(0xFF526B8C), fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: widget.onSignup,
                        child: const Text('Sign Up',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1554A2))),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 80),
                  const Center(
                      child: Text('Better Networks. Stronger Communities.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF526B8C)))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
                         SUCCESS PAGE
   ========================================================= */

class SuccessPage extends StatefulWidget {
  final VoidCallback onDone;
  const SuccessPage({super.key, required this.onDone});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF1554A2).withOpacity(0.2), blurRadius: 40, spreadRadius: 10)
              ],
            ),
            child: const Icon(Icons.check_circle_rounded, size: 120, color: Color(0xFF1554A2)),
          ),
          const SizedBox(height: 50),
          const Text('Account Created!',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF102D55))),
          const SizedBox(height: 12),
          const Text('Welcome to CWiMS', style: TextStyle(fontSize: 20, color: Color(0xFF526B8C))),
          const SizedBox(height: 80),
          const Text('Redirecting to login...', 
              style: TextStyle(fontSize: 15, color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 30),
          const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1554A2)),
        ],
      ),
    );
  }
}

/* =========================================================
                      SHARED COMPONENTS
   ========================================================= */

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5DFEC), width: 1.8),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF17365F)),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: const Color(0xFF15355F), size: 28),
          ),
          suffixIcon: suffixIcon,
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF486282)),
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8093AC)),
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const RoleButton({super.key, required this.title, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF102D55) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? const Color(0xFF102D55) : const Color(0xFFD5DFEC), width: 1.8),
            boxShadow: selected ? [BoxShadow(color: const Color(0xFF102D55).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: selected ? Colors.white : const Color(0xFF15355F)),
              const SizedBox(height: 4),
              Text(title,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : const Color(0xFF17365F))),
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF102D55), Color(0xFF1554A2)]),
        boxShadow: [BoxShadow(color: const Color(0xFF102D55).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(width: 14),
            Icon(icon, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

/* =========================================================
                      HEADERS
   ========================================================= */

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 70, 25, 0),
      child: Stack(
        children: [
          Positioned(right: -40, top: 40, child: _WifiIllustration()),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.wifi_rounded, color: Color(0xFF1554A2), size: 75),
                SizedBox(width: 12),
                Text('CWiMS',
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Color(0xFF102D55), letterSpacing: -3.0))
              ]),
              Text('Centralized WiFi Management System',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF102D55))),
              SizedBox(height: 70),
              Text('Smarter Network. Better Connectivity.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF526B8C))),
              Text('For a Stronger Tomorrow.', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF526B8C))),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, 
          end: Alignment.bottomCenter, 
          colors: [Color(0xFF071D3B), Color(0xFF102D55)]
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(55)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _AnimatedNetworkNodes()),
          Positioned(right: 0, top: 60, child: _NetworkIllustration()),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
              SizedBox(height: 50),
              Row(children: [
                Icon(Icons.wifi_rounded, color: Colors.white, size: 75),
                SizedBox(width: 12),
                Text('CWiMS', style: TextStyle(fontSize: 62, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -3.0))
              ]),
              Text('Centralized WiFi Management System',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70)),
              SizedBox(height: 55),
              Text('Monitor  ·  Manage  ·  Expand',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFFDCEAFF))),
            ],
          ),
        ],
      ),
    );
  }
}

/* =========================================================
                  VISUAL ILLUSTRATIONS
   ========================================================= */

class _AnimatedNetworkNodes extends StatefulWidget {
  const _AnimatedNetworkNodes();
  @override
  State<_AnimatedNetworkNodes> createState() => _AnimatedNetworkNodesState();
}

class _AnimatedNetworkNodesState extends State<_AnimatedNetworkNodes> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(painter: NodeNetworkPainter(_controller.value));
      },
    );
  }
}

class NodeNetworkPainter extends CustomPainter {
  final double progress;
  NodeNetworkPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1.0;
    final nodePaint = Paint()..color = Colors.white.withOpacity(0.1);
    
    final nodes = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.1),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.9, size.height * 0.7),
    ];

    for (int i = 0; i < nodes.length; i++) {
      final offset = Offset(
        nodes[i].dx + math.sin(progress * 2 * math.pi + i) * 10,
        nodes[i].dy + math.cos(progress * 2 * math.pi + i) * 10,
      );
      canvas.drawCircle(offset, 3, nodePaint);
      for (int j = i + 1; j < nodes.length; j++) {
        final offset2 = Offset(
          nodes[j].dx + math.sin(progress * 2 * math.pi + j) * 10,
          nodes[j].dy + math.cos(progress * 2 * math.pi + j) * 10,
        );
        canvas.drawLine(offset, offset2, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BackgroundWaves extends StatelessWidget {
  const _BackgroundWaves();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: WavePainter());
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD5E5FA).withOpacity(0.4);
    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.75, size.height * 1.0, size.width, size.height * 0.95);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WifiIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 250, height: 260, child: CustomPaint(painter: RouterPainter()));
  }
}

class _NetworkIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 280, height: 280, child: CustomPaint(painter: NetworkPainter()));
  }
}

class RouterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF153F70);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 140, 180, 55), const Radius.circular(15)), paint);
    paint.color = const Color(0xFF09294F);
    canvas.drawRect(Rect.fromLTWH(50, 90, 10, 50), paint);
    canvas.drawRect(Rect.fromLTWH(160, 90, 10, 50), paint);
    paint.color = const Color(0xFF38BDEB);
    canvas.drawCircle(const Offset(100, 168), 5, paint);
    canvas.drawCircle(const Offset(125, 168), 5, paint);
    canvas.drawCircle(const Offset(150, 168), 5, paint);
    final wifiPaint = Paint()..color = const Color(0xFF1762B8).withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 7;
    canvas.drawArc(Rect.fromLTWH(70, 30, 80, 80), 3.65, 2.95, false, wifiPaint);
    canvas.drawArc(Rect.fromLTWH(80, 55, 60, 60), 3.65, 2.95, false, wifiPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 2.0;
    final nodePaint = Paint()..color = const Color(0xFF38BDEB);
    final points = [const Offset(140, 120), const Offset(80, 70), const Offset(200, 60), const Offset(70, 180), const Offset(210, 170)];
    for (final p in points) {
      canvas.drawLine(points[0], p, linePaint);
      canvas.drawCircle(p, 6, nodePaint);
    }
    canvas.drawCircle(const Offset(140, 120), 32, Paint()..color = const Color(0xFF1D6EAF));
    Path house = Path()..moveTo(130, 120)..lineTo(140, 110)..lineTo(150, 120)..lineTo(147, 120)..lineTo(147, 135)..lineTo(133, 135)..lineTo(133, 120)..close();
    canvas.drawPath(house, Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
