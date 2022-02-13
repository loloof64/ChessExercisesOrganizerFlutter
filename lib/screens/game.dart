/*
    Chess exercises organizer : oad your chess exercises and train yourself against the device.
    Copyright (C) 2022  Laurent Bernabe <laurent.bernabe@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
import 'package:flutter/material.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import "package:chess/chess.dart" as chesslib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:chess_exercises_organizer/components/richboard.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  var _chess = new chesslib.Chess();
  var _blackAtBottom = true;
  var _lastMove = <String>[];

  void _tryMakingMove(ShortMove move) {
    final success = _chess.move(<String, String?>{
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion.match(
        (piece) => piece.name,
        () => null,
      ),
    });
    if (success) {
      setState(() {
        _lastMove.clear();
        _lastMove.add(move.from);
        _lastMove.add(move.to);
      });
    }
  }

  Future<PieceType?> _showPromotionDialog(BuildContext context) {
    final pieceSize = _getMinScreenSize(context) * 0.15;
    final whitePieces = _chess.turn == chesslib.Color.WHITE;
    return showDialog<PieceType>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: I18nText('game.choose_promotion_title'),
            alignment: Alignment.center,
            content: FittedBox(
              child: Row(
                children: [
                  InkWell(
                    child: whitePieces
                        ? WhiteQueen(size: pieceSize)
                        : BlackQueen(size: pieceSize),
                    onTap: () => Navigator.of(context).pop(PieceType.QUEEN),
                  ),
                  InkWell(
                    child: whitePieces
                        ? WhiteRook(size: pieceSize)
                        : BlackRook(size: pieceSize),
                    onTap: () => Navigator.of(context).pop(PieceType.ROOK),
                  ),
                  InkWell(
                    child: whitePieces
                        ? WhiteBishop(size: pieceSize)
                        : BlackBishop(size: pieceSize),
                    onTap: () => Navigator.of(context).pop(PieceType.BISHOP),
                  ),
                  InkWell(
                    child: whitePieces
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

  double _getMinScreenSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return screenWidth < screenHeight ? screenWidth : screenHeight;
  }

  bool _isInLandscapeMode(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  void _toggleBoardOrientation() {
    setState(() {
      _blackAtBottom = !_blackAtBottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final minScreenSize = _getMinScreenSize(context);
    final isInLandscapeMode = _isInLandscapeMode(context);

    final content = <Widget>[
      RichChessboard(
        fen: _chess.fen,
        size: minScreenSize * (isInLandscapeMode ? 0.75 : 1.0),
        onMove: _tryMakingMove,
        onPromote: () => _showPromotionDialog(context),
        orientation: _blackAtBottom ? BoardColor.BLACK : BoardColor.WHITE,
        lastMoveToHighlight: _lastMove,
      ),
      Column(
        children: [
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            child: I18nText('game.go_back_home'),
          )
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: I18nText('game.title'),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_vert),
            onPressed: _toggleBoardOrientation,
          ),
        ],
      ),
      body: Center(
        child: isInLandscapeMode
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: content,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: content,
              ),
      ),
    );
  }
}
