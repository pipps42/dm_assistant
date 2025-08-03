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