import 'package:flutter/material.dart';

class PlayerLives extends StatelessWidget {
  final int lives; // Número de vidas del jugador.

  const PlayerLives({
    Key? key,
    required this.lives,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10, // Ajusta esta posición según tu diseño.
      right: 10, // Vidas en la esquina superior derecha.
      child: Row(
        children: List.generate(
          lives,
          (index) => Icon(
            Icons.favorite,
            color: Colors.red,
            size: 30,
          ),
        ),
      ),
    );
  }
}
