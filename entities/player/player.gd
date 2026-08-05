class_name Player
extends CharacterBody2D


@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
@onready var visuals: Node2D = $Visuals
@onready var weapon_root: Node2D = $Visuals/WeaponRoot
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var barrel_position: Marker2D = %BarrelPosition

var bullet_scene: PackedScene = preload("uid://cmsm71jq22qef")
var muzzle_flash_scene: PackedScene = preload("uid://b604dyvkaj7mf")
var input_multiplayer_authority: int


func _ready() -> void:
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)
	health_component.died.connect(_on_died)


func _process(_delta: float) -> void:
	# Client logic
	update_aim_position()
	
	# Server logic
	if is_multiplayer_authority():
		velocity = player_input_synchronizer_component.movement_vector * 100
		move_and_slide()
		
		if player_input_synchronizer_component.is_attack_pressed:
			try_fire()


func update_aim_position() -> void:
	var aim_vector := player_input_synchronizer_component.aim_vector
	var aim_position := weapon_root.global_position + aim_vector
	# Flip sprite in relation to mouse position
	visuals.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1.0, 1.0)
	weapon_root.look_at(aim_position)


func try_fire() -> void:
	if not fire_rate_timer.is_stopped():
		# Timer is still running, do not create bullet
		return
	
	var bullet := bullet_scene.instantiate() as Bullet
	bullet.global_position = barrel_position.global_position
	# One must use caution when calling functions before adding to the scene tree.
	# In this case, it's safe, but this should be something to be considered.
	bullet.start(player_input_synchronizer_component.aim_vector)
	get_parent().add_child(bullet, true)
	fire_rate_timer.start()
	
	play_fire_effects.rpc()


@rpc("authority", "call_local", "unreliable")
func play_fire_effects() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("fire")
	
	var muzzle_flash := muzzle_flash_scene.instantiate() as GPUParticles2D
	muzzle_flash.global_position = barrel_position.global_position
	muzzle_flash.rotation = barrel_position.global_rotation
	get_parent().add_child(muzzle_flash)


func _on_died() -> void:
	print("player died")
