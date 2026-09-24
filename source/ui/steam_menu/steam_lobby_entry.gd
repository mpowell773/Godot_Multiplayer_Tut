extends Node

signal joining_lobby


var lobby_id: int = 0:
	set(value):
		lobby_id = value
		lobby_name = Steam.getLobbyData(lobby_id, "lobby_name")

var lobby_name := "":
	set(value):
		lobby_name = value
		if not is_node_ready():
			await ready
		name_label.text = "Lobby %s" % lobby_id if lobby_name.is_empty() else lobby_name

@onready var name_label: Label = %NameLabel
@onready var join_button: Button = %JoinButton


func _ready() -> void:
	join_button.pressed.connect(_on_join_button_pressed)


func _on_join_button_pressed() -> void:
	joining_lobby.emit()
