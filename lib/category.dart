import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'domain.dart';
import 'post.dart';

class CategorySection extends StatelessWidget {
  final Color backgroundColor;

  final Category category;

  const CategorySection({
    Key key,
    this.backgroundColor: const Color(0xFF222222),
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    this.category.name,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Text(
                      this.category.description,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Provider.value(
                value: this.category,
                child: PostList(posts: category.posts ?? []))
          ],
        ),
      ),
    );
  }
}
