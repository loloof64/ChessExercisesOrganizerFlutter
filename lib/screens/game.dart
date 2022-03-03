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

import 'package:chess_exercises_organizer/components/history.dart';
import 'package:chess_exercises_organizer/logic/history/history_builder.dart';
import 'package:chess_exercises_organizer/stores/game_store.dart';
import 'package:chess_exercises_organizer/components/dialog_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import "package:chess/chess.dart" as chesslib;
import 'package:chess_exercises_organizer/components/richboard.dart';
import 'package:stockfish/stockfish.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

class GameScreen extends StatefulWidget {
  static const routerName = 'game';
  final int cpuThinkingTimeMs;
  const GameScreen({
    Key? key,
    this.cpuThinkingTimeMs = 1000,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late chesslib.Chess _chess;
  var _blackAtBottom = false;
  var _lastMoveArrowCoordinates = <String>[];
  var _whitePlayerType = PlayerType.computer;
  var _blackPlayerType = PlayerType.computer;
  var _stockfish;
  var _engineThinking = false;
  var _gameStart = true;
  var _lastInputPositionForCpuComputation = '';
  HistoryNode? _gameHistoryTree = null;
  HistoryNode? _currentGameHistoryNode = null;
  HistoryNode? _solutionHistoryTree = null;
  List<Widget> _historyWidgetsTree = [];

  @override
  void initState() {
    super.initState();
    _initStockfish().then((_) => null).catchError((e, stacktrace) {
      Logger().e(stacktrace);
    });
    _loadSolutionHistory().then((_) => null).catchError((e, stacktrace) {
      Logger().e(stacktrace);
    });
    _restartGame();
  }

  void _updateHistoryChildrenWidgets() {
    setState(() {
      if (_gameHistoryTree != null) {
        _historyWidgetsTree = recursivelyBuildWidgetsFromHistoryTree(
          fontSize: 20,
          tree: _gameHistoryTree!,
          onMoveDoneUpdateRequest: onMoveDoneUpdateRequest,
        );
      }
    });
  }

  void onMoveDoneUpdateRequest({required Move moveDone}) {}

  void _resetGameHistory() {
    final gameStore = context.read<GameStore>();
    final startPosition = gameStore.getStartPosition();
    final parts = startPosition.split(' ');
    final whiteTurn = parts[1] == 'w';
    final moveNumber = parts[5];
    final caption = "${moveNumber}${whiteTurn ? '.' : '...'}";
    setState(() {
      _gameHistoryTree = HistoryNode(caption: caption);
      _currentGameHistoryNode = _gameHistoryTree;
    });
  }

  Future<void> _loadSolutionHistory() async {
    var gameStore = context.read<GameStore>();
    try {
      final historyTree =
          await buildHistoryTreeFromPgnTree(gameStore.getSelectedGame());
      setState(() {
        _solutionHistoryTree = historyTree;
      });
    } catch (err, stacktrace) {
      Logger().e(stacktrace);
      setState(() {
        _solutionHistoryTree = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: I18nText(
            'game.solution_loading_error',
          ),
        ),
      );
    }
  }

  Future<void> _initStockfish() async {
    _stockfish = new Stockfish();
    _stockfish.stdout.listen(_processStockfishLine);
    await _waitUntilStockfishReady();
    _stockfish.stdin = 'isready';
    _restartGame();
  }

  Future<void> _waitUntilStockfishReady() async {
    while (!_stockfishReady()) {
      await Future.delayed(Duration(milliseconds: 600));
    }
  }

  bool _stockfishReady() => _stockfish.state.value == StockfishState.ready;

  _disposeStockfish() {
    if (_stockfishReady()) _stockfish.dispose();
    _stockfish = null;
  }

  Future<void> _makeComputerMove() async {
    /*
    Important check !
    We don't want CPU to compute twice on the same position.
    */
    if (_engineThinking) return;
    await _waitUntilStockfishReady();
    final whiteTurn = _chess.turn == chesslib.Color.WHITE;
    final humanTurn = (whiteTurn && (_whitePlayerType == PlayerType.human)) ||
        (!whiteTurn && (_blackPlayerType == PlayerType.human));
    if (humanTurn) return;

    if (_chess.game_over) {
      return;
    }

    setState(() {
      _engineThinking = true;
    });

    /*
    As code is multi-threaded : we don't want CPU to process
    twice the same position (in a row).
    */
    if (_lastInputPositionForCpuComputation == _chess.fen) return;
    setState(() {
      _lastInputPositionForCpuComputation = _chess.fen;
    });

    _stockfish.stdin = 'position fen ${_chess.fen}';
    _stockfish.stdin = 'go movetime ${widget.cpuThinkingTimeMs}';
  }

  void _processStockfishLine(String line) {
    if (line.startsWith('bestmove')) {
      final moveUci = line.split(' ')[1];
      final from = moveUci.substring(0, 2);
      final to = moveUci.substring(2, 4);
      final promotion = moveUci.length >= 5 ? moveUci.substring(4, 5) : null;
      _chess.move(<String, String?>{
        'from': from,
        'to': to,
        'promotion': promotion?.toLowerCase(),
      });
      if (mounted) {
        setState(() {
          _engineThinking = false;
          _lastMoveArrowCoordinates.clear();
          _lastMoveArrowCoordinates.addAll([from, to]);
          _addMoveToHistory();
          _gameStart = false;
        });
      } else {
        return;
      }
      if (_chess.game_over) {
        final gameResultString = _getGameResultString();
        final nextHistoryNode = HistoryNode(caption: gameResultString);

        setState(() {
          _currentGameHistoryNode?.next = nextHistoryNode;
          _currentGameHistoryNode = nextHistoryNode;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: _getGameEndedType(),
          ),
        );
        return;
      } else {
        _makeComputerMove();
      }
    }
  }

  void _restartGame() {
    setState(() {
      var gameStore = context.read<GameStore>();
      final startPosition = gameStore.getStartPosition();
      _lastInputPositionForCpuComputation = '';
      _chess = new chesslib.Chess.fromFEN(startPosition);
      _resetGameHistory();
      _lastMoveArrowCoordinates.clear();
      _gameStart = true;
    });
    _updateHistoryChildrenWidgets();
    _makeComputerMove();
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
            DialogActionButton(
              onPressed: doStartNewGame,
              textContent: I18nText(
                'buttons.ok',
              ),
              backgroundColor: Colors.tealAccent,
              textColor: Colors.white,
            ),
            DialogActionButton(
              onPressed: closeDialog,
              textContent: I18nText(
                'buttons.cancel',
              ),
              textColor: Colors.white,
              backgroundColor: Colors.redAccent,
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

  Widget _getGameEndedType() {
    var result = null;
    if (_chess.in_checkmate) {
      result = (_chess.turn == chesslib.Color.WHITE)
          ? I18nText('game_termination.black_checkmate_white')
          : I18nText('game_termination.white_checkmate_black');
    } else if (_chess.in_stalemate) {
      result = I18nText('game_termination.stalemate');
    } else if (_chess.in_threefold_repetition) {
      result = I18nText('game_termination.repetitions');
    } else if (_chess.insufficient_material) {
      result = I18nText('game_termination.insufficient_material');
    } else if (_chess.in_draw) {
      result = I18nText('game_termination.fifty_moves');
    }
    return result;
  }

  /*
    Must be called after a move has just been
    added to _chess (Chess class instance)
    Do not update state itself.
  */
  void _addMoveToHistory() {
    if (_currentGameHistoryNode != null) {
      final whiteMove = _chess.turn == chesslib.Color.WHITE;
      final lastPlayedMove = _chess.history.last.move;

      /*
      We need to know if it was white move before the move which
      we want to add history node(s).
      */
      if (!whiteMove && !_gameStart) {
        final moveNumber = _chess.move_number;
        final moveNumberCaption = "${moveNumber}.";
        final nextHistoryNode = HistoryNode(caption: moveNumberCaption);
        _currentGameHistoryNode?.next = nextHistoryNode;
        _currentGameHistoryNode = nextHistoryNode;
      }

      // In order to get move SAN, it must not be done on board yet !
      // So we rollback the move, then we'll make it happen again.
      _chess.undo_move();
      final san = _chess.move_to_san(lastPlayedMove);
      _chess.make_move(lastPlayedMove);

      // Move has been played: we need to revert player turn for the SAN.
      final fan = san.toFan(whiteMove: !whiteMove);
      final relatedMoveFromSquareIndex = CellIndexConverter(lastPlayedMove.from)
          .convertSquareIndexFromChessLib();
      final relatedMoveToSquareIndex = CellIndexConverter(lastPlayedMove.to)
          .convertSquareIndexFromChessLib();
      final relatedMove = Move(
        from: Cell.fromSquareIndex(relatedMoveFromSquareIndex),
        to: Cell.fromSquareIndex(relatedMoveToSquareIndex),
      );

      final nextHistoryNode = HistoryNode(
        caption: fan,
        fen: _chess.fen,
        relatedMove: relatedMove,
      );
      _currentGameHistoryNode?.next = nextHistoryNode;
      _currentGameHistoryNode = nextHistoryNode;
      _updateHistoryChildrenWidgets();
    }
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
        _lastMoveArrowCoordinates.clear();
        _lastMoveArrowCoordinates.addAll([move.from, move.to]);
        _addMoveToHistory();
        _gameStart = false;
      });
      if (_chess.game_over) {
        final gameResultString = _getGameResultString();
        final nextHistoryNode = HistoryNode(caption: gameResultString);

        setState(() {
          _currentGameHistoryNode?.next = nextHistoryNode;
          _currentGameHistoryNode = nextHistoryNode;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: _getGameEndedType(),
          ),
        );
      }
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

  void _confirmBeforeExit(BuildContext contex) {
    void closeDialog() {
      Navigator.of(context).pop();
    }

    void doExitGame() {
      // Exiting dialog
      Navigator.of(context).pop();
      // Returning to home page
      Navigator.of(context).pop();
    }

    final dialogShowingDelayMs = _stockfishReady() ? 0 : 800;

    Future.delayed(Duration(milliseconds: dialogShowingDelayMs), () {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: I18nText('game.exit_game_title'),
              content: I18nText('game.exit_game_msg'),
              actions: [
                DialogActionButton(
                  onPressed: doExitGame,
                  textContent: I18nText(
                    'buttons.ok',
                  ),
                  backgroundColor: Colors.tealAccent,
                  textColor: Colors.white,
                ),
                DialogActionButton(
                  onPressed: closeDialog,
                  textContent: I18nText(
                    'buttons.cancel',
                  ),
                  textColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                )
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() async {
      _confirmBeforeExit(context);
      return false;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
        body: Consumer<GameStore>(builder: (ctx, gameStore, child) {
          return Center(
            child: GameContent(
              boardOrientationBlackBottom: _blackAtBottom,
              boardPosition: _chess.fen,
              engineThinking: _engineThinking,
              whitePlayerType: _whitePlayerType,
              blackPlayerType: _blackPlayerType,
              lastMove: _lastMoveArrowCoordinates,
              historyTree: _gameHistoryTree,
              initStockfish: _initStockfish,
              disposeStockfish: _disposeStockfish,
              tryMakingMove: _tryMakingMove,
              handlePromotion: _handlePromotion,
              historyChildren: _historyWidgetsTree,
            ),
          );
        }),
      ),
    );
  }

  String _getGameResultString() {
    if (_chess.in_checkmate)
      return _chess.turn == chesslib.Color.WHITE ? '0-1' : '1-0';
    else if (_chess.in_draw) {
      return '1/2-1/2';
    }
    return '*';
  }
}

class TempZone extends StatelessWidget {
  final bool isDebugging;
  final void Function() initStockfish;
  final void Function() disposeStockfish;
  const TempZone(
      {Key? key,
      required this.isDebugging,
      required this.initStockfish,
      required this.disposeStockfish})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: isDebugging
            ? <Widget>[
                ElevatedButton(
                  onPressed: disposeStockfish,
                  child: Wrap(
                    children: [
                      Icon(Icons.warning_rounded),
                      Text(
                        'Dispose stockfish before reload !',
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: initStockfish,
                  child: Wrap(children: [
                    Icon(Icons.warning_rounded),
                    Text('Restart stockfish after reload !'),
                  ]),
                )
              ]
            : <Widget>[]);
  }
}

class GameContent extends StatelessWidget {
  final bool engineThinking;
  final bool boardOrientationBlackBottom;
  final String boardPosition;
  final PlayerType whitePlayerType;
  final PlayerType blackPlayerType;
  final List<String> lastMove;
  final HistoryNode? historyTree;
  final List<Widget> historyChildren;
  final void Function() initStockfish;
  final void Function() disposeStockfish;
  final void Function({required ShortMove move}) tryMakingMove;
  final Future<PieceType?> Function(BuildContext context) handlePromotion;

  const GameContent({
    Key? key,
    required this.engineThinking,
    required this.boardPosition,
    required this.boardOrientationBlackBottom,
    required this.whitePlayerType,
    required this.blackPlayerType,
    required this.lastMove,
    required this.historyTree,
    required this.historyChildren,
    required this.initStockfish,
    required this.disposeStockfish,
    required this.tryMakingMove,
    required this.handlePromotion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isInLandscapeMode =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final boardOrientation =
        boardOrientationBlackBottom ? BoardColor.BLACK : BoardColor.WHITE;
    return isInLandscapeMode
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RichChessboard(
                engineThinking: engineThinking,
                fen: boardPosition,
                onMove: tryMakingMove,
                orientation: boardOrientation,
                whitePlayerType: whitePlayerType,
                blackPlayerType: blackPlayerType,
                lastMoveToHighlight: lastMove,
                onPromote: () => handlePromotion(context),
              ),
              ChessHistory(
                historyTree: historyTree,
                children: historyChildren,
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RichChessboard(
                engineThinking: engineThinking,
                fen: boardPosition,
                onMove: tryMakingMove,
                orientation: boardOrientation,
                whitePlayerType: whitePlayerType,
                blackPlayerType: blackPlayerType,
                lastMoveToHighlight: lastMove,
                onPromote: () => handlePromotion(context),
              ),
              ChessHistory(
                historyTree: historyTree,
                children: historyChildren,
              ),
            ],
          );
  }
}
