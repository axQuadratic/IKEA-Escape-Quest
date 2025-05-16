extends Node2D

var wall_types_h: Dictionary = {
	"closed": preload("res://scenes/map-manager/walls/horizontal_closed.tscn"),
	"open": preload("res://scenes/map-manager/walls/horizontal_open.tscn")
}

var wall_types_v: Dictionary = {
	"closed": preload("res://scenes/map-manager/walls/vertical_closed.tscn"),
	"open": preload("res://scenes/map-manager/walls/vertical_open.tscn")
}
var floors: Array[PackedScene]

@export var room_walls: Array
@export var room_floor: String

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
	var wall_instance = wall_types_h[room_walls[0]].instantiate()
	add_child(wall_instance)
	move_child(wall_instance, 0)

	wall_instance = wall_types_v[room_walls[1]].instantiate()
	add_child(wall_instance)
	wall_instance.set_global_position(Vector2(get_viewport_rect().size.x - 32, 0))
	move_child(wall_instance, 0)
	
	wall_instance = wall_types_h[room_walls[2]].instantiate()
	add_child(wall_instance)
	wall_instance.set_global_position(Vector2(0, get_viewport_rect().size.y - 32)) # Move to bottom of screen excluding wall width
	move_child(wall_instance, 0)

	wall_instance = wall_types_v[room_walls[3]].instantiate()
	add_child(wall_instance)
	move_child(wall_instance, 0)

	# Select a floor
	var floor_instance = load("res://scenes/map-manager/floors/floor_" + room_floor + ".tscn").instantiate()
	add_child(floor_instance)
	move_child(floor_instance, 0)


func clear_room() -> void:
	# Triggered when all enemies are defeated
	print("Room cleared!")
	for door in door_collision_manager.get_children():
		door.disabled = true
		door.visible = false
