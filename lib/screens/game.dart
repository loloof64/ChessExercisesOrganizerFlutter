import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ChessBoardController _controller = ChessBoardController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: I18nText('game.title'),
      ),
      body: Center(
          child: Column(
        children: [
          ChessBoard(controller: _controller),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            child: I18nText('game.go_back_home'),
          )
        ],
      )),
    );
  }
}
