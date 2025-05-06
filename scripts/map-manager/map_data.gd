extends Node


class Room:
	var room_walls: Array[String]
	var room_floor: String
	var room_position: Vector2i

	func _init(_room_walls, _room_floor, _room_position) -> void:
		self.room_walls = _room_walls
		self.room_floor = _room_floor
		self.room_position = _room_position


var map_data: Array[Room]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()


func generate_map() -> void:
	randomize()

	var room_count: int = randi_range(10, 20)

	var floor_types: Array[String]
	var floor_dir = DirAccess.open("res://scenes/map-manager/floors/")
	floor_dir.list_dir_begin()

	var file_name = floor_dir.get_next()
	while file_name != "":
		floor_types.append(file_name.replace("floor_", "").replace(".tscn", ""))

		file_name = floor_dir.get_next()

	floor_dir.list_dir_end()

	var occupied_positions: Array[Vector2i]
	var last_position: Vector2i = Vector2i(10, 10)

	for i in range(room_count):
		var new_position: Vector2i = last_position
		while true:

			match randi_range(0, 3):
				0:
					new_position.x += 1
				1:
					new_position.x -= 1
				2:
					new_position.y += 1
				3:
					new_position.y -= 1

			if new_position in occupied_positions:
				new_position = last_position
				continue

			break

		var new_floor: String = floor_types.pick_random()

		# Walls are defined once all rooms are placed
		map_data.append(Room.new(["closed", "closed", "closed", "closed"], new_floor, new_position))

	# Create doors in all shared walls
	for room in map_data:
		if Vector2i(room.room_position.x, room.room_position.y - 1) in occupied_positions:
			room.room_walls[0] = "open"

		if Vector2i(room.room_position.x + 1, room.room_position.y) in occupied_positions:
			room.room_walls[1] = "open"
			
		if Vector2i(room.room_position.x, room.room_position.y + 1) in occupied_positions:
			room.room_walls[2] = "open"
			
		if Vector2i(room.room_position.x - 1, room.room_position.y) in occupied_positions:
			room.room_walls[3] = "open"
