extends GridContainer

var map_icon: PackedScene = preload("res://scenes/map-manager/minimap/map_icon.tscn")


func update_minimap(map_data: Array, player_current_pos: Vector2i):
	for icon in get_children():
		icon.queue_free()

	# Determine map bounds
	var highest_x_pos: int
	for room in map_data:
		if room.room_position.x <= highest_x_pos: continue

		highest_x_pos = room.room_position.x

	var lowest_x_pos: int = 99
	for room in map_data:
		if room.room_position.x > lowest_x_pos: continue

		lowest_x_pos = room.room_position.x

	var x_span: int = highest_x_pos + 1 - lowest_x_pos

	var highest_y_pos: int
	for room in map_data:
		if room.room_position.y <= highest_y_pos: continue

		highest_y_pos = room.room_position.y

	var lowest_y_pos: int = 99
	for room in map_data:
		if room.room_position.y > lowest_y_pos: continue

		lowest_y_pos = room.room_position.y

	var y_span: int = highest_y_pos + 1 - lowest_y_pos

	# Add padding to ensure square shape of minimap
	if x_span > y_span:
		if x_span - y_span % 2 == 0:
			lowest_y_pos -= (x_span - y_span) / 2
			highest_y_pos += (x_span - y_span) / 2

		else:
			lowest_y_pos -= floori(float(x_span - y_span) / 2)
			highest_y_pos += ceili(float(x_span - y_span) / 2)

		y_span += x_span - y_span

	elif y_span > x_span:
		if y_span - x_span % 2 == 0:
			lowest_x_pos -= (y_span - x_span) / 2
			highest_x_pos += (y_span - x_span) / 2

		else:
			lowest_x_pos -= floori(float(y_span - x_span) / 2)
			highest_x_pos += ceili(float(y_span - x_span) / 2)

		x_span += y_span - x_span

	# Determine room locations
	var room_positions: Array[Vector2i]
	var cleared_positions: Array[Vector2i]
	for room in map_data:
		room_positions.append(Vector2i(room.room_position.x - lowest_x_pos, room.room_position.y - lowest_y_pos))

		if not room.room_cleared: continue
		cleared_positions.append(Vector2i(room.room_position.x - lowest_x_pos, room.room_position.y - lowest_y_pos))

	player_current_pos = Vector2i(player_current_pos.x - lowest_x_pos, player_current_pos.y - lowest_y_pos)

	columns = x_span

	# Draw the minimap tiles based on determined bounds
	for y in range(y_span):
		for x in range(x_span):
			var new_icon: ColorRect = map_icon.instantiate()

			if player_current_pos == Vector2i(x, y):
				new_icon.color = "#ffffffe0"
			elif Vector2i(x, y) in room_positions and Vector2i(x, y) in cleared_positions:
				new_icon.color = "#696969e0"
			elif Vector2i(x, y) in room_positions:
				new_icon.color = "#505050a0"
			else:
				new_icon.color = "#00000000"

			add_child(new_icon)
