import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eli5_flutter/genkit_service.dart';

class StorySummary {
  final String question;
  final String bookTitle;
  final int pageCount;
  final DateTime createdAt;
  final String storybookJson;

  StorySummary({
    required this.question,
    required this.bookTitle,
    required this.pageCount,
    required this.createdAt,
    required this.storybookJson,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'bookTitle': bookTitle,
        'pageCount': pageCount,
        'createdAt': createdAt.toIso8601String(),
        'storybookJson': storybookJson,
      };

  factory StorySummary.fromJson(Map<String, dynamic> json) => StorySummary(
        question: json['question'] as String,
        bookTitle: json['bookTitle'] as String,
        pageCount: json['pageCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        storybookJson: json['storybookJson'] as String,
      );

  Storybook get storybook =>
      Storybook.fromJson(jsonDecode(storybookJson) as Map<String, dynamic>);
}

class HistoryService {
  static const _key = 'story_history';

  Future<List<StorySummary>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => StorySummary.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveStory(String question, Storybook storybook) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final summary = StorySummary(
      question: question,
      bookTitle: storybook.bookTitle ?? question,
      pageCount: storybook.pages?.length ?? 0,
      createdAt: DateTime.now(),
      storybookJson: jsonEncode(storybook.toJson()),
    );
    raw.add(jsonEncode(summary.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> deleteStory(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    // History is sorted newest-first in getHistory, but stored in insertion order.
    // Reverse index to match display order.
    final storageIndex = raw.length - 1 - index;
    if (storageIndex >= 0 && storageIndex < raw.length) {
      raw.removeAt(storageIndex);
      await prefs.setStringList(_key, raw);
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
