#@tool
extends Node2D

@export var full_heart_num: int = 90
@export var health_heart_num: int = 75
@export var danger_heart_num: int = 55
@export var lose_heart_num: int = 45

@export var add_heart_num_combo_cnt: int = 10
@export var add_heart_num_cnt: int = 2

@export var miss_note_beta: float = 0
@export var good_note_beta: float = 0.6
@export var perfect_note_beta: float = 1

@export var default_heart_line_color: Color = Color8(116, 221,163)
@export var health_heart_line_color: Color = Color8(116, 221, 163)
@export var danger_heart_line_color: Color = Color8(230, 175, 106)
@export var lose_heart_line_color: Color = Color8(203, 63, 44)

@export var default_line_color: Color = Color8(225, 188, 137)

@export var b_game_started: bool = false
@export var speed: int = 300
@export var heart_num: float = full_heart_num # sum(n)
@export var last_combo_num: int = 999
@export var combo_num: int = 0:
	get = get_combo_num,
	set = set_combo_num

@export var cur_note_cnt: int = 0

@onready var electrocardiogram = $electrocardiogram
@onready var notes = $notes
@onready var heart = $heart
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
@onready var timer = $Timer

@onready var note_cnt = $notes.get_child_count()

@onready var vertical_line = $vertical_line
@onready var heart_line_color: Color = default_line_color

@onready var combo = $combo
@onready var fail = $fail
@onready var fail_anim_player = $fail/AnimationPlayer
@onready var fail_again_button = $fail/again
@onready var fail_exit_button = $fail/exit

var game_finish_callback   = null
var reload_tables_callback = null
var b_game_over: bool      = false

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
	for note in notes.get_children():
		if not (note.visible):
			note.free()
	last_combo_num = 999
	b_comboing = false
	b_game_over = false
	fail.visible = false
	judgment_anim_player.play("RESET")
	change_line_color(default_line_color)
	change_heart_line_color(default_heart_line_color)
	var vertical_line_center_position = vertical_line.position + (vertical_line.size * vertical_line.scale / 2)
	var viewport_size = get_viewport().size
	var mask_screen_position_x = vertical_line_center_position.x / viewport_size.x
	var original_material = load("res://Runtime/Shader/electrocardiogram_mask.material")
	for child in electrocardiogram.get_children():
		child.material = original_material.duplicate()
		child.material.set_shader_parameter("modulate_color", heart_line_color)
		child.material.set_shader_parameter("mask_screen_position_x", mask_screen_position_x)

	fail_again_button.pressed.connect(self.on_fail_again_button_press)
	fail_exit_button.pressed.connect(self.on_fail_exit_button_press)

	print("[_ready] note_cnt: ", note_cnt, ", viewport_size: ", viewport_size, ", vertical_line_center_position: ", vertical_line_center_position, ", mask_screen_position_x: ", mask_screen_position_x)
	if Engine.is_editor_hint():
		return

#	self.start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (not b_game_started):
		return

	if not Engine.is_editor_hint():
		electrocardiogram.translate(Vector2(-speed*delta, 0))
		notes.translate(Vector2(-speed*delta, 0))
	
		if (self.b_game_started and Input.is_action_just_pressed("gm_skip")):
			self.on_music_play_end(null)

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
						change_line_color(note.perfect_color)
						add_note(perfect_note_beta)
						judgment_anim_player.play("perfect_appeared")
						set_combo_num(get_combo_num() + 1)
						check_combo()
					elif (note.state == note.KeyState.Good):
						change_line_color(note.good_color)
						add_note(good_note_beta)
						judgment_anim_player.play("good_appeared")
						set_combo_num(get_combo_num() + 1)
						check_combo()
					else:
						assert(false, "Unkown note state: " + str(note.state))
				else:
					note.state = note.KeyState.Missed
					add_note(miss_note_beta)
					judgment_anim_player.play("miss_appeared")
					set_combo_num(0)

	var heart_num_int: int = roundi(heart_num)
	heartbeart_figures_list[0].texture = heartbeat_texture_list[heart_num_int % 10]
	heartbeart_figures_list[1].texture = heartbeat_texture_list[(heart_num_int / 10) % 10]

	var last_combo_num_bits: Array[int] = [last_combo_num % 10, last_combo_num / 10 % 10, last_combo_num / 100 % 10]
	var combo_num_bits: Array[int]      = [combo_num % 10, combo_num / 10 % 10, combo_num / 100 % 10]

	for i in range(0, 3):
		if (last_combo_num_bits[i] != combo_num_bits[i]):
			combo_digital_list[i].texture = combo_digital_texture_list[combo_num_bits[i]]
			var anim_name: String = "digital" + str(3 - i) + "_appeared"
			print("combo_animation_player[", i, "].play: ", anim_name)
			combo_animation_player_list[i].play(anim_name)

	last_combo_num = combo_num

	heart.modulate = heart_line_color
	for child in electrocardiogram.get_children():
		child.material.set_shader_parameter("modulate_color", heart_line_color)

func start_game(game_finish_callback, reload_tables_callback) -> void:
	b_game_started = true
	self.combo.visible = true
	self.game_finish_callback = game_finish_callback
	self.reload_tables_callback = reload_tables_callback


func add_note(beta: float):
	cur_note_cnt = cur_note_cnt + 1
	heart_num = (heart_num * (cur_note_cnt - 1) + beta * full_heart_num) / cur_note_cnt
	heart_num = min(heart_num, full_heart_num)
	if (heart_num >= health_heart_num):
		change_heart_line_color(health_heart_line_color)
	elif (heart_num >= danger_heart_num):
		change_heart_line_color(danger_heart_line_color)
	else:
		change_heart_line_color(lose_heart_line_color)



func check_combo():
	if (get_combo_num() != 0 and (get_combo_num() % add_heart_num_combo_cnt == 0)):
		heart_num = heart_num + add_heart_num_cnt
		heart_num = min(heart_num, full_heart_num)

	
func change_line_color(color: Color):
	vertical_line.modulate = color
	
func change_heart_line_color(color: Color):
	heart_line_color = color
	pass

	
func game_over():
	self.b_game_started = false
	audio_player.stop()
	timer.stop()

	self.b_game_over = true


	var children = self.get_children()
	for child in children:
		if (child.name != "Timer"):
			child.visible = false

	fail.visible = true
	fail_anim_player.play("fail")
	if (game_finish_callback):
		game_finish_callback.call(false)


func on_note_entered_good(note) -> void:
	print("[tables][on_note_entered_good] ", note.name)
	if not (b_game_started):
		return
	que_push(note)
	note.state = note.KeyState.Active
	note.active_state.push_back(note.KeyState.Good)


func on_note_exited_good(note) -> void:
	print("[tables][on_note_exited_good] ", note.name)
	if not (b_game_started):
		return
	if (note.state == note.KeyState.Active):
		note.state = note.KeyState.Missed
		add_note(miss_note_beta)
		judgment_anim_player.play("miss_appeared")
		set_combo_num(0)
		que_pop()

	note.active_state.pop_back()


func on_note_entered_perfect(note) -> void:
	print("[tables][on_note_entered_perfect] ", note.name)
	if not (b_game_started):
		return
	note.active_state.push_back(note.KeyState.Perfect)


func on_note_exited_perfect(note) -> void:
	print("[tables][on_note_exited_perfect] ", note.name)
	if not (b_game_started):
		return
	note.active_state.pop_back()
	change_line_color(default_line_color)


func on_music_play_start(node) -> void:
	print("[tables][on_music_play_start] ", node.name)
	timer.start()
	audio_player.play()


func on_music_play_end(node) -> void:
	if (node != null):
		on_timer_trigger()
	self.b_game_started = false
	audio_player.stop()
	timer.stop()
	if (not self.b_game_over):
		print("[tables][on_music_play_end] 过关.")
		if(game_finish_callback):
			game_finish_callback.call(true)


func on_timer_trigger() -> void:
	print("[tables][on_timer_trigger] ", Time.get_time_string_from_system())
	if (heart_num < lose_heart_num and self.b_game_started):
		self.game_over()
	pass


func on_fail_again_button_press() -> void:
	print("[tables][on_fail_again_button_press]")
	if (self.reload_tables_callback):
		self.reload_tables_callback.call()
	pass


func on_fail_exit_button_press() -> void:
	print("[tables][on_fail_exit_button_press]")
	get_tree().reload_current_scene()
	pass
