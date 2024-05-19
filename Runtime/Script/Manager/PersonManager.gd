@tool
extends CharacterBody2D

const SPEED = 300.0

static var npc_can_move = true
static var player_can_move = true

enum PersonType {
	Player = 0,
	NPC1 = 1,
	NPC2 = 2,
	NPC3 = 3,
}

enum PersonState {
	Fat,
	Medium,
}

enum PersonAnimationState {
	Standing,
	Walking,
	LiftingUpCloth,
	BecomingThin,
}

@onready var animation_player = $AnimationPlayer
@export var person_type: PersonType
@export var person_animation_state: PersonAnimationState
@export var person_state: PersonState
@export var b_has_mark = false
@export var b_has_diagnosed = false

var last_played_animation = ""

func play_animation():
	var animation_name = ""
	match (person_type):
		PersonType.Player:
			animation_name = "protagonist_"
		PersonType.NPC1:
			animation_name = "npc1_"
		PersonType.NPC2:
			animation_name = "npc2_"
		PersonType.NPC3:
			animation_name = "npc3_"

	match (person_state):
		PersonState.Fat:
			animation_name += "fat_"
		PersonState.Medium:
			animation_name += "medium_"
	
	match (person_animation_state):
		PersonAnimationState.Standing:
			if (b_has_mark && person_state == PersonState.Fat):
				animation_name += "mark_"
			animation_name += "standing"
		PersonAnimationState.Walking:
			if (b_has_mark && person_state == PersonState.Fat):
				animation_name += "mark_"
			animation_name += "walking"
		PersonAnimationState.LiftingUpCloth:
			animation_name += "cloth"
		PersonAnimationState.BecomingThin:
			animation_name += "becom_thin"

	animation_player.play(animation_name)
	if (last_played_animation != animation_name):
		print("[Person(%s)][play_animation] animation_name: " % name + animation_name)
		last_played_animation = animation_name
	return animation_name

func check_can_move_y():
	var x = global_position.x
	if (1024 <= x && x <= 1152):
		return 1
	elif (1616 <= x && x <= 1760):
		return 1
	elif (2480 <= x && x <= 2608):
		return -1
	elif (3456 <= x && x <= 3568):
		return -1

	return 0

func _physics_process(_delta):
	play_animation()
	if Engine.is_editor_hint():
		return

	if person_type == PersonType.Player && player_can_move:
		var direction = Input.get_axis("ui_left", "ui_right")
		var can_move_y = check_can_move_y()
		if direction:
			velocity.x = direction * SPEED
			velocity.y = direction * can_move_y * SPEED
			person_animation_state = PersonAnimationState.Walking
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			person_animation_state = PersonAnimationState.Standing

		move_and_slide()

func do_lifting_cloth():
	person_animation_state = PersonAnimationState.LiftingUpCloth	

func do_mark():
	b_has_mark = true
	person_animation_state = PersonAnimationState.Standing

func do_diagnose():
	b_has_diagnosed = true
	person_animation_state = PersonAnimationState.Standing

func do_becoming_thin():
	person_animation_state = PersonAnimationState.BecomingThin

func do_change_move_state(b_can_move):
	if not b_can_move:
		person_animation_state = PersonAnimationState.Standing
		
	npc_can_move = b_can_move
	if (person_type == PersonType.Player):
		player_can_move = b_can_move

func _on_animation_player_animation_finished(anim_name):
	print("[Person(%s)][animation_finished]: anim_name == " % name, anim_name)
	if person_animation_state == PersonAnimationState.LiftingUpCloth:
		person_animation_state = PersonAnimationState.Standing
		
	if person_animation_state == PersonAnimationState.BecomingThin:
		person_animation_state = PersonAnimationState.Standing
		person_state = PersonState.Medium

