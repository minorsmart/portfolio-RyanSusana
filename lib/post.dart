import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'domain.dart';

class PostCard extends StatelessWidget {
  const PostCard({Key key, @required this.cardSize, this.post, this.categoryId})
      : super(key: key);

  final Post post;
  final String categoryId;
  final double cardSize;

  @override
  Widget build(BuildContext context) {
    String category = this.categoryId ?? Provider.of<Category>(context).id;
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "/post/$category/${post.id}");
        },
        child: Ink(
          width: cardSize,
          height: cardSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 90,
                child: Hero(
                  tag: "$category/${post.id}",
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      this.post.image,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).primaryColor),
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
                flex: 35,
                child: Ink(
                  color: Color(0x00ffffff),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        this.post.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FuturePostList extends StatelessWidget {
  final String categoryId;

  final Map<String, String> qry;

  const FuturePostList({Key key, this.categoryId, this.qry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Iterable<Post>>(
      future: Post.qry(qry),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PostList(
            posts: snapshot.data.toList(),
            categoryId: categoryId,
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class PostList extends StatelessWidget {
  final List<Post> posts;
  final String categoryId;

  const PostList({
    Key key,
    this.posts,
    this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cardSize = min(MediaQuery.of(context).size.width * 0.6, 300).toDouble();
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
                    categoryId: categoryId,
                    post: post,
                  ),
                ),
              ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}

class PostScreen extends StatefulWidget {
  final String tag;
  final Post post;
  final String postId;

  PostScreen({Key key, this.post, postId, this.tag})
      : this.postId = postId ?? post.id,
        super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Post post;

  @override
  Widget build(BuildContext context) {
    if (this.post == null) {
      return Container(
        color: Theme.of(context).accentColor,
      );
    }

    var tag = "${(widget.tag ?? Uuid().v4())}/${post.id}";

    var size = MediaQuery.of(context).size;
    bool wideScreen = size.width > size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 200, maxHeight: 500),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(post.title),
        ),
        body: Container(
          child: !wideScreen
              ? RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  onRefresh: () => reloadPost(),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: PostContent(
                      tag: tag,
                      post: post,
                    ),
                  ),
                )
              : PostContent(tag: widget.tag, post: post),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    post = Domain.getCachedPost(widget.postId);
    if (post == null) {
      Domain.load();
    }
    reloadPost();
  }

  Future<void> reloadPost() async {
    var newPost = await Post.getById(widget.postId);
    setState(() {
      this.post = newPost;
    });
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
    double padding = min(100.0, MediaQuery.of(context).size.width / 20);
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
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                          width: double.infinity,
                          child: PostHeader(padding: padding, post: post)),
                      PostHtmlContent(post: post, padding: padding),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: double.infinity,
                        child: PostHeader(padding: padding, post: post)),
                    PostHtmlContent(
                      post: post,
                      padding: padding,
                    ),
                  ],
                ),
        )
      ],
    );
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({
    Key key,
    @required this.padding,
    @required this.post,
  }) : super(key: key);

  final double padding;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: padding, right: padding, top: padding),
          child: Text(post.title,
              style:
                  Theme.of(context).textTheme.headline3.copyWith(fontSize: 24)),
        ),
        Padding(
          padding:
              EdgeInsets.only(top: 10, left: padding, right: padding, bottom: 20),
          child: Wrap(
            spacing: 5,
            children: post.categoryIds
                .map(
                  (e) => Chip(
                      label: Text(Domain.getCategory(e).name,
                          style: TextStyle(fontSize: 14))),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class PostHtmlContent extends StatelessWidget {
  const PostHtmlContent({
    Key key,
    @required this.post,
    this.padding,
  }) : super(key: key);

  final Post post;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding, left: padding, right: padding),
      child: Html(
        onLinkTap: (url) async {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            print('Could not launch $url');
          }
        },
        data: post.content ?? '<p>No content...</p>',
      ),
    );
  }
}
