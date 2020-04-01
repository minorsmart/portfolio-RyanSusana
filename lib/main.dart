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
        '/': (context) => Home(),
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
  List<Category> categories = [];

  ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = new ScrollController();
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

  double mix(double min, double max, double a) => min + a * (max - min);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    var introCardWidth = 350;

    var headerHeight = 600.0;

    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Theme.of(context).appBarTheme.color,
        child: SafeArea(
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Color(0xff111111),
            onRefresh: () {
              return loadCategories();
            },
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              controller: controller,
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  leading: Icon(Icons.menu),
                  expandedHeight: headerHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    background: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            right: 0,
                            left: 0,
                            height: headerHeight,
                            child: Image.asset(
                              "assets/header.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          AnimatedBuilder(
                            animation: controller,
                            builder: (context, child) {
                              return Positioned(
                                top: 200 + controller.offset / 3,
                                right: (screenWidth - introCardWidth) / 2,
                                left: (screenWidth - introCardWidth) / 2,
                                child: Opacity(
                                  opacity: Tween<double>(begin: 0.0, end: 1.0)
                                      .transform(
                                          (1 - controller.offset / headerHeight)
                                              .clamp(0.0, 1.0)),
                                  child: child,
                                ),
                              );
                            },
                            child: OpeningCard(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ...categories
                          .where((element) => element.posts.length > 0)
                          .toList()
                          .asMap()
                          .entries
                          .map(
                            (entry) => CategorySection(
                              category: entry.value,
                              backgroundColor: entry.key.isOdd
                                  ? Color(0xFF222222)
                                  : Theme.of(context).appBarTheme.color,
                            ),
                          )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OpeningCard extends StatelessWidget {
  const OpeningCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(50.0),
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
          ],
        ),
      ),
    );
  }
}
