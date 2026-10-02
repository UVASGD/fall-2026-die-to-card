extends Node

### Class for storing data for the current run regarding the player
## add anything here that will be needed between combats, encounters
## saving and loading player data between sessions will be handled elsewhere

var player_units : Array[UnitData] = []
var player_cards : Array[ActionCard] = []
var player_dice : Array[String] = [] #TODO: make dice when dice make

var reserves_max : int = 3
var health_max : int = 10
var health : int = health_max #out of max, saves health loss between encounters

func _ready():
	#for debug purposes, got to move this init somewhere else soon
	var baseset : Playset = load("uid://b2datigqkegl2")
	load_playset(baseset)

### Loads playset (to be used with save loading or starting up a run)
func load_playset(playset : Playset):
	player_cards = playset.deck
	player_units = playset.units
	player_dice = playset.dice
