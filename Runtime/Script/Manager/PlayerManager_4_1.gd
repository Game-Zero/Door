@tool
extends CharacterBody2D

@export var speed: float = 300.0

enum PersonAnimationState {
	Standing,
	Walking,
	Lie,
	LieCycle,
	LieOpenBelly,
	LieSuegeryEnd,
}

enum PersonState {
	Medium,
	Thin,
}

@onready var animation_player = $AnimationPlayer
@onready var gradually_player = $gradually
@export var person_animation_state: PersonAnimationState = PersonAnimationState.Standing
@export var person_state: PersonState = PersonState.Medium
@export var camera: Camera2D
@export var b_can_move: bool = true

@onready var animation_finish_callback = null
@onready var last_animation_name: String = ""
@onready var auto_play: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	b_can_move = true
	animation_player.animation_finished.connect(on_animation_finish)
	gradually_player.animation_finished.connect(on_animation_finish)
	pass
	
func set_can_move(can_move: bool) -> bool:
	self.b_can_move = can_move
	if (not can_move and transform.x.x < 0):
		transform.x.x *= -1
	return self.b_can_move

func get_can_move() -> bool:
	return self.b_can_move


func play_gradually_in():
	self.gradually_player.play("gradually_enter")


func play_gradually_out():
	self.gradually_player.play("gradully_out")


func turn_off_auto_play():
	auto_play = false


func turn_on_auto_play():
	auto_play = true


func play_animation():
	var animation_name: String = "protagonist_"
	match (person_state):
		PersonState.Medium:
			animation_name += "medium_"
		PersonState.Thin:
			animation_name += "thin_"

	match (person_animation_state):
		PersonAnimationState.Standing:
			animation_name += "standing"
		PersonAnimationState.Walking:
			animation_name += "walking"
		PersonAnimationState.Lie:
			animation_name += "lie"
		PersonAnimationState.LieCycle:
			animation_name += "lie_cycle"
		PersonAnimationState.LieOpenBelly:
			animation_name += "lie_open_belly"
		PersonAnimationState.LieSuegeryEnd:
			animation_name += "lie_suegery_end"

	if animation_player != null and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	if (self.auto_play):
		play_animation()
	if Engine.is_editor_hint() or !get_parent().visible:
		return

	if (not self.b_can_move):
		return

	var direction: float = Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x = direction * speed
		person_animation_state = PersonAnimationState.Walking

		if velocity.x * transform.x.x < 0:
			transform.x.x *= -1
	else:
		if transform.x.x < 0:
			transform.x.x *= -1
		velocity.x = move_toward(velocity.x, 0, speed)
		if person_animation_state == PersonAnimationState.Walking:
			person_animation_state = PersonAnimationState.Standing

	move_and_slide()

	var x: float = global_position.x
	if camera and 960 <= x and x <= 2115:
		#var tween: Tween = get_tree().create_tween()
		#tween.set_trans(Tween.TRANS_QUAD) # warning-ignore:return_value_discarded
		#tween.tween_property(camera, "global_position:x", x, 0.1)
		camera.global_position.x = x

func set_animation_finish_callback(animation_finish_callback):
	self.animation_finish_callback = animation_finish_callback


func on_animation_finish(anim_name):
	print("[PlayerManager_4_1][on_animation_finish] anim_name: ", anim_name)
	if (self.animation_finish_callback != null):
		animation_finish_callback.call(anim_name)
	pass
