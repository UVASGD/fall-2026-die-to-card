
extends Control

@export var drag_layer: Control
@export var destinations: Array[Control] = []

var dragging := false
var drag_offset := Vector2.ZERO

var original_parent: Node
var original_index: int


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_drag()
			accept_event()


func _input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			finish_drag()


func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset


func start_drag() -> void:
	if drag_layer == null or destinations.is_empty():
		push_error("Assign DragLayer and at least one Destination.")
		return

	dragging = true

	original_parent = get_parent()
	original_index = get_index()

	drag_offset = get_global_mouse_position() - global_position

	reparent(drag_layer, true)
	z_index = 100


func finish_drag() -> void:
	dragging = false

	var target_slot: Control = null
	
	for dest in destinations:
		if is_instance_valid(dest):
			if dest.get_global_rect().has_point(get_global_mouse_position()):
				target_slot = dest
				print("Overlapped destination: ", dest.name)
				break

	if target_slot:
		reparent(target_slot, false)
		position = Vector2.ZERO
		z_index = 0
		
	else:
		reparent(original_parent, false)
		print("Could not finding specific slot matched")

		original_parent.move_child(
			self,
			mini(original_index, original_parent.get_child_count() - 1)
		)

		z_index = 0
		print("Element returned to its original position.")
