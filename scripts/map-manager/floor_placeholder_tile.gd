# TODO: Replace this script with manually tiled rooms or single large sprites
extends Node2D


var icon_svg: CompressedTexture2D = preload("res://icon.svg")


func _ready() -> void:
	# Iterate through all collision in the scene and place an icon.svg matching each of it
	for body in get_children():
		if body is NavigationRegion2D: continue

		for shape in body.get_children():
			if shape is NavigationObstacle2D: continue
			
			var new_sprite: Sprite2D = Sprite2D.new()

			new_sprite.texture = icon_svg
			new_sprite.centered = true
			new_sprite.scale = shape.shape.size / icon_svg.get_size()

			shape.add_child(new_sprite)
