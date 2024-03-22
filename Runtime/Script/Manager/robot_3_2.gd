extends CharacterBody2D


@export var SPEED = 100 * 20
const STANDIG_TIME = 3

@onready var anim = $AnimatedSprite2D
@onready var ray_to_wall = $ray_to_wall
@onready var ray_not_to_wall = $ray_not_to_wall
@onready var ray_eyes = [$ray_eye_0, $ray_eye_1, $ray_eye_2, $ray_eye_3, $ray_eye_3]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = -1

var state = 0
# 0 向direction方向走
# 1 站立不动

var standing_tot_time = 0
var ray_not_to_wall_tot_time = 0

func _check_eyes_see_player():
	for ray_eye in ray_eyes:
		if ray_eye.is_colliding():
			var collider = ray_eye.get_collider()
			if collider.collision_layer & (1 << 1):
				return collider
	return null

func _physics_process(delta):
	# Add the gravity.

	if not is_on_floor():
		velocity.y += gravity * delta

	var collider_player = _check_eyes_see_player()
	if collider_player != null:
		collider_player.dead(self)
		return

	#print(name, ", ", ray_not_to_wall.is_colliding())

	if ray_not_to_wall.is_colliding():
		ray_not_to_wall_tot_time = 0
	else:
		ray_not_to_wall_tot_time += delta

	if state == 0:
		if ray_to_wall.is_colliding() or is_on_wall() or ray_not_to_wall_tot_time > 0.2:
			state = 1
		else:
			anim.play("robot_walking")
			#print(anim.frame)
			#if 25 <= anim.frame and anim.frame <= 47:
			velocity.x = delta * SPEED * direction
			#else:
				#velocity.x = move_toward(velocity.x, 0, SPEED)
	elif state == 1:
		anim.play("robot_standing")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		standing_tot_time += delta
		if standing_tot_time >= STANDIG_TIME:
			standing_tot_time = 0
			direction *= -1
			state = 0
			scale.x = scale.x * -1
	move_and_slide()
