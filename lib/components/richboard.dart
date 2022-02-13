import 'package:flutter/material.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart';

class RichChessboard extends StatefulWidget {
  final String fen;
  final double size;
  final void Function(ShortMove move) onMove;
  final Future<PieceType?> Function() onPromote;
  final BoardColor orientation;

  const RichChessboard({
    Key? key,
    required this.fen,
    required this.size,
    required this.onMove,
    required this.onPromote,
    required this.orientation,
  }) : super(key: key);

  @override
  _RichChessboardState createState() => _RichChessboardState();
}

class _RichChessboardState extends State<RichChessboard> {
  @override
  Widget build(BuildContext context) {
    final commonTextStyle = TextStyle(
      color: Colors.yellow.shade400,
      fontWeight: FontWeight.bold,
      fontSize: widget.size * 0.04,
    );
    final topFilesCoordinates = [0, 1, 2, 3, 4, 5, 6, 7].map((file) {
      final letterOffset =
          widget.orientation == BoardColor.WHITE ? file : 7 - file;
      final letter = String.fromCharCode('A'.codeUnitAt(0) + letterOffset);
      return Positioned(
        top: widget.size * 0.005,
        left: widget.size * (0.09 + 0.113 * file),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    });

    final bottomFilesCoordinates = [0, 1, 2, 3, 4, 5, 6, 7].map((file) {
      final letterOffset =
          widget.orientation == BoardColor.WHITE ? file : 7 - file;
      final letter = String.fromCharCode('A'.codeUnitAt(0) + letterOffset);
      return Positioned(
        bottom: widget.size * 0.003,
        left: widget.size * (0.09 + 0.113 * file),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    });

    final leftRanksCoordinates = [0, 1, 2, 3, 4, 5, 6, 7].map((rank) {
      final letterOffset =
          widget.orientation == BoardColor.WHITE ? 7 - rank : rank;
      final letter = String.fromCharCode('1'.codeUnitAt(0) + letterOffset);
      return Positioned(
        left: widget.size * 0.012,
        top: widget.size * (0.09 + 0.113 * rank),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    });

    final rightRanksCoordinates = [0, 1, 2, 3, 4, 5, 6, 7].map((rank) {
      final letterOffset =
          widget.orientation == BoardColor.WHITE ? 7 - rank : rank;
      final letter = String.fromCharCode('1'.codeUnitAt(0) + letterOffset);
      return Positioned(
        right: widget.size * 0.012,
        top: widget.size * (0.09 + 0.113 * rank),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.indigo.shade300,
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              ...topFilesCoordinates,
              ...bottomFilesCoordinates,
              ...leftRanksCoordinates,
              ...rightRanksCoordinates,
            ],
          ),
        ),
        Chessboard(
          fen: widget.fen,
          size: widget.size * 0.9,
          onMove: widget.onMove,
          onPromote: widget.onPromote,
          orientation: widget.orientation,
        ),
      ],
    );
  }
}
