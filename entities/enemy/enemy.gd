extends CharacterBody2D

var impact_particles_scene: PackedScene = preload("uid://cps4vk7gofgi0")
var ground_particles_scene: PackedScene = preload("uid://dpu8dwdw0k7hq")

var target_position: Vector2
var state_machine: CallableStateMachine = CallableStateMachine.new()
var default_collision_mask: int
var default_collision_layer: int
var alert_tween: Tween

# Whenever current_state is changed, the multiplayer synchronizer will run the
# according callable to update clients. You can't pass references, but you can
# pass a primitive like a string that then gets converted in the setter.
var current_state: String:
	get:
		return state_machine.current_state
	set(value):
		var state: Callable = Callable.create(self, value)
		state_machine.change_state(state)

@onready var target_acquisition_timer: Timer = $TargetAcquisitionTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var charge_attack_timer: Timer = $ChargeAttackTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node2D = $Visuals
@onready var hitbox_collision_shape: CollisionShape2D = %HitboxCollisionShape
@onready var alert_sprite: Sprite2D = $AlertSprite
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_stream_player: AudioStreamPlayer = $HitStreamPlayer


func _notification(what: int) -> void:
	# Called before _ready(), avoids impromper state configuration
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		state_machine.add_states(state_spawn, enter_state_spawn, Callable())
		state_machine.add_states(state_normal, enter_state_normal, leave_state_normal)
		state_machine.add_states(state_charge_attack, enter_state_charge_attack,\
			leave_state_charge_attack)
		state_machine.add_states(state_attack, enter_state_attack, leave_state_attack)


func _ready() -> void:
	default_collision_mask = collision_mask
	default_collision_layer = collision_layer
	hitbox_collision_shape.disabled = true
	alert_sprite.scale = Vector2.ZERO

	if is_multiplayer_authority():
		health_component.died.connect(_on_died)
		state_machine.set_initial_state(state_spawn)
		hurtbox_component.hit_by_hitbox.connect(_on_hit_by_hitbox)


func _process(_delta: float) -> void:
	state_machine.update()
	if is_multiplayer_authority():
		move_and_slide()


func enter_state_spawn() -> void:
	var tween := create_tween()
	tween.tween_property(visuals, "scale", Vector2.ONE, 0.4)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func ():
		state_machine.change_state(state_normal)
	)


func state_spawn() -> void:
	# state_spawn must be defined due to the configuration of the
	# callable state machine.
	pass


func enter_state_normal() -> void:
	animation_player.play("run")

	if is_multiplayer_authority():
		acquire_target()
		target_acquisition_timer.start()


func state_normal() -> void:
	if is_multiplayer_authority():
		velocity = global_position.direction_to(target_position) * 40

		if target_acquisition_timer.is_stopped():
			acquire_target()
			target_acquisition_timer.start()

		var can_attack := attack_cooldown_timer.is_stopped()\
			or global_position.distance_to(target_position) < 16
		if can_attack and global_position.distance_to(target_position) < 150:
			state_machine.change_state(state_charge_attack)

	flip()


func leave_state_normal() -> void:
	animation_player.play("RESET")


func enter_state_charge_attack() -> void:
	if is_multiplayer_authority():
		acquire_target()
		charge_attack_timer.start()

	if alert_tween != null and alert_tween.is_valid():
		alert_tween.kill()

	alert_tween = create_tween()
	alert_tween.tween_property(alert_sprite, "scale", Vector2.ONE, 0.2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TransitionType.TRANS_BACK)


func state_charge_attack() -> void:
	if is_multiplayer_authority():
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-15.0 * get_process_delta_time()))
		if charge_attack_timer.is_stopped():
			state_machine.change_state(state_attack)

	flip()


func leave_state_charge_attack() -> void:
	if alert_tween != null and alert_tween.is_valid():
		alert_tween.kill()

	alert_tween = create_tween()
	alert_tween.tween_property(alert_sprite, "scale", Vector2.ZERO, 0.2)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TransitionType.TRANS_BACK)


func enter_state_attack() -> void:
	if is_multiplayer_authority():
		collision_mask = 1 << 0
		collision_layer = 0
		hitbox_collision_shape.disabled = false
		velocity = global_position.direction_to(target_position) * 400


func state_attack() -> void:
	if is_multiplayer_authority():
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-3 * get_process_delta_time()))
		if velocity.length() < 25:
			state_machine.change_state(state_normal)


func leave_state_attack() -> void:
	if is_multiplayer_authority():
		collision_mask = default_collision_mask
		collision_layer = default_collision_layer
		hitbox_collision_shape.disabled = true
		attack_cooldown_timer.start()


func flip() -> void:
	visuals.scale = Vector2.ONE if target_position.x > global_position.x\
		else Vector2(-1, 1)


func acquire_target() -> void:
	var players := get_tree().get_nodes_in_group("player")
	var nearest_player: Player = null
	var nearest_squared_distance: float

	for player in players:
		if nearest_player == null:
			nearest_player = player
			nearest_squared_distance = nearest_player.global_position\
				.distance_squared_to(global_position)
			continue

		var player_squared_distance: float = player.global_position\
			.distance_squared_to(global_position)
		if player_squared_distance < nearest_squared_distance:
			nearest_squared_distance = player_squared_distance
			nearest_player = player

	if nearest_player != null:
		target_position = nearest_player.global_position


@rpc("authority", "call_local", "unreliable")
func spawn_hit_effects() -> void:
	hit_stream_player.play()

	var hit_particles: Node2D = impact_particles_scene.instantiate()
	hit_particles.global_position = hurtbox_component.global_position
	get_parent().add_child(hit_particles)


@rpc("authority", "call_local", "unreliable")
func spawn_ground_particles() -> void:
	var ground_particles: Node2D = ground_particles_scene.instantiate()

	var background_node: Node = Main.background_mask
	if not is_instance_valid(background_node):
		background_node = get_parent()

	background_node.add_child(ground_particles)
	ground_particles.global_position = global_position


#region Signals

func _on_died() -> void:
	spawn_ground_particles.rpc()
	GameEvents.emit_enemy_died()
	queue_free()


func _on_hit_by_hitbox() -> void:
	spawn_hit_effects.rpc()

#endregion
