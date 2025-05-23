extends Area2D

@export var bullet_speed = 750
@export var bullet_damage = 9999

func _physics_process(delta):
	position += transform.x * bullet_speed * delta


func on_collision(body: Node2D) -> void:
	queue_free()
