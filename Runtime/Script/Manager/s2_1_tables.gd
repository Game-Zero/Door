extends Node2D

@export var b_game_started = false
@export var speed = 300

@onready var electrocardiogram = $electrocardiogram
@onready var notes = $notes

var _data:Array
var dialog

# 末尾压入值
func que_push(value):
	_data.push_back(value)


# 弹出并返回第一元素值
func que_pop():
	return _data.pop_front()


func que_front():
	return _data.front()


func que_empty():
	return _data.is_empty()


enum KeyType {
	W,
	S,
	A,
	D,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_data = []
	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.size.x = 300
	dialog.dialog_text = "GameOver."
	dialog.title = "提示"
	dialog.get_ok_button().pressed.connect(func():get_tree().reload_current_scene())

	self.start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (not b_game_started):
		return 
		
	electrocardiogram.translate(Vector2(-speed*delta, 0))
	notes.translate(Vector2(-speed*delta, 0))

	var key_type = null
	if (Input.is_action_just_pressed("player_up")):
		key_type = KeyType.W
	if (Input.is_action_just_pressed("player_down")):
		key_type = KeyType.S
	if (Input.is_action_just_pressed("player_left")):
		key_type = KeyType.A
	if (Input.is_action_just_pressed("player_right")):
		key_type = KeyType.D

	if (key_type != null and not que_empty()):
		var node = que_pop()
		if (node.value == key_type):
			node.state = node.KeyState.Perfect
		else:
			node.state = node.KeyState.Missed


func start_game() -> void:
	b_game_started = true
	pass

func on_area_entered(area) -> void:
	print("[on_area_entered] ", area.name)
	que_push(area)
	area.state = area.KeyState.Active


func on_area_exited(area) -> void:
	print("[on_area_exited] ", area.name)
	if (area.state == area.KeyState.Active):
		area.state = area.KeyState.Missed
		que_pop()
	
	if (area == notes.get_child(-1)):
		b_game_started = false
		dialog.popup_centered()
