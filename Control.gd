extends Control
#BOTON NEGRO


var posicion = Vector2(48, -720)
var vul = null
var indice= 57
var turn = false



# Called when the node enters the scene tree for the first time.
func _ready():
	var selector_sprite = Sprite2D.new()
	selector_sprite.texture = preload("res://assets/UI_Flat_Select_02a3.png")
	add_child(selector_sprite)
	self.scale = Vector2(-3,3)
	self.position = posicion
	self_modulate = Color(1,1,1,0)
	
	

	
		
func _process(delta):
	pass

func invalidate():
	modulate = Color(1,0,0)
	await get_tree().create_timer(0.6).timeout
	modulate = Color(0,0,0)


		
		
func pos_turn_handler():
	var pos1 = Vector2(48, -720)
	var pos2 = self.posicion
	var pos3= pos2
	
	if self.turn == true:
		self.posicion = pos1
	
	else:
		self.posicion= pos2	

func _input(event):
	
	if self.turn == true:
		pass
		
	else:
		
		if Input.is_action_just_pressed("ui_left") and self.position.x>48:
			self.position.x -= 96
			self.indice-=1
			
			
		if Input.is_action_just_pressed("ui_right") and self.position.x<720:
			self.position.x += 96
			self.indice+=1
			
			
		if Input.is_action_just_pressed("ui_up") and self.position.y> -712:
			self.position.y -= 96
			self.indice+=8
			
			
		if Input.is_action_just_pressed("ui_down") and self.position.y< -48:
			self.position.y += 96
			self.indice-=8
			
		
		if Input.is_action_just_pressed("ui_accept") and self.vul == null:
			self.vul = false
			self.modulate = Color(0,1,0)
		
		elif Input.is_action_just_pressed("ui_accept") and self.vul == true:		
				self.vul = false
				self.modulate = Color(0,1,0)
			
			
		elif Input.is_action_just_pressed("ui_accept") and self.vul == false:
			
			self.vul = true
			self.modulate = Color(0,0,0)
