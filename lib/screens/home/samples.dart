import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SamplesScreen extends StatelessWidget {
  final _sampleFiles = <String>['KQ_K', 'K2R_K', 'KR_K', 'KP_K'];
  SamplesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _sampleFiles.length,
      itemBuilder: (ctx, index) {
        final itemRef = _sampleFiles[index];
        final itemText = FlutterI18n.translate(
          context,
          'sample_games.$itemRef',
        );

        return ListTile(
          leading: SvgPicture.asset(
            'assets/vectors/text_file.svg',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          title: Text(
            itemText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      padding: EdgeInsets.only(top: 10),
    );
  }
}
