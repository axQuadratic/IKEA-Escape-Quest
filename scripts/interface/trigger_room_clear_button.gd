extends Button


func _ready() -> void:
	connect("pressed", func(): get_node("/root/Map").damage_all_enemies(9999))
