// lib/features/character/models/character.dart
import 'package:isar/isar.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

part 'character.g.dart';

@collection
class Character {
  Id id = Isar.autoIncrement;

  // Basic properties
  late String name;
  String? avatarPath;
  late DateTime createdAt;
  late DateTime updatedAt;

  // Campaign relationship - REQUIRED
  late int campaignId;

  // D&D specific properties
  @Enumerated(EnumType.name)
  late DndRace race;

  @Enumerated(EnumType.name)
  late DndClass characterClass;

  late int level; // 1-20

  @Enumerated(EnumType.name)
  DndBackground? background;

  @Enumerated(EnumType.name)
  DndAlignment? alignment;

  Character({
    required this.name,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
    required this.campaignId,
    required this.race,
    required this.characterClass,
    required this.level,
    this.background,
    this.alignment,
  });

  factory Character.create({
    required String name,
    String? description,
    String? avatarPath,
    required int campaignId,
    required DndRace race,
    required DndClass characterClass,
    int level = 1,
    DndBackground? background,
    DndAlignment? alignment,
  }) {
    final now = DateTime.now();
    return Character(
      name: name,
      avatarPath: avatarPath,
      createdAt: now,
      updatedAt: now,
      campaignId: campaignId,
      race: race,
      characterClass: characterClass,
      level: level,
      background: background,
      alignment: alignment,
    );
  }

  Character copyWith({
    String? name,
    String? description,
    String? avatarPath,
    int? campaignId,
    DndRace? race,
    DndClass? characterClass,
    int? level,
    DndBackground? background,
    DndAlignment? alignment,
  }) {
    return Character(
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      campaignId: campaignId ?? this.campaignId,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      background: background ?? this.background,
      alignment: alignment ?? this.alignment,
    )..id = id;
  }

  // Helper getters
  String get raceDisplayName => race.displayName;
  String get classDisplayName => characterClass.displayName;
  String? get backgroundDisplayName => background?.displayName;
  String? get alignmentDisplayName => alignment?.displayName;
}
