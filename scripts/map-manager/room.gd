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

func _ready() -> void:
	var floor_dir: DirAccess = DirAccess.open("res://scenes/map-manager/floors")
	floor_dir.list_dir_begin()

	var floor_scene: String = floor_dir.get_next()
	while floor_scene != "":
		print("here")
		floors.append(load("res://scenes/map-manager/floors/" + floor_scene))

		floor_scene = floor_dir.get_next()

	floor_dir.list_dir_end()

	randomize()
	generate_random_room()


func generate_random_room() -> void:
	# Destroy any current walls
	for child in get_children():
		if child is Control: continue

		child.queue_free()

	# Place randomly generated walls on all sides
	var wall_instance = wall_types_h[wall_types_h.keys().pick_random()].instantiate()
	add_child(wall_instance)
	move_child(wall_instance, 0)

	wall_instance = wall_types_h[wall_types_h.keys().pick_random()].instantiate()
	add_child(wall_instance)
	wall_instance.set_global_position(Vector2(0, get_viewport_rect().size.y - 32)) # Move to bottom of screen excluding wall width
	move_child(wall_instance, 0)

	wall_instance = wall_types_v[wall_types_v.keys().pick_random()].instantiate()
	add_child(wall_instance)
	move_child(wall_instance, 0)

	wall_instance = wall_types_v[wall_types_v.keys().pick_random()].instantiate()
	add_child(wall_instance)
	wall_instance.set_global_position(Vector2(get_viewport_rect().size.x - 32, 0))
	move_child(wall_instance, 0)

	# Select a random floor
	var floor_instance = floors.pick_random().instantiate()
	add_child(floor_instance)
	move_child(floor_instance, 0)
