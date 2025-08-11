extends Resource

const Types = preload("res://scripts/Types.gd")

# Base stats per piece type. Can be tweaked for balance.
@export var base_hp_by_type: Dictionary = {
	Types.PieceType.P: 100,
	Types.PieceType.N: 120,
	Types.PieceType.B: 110,
	Types.PieceType.R: 150,
	Types.PieceType.Q: 160,
	Types.PieceType.K: 200
}

@export var base_attack_by_type: Dictionary = {
	Types.PieceType.P: 18,
	Types.PieceType.N: 24,
	Types.PieceType.B: 22,
	Types.PieceType.R: 16,
	Types.PieceType.Q: 28,
	Types.PieceType.K: 20
}

@export var base_defense_by_type: Dictionary = {
	Types.PieceType.P: 10,
	Types.PieceType.N: 14,
	Types.PieceType.B: 12,
	Types.PieceType.R: 24,
	Types.PieceType.Q: 18,
	Types.PieceType.K: 20
}

@export var base_speed_by_type: Dictionary = {
	Types.PieceType.P: 1.0,
	Types.PieceType.N: 1.4,
	Types.PieceType.B: 1.3,
	Types.PieceType.R: 0.9,
	Types.PieceType.Q: 1.2,
	Types.PieceType.K: 1.0
}

func get_stats(team: int, piece_type: int) -> Dictionary:
	# Team is kept for future asymmetry. For now stats are type-based only.
	var hp: int = int(base_hp_by_type.get(piece_type, 100))
	return {
		"team": team,
		"type": piece_type,
		"hp": hp,
		"attack": int(base_attack_by_type.get(piece_type, 15)),
		"defense": int(base_defense_by_type.get(piece_type, 10)),
		"speed": float(base_speed_by_type.get(piece_type, 1.0))
	}
