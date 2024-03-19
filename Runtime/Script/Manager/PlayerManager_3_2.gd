extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var player = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var dialog = $AcceptDialog

var bCanControl = true
var bFatEatenAnimPlayFinished = false
var bPlayerEatPlayFinished = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_direct = 1

func _physics_process(delta):
	if !bCanControl:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * gravity_direct * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y += JUMP_VELOCITY * gravity_direct
		gravity_direct *= -1
		animated_sprite_2d.flip_v = !animated_sprite_2d.flip_v
		set_up_direction(Vector2(0, gravity_direct * -1))

	#print("gravity: ", gravity, ", velocity.y: ", velocity.y, ", gravity_direct: ", gravity_direct)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if direction < 0:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.x != 0:
		animated_sprite_2d.play("swarm_walking")
	else:
		animated_sprite_2d.pause()

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.name.begins_with("fat"):
			bCanControl = false
			var callback = func():
				bFatEatenAnimPlayFinished = true
				try_resume_contrl()
			body.start_being_eaten(direction, callback)
			animated_sprite_2d.play("swarm_eating")

func try_resume_contrl():
	if bFatEatenAnimPlayFinished and bPlayerEatPlayFinished:
		bCanControl = true
		bFatEatenAnimPlayFinished = false
		bPlayerEatPlayFinished = false

func animation_finished():
	if animated_sprite_2d.animation == "swarm_eating":
		bPlayerEatPlayFinished = true
		animated_sprite_2d.animation = "swarm_walking"
		try_resume_contrl()

