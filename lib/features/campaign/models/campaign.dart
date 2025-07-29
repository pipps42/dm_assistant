// lib/features/campaign/models/campaign.dart
import 'package:isar/isar.dart';

part 'campaign.g.dart';

@collection
class Campaign {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  late DateTime createdAt;
  DateTime? lastPlayed;

  Campaign({
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Campaign.create({
    required String name,
    String? description,
  }) =>
      Campaign(
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

  Campaign copyWith({
    String? name,
    String? description,
    DateTime? lastPlayed,
  }) =>
      Campaign(
        name: name ?? this.name,
        description: description ?? this.description,
        createdAt: createdAt,
      )..id = id
       ..lastPlayed = lastPlayed ?? this.lastPlayed;
}