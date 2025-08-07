// lib/features/npcs/models/npc.dart
import 'package:isar/isar.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

part 'npc.g.dart';

@collection
class Npc {
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
  DndClass? characterClass; // Optional for NPCs

  @Enumerated(EnumType.name)
  late DndCreatureType creatureType;

  @Enumerated(EnumType.name)
  late NpcRole role;

  @Enumerated(EnumType.name)
  late NpcAttitude attitude;

  @Enumerated(EnumType.name)
  DndAlignment? alignment;

  // Extended NPC information
  String? description;

  Npc({
    required this.name,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
    required this.campaignId,
    required this.race,
    this.characterClass,
    required this.creatureType,
    required this.role,
    required this.attitude,
    this.alignment,
    this.description,
  });

  factory Npc.create({
    required String name,
    String? avatarPath,
    required int campaignId,
    required DndRace race,
    DndClass? characterClass,
    DndCreatureType creatureType = DndCreatureType.humanoid,
    NpcRole role = NpcRole.citizen,
    NpcAttitude attitude = NpcAttitude.neutral,
    DndAlignment? alignment,
    String? description,
  }) {
    final now = DateTime.now();
    return Npc(
      name: name,
      avatarPath: avatarPath,
      createdAt: now,
      updatedAt: now,
      campaignId: campaignId,
      race: race,
      characterClass: characterClass,
      creatureType: creatureType,
      role: role,
      attitude: attitude,
      alignment: alignment,
      description: description,
    );
  }

  Npc copyWith({
    String? name,
    String? avatarPath,
    int? campaignId,
    DndRace? race,
    DndClass? characterClass,
    DndCreatureType? creatureType,
    NpcRole? role,
    NpcAttitude? attitude,
    DndAlignment? alignment,
    String? description,
  }) {
    return Npc(
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      campaignId: campaignId ?? this.campaignId,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      creatureType: creatureType ?? this.creatureType,
      role: role ?? this.role,
      attitude: attitude ?? this.attitude,
      alignment: alignment ?? this.alignment,
      description: description ?? this.description,
    )..id = id;
  }

  // Helper getters
  String get raceDisplayName => race.displayName;
  String? get classDisplayName => characterClass?.displayName;
  String get creatureTypeDisplayName => creatureType.displayName;
  String get roleDisplayName => role.displayName;
  String get attitudeDisplayName => attitude.displayName;
  String? get alignmentDisplayName => alignment?.displayName;
}