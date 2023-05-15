extends Node2D


signal invalid_movement


var ind2

var ficha = {
	id = "P",
	pos = "A1",
	team = "White",
	state = "Live",
	index =1,
	road_map = []
}

func buscar_llave_por_valor(diccionario, valor_buscado):
	for llave in diccionario:
		if diccionario[llave]== valor_buscado:
				
				return llave
	# Si no se encontró ninguna llave correspondiente al valor buscador

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func get_road_map(cas,pos,mapa,selector, valid):
	ind2 =self.move(cas,pos, mapa, selector,false)
	if ind2!=0:
		var road_map =self.obstr(cas, pos, mapa, selector , valid)
		return road_map
	else:
		return []
	
func move_piece(cas, pos2 ,mapa, selector, full_map, valid):# Moves the selected piece, to the index returned by the move funx
	
	#print("eje")
	#print("cas: ", cas)
	#print("cas num: ", cas[0].to_ascii_buffer()[0])
	ficha.pos=cas
	#self.position = Vector2(pos2.x-48, pos2.y+50)
	ind2 =self.move(cas,pos2, mapa, selector, valid)
	if ind2!=0:
		var old_ind = buscar_llave_por_valor(mapa, cas)
		var new_ind = ind2
		
		
		self.position = Vector2(pos2.x-48, pos2.y+50)
		self.ficha.index = new_ind
		full_map.sort()
		
		for i in (len(full_map)-1):
			if full_map[i] == old_ind:
				full_map[i]=new_ind
				


func move(cas,pos2, mapa, selector, valid): #Returns the new index the selected piece will move to , if the move selected is valid
	
	var ind
	
	if (self.ficha.id == "P" and  self.ficha.team == "White"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if valid == true:
			if (((indice_2 - indice_1)==7) or ((indice_2 - indice_1)) ==9):
				ind = buscar_llave_por_valor(mapa,pos2)
				
				
		elif valid== false:
			if  indice_1<=16: #First move
					if abs(indice_2-indice_1 )==16 :
						ind= buscar_llave_por_valor(mapa,pos2)
						
										
					elif (indice_2-indice_1 )==8: 
						ind= buscar_llave_por_valor(mapa,pos2)
						
						
						
					else:
						print("Invalid Movement")
						invalid_movement.emit()
						ind=0
						
			
			else : #inicio == false, osea ya se movio una vez
					
				if (indice_2-indice_1 )==8: 
					ind= buscar_llave_por_valor(mapa,pos2)
					
					
					
				else:	
					print("Invalid Movement")	
					invalid_movement.emit()
					ind=0
					
				
	elif (self.ficha.id == "P" and  self.ficha.team == "Black"):		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if valid == true:
			if (abs(indice_2 - indice_1)==7) or (abs(indice_2 - indice_1)) ==9:
				ind = buscar_llave_por_valor(mapa,pos2)
		
		
		elif (valid == false):
			if  indice_1>=49: #First move
				if (indice_2-indice_1 )== -16 :
					
					ind= buscar_llave_por_valor(mapa,pos2)
					
									
				elif (indice_2-indice_1 )==-8: 
			
					ind= buscar_llave_por_valor(mapa,pos2)
					
					
					
				else:
					print("Invalid Movement")
					invalid_movement.emit()
					ind=0
					
		
			else: #inicio == false, osea ya se movio una vez
				
				if indice_2-indice_1 ==-8: 
					
					ind= buscar_llave_por_valor(mapa,pos2)	
				
				
				else:	
					print("Invalid Movement")	
					invalid_movement.emit()
					ind=0
			
		
	elif (self.ficha.id == "B" and  self.ficha.team == "White"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if ((indice_2 - indice_1)%7==0) or ((indice_2 - indice_1)%9==0):
			ind= buscar_llave_por_valor(mapa,pos2)
		
		else:
			print("Invalid Movement")	
			invalid_movement.emit()
			ind=0
			
	elif (self.ficha.id == "B" and  self.ficha.team == "Black"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1)%7==0) or (abs(indice_2 - indice_1)%9==0):
			ind= buscar_llave_por_valor(mapa,pos2)
		
		else:
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
	
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
			ind= buscar_llave_por_valor(mapa,pos2)
			
		else :
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
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
			ind= buscar_llave_por_valor(mapa,pos2)
			
		else :
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
					
	elif (self.ficha.id == "R" and  self.ficha.team == "White"):
		
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if( cas.x != pos2.x and cas.y != pos2.y):
			
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
		
		elif (abs(indice_2 - indice_1)%8==0) or (abs(indice_2 - indice_1)<=7):
			ind= buscar_llave_por_valor(mapa,pos2)
		
		else:
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
	elif (self.ficha.id == "R" and  self.ficha.team == "Black"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if( cas.x != pos2.x and cas.y != pos2.y):
			
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
		
		elif (abs(indice_2 - indice_1)%8==0) or (abs(indice_2 - indice_1)<=7):
			ind= buscar_llave_por_valor(mapa,pos2)
		
		else:
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
	elif (self.ficha.id == "Q" and  self.ficha.team == "White"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if ((indice_2 - indice_1)%8==0) or ((indice_2 - indice_1)<=7) or ((indice_2 - indice_1)%7==0) or ((indice_2 - indice_1)%9==0):
			ind= buscar_llave_por_valor(mapa,pos2)
		
		else:
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
	elif (self.ficha.id == "Q" and  self.ficha.team == "Black"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1)%8==0) or (abs(indice_2 - indice_1)<=7) or (abs(indice_2 - indice_1)%7==0) or (abs(indice_2 - indice_1)%9==0):
			ind= buscar_llave_por_valor(mapa,pos2)
		
		else:
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
	elif (self.ficha.id == "K" and  self.ficha.team == "White"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1) ==1) or (abs(indice_2 - indice_1)==7) or (abs(indice_2 - indice_1)) ==9 or  (abs(indice_2 - indice_1)==8):
			ind= buscar_llave_por_valor(mapa,pos2)
			
		else:
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
			
	elif (self.ficha.id == "K" and  self.ficha.team == "Black"):
		
		var indice_1=buscar_llave_por_valor(mapa,cas)
		var indice_2=buscar_llave_por_valor(mapa,pos2)
		
		if (abs(indice_2 - indice_1) ==1) or (abs(indice_2 - indice_1)==7) or (abs(indice_2 - indice_1)) ==9 or  (abs(indice_2 - indice_1)==8):
			ind= buscar_llave_por_valor(mapa,pos2)
		
		else:
			print("Invalid Movement")
			invalid_movement.emit()
			ind=0
	
		
	return ind
	
func obstr(cas, pos, mapa, selector, valid): # Simulamos todos los posibles movimientos que hace una pieza hasta su posicion escogida, para ver si obstruye con alguna pieza ya existente
	
	var new_indx = buscar_llave_por_valor(mapa, pos)
	var old_indx = buscar_llave_por_valor(mapa,cas)
	var aux_indx
	
	
	var pawn_conquerable= []
	

	var camino_pos = [] #Sera una lista que a modo de "road map" mostrara todas los casilleros que la pieza "tendria que haber atravesado" hasta su posicion final"
	var camino_pos_indx = [] #lo mismo pero en indices en vez de posicion
	
	aux_indx=old_indx
		
	while(aux_indx != new_indx):
		
		
		if ( self.ficha.id == "P" ):
			
			if valid == false:
				
				var road = Vector2(mapa[aux_indx].x, mapa[aux_indx].y)
				if  (self.ficha.team == "White"):
					aux_indx += 8
				
				elif (self.ficha.team == "Black"):
				
					aux_indx -= 8
			
				camino_pos.append(road)
				camino_pos_indx.append(buscar_llave_por_valor(mapa,road))
			
			elif valid == true:
							
				if  (self.ficha.team == "White"):
					camino_pos.append(aux_indx + 9)
					camino_pos.append(aux_indx + 7)
						
					return camino_pos
				
				elif (self.ficha.team == "Black"):
				
					camino_pos.append(aux_indx - 9)
					camino_pos.append(aux_indx - 7)
					return camino_pos
					
		elif  (self.ficha.id == "B"):
			var road = Vector2(mapa[aux_indx].x, mapa[aux_indx].y)
			
			if mapa[new_indx].y < mapa[old_indx].y: #norte
					if mapa[new_indx].x > mapa[old_indx].x: #noreste
						aux_indx += 9
						
					elif mapa[new_indx].x < mapa[old_indx].x: #noroeste	
						aux_indx +=7
				
			if mapa[new_indx].y > mapa[old_indx].y: #sur
					if mapa[new_indx].x > mapa[old_indx].x: #sureste
						aux_indx -= 7
						
					elif mapa[new_indx].x < mapa[old_indx].x: #suroeste	
						aux_indx -= 9
			
			
			elif (mapa[new_indx].y ==  mapa[old_indx].y or mapa[new_indx].x == mapa[old_indx].x):
				return
			
			
			camino_pos.append(road)
			camino_pos_indx.append(buscar_llave_por_valor(mapa,road))
			
		
		elif (self.ficha.id == "N"): #El caballo puede saltar piezas asi que solo veremos su posicion final
			aux_indx = new_indx
			
		
		elif (self.ficha.id == "R" ):
				
			
			var road = Vector2(mapa[aux_indx].x, mapa[aux_indx].y)
			
			if  (mapa[new_indx].x != mapa[old_indx].x and mapa[new_indx].y == mapa[old_indx].y): #movimiento en horizontal
				if mapa[new_indx].x > mapa[old_indx].x:
					aux_indx += 1
				elif mapa[new_indx].x < mapa[old_indx].x:	
					aux_indx -=1
			
			elif  (mapa[new_indx].y != mapa[old_indx].y and mapa[new_indx].x == mapa[old_indx].x): #movimiento en vertical
				if mapa[new_indx].y > mapa[old_indx].y:
					aux_indx -= 8
				elif mapa[new_indx].y < mapa[old_indx].y:	
					aux_indx +=8
			
			else:
				return		
				
			camino_pos.append(road)
			camino_pos_indx.append(buscar_llave_por_valor(mapa,road))
		
		elif (self.ficha.id == "Q"):
			var road = Vector2(mapa[aux_indx].x, mapa[aux_indx].y)
			
			if  (mapa[new_indx].x != mapa[old_indx].x) and (mapa[new_indx].y == mapa[old_indx].y) : #Movimiento horizontal
					
				if mapa[new_indx].x > mapa[old_indx].x:
					aux_indx += 1
				elif mapa[new_indx].x < mapa[old_indx].x:	
					aux_indx -=1
			
			elif  (mapa[new_indx].x == mapa[old_indx].x) and (mapa[new_indx].y != mapa[old_indx].y): #Movimiento vertical
				
				if mapa[new_indx].y > mapa[old_indx].y:
					aux_indx -= 8
				elif mapa[new_indx].y < mapa[old_indx].y:	
					aux_indx +=8
			
			elif (mapa[new_indx].x != mapa[old_indx].x) and (mapa[new_indx].y != mapa[old_indx].y): #Movimiento diagonal
				
				if mapa[new_indx].y < mapa[old_indx].y: #norte
					if mapa[new_indx].x > mapa[old_indx].x: #noreste
						aux_indx += 9
						
					elif mapa[new_indx].x < mapa[old_indx].x: #noroeste	
						aux_indx +=7
				
				if mapa[new_indx].y > mapa[old_indx].y: #sur
					if mapa[new_indx].x > mapa[old_indx].x: #sureste
						aux_indx -= 7
						
					elif mapa[new_indx].x < mapa[old_indx].x: #suroeste	
						aux_indx -= 9
		
		
		
			camino_pos.append(road)
			camino_pos_indx.append(buscar_llave_por_valor(mapa,road))
			
		elif (self.ficha.id == "K"): #solo puede moverse un casillero por lo que checkearemos solamente su posicion final
			aux_indx = new_indx
				
			
	camino_pos.append(mapa[new_indx])
	camino_pos_indx.append(new_indx)
	
	if len(camino_pos)>1:
		
		camino_pos.pop_front()		
		camino_pos_indx.pop_front()	
	
	return camino_pos_indx


func pawn_eat(cas, mapa, selector):
	
	var indice_1=buscar_llave_por_valor(mapa,cas)
	
	
	var aux_indx
	
	var pawn_conquerable= []
	
	if self.ficha.id == "P":
	
		if self.ficha.team == "White":
			pawn_conquerable.append((indice_1 + 9))
			pawn_conquerable.append((indice_1 + 7))
			
	
		elif self.ficha.team == "Black":
			pawn_conquerable.append((indice_1 - 9))
			pawn_conquerable.append((indice_1 - 7))
	
	else:
		
		pawn_conquerable= []
		
	return pawn_conquerable



	
