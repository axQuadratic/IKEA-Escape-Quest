extends Node2D


@onready var player: Node2D = get_node("Player")
@onready var room: Node2D = get_node("Room")
@onready var minimap: Control = get_node("Control/MinimapContainer/MinimapContainerInner/Minimap")
@onready var health_bar: ProgressBar = get_node("Control/HealthBar")
@onready var global_sfx_player: AudioStreamPlayer = get_node("GlobalSFXPlayer")

var door_open_audio = preload("res://assets/audio/door_open.mp3")
var door_close_audio = preload("res://assets/audio/door_close.mp3")
var enemy_death_audio = preload("res://assets/audio/enemy_death.mp3")


class Room:
	var room_walls: Array
	var room_floor: String
	var room_position: Vector2i
	var room_enemies: Array[String]
	var room_spawn_points: int
	var room_cleared: bool = false

	func _init(_room_walls, _room_floor, _room_position, _room_enemies) -> void:
		self.room_walls = _room_walls
		self.room_floor = _room_floor
		self.room_position = _room_position
		self.room_enemies = _room_enemies

var map_data: Array[Room]

var current_room: Room

var player_current_pos: Vector2i = Vector2i(10, 10)

var nav_map: RID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()
	update_position(true)

func generate_map() -> void:
	randomize()

	var room_count: int = randi_range(10, 30)

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

		var new_enemies: Array[String]

		var enemy_count: int
		match randi_range(0, 4):
			0:
				enemy_count = 0
			_:
				enemy_count = randi_range(1, 10)

		match new_floor:
			"corners":
				if enemy_count > 9: enemy_count = 9

			"block":
				if enemy_count > 3: enemy_count = 3

			"checkerboard":
				if enemy_count > 7: enemy_count = 7
			
		for k in range(enemy_count):
			new_enemies.append(GlobalAssets.enemies.keys()[randi() % GlobalAssets.enemies.size()])

		# Walls are defined once all rooms are placed
		map_data.append(Room.new(["closed", "closed", "closed", "closed"], new_floor, new_position, new_enemies))
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
	room.room_enemies = current_room.room_enemies
	room.room_cleared = current_room.room_cleared

	if not room.room_cleared and len(room.room_enemies) == 0:
		room.room_cleared = true
		
		for data_room in map_data:
			if data_room.room_position != player_current_pos: continue

			data_room.room_cleared = true
			break

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

	if current_room.room_cleared: return

	global_sfx_player.stream = door_close_audio
	global_sfx_player.play()


func on_enemy_defeated() -> void:
	current_room.room_enemies.pop_back()

	global_sfx_player.stream = enemy_death_audio
	global_sfx_player.play()

	if len(current_room.room_enemies) > 0: return

	room.call_deferred("clear_room")

	global_sfx_player.stream = door_open_audio
	global_sfx_player.play()

	for data_room in map_data:
		if data_room.room_position != player_current_pos: continue

		data_room.room_cleared = true
		break


func damage_all_enemies(damage: int) -> void:
	# Get all enemies in the room
	print(len(current_room.room_enemies))
	print(current_room.room_floor)

	for child in get_node("/root/Map/Room").get_children():
		if !child is CharacterBody2D: continue

		child.enemy_health -= damage

func on_player_hit() -> void:
	health_bar.value += 1
