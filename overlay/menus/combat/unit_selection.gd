extends ItemList
class_name CombatUnitSelection

## Backend for ui system for selecting units to deploy

@onready var tooltip : CombatTooltipBox = $"../../../../MarginContainer/PlayerCommand/Tooltip"
var last_index : int = -1

## obtaining the unit currently selected in the item list
func get_selected_unit() -> Unit:
	if get_selected_items().is_empty():
		return null
	return get_item_metadata(get_selected_items().get(0)) as Unit

## adding a new unit to the item list
func add_unit(new_unit_data : UnitData):
	#simple check for valid unit
	var p_scene : PackedScene = load(new_unit_data.unit_uid)
	var scene_inst = p_scene.instantiate()
	if not scene_inst is Unit:
		print("non unit attempted to add to unit selection")
		return
	var new_unit : Unit = scene_inst
	new_unit.unit_data = new_unit_data
	var idx : int = add_item(new_unit_data.name,new_unit.select_icon)
	set_item_metadata(idx,new_unit)

## removing unit from list
func remove_unit(unit : Unit):
	for i in range(item_count):
		if get_item_text(i) == unit.unit_data.name:
			remove_item(i)
			return

## use this later for the "tooltip" display for unit data
func _on_item_selected(index: int) -> void:
	if index == last_index: #making deselect possible
		deselect(last_index)
		last_index = -1
		tooltip.hide_tip()
		CombatManager.combat_grid.clear_highlight_layer()
	else:
		last_index = index
		var selected_unit : Unit = get_selected_unit()
		tooltip.display_unit_data_tip(selected_unit.unit_data)
		CombatManager.combat_grid.highlight_team()

## disable units you can't afford
func check_affordable():
	for i in item_count:
		var unit : Unit = get_item_metadata(i)
		if unit.unit_data.cost > CombatManager.player_reserves:
			set_item_disabled(i,true)
		else:
			set_item_disabled(i,false)

## forceful deselect
func deselect_unit():
	if last_index != -1: #to avoid unnecessary calls
		deselect(last_index)
		last_index = -1
		tooltip.hide_tip()
		CombatManager.combat_grid.clear_highlight_layer()
