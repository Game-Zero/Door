extends Node2D

var dialog
@export var hud: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.size.x = 300
	dialog.dialog_text = "恭喜过关!"
	dialog.title = "提示"
	dialog.get_ok_button().pressed.connect(self._button_pressed)


func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("gm_skip")):
		self.level_success()


func level_success():
	var share_instance: Node = get_node("/root/SharedInstance")
	if share_instance != null and share_instance.shared_data_map.has("s3_1"):
		var data_map = share_instance.shared_data_map["s3_1"]
		data_map["person_state"] = 1
		data_map["b_has_pressed_button"] = true
		data_map["b_has_eaten_medication"] = true
		hud.change_scene_to_file("res://Runtime/Scene/Stage_3_1.tscn")
	else:
		get_tree().reload_current_scene()


func body_entered(body):
	body.bCanControl = false
	body.animated_sprite_2d.stop()
	self.level_success()
	#dialog.popup_centered()
	#get_tree().reload_current_scene()


func _button_pressed():
	hud.reload_current_scene()
