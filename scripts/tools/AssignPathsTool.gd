@tool
extends Node

# CONFIGURACIÓN:
# 1. Llena este diccionario.
#    La clave (key) es la ruta a tu escena de pieza (ej. Red_Pawn.tscn).
#    El valor (value) es la ruta al archivo JSON que le corresponde.
#    Asegúrate de que las rutas empiecen con "res://".
var scene_to_json_map = {
"res://Fight_Pieces/Red_Pieces/Red_Pawn/Red_Pawn.tscn": "res://assets/Characters Fight/Punches/red_punches/B_pawn_boxes_active.json",
"res://Fight_Pieces/Blue_Pieces/Blue_Pawn/Blue_Pawn.tscn": "res://assets/Characters Fight/Punches/blue_punches/WP_boxes_active.json",
}

@export var execute_assignment: bool = false:
	set(value):
		if value:
			_run_assignment()
			execute_assignment = false

func _run_assignment():
	if scene_to_json_map.is_empty():
		print("El diccionario 'scene_to_json_map' está vacío. Por favor, añade las rutas de tus escenas y archivos JSON.")
		return

	print("--- Iniciando asignación de rutas JSON ---")
	var modified_count = 0
	var error_count = 0

	for scene_path in scene_to_json_map:
		var json_path = scene_to_json_map[scene_path]
		
		var file_read = FileAccess.open(scene_path, FileAccess.READ)
		if not file_read:
			printerr("ERROR: No se pudo abrir la escena en la ruta: %s" % scene_path)
			error_count += 1
			continue
		
		var content = file_read.get_as_text()
		file_read.close()

		var new_content = ""
		var success = false
		var property_line_to_set = "boxes_json_path = \"%s\"" % json_path
		
		var regex = RegEx.new()
		regex.compile("(?m)^boxes_json_path = \".*\"")
		
		var match = regex.search(content)
		if match:
			new_content = regex.sub(content, property_line_to_set, true, 1)
			print("OK: Se *actualizó* la ruta en '%s'" % scene_path.get_file())
			success = true
		else:
			var script_regex = RegEx.new()
			script_regex.compile("(?m)^script = ExtResource\\(\\\".*\\\"\\)")
			var script_match = script_regex.search(content)
			
			if script_match:
				var script_line = script_match.get_string()
				new_content = content.replace(script_line, script_line + "\n" + property_line_to_set)
				print("OK: Se *añadió* la nueva ruta a '%s'" % scene_path.get_file())
				success = true
			else:
				printerr("ERROR: No se encontró la línea 'script = ExtResource(...)' en '%s'. No se pudo añadir la propiedad." % scene_path.get_file())
				error_count += 1
				continue

		if success:
			var file_write = FileAccess.open(scene_path, FileAccess.WRITE)
			if not file_write:
				printerr("ERROR: No se pudo ABRIR PARA ESCRIBIR la escena: %s" % scene_path)
				error_count += 1
				continue

			file_write.store_string(new_content)
			file_write.close()
			modified_count += 1

	print("--- Asignación completada ---")
	print("%d escenas modificadas, %d errores." % [modified_count, error_count])
