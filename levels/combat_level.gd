class_name CombatLevel
extends Level

### Script for combat arena + combat encounter setup

@export var combat_grid : CombatGrid
@export var combat_encounter : CombatEncounter

# prep for combat woo
func enter():
	for i in PlayerData.player_units:
		CombatManager.combat_menu.unit_selection.add_unit(i)
	#converting terrain resource to terrain array
	for i : CombatTile in combat_encounter.terrain_map.terrain.values():
		CombatManager.combat_grid.terrain_grid.get(i.coords.x).set(i.coords.y,i)
	CombatManager.combat_grid.draw_terrain()
	CombatManager.combat_grid.clear_highlight_layer() #as a precaution :)
	CombatManager.combat_menu.card_manager.load_deck(PlayerData.player_cards)
	CombatManager.combat_menu.card_manager.shuffle_deck()
	CombatManager.in_combat = true

func exit():
	CombatManager.in_combat = false
