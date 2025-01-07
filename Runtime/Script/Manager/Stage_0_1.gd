extends Node2D

@onready var cross_door_part1 = $s0_1_cross_door
@onready var cross_door_part1_anim_player = $s0_1_cross_door/AnimationPlayer
@onready var cross_door_part2 = $s0_1_cross_door_part2
@onready var cross_door_part2_anim_player = $s0_1_cross_door_part2/AnimationPlayer
@onready var door_light = $door_light
@export var hud: CanvasLayer

@export var camera: Camera2D = null

var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.b_can_pause = true
	cross_door_part1_anim_player.animation_finished.connect(self.on_animation_finish)
	cross_door_part2_anim_player.animation_finished.connect(self.on_animation_finish)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("player_fire") and player and player.is_can_move()):
		player.set_can_move(false)
		cross_door_part1.global_position = camera.global_position
		cross_door_part2.global_position = camera.global_position
		cross_door_part1.visible = true
		hud.b_can_pause = false
		cross_door_part1_anim_player.play("part1")
		pass


func on_animation_finish(anim_name: String):
	print("[Stage_0_1][on_animation_finish] anim_name: ", anim_name)
	match(anim_name):
		"part1":
			cross_door_part1_anim_player.stop()
			cross_door_part1.visible = false
			cross_door_part2.visible = true
			cross_door_part2_anim_player.play("part2")
		"part2":
			hud.change_scene_to_file("res://Runtime/Scene/Stage_1_1.tscn")
			pass


func on_body_entered(body):
	self.player = body
	self.door_light.visible = true
	print("[Stage_0_1][on_body_entered] body.name: ", body.name)
	pass


func on_body_exited(body):
	self.player = null
	self.door_light.visible = false
	print("[Stage_0_1][on_body_exited] body.name: ", body.name)
	pass
