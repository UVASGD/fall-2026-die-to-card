extends Node

### Manages combat encounter functionality
## combat setup is handled in combat_level for timing's sake

signal phase_change(new_phase : PHASE)
signal player_health_changed(value : int)
signal player_reserves_changed(value : int)
enum PHASE {
	NONE, 
	DEPLOY, #deployment of units
	COMMAND, #applying intents to units
	EXECUTE #execute intents of units
}

var combat_menu : CombatMenu = null
var combat_grid : CombatGrid = null
var current_phase : PHASE = PHASE.NONE

## functions as both a lock and a ready up signal :)
var in_combat : bool = false:
	set(value):
		if not phase_change.has_connections():
			phase_change.connect(_phase_change)
		if !value:
			set_phase(PHASE.NONE)
		else:
			start_combat()
		in_combat = value

#region player_values
var player_reserves : int = 3:
	set(value):
		player_reserves = value
		player_reserves_changed.emit(value)
var player_health : int = 10:
	set(value):
		player_health = value
		player_health_changed.emit(value)
var player_draw : int = 5 # how many cards the player draws in COMMAND
#endregion
#TODO: these when I make the basic ai work
#region enemy_values
var enemy_reserves : int = 3
var enemy_health : int = 10
var selected_dice : Control = null  #TODO: Fix this
#endregion
#handling player interaction with the grid (DEPLOY,COMMAND)
#TODO: mouseovers show up tooltip with tile + unit data
func _input(event: InputEvent) -> void:
	if in_combat:
		if event is InputEventKey:
			if event.is_action_released("debug"):
				progress_phase()
		if event is InputEventMouseButton:
			if event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					var mouse_pos : Vector2 = combat_grid.terrain_map.get_local_mouse_position()
					var map_pos : Vector2 = combat_grid.terrain_map.local_to_map(mouse_pos)
					if map_pos in combat_grid.terrain_map.get_used_cells():
						#INFO: DEPLOY handling
						if current_phase == PHASE.DEPLOY:
							deploy(map_pos)
						#INFO: COMMAND handling
						if current_phase == PHASE.COMMAND:
							var unit : Unit = combat_grid.unit_grid.get(map_pos)
							if unit != null:
								combat_menu.card_manager.command_unit(unit)

#region phase_transition

## basically the init function for combat, but it starts from setting in_combat
func start_combat():
	player_health = PlayerData.health
	player_reserves = PlayerData.reserves_max

## call this to move the phase along organically
func progress_phase():
	if current_phase == PHASE.EXECUTE:
		current_phase = PHASE.NONE
	current_phase = (current_phase + 1) as PHASE
	phase_change.emit(current_phase)
	
	#FOR DEBUG PURPOSES
	match current_phase:
					PHASE.NONE:
						print("now in phase NONE")
					PHASE.DEPLOY:
						print("now in phase DEPLOY")
					PHASE.COMMAND:
						print("now in phase COMMAND")
					PHASE.EXECUTE:
						print("now in phase EXECUTE")

#forceful, shouldn't be needed... I think
## Only use if you absolutely HAVE to, this can and will cause problems
func set_phase(phase : PHASE):
	current_phase = phase
	phase_change.emit(current_phase)

#reacting to phase change (handles the needed intermission actions)
func _phase_change(new_phase : PHASE):
	match new_phase:
		PHASE.DEPLOY:
			combat_menu.unit_selection.visible = true
		PHASE.COMMAND:
			combat_menu.unit_selection.visible = false
			combat_menu.card_manager.draw(player_draw)
			combat_menu.card_manager.current_select_mode = CombatActionCardManager.SELECT_MODE.COMMAND
		PHASE.EXECUTE:
			combat_menu.card_manager.discard(combat_menu.card_manager.player_hand)
			combat_menu.card_manager.current_select_mode = CombatActionCardManager.SELECT_MODE.NONE
		PHASE.NONE:
			combat_menu.unit_selection.visible = false
			combat_menu.card_manager.discard(combat_menu.card_manager.player_hand)
			combat_menu.card_manager.current_select_mode = CombatActionCardManager.SELECT_MODE.NONE
#endregion

#handle deploy off of mouse click (This is here to make _input less bulky)
func deploy(map_pos : Vector2):
	var current_tile : CombatTile = combat_grid.get_combat_tile(map_pos)
	if current_tile.territory == CombatTile.TERRITORY.PLAYER:
		var selected_unit : Unit = combat_menu.unit_selection.get_selected_unit()
		if selected_unit != null:
			selected_unit = selected_unit.duplicate(8)
			#backup cost check, but shouldn't be necessary
			if selected_unit.unit_data.cost > player_reserves:
				print("too costly triggered, but how?")
				combat_menu.unit_selection.deselect_unit()
				combat_menu.unit_selection.check_affordable()
			else:
				var success : bool = combat_grid.move_unit(selected_unit,map_pos,true)
				if !success:
					print("failed to place unit! (UNIT PROBABLY IN THE WAY)")
					#TODO: some sorta animation when this triggers would be cool...
				else:
					player_reserves -= selected_unit.unit_data.cost
					combat_menu.unit_selection.deselect_unit()
