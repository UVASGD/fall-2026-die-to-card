extends Resource
class_name CombatTile

## Stores an individual combat tile's data

enum TERRITORY {
	NEUTRAL,
	PLAYER,
	ENEMY
}
enum TYPE {
	VOID,
	FIELD
}

@export var territory : TERRITORY = TERRITORY.NEUTRAL
@export var type : TYPE = TYPE.VOID
@export var coords: Vector2i = Vector2i.ZERO
