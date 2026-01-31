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
      title: 'İlayda''nın Doğum Günü',
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
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    
    // Konfeti kontrolcüsü (10 saniye boyunca patlayacak)
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    
    // Uygulama açıldığında konfetileri patlat
    _confettiController.play();

    // Kalp atışı animasyonu için kontrolcü
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // Sürekli tekrar et

    _heartAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // Arka plan rengi
      body: Stack(
        children: [
          // Ana İçerik
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Kalp Animasyonu
                ScaleTransition(
                  scale: _heartAnimation,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 150,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Başlık Mesajı
                Text(
                  'İyi ki Doğdun',
                  style: GoogleFonts.pacifico(
                    fontSize: 40,
                    color: Colors.pink[800],
                  ),
                ),
                Text(
                  'Ahmet!',
                  style: GoogleFonts.pacifico(
                    fontSize: 60,
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Alt Mesaj
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Seni çok seviyorum ❤️',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lora(
                          fontSize: 22,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nice mutlu, sağlıklı ve\nbirlikte geçireceğimiz senelere.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Tekrar Kutla Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    _confettiController.stop();
                    _confettiController.play();
                  },
                  icon: const Icon(Icons.celebration),
                  label: const Text('Tekrar Kutla 🎉'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),

          // Konfeti Efekti (En üst katmanda)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Aşağı doğru
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}
