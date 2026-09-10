extends Node2D
class_name World

### For managing and accessing the world scene and its children

@onready var level_holder : Node2D = $LevelHolder
@onready var overlay_layer: CanvasLayer = $OverlayLayer

func _input(event : InputEvent):
	#debug test space
	if event.is_action_pressed("debug"):
		pass
