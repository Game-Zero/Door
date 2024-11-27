extends CharacterBody2D

@export var speed = 300.0

enum PersonAnimationState {
	Standing,
	Walking,
}

@onready var animation_player = $AnimationPlayer
@export var person_animation_state: PersonAnimationState
@export var camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func play_animation():
	var animation_name = "protagonist_thinner_"
	match (person_animation_state):
		PersonAnimationState.Standing:
			animation_name += "standing"
		PersonAnimationState.Walking:
			animation_name += "walking"

	if animation_player != null and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	play_animation()
	if Engine.is_editor_hint() or !get_parent().visible:
		return

	var direction = Input.get_axis("player_left", "player_right")
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

	var x = global_position.x
	if camera and 960 <= x and x <= 2132:
		#var tween: Tween = get_tree().create_tween()
		#tween.set_trans(Tween.TRANS_QUAD) # warning-ignore:return_value_discarded
		#tween.tween_property(camera, "global_position:x", x, 0.1)
		camera.global_position.x = x
