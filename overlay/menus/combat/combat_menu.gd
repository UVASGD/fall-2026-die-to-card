class_name CombatMenu
extends Overlay

### This exists mostly to create a relay point for everything in this overlay
## most functionality in the combat ui lies in other scripts
## However, things like health and resources display are handled here (at least for now)

@onready var unit_selection : CombatUnitSelection = $PlayerBar/HBoxContainer/DESpace/UnitSelection
@onready var tooltip : CombatTooltipBox = $MarginContainer/PlayerCommand/Tooltip
@onready var player_reserves_display: Label = $PlayerResources/Reserves
@onready var player_health_display: Label = $PlayerResources/Health
@onready var card_manager: CombatActionCardManager = $PlayerBar/HBoxContainer/CardManager

# player health and resources
func _ready():
	CombatManager.player_health_changed.connect(update_player_health)
	CombatManager.player_reserves_changed.connect(update_reserves)

# these functions are currently barebones;
# going to expand them when player resources are more fleshed out
func update_player_health(value : int):
	player_health_display.text = "Health: %s" % value

func update_reserves(value : int):
	player_reserves_display.text = "Reserves: %s" % value
	unit_selection.check_affordable()
