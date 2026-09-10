extends Node

### Handles switching, loading, and dumping levels
## transition timings are handled in OverlayManager, functions are here
## see EncounterLib and LevelLib for encounters and levels

var current_level : Level
var level_holder : Node2D = null

func _ready():
	level_holder = (await Utilities.get_world_when_ready()).level_holder
	# recording the preloaded level
	for i in level_holder.get_children():
		if i is Level:
			current_level = i
			if current_level.is_combat:
				CombatManager.combat_grid = current_level.combat_grid

## attaching a new current level
## WARNING: this replaces current_level with the new level
##          so make sure it's cleared before running this function
func attach_level(level_name : StringName, encounter_name : StringName):
	var new_level : Level = (load(LevelLib.retrieve_level(level_name)) as PackedScene).instantiate()
	level_holder.add_child(new_level)
	current_level = new_level
	if current_level.is_combat:
		CombatManager.combat_grid = current_level.combat_grid
		CombatManager.combat_menu = OverlayManager.overlay_stack.get(&"combat_menu")
		(current_level as CombatLevel).combat_encounter = load(EncounterLib.retrieve_encounter(encounter_name))
	await current_level.enter() # await for transition timings

## detaching the current level
func detach_level():
	await current_level.exit()
	current_level.queue_free()
	current_level = null
	CombatManager.combat_grid = null
