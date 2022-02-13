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
    return Chessboard(
      fen: widget.fen,
      size: widget.size,
      onMove: widget.onMove,
      onPromote: widget.onPromote,
      orientation: widget.orientation,
    );
  }
}
