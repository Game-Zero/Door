extends Node2D

@onready var ray_left = $ray_left
@onready var ray_mid = $ray_mid
@onready var ray_right = $ray_right

@onready var rays = [ray_left, ray_mid, ray_right]
@onready var audio_player = $AudioStreamPlayer

var delta_y = -105

var player_in_hole = null
var bPlayDead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_player.stream = load("res://Runtime/Resource/Audio/s3/s3_2/worm_flip_and_hide.MP3")
	delta_y *= scale.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if bPlayDead:
		return

	if player_in_hole != null:
		if Input.is_action_just_pressed("player_fire") and player_in_hole.bCanControl:
			audio_player.play()
			var robot = player_in_hole.get_ray_clliding_robot()
			if robot:
				bPlayDead = true
				player_in_hole.dead(robot)
			else:
				player_in_hole.global_position.y += delta_y
				delta_y *= -1
				player_in_hole.bGravityEnable = true
				player_in_hole.bCanRevertGravity = true
				player_in_hole = null

		return

	for ray in rays:
		if ray.is_colliding():
			var l = ray_left.global_position.x
			var r = ray_right.global_position.x
			var player = ray.get_collider()
			var player_half_size = player.collision_shape.shape.get_rect().size.x / 2
			if l < player.global_position.x - player_half_size && player.global_position.x + player_half_size < r:
				if Input.is_action_just_pressed("player_fire") and player.bCanControl:
					audio_player.play()
					player_in_hole = player
					player.global_position.y += delta_y
					delta_y *= -1
					player.bGravityEnable = false
					player_in_hole.bCanRevertGravity = false
					break

