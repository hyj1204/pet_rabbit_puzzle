import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_puzzle/l10n/l10n.dart';
import 'package:flutter_puzzle/puzzle/puzzle.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
//为什么要加入这部分
    Future<void>.delayed(const Duration(milliseconds: 20), () {
      //在20秒之后,执行 把图片放入image cache里
      //precache image 第一次加载的时候存好，下一次会更快得显示这张图片
      //里面放的是imageProvider
      precacheImage(
        Image.asset('assets/images/shuffle_icon.png').image,
        context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFF13B9FF),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PuzzlePage(),
    );
  }
}
