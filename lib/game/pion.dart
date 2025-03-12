import 'dart:math';

String side = 'white';
Pion? pionslect; // Utiliser null-safety avec Pion?

class Pion {
  final String color;
  final String name;
  int ID;
  final String img;
  int x;
  int y;
  List<List<int>> mouvsTheorique;
  bool mouvMultiple;
  bool firstMouv = true;


  Pion({
    required this.color,
    required this.x,
    required this.y,
    required this.img,
    required this.name,
    required this.mouvsTheorique,
    required this.mouvMultiple,
    required this.ID,
  });

  void deplacer(int newX, int newY) {
    x = newX;
    y = newY;
  }
}

List<Pion?> initialiser(List<Pion?> pieces) {
  pieces.clear();
  side = Random().nextBool() ? 'white' : 'black';
  String opponentColor = (side == 'white') ? 'black' : 'white';

  // Définition des mouvements théoriques sous forme de classe pour plus de clarté
  final Map<String, (List<List<int>>, bool)> mouvTheorique = {
    'r': ([[0, 1], [0, -1], [1, 0], [-1, 0]], true),
    'n': ([[2, 1], [2, -1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [1, -2], [-1, -2]], false),
    'b': ([[1, 1], [-1, -1], [1, -1], [-1, 1]], true),
    'q': ([[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [-1, -1], [1, -1], [-1, 1]], true),
    'k': ([[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [-1, -1], [1, -1], [-1, 1], [2,0], [-2,0]], false),
  };

  // Placement des pions
  for (int i = 0; i < 8; i++) {
    pieces.add(Pion(color: opponentColor, x: i, y: 1, img: 'assets/${opponentColor.substring(0, 1)}p.png', name: 'p', mouvsTheorique: [[0, 1],[-1,1],[1,1],[0,2]], mouvMultiple: false, ID: i*2));
    pieces.add(Pion(color: side, x: i, y: 6, img: 'assets/${side.substring(0, 1)}p.png', name: 'p', mouvsTheorique: [[0,-1],[-1,-1],[1,-1],[0,-2]], mouvMultiple: false, ID: i*2+1));
  }

  // Placement des autres pièces
  List<String> types = side == 'white' ? ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'] : ['r', 'n', 'b', 'k', 'q', 'b', 'n', 'r'];

  for (int i = 0; i < 8; i++) {
    String type = types[i];
    pieces.add(Pion(
      color: opponentColor,
      x: i,
      y: 0,
      img: 'assets/${opponentColor.substring(0, 1)}$type.png',
      name: type,
      mouvsTheorique: mouvTheorique[type]!.$1,
      mouvMultiple: mouvTheorique[type]!.$2,
      ID: 16+i,
    ));
    pieces.add(Pion(
      color: side,
      x: i,
      y: 7,
      img: 'assets/${side.substring(0, 1)}$type.png',
      name: type,
      mouvsTheorique: mouvTheorique[type]!.$1,
      mouvMultiple: mouvTheorique[type]!.$2,
      ID: 24+i,
    ));
  }
  return pieces;
}

Map<Pion, List<List<dynamic>>> MapMouvsPossible(List<Pion?> pieces) {
  Map<Pion, List<List<dynamic>>> mapMouvsPossible = {};
  List<List<dynamic>> listResult = [];
  int count = 0;
  for (var piece  in pieces) {
    listResult = [];
    listResult = mouvsPossible(pieces, piece);
    listResult = echec_au_roi(pieces, piece, listResult);
    listResult = special_mouv(pieces, piece, listResult);
    if(piece != null) mapMouvsPossible[piece] = listResult;
    count ++;
  }

  return mapMouvsPossible;
}

List<List<dynamic>> mouvsPossible(List<Pion?> pieces, Pion? piece) {
  List<List<dynamic>> listResult = [];
  for (List<int> mouvTheorique in piece!.mouvsTheorique) {
    List<dynamic>? result = mouvPossible(pieces, piece, mouvTheorique);
    if (result != null) {
      listResult.add(result);
    }
    int count = 2;
    while (result != null && result.length >= 3 && result[2] != "assets/r2.png" &&
        piece.mouvMultiple) {
      result = mouvPossible(
          pieces, piece, [mouvTheorique[0] * count, mouvTheorique[1] * count]);
      if (result != null) {
        listResult.add(result);
      }
      count++;
    }
  }
  return listResult;
}

List<dynamic>? mouvPossible(List<Pion?> pieces, Pion piece, List<int> mouvTheorique) {
  int xMouv = piece.x + mouvTheorique[0];
  int yMouv = piece.y + mouvTheorique[1];

  if (xMouv >= 0 && xMouv <= 7 && yMouv >= 0 && yMouv <= 7) {
    for (var pion in pieces) {
      if (pion != null) {
        if (pion.x == xMouv && pion.y == yMouv) {
          if (pion.color == piece.color) {
            return null;
          } else {
            if (piece.name == 'p') {
              if (mouvTheorique[0] != 0) {
                return [xMouv, yMouv, "assets/r2.png", pion];
              }
              else {
                return null;
              }
            }
            return [xMouv, yMouv, "assets/r2.png", pion];
          }
        }
      }
    }
    if (piece.name == 'p'){
      if (mouvTheorique[0] == 0){
        return [xMouv, yMouv, "assets/r1.png"];
      }
    }
    else{
      return [xMouv, yMouv, "assets/r1.png"];
    }
  }
  return null;
}

List<List<dynamic>> echec_au_roi(List<Pion?> pieces, Pion? piece, List<List<dynamic>> listResult) {
  Pion? roi;
  for (var pion in pieces) {
    if (pion != null) {
      if (pion.name == 'k' && pion.color == piece?.color) {
        roi = pion;
        break;
      }
    }
  }
  listResult.removeWhere((result) {
    int? oldX = piece?.x;
    int? oldY = piece?.y;
    Pion? pieceCapturee;
    int? indexPieceCapturee;

    piece?.x = result[0];
    piece?.y = result[1];

    // Trouver la pièce capturée et stocker son index
    for (int i = 0; i < pieces.length; i++) {
      if (pieces[i]?.x == piece?.x && pieces[i]?.y == piece?.y && pieces[i]?.color != piece?.color) {
        pieceCapturee = pieces[i];
        indexPieceCapturee = i;
        pieces[i] = null; // Remplace la pièce capturée par null
        break;
      }
    }

    // Vérifier si le roi est en échec après le déplacement
    bool roiEnEchec = false;
    for (var p in pieces) {
      if (p != null && p.color != piece?.color) { // Vérifier les mouvements des adversaires
        List<List<dynamic>> mouvsAdverses = mouvsPossible(pieces, p);
        for (var mouv in mouvsAdverses) {
          if (mouv[0] == roi?.x && mouv[1] == roi?.y) {
            roiEnEchec = true;
            break;
          }
        }
      }
      if (roiEnEchec) break;
    }

    // Restaurer la pièce capturée si nécessaire
    if (indexPieceCapturee != null) {
      pieces[indexPieceCapturee] = pieceCapturee;
    }

    // Réinitialiser la position de la pièce testée
    piece?.x = oldX!;
    piece?.y = oldY!;

    return roiEnEchec;
  });
  return listResult;
}

List<List<dynamic>> special_mouv(List<Pion?> pieces, Pion? piece, List<List<dynamic>> listResult){
  if (piece?.name == 'p'){
    if (piece!.firstMouv) {
      listResult.removeWhere((element) =>
      (element[0] == piece.x && (element[1] == piece.y+2 || element[1] == piece.y-2)) &&
          !listResult.any((e) => e[0] == piece.x && (e[1] == piece.y+1 || e[1] == piece.y-1)));
    }
    else {
      listResult.removeWhere((element) =>
      (element[0] == piece.x && (element[1] == piece.y+2 || element[1] == piece.y-2)));
    }
  }

  if (piece?.name == 'k'){
    if (piece!.firstMouv) {
      listResult.removeWhere((element) {
        if (element[1] == piece.y && element[0] == piece.x+2) {
          bool condition1 = listResult.any((e) => e[1] == piece.y && e[0] == piece.x+1 && e.length < 3);

          bool condition2 = !pieces.any((p) =>
          (p?.x == piece.x+3 || p?.x == piece.x+4) && p?.name == 'r' && p!.firstMouv);

          return condition1 && condition2;
        }
        return false;
      });
      listResult.removeWhere((element) {
        if (element[1] == piece.y && element[0] == piece.x-2) {
          bool condition1 = listResult.any((e) => e[1] == piece.y && e[0] == piece.x-1 && e.length < 3);

          bool condition2 = !pieces.any((p) =>
          (p?.x == piece.x-3 || p?.x == piece.x-4) && p?.name == 'r' && p!.firstMouv);

          return condition1 && condition2;
        }
        return false;
      });
    }
    else {
      listResult.removeWhere((element) =>
      (element[1] == piece.y && (element[0] == piece.x+2 || element[0] == piece.x-2)));
    }
  }
  return listResult;
}