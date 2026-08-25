class_name GameUI
extends CanvasLayer

@export var enemy_manager: EnemyManager
@export var lobby_manager: LobbyManager

@onready var timer_label: Label = %TimerLabel
@onready var round_label: Label = %RoundLabel
@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var display_name_label: Label = %DisplayNameLabel
@onready var ready_label: Label = %ReadyLabel
@onready var not_ready_label: Label = %NotReadyLabel
@onready var ready_count_label: Label = %ReadyCountLabel
@onready var ready_up_container: VBoxContainer = $MarginContainer/ReadyUpContainer
@onready var round_info_container: VBoxContainer = $MarginContainer/RoundInfoContainer


func _ready() -> void:
	enemy_manager.round_changed.connect(_on_round_changed)
	lobby_manager.self_peer_readied.connect(_on_self_peer_readied)
	lobby_manager.lobby_closed.connect(_on_lobby_closed)
	lobby_manager.peer_ready_states_changed.connect(_on_peer_ready_states_changed)
	
	var is_single_player := multiplayer.multiplayer_peer is OfflineMultiplayerPeer
	ready_up_container.visible = not is_single_player
	ready_up_container.visible = is_single_player
	round_info_container.visible = false
	ready_label.visible = false
	not_ready_label.visible = true


func _process(_delta: float) -> void:
	timer_label.text = str(ceili(enemy_manager.get_round_time_remaining()))


func connect_player(player: Player) -> void:
	# Wrapping the definition with a lambda to have it defer its call.
	# This allows the player to call _ready() upon itself before connect_player()
	# calls.
	(func():
		if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
			display_name_label.text = "Player"
		else:
			display_name_label.text = player.display_name
			
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


func _on_self_peer_readied() -> void:
	ready_label.visible = true
	not_ready_label.visible = false


func _on_lobby_closed() -> void:
	ready_up_container.visible = false
	round_info_container.visible = true


func _on_peer_ready_states_changed(ready_count: int, total_count: int) -> void:
	ready_count_label.text = "%s/%s READY" %[ready_count, total_count]
