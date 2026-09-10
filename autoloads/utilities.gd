extends Node

### Holds code and nodes that many other scripts will use
##

var world : World = null

func _ready():
	world = await get_world_when_ready()

## waits around for world to be loaded and ready, and then nabs it
func get_world_when_ready() -> World :
	while get_tree().current_scene == null:
		await get_tree().process_frame
	await get_tree().current_scene.ready
	return get_tree().current_scene as World
