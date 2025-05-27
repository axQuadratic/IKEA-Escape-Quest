extends Control


func on_start() -> void:
	get_tree().root.add_child(load("res://scenes/map.tscn").instantiate())
	queue_free()
