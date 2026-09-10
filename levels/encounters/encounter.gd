extends Resource
class_name Encounter

### Parent class for encounters, combat or otherwise
## To create a new encounter, create a new resource inheriting from this

enum E_TYPE {
	COMBAT,
	OTHER
}

@export var type : E_TYPE = E_TYPE.OTHER
