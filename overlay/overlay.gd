extends Control
class_name Overlay

### Parent class for all overlays, intended to be inherited from.
## make sure every overlay has a script inherting from this, or this script
## this ensures the overlay will function correctly in OverlayManager

## override this in your overlays to have functionality upon attach
## for transitions, the end of enter should be the middle of the transition
func enter():
	pass

## override this in your overlays to have functionality upon detach
## for transitions, the start of exit should be the middle of the transition
func exit():
	pass
