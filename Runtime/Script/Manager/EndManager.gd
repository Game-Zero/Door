@tool
extends Node2D

enum EndAnimationState {
	End1,
	End2Top,
	End2Base,
	End31,
	End32,
}

@export var end_animation_state: EndAnimationState
var last_played_animation = ""
@onready var animation_player = $AnimationPlayer

func play_animation():
	var animation_name = ""
	match (end_animation_state):
		EndAnimationState.End1:
			animation_name = "end1"
		EndAnimationState.End2Top:
			animation_name = "end2_top"
		EndAnimationState.End2Base:
			animation_name = "end2_base"
		EndAnimationState.End31:
			animation_name = "end3_1"
		EndAnimationState.End32:
			animation_name = "end3_2"

	if animation_player != null and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

	if (last_played_animation != animation_name):
		print("[Person(%s)][play_animation] animation_name: " % name + animation_name)
		last_played_animation = animation_name
	return animation_name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	play_animation()


