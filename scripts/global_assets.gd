extends Node

var wall_types_h: Dictionary = {
	"closed": preload("res://scenes/map-manager/walls/horizontal_closed.tscn"),
	"open": preload("res://scenes/map-manager/walls/horizontal_open.tscn")
}

var wall_types_v: Dictionary = {
	"closed": preload("res://scenes/map-manager/walls/vertical_closed.tscn"),
	"open": preload("res://scenes/map-manager/walls/vertical_open.tscn")
}

var enemies: Dictionary = {
	"test_enemy": preload("res://scenes/enemy-manager/enemies/test_enemy.tscn")
}
