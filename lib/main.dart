import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Titreşim için
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const UltraBirthdayApp());
}

class UltraBirthdayApp extends StatelessWidget {
  const UltraBirthdayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ultra Birthday Experience',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1E), // Derin gece mavisi
      ),
      home: const MasterStage(),
    );
  }
}

class MasterStage extends StatefulWidget {
  const MasterStage({super.key});

  @override
  State<MasterStage> createState() => _MasterStageState();
}

class _MasterStageState extends State<MasterStage> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _candleController;
  
  // Hikaye Durumları
  bool _isCandleBlown = false;
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    
    // Mum titreme efekti için
    _candleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _candleController.dispose();
    super.dispose();
  }

  // Mumu söndürme eylemi
  void _blowCandle() {
    if (_isCandleBlown) return;

    HapticFeedback.mediumImpact(); // Titreşim
    setState(() {
      _isCandleBlown = true;
    });

    // 1 saniye sonra patlama ve mesaj
    Future.delayed(const Duration(milliseconds: 800), () {
      _confettiController.play();
      setState(() {
        _showMessage = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. KATMAN: Uzay/Yıldız Arka Planı (Custom Painter)
          const Positioned.fill(child: StarFieldBackground()),

          // 2. KATMAN: Ana Sahne
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dinamik Başlık
                if (_showMessage)
                  _buildGoldText("İYİ Kİ DOĞDUN!")
                else
                  Text(
                    "Bir dilek tut...",
                    style: GoogleFonts.cinzel(
                      color: Colors.white70,
                      fontSize: 24,
                      letterSpacing: 4,
                    ),
                  ),
                
                const SizedBox(height: 50),

                // Pasta ve Mum Alanı
                GestureDetector(
                  onTap: _blowCandle,
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    // Mum sönünce pasta biraz aşağı iner
                    transform: Matrix4.translationValues(0, _showMessage ? 50 : 0, 0),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                         // Ateş Efekti (Mum sönmediyse göster)
                        if (!_isCandleBlown)
                          Positioned(
                            top: -60,
                            child: _buildRealisticFlame(),
                          ),
                        
                        // Duman Efekti (Mum söndüyse göster)
                        if (_isCandleBlown && !_showMessage)
                           const Positioned(
                            top: -80,
                            child: Icon(Icons.cloud, color: Colors.grey, size: 40), 
                            // Not: Buraya normalde karmaşık bir duman animasyonu gelir
                           ),

                        // Pasta Gövdesi
                        _buildPremiumCake(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Fotoğraf / Mesaj Kartı (Patlamadan sonra gelir)
                AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: _showMessage ? 1.0 : 0.0,
                  child: _showMessage ? const PremiumInfoCard() : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // 3. KATMAN: Konfeti (En üstte)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.01,
              colors: const [Colors.amber, Colors.orange, Colors.pink, Colors.purple, Colors.cyan],
              createParticlePath: drawStar, // Özel şekil (Yıldız)
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  // Gerçekçi Titreyen Alev
  Widget _buildRealisticFlame() {
    return AnimatedBuilder(
      animation: _candleController,
      builder: (context, child) {
        // Rastgele titreme büyüklüğü
        final wobble = sin(DateTime.now().millisecondsSinceEpoch / 100) * 0.1;
        final scale = 1.0 + (_candleController.value * 0.1);
        
        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: wobble,
            child: Container(
              width: 30,
              height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.orange.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 5),
                  BoxShadow(color: Colors.yellow.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10),
                ],
                gradient: const LinearGradient(
                  colors: [Colors.yellowAccent, Colors.orange, Colors.red],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 3D Görünümlü Pasta
  Widget _buildPremiumCake() {
    return Container(
      width: 180,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink[200]!, Colors.pink[400]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(10, 10),
            blurRadius: 20,
          ),
          // Işık yansıması (Highlight)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            offset: const Offset(-5, -5),
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Krema katmanları
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          // Süsler
          const Center(child: Text("🎂", style: TextStyle(fontSize: 40))),
          // Mum Çubuğu
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 8,
              height: 40,
              margin: const EdgeInsets.only(top: 0),
              transform: Matrix4.translationValues(0, -20, 0),
              color: Colors.blueGrey[100],
            ),
          )
        ],
      ),
    );
  }

  // Altın Metin Efekti (ShaderMask)
  Widget _buildGoldText(String text) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFDEB71), Color(0xFFF8D800), Color(0xFFFDEB71)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          shadows: [
            const Shadow(blurRadius: 10, color: Colors.orange, offset: Offset(0, 0)),
          ],
        ),
      ),
    );
  }

  // Konfeti için Yıldız Şekli
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep), halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}

// 4. KATMAN: Kişiye Özel Kart (Glassmorphism)
class PremiumInfoCard extends StatelessWidget {
  const PremiumInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // Fotoğraf Çerçevesi
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.pink.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                  // backgroundImage: AssetImage('assets/photo.jpg'), // Kendi resminizi koyun
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Senin Işığın Hiç Sönmesin",
                style: GoogleFonts.raleway(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Yeni yaşın sana evrendeki tüm güzellikleri getirsin. Seni çok seviyoruz!",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ARKA PLAN: Hareketli Yıldızlar (Canvas Painting)
class StarFieldBackground extends StatefulWidget {
  const StarFieldBackground({super.key});

  @override
  State<StarFieldBackground> createState() => _StarFieldBackgroundState();
}

class _StarFieldBackgroundState extends State<StarFieldBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    for (int i = 0; i < 100; i++) {
      _stars.add(_Star());
    }
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
        return CustomPaint(
          painter: _StarPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double size = Random().nextDouble() * 2 + 1;
  double speed = Random().nextDouble() * 0.002 + 0.001;
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;

  _StarPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);

    for (var star in stars) {
      // Yıldızları yukarı doğru hareket ettir
      double currentY = (star.y - (progress * 10 * star.speed)) % 1.0;
      if (currentY < 0) currentY += 1.0;

      // Parıltı efekti (Opaklık değişimi)
      final opacity = (sin(progress * 20 + star.x * 10) + 1) / 2 * 0.5 + 0.3;
      paint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(star.x * size.width, currentY * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}