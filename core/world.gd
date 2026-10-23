extends Node2D
class_name World

### For managing and accessing the world scene and its children

@onready var level_holder : Node2D = $LevelHolder
@onready var overlay_layer: CanvasLayer = $OverlayLayer

func _input(_event: InputEvent) -> void:
	pass
	#NOTE: use the following lines if you're fiddling with the gui, it's VERY helpful!
	#if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		#var clicked_control = get_viewport().gui_get_hovered_control()
		#print("Control receiving mouse hover: ", clicked_control)
