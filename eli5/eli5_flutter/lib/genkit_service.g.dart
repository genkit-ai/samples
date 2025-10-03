// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genkit_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Page _$PageFromJson(Map<String, dynamic> json) => Page(
  text: json['text'] as String,
  illustration: json['illustration'] as String,
);

Map<String, dynamic> _$PageToJson(Page instance) => <String, dynamic>{
  'text': instance.text,
  'illustration': instance.illustration,
};

Storybook _$StorybookFromJson(Map<String, dynamic> json) => Storybook(
  bookTitle: json['bookTitle'] as String?,
  pages: (json['pages'] as List<dynamic>?)
      ?.map((e) => Page.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StorybookToJson(Storybook instance) => <String, dynamic>{
  'bookTitle': instance.bookTitle,
  'pages': instance.pages,
};
