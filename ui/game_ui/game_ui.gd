class_name GameUI
extends CanvasLayer

@export var enemy_manager: EnemyManager

@onready var timer_label: Label = %TimerLabel
@onready var round_label: Label = %RoundLabel
@onready var health_progress_bar: ProgressBar = %HealthProgressBar


func _ready() -> void:
	enemy_manager.round_changed.connect(_on_round_changed)


func _process(_delta: float) -> void:
	timer_label.text = str(ceili(enemy_manager.get_round_time_remaining()))


func connect_player(player: Player) -> void:
	# Wrapping the definition with a lambda to have it defer its call.
	# This allows the player to call _ready() upon itself before connect_player()
	# calls.
	(func():
		player.health_component.health_changed.connect(_on_health_changed)
		update_health(player.health_component.current_health,\
			player.health_component.max_health)
	).call_deferred()


func update_health(current_health: int, max_health: int) -> void:
	if max_health == 0:
		push_error("Max health is set to 0 and creating a dividing by 0 case.")
		health_progress_bar.value = 0.0
		return
	
	health_progress_bar.value = float(current_health) / max_health
		# Ternary handles dividing by 0 case
		# I would not do this in a real project and would rather push an error.
		# I'm keeping this here just as an example.
		#if max_health != 0.0 else 0.0


func _on_round_changed(round_count: int) -> void:
	round_label.text = "Round %s" % round_count


func _on_health_changed(current_health: int, max_health: int) -> void:
	update_health(current_health, max_health)
