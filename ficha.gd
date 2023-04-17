extends Node2D

var ficha = {
	id = "P",
	pos = "A1",
	team = "White",
	state = "Live"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func move_piece(cas):
	print("eje")
	print("cas: ", cas)
	print("cas num: ", cas[0].to_ascii_buffer()[0])
	ficha.pos=cas
	global_position = Vector2(get_parent().square_size.x*(cas[0].to_ascii_buffer()[0]-65), get_parent().square_size.y*(int(cas[1])-1))
