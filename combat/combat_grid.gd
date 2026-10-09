class_name CombatGrid
extends Node2D

### Handles the storage of terrain and deployed units locations
## basically the lookup spot for where things are in a combat

# x = width, y = height
#NOTE: I'm using this for initialization currently...
# If we make any terrains outside of 12 by 5, we'll need to change something
var grid_size : Vector2i = Vector2i(12,5)

## for use in the highlight functions
# Should most certainly be updated to align with newer visuals and tiles
var highlight_atlas : Dictionary[String,Vector2] = {
	"player" : Vector2(0,0),
	"enemy" : Vector2(1,0),
	"target" : Vector2(2,0),
	"neutral": Vector2(4,4)
}

## for use in draw_terrain(), converting terrain map to visuals
#Should most certainly be updated to align with newer visuals and tiles
var tile_atlas : Dictionary[int,Vector2i] = {
	1 : Vector2i(1,0) #plains (numbers based off of CombatTile.TYPE)
}

#stores terrain data
@onready var terrain_grid : Array[Array] = []
#stores unit locations
#INFO: for targeting reference, the grid starts at the top left with 0,0
@onready var unit_grid : Dictionary[Vector2i,Unit] = {}
@onready var terrain_map : TileMapLayer = $TerrainLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer

func _ready():
	#initializing terrain grid
	for i in grid_size.x:
		terrain_grid.append([])
		for j in grid_size.y:
			terrain_grid.get(i).append(null)

func get_combat_tile(coords : Vector2i) -> CombatTile:
	var array : Array = terrain_grid.get(coords.x)
	var tile : CombatTile = null
	if array != null:
		tile = array.get(coords.y)
	return tile

## this is to use the terrain loaded from terrain_map to "draw" the terrain
func draw_terrain():
	terrain_map.clear()
	for i in terrain_grid:
		for j : CombatTile in i:
			if j == null:
				print("null tile attempted draw in combat_grid")
				continue
			terrain_map.set_cell(Vector2i(j.coords.x,j.coords.y),0,tile_atlas.get((j.type) as int))

#region targeting
## targeting an individual cell
func target_cell(coords : Vector2i) -> Array[Unit]:
	var target : Unit = unit_grid.get(coords)
	return [target]

## targeting a rectangle about a cell
func target_rect(rect : Rect2i) -> Array[Unit]:
	var targets : Array[Unit]
	for i in rect.size.x:
		for j in rect.size.y:
			var p_unit : Unit = unit_grid.get(rect.position + Vector2i(i,j))
			if p_unit != null:
				targets.append(p_unit)
	return targets

## targeting a cross about a cell
## INFO: a radius of 0 means only including the cell it's centered on!
func target_cross(center : Vector2i, radius : int) -> Array[Unit]:
	var targets : Array[Unit]
	for i in range(radius):
		for j in range(4):
			var dir : Vector2 = Vector2.from_angle((PI/4)*j)
			var p_unit : Unit = unit_grid.get(center + Vector2i(dir*i))
			if p_unit != null:
				targets.append(p_unit)
			if i == 0: #no dupes on center
				continue
	return targets

## targeting a row of the grid
func target_row(row : int) -> Array[Unit]:
	var targets : Array[Unit]
	for i in range(terrain_grid):
		var p_unit : Unit = unit_grid.get(Vector2i(i,row))
		if p_unit != null:
			targets.append(p_unit)
	return targets

## targeting a column of the grid
func target_column(column : int) -> Array[Unit]:
	var targets : Array[Unit]
	for i in range(terrain_grid[column]):
		var p_unit : Unit = unit_grid.get(Vector2i(column,i))
		if p_unit != null:
			targets.append(p_unit)
	return targets
#endregion

#also handles deployment
func move_unit(unit : Unit, destination : Vector2i, deployment : bool = false) -> bool:
	if !check_coords_movable_to(destination): return false
	
	unit_grid.erase(unit.location)
	unit.location = destination
	unit_grid.set(destination,unit)
	var move_tween : Tween = unit.create_tween().bind_node(unit)
	#TODO: tweak this tween at some point to make the anim good
	#TODO: also trigger movement animation in unit here
	move_tween.tween_property(unit,"position",terrain_map.map_to_local(destination),unit.unit_data.speed/3.0)
	#unit.position = Vector2i(terrain_map.map_to_local(destination))
	return true

# deployment; practically identical to move_unit but for clarity
func deploy_unit(unit: Unit, coords: Vector2i) -> bool:
	if !check_coords_movable_to(coords): return false
	unit_grid.erase(unit.location)
	unit.location = coords
	unit_grid.set(coords,unit)
	if not unit in get_children():
		add_child(unit)
	#TODO: add in deployment animation here!
	unit.position = Vector2i(terrain_map.map_to_local(coords))
	return true
	

# checks if grid coords store an entity or are out of bounds and returns false if this is the case
func check_coords_movable_to(coords : Vector2i):
	var mt = true
	if unit_grid.get(coords) != null:
		print("there's a unit in the way of movement")
		mt = false
	if check_coords_out_of_bounds(coords):
		mt = false
	return mt

# self-explanatory
func check_coords_out_of_bounds(coords : Vector2i):
	var oob = false
	var text = "no out of bounds movement"
	if coords.x < 0 or coords.x >= grid_size.x:
		text += " (x: {0} out of [0, {1}))".format([coords.x, grid_size.x])
		oob = true
	if coords.y < 0 or coords.y >= grid_size.y:
		text += " (y: ${0} out of [0, ${1}))".format([coords.y, grid_size.y])
		oob = true
	if oob: print(text)
	print("cannot move: %s" %oob)
	return oob


#region highlighting
func highlight_team():
	for i in terrain_grid:
		for j : CombatTile in i:
			if j.territory == CombatTile.TERRITORY.PLAYER:
				highlight_layer.set_cell(j.coords,0,highlight_atlas.get("player"))

func highlight_enemy():
	for i in terrain_grid:
		for j : CombatTile in i:
			if j.territory == CombatTile.TERRITORY.ENEMY:
				highlight_layer.set_cell(j.coords,0,highlight_atlas.get("enemy"))

func clear_highlight_layer():
	for i in terrain_grid:
		for j : CombatTile in i:
			highlight_layer.set_cell(j.coords,0,highlight_atlas.get("neutral"))
#endregion

func _process(delta: float) -> void:
	print(target_cell(Vector2i(0,0)))
