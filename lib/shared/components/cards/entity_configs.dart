// lib/shared/components/cards/entity_configs.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/npcs/models/npc.dart';
import 'package:dm_assistant/shared/components/cards/entity_display_config.dart';

/// Pre-configured EntityDisplayConfig instances for all D&D entities
class EntityConfigs {
  /// Configuration for Campaign entities
  static EntityDisplayConfig<Campaign> campaign = EntityDisplayConfig.dndEntity(
    titleExtractor: (campaign) => campaign.name,
    subtitleExtractor: (campaign) => campaign.description,
    imagePathExtractor: (campaign) => campaign.coverImagePath,
    badgesBuilder: (campaign, context) => [],
    metadataExtractor: (campaign) => {
      'created': EntityDetailWidgetBuilder.formatDate(campaign.createdAt),
    },
    fallbackIcon: Icons.campaign,
  );

  /// Configuration for Character entities
  static EntityDisplayConfig<Character>
  character = EntityDisplayConfig.dndEntity(
    titleExtractor: (character) => character.name,
    subtitleExtractor: (character) =>
        'Level ${character.level} ${EntityDetailWidgetBuilder.formatEnumName(character.race.name)} ${EntityDetailWidgetBuilder.formatEnumName(character.characterClass.name)}',
    imagePathExtractor: (character) => character.avatarPath,
    badgesBuilder: (character, context) => [
      if (character.background != null)
        EntityDetailWidgetBuilder.chip(
          icon: Icons.history_edu,
          label: EntityDetailWidgetBuilder.formatEnumName(
            character.background!.name,
          ),
          color: Colors.blue,
        ),
      if (character.alignment != null)
        EntityDetailWidgetBuilder.chip(
          icon: Icons.balance,
          label: EntityDetailWidgetBuilder.formatEnumName(
            character.alignment!.name,
          ),
          color: Colors.green,
        ),
    ],
    detailsBuilder: (character, context) => [
      EntityDetailWidgetBuilder.detailRow(
        icon: Icons.history_edu,
        text: 'Background: ${character.background?.displayName ?? 'None'}',
      ),
      if (character.alignment != null)
        EntityDetailWidgetBuilder.detailRow(
          icon: Icons.balance,
          text: 'Alignment: ${character.alignment!.displayName}',
        ),
    ],
    metadataExtractor: (character) => {
      'created': EntityDetailWidgetBuilder.formatDate(character.createdAt),
      'level': character.level.toString(),
    },
    fallbackIcon: Icons.person,
  );

  /// Configuration for NPC entities
  static EntityDisplayConfig<Npc> npc = EntityDisplayConfig.dndEntity(
    titleExtractor: (npc) => npc.name,
    subtitleExtractor: (npc) {
      final parts = <String>[];
      parts.add(EntityDetailWidgetBuilder.formatEnumName(npc.race.name));
      parts.add(
        EntityDetailWidgetBuilder.formatEnumName(npc.creatureType.name),
      );
      if (npc.characterClass != null) {
        parts.add(
          EntityDetailWidgetBuilder.formatEnumName(npc.characterClass!.name),
        );
      }
      return parts.join(' • ');
    },
    imagePathExtractor: (npc) => npc.avatarPath,
    badgesBuilder: (npc, context) => [
      EntityDetailWidgetBuilder.chip(
        icon: Icons.work,
        label: EntityDetailWidgetBuilder.formatEnumName(npc.role.name),
        color: Colors.blue,
      ),
      EntityDetailWidgetBuilder.chip(
        icon: Icons.mood,
        label: EntityDetailWidgetBuilder.formatEnumName(npc.attitude.name),
        color: EntityDetailWidgetBuilder.getAttitudeColor(npc.attitude.name),
      ),
      if (npc.characterClass != null)
        EntityDetailWidgetBuilder.chip(
          icon: Icons.shield,
          label: EntityDetailWidgetBuilder.formatEnumName(
            npc.characterClass!.name,
          ),
          color: Colors.purple,
        ),
      if (npc.alignment != null)
        EntityDetailWidgetBuilder.chip(
          icon: Icons.balance,
          label: EntityDetailWidgetBuilder.formatEnumName(npc.alignment!.name),
          color: Colors.green,
        ),
    ],
    detailsBuilder: (npc, context) => [
      EntityDetailWidgetBuilder.detailRow(
        icon: Icons.work,
        text:
            'Role: ${EntityDetailWidgetBuilder.formatEnumName(npc.role.name)}',
      ),
      EntityDetailWidgetBuilder.detailRow(
        icon: Icons.mood,
        text:
            'Attitude: ${EntityDetailWidgetBuilder.formatEnumName(npc.attitude.name)}',
        color: EntityDetailWidgetBuilder.getAttitudeColor(npc.attitude.name),
      ),
      if (npc.characterClass != null)
        EntityDetailWidgetBuilder.detailRow(
          icon: Icons.shield,
          text:
              'Class: ${EntityDetailWidgetBuilder.formatEnumName(npc.characterClass!.name)}',
        ),
      if (npc.alignment != null)
        EntityDetailWidgetBuilder.detailRow(
          icon: Icons.balance,
          text:
              'Alignment: ${EntityDetailWidgetBuilder.formatEnumName(npc.alignment!.name)}',
        ),
    ],
    metadataExtractor: (npc) => {
      'created': EntityDetailWidgetBuilder.formatDate(npc.createdAt),
      'role': EntityDetailWidgetBuilder.formatEnumName(npc.role.name),
    },
    fallbackIcon: Icons.person,
  );
}
