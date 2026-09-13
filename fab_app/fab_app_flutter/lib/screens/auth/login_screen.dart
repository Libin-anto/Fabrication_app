import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Form state ────────────────────────────────────────────────────
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // ── Entrance animation ────────────────────────────────────────────
  // Total: 850 ms. Each element staggers in from its own offset.
  late final AnimationController _animCtrl;

  late final Animation<Offset> _headerSlide;
  late final Animation<double> _headerFade;

  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  late final Animation<double> _field1Fade;
  late final Animation<double> _field2Fade;
  late final Animation<double> _buttonFade;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Header (logo + title) slides down from above
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.55),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.00, 0.55, curve: Curves.easeOut),
    ));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.00, 0.40, curve: Curves.easeIn),
    ));

    // Card + form slides up from below
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.12, 0.62, curve: Curves.easeOut),
    ));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.12, 0.50, curve: Curves.easeIn),
    ));

    // Fields stagger inside the card
    _field1Fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.30, 0.60, curve: Curves.easeIn),
    ));
    _field2Fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.40, 0.68, curve: Curves.easeIn),
    ));
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.52, 0.78, curve: Curves.easeIn),
    ));
    _footerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.65, 0.90, curve: Curves.easeIn),
    ));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).login(
            _usernameController.text.trim(),
            _passwordController.text,
          );
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        body: AnimatedBuilder(
          animation: _animCtrl,
          builder: (context, _) {
            return Stack(
              children: [
                // ── Decorative background ───────────────────────────
                _buildBackground(),

                // ── Scrollable content ──────────────────────────────
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 56),

                          // ── Header: logo + brand ──────────────────
                          SlideTransition(
                            position: _headerSlide,
                            child: FadeTransition(
                              opacity: _headerFade,
                              child: _buildHeader(),
                            ),
                          ),

                          const SizedBox(height: 44),

                          // ── Form card ─────────────────────────────
                          SlideTransition(
                            position: _cardSlide,
                            child: FadeTransition(
                              opacity: _cardFade,
                              child: _buildFormCard(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Footer link ───────────────────────────
                          FadeTransition(
                            opacity: _footerFade,
                            child: TextButton(
                              onPressed:
                                  _isLoading ? null : () => context.go('/register'),
                              child: const Text(
                                "Don't have an account? Create one",
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
      ),
    );
  }

  // ── Decorative soft-pink blobs in the background ──────────────────
  Widget _buildBackground() {
    return Stack(
      children: [
        // Top-right blush bloom
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x55EC4899), Colors.transparent],
              ),
            ),
          ),
        ),
        // Bottom-left secondary bloom
        Positioned(
          bottom: -40,
          left: -50,
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
      ],
    );
  }

  // ── Logo + title ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo ring with pink glow
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage('assets/icon.jpg'),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'FAB',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2E1E26),
            letterSpacing: 4,
          ),
        ),
        const Text(
          'MANAGEMENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8A6070),
            letterSpacing: 5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFFF5CBDD)],
            ),
          ),
        ),
      ],
    );
  }

  // ── Form card with staggered fields ──────────────────────────────
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
          const Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E1E26),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in to your admin account',
            style: TextStyle(fontSize: 13, color: Color(0xFF9A8090)),
          ),

          const SizedBox(height: 24),

          // Error banner
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
            const SizedBox(height: 16),
          ],

          // ── Username field ────────────────────────────────────────
          FadeTransition(
            opacity: _field1Fade,
            child: _buildField(
              controller: _usernameController,
              hint: 'User ID',
              icon: Icons.person_outline,
              validator: (v) => v == null || v.isEmpty ? 'Enter your user ID' : null,
              enabled: !_isLoading,
            ),
          ),

          const SizedBox(height: 14),

          // ── Password field ────────────────────────────────────────
          FadeTransition(
            opacity: _field2Fade,
            child: _buildPasswordField(),
          ),

          const SizedBox(height: 24),

          // ── Login button ──────────────────────────────────────────
          FadeTransition(
            opacity: _buttonFade,
            child: _buildLoginButton(),
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
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF2E1E26)),
      decoration: InputDecoration(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      enabled: !_isLoading,
      validator: (v) => v == null || v.isEmpty ? 'Enter your password' : null,
      style: const TextStyle(fontSize: 15, color: Color(0xFF2E1E26)),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: const TextStyle(color: Color(0xFFB8A0AA)),
        prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFFB090A0)),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: const Color(0xFFB090A0),
          ),
        ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: _isLoading
              ? const LinearGradient(colors: [Color(0xFFD4A0B8), Color(0xFFD4A0B8)])
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
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
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
