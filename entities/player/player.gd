class_name Player
extends CharacterBody2D

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
@onready var weapon_root: Node2D = $WeaponRoot
@onready var fire_rate_timer: Timer = $FireRateTimer

var bullet_scene: PackedScene = preload("uid://cmsm71jq22qef")
var input_multiplayer_authority: int


func _ready() -> void:
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)


func _process(_delta: float) -> void:
	# Client logic
	var aim_position := weapon_root.global_position + player_input_synchronizer_component.aim_vector
	weapon_root.look_at(aim_position)
	
	# Server logic
	if is_multiplayer_authority():
		velocity = player_input_synchronizer_component.movement_vector * 100
		move_and_slide()
		
		if player_input_synchronizer_component.is_attack_pressed:
			try_create_bullet()


func try_create_bullet() -> void:
	if not fire_rate_timer.is_stopped():
		# Timer is still running, do not create bullet
		return
	
	var bullet := bullet_scene.instantiate() as Bullet
	bullet.global_position = weapon_root.global_position
	# One must use caution when calling functions before adding to the scene tree.
	# In this case, it's safe, but this should be something to be considered.
	bullet.start(player_input_synchronizer_component.aim_vector)
	get_parent().add_child(bullet, true)
	fire_rate_timer.start()
