// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Download _$DownloadFromJson(Map<String, dynamic> json) {
  return Download(
    name: json['name'] as String,
    file: json['file'] as String,
  );
}

Map<String, dynamic> _$DownloadToJson(Download instance) => <String, dynamic>{
      'name': instance.name,
      'file': instance.file,
    };

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post(
    id: json['id'] as String,
    week: json['week'] as int,
    title: json['title'] as String,
    content: json['content'] as String,
    image: json['image'] as String,
    categoryIds:
        (json['categoryIds'] as List)?.map((e) => e as String)?.toList(),
    downloads: (json['downloads'] as List)
        ?.map((e) =>
            e == null ? null : Download.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'image': instance.image,
      'week': instance.week,
      'categoryIds': instance.categoryIds,
      'downloads': instance.downloads,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    id: json['id'] as String,
    name: json['name'] as String,
    main: json['main'] as bool,
    description: json['description'] as String,
    posts: (json['posts'] as List)
        ?.map(
            (e) => e == null ? null : Post.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'main': instance.main,
      'posts': instance.posts,
    };
