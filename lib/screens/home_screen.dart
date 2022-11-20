import 'dart:convert';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_simple_game_collection/bloc/theme_bloc/bloc/theme_bloc_bloc.dart';
import 'package:flutter_simple_game_collection/bloc/theme_bloc/bloc/theme_bloc_event.dart';
import 'package:flutter_simple_game_collection/components/rule_dialog.dart';
import 'package:flutter_simple_game_collection/screens/tic_tac_toe/tic_tac_toe.dart';
import 'package:flutter_simple_game_collection/utilities/app_themes.dart';
import 'package:flutter_simple_game_collection/utilities/constanst.dart';
import 'package:flutter_simple_game_collection/utilities/preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List listGame = [];

  @override
  void initState() {
    super.initState();
    _loadListGame();
  }

  void _loadListGame() {
    DefaultAssetBundle.of(context)
        .loadString("assets/datasets/gameList.json")
        .then((value) {
      final jsonResult = jsonDecode(value);
      setState(() {
        listGame = jsonResult['datas'];
      });
    });
  }

  _setTheme(bool darkTheme) async {
    AppTheme selectedTheme =
        darkTheme ? AppTheme.lightTheme : AppTheme.darkTheme;
    BlocProvider.of<ThemeBloc>(context)
        .add(ThemeBlocEvent(appTheme: selectedTheme));
    Preferences.saveTheme(selectedTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        backgroundColor: Theme.of(context).backgroundColor,
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(
            width: 50.0,
            height: 50.0,
            child: IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              tooltip: "Setting",
              iconSize: 50.0,
              icon: Icon(
                color: Preferences.getTheme() == AppTheme.lightTheme
                    ? kDarkBgColor
                    : kLightBgColor,
                Icons.settings,
              ),
              onPressed: () {},
            ),
          ),
          const Spacer(),
          AnimatedIconButton(
            alignment: Alignment.center,
            initialIcon: Preferences.getTheme() == AppTheme.lightTheme ? 1 : 0,
            size: 50,
            duration: const Duration(milliseconds: 500),
            splashColor: Colors.transparent,
            icons: const <AnimatedIconItem>[
              AnimatedIconItem(
                tooltip: 'Light Mode',
                icon: Icon(Icons.light_mode, color: kLightBgColor),
              ),
              AnimatedIconItem(
                tooltip: 'Dark Mode',
                icon: Icon(Icons.dark_mode, color: kDarkBgColor),
              ),
            ],
            onPressed: () {
              if (Preferences.getTheme() == AppTheme.lightTheme) {
                _setTheme(false);
              } else {
                _setTheme(true);
              }
            },
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final List<Widget> imageSliders = listGame
        .map(
          (item) => SafeArea(
            child: Card(
              color: Theme.of(context).cardColor,
              elevation: 7.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 7.0,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
              ),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                splashColor: Theme.of(context).splashColor,
                onTap: () => _selectGame(item),
                child: SizedBox(
                  width: 250.0,
                  height: 400.0,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                        child: item['image_path'] != null
                            ? Image.asset(
                                item['image_path'],
                                fit: BoxFit.contain,
                                width: 250.0,
                                height: 250.0,
                              )
                            : const SizedBox(
                                width: 250.0,
                                height: 400.0,
                                child: Center(
                                  child: Icon(Icons.games),
                                ),
                              ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        child: SizedBox(
                          width: 65.0,
                          height: 65.0,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                              backgroundColor: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style
                                  ?.backgroundColor,
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2.5,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.info_outline,
                                size: 50.0,
                              ),
                            ),
                            onPressed: () {
                              showRuleDialog(
                                context: context,
                                title: 'RULE - ${item['label']}',
                                content: item['rule'],
                                defaultActionText: 'OK',
                                onOkPressed: (() => Navigator.pop(context)),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        height: 75.0,
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: ClipPath(
                          clipper: const ShapeBorderClipper(
                            shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(25.0),
                                  topLeft: Radius.circular(25.0)),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              item['label'] ?? 'Game Title',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            height: 110.0,
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                    textAlign: TextAlign.center,
                    'GAME\nCOLLECTION',
                    textStyle: kAppbarTextStyle,
                    speed: const Duration(milliseconds: 150),
                    cursor: ''),
              ],
              pause: const Duration(milliseconds: 500),
              isRepeatingAnimation: true,
              repeatForever: true,
            ),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 350.0,
            aspectRatio: 16 / 9,
            autoPlay: false,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            scrollDirection: Axis.horizontal,
            autoPlayCurve: Curves.fastOutSlowIn,
            viewportFraction: 0.8,
          ),
          items: imageSliders,
        ),
      ],
    );
  }

  void _selectGame(Map<String, dynamic> item) {
    // showRuleDialog(
    //   context: context,
    //   title: item['label'],
    //   content:
    //       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    //   defaultActionText: "OK",
    //   onOkPressed: () => Navigator.pop(context),
    // );
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const TicTacToe()));
  }
}
