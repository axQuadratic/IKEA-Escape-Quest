extends GridContainer

var map_icon: PackedScene = preload("res://scenes/map-manager/minimap/map_icon.tscn")


func update_minimap(map_data: Array, player_current_pos: Vector2i):
	for icon in get_children():
		icon.queue_free()

	var highest_x_pos: int
	for room in map_data:
		if room.room_position.x <= highest_x_pos: continue

		highest_x_pos = room.room_position.x

	var lowest_y_pos: int = 99
	for room in map_data:
		if room.room_position.y > lowest_y_pos: continue

		lowest_y_pos = room.room_position.y

	columns = highest_x_pos + 1

	var room_positions: Array[Vector2i]
	for room in map_data:
		room_positions.append(Vector2i(room.room_position.x, room.room_position.y - lowest_y_pos))

	player_current_pos = Vector2i(player_current_pos.x, player_current_pos.y - lowest_y_pos)

	for y in range(highest_x_pos + 1):
		for x in range(highest_x_pos + 1):
			var new_icon: ColorRect = map_icon.instantiate()

			if player_current_pos == Vector2i(x, y):
				new_icon.color = "#ffffff"
			elif Vector2i(x, y) in room_positions:
				new_icon.color = "#696969"
			else:
				new_icon.color = "#00000000"

			add_child(new_icon)
