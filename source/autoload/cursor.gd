extends CanvasLayer

var current_cursor: Sprite2D

@onready var gameplay_cursor: Sprite2D = $GameplayCursor
@onready var menu_cursor: Sprite2D = $MenuCursor


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	current_cursor = menu_cursor
	gameplay_cursor.visible = false


func _process(_delta: float) -> void:
	current_cursor.global_position = current_cursor.get_global_mouse_position()


func change_cursor(is_gameplay: bool) -> void:
	if is_gameplay:
		current_cursor = gameplay_cursor
		gameplay_cursor.visible = true
		menu_cursor.visible = false
	else:
		current_cursor = menu_cursor
		menu_cursor.visible = true
		gameplay_cursor.visible = false
