import 'package:flutter/material.dart';
import 'package:cheese/game/pion.dart';
import 'package:cheese/game/IA.dart';

class GameIA extends StatefulWidget {
  const GameIA({super.key});

  @override
  State<GameIA> createState() => _GameIAState();
}

class _GameIAState extends State<GameIA> {
  List<List<List<dynamic>>> game = [];
  int tour = 1;
  String sidePlay = 'white';
  List<Pion?> pieces = [];
  var pionhere;
  Pion? pionhereOnTap;
  List<List<dynamic>> listMouvsPossible = [];
  Map<Pion, List<List<dynamic>>> mapMouvsPossible = {};
  Pion? pieceSelect;
  List<List<dynamic>> listForIA = [];

  void initState() {
    super.initState();
    pieces = initialiser(pieces);
    game = [];
    tour = 1;
    mapMouvsPossible = MapMouvsPossible(pieces);
  }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Plateau d'échecs")),
        body: Column(
            children: [
              Column(
                children: List.generate(8, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (col) {
                    bool isWhite = (row + col) % 2 == 0;
                    pionhere = null;
                    if (tour == game.length + 1){
                      for (var pion in pieces) {
                        if (pion?.x == col && pion?.y == row) {
                          pionhere = pion;
                        }
                      }
                    }
                    else{
                      for (var pion in game[tour-1]) {
                        if (pion[0] == col && pion[1] == row) {
                          pionhere = pion;
                        }
                      }
                    }
                    List<dynamic>? mouv = listMouvsPossible.firstWhere(
                          (m) => m[0] == col && m[1] == row,
                      orElse: () => [],
                    );
                    return GestureDetector(
                      onTap: () async {
                        if (tour == game.length + 1) {
                          pionhereOnTap = null;
                          for (var pion in pieces) {
                            if (pion?.x == col && pion?.y == row) {
                              pionhereOnTap = pion;
                            }
                          }
                          if (pionhereOnTap != null &&
                              pionhereOnTap?.color == sidePlay) {
                            setState(() {
                              pieceSelect = pionhereOnTap;
                              listMouvsPossible =
                                  mapMouvsPossible[pionhereOnTap] ?? [];
                            });
                          } else if (pieceSelect != null) {
                            for (var coup in listMouvsPossible) {
                              if (coup[0] == col && coup[1] == row) {
                                setState(() {
                                  List<List<dynamic>> list_pieces = [];
                                  for (var pieceID in pieces) {
                                    list_pieces.add(
                                        [pieceID?.x, pieceID?.y, pieceID?.img]);
                                  }
                                  game.add(list_pieces);
                                  if (coup[2] == "assets/r2.png") {
                                    pieces.removeWhere((piece_remouv) =>
                                    piece_remouv?.x == col &&
                                        piece_remouv?.y == row);
                                  }
                                  pieceSelect?.x = col;
                                  pieceSelect?.y = row;
                                  pieceSelect?.firstMouv = false;
                                  sidePlay =
                                  sidePlay == 'white' ? 'black' : 'white';
                                  mapMouvsPossible = MapMouvsPossible(pieces);
                                  tour ++;

                                });
                                if(sidePlay != side) {
                                  listForIA = [];
                                  for (var piece in pieces) {
                                    listForIA.add([
                                      piece?.y,
                                      piece?.x,
                                      piece?.name,
                                      piece?.color
                                    ]);
                                  }
                                  String fen = genererFENDepuisCoordonnees(
                                      listForIA, sidePlay.substring(0, 1),
                                      "-", "-", 0, tour);
                                  print("Chaîne FEN générée : $fen");
                                  try {
                                    String meilleurCoup = await obtenirMeilleurCoup(fen);
                                    print("Meilleur coup proposé : $meilleurCoup");
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                                break;
                              }
                            }
                            setState(() {
                              pieceSelect = null;
                              listMouvsPossible = [];
                            });
                          } else {
                            setState(() {
                              pieceSelect = null;
                              listMouvsPossible = [];
                            });
                          }
                        }
                        },
                      child: Container(
                        width: 40,
                        height: 40,
                        color: isWhite ? Colors.white : Colors.yellow,
                        child: Stack(
                          children: [
                            if (tour == game.length + 1) ...[
                              if (pionhere != null && pionhere!.img.isNotEmpty)
                                Center(child: Image.asset(
                                    pionhere!.img, width: 30,
                                    height: 30,
                                    fit: BoxFit.fill)),
                              if (mouv.isNotEmpty)
                                Center(child: Image.asset(
                                    mouv[2], width: 30, height: 30),
                                ),
                            ]
                            else ...[
                              if (pionhere != null && pionhere[2].isNotEmpty)
                                Center(child: Image.asset(
                                    pionhere[2], width: 30,
                                    height: 30,
                                    fit: BoxFit.fill)),
                            ]
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: tour > 1
                          ? () {
                        setState(() {
                          tour = 1;
                        });
                      }
                      : null, // Désactive le bouton si tour <= 1
                        style: ElevatedButton.styleFrom(
                        backgroundColor: tour > 1 ? null : Colors.grey, // Fond gris si désactivé
                        ),
                      child: const Text("<<"),
                    ),
                    ElevatedButton(
                      onPressed: tour > 1
                          ? () {
                        setState(() {
                          tour--;
                        });
                      }
                      : null, // Désactive le bouton si tour <= 1
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tour > 1 ? null : Colors.grey, // Fond gris si désactivé
                      ),
                      child: const Text("<"),
                    ),
                    const SizedBox(width: 20),
                    Text("$tour / ${game.length + 1}", style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: tour < game.length + 1
                          ? () {
                        setState(() {
                          tour++;
                        });
                      }
                      : null, // Désactive le bouton si tour >= game.length + 1
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tour < game.length + 1 ? null : Colors.grey, // Fond gris si désactivé
                      ),
                      child: const Text(">"),
                    ),
                    ElevatedButton(
                      onPressed: tour < game.length + 1
                          ? () {
                        setState(() {
                          tour = game.length + 1;
                        });
                      }
                      : null, // Désactive le bouton si tour >= game.length + 1
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tour < game.length + 1 ? null : Colors.grey, // Fond gris si désactivé
                      ),
                      child: const Text(">>"),
                    ),
                  ],
                ),
              ),
            ]
          )
    );
  }
}

