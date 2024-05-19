#@tool
extends Node2D

enum NurseType {
	Type1 = 1,
	Type2 = 2,
}

enum NurseState {
	Standing,
	Acting,
}

@export var nurse_type: NurseType = NurseType.Type1
@export var nurse_state: NurseState = NurseState.Standing
@onready var animation_player = $AnimationPlayer

func play_animation():
	var anim_name = ""
	match(nurse_type):
		NurseType.Type1:
			anim_name = "nurse1_animation"
		NurseType.Type2:
			anim_name = "nurse2_arm_anime"
	
	if (nurse_state == NurseState.Standing):
		animation_player.play(anim_name)
		animation_player.stop()
	else:
		animation_player.play(anim_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	play_animation()
	pass
