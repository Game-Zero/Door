extends Node2D

@onready var again_button = $again
@onready var exit_button = $exit
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	again_button.pressed.connect(self.on_again_pressed)
	exit_button.pressed.connect(self.on_exit_pressed)
	pass # Replace with function body.


func show_fail():
	self.visible = true
	animation_player.play("s3_2_fail")


func on_again_pressed():
	get_tree().reload_current_scene()
	

func on_exit_pressed():
	var share_instance = get_node("/root/SharedInstance")
	var data_map = share_instance.shared_data_map["s3_1"]
	data_map["person_state"] = 0
	data_map["b_has_pressed_button"] = true
	data_map["b_has_eaten_medication"] = false
	get_tree().change_scene_to_file("res://Runtime/Scene/Stage_3_1.tscn")
