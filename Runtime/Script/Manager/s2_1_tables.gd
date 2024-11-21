@tool
extends Node2D

@export var b_game_started: bool = false
@export var speed: int = 300
@export var heart_num: int = 0
@export var last_combo_num: int = 999
@export var combo_num: int = 0:
	get = get_combo_num,
	set = set_combo_num


@onready var electrocardiogram = $electrocardiogram
@onready var notes = $notes
@onready var casing = $heart/casing
@onready var heartbeart_figures_list: Array[Variant] = [$heart/heartbeart_figures/second, $heart/heartbeart_figures/first]
@onready var heartbeat_texture_list: Array[CompressedTexture2D ] = [
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
@onready var combo_digital_list: Array[Variant] = [$combo/digital3, $combo/digital2, $combo/digital1]
@onready var combo_digital_texture_list: Array[CompressedTexture2D ] = [
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_0.png"),	# 0
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_1.png"),	# 1
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_2.png"),	# 2
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_3.png"),	# 3
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_4.png"),	# 4
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_5.png"),	# 5
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_6.png"),	# 6
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_7.png"),	# 7
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_8.png"),	# 8
	load("res://Runtime/Resource/Sprite/S2-1_UI_icon/combe_9.png"),	# 9
]
@onready var combo_animation_player_list: Array[Variant] = [$combo/digital3/AnimationPlayer, $combo/digital2/AnimationPlayer, $combo/digital1/AnimationPlayer]
@onready var b_comboing: bool = false
@onready var que: Array
@onready var audio_player = $AudioStreamPlayer2D
@onready var judgment_anim_player = $judgment/AnimationPlayer

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


func get_combo_num() -> int:
	return combo_num


func set_combo_num(value):
	print("[set_combo_num] value: ", value)
	combo_num = value
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_combo_num = 999
	b_comboing = false
	judgment_anim_player.play("RESET")
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
	heartbeart_figures_list[0].texture = heartbeat_texture_list[heart_num % 10]
	heartbeart_figures_list[1].texture = heartbeat_texture_list[(heart_num / 10) % 10]

	var last_combo_num_bits: Array[int] = [last_combo_num % 10, last_combo_num / 10 % 10, last_combo_num / 100 % 10]
	var combo_num_bits: Array[int]      = [combo_num % 10, combo_num / 10 % 10, combo_num / 100 % 10]

	for i in range(0, 3):
		if (last_combo_num_bits[i] != combo_num_bits[i]):
			combo_digital_list[i].texture = combo_digital_texture_list[combo_num_bits[i]]
			var anim_name: String = "digital" + str(3 - i) + "_appeared"
			print("combo_animation_player[", i, "].play: ", anim_name)
			combo_animation_player_list[i].play(anim_name)

	last_combo_num = combo_num

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
				if (note.state == note.KeyState.Perfect):
					judgment_anim_player.play("perfect_appeared")
					set_combo_num(get_combo_num() + 1)
				elif (note.state == note.KeyState.Good):
					judgment_anim_player.play("good_appeared")
					set_combo_num(0)
				else:
					assert(false, "Unkown note state: " + str(note.state))
			else:
				note.state = note.KeyState.Missed
				judgment_anim_player.play("miss_appeared")
				set_combo_num(0)


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
		judgment_anim_player.play("miss_appeared")
		set_combo_num(0)
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


func on_music_play_start(node) -> void:
	print("[on_music_play_start] ", node.name)
	audio_player.play()
