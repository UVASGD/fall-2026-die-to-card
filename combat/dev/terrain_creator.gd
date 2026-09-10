@tool
class_name TerrainCreator
extends Node2D

### Tool script for creating, loading, and editing terrain for combat encounters

@export var resource_name : StringName
@export_tool_button("Save Terrain","Save") var terrain_save : Callable = save_terrain
@export_tool_button("Load Terrain","Load") var terrain_load : Callable = load_terrain
@export_tool_button("Clear Terrain","Clear") var terrain_clear : Callable = clear_terrain

# used for loading terrainmaps to visually accessible format
var type_to_tile : Dictionary[int,Vector2i] = {}
var territory_to_tile : Dictionary[int,Vector2i] = {}

@onready var base_layer : TileMapLayer = $Base
@onready var territory_layer : TileMapLayer = $Territory

func _init():
	#init here to make it loaded on tool runtime
	type_to_tile = {
	0 : Vector2i(4,4),
	1 : Vector2i(1,0)
	}
	territory_to_tile = {
	0 : Vector2i(4,4),
	1 : Vector2i(0,0),
	2 : Vector2i(1,0)
	}

func save_terrain():
	if Engine.is_editor_hint():
		var new_terrain : TerrainMap = TerrainMap.new()
		for i in base_layer.get_used_cells():
			# read data from tilemap layer
			#NOTE: check CombatTile for int -> enum conversion here
			var base_data : TileData = base_layer.get_cell_tile_data(i)
			var territory_data : TileData = territory_layer.get_cell_tile_data(i)
			var tile_type : CombatTile.TYPE = base_data.get_custom_data("Type")
			var tile_territory: CombatTile.TERRITORY = territory_data.get_custom_data("Territory")
			# load data
			var new_tile : CombatTile = CombatTile.new()
			new_tile.type = tile_type
			new_tile.territory = tile_territory
			new_tile.coords = i
			# save data
			new_terrain.terrain.set(i,new_tile)
		var error : Error = ResourceSaver.save(new_terrain,"res://data/terrain/"+String(resource_name)+".tres")
		if error != Error.OK:
			print(error)

func load_terrain():
	if Engine.is_editor_hint():
		var loaded_terrain : TerrainMap = load("res://data/terrain/"+String(resource_name)+".tres")
		base_layer.clear()
		territory_layer.clear()
		for i in loaded_terrain.terrain:
			var combat_tile : CombatTile = loaded_terrain.terrain.get(i)
			base_layer.set_cell(i,0,type_to_tile.get(combat_tile.type))
			territory_layer.set_cell(i,0,territory_to_tile.get(combat_tile.territory))

func clear_terrain():
	if Engine.is_editor_hint():
		base_layer.clear()
		territory_layer.clear()
		for i in range(12):
			for j in range(5):
				base_layer.set_cell(Vector2i(i,j),0,type_to_tile.get(0))
				territory_layer.set_cell(Vector2i(i,j),0,territory_to_tile.get(0))
