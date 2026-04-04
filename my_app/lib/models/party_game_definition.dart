import 'package:flutter/material.dart';

enum PartyGameCategory {
  priority,
  trump,
  quiz,
  social,
  casual,
}

enum PartyGameAvailability {
  playable,
  prototype,
  planning,
}

class PartyGameDefinition {
  const PartyGameDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.availability,
    this.routeName,
    this.tags = const <String>[],
  });

  final String id;
  final String title;
  final String description;
  final PartyGameCategory category;
  final IconData icon;
  final Color color;
  final PartyGameAvailability availability;
  final String? routeName;
  final List<String> tags;

  bool get isPlayable => availability == PartyGameAvailability.playable;
}
