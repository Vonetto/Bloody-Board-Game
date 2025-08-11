extends Node

# Pure functions for damage/knockback calculation.

static func calc_damage(attacker: Dictionary, defender: Dictionary) -> int:
	# Simple MVP damage formula: dmg = attack * (1 - defense_factor)
	# defense_factor = clamp(def/100, 0, 0.7)
	var atk: float = float(attacker.get("attack", 15))
	var defv: float = float(defender.get("defense", 10))
	var defense_factor: float = clamp(defv / 100.0, 0.0, 0.7)
	var dmg: int = int(round(atk * (1.0 - defense_factor)))
	return max(1, dmg)
