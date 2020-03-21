import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'domain.dart';

class PostCard extends StatelessWidget {
  const PostCard({Key key, @required this.cardSize, this.post})
      : super(key: key);

  final Post post;
  final double cardSize;

  @override
  Widget build(BuildContext context) {
    String tag = Provider.of<Category>(context).id + "/" + post.id;
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PostScreen(
                    post: post,
                    tag: tag,
                  )));
        },
        child: Ink(
          width: cardSize,
          height: cardSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Hero(
                  tag: tag,
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      this.post.image,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Ink(
                  color: Color(0x00ffffff),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        this.post.title,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PostList extends StatelessWidget {
  final List<Post> posts;

  const PostList({
    Key key,
    this.posts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cardSize = min(MediaQuery.of(context).size.width * 0.6, 300);
    return SizedBox(
      height: cardSize,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          ...this.posts.map(
                (post) => Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 8, bottom: 8),
                  child: PostCard(
                    cardSize: cardSize,
                    post: post,
                  ),
                ),
              ),
          SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }
}

class PostScreen extends StatelessWidget {
  final String tag;
  final Post post;

  const PostScreen({Key key, this.post, @required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool wideScreen = size.width > size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(post.title),
      ),
      body: Container(
        child: !wideScreen
            ? SingleChildScrollView(
                child: PostContent(tag: tag, post: post),
              )
            : PostContent(tag: tag, post: post),
      ),
    );
  }
}

class PostContent extends StatelessWidget {
  const PostContent({
    Key key,
    this.tag,
    @required this.post,
  }) : super(key: key);

  final String tag;
  final Post post;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool wideScreen = size.width > size.height;
    return Flex(
      direction: wideScreen ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: wideScreen ? size.width / 2 : double.infinity,
          height: wideScreen ? double.infinity : null,
          child: Hero(
            tag: this.tag ?? Uuid().v4(),
            child: Image.network(
              post.image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          width: wideScreen ? size.width / 2 : double.infinity,
          child: wideScreen
              ? SingleChildScrollView(
                  child: PostHtmlContent(post: post),
                )
              : PostHtmlContent(
                  post: post,
                ),
        )
      ],
    );
  }
}

class PostHtmlContent extends StatelessWidget {
  const PostHtmlContent({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.all(min(100.0, MediaQuery.of(context).size.width / 20)),
      child: Html(
        onLinkTap: (url) async {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            print('Could not launch $url');
          }
        },
        defaultTextStyle:
            Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
        data: post.content,
      ),
    );
  }
}
