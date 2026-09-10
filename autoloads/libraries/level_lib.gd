extends Node

### Handles storing and communicating level scene and overlay references
## back dictionaries are for reverse lookup needed in specific situations

const LEVELS : Dictionary[StringName,String] = {
	&"titlescreen" : "uid://be8uufjh0lvxv",
	&"combat_arena" : "uid://cutnrcn078gls"
}

#const BACK_LEVELS : Dictionary[String,StringName] = {
	#"uid://be8uufjh0lvxv" : &"titlescreen",
	#"uid://cutnrcn078gls" : &"combat_arena"
#}

const OVERLAYS : Dictionary[StringName,String] = {
	&"titlescreen_menu": "uid://c08m6jqvkj53w",
	&"blank_transition": "uid://bfc6oo33uoifm", #fanfareless swap
	&"combat_menu": "uid://b4720mj7xepuf"
}

const BACK_OVERLAYS : Dictionary[String,StringName] = {
	"uid://c08m6jqvkj53w": &"titlescreen_menu",
	"uid://bfc6oo33uoifm": &"blank_transition",
	"uid://b4720mj7xepuf": &"combat_menu"
}

## call this to obtain level uid safely
func retrieve_level(level_name : StringName) -> String:
	var level_uid : String = LEVELS.get(level_name)
	if level_uid == null:
		print("failed to retrieve level uid")
		return "uid://be8uufjh0lvxv"
	return level_uid

## call this to obtain overlay uid safely
func retrieve_overlay(overlay_name : StringName) -> String:
	var overlay_uid : String = OVERLAYS.get(overlay_name)
	if overlay_uid == null:
		print("failed to retrieve overlay uid")
		return "uid://c08m6jqvkj53w"
	return overlay_uid

## call this to obtain overlay name safely
func retrieve_back_overlay(overlay_uid : String) -> StringName:
	var overlay_name : String = BACK_OVERLAYS.get(overlay_uid)
	if overlay_name == null:
		print("failed to retrieve overlay name")
		return "uid://c08m6jqvkj53w"
	return overlay_name
