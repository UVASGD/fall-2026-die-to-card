class_name IntentDisplay
extends Control

## individual intent here, will be instantiated into CombatUnitIntentDisplay
@onready var intent_texture : TextureRect = $TextureRect
@onready var value_label: Label = $Value
# I only need these stored here for lookup in intentsdisplay
var intent_type : Unit.INTENT_TYPE = Unit.INTENT_TYPE.NULL
var value : int

#NOTE: this should be made to look nicer and whatnot in the future...

func set_intent(new_intent_type : Unit.INTENT_TYPE, new_value : int):
	match new_intent_type:
		Unit.INTENT_TYPE.ATTACK:
			((intent_texture.texture) as AtlasTexture).region.position = Vector2(0,0)
		Unit.INTENT_TYPE.DEFEND:
			((intent_texture.texture) as AtlasTexture).region.position = Vector2(8,0)
		Unit.INTENT_TYPE.HEAL:
			((intent_texture.texture) as AtlasTexture).region.position = Vector2(16,0)
		Unit.INTENT_TYPE.MOVE:
			((intent_texture.texture) as AtlasTexture).region.position = Vector2(24,0)
		_:
			((intent_texture.texture) as AtlasTexture).region.position = Vector2(32,0)
	value_label.text = str(new_value)
	intent_type = new_intent_type
	value = new_value
