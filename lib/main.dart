import 'dart:math';

import 'package:flare_flutter/flare_controls.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:flutter/widgets.dart";
import "package:google_fonts/google_fonts.dart";

import "category.dart";
import "domain.dart";

//Test build
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ryan Portfolio",
      routes: <String, WidgetBuilder>{
        '/': (context) => Home(),
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        accentColor: Color(0xFF090909),
        appBarTheme: AppBarTheme(
          color: Color(0xFF090909),
        ),
        textTheme: GoogleFonts.latoTextTheme(
          ThemeData.dark().textTheme.copyWith(
                button: TextStyle(fontWeight: FontWeight.w300),
                headline3: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    color: Colors.white),
                bodyText1: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.3,
                    wordSpacing: 1.3,
                    color: Colors.grey),
              ),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Categories categories = Categories();
  bool initiallyLoaded = false;

  AnimationController initializedAnimation;

  @override
  void initState() {
    super.initState();
    var flareControls = FlareControls();

    initializedAnimation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    Future.wait([
      categories.loadFromFiles(),
      Future.delayed(Duration(milliseconds: 3500))
    ])
        .then((value) => initializedAnimation.forward())
        .then((value) => setState(() {
              initiallyLoaded = true;
            }));
  }

  @override
  void dispose() {
    super.dispose();
    initializedAnimation.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initiallyLoaded) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text("Test"),
            ),
            body: ListView(
              children: categories.categories
                  .asMap()
                  .entries
                  .map((entry) => CategorySection(
                        category: entry.value,
                        backgroundColor: entry.key.isOdd
                            ? Color(0xFF222222)
                            : Color(0xFF181818),
                      ))
                  .toList(),
            )),
      );
    } else {
      return Splash(
        animation: CurvedAnimation(
            parent: initializedAnimation, curve: Curves.easeInOut),
      );
    }
  }
}

class Splash extends StatelessWidget {
  final Animation<double> animation;

  const Splash({Key key, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Opacity(
                    opacity: Tween(begin: 1.0, end: 0.0).evaluate(animation),
                    child: Transform.scale(
                      scale: Tween(begin: 1.0, end: 0.2).evaluate(animation),
                      child: Transform.rotate(
                        angle: animation.value * pi,
                        child: child,
                      ),
                    ));
              },
              child: SizedBox(
                width: 300,
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Welcome to the portfolio of",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      "Ryan Susana",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ],
                ),
              ),
            ),
            CircularProgressIndicator(
              backgroundColor: Colors.red,
            )
          ],
        ),
      ),
    );
  }
}
