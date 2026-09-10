extends Node2D
class_name Level

### Parent class for all levels, intended to be inherited from.
## make sure every level has a script inherting from this, or this script
## this ensures the level will function correctly in LevelManager

# only for combat arena; exists here because ALL levels are checked for this
@export var is_combat : bool = false

## override this in your levels to have functionality upon attach
func enter():
	pass

## override this in your levels to have functionality upon detach
func exit():
	pass
