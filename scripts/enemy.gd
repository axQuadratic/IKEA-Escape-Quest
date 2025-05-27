extends CharacterBody2D


signal defeated(enemy)


enum AIType { CHARGE, NONE }


@export var enemy_health: int
@export var enemy_sprite: CompressedTexture2D
@export var enemy_ai: AIType

@onready var shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")

var spawn_timer: float = 0.5


func _ready() -> void:
	# Add the enemy sprite
	sprite.texture = enemy_sprite
	sprite.centered = true
	sprite.scale = shape.shape.size / enemy_sprite.get_size()

	connect("defeated", get_node("/root/Map").on_enemy_defeated)


func _process(delta: float) -> void:
	if spawn_timer > 0:
		spawn_timer -= delta
		return

	# Check for 0 HP
	if enemy_health <= 0:
		emit_signal("defeated")
		queue_free()

	# Determine action based on AI
	match enemy_ai:
		AIType.CHARGE:
			agent.set_target_position(get_node("/root/Map/Player").global_position)
			var next_position: Vector2 = agent.get_next_path_position()

			var new_velocity: Vector2 = global_position.direction_to(next_position) * 200

			velocity = new_velocity
			move_and_slide()

		AIType.NONE:
			pass


func on_bullet_hit(bullet: Area2D) -> void:
	if spawn_timer > 0: return
	enemy_health -= bullet.bullet_damage
