import 'dart:convert';

import 'settings_repo.dart';

/// The last few search queries, newest first, kept in settings.
class RecentSearches {
  RecentSearches(this.settings);

  static const key = 'recent_searches';
  static const max = 8;

  final SettingsRepo settings;

  List<String> get items {
    final raw = settings.get(key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<Object?>).whereType<String>().toList();
    } on FormatException {
      return const [];
    }
  }

  /// Moves [query] to the front; blank queries are ignored.
  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final next = [q, ...items.where((x) => x.toLowerCase() != q.toLowerCase())].take(max).toList();
    settings.set(key, jsonEncode(next));
  }

  void remove(String query) => settings.set(key, jsonEncode(items.where((x) => x != query).toList()));

  void clear() => settings.set(key, '[]');
}
