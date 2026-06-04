import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoConfetti extends StatefulWidget {
  final VoidCallback onFinished;
  const LoConfetti({super.key, required this.onFinished});

  @override
  State<LoConfetti> createState() => _LoConfettiState();
}

class _LoConfettiState extends State<LoConfetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  );

  final List<_ConfettiParticle> _particles = [];
  final Random _rand = Random();
  double _lastTime = 0.0;

  @override
  void initState() {
    super.initState();
    _c.addListener(_updateAnimation);
    _c.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _c.removeListener(_updateAnimation);
    _c.dispose();
    super.dispose();
  }

  void _initParticles(double width, double height) {
    final colors = [
      LoTheme.primary,
      LoTheme.accent,
      const Color(0xFF6ED097),
      const Color(0xFFFFE082),
      const Color(0xFF4CAF50),
      const Color(0xFF81C784),
      const Color(0xFFE9F4EE),
    ];

    const count = 100;
    for (int i = 0; i < count; i++) {
      final fromLeft = i % 2 == 0;
      final x = fromLeft ? 0.0 : width;
      // Start a bit above the bottom of the screen to clear navigation buttons
      final y = height - 80;

      // Shoot upward and inward
      final angleDeg = fromLeft 
          ? -30.0 - _rand.nextDouble() * 45.0
          : -105.0 - _rand.nextDouble() * 45.0;
      final angle = angleDeg * pi / 180.0;

      final speed = 400.0 + _rand.nextDouble() * 450.0;
      final vx = cos(angle) * speed;
      final vy = sin(angle) * speed;

      _particles.add(_ConfettiParticle(
        x: x,
        y: y,
        vx: vx,
        vy: vy,
        size: 8.0 + _rand.nextDouble() * 10.0,
        color: colors[_rand.nextInt(colors.length)],
        rotation: _rand.nextDouble() * 2 * pi,
        rotationSpeed: (_rand.nextDouble() - 0.5) * 8.0,
        scaleX: _rand.nextDouble() * 2 - 1,
        scaleSpeed: 2.0 + _rand.nextDouble() * 4.0,
        shapeType: _rand.nextInt(3),
      ));
    }
  }

  void _updateAnimation() {
    final currentTime = _c.value * 2.5; // Scale value to seconds
    final dt = (currentTime - _lastTime).clamp(0.0, 0.03);
    _lastTime = currentTime;

    if (dt > 0) {
      for (final p in _particles) {
        p.update(dt);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_particles.isEmpty && constraints.maxWidth > 0) {
          _initParticles(constraints.maxWidth, constraints.maxHeight);
        }
        return CustomPaint(
          painter: _ConfettiPainter(particles: _particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;
  double scaleX;
  double scaleSpeed;
  int shapeType; // 0 = rect, 1 = circle, 2 = triangle

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.scaleX,
    required this.scaleSpeed,
    required this.shapeType,
  });

  void update(double dt) {
    // Air resistance and gravity
    vy += 320 * dt; // gravity
    vx *= 0.97;
    vy *= 0.97;

    x += vx * dt;
    y += vy * dt;

    rotation += rotationSpeed * dt;
    scaleX += scaleSpeed * dt;
    if (scaleX > 1 || scaleX < -1) {
      scaleSpeed = -scaleSpeed;
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      if (p.y > size.height + 20) continue;

      paint.color = p.color;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.scale(p.scaleX, 1.0);

      if (p.shapeType == 0) {
        // Rectangle
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size * 1.4, height: p.size * 0.7),
          paint,
        );
      } else if (p.shapeType == 1) {
        // Circle
        canvas.drawCircle(Offset.zero, p.size / 2.2, paint);
      } else {
        // Triangle
        final path = Path();
        final hs = p.size / 2;
        path.moveTo(0, -hs);
        path.lineTo(hs, hs);
        path.lineTo(-hs, hs);
        path.close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
