import 'package:flutter/material.dart';

class InicioSesion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF979696),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'Progress Saver',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/cerebro.jpg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción para iniciar sesión
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Color(0xFF88E3E3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Acción para registrarse
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Color(0xFF88E3E3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Registrarse'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Save your progress, save your life',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
