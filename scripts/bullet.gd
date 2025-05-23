extends Area2D

var bullet_speed = 750

func _physics_process(delta):
	position += transform.x * bullet_speed * delta
