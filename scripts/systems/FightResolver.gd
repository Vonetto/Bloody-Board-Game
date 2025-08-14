class_name FightResolver
extends Node

const BaseFighter = preload("res://scripts/fighters/BaseFighter.gd")

signal hit_resolved(attacker_node: Node, defender_node: Node)

# El "árbitro" del combate. Conecta las señales de los luchadores
# y resuelve los resultados de las acciones.

func connect_fighters(fighter1: Node, fighter2: Node) -> void:
	# Conectamos la señal de "hit_landed" de cada luchador a este resolver.
	# El .bind(fighter) añade el propio luchador como un argumento extra cuando la señal se emite.
	if not fighter1.hit_landed.is_connected(on_hit_landed):
		fighter1.hit_landed.connect(on_hit_landed.bind(fighter1))
	if not fighter2.hit_landed.is_connected(on_hit_landed):
		fighter2.hit_landed.connect(on_hit_landed.bind(fighter2))

func on_hit_landed(hurtbox_area: Area2D, attacker: Node) -> void:
	# 1. Identificar al defensor
	# La estructura es: BaseFighter -> pivot -> HurtboxArea -> CollisionShape2D
	# El hurtbox_area que recibimos es el Area2D del defensor.
	if not is_instance_valid(hurtbox_area) or not hurtbox_area.get_parent() or not hurtbox_area.get_parent().get_parent():
		print("[DEBUG] Resolver failed: hurtbox_area or its parents are not valid.")
		return
	
	var defender: Node = hurtbox_area.get_parent().get_parent()

	# Asegurarnos de que son BaseFighters válidos y no nos estamos pegando a nosotros mismos
	if not defender is BaseFighter:
		return
	if not attacker is BaseFighter:
		return
	if defender == attacker:
		return

	# 2. Emitir señal de que el golpe fue válido
	emit_signal("hit_resolved", attacker, defender)


# --- Funciones Estáticas de Cálculo ---
# (No necesitan una instancia para ser llamadas)

static func calc_damage(attacker: Dictionary, defender: Dictionary) -> int:
	# Simple MVP damage formula: dmg = attack * (1 - defense_factor)
	# defense_factor = clamp(def/100, 0, 0.7)
	var atk: float = float(attacker.get("attack", 15))
	var defv: float = float(defender.get("defense", 10))
	var defense_factor: float = clamp(defv / 100.0, 0.0, 0.7)
	var dmg: int = int(round(atk * (1.0 - defense_factor)))
	return max(1, dmg)


static func calc_knockback(attacker: Dictionary, defender: Dictionary, base_impulse: float) -> Vector2:
	# TODO: Implement knockback based on weight, damage, etc.
	var dir: float = signf(attacker.get("pos_x", 0) - defender.get("pos_x", 0))
	return Vector2(dir * base_impulse, -base_impulse * 0.5)
