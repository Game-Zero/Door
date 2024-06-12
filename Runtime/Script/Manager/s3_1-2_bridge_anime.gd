extends Node2D
@onready var anim_player = $AnimationPlayer

func play():
	anim_player.play("s3_1-2_bridge anime")
	pass

func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://Runtime/Scene/Stage_3_2.tscn")
	pass # Replace with function body.
