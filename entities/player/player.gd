class_name Player
extends CharacterBody2D

signal died

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
@onready var visuals: Node2D = $Visuals
@onready var weapon_root: Node2D = $Visuals/WeaponRoot
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var barrel_position: Marker2D = %BarrelPosition
@onready var display_name_label: Label = $DisplayNameLabel

var bullet_scene: PackedScene = preload("uid://cmsm71jq22qef")
var muzzle_flash_scene: PackedScene = preload("uid://b604dyvkaj7mf")
var input_multiplayer_authority: int
var is_dying: bool
var is_respawn: bool
var display_name: String


func _ready() -> void:
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)
	
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		display_name_label.visible = false
	else:
		display_name_label.text = display_name
	
	if is_multiplayer_authority():
		if is_respawn:
			health_component.current_health = 1
			
		health_component.died.connect(_on_died)


func _process(_delta: float) -> void:
	# Client logic
	update_aim_position()
	
	# Server logic
	if is_multiplayer_authority():
		if is_dying:
			global_position = Vector2.RIGHT * 1000
			return

		velocity = player_input_synchronizer_component.movement_vector * 100
		move_and_slide()
		
		if player_input_synchronizer_component.is_attack_pressed:
			try_fire()


func set_display_name(incoming_name: String) -> void:
	display_name = incoming_name


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
	
	if player_input_synchronizer_component.is_multiplayer_authority():
		GameCamera.shake(1.0)


func kill():
	if not is_multiplayer_authority():
		push_error("Cannont call kill on non-server client")
		return
	
	_kill.rpc()
	await get_tree().create_timer(0.5).timeout
	
	died.emit()
	queue_free()


@rpc("authority", "call_local", "reliable")
func _kill() -> void:
	is_dying = true
	# Setting public visibility to false will stop broadcasting inputs to server
	player_input_synchronizer_component.public_visibility = false


func _on_died() -> void:
	kill()
