extends CharacterBody2D

@export var speed = 400
@export var bullet : PackedScene = preload("res://scenes/bullet.tscn")

func movement():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func shoot():
	var mouse_pos = get_viewport().get_mouse_position()
	var direction = get_angle_to(mouse_pos)
	var b = bullet.instantiate()
	add_sibling(b)
	b.transform = transform
	b.rotation += direction

func _physics_process(delta):
	movement()
	move_and_slide()

func _input(event):
	if Input.is_action_just_pressed("shoot"):
		shoot()
