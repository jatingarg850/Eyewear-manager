import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import '../services/customer_service.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

/// BillCompletionScreen - Final step of Create Bill flow
/// Saves bill to database, increments customer visit count, and shows success animation
/// Features:
/// - Save bill to database with all details
/// - Increment customer visit count and update last visit timestamp
/// - Show success animation (checkmark with confetti effect)
/// - Navigate back to bills list
class BillCompletionScreen extends StatefulWidget {
  const BillCompletionScreen({super.key});

  @override
  State<BillCompletionScreen> createState() => _BillCompletionScreenState();
}

class _BillCompletionScreenState extends State<BillCompletionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    // Process bill completion
    _completeBill();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Complete the bill and save to database
  Future<void> _completeBill() async {
    try {
      final billProvider = context.read<BillProvider>();
      final currentBill = billProvider.currentBill;

      if (currentBill == null) {
        throw Exception('No bill in progress');
      }

      // Save bill to database
      await billProvider.createBill(currentBill);

      // Increment customer visit count
      final customerService = CustomerService();
      await customerService.incrementVisitCount(currentBill.customerId);

      // Start success animation
      setState(() {
        _isProcessing = false;
      });

      _animationController.forward();

      // Navigate back to bills list after animation
      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        // Clear the bill provider's current bill
        billProvider.clearCurrentBill();

        // Navigate back to bills screen, removing all create-bill routes
        Navigator.of(context).popUntil((route) => route.settings.name == '/bills' || route.isFirst);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation during processing
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Center(
            child: _isProcessing
                ? _buildProcessingView()
                : _hasError
                    ? _buildErrorView()
                    : _buildSuccessView(),
          ),
        ),
      ),
    );
  }

  /// Build processing view
  Widget _buildProcessingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
        const SizedBox(height: AppTheme.spacing24),
        const Text(
          'Processing bill...',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  /// Build error view
  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: AppTheme.spacing24),
          const Text(
            'Failed to complete bill',
            style: TextStyle(
              fontFamily: AppTheme.headingFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            _errorMessage,
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 14,
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing32,
                vertical: AppTheme.spacing16,
              ),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  /// Build success view with animation
  Widget _buildSuccessView() {
    return Stack(
      children: [
        // Confetti particles
        ...List.generate(20, (index) {
          return _ConfettiParticle(
            animation: _animationController,
            index: index,
          );
        }),
        // Success content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _checkmarkAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _CheckmarkPainter(
                          progress: _checkmarkAnimation.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing32),
              const Text(
                'Bill Created Successfully!',
                style: TextStyle(
                  fontFamily: AppTheme.headingFont,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Redirecting to bills list...',
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 14,
                  color: AppTheme.textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for animated checkmark
class _CheckmarkPainter extends CustomPainter {
  final double progress;

  _CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Checkmark path
    final p1 = Offset(size.width * 0.3, size.height * 0.5);
    final p2 = Offset(size.width * 0.45, size.height * 0.65);
    final p3 = Offset(size.width * 0.7, size.height * 0.35);

    if (progress < 0.5) {
      // Draw first part of checkmark
      final t = progress * 2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    } else {
      // Draw complete first part and second part
      final t = (progress - 0.5) * 2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * t,
        p2.dy + (p3.dy - p2.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Confetti particle widget
class _ConfettiParticle extends StatelessWidget {
  final Animation<double> animation;
  final int index;

  const _ConfettiParticle({
    required this.animation,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final startAngle = random.nextDouble() * 2 * math.pi;
    final distance = 100 + random.nextDouble() * 100;
    final size = 8 + random.nextDouble() * 8;
    final color = [
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.primaryColor,
      const Color(0xFFec4899),
      const Color(0xFF8b5cf6),
    ][random.nextInt(5)];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final x = math.cos(startAngle) * distance * progress;
        final y = math.sin(startAngle) * distance * progress - (progress * progress * 50);
        final opacity = 1.0 - progress;
        final rotation = progress * 4 * math.pi;

        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + x,
          top: MediaQuery.of(context).size.height / 2 + y,
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
