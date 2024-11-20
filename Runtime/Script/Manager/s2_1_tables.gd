@tool
extends Node2D

@export var b_game_started = false
@export var speed = 300
@export var heart_num = 0

@onready var electrocardiogram = $electrocardiogram
@onready var notes = $notes
@onready var casing = $heart/casing
@onready var heartbeart_figures_list = [$heart/heartbeart_figures/second, $heart/heartbeart_figures/first]
@onready var texture_list = [
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_0.png"),	# 0
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_1.png"),	# 1
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_2.png"),	# 2
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_3.png"),	# 3
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_4.png"),	# 4
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_5.png"),	# 5
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_6.png"),	# 6
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_7.png"),	# 7
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_8.png"),	# 8
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/heartbeat_9.png"),	# 9
]

@onready var que: Array

var dialog

# 末尾压入值
func que_push(value):
	que.push_back(value)


# 弹出并返回第一元素值
func que_pop():
	return que.pop_front()


func que_front():
	return que.front()


func que_empty():
	return que.is_empty()


enum KeyType {
	W,
	S,
	A,
	D,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.size.x = 300
	dialog.dialog_text = "GameOver."
	dialog.title = "提示"
	dialog.get_ok_button().pressed.connect(func():get_tree().reload_current_scene())

	self.start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	heartbeart_figures_list[0].texture = texture_list[heart_num % 10]
	heartbeart_figures_list[1].texture = texture_list[(heart_num / 10) % 10]

	if Engine.is_editor_hint():
		return

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
		var note = que_pop()
		if (note.state == note.KeyState.Active):
			if (note.value == key_type):
				note.state = note.active_state.back()
			else:
				note.state = note.KeyState.Missed


func start_game() -> void:
	b_game_started = true
	pass


func on_note_entered_good(note) -> void:
	print("[on_note_entered_good] ", note.name)
	que_push(note)
	note.state = note.KeyState.Active
	note.active_state.push_back(note.KeyState.Good)
	pass


func on_note_exited_good(note) -> void:
	print("[on_note_exited_good] ", note.name)
	if (note.state == note.KeyState.Active):
		note.state = note.KeyState.Missed
		que_pop()

	if (note == notes.get_child(-1)):
		b_game_started = false
		dialog.popup_centered()

	note.active_state.pop_back()
	pass


func on_note_entered_perfect(note) -> void:
	print("[on_note_entered_perfect] ", note.name)
	note.active_state.push_back(note.KeyState.Perfect)

	pass


func on_note_exited_perfect(note) -> void:
	print("[on_note_exited_perfect] ", note.name)
	note.active_state.pop_back()

	pass
