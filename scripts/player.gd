extends CharacterBody2D

@export var speed = 400
@export var bullet : PackedScene = preload("res://scenes/bullet.tscn")
@export var health = 6

@export var foot_1_audio = preload("res://assets/audio/foot1.mp3")
@export var foot_2_audio = preload("res://assets/audio/foot2.mp3")

@onready var sprite: Sprite2D = get_node("CollisionShape2D/Sprite2D")
@onready var foot_audio_player: AudioStreamPlayer = get_node("FootstepPlayer")
@onready var fire_audio_player: AudioStreamPlayer = get_node("FirePlayer")

var i_frame_timer: float
var bullet_timer: float
var footstep_timer: float


func _ready() -> void:
	foot_audio_player.stream = foot_1_audio

func movement():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	if footstep_timer <= 0 and velocity != Vector2(0, 0):
		footstep_timer = 0.5
		foot_audio_player.stream = foot_1_audio if foot_audio_player.stream == foot_2_audio else foot_2_audio
		foot_audio_player.play()
	
func shoot():
	print("Firing")
	bullet_timer = 0.4
	var mouse_pos = get_viewport().get_mouse_position()
	var direction = get_angle_to(mouse_pos)
	var b = bullet.instantiate()
	add_sibling(b)
	b.transform = transform
	b.rotation += direction

	fire_audio_player.play()

func _process(delta):
	if i_frame_timer > 0:
		i_frame_timer -= delta
	else:
		sprite.modulate = "ffffffff"

	if bullet_timer > 0:
		bullet_timer -= delta

	if health <= 0:
		# Return to main menu
		get_tree().root.add_child(load("res://scenes/main_menu.tscn").instantiate())
		get_node("/root/Map").queue_free()

	if Input.is_action_pressed("shoot") and bullet_timer <= 0:
		shoot()

func _physics_process(delta: float) -> void:
	if footstep_timer > 0:
		footstep_timer -= delta

	movement()
	move_and_slide()


func on_hit(area: Area2D) -> void:
	if i_frame_timer > 0: return

	health -= 1
	i_frame_timer = 1

	sprite.modulate = "ffffff80"
	
	print(health)
