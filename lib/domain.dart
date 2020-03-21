import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
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

  static Future<Post> getById(String p) async {
    var post =
        jsonDecode((await http.get("https://ryansusana.com/posts/$p")).body);

    post["image"] = "https://ryansusana.com${post["image"]}";
    return Post.fromJson(post);
  }
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

class Domain with ChangeNotifier {
  static List<Post> _allPosts;
  static Map<String, Category> _allCategories;

  static bool get needToLoad => _allPosts == null;

  static List<Category> _merge(List<Category> categories, List<Post> posts) {
    categories.forEach((element) => element.posts = []);
    _allCategories = Map.fromIterable(categories, key: (c) => c.id);

    _allPosts = posts;

    //Link posts to categories
    _allPosts.forEach((post) => post.categoryIds.forEach((categoryId) {
          if (_allCategories.containsKey(categoryId)) {
            _allCategories[categoryId].posts.add(post);
          }
        }));

    return categories;
  }

  static Post getCachedPost(postId) {
    if (_allPosts == null) {
      return null;
    }
    return _allPosts.where((element) => element.id == postId).first;
  }

  static Future<Iterable<dynamic>> getFromOnline(String p) async {
    return jsonDecode(
        (await http.get("https://ryansusana.com/$p")).body)["values"];
  }

  static Future<List<Category>> load() async {
    List<Category> categories = (await getFromOnline("categories"))
        .map((e) => Category.fromJson(e))
        .toList();
    Iterable<Post> posts = (await getFromOnline("posts")).map((e) {
      e["image"] = "https://ryansusana.com${e["image"]}";
      return e;
    }).map((e) => Post.fromJson(e));

    categories.shuffle();
    return _merge(categories, posts.toList());
  }

  static Future<Iterable<dynamic>> parseJsonFromAssets(
      String assetsPath) async {
    print('--- Parse json from: $assetsPath');
    return rootBundle
        .loadString(assetsPath)
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  static List<Category> get categories =>
      (_allCategories ?? Map()).values.toList();

  static List<Post> get posts => _allPosts;

  Category getCategory(String categoryId) => _allCategories[categoryId];
}
