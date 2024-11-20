import 'dart:async';
import 'package:bombaman/button.dart';
import 'package:bombaman/pixel.dart';
import 'package:flutter/material.dart';
import 'player_lives.dart'; // Asegúrate de tener este widget para mostrar las vidas

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfSquares = 130;
  int playerPosition = 0;
  int bombPosition = -1;
  int lives = 3; // El jugador comienza con 3 vidas.
  
  List<int> barriers = [
    11, 13, 15, 17, 18, 31, 33, 35, 37, 38,
    51, 53, 55, 57, 58, 71, 73, 75, 77, 78,
    91, 93, 95, 97, 98, 111, 113, 115, 117, 118
  ];
  List<int> boxes = [
    12, 14, 16, 28, 21, 41, 61, 81, 101, 11,
    114, 116, 119, 127, 123, 103, 83, 63, 65, 67,
    47, 39, 19, 1, 30, 50, 70, 121, 100, 96,
    79, 99, 107, 7, 3
  ];
  List<int> fire = [-1]; // Inicializa la lista de fuego

  // Movimientos del jugador
  void moveUp() {
    setState(() {
      if (playerPosition - 10 >= 0 &&
          !barriers.contains(playerPosition - 10) &&
          !boxes.contains(playerPosition - 10)) {
        playerPosition -= 10;
      }
    });
  }

  void moveLeft() {
    setState(() {
      if (!(playerPosition % 10 == 0) &&
          !barriers.contains(playerPosition - 1) &&
          !boxes.contains(playerPosition - 1)) {
        playerPosition -= 1;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (!(playerPosition % 10 == 9) &&
          !barriers.contains(playerPosition + 1) &&
          !boxes.contains(playerPosition + 1)) {
        playerPosition += 1;
      }
    });
  }

  void moveDown() {
    setState(() {
      if (playerPosition + 10 < numberOfSquares &&
          !barriers.contains(playerPosition + 10) &&
          !boxes.contains(playerPosition + 10)) {
        playerPosition += 10;
      }
    });
  }

  // Colocar bomba
  void placeBomb() {
    if (bombPosition == -1) {
      setState(() {
        bombPosition = playerPosition; // Asigna la posición de la bomba
        fire.clear(); // Limpiar la lista de fuego

        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            fire.add(bombPosition); // Añadir la bomba al fuego
            addExplosionInDirection(bombPosition, 1, 1);  // Derecha
            addExplosionInDirection(bombPosition, -1, 1); // Izquierda
            addExplosionInDirection(bombPosition, 10, 1); // Abajo
            addExplosionInDirection(bombPosition, -10, 1); // Arriba
          });

          clearFire(); // Limpiar fuego después de un tiempo
        });
      });
    }
  }

  // Agregar explosión en una dirección
  void addExplosionInDirection(int start, int step, int range) {
    for (int i = 1; i <= range; i++) {
      int nextPosition = start + step * i;

      if (nextPosition < 0 || nextPosition >= numberOfSquares) break;

      if (step == 1 && nextPosition % 10 == 0) break; // Cruce hacia la derecha
      if (step == -1 && nextPosition % 10 == 9) break; // Cruce hacia la izquierda

      if (barriers.contains(nextPosition)) break; // Detener en barreras

      fire.add(nextPosition);

      if (boxes.contains(nextPosition)) {
        boxes.remove(nextPosition); // Eliminar caja
        break;
      }
    }
  }

  // Limpiar el fuego
  void clearFire() {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        if (fire.contains(playerPosition)) {
          lives--; // Pierde una vida si está en la explosión
          if (lives == 0) {
            showGameOverDialog(); // Mostrar "Game Over"
          }
        }

        fire.clear(); // Limpiar fuego
        bombPosition = -1; // Eliminar bomba
      });
    });
  }

  // Resetear el juego
  void resetGame() {
    setState(() {
      lives = 3; // Restablecer vidas
      playerPosition = 0; // Restablecer la posición del jugador
      bombPosition = -1; // Eliminar bombas activas
      fire.clear(); // Limpiar fuego
      boxes = [
        12, 14, 16, 28, 21, 41, 61, 81, 101, 11,
        114, 116, 119, 127, 123, 103, 83, 63, 65, 67,
        47, 39, 19, 1, 30, 50, 70, 121, 100, 96,
        79, 99, 107, 7, 3
      ]; // Restablecer cajas
    });
  }

  // Mostrar "Game Over" y reiniciar el juego
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: const Text("¡Te quedaste sin vidas!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              resetGame(); // Reiniciar el juego completamente
            },
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Stack(
        children: [
          // Parte del juego: el grid donde se mueve el jugador y se colocan los elementos
          Column(
            children: [
              Expanded(
                flex: 2,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: numberOfSquares,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (fire.contains(index)) {
                      return MyPixel(
                        innerColor: Colors.red,
                        outerColor: Colors.red[800],
                      );
                    } else if (bombPosition == index) {
                      return MyPixel(
                        innerColor: Colors.green,
                        outerColor: Colors.green[800],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('lib/images/Pokeball.png'), // Imagen de la bomba
                        ),
                      );
                    } else if (playerPosition == index) {
                      return MyPixel(
                        innerColor: Colors.green,
                        outerColor: Colors.green[800],
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset('lib/images/528079.png'), // Imagen del jugador
                        ),
                      );
                    } else if (barriers.contains(index)) {
                      return MyPixel(
                        innerColor: Colors.black,
                        outerColor: Colors.black,
                      );
                    } else if (boxes.contains(index)) {
                      return MyPixel(
                        innerColor: Colors.brown,
                        outerColor: Colors.brown[800],
                      );
                    } else {
                      return MyPixel(
                        innerColor: Colors.green,
                        outerColor: Colors.green[800],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          PlayerLives(lives: lives), // Mostrar las vidas en la parte superior derecha
          // Controles de movimiento y bomba
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: MyButton(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: MyButton(
                        function: moveUp,
                        Color: Colors.grey,
                        child: const Icon(
                          Icons.arrow_drop_up,
                          size: 70,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: MyButton(),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: MyButton(
                        function: moveLeft,
                        Color: Colors.grey,
                        child: const Icon(
                          Icons.arrow_left,
                          size: 70,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: MyButton(
                        function: placeBomb,
                        Color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'lib/images/Pokeball.png', // Icono de la bomba
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: MyButton(
                        function: moveRight,
                        Color: Colors.grey,
                        child: const Icon(
                          Icons.arrow_right,
                          size: 70,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: MyButton(), // Espaciador
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: MyButton(
                        function: moveDown,
                        Color: Colors.grey,
                        child: const Icon(
                          Icons.arrow_drop_down,
                          size: 70,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: MyButton(), // Espaciador
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
