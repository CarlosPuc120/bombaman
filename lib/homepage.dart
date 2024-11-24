 import 'dart:async';
import 'package:bombaman/button.dart';
import 'package:bombaman/pixel.dart';
import 'package:flutter/material.dart';
import 'player_lives.dart'; // Importar el archivo donde está el widget de las vidas

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
  List<int> fire = [-1];

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

  void placeBomb() {
    setState(() {
      bombPosition = playerPosition;
      fire.clear();
      if(bombPosition != -1){}

      Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          fire.add(bombPosition);
          addExplosionInDirection(bombPosition, 1, 1);  // Derecha
          addExplosionInDirection(bombPosition, -1, 1); // Izquierda
          addExplosionInDirection(bombPosition, 10, 1); // Abajo
          addExplosionInDirection(bombPosition, -10, 1); // Arriba
        });
        clearFire();
      });
    });
  }

  void addExplosionInDirection(int start, int step, int range) {
    for (int i = 1; i <= range; i++) {
      int nextPosition = start + step * i;

      // Verificar si la posición está dentro de los límites del mapa
      if (nextPosition < 0 || nextPosition >= numberOfSquares) break;

      // Verificar si la explosión cruza los límites horizontales (Izquierda o Derecha)
      if (step == 1 && nextPosition % 10 == 0) break; // Cruce hacia la derecha
      if (step == -1 && nextPosition % 10 == 9) break; // Cruce hacia la izquierda

      // Detener si encuentra una barrera
      if (barriers.contains(nextPosition)) break;

      // Añadir posición afectada por la explosión
      fire.add(nextPosition);

      // Si encuentra una caja, detén la explosión y elimínala
      if (boxes.contains(nextPosition)) {
        boxes.remove(nextPosition);
        break;
      }
    }
  }

  void clearFire() {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // Verificar si el jugador está en la explosión
        if (fire.contains(playerPosition)) {
          lives--; // Reduce una vida
          if (lives == 0) {
            showGameOverDialog(); // Mostrar "Game Over"
          }
        }

        fire.clear();
        bombPosition = -1;
      });
    });
  }

  void resetGame() {
    setState(() {
      lives = 3; // Reiniciar las vidas
      playerPosition = 0; // Reiniciar la posición del jugador
      bombPosition = -1; // Eliminar bombas activas
      fire.clear(); // Eliminar fuego
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: const Text("¡Te quedaste sin vidas!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el cuadro de diálogo
              resetGame(); // Reiniciar el juego
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
                          child: Image.asset('lib/images/bomb1.png'),
                        ),
                      );
                    } else if (playerPosition == index) {
                      return MyPixel(
                        innerColor: Colors.green,
                        outerColor: Colors.green[800],
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset('lib/images/Down1.png'),
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
          // Llamamos al widget PlayerLives para mostrar las vidas en la parte superior derecha
          PlayerLives(lives: lives),
          // Aquí colocamos los botones de control
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
                            'lib/images/bomb1.png',
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
                      child: MyButton(),
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
                      child: MyButton(),
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
