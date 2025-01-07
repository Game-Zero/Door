extends Node2D
@onready var anim_player = $AnimationPlayer
@export var hud: CanvasLayer


func _ready() -> void:
	hud.b_can_pause = true


func play():
	hud.b_can_pause = false
	anim_player.play("s3_1-2_bridge anime")
	pass


func _on_animation_player_animation_finished(anim_name):
	hud.change_scene_to_file("res://Runtime/Scene/Stage_3_2.tscn")
	pass # Replace with function body.
