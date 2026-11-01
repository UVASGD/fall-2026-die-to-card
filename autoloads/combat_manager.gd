extends Node

### Manages combat encounter functionality
## combat setup is handled in combat_level for timing's sake

signal phase_change(new_phase : PHASE)
signal player_health_changed(value : int)
signal player_reserves_changed(value : int)
#signal enemy_health_changed(value : int)
#signal enemy_reserves_changed(value: int)

enum PHASE {
	NONE, 
	DEPLOY, #deployment of units
	COMMAND, #applying intents to units
	EXECUTE #execute intents of units
}

## An array holding the order of intent execution in the EXECUTE phase
const INTENT_QUEUE_ORDER : Array[Unit.INTENT_TYPE] = [
	Unit.INTENT_TYPE.HEAL,
	Unit.INTENT_TYPE.MOVE,
	Unit.INTENT_TYPE.DEFEND,
	Unit.INTENT_TYPE.ATTACK,
	Unit.INTENT_TYPE.NULL
	]

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
			combat_grid.mouse_highlight = true
		PHASE.COMMAND:
			combat_menu.unit_selection.visible = false
			combat_menu.card_manager.draw(player_draw)
			combat_menu.card_manager.current_select_mode = CombatActionCardManager.SELECT_MODE.COMMAND
			combat_grid.mouse_highlight = true
		PHASE.EXECUTE:
			combat_menu.card_manager.discard(combat_menu.card_manager.player_hand)
			combat_menu.card_manager.current_select_mode = CombatActionCardManager.SELECT_MODE.NONE
			combat_grid.mouse_highlight = false
			handle_execute()
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

#region EXECUTE
func handle_execute():
	#prep the queue
	var intent_queues : Dictionary[Unit.INTENT_TYPE,Array] = {}
	#Array for each intent type will be in format ->
	#[[card_action,unit_data,unit_location(Vector2i)],...]
	
	#sorting intents into the queues
	for i in Unit.INTENT_TYPE.size():
		intent_queues.set(i,[])
	for i in combat_grid.unit_grid.keys():
		var unit : Unit = combat_grid.unit_grid.get(i)
		for k : CardAction in unit.intent_actions:
			var intent : Array = [k,unit.unit_data,i]
			intent_queues.get(k.intent_type).append(intent)
	
	#sorting the queues by unit_data
	#first running luck chance
	var luck_queue : Array = []
	for i : Array in intent_queues.values():
		var movin_intents : Array = []
		for j : Array in i:
			if randf() <= (j.get(1) as UnitData).luck:
				movin_intents.append(j)
		for j in movin_intents:
			i.erase(j)
		luck_queue.append_array(movin_intents)
	
	#then running speed comparison
	for i : Array in intent_queues.values():
		i.sort_custom(func(a,b): return (a.get(1) as UnitData).speed > (b.get(1) as UnitData).speed)
	luck_queue.sort_custom(func(a,b): return (a.get(1) as UnitData).speed > (b.get(1) as UnitData).speed)
	
	#activating the intents
	for i : Array in luck_queue:
		process_intent(i)
	for i : Unit.INTENT_TYPE in INTENT_QUEUE_ORDER:
		for j : Array in intent_queues.get(i):
			process_intent(j)

##Executes the provided intent
##intent array should match the format listed in handle_execute()
##intent arguments should match the documentation listed in CardAction
func process_intent(intent : Array):
	var card_action : CardAction = intent.get(0)
	var unit_coords : Vector2i
	var unit : Unit = null
	var i2 = intent.get(2)
	if i2 is Vector2i:
		unit_coords = i2
		if combat_grid.unit_grid.get(unit_coords) == null:
			assert(combat_grid.unit_grid.get(unit_coords) != null,"did not provide valid unit coordinates for intent")
			return
		else:
			unit = combat_grid.unit_grid.get(unit_coords)
	else:
		assert(i2 is Vector2i, "did not provide valid coordinates for intent")
	assert(card_action != null,"Provided null card action! No intent processing")
	match card_action.intent_type:
		Unit.INTENT_TYPE.HEAL:
			var targets : Array[Unit] = args_to_targets(intent)
			for i in targets:
				i.heal(card_action.value)
		Unit.INTENT_TYPE.MOVE:
			combat_grid.move_unit(unit,Vector2i(unit_coords.x+card_action.value,unit_coords.y))
		Unit.INTENT_TYPE.DEFEND:
			pass
			##var unit_coords : Vector2i
			##var i2 = intent.get(2)
			#if i2 is Vector2i:
				#unit_coords = i2
			##TODO: build in defend here!
		Unit.INTENT_TYPE.ATTACK:
			var targets : Array[Unit] = args_to_targets(intent)
			for i in targets:
				i.take_damage(card_action.value)
	unit.clear_intents()

func args_to_targets(intent : Array) -> Array[Unit]:
	var targets : Array[Unit] = []
	#obtaining and verifing data
	var card_action : CardAction = intent.get(0)
	
	var unit_coords : Vector2i
	var i2 = intent.get(2)
	if i2 is Vector2i:
		unit_coords = i2
	
	var target : String
	var a0 = card_action.args.get(0)
	if a0 is String:
		target = a0
	else:
		assert(a0 is String,"invalid target argument")
		return targets
	
	if not target == "self":
		#more obtaining and verifing data
		var area : String
		var a1 = card_action.args.get(1)
		if a1 is String:
			area = a1
		else:
			assert(a1 is String,"invalid area argument")
			return targets
		
		var area_size : int
		var area_box_size : Vector2i #only used for rectangles
		var a2 = card_action.args.get(2)
		if a2 is int:
			area_size = a2
		elif a2 is Vector2i:
			area_size = 1
			area_box_size = a2
		else:
			assert(a2 is int,"invalid area_size argument")
			area_size = 1
		
		var displacement : Vector2i
		var a3 = card_action.args.get(3)
		if a3 is Vector2i:
			displacement = a3
		else:
			assert(a3 is Vector2i,"invalid displacement argument")
			displacement = Vector2i.ZERO
		
		#area targeting
		var cell_coords : Vector2i = unit_coords + displacement
		match area:
			"cell":
				targets.append(combat_grid.target_cell(cell_coords))
			"cross":
				targets = combat_grid.target_cross(cell_coords,area_size)
			"row":
				targets = combat_grid.target_row(cell_coords.y)
			"column":
				targets = combat_grid.target_row(cell_coords.x)
			"square":
				var rect : Rect2i = Rect2i()
				rect.position = cell_coords
				rect.size = area_box_size
				targets = combat_grid.target_rect(rect)
			_:
				return targets
		
		#cleaning out unwanted targets
		var unit_data : UnitData = intent.get(1)
		var enemy : bool = false
		if unit_data != null:
			enemy = unit_data.is_enemy
			var erase_list : Array[Unit]
			match target: 
				"ally":
					for i in targets:
						if not enemy == i.enemy:
							erase_list.append(i)
				"enemy":
					for i in targets:
						if enemy == i.enemy:
							erase_list.append(i)
			for i in erase_list:
				targets.erase(i)
		assert(unit_data != null,"Unit data should not be null for intent!")
	else:
		return [combat_grid.unit_grid.get(unit_coords)]
	return targets
#endregion
