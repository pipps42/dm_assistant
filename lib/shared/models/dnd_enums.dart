// lib/shared/models/dnd_enums.dart

/// Character and NPC races in D&D 5e
enum DndRace {
  human('Human'),
  elf('Elf'),
  dwarf('Dwarf'),
  halfling('Halfling'),
  dragonborn('Dragonborn'),
  gnome('Gnome'),
  halfElf('Half-Elf'),
  halfOrc('Half-Orc'),
  tiefling('Tiefling');

  const DndRace(this.displayName);
  final String displayName;
}

/// Character and NPC classes in D&D 5e
enum DndClass {
  barbarian('Barbarian'),
  bard('Bard'),
  cleric('Cleric'),
  druid('Druid'),
  fighter('Fighter'),
  monk('Monk'),
  paladin('Paladin'),
  ranger('Ranger'),
  rogue('Rogue'),
  sorcerer('Sorcerer'),
  warlock('Warlock'),
  wizard('Wizard');

  const DndClass(this.displayName);
  final String displayName;
}

/// Character and NPC alignments in D&D 5e
enum DndAlignment {
  lawfulGood('Lawful Good'),
  neutralGood('Neutral Good'),
  chaoticGood('Chaotic Good'),
  lawfulNeutral('Lawful Neutral'),
  trueNeutral('True Neutral'),
  chaoticNeutral('Chaotic Neutral'),
  lawfulEvil('Lawful Evil'),
  neutralEvil('Neutral Evil'),
  chaoticEvil('Chaotic Evil');

  const DndAlignment(this.displayName);
  final String displayName;
}

/// Character and NPC backgrounds in D&D 5e
enum DndBackground {
  acolyte('Acolyte'),
  criminal('Criminal'),
  folkHero('Folk Hero'),
  noble('Noble'),
  sage('Sage'),
  soldier('Soldier'),
  charlatan('Charlatan'),
  entertainer('Entertainer'),
  guildArtisan('Guild Artisan'),
  hermit('Hermit'),
  outlander('Outlander'),
  sailor('Sailor');

  const DndBackground(this.displayName);
  final String displayName;
}

/// Creature types in D&D 5e (for NPCs and monsters)
enum DndCreatureType {
  aberration('Aberration'),
  beast('Beast'),
  celestial('Celestial'),
  construct('Construct'),
  dragon('Dragon'),
  elemental('Elemental'),
  fey('Fey'),
  fiend('Fiend'),
  giant('Giant'),
  humanoid('Humanoid'),
  monstrosity('Monstrosity'),
  ooze('Ooze'),
  plant('Plant'),
  undead('Undead');

  const DndCreatureType(this.displayName);
  final String displayName;
}

/// NPC roles in the world
enum NpcRole {
  citizen('Citizen'),
  hermit('Hermit'),
  ruler('Ruler'),
  tyrant('Tyrant'),
  guard('Guard'),
  adventurer('Adventurer'),
  merchant('Merchant'),
  scholar('Scholar'),
  priest('Priest'),
  criminal('Criminal'),
  noble('Noble'),
  servant('Servant'),
  soldier('Soldier'),
  artisan('Artisan'),
  farmer('Farmer'),
  innkeeper('Innkeeper');

  const NpcRole(this.displayName);
  final String displayName;
}

/// NPC attitude towards the party
enum NpcAttitude {
  friendly('Friendly'),
  suspicious('Suspicious'),
  indifferent('Indifferent'),
  hostile('Hostile'),
  helpful('Helpful'),
  neutral('Neutral'),
  fearful('Fearful'),
  respectful('Respectful');

  const NpcAttitude(this.displayName);
  final String displayName;
}