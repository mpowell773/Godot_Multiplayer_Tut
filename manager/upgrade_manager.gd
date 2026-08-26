class_name UpgradeManager
extends Node

@export var enemy_manager: EnemyManager
@export var spawn_position: Marker2D
@export var spawn_root: Node2D
@export var available_upgrades: Array[UpgradeResource]

var upgrade_option_scene: PackedScene = preload("uid://egb6it4cxmj6")


func _ready() -> void:
	enemy_manager.round_completed.connect(_on_round_completed)


func _on_round_completed() -> void:
	var upgrade_option := upgrade_option_scene.instantiate() as UpgradeOption
	upgrade_option.global_position = spawn_position.global_position
	spawn_root.add_child(upgrade_option)
