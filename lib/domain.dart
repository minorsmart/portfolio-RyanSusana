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
  final int week;
  final List<String> categoryIds;

  const Post({
    this.id: "x",
    this.week: 0,
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

  static Future<Iterable<Post>> qry(
      [Map<String, String> options = const {}]) async {
    Uri uri = Uri.https(null, "ryansusana.com/posts", options);

    var response = await http.get(uri);

    Iterable rawPosts = jsonDecode(response.body)["values"];
    return rawPosts.map((e) {
      e["image"] = e["image"] == null
          ? 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARMAAAC3CAMAAAAGjUrGAAAAMFBMVEXx8/XCy9K/yNDw8vTO1dvi5urEzdTJ0dfe4+fp7O/R2N3b4OTT2d/r7vHh5enGz9WbD+cxAAAE9klEQVR4nO2c26KjIAxFLd61Hv//b6dqbxpUAlHidK95HmvXCUmI2OQGliSxb0AhcEKBEwqcUOCEAicUOKHACQVOKHBCgRMKnFDghAInFDihwAkFTihwQoETCpxQ4IQCJxQ4ocAJBU4ocEKBEwqcUOCEAicUOKHACQVOKHBCgRMKnFDghAInFDihwAkFTihwQoETCpxQ4IQCJ5TLOTG3osya++NfVvY3Yw74iEs5MaZs8y75kNZtU4h7uY4Tc8vyNLHQtdlNVMtVnJiitQp5xktVClq5hhNT5utCXtFSSGm5ghNT7BqZgqWXsXIFJ62LkZE/kSWk3onJNvKIxYrACtLuxFQcIwNt8GfqdmLKbl/CkvQeGCqqnZg738hAHZZWNDvhr5s3QQtIsxOnCrxCFxAqep0UHqlkFireUtQ6KVgl2EbtW5a1OimDlTxo/KQodSKiJEkqLyk6nQgpGdaPx6erdNJLKXk0cB71R6OT8PT6Db+r1egksAgvYRdlhU5qWSVJkjNvQNTJOC0OHBmbkO51BWamFXRiyrZOk7T7y0Iu4j5AYtD1nHsQc2LKT8ynns2S/054j5QjRcrJ4stwl/CL8hglDxg1WcgJCfnaK1Jkq/CczPmOZJxYQj73kGLES46XFBknheUWGvZVAmZIolJEnFi/TMoNlKPy6wfH1C/ixJ4GuCW5P1qJa6SIOGmsN/DHDBThlt5fioSTlT6rYzk5OpkwpIg4sbfjKesi9liTx6FP0eLkhGTykrJ7L0qcHNuZzNndEB6YTxit7DE7vxXSPSkidSezfjZjQHzcNsdGt3M3Mn1saH9yRhn+ot6+G5k+1hb67qX4pDL8xfZmTGhfbAkU9zCxL71D2VzXQk7o12JkkwMHBKtsTfOl5ifL/Zv7qMD8RVCyuR8Um7PNI4Xx/OCsBnbJeu8mN6MuPpmSc07oyNHaJuttiuTcvrjnddflLedx5BGPLhxZrciyz7zMCOd/xFo5A2s5L/ZzwFgrZ2Ql68V1EnHljNinKXGdxFw5I9biE9dJ1JUzYN0OxnQSqVubYcuzdiev4sGtIjwi7HMoljxLnRjT36u6G8M6rfM2k3/h7kn0lTNC96pLJ6ZvyTCjq4RfuJs+ScHKGSFHDuZOVt8xSyv3R9COqFg5A2RGOneyNRbt7mIv3I3oWDkDy7HGt5NiZ3ieyr2GGGG2tsFibvBxYlwGxZWUFTUrZ2SeUt5OjGNP2cqkWz0rZ2A+O345cVUi8GrZTVHNeTFLKU8nrLMfdXANir7PIXyfIJqcuEfJRBWmJNpsbYOvqdvkhJ3x0pBQiT0hsPLVpYxOfB7q+572POOMlhefjc/gxO/NO+9QsR0I1MB745MEnHPwewvxzGMVLN5nQ5KQjtLnLapTj1XweM1SEm7JmcNfP7oa2DnPHj8JPDTFXT8ay/CHKe6T0NXNWz9qk8nEVJDDr8N5C1HVbtjGGPYSF3LeAIXlrlPohZw4J5Vzj615UUs5cWxqdefXJ4+/r9CVOpdMe/JJPk9KKScOmVZ5yXnTiTnZbd9UboatSDbam+XnOkpk2Sg/v6pk67DjRXLJEawcEQv9aaRrY3sJnvnrhP8flumb9j3OCcwzrWl+PEgmuub5ex/GFPefziQz6rbJsnv7w9UGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABc+QcQsWvCL5ypTQAAAABJRU5ErkJggg=='
          : "https://ryansusana.com${e["image"]}";
      return e;
    }).map((e) => Post.fromJson(e));
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

  static Future<Iterable<Category>> qry(
      [Map<String, String> options = const {}]) async {
    Uri uri = Uri.https(null, "ryansusana.com/categories", options);

    print(uri);
    var response = await http.get(uri);

    Iterable rawCategories = jsonDecode(response.body)["values"];

    return rawCategories.map((e) => Category.fromJson(e));
  }
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

  static Future<List<Category>> load() async {
    List<Category> categories = (await Category.qry()).toList();

    List<Post> posts = (await Post.qry()).toList();

    categories.shuffle();
    posts.shuffle();
    return _merge(categories, posts);
  }

  static List<Category> get categories =>
      (_allCategories ?? Map()).values.toList();

  static List<Post> get posts => _allPosts;

  Category getCategory(String categoryId) => _allCategories[categoryId];
}
