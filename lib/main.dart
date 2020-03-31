import 'package:fluro/fluro.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:flutter/widgets.dart";
import "package:google_fonts/google_fonts.dart";
import 'package:portfolio_minor/post.dart';
import 'package:provider/provider.dart';

import 'category.dart';
import "domain.dart";

//Test build
void main() {
  var router = Router();
  router.define(
    "/post/:category/:id",
    handler: Handler(handlerFunc: (context, params) {
      return PostScreen(
        postId: params["id"][0],
        tag: params["category"][0],
      );
    }),
  );

  Domain.load();

  runApp(
    Provider.value(
      value: router,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ryan Portfolio",
      onGenerateRoute: Provider.of<Router>(context).generator,
      routes: <String, WidgetBuilder>{
        '/home': (context) => Home(),
        '/': (context) => Splash(),
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        brightness: Brightness.dark,
        accentColor: Color(0xFF090909),
        appBarTheme: AppBarTheme(
          color: Color(0xFF191919),
        ),
        textTheme: GoogleFonts.latoTextTheme(
          ThemeData.dark().textTheme.copyWith(
                button: TextStyle(fontWeight: FontWeight.w300),
                headline3: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
                bodyText1: TextStyle(
                    fontSize: 18,
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
  List<Category> categories;

  AnimationController initializedAnimation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadCategories();
  }

  Future loadCategories() {
    return Domain.load().then((value) => setState(() {
          categories = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) {
      return Container(
        color: Theme.of(context).appBarTheme.color,
      );
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Theme.of(context).appBarTheme.color,
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            body: RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Color(0xff111111),
              onRefresh: () {
                return loadCategories();
              },
              child: ListView(
                children: categories
                    .where((element) => element.posts.length > 0)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) => CategorySection(
                          category: entry.value,
                          backgroundColor: entry.key.isOdd
                              ? Color(0xFF222222)
                              : Theme.of(context).appBarTheme.color,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  AnimationController initializedAnimation;

  void load() {
    Future.wait([
      Future.delayed(Duration(milliseconds: 3500)),
      Future.delayed(Duration(milliseconds: 1000))
          .then((value) => initializedAnimation.forward())
    ])
        .then((value) => initializedAnimation.reverse())
        .then((value) => Navigator.of(context).pushReplacementNamed("/home"));
  }

  @override
  void dispose() {
    super.dispose();
    initializedAnimation.dispose();
  }

  @override
  void initState() {
    super.initState();

    initializedAnimation = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
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
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
