extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var failed_node: Node2D = null
@export var bgm_player: AudioStreamPlayer = null
@export var camera: Camera2D = null

@onready var player = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var rays = [$ray_left, $ray_mid, $ray_right]
@onready var audio_player = $AudioStreamPlayer

var bCanControl = true
var bCanRevertGravity = true
var bGravityEnable = true
var bFatEatenAnimPlayFinished = false
var bPlayerEatPlayFinished = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_direct = 1
var direction = -1
var dialog


func _ready():
	audio_player.stream = load("res://Runtime/Resource/Audio/s3/s3_2/worm_flip_and_hide.MP3")
	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.size.x = 300
	dialog.dialog_text = "GameOver."
	dialog.title = "提示"
	dialog.get_ok_button().pressed.connect(func():get_tree().reload_current_scene())


func _physics_process(delta):
	if (Input.is_action_just_pressed("gm_fail")):
		self.dead(null)

	if !bCanControl:
		return
	
	if bGravityEnable:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * gravity_direct * delta

		# Handle jump.
		if Input.is_action_just_pressed("player_jump") and is_on_floor() and bCanRevertGravity:
			audio_player.play()
			velocity.y += JUMP_VELOCITY * gravity_direct
			gravity_direct *= -1
			scale.y *= -1  
			set_up_direction(Vector2(0, gravity_direct * -1))
	else:
		velocity.y = 0
	#print("gravity: ", gravity, ", velocity.y: ", velocity.y, ", gravity_direct: ", gravity_direct)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x = direction * SPEED
		if direction < 0:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.x != 0:
		animated_sprite_2d.speed_scale = abs(direction)
		animated_sprite_2d.play("swarm_walking")
	else:
		animated_sprite_2d.pause()

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.name.begins_with("fat") || body.name.begins_with("big_fat"):
			bCanControl = false
			if global_position.y != body.global_position.y:
				var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
				var delta_y = 0
				if gravity_direct < 0:
					delta_y = 20
				tween.tween_property(body, "global_position:y", global_position.y - delta_y, 1)
			body.start_being_eaten(direction, self.being_eaten)
			animated_sprite_2d.play("swarm_eating" if body.name.begins_with("fat") else "swarm_eating_big")
		elif body.name.begins_with("robot"):
			body.fade_to_player()
			body.discovered()
			self.dead(body)


func being_eaten():
	bFatEatenAnimPlayFinished = true
	try_resume_contrl()


func dead(robot):
	bCanControl = false
	bgm_player.stop()
	if robot:
		robot.set_physics_process(false)
		robot.anim.play("robot_standing")
	if (failed_node):
		failed_node.global_position.y = camera.global_position.y - 540
		failed_node.show_fail()
	else:
		dialog.popup_centered()


func try_resume_contrl():
	if bFatEatenAnimPlayFinished and bPlayerEatPlayFinished:
		bCanControl = true
		bFatEatenAnimPlayFinished = false
		bPlayerEatPlayFinished = false


func animation_finished():
	if animated_sprite_2d.animation == "swarm_eating" || animated_sprite_2d.animation == "swarm_eating_big":
		bPlayerEatPlayFinished = true
		animated_sprite_2d.animation = "swarm_walking"
		try_resume_contrl()


func get_ray_clliding_robot():
	for ray in rays:
		if ray.is_colliding():
			return ray.get_collider()
	return null
