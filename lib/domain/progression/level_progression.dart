class LevelProgression {
  int level;
  int xp;

  LevelProgression({
    this.level = 1,
    this.xp = 0,
  });

  int xpToNext() => level * 100;

  bool gainXp(int value) {
    xp += value;
    var leveledUp = false;

    while (xp >= xpToNext() && level < 20) {
      xp -= xpToNext();
      level++;
      leveledUp = true;
    }

    if (level >= 20) {
      xp = xp.clamp(0, xpToNext() - 1).toInt();
    }

    return leveledUp;
  }
}
