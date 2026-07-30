class_name Bullet
extends Node2D

# SPEED is in pixels per second
const SPEED: int = 600

var direction: Vector2


func _process(delta: float) -> void:
	global_position += direction * SPEED * delta


func start(_direction: Vector2) -> void:
	direction = _direction
	# align bullet with gun's orientation
	rotation = direction.angle()
