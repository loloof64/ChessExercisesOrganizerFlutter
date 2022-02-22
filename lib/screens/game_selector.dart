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

import 'package:chess_exercises_organizer/screens/game.dart';
import 'package:flutter/material.dart';
import 'package:chess_exercises_organizer/components/richboard.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:chess_exercises_organizer/stores/game_store.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart';
import 'package:chess_exercises_organizer/components/dialog_buttons.dart';

class GameSelectorScreen extends StatefulWidget {
  static const routeName = 'game-selector';
  const GameSelectorScreen({Key? key}) : super(key: key);

  @override
  _GameSelectorScreenState createState() => _GameSelectorScreenState();
}

class _GameSelectorScreenState extends State<GameSelectorScreen> {
  void gotoFirst() {
    final gameStore = context.read<GameStore>();
    setState(() {
      gameStore.gotoFirstGame();
    });
  }

  void gotoPrevious() {
    final gameStore = context.read<GameStore>();
    setState(() {
      gameStore.gotoPreviousGame();
    });
  }

  void gotoNext() {
    final gameStore = context.read<GameStore>();
    setState(() {
      gameStore.gotoNextGame();
    });
  }

  void gotoLast() {
    final gameStore = context.read<GameStore>();
    setState(() {
      gameStore.gotoLastGame();
    });
  }

  void handleValidation() {
    Navigator.of(context).pushReplacementNamed(GameScreen.routerName);
  }

  void handleCancelation() {
    // Returing to home page
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final gameStore = context.read<GameStore>();
    final fileTitle = gameStore.fileTitle;
    final gameIndex = gameStore.selectedGameIndex;
    final gamesCount = gameStore.gamesCount;
    final isInLandscapeMode =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final minScreenSize =
        screenWidth < screenHeight ? screenWidth : screenHeight;
    final fen = gameStore.getStartPosition();
    final isWhiteMove = fen.split(' ')[1] == 'w';
    final boardOrientation = isWhiteMove ? BoardColor.WHITE : BoardColor.BLACK;

    return Scaffold(
      appBar: AppBar(
        title: I18nText('game_selector.title'),
      ),
      body: Consumer<GameStore>(
        builder: (ctx, gameStore, child) {
          return isInLandscapeMode
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RichChessboard(
                      fen: fen,
                      size: minScreenSize * (isInLandscapeMode ? 0.75 : 1.0),
                      onMove: ({required ShortMove move}) {},
                      orientation: boardOrientation,
                      whitePlayerType: PlayerType.computer,
                      blackPlayerType: PlayerType.computer,
                      onPromote: () async {
                        return null;
                      },
                      engineThinking: false,
                    ),
                    Column(
                      children: [
                        _DataZone(
                          fileTitle: fileTitle,
                          gameIndex: gameIndex,
                          gamesCount: gamesCount,
                          goFirstHandler: gotoFirst,
                          goPreviousHandler: gotoPrevious,
                          goNextHandler: gotoNext,
                          goLastHandler: gotoLast,
                        ),
                        _ValidationZone(
                          validationHandler: handleValidation,
                          cancelationHandler: handleCancelation,
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichChessboard(
                      fen: fen,
                      size: minScreenSize * (isInLandscapeMode ? 0.75 : 1.0),
                      onMove: ({required ShortMove move}) {},
                      orientation: boardOrientation,
                      whitePlayerType: PlayerType.computer,
                      blackPlayerType: PlayerType.computer,
                      onPromote: () async {
                        return null;
                      },
                      engineThinking: false,
                    ),
                    _DataZone(
                      fileTitle: fileTitle,
                      gameIndex: gameIndex,
                      gamesCount: gamesCount,
                      goFirstHandler: gotoFirst,
                      goPreviousHandler: gotoPrevious,
                      goNextHandler: gotoNext,
                      goLastHandler: gotoLast,
                    ),
                    _ValidationZone(
                      validationHandler: handleValidation,
                      cancelationHandler: handleCancelation,
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _DataZone extends StatelessWidget {
  final String fileTitle;
  final int gameIndex;
  final int gamesCount;
  final void Function() goFirstHandler;
  final void Function() goPreviousHandler;
  final void Function() goNextHandler;
  final void Function() goLastHandler;
  const _DataZone({
    Key? key,
    required this.fileTitle,
    required this.gameIndex,
    required this.gamesCount,
    required this.goFirstHandler,
    required this.goPreviousHandler,
    required this.goNextHandler,
    required this.goLastHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameStore = context.read<GameStore>();
    final goalValue = gameStore.getGameGoal();
    final fen = gameStore.getStartPosition();
    final isWhiteTurn = fen.split(' ')[1] == 'w';
    final whiteCheckmateRegex = RegExp(r'\#(\d)-0');
    final blackCheckmateRegex = RegExp(r'0-\#(\d)');

    var goalString;
    if (goalValue == null) {
      goalString = '';
    } else if (goalValue == '1-0') {
      goalString = FlutterI18n.translate(context, 'game_goal.white_win');
    } else if (goalValue == '0-1') {
      goalString = FlutterI18n.translate(context, 'game_goal.black_win');
    } else if (goalValue == '1/2-1/2') {
      goalString = FlutterI18n.translate(
          context, isWhiteTurn ? 'game_goal.white_win' : 'game_goal.black_win');
    } else if (whiteCheckmateRegex.hasMatch(goalValue)) {
      final match = whiteCheckmateRegex.firstMatch(goalValue);
      final movesCount = match!.group(1)!;
      goalString = FlutterI18n.translate(context, 'game_goal.white_checkmate',
          translationParams: {'moves': movesCount});
    } else if (blackCheckmateRegex.hasMatch(goalValue)) {
      final match = blackCheckmateRegex.firstMatch(goalValue);
      final movesCount = match!.group(1)!;
      goalString = FlutterI18n.translate(context, 'game_goal.black_checkmate',
          translationParams: {'moves': movesCount});
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              fileTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: goFirstHandler,
              icon: Icon(Icons.skip_previous),
            ),
            IconButton(
              onPressed: goPreviousHandler,
              icon: Icon(Icons.arrow_back),
            ),
            Text("${gameIndex + 1} / ${gamesCount}"),
            IconButton(
              onPressed: goNextHandler,
              icon: Icon(Icons.arrow_forward),
            ),
            IconButton(
              onPressed: goLastHandler,
              icon: Icon(Icons.skip_next),
            ),
          ],
        ),
        if (goalString.isNotEmpty) Text(goalString),
      ],
    );
  }
}

class _ValidationZone extends StatelessWidget {
  final void Function() validationHandler;
  final void Function() cancelationHandler;
  const _ValidationZone({
    Key? key,
    required this.validationHandler,
    required this.cancelationHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DialogActionButton(
          onPressed: validationHandler,
          textContent: I18nText(
            'buttons.ok',
          ),
          backgroundColor: Colors.tealAccent,
          textColor: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: DialogActionButton(
            onPressed: cancelationHandler,
            textContent: I18nText(
              'buttons.cancel',
            ),
            textColor: Colors.white,
            backgroundColor: Colors.redAccent,
          ),
        )
      ],
    );
  }
}
