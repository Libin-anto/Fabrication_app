import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Main sequencer – 3 200 ms total
  late final AnimationController _mainCtrl;
  // Ambient orb float – loops independently
  late final AnimationController _orbCtrl;

  // ── Phase timings (fractions of _mainCtrl) ──────────────────────────
  // 0.00-0.12  background + orbs fade in
  // 0.00-0.22  icon scale-in + fade
  // 0.22-0.46  F A B drop from top (staggered bounce)
  // 0.44-0.65  pink underline sweeps right
  // 0.50-0.65  MANAGEMENT slides up + fades
  // 0.68-0.80  tagline fades in
  // 0.88-1.00  cream exit overlay fades in

  late final Animation<double> _bgFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _lettersOpacity;
  late final Animation<double> _fDrop;
  late final Animation<double> _aDrop;
  late final Animation<double> _bDrop;
  late final Animation<double> _lineProgress;
  late final Animation<double> _mgmtDrop;
  late final Animation<double> _mgmtOpacity;
  late final Animation<double> _taglineFade;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    // ── Build all animations ─────────────────────────────────────────
    _bgFade = _interval(0.00, 0.10, Curves.easeIn);
    _iconOpacity = _interval(0.00, 0.14, Curves.easeIn);
    _iconScale = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.00, 0.22, curve: Curves.easeOutBack),
      ),
    );

    _lettersOpacity = _interval(0.22, 0.34, Curves.easeIn);
    _fDrop = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.22, 0.40, curve: Curves.easeOutBounce),
      ),
    );
    _aDrop = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.27, 0.45, curve: Curves.easeOutBounce),
      ),
    );
    _bDrop = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.32, 0.50, curve: Curves.easeOutBounce),
      ),
    );

    _lineProgress = _interval(0.44, 0.65, Curves.easeInOut);

    _mgmtOpacity = _interval(0.50, 0.66, Curves.easeIn);
    _mgmtDrop = Tween<double>(begin: 28, end: 0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.50, 0.65, curve: Curves.easeOut),
      ),
    );

    _taglineFade = _interval(0.68, 0.80, Curves.easeIn);
    _exitFade = _interval(0.88, 1.00, Curves.easeIn);

    _mainCtrl.forward().then((_) => _checkAuthAndNavigate());
  }

  /// Shortcut: build a 0→1 opacity animation over a given interval.
  Animation<double> _interval(double begin, double end, Curve curve) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: Interval(begin, end, curve: curve),
      ),
    );
  }

  void _checkAuthAndNavigate() {
    final authState = ref.read(authStateProvider);
    if (authState.isLoading || authState.value == false) {
      ref.listenManual(authStateProvider, (_, next) {
        if (!next.isLoading && mounted) {
          context.go(next.value == true ? '/dashboard' : '/login');
        }
      }, fireImmediately: true);
    } else {
      if (mounted) {
        context.go(authState.value == true ? '/dashboard' : '/login');
      }
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D14),
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainCtrl, _orbCtrl]),
        builder: (context, _) {
          final orb = _orbCtrl.value; // 0→1→0 float

          return Stack(
            children: [
              // ── Ambient glow orbs ──────────────────────────────────
              Opacity(
                opacity: _bgFade.value,
                child: Stack(children: [
                  // Large pink orb — top right
                  Positioned(
                    top: -110 + orb * 18,
                    right: -90,
                    child: Container(
                      width: 340,
                      height: 340,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFEC4899).withValues(alpha: 0.38),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Soft blush orb — bottom left
                  Positioned(
                    bottom: 60 + orb * -14,
                    left: -70,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF5CBDD).withValues(alpha: 0.22),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tiny accent orb — bottom right
                  Positioned(
                    bottom: 140 + orb * 10,
                    right: 30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFEC4899).withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ),

              // ── Central content ────────────────────────────────────
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo icon ────────────────────────────────────
                    Opacity(
                      opacity: _iconOpacity.value,
                      child: Transform.scale(
                        scale: _iconScale.value,
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: AssetImage('assets/icon.jpg'),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: const Color(0xFFEC4899)
                                  .withValues(alpha: 0.45 + orb * 0.25),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEC4899)
                                    .withValues(alpha: 0.40 + orb * 0.20),
                                blurRadius: 26 + orb * 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ── FAB letters + sweeping underline ─────────────
                    SizedBox(
                      width: 260,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Letters row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _letter('F', _fDrop.value),
                              _letter('A', _aDrop.value),
                              _letter('B', _bDrop.value),
                            ],
                          ),
                          // Pink neon underline
                          if (_lineProgress.value > 0)
                            Container(
                              width: 260 * _lineProgress.value,
                              height: 3.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEC4899),
                                    Color(0xFFF5CBDD),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEC4899)
                                        .withValues(alpha: 0.70),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── MANAGEMENT ───────────────────────────────────
                    Transform.translate(
                      offset: Offset(0, _mgmtDrop.value),
                      child: Opacity(
                        opacity: _mgmtOpacity.value,
                        child: const Text(
                          'MANAGEMENT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFFCDB0C2),
                            letterSpacing: 7.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Tagline ──────────────────────────────────────
                    Opacity(
                      opacity: _taglineFade.value,
                      child: const Text(
                        'Fabrication Floor Intelligence',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF7A607A),
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Exit: cream wipe-out ───────────────────────────────
              if (_exitFade.value > 0)
                Opacity(
                  opacity: _exitFade.value,
                  child: Container(color: const Color(0xFFFAF6F0)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _letter(String char, double dropOffset) {
    return Transform.translate(
      offset: Offset(0, dropOffset),
      child: Opacity(
        opacity: _lettersOpacity.value.clamp(0.0, 1.0),
        child: Text(
          char,
          style: TextStyle(
            fontSize: 90,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            height: 1.05,
            shadows: [
              Shadow(
                color: const Color(0xFFEC4899).withValues(alpha: 0.55),
                blurRadius: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
