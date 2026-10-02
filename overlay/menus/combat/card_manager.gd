class_name CombatActionCardManager
extends Node

### Manages the player action cards during combat, and their use
## refer to this script for any management of player hand or deck

#used in select_cards(), refer to that for these meanings
enum SELECT_MODE {
	NONE,
	COMMAND,
	DISCARD
}

#used in deselect_cards(), refer to that for these meanings
enum DESTINATION {
	HAND,
	DISCARD,
	DRAW
}

#region handfan constants
const HAND_X_SEP : float = 5 # default pixel seperation
const HAND_MAX_ROTATION_RADIANS : float = PI/12 # card rotation
const HAND_Y_HEIGHT_MAX : int = 25 # card height limit
const HAND_Y_TOTAL_OFFSET : int = 10 # adding height to the hand
#focus visibility offsets
const HAND_X_FOCUS_OFFSET : int = 10
const HAND_Y_FOCUS_OFFSET : int = 15
#endregion

#region selectspread constants
const SELECT_X_SEP : float = 5 #default pixel seperation
const SELECT_Y_TOTAL_OFFSET : int = 0 #adding height to spread
#focus visibility offsets
const SELECT_X_FOCUS_OFFSET : int = 5
const SELECT_Y_FOCUS_OFFSET : int = 0
#endregion

const HAND_MAX : int = 12 # actual card limit

#the curves are for the good ol' hand fanning effect
@export var hand_curve : Curve
@export var rotation_curve : Curve

var player_hand : Array[ActionCardDisplay] = []
var player_deck : Array[ActionCard] = []
var player_discard : Array[ActionCard] = []
var selected_cards : Array[ActionCardDisplay] = []
 #communicating what type of selection COULD be happening
var current_select_mode : SELECT_MODE = SELECT_MODE.NONE:
	set(new_mode):
		close_select()
		current_select_mode = new_mode
#communicating if selecting is happening
var is_selecting : bool = false
#flag for telling combatmanager that command is ready to be applied to unit
var command_ready : bool = false

@onready var player_mat: Panel = $"../DESpace/PlayerMat"
@onready var player_mat_pos : Marker2D = $"../DESpace/PlayerMat/PlayerHandPos"
@onready var player_deck_mat: Panel = $"../DeckSpace/DeckMargin/PlayerDeckMat"
@onready var player_discard_mat : Panel = $"../Discard Space/DiscardMargin/PlayerDiscardMat"
@onready var select_container : MarginContainer = $"../../../CenterOffset"
@onready var select_mat : Panel = $"../../../CenterOffset/VBoxContainer/SelectMat"
@onready var select_text_label : RichTextLabel = $"../../../CenterOffset/VBoxContainer/SelectText"
@onready var select_confirm_button : Button = $"../../../CenterOffset/VBoxContainer/SelectConfirmButton"
@onready var side_slot_mat : Panel = $"../../../MarginContainer/PlayerCommand/SideMargins/SideSlotMat"
@onready var card_display_template : PackedScene = preload("uid://b8nnn0fw630u5")

#region datamovement
# right now, this only replaces the player_deck array
# in the future we should probably use this to setup the player deck display
func load_deck(cards : Array[ActionCard]):
	player_deck = cards

#call the following two functions throughout this script to do what they're called
func _add_display_to_hand(new_display : ActionCardDisplay):
	player_hand.append(new_display)
	new_display.load_display()
	_connect_hand_signals(new_display)

func _remove_display_from_hand(display : ActionCardDisplay):
	player_hand.erase(display)
	display.scale = Vector2.ONE
	_disconnect_hand_signals(display)

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
		var new_display : ActionCardDisplay = _make_card_display(player_deck.pop_front(),player_deck_mat.global_position)
		_add_display_to_hand(new_display)
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
	var new_display : ActionCardDisplay = _make_card_display(player_deck.pop_at(card_idx),player_deck_mat.global_position)
	_add_display_to_hand(new_display)
	_update_hand() #triggering movement

## discard the given cards to the discard pile (from hand or after use)
# special case (need to not use _remove_display_from_hand() )
func discard(cards : Array[ActionCardDisplay]):
	if player_hand.is_empty():
		return
	for i in cards:
		i.scale = Vector2.ONE
		_disconnect_hand_signals(i)
		var new_target : Vector2 = player_mat_pos.to_local(player_discard_mat.global_position)
		i.move_target(new_target,0.0,true)
		player_discard.append(i.action_card)
	var delete_cards : Array[ActionCardDisplay] = cards.duplicate()
	for i in delete_cards: # this is done after in case player_hand is passed directly in!
		player_hand.erase(i)

## reloads the discard pile into the deck
func reload_deck():
	for i in player_discard:
		var new_display : ActionCardDisplay = _make_card_display(i,player_discard_mat.global_position)
		new_display.action_card = i
		new_display.load_display()
		new_display.move_target(player_mat_pos.to_local(player_deck_mat.global_position),0.0,true)
		player_deck.append(i)
	player_discard.clear()

## shufflin the card order
func shuffle_deck():
	#TODO: some sorta animation trigger here would be cool
	player_deck.shuffle()
#endregion

#region cardmovement
# in case any changes need to be made, here's my references for this:
# https://www.youtube.com/watch?v=waVOR2ehpuU
# https://www.youtube.com/watch?v=Alwy-TH0WzE&t=8s <- just the drawing animation (code mostly in display tween)
# hooray for youtube resources :)
## this manages the fanning of the hand (making it look pretty)
func _update_hand():
	var cards_size : float = 0
	var hand_sep = HAND_X_SEP
	var card_count = player_hand.size()
	var card_sizes_x : Array[int] = []
	var card_offsets_y : Array[int] = [] #for cards that are being scaled! (focus)
	for i : ActionCardDisplay in player_hand:
		var card_size_x : int = int(i.size.x * i.scale.x)
		var card_offset_y = 0.5*i.size.y*(i.scale.y-1)
		if i.focus:
			#offsets for focus visibility
			card_size_x += HAND_X_FOCUS_OFFSET
			card_offset_y += HAND_Y_FOCUS_OFFSET
		card_sizes_x.append(card_size_x)
		cards_size += card_size_x
		card_offsets_y.append(card_offset_y)
	var hand_size = cards_size + (card_count-1)*HAND_X_SEP
	#making sure the cards stay in their space!
	if hand_size > player_mat.size.x:
		hand_size = player_mat.size.x
		if card_count > 1:
			hand_sep = (player_mat.size.x - cards_size) / (card_count-1)
	#centering the hand when the cards aren't taking up the whole space
	var centering_offset : float = (player_mat.size.x - hand_size) / 2
	#sending targets to cards
	for i in card_count:
		var y_mult : float = hand_curve.sample((1.0/(card_count-1))*i)
		var rot_mult : float = rotation_curve.sample((1.0/(card_count-1))*i)
		if card_count == 1: #otherwise the card will just end up at max right rotation
			y_mult = 0.0
			rot_mult = 0.0
		#obtaining culumative card sizes for offset
		var x_pos : int = 0
		for j in i:
			x_pos += card_sizes_x.get(j)
		var target_rot : float
		#focus management
		var card : ActionCardDisplay = player_hand.get(i)
		if card.focus: # so you can properly read the text on the card
			target_rot = 0
			x_pos += int(0.5*card.size.x*(card.scale.x-1))
		else:
			target_rot = HAND_MAX_ROTATION_RADIANS * rot_mult
		#directing cards where to move and rotate
		var target_pos : Vector2 = Vector2(centering_offset+(x_pos + (hand_sep*i)),(HAND_Y_HEIGHT_MAX*(1.0-y_mult))-card_offsets_y.get(i)-HAND_Y_TOTAL_OFFSET)
		card.move_target(target_pos,target_rot)

##Handling the spread of cards for the select area, similar to above function but tweaked
func _update_select_spread():
	var cards_size : float = 0
	var spread_sep = SELECT_X_SEP
	var card_count = selected_cards.size()
	var card_sizes_x : Array[int] = []
	var card_offsets_y : Array[int] = [] #for cards the are being scaled! (focus)
	for i : ActionCardDisplay in selected_cards:
		var card_size_x : int = int(i.size.x * i.scale.x)
		var card_offset_y = 0.5*i.size.y*(i.scale.y-1)
		card_sizes_x.append(card_size_x)
		cards_size += card_size_x
		card_offsets_y.append(card_offset_y)
	var spread_size = cards_size + (card_count-1)*SELECT_X_SEP
	#making sure the cards stay in their space!
	if spread_size > select_mat.size.x:
		spread_size = select_mat.size.x
		if card_count > 1:
			spread_sep = (select_mat.size.x - cards_size) / (card_count-1)
	#centering the hand when the cards aren't taking up the whole space
	var centering_offset : float = (select_mat.size.x - spread_size) / 2
	#sending targets to cards
	for i in card_count:
		#obtaining culumative card sizes for offset
		var x_pos : int = 0
		for j in i:
			x_pos += card_sizes_x.get(j)
		#directing cards where to move
		var target_pos : Vector2 = Vector2(centering_offset+player_mat_pos.to_local(select_mat.global_position).x+(x_pos + (spread_sep*i)),(player_mat_pos.to_local(select_mat.global_position).y)-card_offsets_y.get(i)-SELECT_Y_TOTAL_OFFSET)
		selected_cards.get(i).move_target(target_pos,0)

#NOTE: start_pos is GLOBAL POSITION!
func _make_card_display(action_card : ActionCard, start_pos : Vector2) -> ActionCardDisplay:
	var new_display : ActionCardDisplay = card_display_template.instantiate()
	player_mat.add_child(new_display)
	new_display.action_card = action_card
	new_display.global_position = start_pos
	return new_display
#endregion

#region cardinteraction
#please call this ONLY when you're sending a card to the player hand
func _connect_hand_signals(display : ActionCardDisplay):
	display.can_focus = true
	display.can_select = true
	if not display.card_moused.is_connected(_toggle_focus_card):
		display.card_moused.connect(_toggle_focus_card)
	if not display.card_clicked.is_connected(_select_card):
		display.card_clicked.connect(_select_card)

#PLEASE call this BEFORE you send a card to outside player hand!
func _disconnect_hand_signals(display : ActionCardDisplay):
	display.can_focus = false
	display.can_select = false
	display.scale = Vector2.ONE
	if display.card_moused.is_connected(_toggle_focus_card):
		display.card_moused.disconnect(_toggle_focus_card)
	if display.card_clicked.is_connected(_select_card):
		display.card_clicked.disconnect(_select_card)

#for the overall hand movement when the player hovers over a card to enlarge it / stops hovering over it
func _toggle_focus_card():
	for i in player_hand:
		if i.focus:
			i.scale = Vector2(1.5,1.5)
		else:
			i.scale = Vector2.ONE
	_update_hand()

#for when cards are clicked on
func _select_card(display : ActionCardDisplay):
	if display in player_hand:
		select_card(display)
	elif display in selected_cards:
		deselect_cards([display],DESTINATION.HAND)
	else:
		#this literally shouldn't happen, but here's a failsafe nonetheless
		assert(false,"Card selected outside of expected areas")
		display.queue_free()

##using cards, basically
func select_card(selected : ActionCardDisplay):
	if not is_selecting:
		open_select()
		await get_tree().process_frame
	match current_select_mode:
		SELECT_MODE.COMMAND:
			if selected_cards.is_empty():
				_disconnect_hand_signals(selected)
				if not selected.card_clicked.is_connected(_select_card):
					selected.card_clicked.connect(_select_card)
				selected_cards.append(selected)
				player_hand.erase(selected)
				_update_hand()
				_update_select_spread()
				#TODO: insert diceslot filling stuff RIGHT HERE!
				#
			else:
				return #no do thing if thing is full
		SELECT_MODE.DISCARD:
			pass #TODO: for when/if we implement card discard where you select what to discard

##finishing or cancelling the use of cards
func deselect_cards(selected : Array[ActionCardDisplay], destination : DESTINATION) -> void:
	for i : ActionCardDisplay in selected:
		if i in selected_cards: #safety catch!
			match destination:
				DESTINATION.HAND:
					player_hand.append(i)
					_connect_hand_signals(i)
				DESTINATION.DISCARD:
					var new_target : Vector2 = player_mat_pos.to_local(player_discard_mat.global_position)
					i.move_target(new_target,0.0,true)
					player_discard.append(i.action_card)
			selected_cards.erase(i)
	if selected_cards.is_empty():
		close_select()
	_update_select_spread()

##closing up the select gui, MAKE SURE TO RUN THIS BEFORE SWITCHING SELECT MODE!
func close_select() -> void:
	if not selected_cards.is_empty():
		deselect_cards(selected_cards,DESTINATION.DISCARD)
	match current_select_mode:
		SELECT_MODE.COMMAND:
			select_text_label.visible = false
			select_confirm_button.visible = false
		SELECT_MODE.DISCARD:
			pass
	select_container.visible = false
	is_selecting = false

##opening up the select gui, MAKE SURE TO RUN THIS AFTER SWITCHING SELECT MODE!
func open_select() -> void:
	select_container.visible = true
	match current_select_mode:
		SELECT_MODE.COMMAND:
			select_text_label.text = "Place Your Bet"
			select_text_label.visible = true
			select_confirm_button.visible = true
		SELECT_MODE.DISCARD:
			pass
	is_selecting = true

#moving onto the next step of select
func _on_select_confirm_button_pressed() -> void:
	match current_select_mode:
		SELECT_MODE.COMMAND:
			#TODO: add some check for dice slot fill, or something
			selected_cards.get(0).move_target(player_mat_pos.to_local(side_slot_mat.global_position),0.0)
			select_container.visible = false
			command_ready = true

#actually giving the unit the intent
func command_unit(unit : Unit) -> void:
	if command_ready:
		var focus_actions : Array[CardAction] = []
		var selected_actions : Array[CardAction] = selected_cards.get(0).action_card.actions.values()
		for i in selected_actions:
			if i.focus:
				focus_actions.append(i)
		unit.set_intents(focus_actions)
#endregion
