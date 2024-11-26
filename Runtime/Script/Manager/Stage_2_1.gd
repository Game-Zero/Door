extends Node2D
var bHasSurgeryDone: bool = false
var bCanStartGame: bool = false
var body = null

@onready var camera = $camera
@onready var tables = $tables
@onready var doll_anime_complete = $doll_anime_complete
@onready var doll_anime = $doll_anime
@onready var doll_anime_complete_anim_player = $doll_anime_complete/AnimationPlayer
@onready var doll_anime_player = $doll_anime/AnimationPlayer
@onready var b_doll_arm_open_belly_finished: bool = false
@onready var b_protagonist_medium_lie_open_belly_finished: bool = false
@onready var b_doll_arm_suegery_end_finished: bool = false
@onready var b_protagonist_medium_lie_suegery_end_finished: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	doll_anime.visible = false
	doll_anime_complete.visible = true
	doll_anime_complete_anim_player.animation_finished.connect(self.on_animation_finished)
	doll_anime_player.animation_finished.connect(self.on_animation_finished)
	doll_anime_complete_anim_player.play("doll_initial_state_complete")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (self.bCanStartGame and Input.is_action_just_pressed("player_fire") and not self.bHasSurgeryDone):
		self.bHasSurgeryDone = true
		start_game()


func start_game() -> void:
	body.set_can_move(false)
	body.person_state = body.PersonState.Medium
	body.person_animation_state = body.PersonAnimationState.Lie
	body.set_global_position(Vector2(1280, 570))
	body.set_animation_finish_callback(self.on_animation_finished)
	tables.global_position.x = camera.global_position.x - 960
	tables.visible = true
	doll_anime_complete_anim_player.play("doll_surgery_ready_complete")

func on_animation_finished(anim_name):
	print("[Stage_2_1][on_animation_finished] anim_name: ", anim_name)
	match (anim_name):
		"doll_surgery_ready_complete":
			doll_anime_complete.visible = false
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
			self.check_next_game()
		"protagonist_medium_lie_suegery_end":
			self.b_protagonist_medium_lie_suegery_end_finished = true
			self.check_next_game()
			pass
	pass

func check_start_game():
	if (self.b_doll_arm_open_belly_finished and self.b_protagonist_medium_lie_open_belly_finished):
		doll_anime_player.play("doll_arm_suegery_cycle")
		body.person_animation_state = body.PersonAnimationState.LieCycle
		tables.start_game(self.on_game_finish)

func check_next_game():
	if (self.b_doll_arm_suegery_end_finished and self.b_protagonist_medium_lie_suegery_end_finished):
		body.person_animation_state = body.PersonAnimationState.Standing
		body.person_state = body.PersonState.Thin
		body.set_can_move(true)


func on_game_finish(b_success):
	print("[on_game_finish] b_success: ", b_success)
	if (b_success):
		tables.visible = false
		doll_anime_player.play("doll_arm_suegery_end")
		body.person_animation_state = body.PersonAnimationState.LieSuegeryEnd
	else:
		doll_anime_player.stop()
		pass

func on_doll_body_entered(body: Node2D) -> void:
	print("[Stage_2_1][on_doll_body_entered] body.name: ", body.name)
	self.body = body
	self.bCanStartGame = true


func on_doll_body_exit(body: Node2D) -> void:
	print("[Stage_2_1][on_doll_body_exit] body.name: ", body.name)
	self.bCanStartGame = false
	pass


func on_door_body_entered(body: Node2D) -> void:
	print("[Stage_2_1][on_door_body_entered] body.name: ", body.name)
	self.body = body
