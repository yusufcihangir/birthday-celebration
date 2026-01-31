import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doğum Günü Kutlama',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      home: const BirthdayScreen(),
    );
  }
}

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _heartController;
  late AnimationController _fadeController;
  late AnimationController _balloonController;
  late AnimationController _rotateController;
  late AnimationController _cakeController;
  
  late Animation<double> _heartAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  final List<Balloon> _balloons = [];
  final Random _random = Random();
  bool _showFireworks = false;
  int _celebrationCount = 0;

  @override
  void initState() {
    super.initState();
    
    // Konfeti kontrolcüsü
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();

    // Kalp atışı animasyonu
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    // Fade in animasyonu
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut));

    _fadeController.forward();

    // Balon animasyonu
    _balloonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Rotate animasyonu
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Pasta animasyonu
    _cakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _cakeController, curve: Curves.easeInOut),
    );

    // Balonları oluştur
    _createBalloons();
  }

  void _createBalloons() {
    for (int i = 0; i < 15; i++) {
      _balloons.add(Balloon(
        color: _getRandomColor(),
        left: _random.nextDouble() * 300,
        delay: _random.nextDouble() * 5000,
      ));
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _celebrate() {
    setState(() {
      _celebrationCount++;
      _showFireworks = true;
    });
    
    _confettiController.stop();
    _confettiController.play();

    // Fireworks efektini 3 saniye sonra kapat
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFireworks = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _heartController.dispose();
    _fadeController.dispose();
    _balloonController.dispose();
    _rotateController.dispose();
    _cakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink[100]!,
              Colors.purple[100]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Yüzen balonlar
            ..._balloons.map((balloon) => AnimatedBalloon(
              balloon: balloon,
              controller: _balloonController,
            )),

            // Ana İçerik
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Dönen parti şapkası
                        RotationTransition(
                          turns: _rotateAnimation,
                          child: const Text(
                            '🎊',
                            style: TextStyle(fontSize: 60),
                          ),
                        ),

                        const SizedBox(height: 20),
                        
                        // Başlık Mesajı - Slide animasyonu ile
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Text(
                                'İyi ki Doğdun',
                                style: GoogleFonts.pacifico(
                                  fontSize: 48,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [
                                        Colors.pink[800]!,
                                        Colors.purple[600]!,
                                      ],
                                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                                ),
                              ),
                              Text(
                                'Sevgili!',
                                style: GoogleFonts.pacifico(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [
                                        Colors.pink,
                                        Colors.red[400]!,
                                      ],
                                    ).createShader(const Rect.fromLTWH(0, 0, 300, 100)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),

                        // Kalp ve Pasta kombinasyonu
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Kalp Animasyonu
                            ScaleTransition(
                              scale: _heartAnimation,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 180,
                                ),
                              ),
                            ),
                            // Pasta emoji
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: const Text(
                                '🎂',
                                style: TextStyle(fontSize: 80),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Mesaj Kartı
                        Container(
                          padding: const EdgeInsets.all(25),
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                '✨ Senin Özel Günün! ✨',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lora(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink[800],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Hayatın her anı güzelliklerle dolsun,\ngülüşün hiç eksilmesin!\n\nSeni seviyoruz! ❤️',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lora(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.pink[50],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '🎈 ${_celebrationCount > 0 ? "$_celebrationCount kez kutlandı!" : "İlk kutlamaya hazır!"} 🎈',
                                  style: GoogleFonts.lora(
                                    fontSize: 16,
                                    color: Colors.pink[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Butonlar
                        Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _celebrate,
                              icon: const Icon(Icons.celebration, size: 28),
                              label: const Text('Kutla! 🎉'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _balloons.clear();
                                  _createBalloons();
                                });
                              },
                              icon: const Icon(Icons.refresh, size: 28),
                              label: const Text('Yenile 🎈'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Konfeti Efekti - Üstten
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 8,
                minBlastForce: 3,
                emissionFrequency: 0.03,
                numberOfParticles: 60,
                gravity: 0.15,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.red,
                  Colors.yellow,
                  Colors.teal,
                ],
              ),
            ),

            // Konfeti Efekti - Soldan
            if (_showFireworks)
              Align(
                alignment: Alignment.centerLeft,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 0,
                  maxBlastForce: 10,
                  minBlastForce: 5,
                  emissionFrequency: 0.02,
                  numberOfParticles: 40,
                  gravity: 0.1,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ],
                ),
              ),

            // Konfeti Efekti - Sağdan
            if (_showFireworks)
              Align(
                alignment: Alignment.centerRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi,
                  maxBlastForce: 10,
                  minBlastForce: 5,
                  emissionFrequency: 0.02,
                  numberOfParticles: 40,
                  gravity: 0.1,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ],
                ),
              ),

            // Yıldız efekti
            ...List.generate(20, (index) => StarParticle(index: index)),
          ],
        ),
      ),
    );
  }
}

// Balon sınıfı
class Balloon {
  final Color color;
  final double left;
  final double delay;

  Balloon({
    required this.color,
    required this.left,
    required this.delay,
  });
}

// Animasyonlu Balon Widget
class AnimatedBalloon extends StatelessWidget {
  final Balloon balloon;
  final AnimationController controller;

  const AnimatedBalloon({
    super.key,
    required this.balloon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value + balloon.delay / 5000) % 1.0;
        final yPosition = screenHeight * (1 - progress) - 100;
        
        return Positioned(
          left: balloon.left,
          bottom: yPosition,
          child: Transform.rotate(
            angle: sin(progress * 4 * pi) * 0.1,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 50,
                  decoration: BoxDecoration(
                    color: balloon.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: balloon.color.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2,
                  height: 30,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Yıldız parçacığı
class StarParticle extends StatefulWidget {
  final int index;

  const StarParticle({super.key, required this.index});

  @override
  State<StarParticle> createState() => _StarParticleState();
}

class _StarParticleState extends State<StarParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();
  late double left;
  late double top;

  @override
  void initState() {
    super.initState();
    left = _random.nextDouble() * 400;
    top = _random.nextDouble() * 800;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000 + _random.nextInt(2000)),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: FadeTransition(
        opacity: _animation,
        child: const Text(
          '✨',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}