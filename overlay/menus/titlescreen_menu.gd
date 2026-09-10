extends Overlay

## titlescreen functionality goes here


func _on_game_button_pressed() -> void:
	OverlayManager.run_transition(&"combat_arena",&"combat_test",&"blank_transition",[&"combat_menu"])
	
