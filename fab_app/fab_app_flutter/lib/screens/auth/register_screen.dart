import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // ── Form state ────────────────────────────────────────────────────
  final _usernameController = TextEditingController();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // ── Entrance animation ────────────────────────────────────────────
  late final AnimationController _animCtrl;

  late final Animation<Offset> _headerSlide;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _field1Fade;
  late final Animation<double> _field2Fade;
  late final Animation<double> _field3Fade;
  late final Animation<double> _buttonFade;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.50),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.00, 0.55, curve: Curves.easeOut),
    ));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.00, 0.38, curve: Curves.easeIn),
    ));

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.10, 0.60, curve: Curves.easeOut),
    ));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.10, 0.48, curve: Curves.easeIn),
    ));

    _field1Fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.28, 0.55, curve: Curves.easeIn),
    ));
    _field2Fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.36, 0.62, curve: Curves.easeIn),
    ));
    _field3Fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.44, 0.70, curve: Curves.easeIn),
    ));
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.55, 0.78, curve: Curves.easeIn),
    ));
    _footerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.68, 0.90, curve: Curves.easeIn),
    ));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).register(
            _userIdController.text.trim(),
            _passwordController.text,
            name: _usernameController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful. Please login.')),
        );
        context.go('/login');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: AnimatedBuilder(
        animation: _animCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              // ── Decorative blobs ──────────────────────────────────
              _buildBackground(),

              // ── Content ───────────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Back button + header
                        SlideTransition(
                          position: _headerSlide,
                          child: FadeTransition(
                            opacity: _headerFade,
                            child: _buildHeader(context),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Form card
                        SlideTransition(
                          position: _cardSlide,
                          child: FadeTransition(
                            opacity: _cardFade,
                            child: _buildFormCard(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login link
                        FadeTransition(
                          opacity: _footerFade,
                          child: TextButton(
                            onPressed:
                                _isLoading ? null : () => context.go('/login'),
                            child: const Text(
                              'Already have an account? Sign in',
                              style: TextStyle(
                                color: Color(0xFFEC4899),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      // Top-left bloom
      Positioned(
        top: -70,
        left: -50,
        child: Container(
          width: 260,
          height: 260,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0x44EC4899), Colors.transparent],
            ),
          ),
        ),
      ),
      // Bottom-right bloom
      Positioned(
        bottom: -30,
        right: -40,
        child: Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0x33F5CBDD), Colors.transparent],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Back navigation
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEDCC5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF8A6070)),
                  SizedBox(width: 4),
                  Text(
                    'Back',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8A6070), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Icon + brand
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage('assets/icon.jpg'),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: const Color(0xFFEC4899).withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withValues(alpha: 0.22),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2E1E26),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Set up your admin credentials',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF9A8090),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error banner
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
            const SizedBox(height: 16),
          ],

          FadeTransition(
            opacity: _field1Fade,
            child: _buildField(
              controller: _usernameController,
              hint: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter your full name' : null,
            ),
          ),

          const SizedBox(height: 14),

          FadeTransition(
            opacity: _field2Fade,
            child: _buildField(
              controller: _userIdController,
              hint: 'User ID (login username)',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter a user ID' : null,
            ),
          ),

          const SizedBox(height: 14),

          FadeTransition(
            opacity: _field3Fade,
            child: _buildPasswordField(),
          ),

          const SizedBox(height: 24),

          FadeTransition(
            opacity: _buttonFade,
            child: _buildCreateButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF2E1E26)),
      decoration: _inputDecoration(hint, icon),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      enabled: !_isLoading,
      validator: (v) => v == null || v.isEmpty ? 'Enter a password' : null,
      style: const TextStyle(fontSize: 15, color: Color(0xFF2E1E26)),
      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: const Color(0xFFB090A0),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB8A0AA)),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFFB090A0)),
      filled: true,
      fillColor: const Color(0xFFF9F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEEDCC5), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEC4899), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRegister,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: _isLoading
              ? const LinearGradient(
                  colors: [Color(0xFFD4A0B8), Color(0xFFD4A0B8)])
              : const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFD43680)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
