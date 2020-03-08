import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:json_annotation/json_annotation.dart';

part 'domain.g.dart';

@JsonSerializable(nullable: true)
class Post {
  final String id, title, content, image;
  final List<String> categoryIds;

  const Post({
    this.id: "x",
    this.title: "DevCon 2020",
    this.content: "",
    this.image:
        "https://p.bigstockphoto.com/GeFvQkBbSLaMdpKXF1Zv_bigstock-Aerial-View-Of-Blue-Lakes-And--227291596.jpg",
    this.categoryIds: const <String>[],
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@JsonSerializable()
class Category {
  final String id, name, description;
  List<Post> posts;

  Category({
    this.id,
    this.name: "Smart Connection",
    this.description:
        "Lorem ipsum dolor sit amet, lorem utinam cu his. Has alterum ceteros similique eu, docendi necessitatibus eam ei. Agam numquam bonorum ut sed.",
    this.posts: const <Post>[],
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

class Categories with ChangeNotifier {
  List<Post> _allPosts;
  Map<String, Category> _allCategories;


  bool get loading => _allPosts == null;

  List<Category> _merge(List<Category> categories, List<Post> posts) {
    categories.forEach((element) => element.posts = []);
    this._allCategories = Map.fromIterable(categories, key: (c) => c.id);

    this._allPosts = posts;

    //Link posts to categories
    this._allPosts.forEach((post) => post.categoryIds.forEach((categoryId) {
          if (this._allCategories.containsKey(categoryId)) {
            this._allCategories[categoryId].posts.add(post);
          }
        }));

    this.notifyListeners();
    return this.categories;
  }

  Future<List<Category>> loadFromFiles() async {
    var categories = (await parseJsonFromAssets("assets/categories.json"))
        .map((category) => Category.fromJson(category));
    var posts = (await parseJsonFromAssets("assets/posts.json"))
        .map((post) => Post.fromJson(post));
    return _merge(categories.toList(), posts.toList());
  }

  Future<Iterable<dynamic>> parseJsonFromAssets(String assetsPath) async {
    print('--- Parse json from: $assetsPath');
    return rootBundle
        .loadString(assetsPath)
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  List<Category> get categories => (_allCategories ?? Map()).values.toList();

  List<Post> get posts => _allPosts;

  Category getCategory(String categoryId) => _allCategories[categoryId];
}
