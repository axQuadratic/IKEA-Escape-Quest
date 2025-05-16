extends Node2D


@onready var player: Node2D = get_node("Player")
@onready var room: Node2D = get_node("Room")
@onready var minimap: Control = get_node("Control/Minimap")


class Room:
	var room_walls: Array
	var room_floor: String
	var room_position: Vector2i

	func _init(_room_walls, _room_floor, _room_position) -> void:
		self.room_walls = _room_walls
		self.room_floor = _room_floor
		self.room_position = _room_position


var map_data: Array[Room]

var player_current_pos: Vector2i = Vector2i(10, 10)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()
	update_position(true)

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

			last_position = new_position
			break

		var new_floor: String = floor_types.pick_random()

		# Walls are defined once all rooms are placed
		map_data.append(Room.new(["closed", "closed", "closed", "closed"], new_floor, new_position))
		occupied_positions.append(new_position)

	# Create doors in all shared walls
	for data_room in map_data:

		if Vector2i(data_room.room_position.x, data_room.room_position.y - 1) in occupied_positions:
			data_room.room_walls[0] = "open"
			print("Top open")

		if Vector2i(data_room.room_position.x + 1, data_room.room_position.y) in occupied_positions:
			data_room.room_walls[1] = "open"
			print("Right open")
			
		if Vector2i(data_room.room_position.x, data_room.room_position.y + 1) in occupied_positions:
			data_room.room_walls[2] = "open"
			print("Bottom open")
			
		if Vector2i(data_room.room_position.x - 1, data_room.room_position.y) in occupied_positions:
			data_room.room_walls[3] = "open"
			print("Left open")


func update_position(first_update = false) -> void:
	var current_room: Room

	for data_room in map_data:
		if data_room.room_position != player_current_pos: continue

		current_room = data_room
		break

	if current_room == null and first_update:
		# Fall back to first created room
		current_room = map_data[0]
		player_current_pos = current_room.room_position

	room.room_walls = current_room.room_walls
	room.room_floor = current_room.room_floor

	if first_update:
		room.generate_room()
		minimap.update_minimap(map_data, player_current_pos)

	else:
		room.call_deferred("generate_room")
		minimap.call_deferred("update_minimap", map_data, player_current_pos)


func on_door_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if body != player: return

	match local_shape_index:
		0:
			player_current_pos.y -= 1
			player.global_position = Vector2i(640, 672)
		1:
			player_current_pos.x += 1
			player.global_position = Vector2i(48, 360)
		2:
			player_current_pos.y += 1
			player.global_position = Vector2i(640, 48)
		3:
			player_current_pos.x -= 1
			player.global_position = Vector2i(1232, 360)

	update_position()


func on_enemy_defeated() -> void:
	room.call_deferred("clear_room")
