extends CharacterBody2D

@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	area_2d.area_entered.connect(_on_area_entered)


func _on_area_entered(other_area: Area2D) -> void:
	if not is_multiplayer_authority():
		return
	if other_area.owner is Bullet:
		var bullet := other_area.owner as Bullet
		bullet.register_collision()
		print("collision")
