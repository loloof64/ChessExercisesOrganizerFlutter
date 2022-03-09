/*
    Chess exercises organizer : load your chess exercises and train yourself against the device.
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
import 'package:flutter_stateless_chessboard/models/board_arrow.dart';

enum PlayerType {
  human,
  computer,
}

class RichChessboard extends StatelessWidget {
  final String fen;
  final void Function({required ShortMove move}) onMove;
  final BoardColor orientation;
  final BoardArrow? lastMoveToHighlight;
  final PlayerType whitePlayerType;
  final PlayerType blackPlayerType;
  final Future<PieceType?> Function() onPromote;
  final bool engineThinking;

  bool currentPlayerIsHuman() {
    final whiteTurn = fen.split(' ')[1] == 'w';
    return (whitePlayerType == PlayerType.human && whiteTurn) ||
        (blackPlayerType == PlayerType.human && !whiteTurn);
  }

  const RichChessboard({
    Key? key,
    required this.fen,
    required this.onMove,
    required this.orientation,
    required this.whitePlayerType,
    required this.blackPlayerType,
    required this.onPromote,
    required this.engineThinking,
    this.lastMoveToHighlight = null,
  }) : super(key: key);

  void _processMove(ShortMove move) {
    if (currentPlayerIsHuman()) {
      onMove(move: move);
    }
  }

  Widget _buildPlayerTurn({required double size}) {
    final isWhiteTurn = fen.split(' ')[1] == 'w';
    return Positioned(
      child: _PlayerTurn(size: size * 0.05, whiteTurn: isWhiteTurn),
      bottom: size * 0.001,
      right: size * 0.001,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((ctx, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.indigo.shade300,
              width: size,
              height: size,
              child: Stack(
                children: [
                  ...getFilesCoordinates(
                    boardSize: size,
                    top: true,
                    reversed: orientation == BoardColor.BLACK,
                  ),
                  ...getFilesCoordinates(
                    boardSize: size,
                    top: false,
                    reversed: orientation == BoardColor.BLACK,
                  ),
                  ...getRanksCoordinates(
                    boardSize: size,
                    left: true,
                    reversed: orientation == BoardColor.BLACK,
                  ),
                  ...getRanksCoordinates(
                    boardSize: size,
                    left: false,
                    reversed: orientation == BoardColor.BLACK,
                  ),
                  _buildPlayerTurn(size: size),
                ],
              ),
            ),
            Chessboard(
              fen: fen,
              size: size * 0.9,
              onMove: _processMove,
              onPromote: onPromote,
              orientation: orientation,
              lastMoveHighlightColor: Colors.indigoAccent.shade200,
              selectionHighlightColor: Colors.greenAccent,
              arrows: <BoardArrow>[
                if (lastMoveToHighlight != null)
                  BoardArrow(
                      from: lastMoveToHighlight!.from,
                      to: lastMoveToHighlight!.to,
                      color: lastMoveToHighlight!.color)
              ],
            ),
            SizedBox(
              width: currentPlayerIsHuman() ? 1 : size,
              height: currentPlayerIsHuman() ? 1 : size,
              child: engineThinking
                  ? CircularProgressIndicator(
                      backgroundColor: Colors.teal,
                      strokeWidth: 8,
                    )
                  : Text(''),
            ),
          ],
        );
      }),
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

Iterable<Widget> getFilesCoordinates({
  required double boardSize,
  required bool top,
  required bool reversed,
}) {
  final commonTextStyle = TextStyle(
    color: Colors.yellow.shade400,
    fontWeight: FontWeight.bold,
    fontSize: boardSize * 0.04,
  );

  return [0, 1, 2, 3, 4, 5, 6, 7].map(
    (file) {
      final letterOffset = !reversed ? file : 7 - file;
      final letter = String.fromCharCode('A'.codeUnitAt(0) + letterOffset);
      return Positioned(
        top: boardSize * (top ? 0.005 : 0.955),
        left: boardSize * (0.09 + 0.113 * file),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    },
  );
}

Iterable<Widget> getRanksCoordinates({
  required double boardSize,
  required bool left,
  required bool reversed,
}) {
  final commonTextStyle = TextStyle(
    color: Colors.yellow.shade400,
    fontWeight: FontWeight.bold,
    fontSize: boardSize * 0.04,
  );

  return [0, 1, 2, 3, 4, 5, 6, 7].map((rank) {
    final letterOffset = reversed ? rank : 7 - rank;
    final letter = String.fromCharCode('1'.codeUnitAt(0) + letterOffset);
    return Positioned(
      left: boardSize * (left ? 0.012 : 0.965),
      top: boardSize * (0.09 + 0.113 * rank),
      child: Text(
        letter,
        style: commonTextStyle,
      ),
    );
  });
}
