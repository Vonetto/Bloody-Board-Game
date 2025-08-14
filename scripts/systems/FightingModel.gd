extends Node

const PieceStats = preload("res://scripts/game_logic/PieceStats.gd")
const Types = preload("res://scripts/game_logic/Types.gd")
const FightResolver = preload("res://scripts/systems/FightResolver.gd")

var p1: Dictionary
var p2: Dictionary
var attacker_piece_ref: Node = null
var defender_piece_ref: Node = null

func setup(attacker_team: int, attacker_type: int, defender_team: int, defender_type: int, attacker_piece: Node, defender_piece: Node) -> void:
	var stats := PieceStats.new()
	p1 = stats.get_stats(attacker_team, attacker_type)
	p2 = stats.get_stats(defender_team, defender_type)
	attacker_piece_ref = attacker_piece
	defender_piece_ref = defender_piece
	# If pieces have persistent hp, override
	if attacker_piece_ref and attacker_piece_ref.ficha:
		if attacker_piece_ref.ficha.hp_max > 0:
			p1.hp = clamp(attacker_piece_ref.ficha.hp_current, 0, attacker_piece_ref.ficha.hp_max)
	if defender_piece_ref and defender_piece_ref.ficha:
		if defender_piece_ref.ficha.hp_max > 0:
			p2.hp = clamp(defender_piece_ref.ficha.hp_current, 0, defender_piece_ref.ficha.hp_max)

func apply_attack(from_player: int) -> int:
	# Returns remaining HP of the target after applying damage
	if from_player == 1:
		var dmg := FightResolver.calc_damage(p1, p2)
		p2.hp = max(0, int(p2.hp) - dmg)
		return int(p2.hp)
	else:
		var dmg := FightResolver.calc_damage(p2, p1)
		p1.hp = max(0, int(p1.hp) - dmg)
		return int(p1.hp)

func get_hp(player: int) -> int:
	return int(p1.hp) if player == 1 else int(p2.hp)

func persist_back_to_pieces() -> void:
	if attacker_piece_ref and attacker_piece_ref.ficha:
		attacker_piece_ref.ficha.hp_current = int(p1.hp)
		attacker_piece_ref.ficha.hp_max = max(attacker_piece_ref.ficha.hp_max, int(p1.hp))
	if defender_piece_ref and defender_piece_ref.ficha:
		defender_piece_ref.ficha.hp_current = int(p2.hp)
		defender_piece_ref.ficha.hp_max = max(defender_piece_ref.ficha.hp_max, int(p2.hp))
