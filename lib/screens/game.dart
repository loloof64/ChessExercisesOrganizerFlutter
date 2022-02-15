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
import 'package:chess_exercises_organizer/components/richboard.dart';
import 'package:stockfish/stockfish.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

import 'package:logger/logger.dart';

class GameScreen extends StatefulWidget {
  final int cpuThinkingTimeMs;
  final String startFen;
  const GameScreen({
    Key? key,
    this.cpuThinkingTimeMs = 1000,
    this.startFen = chesslib.Chess.DEFAULT_POSITION,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  var _chess;
  var _blackAtBottom = false;
  var _lastMove = <String>[];
  var _whitePlayerType = PlayerType.human;
  var _blackPlayerType = PlayerType.computer;
  late final _stockfish;

  @override
  void initState() {
    super.initState();
    _chess = new chesslib.Chess.fromFEN(widget.startFen);
    _initStockfish();
  }

  Future<void> _initStockfish() async {
    _stockfish = new Stockfish();
    _stockfish.stdout.listen(_processStockfishLine);
    await waitUntilStockfishReady();
    _stockfish.stdin = 'isready';
    _makeComputerMove();
  }

  Future<void> waitUntilStockfishReady() async {
    while (_stockfish.state.value != StockfishState.ready) {
      await Future.delayed(Duration(milliseconds: 600));
    }
  }

  Future<bool> _disposeStockfish() async {
    _stockfish.dispose();
    return true;
  }

  void _makeComputerMove() {
    final whiteTurn = _chess.turn == chesslib.Color.WHITE;
    final humanTurn = (whiteTurn && (_whitePlayerType == PlayerType.human)) ||
        (!whiteTurn && (_blackPlayerType == PlayerType.human));
    if (humanTurn) return;

    if (_chess.game_over) return;

    _stockfish.stdin = 'position fen ${_chess.fen}';
    _stockfish.stdin = 'go movetime ${widget.cpuThinkingTimeMs}';
  }

  void _processStockfishLine(String line) {
    print(line);
    if (line.startsWith('bestmove')) {
      final moveUci = line.split(' ')[1];
      final from = moveUci.substring(0, 2);
      final to = moveUci.substring(2, 4);
      final promotionStr = moveUci.length >= 5 ? moveUci.substring(4, 5) : null;
      var promotion;
      switch (promotionStr?.toLowerCase()) {
        case 'q':
          promotion = PieceType.QUEEN;
          break;
        case 'r':
          promotion = PieceType.ROOK;
          break;
        case 'b':
          promotion = PieceType.BISHOP;
          break;
        case 'n':
          promotion = PieceType.KNIGHT;
          break;
        default:
          promotion = null;
      }
      _chess.move(<String, String?>{
        'from': from,
        'to': to,
        'promotion': promotion,
      });
      setState(() {
        _lastMove.clear();
        _lastMove.addAll([from, to]);
      });
      _makeComputerMove();
    }
  }

  void _restartGame() {
    ////////////////////
    Logger().i(widget.startFen);
    ///////////////////////
    setState(() {
      _chess = new chesslib.Chess.fromFEN(widget.startFen);
      _lastMove.clear();
    });
  }

  void _purposeRestartGame(BuildContext context) {
    void closeDialog() {
      Navigator.of(context).pop();
    }

    void doStartNewGame() {
      closeDialog();
      _restartGame();
    }

    final isStartPosition = _chess.fen == chesslib.Chess.DEFAULT_POSITION;
    if (isStartPosition) return;

    showDialog(
      context: context,
      builder: (BuildContext innerCtx) {
        return AlertDialog(
          title: I18nText('game.restart_game_title'),
          content: I18nText('game.restart_game_msg'),
          actions: [
            ElevatedButton(
              onPressed: doStartNewGame,
              child: I18nText(
                'buttons.ok',
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
                textStyle: TextStyle(color: Colors.white),
                elevation: 5,
              ),
            ),
            ElevatedButton(
              onPressed: closeDialog,
              child: I18nText(
                'buttons.cancel',
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
                textStyle: TextStyle(color: Colors.white),
                elevation: 5,
              ),
            )
          ],
        );
      },
    );
  }

  Future<PieceType?> _handlePromotion(BuildContext context) async {
    final promotion = await _showPromotionDialog(context);
    _makeComputerMove();
    return promotion;
  }

  Future<PieceType?> _showPromotionDialog(BuildContext context) {
    final pieceSize = _getMinScreenSize(context) *
        (_isInLandscapeMode(context) ? 0.75 : 1.0) *
        0.15;
    final whiteTurn = _chess.fen.split(' ')[1] == 'w';
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

  void _tryMakingMove({required ShortMove move}) {
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
        _lastMove.addAll([move.from, move.to]);
      });
      _makeComputerMove();
    }
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
  void dispose() {
    _disposeStockfish();
    super.dispose();
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
        orientation: _blackAtBottom ? BoardColor.BLACK : BoardColor.WHITE,
        whitePlayerType: _whitePlayerType,
        blackPlayerType: _blackPlayerType,
        lastMoveToHighlight: _lastMove,
        onPromote: () => _handlePromotion(context),
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
            onPressed: () => _purposeRestartGame(context),
            icon: Icon(
              Icons.restart_alt_outlined,
            ),
          ),
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
