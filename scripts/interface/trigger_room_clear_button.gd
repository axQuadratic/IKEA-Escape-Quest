extends Button


func _ready() -> void:
	connect("pressed", get_node("/root/Map").on_enemy_defeated)
