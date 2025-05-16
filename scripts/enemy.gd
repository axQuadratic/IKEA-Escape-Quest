extends CharacterBody2D


@export var enemy_health: int
@export var enemy_sprite: CompressedTexture2D

@onready var shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var sprite: Sprite2D = get_node("Sprite2D")


func _ready() -> void:
	# Add the enemy sprite
	sprite.texture = enemy_sprite
	sprite.centered = true
	sprite.scale = shape.shape.size / enemy_sprite.get_size()
