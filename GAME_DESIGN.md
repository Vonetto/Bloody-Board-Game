# Bloody Board Game - Piece Design Document

This document outlines the fighting style, mechanics, and stats for each piece in the game.

---

## Universal Mechanics

All pieces have access to a core defensive and resource system:

- **Block:** Reduces incoming damage by ~60–70%.
- **Parry:** Precisely-timed block. Active window ~5–7 frames. On success the attacker is stunned for ~18–22 frames and the defender gains ~+12 frames of advantage. Alternative tuning variant: instead of stun, the next hit within 500 ms deals +20% damage (use one variant per balance pass).

### Stamina System
- Global resource for mobility and specials. Baseline Max 100, regenerates 15/s after 0.8 s without spending.
- Actions consume at the start. If stamina < 10, expensive actions cannot start.
- No regeneration while charging, flying or during Stonewall.
- Exhausted (0): regen 10/s and −15% move speed for 1 s.

---

## The Pieces

### Pawn

> "They are the shield of the kingdom, numerous and steadfast. In the soul of every pawn lies the heart of a queen."

- **Role:** The Standard Soldier (Value: 1)
- **Fighting Style:** A straightforward, all-around fighter with no major strengths or weaknesses. They are the benchmark for balance.
- **Mechanics:**
  - Standard melee attack
  - Single jump
- **Stats:**
  - Health: 100
  - Attack: 15
  - Defense: 10
- **Stamina:**
  - Max 100, Regen 15/s

### Knight

> "The unpredictable wrath of the king, leaping from shadows to strike where least expected."

- **Role:** The Agile Trickster (Value: 3)
- **Fighting Style:** A fast, evasive fighter who excels at mobility and confusing the opponent. Not a direct brawler, but a high-skill duelist.
- **Mechanics:**
  - Mobility: Double jump
  - Unique (Blink Strike): Short-range, fast teleport that passes through an opponent (cannot cross walls/arena bounds). Startup i-frames ~6f, exit lag ~10f.
- **Stats:**
  - Health: 80
  - Attack: 12
  - Defense: 5
- **Stamina & Cooldowns:**
  - Max 110, Regen 18/s; Blink costs 35 stamina; Cooldown 4 s

### Bishop

> "Keepers of the sacred flame, their faith is a weapon that purges the wicked from afar."

- **Role:** The Zoner (Value: 3)
- **Fighting Style:** Controls the battlefield from a distance with projectiles. Powerful when left alone, but vulnerable to being rushed down.
- **Mechanics:**
  - Charged Projectile: Tap = fast/weak; Hold (0.2–1.0 s) = slow/strong. Cannot move while charging. Cancel with dodge (loses 50% of spent stamina).
  - Unique (Diagonal Warp): Instant warp strictly at 45°, fixed distance.
- **Stats:**
  - Health: 75
  - Attack: 8 - 20
  - Defense: 5
- **Stamina & Cooldowns:**
  - Max 120, Regen 14/s; Projectile costs 10–40 stamina (by charge); Warp costs 40 stamina, Cooldown 6 s

### Rook

> "The unbreachable walls of the kingdom given form, a moving fortress of stone and might."

- **Role:** The Juggernaut (Value: 5)
- **Fighting Style:** A slow, inexorable tank. Controls space with powerful, disruptive attacks and is incredibly difficult to take down.
- **Mechanics:**
  - Heavy Attacks: High damage and massive knockback with longer startup windows (vulnerable to whiff punish).
  - Unique (Stonewall): Immovable stance, super armor (−50% knockback), reflects 15% melee damage, cannot move; drains stamina over time; startup ~8f / recovery ~16f.
- **Stats:**
  - Health: 180
  - Attack: 20
  - Defense: 25
- **Stamina & Cooldowns:**
  - Max 90, Regen 12/s; Stonewall drains 20 stamina/second

### Queen

> "The king's right hand, a perfect union of grace and power. She is the ultimate weapon, a master of both the blade and the battlefield."

- **Role:** The Apex Warrior (Value: 9)
- **Fighting Style:** The ultimate all-rounder, combining power, range, and mobility to dominate any situation.
- **Mechanics:**
  - Hybrid Offense: Strong melee combo plus a simple, fast projectile.
  - Flight (Hover): Temporary flight for positioning; cannot attack while flying.
  - Unique Ability (Royal Decree): A devastating, close-range flurry of strikes that deals immense damage.
- **Stats:**
  - Health: 150
  - Attack: 18 (Melee) / 12 (Ranged)
  - Defense: 20
- **Stamina & Cooldowns:**
  - Max 110, Regen 15/s; Flight drains 25 stamina/second; max ~2.5 s per use

### King

> "The heart of the army, upon whose will the battle turns. His presence inspires respect even in the fallen."

- **Role:** The Sovereign (Value: Priceless)
- **Fighting Style:** A stoic and powerful king. Not a brute, but a skilled duelist whose victories have massive strategic impact.
- **Mechanics:**
  - Passive (King's Sword): Standard attacks are unblockable, but each attack consumes stamina. If stamina is insufficient, the king cant attack.
  - Passive (King's Shield): Successful parries restore stamina and a small amount of health.
  - Unique Ability (Bow Before the King): If the King personally defeats an enemy, they are converted into a Pawn on his team. When attacking: the Pawn appears in the King’s original square and the King occupies the defender’s square. When defending: the attacker’s square becomes a Pawn ally and the King remains in place.
- **Stats:**
  - Health: 100
  - Attack: 15
  - Defense: 15
- **Stamina & Cooldowns:**
  - Max 60, Regen 12/s; King’s Sword costs ~18 stamina per attack; King’s Shield parry restores ~25 stamina and ~10 HP
