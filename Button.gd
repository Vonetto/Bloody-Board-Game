extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	var button = Button.new()
	add_child(button) 
	
	button.connect("pressed", self, "_input" )



func _input(event):
	if event.type== InputEvent.MOUSE_BUTTON:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			button.DRAW_NORMAL=0
			
			
			
			
			
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
