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

    initializedAnimation = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    Future.wait([
      categories.loadFromFiles(),
      Future.delayed(Duration(milliseconds: 3500))
    ])
        .then((value) => initializedAnimation.forward().then((value) =>
            Future.delayed(Duration(seconds: 2))
                .then((value) => initializedAnimation.reverse())))
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
        open: CurvedAnimation(
            parent: initializedAnimation, curve: Curves.easeInOut),
      );
    }
  }
}

class Splash extends StatelessWidget {
  final Animation<double> open;

  final Animation<double> scale;
  final Animation<double> opacity;
  final Animation<double> offsetY;

  Splash({Key key, this.open})
      : scale = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: open,
            curve: Interval(
              0.0,
              0.600,
              curve: Curves.bounceInOut,
            ),
          ),
        ),
        offsetY = Tween<double>(begin: 100, end: 0).animate(
          CurvedAnimation(
            parent: open,
            curve: Interval(
              0.200,
              1.00,
              curve: Curves.easeInOut,
            ),
          ),
        ),
        opacity = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: open,
            curve: Interval(
              0.100,
              0.400,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: open,
      builder: (context, child) {
        return Container(
          color: Theme.of(context).accentColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Transform.translate(
                  offset: Offset(0, offsetY.value),
                  child: Transform.scale(
                    scale: scale.value,
                    child: Opacity(
                      opacity: opacity.value,
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
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: this.open.isCompleted
                      ? CircularProgressIndicator(
                          strokeWidth: 2.0,
                          backgroundColor: Colors.red,
                        )
                      : Container(),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
