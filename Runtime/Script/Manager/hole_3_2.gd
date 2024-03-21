extends Node2D

@onready var ray_left = $ray_left
@onready var ray_mid = $ray_mid
@onready var ray_right = $ray_right

@onready var rays = [ray_left, ray_mid, ray_right]

var player_in_hole = null
var player_origin_global_pos = Vector2(INF, INF)
var bPlayDead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if bPlayDead:
		return

	if player_in_hole != null:
		if Input.is_action_just_pressed("player_fire"):
			var robot = player_in_hole.get_ray_clliding_robot()
			if robot:
				bPlayDead = true
				player_in_hole.dead(robot)
			else:
				player_in_hole.global_position = player_origin_global_pos
				player_in_hole.bGravityEnable = true
				player_in_hole.bCanControl = true
				player_in_hole = null

		return

	for ray in rays:
		if ray.is_colliding():
			var l = ray_left.global_position.x
			var r = ray_right.global_position.x
			var player = ray.get_collider()
			var player_half_size = player.collision_shape.shape.get_rect().size.x / 2
			if l <= player.global_position.x - player_half_size && player.global_position.x + player_half_size <= r:
				if Input.is_action_just_pressed("player_fire"):
					player_in_hole = player
					player_origin_global_pos = player.global_position
					player.global_position = global_position
					player.bGravityEnable = false
					player_in_hole.bCanControl = false
					break
	pass
