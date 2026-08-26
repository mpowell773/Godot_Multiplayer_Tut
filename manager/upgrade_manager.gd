class_name UpgradeManager
extends Node

@export var enemy_manager: EnemyManager
@export var spawn_position: Marker2D
@export var spawn_root: Node2D
@export var available_upgrades: Array[UpgradeResource]

var upgrade_option_scene: PackedScene = preload("uid://egb6it4cxmj6")
var peer_id_to_upgrade_options: Dictionary[int, Array] = {}


func _ready() -> void:
	enemy_manager.round_completed.connect(_on_round_completed)


func generate_upgrade_options() -> void:
	peer_id_to_upgrade_options.clear()
	var connected_peer_ids := multiplayer.get_peers()
	connected_peer_ids.append(MultiplayerPeer.TARGET_PEER_SERVER)
	
	for connected_peer_id in connected_peer_ids:
		var selected_upgrades: Array[String] = [
			available_upgrades[0].id,
			available_upgrades[0].id,
			available_upgrades[0].id
		]
		peer_id_to_upgrade_options[connected_peer_id] = [
			available_upgrades[0],
			available_upgrades[0],
			available_upgrades[0]
		]
		set_upgrade_options.rpc_id(connected_peer_id, selected_upgrades)


func show_upgrade_resources(upgrade_resources: Array[UpgradeResource]) -> void:
	var initial_x: int = -64
	var x_difference: int = 64
	
	for i in range(upgrade_resources.size()):
		var upgrade_option := upgrade_option_scene.instantiate() as UpgradeOption
		upgrade_option.set_upgrade_index(i)
		upgrade_option.set_upgrade_resource(upgrade_resources[i])
		
		upgrade_option.global_position = spawn_position.global_position
		# Spreads 3 upgrades evenly across the arena.
		upgrade_option.global_position += Vector2.RIGHT * (initial_x + (x_difference * i))
		
		spawn_root.add_child(upgrade_option)
		
		upgrade_option.selected.connect(_on_upgrade_option_selected)


@rpc("authority", "call_local", "reliable")
func set_upgrade_options(upgrade_ids: Array[String]) -> void:
	var upgrade_resouces: Array[UpgradeResource] = []
	
	for upgrade_id in upgrade_ids:
		var resource_index := available_upgrades.find_custom(func (item: UpgradeResource):
			return item.id == upgrade_id
		)
		upgrade_resouces.append(available_upgrades[resource_index])
	
	show_upgrade_resources(upgrade_resouces)


@rpc("any_peer", "call_local", "reliable")
func notify_upgrade_selected(upgrade_index: int) -> void:
	if not is_multiplayer_authority():
		return
	
	var peer_id := multiplayer.get_remote_sender_id()
	print("Peer %s has selected upgrade with id %s" %[
		peer_id,
		peer_id_to_upgrade_options[peer_id][upgrade_index].id
	])


func _on_round_completed() -> void:
	generate_upgrade_options()


func _on_upgrade_option_selected(upgrade_index: int) -> void:
	notify_upgrade_selected.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, upgrade_index)
