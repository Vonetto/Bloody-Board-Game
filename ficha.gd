extends Node2D





var ficha = {
	id = "P",
	pos = "A1",
	team = "White",
	state = "Live",
	index =1
}

func buscar_llave_por_valor(diccionario, valor_buscado):
	for llave in diccionario:
		if diccionario[llave]== valor_buscado:
				
				return llave
	# Si no se encontró ninguna llave correspondiente al valor buscador

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	

signal invalid_move


func set_value():
	var value = false
	emit_signal("invalid_move", value )

func move_piece(cas, pos2 ,mapa, selector):
	
	#print("eje")
	#print("cas: ", cas)
	#print("cas num: ", cas[0].to_ascii_buffer()[0])
	ficha.pos=cas
	#self.position = Vector2(pos2.x-48, pos2.y+50)
	self.move(cas,pos2, mapa, selector)
	
	
	#global_position = Vector2(ficha.index + 96, ficha.index  -96)
	#global_position = Vector2(get_parent().square_size.x*(cas[0].to_ascii_buffer()[0]-65), get_parent().square_size.y*(int(cas[1])-1))

func move(cas,pos2, mapa, selector):
	
	var valid = true
	var inicio = true
	var primer = mapa[32]
	
	
	
	if (self.ficha.id == "P" and  self.ficha.team == "White"):
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if cas.x != pos2.x:
			valid=false
			print("Invalid Movement")
			
		
		if inicio == true: #First move
			if indice_1<=24 and pos2.x == cas.x:
				if (indice_2-indice_1 )==16 or (indice_2-indice_1 )==8 :
					self.position = Vector2(cas.x-48, pos2.y+50)
					inicio=false
				
				else:
					valid = false
					print("Invalid Movement")
		
		elif (indice_2-indice_1 )==8 and cas.x== pos2.x:
				self.position = Vector2(cas.x-48, pos2.y+50)
		
		else:
				valid= false
				print("Invalid Movement")	
			
	elif (self.ficha.id == "P" and  self.ficha.team == "Black"):
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if cas.x != pos2.x:
			valid=false
			print("Invalid Movement")
			
		if inicio == true: #First move
			if indice_1>=49:
				if abs(indice_2-indice_1 )==16 or abs(indice_2-indice_1 )==8 :
					self.position = Vector2(cas.x-48, pos2.y+50)
					inicio=false
				
				
				else:
					valid = false
					print("Invalid Movement")
		else:
			if abs(indice_2-indice_1 )==8 :
				self.position = Vector2(pos2.x-48, pos2.y+50)
		
			else:
				valid= false 
				print("Invalid Movement")	
		
	elif (self.ficha.id == "B" and  self.ficha.team == "White"):
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if ((indice_2 - indice_1)%7==0) or ((indice_2 - indice_1)%9==0):
			self.position = Vector2(pos2.x-48, pos2.y+50)
		
		else:
			valid = false
			print("Invalid Movement")	
		
	elif (self.ficha.id == "B" and  self.ficha.team == "Black"):
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1)%7==0) or (abs(indice_2 - indice_1)%9==0):
			self.position = Vector2(pos2.x-48, pos2.y+50)
		
		else:
			valid = false
			print("Invalid Movement")
			
	
	elif (self.ficha.id == "N" and  self.ficha.team == "White"):	
		
		var poss_movements = [
			Vector2(cas.x-2*96, cas.y-1*96), # Movimiento hacia arriba y a la izquierda
			Vector2(cas.x-1*96, cas.y-2*96), # Movimiento hacia la izquierda y hacia arriba
			Vector2(cas.x+1*96, cas.y-2*96),  # Movimiento hacia la izquierda y hacia abajo
			Vector2(cas.x+2*96, cas.y-1*96),  # Movimiento hacia abajo y a la izquierda
			Vector2(cas.x-2*96, cas.y+1*96),  # Movimiento hacia arriba y a la derecha
			Vector2(cas.x-1*96, cas.y+2*96),  # Movimiento hacia la derecha y hacia arriba
			Vector2(cas.x+1*96, cas.y+2*96),   # Movimiento hacia la derecha y hacia abajo
			Vector2(cas.x+2*96, cas.y+1*96)   	
		]
		
		if pos2 in poss_movements:
			#print(pos2)
			self.position = Vector2(pos2.x-48, pos2.y+50)
			
		else :
			valid = false
			print("Invalid Movement")

	elif (self.ficha.id == "N" and  self.ficha.team == "Black"):	
		
		var poss_movements = [
			Vector2(cas.x-2*96, cas.y-1*96), # Movimiento hacia arriba y a la izquierda
			Vector2(cas.x-1*96, cas.y-2*96), # Movimiento hacia la izquierda y hacia arriba
			Vector2(cas.x+1*96, cas.y-2*96),  # Movimiento hacia la izquierda y hacia abajo
			Vector2(cas.x+2*96, cas.y-1*96),  # Movimiento hacia abajo y a la izquierda
			Vector2(cas.x-2*96, cas.y+1*96),  # Movimiento hacia arriba y a la derecha
			Vector2(cas.x-1*96, cas.y+2*96),  # Movimiento hacia la derecha y hacia arriba
			Vector2(cas.x+1*96, cas.y+2*96),   # Movimiento hacia la derecha y hacia abajo
			Vector2(cas.x+2*96, cas.y+1*96)   	
		]
		
		if pos2 in poss_movements:
			#print(pos2)
			self.position = Vector2(pos2.x-48, pos2.y+50)
			
		else :
			valid = false
			print("Invalid Movement")
					
	elif (self.ficha.id == "R" and  self.ficha.team == "White"):
		
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if ((indice_2 - indice_1)%8==0) or (abs(indice_2 - indice_1)<=7):
			self.position = Vector2(pos2.x-48, pos2.y+50)
		
		else:
			valid = false
			print("Invalid Movement")
			
	elif (self.ficha.id == "R" and  self.ficha.team == "Black"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1)%8==0) or (abs(indice_2 - indice_1)<=7):
			self.position = Vector2(pos2.x-48, pos2.y+50)
		
		else:
			valid = false
			print("Invalid Movement")
			
	elif (self.ficha.id == "Q" and  self.ficha.team == "White"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if ((indice_2 - indice_1)%8==0) or ((indice_2 - indice_1)<=7) or ((indice_2 - indice_1)%7==0) or ((indice_2 - indice_1)%9==0):
			self.position = Vector2(pos2.x-48, pos2.y+50)
		
		else:
			valid = false
			print("Invalid Movement")
	
	elif (self.ficha.id == "Q" and  self.ficha.team == "Black"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1)%8==0) or (abs(indice_2 - indice_1)<=7) or (abs(indice_2 - indice_1)%7==0) or (abs(indice_2 - indice_1)%9==0):
			self.position = Vector2(pos2.x-48, pos2.y+50)
		
		else:
			valid = false
			print("Invalid Movement")
			
	elif (self.ficha.id == "K" and  self.ficha.team == "White"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1) ==1) or (abs(indice_2 - indice_1)==7) or (abs(indice_2 - indice_1)) ==9 or  (abs(indice_2 - indice_1)==8):
			self.position = Vector2(pos2.x-48, pos2.y+50)
		
		else:
			valid = false
			print("Invalid Movement")
	
	elif (self.ficha.id == "K" and  self.ficha.team == "Black"):
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1) ==1) or (abs(indice_2 - indice_1)==7) or (abs(indice_2 - indice_1)) ==9 or  (abs(indice_2 - indice_1)==8):
			self.position = Vector2(pos2.x-48, pos2.y+50)
		
		else:
			valid = false
			print("Invalid Movement")
	
	if 	valid == false:
		selector.modulate = Color(1,0,0)	
	else:
		selector.modulate = Color(1,1,1,1)

