class_name Bullet
extends Node2D

# SPEED is in pixels per second
const SPEED: int = 600

@onready var life_timer: Timer = $LifeTimer

var direction: Vector2


func _ready() -> void:
	life_timer.timeout.connect(_on_life_timer_timeout)
	

func _process(delta: float) -> void:
	global_position += direction * SPEED * delta


func start(_direction: Vector2) -> void:
	direction = _direction
	# align bullet with gun's orientation
	rotation = direction.angle()


func _on_life_timer_timeout() -> void:
	if is_multiplayer_authority():
		queue_free()
