extends Node2D

var dialog

# Called when the node enters the scene tree for the first time.
func _ready():
	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.size.x = 300
	dialog.dialog_text = "恭喜过关!"
	dialog.title = "提示"
	dialog.get_ok_button().pressed.connect(self._button_pressed)

func body_entered(_body):
	_body.do_change_move_state(false)
	dialog.popup_centered()
	#get_tree().reload_current_scene()

func _button_pressed():
	get_tree().reload_current_scene()
