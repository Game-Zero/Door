extends Node2D
var bHasSurgeryDone: bool = false
var bHasCrossDoor: bool = false
var bCanStartGame: bool = false
var body = null
var doll_anime_arm_origin_z_index = null
var delay_call_queue: Array = []

@onready var camera = $camera
@onready var tables = $tables
@onready var doll_anime_complete = $doll_anime_complete
@onready var doll_anime = $doll_anime
@onready var doll_anime_arm = $doll_anime/arm
@onready var doll_anime_complete_anim_player = $doll_anime_complete/AnimationPlayer
@onready var doll_anime_player = $doll_anime/AnimationPlayer
@onready var b_doll_arm_open_belly_finished: bool = false
@onready var b_protagonist_medium_lie_open_belly_finished: bool = false
@onready var b_doll_arm_suegery_end_finished: bool = false
@onready var b_protagonist_medium_lie_suegery_end_finished: bool = false
@onready var bInDoor: bool = false
@onready var cross_door = $s2_3_cross_door
@onready var cross_door_anim_player = $s2_3_cross_door/AnimationPlayer
@onready var be_thinner = $be_thinner
@onready var be_thinner_anim_player = $be_thinner/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cross_door.visible = false
	doll_anime.visible = false
	doll_anime_complete.visible = true
	cross_door_anim_player.animation_finished.connect(self.goto_next_stage)
	doll_anime_complete_anim_player.animation_finished.connect(self.on_animation_finished)
	doll_anime_player.animation_finished.connect(self.on_animation_finished)
	be_thinner_anim_player.animation_finished.connect(self.on_animation_finished)
	doll_anime_complete_anim_player.play("doll_initial_state_complete")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	while not(delay_call_queue.is_empty()):
		var function = delay_call_queue.pop_front()
		if (function != null):
			function.call()

	if (self.bCanStartGame and Input.is_action_just_pressed("player_fire") and not self.bHasSurgeryDone):
		self.bHasSurgeryDone = true
		body.set_can_move(false)
		body.person_animation_state = body.PersonAnimationState.Standing
		self.body.play_gradually_out()


	if (self.bInDoor and Input.is_action_just_pressed("player_fire") and not self.bHasCrossDoor and body != null):
		if (body.person_state == body.PersonState.Thin):
			self.bHasCrossDoor = true
			body.set_can_move(false)
			body.person_animation_state = body.PersonAnimationState.Standing
			tables.global_position.x = camera.global_position.x - 960
			cross_door.global_position = camera.global_position
			cross_door.visible = true
			cross_door_anim_player.play("s2_3_cross_door")
		else:
			be_thinner.visible = true
			be_thinner_anim_player.play("be_thinner")


func prepare_game() -> void:
	body.set_can_move(false)
	body.person_state = body.PersonState.Medium
	body.person_animation_state = body.PersonAnimationState.Lie
	body.set_global_position(Vector2(1280, 570))
	camera.global_position.x = body.global_position.x


func start_game() -> void:
	tables.global_position.x = camera.global_position.x - 960
	tables.visible = true
	doll_anime.visible = false
	doll_anime_complete.visible = true
	doll_anime_complete_anim_player.play("doll_surgery_ready_complete")


func on_animation_finished(anim_name):
	print("[Stage_2_1][on_animation_finished] anim_name: ", anim_name)
	match (anim_name):
		"doll_surgery_ready_complete":
			doll_anime_complete.visible = false
			doll_anime_arm_origin_z_index = doll_anime_arm.z_index
			doll_anime_arm.z_index = body.z_index + 1
			doll_anime.visible = true
			doll_anime_player.play("doll_arm_open_belly")
			body.person_animation_state = body.PersonAnimationState.LieOpenBelly
		"doll_arm_open_belly":
			self.b_doll_arm_open_belly_finished = true
			self.check_start_game()
		"protagonist_medium_lie_open_belly":
			self.b_protagonist_medium_lie_open_belly_finished = true
			self.check_start_game()
		"doll_arm_suegery_end":
			self.b_doll_arm_suegery_end_finished = true
			doll_anime_arm.z_index = doll_anime_arm_origin_z_index
			self.check_next_game()
		"protagonist_thin_lie_suegery_end":
			self.b_protagonist_medium_lie_suegery_end_finished = true
			self.check_next_game()
		"be_thinner":
			self.be_thinner.visible = false
		"gradully_out":
			if (body.person_state == body.PersonState.Medium):
				self.prepare_game()
			else:
				body.person_animation_state = body.PersonAnimationState.Standing
				body.play_animation()
			self.body.play_gradually_in()
		"gradually_enter":
			if (body.person_state == body.PersonState.Medium):
				start_game()
			else:
				body.turn_on_auto_play()
				body.set_can_move(true)
			pass
	pass

func check_start_game():
	if (self.b_doll_arm_open_belly_finished and self.b_protagonist_medium_lie_open_belly_finished):
		doll_anime_player.play("doll_arm_suegery_cycle")
		body.person_animation_state = body.PersonAnimationState.LieCycle
		tables.start_game(self.on_game_finish, self.on_reload_tables)

func check_next_game():
	if (self.b_doll_arm_suegery_end_finished and self.b_protagonist_medium_lie_suegery_end_finished):
		self.body.play_gradually_out()


func goto_next_stage(anim_name):
	print("[Stage_2_1][goto_next_stage]")
	get_tree().change_scene_to_file("res://Runtime/Scene/Stage_3_1.tscn")
	pass


func on_game_finish(b_success):
	print("[on_game_finish] b_success: ", b_success)
	if (b_success):
		tables.visible = false
		doll_anime_player.play("doll_arm_suegery_end")
		body.turn_off_auto_play()
		body.person_state = body.PersonState.Thin
		body.person_animation_state = body.PersonAnimationState.LieSuegeryEnd
		body.play_animation()
	else:
		doll_anime_arm.z_index = doll_anime_arm_origin_z_index
		doll_anime_player.stop()
		pass


func on_reload_tables():
	self.delay_call_queue.push_back(delay_reload_tables)


func delay_reload_tables():
	var new_node = load("res://Runtime/Prefab/tables.tscn").instantiate()
	new_node.visible = false
	self.add_child(new_node)
	self.move_child(new_node, tables.get_index())
	self.tables.free()
	self.tables = new_node
	self.start_game()


func on_doll_body_entered(body: Node2D) -> void:
	print("[Stage_2_1][on_doll_body_entered] body.name: ", body.name)
	self.body = body
	body.set_animation_finish_callback(self.on_animation_finished)
	self.bCanStartGame = true


func on_doll_body_exit(body: Node2D) -> void:
	print("[Stage_2_1][on_doll_body_exit] body.name: ", body.name)
	self.bCanStartGame = false
	pass


func on_door_body_entered(body: Node2D) -> void:
	print("[Stage_2_1][on_door_body_entered] body.name: ", body.name)
	self.body = body
	self.bInDoor = true

func on_door_body_exit(body: Node2D) -> void:
	self.bInDoor = false
