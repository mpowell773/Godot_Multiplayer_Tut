class_name UpgradeOption
extends Node2D

signal selected(index: int, for_peer_id: int)

var upgrade_index: int
var assigned_resource: UpgradeResource
var peer_id_filter: int

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent


func _ready() -> void:
	health_component.died.connect(_on_died)
	hurtbox_component.peer_id_filter = peer_id_filter


func set_peer_id_filter(new_peer_id: int) -> void:
	peer_id_filter = new_peer_id
	hurtbox_component.peer_id_filter = peer_id_filter


func set_upgrade_index(index: int) -> void:
	upgrade_index = index


func set_upgrade_resource(upgrade_resource: UpgradeResource) -> void:
	assigned_resource = upgrade_resource


@rpc("authority", "call_local", "reliable")
func kill() -> void:
	queue_free()


func _on_died() -> void:
	selected.emit(upgrade_index, peer_id_filter)
	
	kill.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)
	if peer_id_filter != MultiplayerPeer.TARGET_PEER_SERVER:
		kill.rpc_id(peer_id_filter)
