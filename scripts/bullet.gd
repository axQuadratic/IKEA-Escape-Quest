extends Area2D

@export var bullet_speed = 750
@export var bullet_damage = 9999

@onready var audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _physics_process(delta):
	position += transform.x * bullet_speed * delta


func on_collision(body: Node2D) -> void:
	audio_player.play()
	visible = false
	collision_layer = 0
	await audio_player.finished
	queue_free()
