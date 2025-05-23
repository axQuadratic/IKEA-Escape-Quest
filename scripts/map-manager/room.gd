extends Node2D


var floors: Array[PackedScene]

@export var room_walls: Array
@export var room_floor: String

@export var room_enemies: Array[String]
@export var room_cleared: bool

@onready var door_collision_manager: StaticBody2D = get_node("DoorCollisionManager")


func generate_room() -> void:
	for child in get_children():
		if child == door_collision_manager: continue
		
		child.queue_free()

	var wall_index: int = 0
	for door in door_collision_manager.get_children():
		if room_walls[wall_index] != "open":
			wall_index += 1
			continue

		door.disabled = false
		door.visible = true

		wall_index += 1

	# Place walls on all sides
	var wall_instance = GlobalAssets.wall_types_h[room_walls[0]].instantiate()
	add_child(wall_instance)
	move_child(wall_instance, 0)

	wall_instance = GlobalAssets.wall_types_v[room_walls[1]].instantiate()
	add_child(wall_instance)
	wall_instance.set_global_position(Vector2(get_viewport_rect().size.x - 32, 0))
	move_child(wall_instance, 0)
	
	wall_instance = GlobalAssets.wall_types_h[room_walls[2]].instantiate()
	add_child(wall_instance)
	wall_instance.set_global_position(Vector2(0, get_viewport_rect().size.y - 32)) # Move to bottom of screen excluding wall width
	move_child(wall_instance, 0)

	wall_instance = GlobalAssets.wall_types_v[room_walls[3]].instantiate()
	add_child(wall_instance)
	move_child(wall_instance, 0)

	# Select a floor
	var floor_instance = load("res://scenes/map-manager/floors/floor_" + room_floor + ".tscn").instantiate()
	add_child(floor_instance)
	move_child(floor_instance, 0)

	if len(room_enemies) == 0 or room_cleared:
		clear_room()
		return

	var enemy_index: int = 0
	for child in floor_instance.get_children():
		if not "SpawnPoint" in child.name: continue
		if enemy_index >= len(room_enemies): break

		var new_enemy = GlobalAssets.enemies[room_enemies[enemy_index]].instantiate()
		add_child(new_enemy)
		new_enemy.global_position = child.global_position

		enemy_index += 1


func clear_room() -> void:
	# Triggered when all enemies are defeated

	for door in door_collision_manager.get_children():
		door.disabled = true
		door.visible = false

	room_cleared = true