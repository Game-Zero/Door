extends Area2D

var dialog

# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(self.on_body_entered)
	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.size.x = 300
	dialog.dialog_text = "恭喜过关!"
	dialog.title = "提示"
	dialog.get_ok_button().pressed.connect(self._button_pressed)

var cached_body
func on_body_entered(_body):
	cached_body = _body
	if _body.person_type == _body.PersonType.Player:
		_body.do_change_move_state(false)
		dialog.popup_centered()
	else:
		_body.destroy()

func _button_pressed():
	get_tree().reload_current_scene()
	if cached_body != null:
		cached_body.do_change_move_state(true)
