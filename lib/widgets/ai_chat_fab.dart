import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/screens/main/ai_chat_screen.dart';

/// زر عائم متطور لمساعد الرياضيات الذكي (AI Assistant FAB).
/// يتميز بتأثيرات بصرية احترافية:
/// - نبض وإشعاع ضوئي تفاعلي (Ambient Glowing Pulse).
/// - تدرج لوني ذكي متناسق مع الثيم العام (Light / Dark).
/// - حركة دوران وتلألؤ ناعمة لأيقونة الذكاء الاصطناعي (Sparkle & Shimmer).
/// - تفاعل لمسي ناعم (Haptic Feedback + Bouncy Scale).
/// - انتقال انسيابي وسلس بين وضعي التمدد والطي (Expanded / Collapsed).
class AiChatFab extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback? onTap;
  final Object? heroTag;
  final String label;
  final String tooltip;

  const AiChatFab({
    super.key,
    this.isCollapsed = false,
    this.onTap,
    this.heroTag = 'aiChatFab',
    this.label = 'مساعد الرياضيات',
    this.tooltip = 'اسأل مساعد الرياضيات الذكي',
  });

  @override
  State<AiChatFab> createState() => _AiChatFabState();
}

class _AiChatFabState extends State<AiChatFab> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _sparkleController;
  late final Animation<double> _sparkleAnimation;

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. متحكم النبض الضوئي والتوهج المستمر
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );

    // 2. متحكم تلألؤ أيقونة الذكاء الاصطناعي
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _sparkleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: -0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 40,
      ),
    ]).animate(_sparkleController);

    // 3. متحكم الاستجابة اللمسية للضغط (Bouncy Tap Scale)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.forward();
  }

  void _handleTapCancel() {
    _scaleController.forward();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Components.push(
        context: context,
        widget: const AiChatScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PlatformCubit.get(context);
    final isDark = cubit.isDarkMode;
    final primaryColor = Components.setBgColor(isDark);

    // توليد ألوان تدرج متناغمة مع اللون الأساسي للتطبيق ولمسة الذكاء الاصطناعي
    final hsl = HSLColor.fromColor(primaryColor);
    final lighterColor = hsl
        .withLightness((hsl.lightness + 0.14).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.1).clamp(0.0, 1.0))
        .toColor();
    final accentAiColor = hsl
        .withHue((hsl.hue + 25) % 360)
        .withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0))
        .toColor();

    return Hero(
      tag: widget.heroTag ?? 'aiChatFab',
      child: Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseAnimation,
            _sparkleAnimation,
            _scaleAnimation,
          ]),
          builder: (context, child) {
            final pulseVal = _pulseAnimation.value;
            final glowAlpha =
                isDark ? 0.35 + (0.25 * pulseVal) : 0.30 + (0.20 * pulseVal);
            final blurRad = 10.0 + (8.0 * pulseVal);
            final spreadRad = 0.5 + (2.0 * pulseVal);

            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: _handleTap,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.fastOutSlowIn,
                  height: 54,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isCollapsed ? 15 : 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        lighterColor,
                        primaryColor,
                        accentAiColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.32),
                      width: 1.3,
                    ),
                    boxShadow: [
                      // توهج ملون نابض للذكاء الاصطناعي
                      BoxShadow(
                        color: primaryColor.withValues(alpha: glowAlpha),
                        blurRadius: blurRad,
                        spreadRadius: spreadRad,
                        offset: const Offset(0, 4),
                      ),
                      // ظل خلفي ناعم للعمق
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.45 : 0.20),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // أيقونة الذكاء الاصطناعي المتلألئة
                      Transform.rotate(
                        angle: _sparkleAnimation.value * math.pi,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // وهج مصغر خلف الأيقونة
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(
                                  alpha: 0.15 + (0.15 * pulseVal),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),

                      // النص وشارة الذكاء الاصطناعي في حالة التمدد
                      ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          alignment: AlignmentDirectional.centerStart,
                          child: widget.isCollapsed
                              ? const SizedBox.shrink()
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // شارة الذكاء الاصطناعي AI Chip
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.22),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.35),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Text(
                                        'AI',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
