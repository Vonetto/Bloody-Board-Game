extends Node2D

var white_pieces =[]
var black_pieces =[]

var piece
var piece_2

var first_target
var second_target=null

var pieces_index_list = []
var pieces_index_list2 = []
					
var white_obs_pieces_list = []
var black_obs_pieces_list = []

@onready var tablero = $tablero

var index_map= {}
var pos1
var pos2

var turn = true #true: white, false: black
var pawn_conquerable
var camera
var camera_pos1
var dead_piece = null
signal fight_started(piece1, piece2)


@export_node_path("bishop")  var bishop
@export_node_path("peon")  var peon
@export_node_path("rook")  var rook
@export_node_path("knight")  var knight
@export_node_path("queen")  var queen
@export_node_path("king")  var king

@export_node_path("Bpeon")  var Bpeon
@export_node_path("Bbishop")  var Bbishop
@export_node_path("Brook")  var Brook
@export_node_path("Bknight")  var Bknight
@export_node_path("Bqueen")  var Bqueen
@export_node_path("Bking")  var Bking

@onready var selector  = load("res://selector.tscn").instantiate()
@onready var selector2  = load("res://selector_2.tscn").instantiate()

var full_map
signal selector_index

func _ready():
	camera= get_node("Camera2D")
	camera_pos1 = camera.transform.origin
	
	#tablero.pieces_created.connect(_on_pieces_created)
	
	index_map[1]= Vector2(48, -48)
	
	for i in range(2,65):
		while (i<=8):
			index_map[i]= Vector2( ((i*96)-48)%768, - 48)
			i=i+1
		while (i>=9 and i <=16):
			index_map[i]= Vector2( ((i*96)-48)%768, -144)
			i=i+1
		while (i>=17 and i <=24):
			index_map[i]= Vector2( ((i*96)-48)%768, -240)
			i=i+1
			
		while (i>=25 and i <=32):
			index_map[i]= Vector2( ((i*96)-48)%768, -336)
			i=i+1	
			
		while (i>=33 and i <=40):
			index_map[i]= Vector2( ((i*96)-48)%768, -432)
			i=i+1
			
		while (i>=41 and i <=48):
			index_map[i]= Vector2( ((i*96)-48)%768, -528)
			i=i+1
			
		while (i>=49 and i <=56):
			index_map[i]= Vector2( ((i*96)-48)%768, -624)
			i=i+1
	
		while (i>=57 and i <=64):
			index_map[i]= Vector2( ((i*96)-48)%768, -720)
			i=i+1
			
	
	selector_index.emit()
	
	selector.vul=null
	selector2.vul=null
	selector.able =true
	
	
	set_process_input(true)
	var piece
	full_map = gen_full_map()	
	full_map.sort()
	
	
	add_child(selector)
	add_child(selector2)
	
	turn_handler()
	
	
	
	_on_pieces_created()
	
	
	

# Called when the node enters the scene tree for the first time.
	

	
func _on_pieces_created():
	for piece in white_pieces:
		piece.invalid_movement.connect(selector.invalidate)
		
		
	for piece in black_pieces:
		piece.invalid_movement.connect(selector2.invalidate)
	
	

	

func turn_handler():
	
	if selector.able == true and selector2.able==true:
		if turn == true:
			selector.turn = true
			selector2.turn = true
				
		
		elif turn == false:
			selector.turn = false
			selector2.turn = false
		
		if selector2.turn==true:
			selector2.position= index_map[61]
			selector2.indice = 61 
			selector2.modulate = Color(1,1,1,0)
		
		elif selector2.turn==false:
			selector2.position= index_map[61]
			selector2.indice = 61 
			selector2.modulate = Color(0,0,0)
		
		
		if selector.turn==true:
			selector.position= index_map[4]
			selector.indice = 4 
			selector.modulate = Color(1,1,1,1)
		
		
		elif selector.turn==false:
			selector.position= index_map[4]
			selector.indice = 4 
			selector.modulate = Color(1,1,1,0)
		
	
	
	
	
func _input(event):
	if selector.able==true  and selector2.able==true:
	
		if turn == true :
			
			if Input.is_action_just_pressed("ui_accept") and selector.vul== false :
			
				var x=int(selector.position.x)
				var y=int(selector.position.y)
				
				
				pos1= Vector2(x,y)
				
				

				piece=search_in(pos1,selector)

				
				
				
				first_target=piece
			#if (event is InputEventMouseButton):
				#if (event.pressed):
					#var x=int((event.position.x - 243)/$tablero.square_size.x)
					#var y=8-int((event.position.y)/$tablero.square_size.x)
					#var sq=get_square(x, y)
					#var piece=search_in(sq)
					
				if (first_target !=null):
					if (piece != null):
						first_target=piece

						
						#first_target.move_piece(sq)
					else:
						pass
				#else: #assign first target
					#if (piece==null):
							#return
					#if (turn):
							#piece.ficha.team=="White"
							#first_target=piece
					#else:
							#piece.ficha.team=="Black"
							#first_target=piece
				#else:
					#pass
			
			
							
			
		#func get_square(x, y):
				#var charini=65
				#var pos=char(charini+x-1)+str(y)
				#return pos
			
			if Input.is_action_just_pressed("ui_accept") and selector.vul== true :
				
				
				
			
				var x=int(selector.position.x)
				var y=int(selector.position.y)
				
				pos2=Vector2(x,y)
				
				
				piece_2=search_in(pos2,selector)
				
				if pos1 == pos2:
					return
				
			
				if (first_target != null):
					var road_map1 = gen_road_map(first_target,pos1,pos2,index_map,selector, false)
					
					var road_aux = first_target.obstr(pos1,pos2,index_map,selector,true)
					
					var road_map2=[]
					
					if first_target.ficha.id == "P":
						road_map2.append_array(road_aux)
						road_map2.append_array(road_map1)
					
					
					
					var pieces_index_list = []
					var pieces_index_list2 = []
					
					var white_obs_pieces_list = []
					var black_obs_pieces_list = []
					
					
					for i in road_map1:
						if i in full_map:
							pieces_index_list.append(i)
					
					for i in road_map2:
						if i in full_map:
							pieces_index_list2.append(i)
							
			
				
							
							
					for j in pieces_index_list:
						for piece in white_pieces:
							if piece.ficha.index ==j:
								white_obs_pieces_list.append(piece)
						
						
						for piece in black_pieces:
							if piece.ficha.index ==j:
								black_obs_pieces_list.append(piece)	
			
							
					
					if (first_target.ficha.team == "White" and first_target.ficha.id != "P") :#Si a una pieza blanca (no peon porque esos comen distinto):
						if len(white_obs_pieces_list)>0: # La obstruye otra pieza blanca:
							print("Invalid Movement")
							selector.invalidate()
							return
						
						elif (len(black_obs_pieces_list)>0 and len(white_obs_pieces_list)==0): #No la obstruye una pieza blanca pero si la obstruye una negra
							print("ÑOM")
							first_target.move_piece(pos1,pos2, index_map, selector, full_map, false)
							
			
							#piece_2.queue_free()
							#black_pieces.remove_at(black_pieces.find(piece_2))
							#black_obs_pieces_list.remove_at(black_obs_pieces_list.find(piece_2))
							#full_map.remove_at(full_map.find(piece_2.ficha.index))
							
						
							
								
							turn = not(turn)		
							turn_handler()
							
							change_scenes(first_target, piece_2)
							
						
						elif (len(black_obs_pieces_list)==0 and len(white_obs_pieces_list)==0):
							first_target.move_piece(pos1,pos2, index_map, selector, full_map, false)
							if first_target.position == Vector2(pos2.x-48, pos2.y+50):
								turn = not(turn)
								turn_handler()
									
								
					
					elif (first_target.ficha.team == "White" and first_target.ficha.id == "P") :
									
						
						if piece_2 != null:
							if piece_2 in white_pieces:
								selector.invalidate()
								return
						
							elif piece_2 in black_pieces:
								var list = []
								for j in road_aux :
									list.append(index_map[j])
									
								
								if pos2 in list:
									old_indx = first_target.ficha.index		
									first_target.move_piece(pos1,pos2, index_map, selector, full_map, true)
									print("ÑOM")
									#piece_2.queue_free()
									#black_pieces.remove_at(black_pieces.find(piece_2))
									#black_obs_pieces_list.remove_at(black_obs_pieces_list.find(piece_2))
									#full_map.remove_at(full_map.find(piece_2.ficha.index))
									
									turn = not(turn)
									turn_handler()
									
									change_scenes(first_target, piece_2)
									
								else:
									selector.invalidate()
									print("Invalid Movement")
									return
						
						else: #No la obstruye nada
							first_target.move_piece(pos1,pos2, index_map, selector, full_map, false)
							if first_target.position == Vector2(pos2.x-48, pos2.y+50):
								turn = not(turn)
								turn_handler()
						
				
					
					elif (first_target.ficha.team == "Black"):
						print("NOT YOUR PIECE")
						
						selector.invalidate()
						
			
						
			

		elif turn == false:
			if Input.is_action_just_pressed("ui_accept") and selector2.vul== false :
			
				var x=int(selector2.position.x)
				var y=int(selector2.position.y)
				
				
				pos1= Vector2(x,y)
				
				
				
				piece=search_in(pos1,selector2)
				first_target=piece
			#if (event is InputEventMouseButton):
				#if (event.pressed):
					#var x=int((event.position.x - 243)/$tablero.square_size.x)
					#var y=8-int((event.position.y)/$tablero.square_size.x)
					#var sq=get_square(x, y)
					#var piece=search_in(sq)
					
				if (first_target !=null):
					if (piece != null):
						first_target=piece
						pawn_conquerable = first_target.pawn_eat(pos1, index_map, selector2)
						
						#first_target.move_piece(sq)
					else:
						pass
				#else: #assign first target
					#if (piece==null):
							#return
					#if (turn):
							#piece.ficha.team=="White"
							#first_target=piece
					#else:
							#piece.ficha.team=="Black"
							#first_target=piece
				#else:
					#pass
			
			
							
			
		#func get_square(x, y):
				#var charini=65
				#var pos=char(charini+x-1)+str(y)
				#return pos
			
			if Input.is_action_just_pressed("ui_accept") and selector2.vul== true :
			
				
			
				var x=int(selector2.position.x)
				var y=int(selector2.position.y)
				
				pos2=Vector2(x,y)
				
				if pos1 == pos2:
					return
				
				var piece_2=search_in(pos2,selector2)
				
				var road_map1 = gen_road_map(first_target,pos1,pos2,index_map,selector, false)
					
				var road_aux = first_target.obstr(pos1,pos2,index_map,selector,true)
					
				var road_map2=[]
					
				if first_target.ficha.id == "P":
						road_map2.append_array(road_aux)
						road_map2.append_array(road_map1)
				
			
				if (first_target != null):
					
					
					var pieces_index_list = []
					var white_obs_pieces_list = []
					var black_obs_pieces_list = []
					var white_pawn_eat_obs= []
					var black_pawn_eat_obs= []
					
					var white_pawn_eat_obs_pieces= []
					var black_pawn_eat_obs_pieces= []
					
					for i in road_map1:
						if i in full_map:
							pieces_index_list.append(i)
							
						
							
					for j in pieces_index_list:
						for piece in white_pieces:
							if piece.ficha.index ==j:
								white_obs_pieces_list.append(piece)
						
						
						for piece in black_pieces:
							if piece.ficha.index ==j:
								black_obs_pieces_list.append(piece)	
								
								
				
					
					
			
							
					
					if (first_target.ficha.team == "White"):
						print("NOT YOUR PIECE")
						selector2.invalidate()
						turn_handler()
						
				
					
					elif (first_target.ficha.team == "Black" and first_target.ficha.id != "P"):
						if len(black_obs_pieces_list)>0: 
							print("Invalid Movement")
							selector2.invalidate()
							return
						
						elif (len(white_obs_pieces_list)>0 and len(black_obs_pieces_list)==0): 
							print("ÑOM")
							first_target.move_piece(pos1,pos2, index_map, selector2, full_map, false)
							#piece_2.queue_free()
							#white_pieces.remove_at(white_pieces.find(piece_2))
							#white_obs_pieces_list.remove_at(white_obs_pieces_list.find(piece_2))
							#full_map.remove_at(full_map.find(piece_2.ficha.index))
							if (piece_2.ficha.id == "K"):
										end_game()
										
										
							turn = not(turn)		
							turn_handler()
							change_scenes(first_target, piece_2)
							
						elif (len(white_obs_pieces_list)==0 and len(black_obs_pieces_list)==0):
							first_target.move_piece(pos1,pos2, index_map, selector2, full_map, false)
							
							if first_target.position == Vector2(pos2.x-48, pos2.y+50):
								turn = not(turn)		
								turn_handler()
						
					elif (first_target.ficha.team == "Black" and first_target.ficha.id == "P") :
						
						
						if piece_2 != null:
							if piece_2 in black_pieces:
								selector2.invalidate()
								return
						
							elif piece_2 in white_pieces:
								var list = []
								for j in road_aux :
									list.append(index_map[j])
									
								
								if pos2 in list:
									
									first_target.move_piece(pos1,pos2, index_map, selector2, full_map, true)
									print("ÑOM")
									#piece_2.queue_free()
									#white_pieces.remove_at(white_pieces.find(piece_2))
									#white_obs_pieces_list.remove_at(white_obs_pieces_list.find(piece_2))
									#full_map.remove_at(full_map.find(piece_2.ficha.index))
									
									
									turn = not(turn)
									turn_handler()
									change_scenes(first_target, piece_2)
									
									
				
								else:
									selector.invalidate()
									print("Invalid Movement")
									return
						
						else: #No la obstruye nada
							first_target.move_piece(pos1,pos2, index_map, selector2, full_map, false)
							if first_target.position == Vector2(pos2.x-48, pos2.y+50):
								turn = not(turn)
								turn_handler()	
					
					
				
		


			
func gen_road_map(piece, pos1 ,pos2, index_map, selector, valid):
	var road_map=first_target.get_road_map(pos1 ,pos2, index_map, selector, valid)
	return road_map

func gen_full_map():
	var full_pieces_map= []
	for i in white_pieces:
		full_pieces_map.append(i.ficha.index)
	
	for j in black_pieces:
		full_pieces_map.append(j.ficha.index)		
	
	return full_pieces_map
	
func search_in(sq, selector):
	
	for i in white_pieces:
		if (i.ficha.index== selector.indice):
			return i
	for i in black_pieces:
		if (i.ficha.index==selector.indice):
			
			return i
	return null

var next_level_resource = load("res://Floor.tscn")
var next_level = next_level_resource.instantiate()

func end_game():
	get_tree().quit()

var old_indx

func change_scenes(ficha1, ficha2):
	next_level_resource = load("res://Floor.tscn")
	next_level = next_level_resource.instantiate()
	fight_started.connect(next_level._on_fight_started)
	add_child(next_level)
	
	selector.able =false
	selector2.able =false
	
	

	camera_handler()
	
	emit_signal("fight_started", ficha1, ficha2)
	
	
	

	#await get_tree().create_timer(17).timeout
	
	await get_tree().create_timer(17).timeout

	
	selector.able =true
	selector2.able =true
	
	
	camera_handler()
	
	dead_piece = next_level.dead_piece
	
	
	
	
	eat(ficha1, ficha2)
	

	remove_child(next_level)
	
	

func eat(piece1, piece2):
	
	
	if dead_piece != null:
		var pieza_rip
		
		piece1 = first_target
		piece2 = piece_2
		
		
		var duelo= (next_level.duel)
		
		if piece2!=null: #si se mueve una blanca
			for i in duelo:
				if i.ficha.team[0] == dead_piece[0]:
					pieza_rip = i 
					
		
		else :# si se mueve una negra
			piece2 = duelo[1]
			for i in [piece1, piece2]:
				if i.ficha.team[0] == dead_piece[0]:
					pieza_rip = i 
							
		
		if pieza_rip.ficha.team == "Black":
			pieza_rip.queue_free()
			black_pieces.remove_at(black_pieces.find(pieza_rip))
			black_obs_pieces_list.remove_at(black_obs_pieces_list.find(pieza_rip))
			full_map.remove_at(full_map.find(pieza_rip.ficha.index))
			
		elif pieza_rip.ficha.team == "White":
			pieza_rip.queue_free()
			white_pieces.remove_at(white_pieces.find(pieza_rip))
			white_obs_pieces_list.remove_at(white_obs_pieces_list.find(pieza_rip))
			full_map.remove_at(full_map.find(pieza_rip.ficha.index))
		
		
		if (pieza_rip.ficha.id == "K"):
			end_game()
	
	
	else :
			
			if first_target.ficha.id == "P" :
		
				if first_target.ficha.team == "White" :
					
					first_target.move_piece(pos2,pos1, index_map, selector, full_map, true)
					first_target.ficha.index = old_indx
					full_map=gen_full_map()
					full_map.sort()
					
					
				elif first_target.ficha.team == "Black" :
					first_target.move_piece(pos2,pos1, index_map, selector2, full_map, true)
					full_map=gen_full_map()
					full_map.sort()
		
			
			else :
				first_target.move_piece(pos2,pos1, index_map, selector2, full_map, false)
				

	
func camera_handler():
	if selector.able == true:
		camera.transform.origin.x -= 250
		camera.transform.origin.y -= 800
		camera.zoom.x =0.8
		camera.zoom.y =0.8
		
	elif selector.able == false:
		camera.transform.origin.x += 250
		camera.transform.origin.y += 800
		camera.zoom.x =1
		camera.zoom.y =1
	
