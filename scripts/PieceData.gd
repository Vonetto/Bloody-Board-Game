extends Resource

class_name PieceData

const Types = preload("res://scripts/Types.gd")

@export var id: int = Types.PieceType.P
@export var pos: String = "A1"
@export var team: int = Types.Team.White
@export var state: String = "Live"
@export var index: int = 1
@export var road_map: Array = []

# Fighting persistence
@export var hp_max: int = 100
@export var hp_current: int = 100
