@tool
extends CharacterBody2D

const SPEED = 300.0

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
			animation_name += "standing"
		PersonAnimationState.Walking:
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
	
func _physics_process(delta):
	if Engine.is_editor_hint():
		play_animation()
		return
		
	if person_type == PersonType.Player:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
