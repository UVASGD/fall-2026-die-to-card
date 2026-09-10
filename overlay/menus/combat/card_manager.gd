class_name CombatActionCardManager
extends Node

### Manages the player action cards during combat, and their use
## refer to this script for any management of player hand or deck

const X_SEP : float = 5 # default pixel seperation
const HAND_SIZE_LIMIT : float = 420 # pixel limit
const MAX_ROTATION_RADIANS : float = PI/12 # card rotation
const Y_HEIGHT_MAX : int = 20 # card height limit

const HAND_MAX : int = 12 # actual card limit

#the curves are for the good ol' hand fanning effect
@export var hand_curve : Curve
@export var rotation_curve : Curve

var player_hand : Array[ActionCardDisplay]
var player_deck : Array[ActionCard]
var player_discard : Array[ActionCard]

@onready var player_hand_display: Control = $"../DESpace/HandMargin/PlayerHand"
@onready var player_hand_pos : Marker2D = $"../DESpace/HandMargin/PlayerHand/Pos"
@onready var player_deck_display: Control = $"../DeckSpace/DeckMargin/PlayerDeck"
@onready var player_deck_pos : Marker2D = $"../DeckSpace/DeckMargin/PlayerDeck/Pos"
@onready var player_discard_display: Control = $"../Discard Space/DiscardMargin/PlayerDiscard"
@onready var player_discard_pos : Marker2D = $"../Discard Space/DiscardMargin/PlayerDiscard/Pos"
@onready var card_display_template : PackedScene = preload("uid://b8nnn0fw630u5")

# right now, this only replaces the player_deck array
# in the future we should probably use this to setup the player deck display
func load_deck(cards : Array[ActionCard]):
	player_deck = cards

## draw a given number of cards from the deck into the hand
func draw(number : int):
	for i in range(number):
		if player_hand.size() >= HAND_MAX:
			continue # NOTE: we can make the cards discard from the draw or something,
			#               but im leaving this as a "pass" for now
		#load card
		if player_deck.is_empty():
			await reload_deck()
			if player_deck.is_empty():
				print("nothing to draw hit")
				return #there's literally nothing to draw, at all
				#TODO: for this EXTREMELY UNLIKELY situation, we could do some sorta
				#      pop-up or animation, like an easter egg or somethin
		var new_display : ActionCardDisplay = _make_card_display(player_deck.pop_front(),player_deck_pos.global_position)
		player_hand.append(new_display)
		new_display.load_display()
		_update_hand() #triggering movement

## retrieve a specific card from the deck into the hand
func search(card : ActionCard):
	if player_hand.size() >= HAND_MAX:
		return # NOTE: we can make the cards discard from the draw or something,
		#              but im leaving this as a "pass" for now
	if not card in player_deck:
		return #TODO: some sorta indicator for this, I imagine?
		# although, considering how we are likely going to use this, this catch
		# might never matter at all...
	#load card
	if player_deck.is_empty():
		await reload_deck()
		if player_deck.is_empty():
			print("nothing to draw hit")
			return #there's literally nothing to draw, at all
			#TODO: for this EXTREMELY UNLIKELY situation, we could do some sorta
			#      pop-up or animation, like an easter egg or somethin
	var card_idx : int = player_deck.rfind(card)
	var new_display : ActionCardDisplay = _make_card_display(player_deck.pop_at(card_idx),player_deck_pos.global_position)
	player_hand.append(new_display)
	new_display.load_display()
	_update_hand() #triggering movement

## discard the given cards to the discard pile (from hand or after use)
func discard(cards : Array[ActionCardDisplay]):
	if player_hand.is_empty():
		return
	for i in cards:
		var new_target : Vector2 = player_hand_pos.to_local(player_discard_pos.global_position)
		i.move_target(new_target,0.0,true)
		player_discard.append(i.action_card)
	var delete_cards : Array[ActionCardDisplay] = cards.duplicate()
	for i in delete_cards: # this is done after in case player_hand is passed directly in!
		player_hand.erase(i)

## reloads the discard pile into the deck
func reload_deck():
	for i in player_discard:
		var new_display : ActionCardDisplay = _make_card_display(i,player_discard_pos.global_position)
		new_display.move_target(player_hand_pos.to_local(player_deck_pos.global_position),0.0,true)
		player_deck.append(i)
	player_discard.clear()
	await get_tree().create_timer(1.0).timeout #for drawing pausing for reload

## shufflin the card order
func shuffle_deck():
	#TODO: some sorta animation trigger here would be cool
	player_deck.shuffle()

# in case any changes need to be made, here's my references for this:
# https://www.youtube.com/watch?v=waVOR2ehpuU
# https://www.youtube.com/watch?v=Alwy-TH0WzE&t=8s <- just the drawing animation (code mostly in display tween)
# hooray for youtube resources :)
## this manages the fanning of the hand (making it look pretty)
func _update_hand():
	var cards_size : float = 0
	var hand_sep = X_SEP
	var card_count = player_hand.size()
	var card_sizes : Array[int] = []
	for i : ActionCardDisplay in player_hand:
		card_sizes.append(i.size.x)
		cards_size += i.size.x
	var hand_size = cards_size + (card_count-1)*X_SEP
	#making sure the cards stay in their space!
	if hand_size > HAND_SIZE_LIMIT:
		hand_size = HAND_SIZE_LIMIT
		hand_sep = (HAND_SIZE_LIMIT - cards_size) / (player_hand.size()-1)
	#centering (?)
	#var offset_x : float = (HAND_SIZE_LIMIT - hand_size) / 2.0
	#sending targets to cards
	for i in card_count:
		var y_mult : float = hand_curve.sample((1.0/(card_count-1))*i)
		var rot_mult : float = rotation_curve.sample((1.0/(card_count-1))*i)
		if card_count == 1: #otherwise the card will just end up at max right rotation
			y_mult = 0.0
			rot_mult = 0.0
		#obtaining culumative card sizes
		var x_pos : int = 0
		for j in i:
			x_pos += card_sizes.get(j)
		#directing cards where to move and rotate
		var target_pos : Vector2 = Vector2((x_pos + (hand_sep*i)),(player_hand_pos.position.y)+(Y_HEIGHT_MAX*(1.0-y_mult)))
		var target_rot : float = MAX_ROTATION_RADIANS * rot_mult
		player_hand.get(i).move_target(target_pos,target_rot)

#NOTE: start_pos is GLOBAL POSITION!
func _make_card_display(action_card : ActionCard, start_pos : Vector2) -> ActionCardDisplay:
	var new_display : ActionCardDisplay = card_display_template.instantiate()
	player_hand_display.add_child(new_display)
	new_display.action_card = action_card
	new_display.global_position = start_pos
	return new_display
