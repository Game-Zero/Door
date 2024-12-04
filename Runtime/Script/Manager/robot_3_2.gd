@tool
extends CharacterBody2D

@export_category("机器人属性设置")

## 机器人移动速度
@export var SPEED = 100 * 20

## 机器人走到地面边缘或产生碰撞后站立时间, 单位: 秒
@export var STANDIG_TIME = 3

## 机器人面前碰撞检测长度
@export var WALL_DISTANCE = 100

## 机器人走到地面边缘检测长度
@export var GROUND_DISTANCE = 20

## 机器人走到地面边缘检测位置
@export_range(-1, 1, 1.0/42) var GROUND_POSITION = -1.0

@onready var anim = $AnimatedSprite2D
@onready var ray_to_wall = $ray_to_wall
@onready var ray_not_to_wall = $ray_not_to_wall
@onready var ray_eyes = [$ray_eye_0, $ray_eye_1, $ray_eye_2, $ray_eye_3, $ray_eye_3]
@onready var audio_player = $AudioStreamPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = -1

var state = 0
# 0 向direction方向走
# 1 站立不动

var standing_tot_time = 0
var ray_not_to_wall_tot_time = 0
var player

func _ready():
	ray_to_wall.target_position.y = WALL_DISTANCE
	ray_not_to_wall.target_position.y = GROUND_DISTANCE
	ray_not_to_wall.position.x = 42 * GROUND_POSITION
	direction = -1
	state = 0
	player = get_node_or_null("/root/Root/player")
	audio_player.stream = load("res://Runtime/Resource/Audio/s3/s3_2/robot_walking.MP3")

func _process(delta):
	if Engine.is_editor_hint():
		ray_to_wall.target_position.y = WALL_DISTANCE
		ray_not_to_wall.target_position.y = GROUND_DISTANCE
		ray_not_to_wall.position.x = 42 * GROUND_POSITION


func _check_eyes_see_player():
	for ray_eye in ray_eyes:
		if ray_eye.is_colliding():
			var collider = ray_eye.get_collider()
			if collider.collision_layer & (1 << 1):
				return collider
	return null


func discovered():
	$discovered/AnimationPlayer.play("discovered")


func fade_to_player():
	if not (_check_eyes_see_player()):
		scale.x = scale.x * -1
		direction *= -1


func _physics_process(delta):
	# Add the gravity.

	if Engine.is_editor_hint():
		return

	if audio_player.playing and player != null:
		var distance = abs(player.global_position.distance_to(global_position))
		
		# 如果距离小于 10，则将音量设置为最大值
		if distance < 10: 
			distance = 0
		
		# 设置音量
		audio_player.volume_db = -60.0 / 1000 * distance # 根据距离设置音量


	if not is_on_floor():
		velocity.y += gravity * delta

	var collider_player = _check_eyes_see_player()
	if collider_player != null:
		self.discovered()
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
			if not audio_player.playing:
				audio_player.play(0)
			anim.play("robot_walking")
			#print(anim.frame)
			#if 25 <= anim.frame and anim.frame <= 47:
			velocity.x = delta * SPEED * direction
			#else:
				#velocity.x = move_toward(velocity.x, 0, SPEED)
	elif state == 1:
		audio_player.stop()
		anim.play("robot_standing")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		standing_tot_time += delta
		if standing_tot_time >= STANDIG_TIME:
			standing_tot_time = 0
			direction *= -1
			state = 0
			scale.x = scale.x * -1
	move_and_slide()
