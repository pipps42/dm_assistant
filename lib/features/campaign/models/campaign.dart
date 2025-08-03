// lib/features/campaign/models/campaign.dart
import 'package:isar/isar.dart';

part 'campaign.g.dart';

@collection
class Campaign {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  String? coverImagePath;
  late DateTime createdAt;
  DateTime? lastPlayed;

  Campaign({
    required this.name,
    this.description,
    this.coverImagePath,
    required this.createdAt,
  });

  factory Campaign.create({
    required String name,
    String? description,
    String? coverImagePath,
  }) =>
      Campaign(
        name: name,
        description: description,
        coverImagePath: coverImagePath,
        createdAt: DateTime.now(),
      );

  Campaign copyWith({
    String? name,
    String? description,
    String? coverImagePath,
    DateTime? lastPlayed,
  }) =>
      Campaign(
        name: name ?? this.name,
        description: description ?? this.description,
        coverImagePath: coverImagePath ?? this.coverImagePath,
        createdAt: createdAt,
      )..id = id
       ..lastPlayed = lastPlayed ?? this.lastPlayed;
}