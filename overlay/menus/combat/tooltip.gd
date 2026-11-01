class_name CombatTooltipBox
extends RichTextLabel

### Script managing the helpful tooltip that shows up on screen
## grid space info, unit selection info, whatever we desire

var tip_on : bool = false

func hide_tip():
	text = ""

func display_unit_data_tip(unit_data : UnitData, override : bool = true):
	if tip_on and not override:
		return #no display over!
	#TODO: make this look nice!
	hide_tip()
	add_text(unit_data.name)
	add_hr(90,1,Color(0.325, 0.529, 0.992, 1.0),HORIZONTAL_ALIGNMENT_LEFT)
	add_text("Max HP:  %s" % unit_data.max_health)
	newline()
	add_text("Speed:   %s" % unit_data.speed)
	newline()
	add_text("Defense: %s" % unit_data.defense)
	newline()
	add_text("Cost:    %s" % unit_data.cost)
	
func display_grid_space_tip(tile : CombatTile, override : bool = true):
	if tip_on and not override:
		return #no display over!
	hide_tip()
	add_text(tile.type_string())
	add_hr(90,1,Color(0.325, 0.733, 0.0, 1.0),HORIZONTAL_ALIGNMENT_LEFT)
	newline()
	add_text("TBD TILE MODS") #replace with tile information when we implement that
