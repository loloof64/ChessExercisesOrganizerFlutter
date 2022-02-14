import 'package:flutter/material.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

enum PlayerType {
  human,
  computer,
}

class RichChessboard extends StatelessWidget {
  final String fen;
  final double size;
  final void Function({required ShortMove move}) onMove;
  final BoardColor orientation;
  final List<String> lastMoveToHighlight;
  final Widget promotionChooserTitle;
  final PlayerType whitePlayerType;
  final PlayerType blackPlayerType;

  const RichChessboard({
    Key? key,
    required this.fen,
    required this.size,
    required this.onMove,
    required this.orientation,
    required this.promotionChooserTitle,
    required this.whitePlayerType,
    required this.blackPlayerType,
    this.lastMoveToHighlight = const [],
  }) : super(key: key);

  Future<PieceType?> _showPromotionDialog(BuildContext context) {
    final pieceSize = size * 0.15;
    final whiteTurn = fen.split(' ')[1] == 'w';
    return showDialog<PieceType>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: promotionChooserTitle,
            alignment: Alignment.center,
            content: FittedBox(
              child: Row(
                children: [
                  InkWell(
                    child: whiteTurn
                        ? WhiteQueen(size: pieceSize)
                        : BlackQueen(size: pieceSize),
                    onTap: () => Navigator.of(context).pop(PieceType.QUEEN),
                  ),
                  InkWell(
                    child: whiteTurn
                        ? WhiteRook(size: pieceSize)
                        : BlackRook(size: pieceSize),
                    onTap: () => Navigator.of(context).pop(PieceType.ROOK),
                  ),
                  InkWell(
                    child: whiteTurn
                        ? WhiteBishop(size: pieceSize)
                        : BlackBishop(size: pieceSize),
                    onTap: () => Navigator.of(context).pop(PieceType.BISHOP),
                  ),
                  InkWell(
                    child: whiteTurn
                        ? WhiteKnight(size: pieceSize)
                        : BlackKnight(size: pieceSize),
                    onTap: () => Navigator.of(context).pop(PieceType.KNIGHT),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _processMove(ShortMove move) {
    final whiteTurn = fen.split(' ')[1] == 'w';
    final currentPlayerIsHuman =
        (whitePlayerType == PlayerType.human && whiteTurn) ||
            (blackPlayerType == PlayerType.human && !whiteTurn);
    if (currentPlayerIsHuman) {
      onMove(move: move);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commonTextStyle = TextStyle(
      color: Colors.yellow.shade400,
      fontWeight: FontWeight.bold,
      fontSize: size * 0.04,
    );
    final topFilesCoordinates = [0, 1, 2, 3, 4, 5, 6, 7].map((file) {
      final letterOffset = orientation == BoardColor.WHITE ? file : 7 - file;
      final letter = String.fromCharCode('A'.codeUnitAt(0) + letterOffset);
      return Positioned(
        top: size * 0.005,
        left: size * (0.09 + 0.113 * file),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    });

    final bottomFilesCoordinates = [0, 1, 2, 3, 4, 5, 6, 7].map((file) {
      final letterOffset = orientation == BoardColor.WHITE ? file : 7 - file;
      final letter = String.fromCharCode('A'.codeUnitAt(0) + letterOffset);
      return Positioned(
        bottom: size * 0.003,
        left: size * (0.09 + 0.113 * file),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    });

    final leftRanksCoordinates = [0, 1, 2, 3, 4, 5, 6, 7].map((rank) {
      final letterOffset = orientation == BoardColor.WHITE ? 7 - rank : rank;
      final letter = String.fromCharCode('1'.codeUnitAt(0) + letterOffset);
      return Positioned(
        left: size * 0.012,
        top: size * (0.09 + 0.113 * rank),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    });

    final rightRanksCoordinates = [0, 1, 2, 3, 4, 5, 6, 7].map((rank) {
      final letterOffset = orientation == BoardColor.WHITE ? 7 - rank : rank;
      final letter = String.fromCharCode('1'.codeUnitAt(0) + letterOffset);
      return Positioned(
        right: size * 0.012,
        top: size * (0.09 + 0.113 * rank),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    });

    final isWhiteTurn = fen.split(' ')[1] == 'w';
    final playerTurn = Positioned(
      child: _PlayerTurn(size: size * 0.05, whiteTurn: isWhiteTurn),
      bottom: size * 0.001,
      right: size * 0.001,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.indigo.shade300,
          width: size,
          height: size,
          child: Stack(
            children: [
              ...topFilesCoordinates,
              ...bottomFilesCoordinates,
              ...leftRanksCoordinates,
              ...rightRanksCoordinates,
              playerTurn,
            ],
          ),
        ),
        Chessboard(
          fen: fen,
          size: size * 0.9,
          onMove: _processMove,
          onPromote: () => _showPromotionDialog(context),
          orientation: orientation,
          lastMoveHighlightColor: Colors.indigoAccent.shade200,
          selectionHighlightColor: Colors.greenAccent,
          lastMove: lastMoveToHighlight,
        ),
      ],
    );
  }
}

class _PlayerTurn extends StatelessWidget {
  final double size;
  final bool whiteTurn;

  const _PlayerTurn({Key? key, required this.size, required this.whiteTurn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(
        left: 10,
      ),
      decoration: BoxDecoration(
        color: whiteTurn ? Colors.white : Colors.black,
        border: Border.all(
          width: 0.7,
          color: Colors.black,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
