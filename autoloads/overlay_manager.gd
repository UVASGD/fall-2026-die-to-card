extends Node

### Handles switching, loading, and dumping overlays
## also manages level transition timings, functions are in LevelManager
## 

# INFO: could be used to manage the overlay canvas layer as well

# The names of each overlay should match the names in scene_lib
var overlay_stack : Dictionary[StringName,Overlay] = {}
var overlay_layer : CanvasLayer = null

func _ready():
	overlay_layer = (await Utilities.get_world_when_ready()).overlay_layer
	#recording the overlays preloaded into overlay layer
	for i in overlay_layer.get_children():
		if i is Overlay:
			overlay_stack.set(LevelLib.retrieve_back_overlay(ResourceUID.path_to_uid(i.scene_file_path)),i)

## adding an overlay to the overlay layer
func attach_overlay(overlay_name : StringName):
	var new_overlay : Overlay = (load(LevelLib.retrieve_overlay(overlay_name)) as PackedScene).instantiate()
	overlay_layer.add_child(new_overlay)
	overlay_stack.set(overlay_name,new_overlay)
	await new_overlay.enter() #awaiting for transition timing

## removing all of the overlays currently attached to overlay layer, except spares
func clear_stack(spare : bool = false, spares : Array[Overlay] = []):
	for i in overlay_stack.values():
		if spare:
			if spares.has(i):
				continue
		overlay_stack.erase(LevelLib.retrieve_back_overlay(ResourceUID.path_to_uid(i.scene_file_path)))
		i.queue_free()

## removes a specific overlay from overlay layer
func detach_overlay(overlay_name : StringName):
	var overlay : Overlay = overlay_stack.get(overlay_name)
	await overlay.exit() # awaiting for transition timing
	overlay_stack.erase(overlay_name)
	overlay.queue_free()

## handles the overlay and timings for transitioning between scenes
## this is what you call to switch scenes
## WARNING: this clears all other overlays in the process
func run_transition(level_name : StringName, encounter_name : StringName, transition_name : StringName = &"blank_transition", new_overlay_names : Array[StringName] = []):
	await attach_overlay(transition_name)
	# middle block; stuff you want to happen "behind the veil" occurs now
	clear_stack(true,[overlay_stack.get(transition_name)])
	await LevelManager.detach_level()
	for i in new_overlay_names: # we attach overlays first!
		await attach_overlay(i)
	await LevelManager.attach_level(level_name,encounter_name)
	# end of middle block
	await detach_overlay(transition_name)
