import 'dart:convert';
import 'package:http/http.dart' as http;

String convertirYEnLettre(int y) {
  const lettres = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
  return (y >= 0 && y < 8) ? lettres[y] : '?';
}

String genererFENDepuisCoordonnees(List<List<dynamic>> pieces, String tour, String roque, String enPassant, int demiCoup, int coupComplet) {
  List<List<String>> echiquier = List.generate(8, (_) => List.generate(8, (_) => ''));

  for (var piece in pieces) {
    int x = piece[0];int y = piece[1];
    String typePiece = piece[2];
    String couleur = piece[3];
    if (couleur == 'black') {
      typePiece = typePiece.toUpperCase();
    }
    // Placer la pièce sur l'échiquier
    echiquier[x][y] = typePiece;
  }

  // Générer la notation FEN pour chaque ligne
  List<String> fenLignes = [];
  for (int i = 0; i < 8; i++) {
    String ligne = "";
    int casesVides = 0;
    for (int j = 0; j < 8; j++) {
      String caseEchiquier = echiquier[i][j];
      if (caseEchiquier == '') {
        casesVides++;
      } else {
        if (casesVides > 0) {
          ligne += casesVides.toString();
          casesVides = 0;
        }
        ligne += caseEchiquier;
      }
    }
    if (casesVides > 0) {
      ligne += casesVides.toString();
    }
    fenLignes.add(ligne);
  }

  String echiquierFEN = fenLignes.join('/');
  return '$echiquierFEN $tour $roque $enPassant $demiCoup $coupComplet';
}

Future<String> obtenirMeilleurCoup(String fen) async {
  final url = Uri.parse("https://lichess.org/api/cloud-eval?fen=$fen");
  final reponse = await http.get(url);

  if (reponse.statusCode == 200) {
    final donnees = jsonDecode(reponse.body);
    return donnees["pvs"][0]["moves"].split(" ")[0];
  } else {
    throw Exception("Erreur lors de la récupération du meilleur coup");
  }
}