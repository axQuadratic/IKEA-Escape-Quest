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

@export var room_walls: Array[String]
@export var room_floor: String


func _ready() -> void:
	randomize()
	generate_room()


func generate_room() -> void:
	# Destroy any current walls
	for child in get_children():
		if child is Control: continue

		child.queue_free()

	# Place walls on all sides
	var wall_instance = wall_types_h[room_walls[0]].instantiate()
	add_child(wall_instance)
	move_child(wall_instance, 0)

	wall_instance = wall_types_h[room_walls[1]].instantiate()
	add_child(wall_instance)
	wall_instance.set_global_position(Vector2(0, get_viewport_rect().size.y - 32)) # Move to bottom of screen excluding wall width
	move_child(wall_instance, 0)

	wall_instance = wall_types_v[room_walls[2]].instantiate()
	add_child(wall_instance)
	move_child(wall_instance, 0)

	wall_instance = wall_types_v[room_walls[3]].instantiate()
	add_child(wall_instance)
	wall_instance.set_global_position(Vector2(get_viewport_rect().size.x - 32, 0))
	move_child(wall_instance, 0)

	# Select a floor
	var floor_instance = load("res://scenes/map-manager/floors/floor_" + room_floor + ".tscn").instantiate()
	add_child(floor_instance)
	move_child(floor_instance, 0)


func on_door_entered(body: Node2D) -> void:
	pass # Replace with function body.
