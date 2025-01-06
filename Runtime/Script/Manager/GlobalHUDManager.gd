extends CanvasLayer

var b_can_pause: bool = true
var b_is_pausing: bool = false:
	get = is_pausing
var async_scene_resource_path: String = ""

func change_scene_to_file(scene_resource_path: String):
	var share_instance: Node = get_node("/root/SharedInstance")
	var maps = share_instance.shared_data_map["maps"]
	var maps_size = share_instance.shared_data_map["maps_size"]

	if (maps.has(scene_resource_path)):
		var packed_scene = maps[scene_resource_path]
		async_scene_resource_path = ""
		assert(packed_scene != null)
		get_tree().change_scene_to_packed(packed_scene)
	else:
		async_scene_resource_path = scene_resource_path


func reload_current_scene():
	get_tree().reload_current_scene()


func quit_scene():
	get_tree().quit()


func is_pausing() -> bool:
	return get_node("esc").visible or get_node("options").visible or get_node("select_controller").visible


# Called when the node enters the scene tree for the first time.
func _ready():
	print("[hud][current_scene.scene_file_path]", get_tree().current_scene.scene_file_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (async_scene_resource_path != null and async_scene_resource_path != ""):
		var share_instance: Node = get_node("/root/SharedInstance")
		var maps = share_instance.shared_data_map["maps"]
		if (maps.has(async_scene_resource_path)):
			var packed_scene = maps[async_scene_resource_path]
			async_scene_resource_path = ""
			get_tree().change_scene_to_packed(packed_scene)

	if (get_tree()):
		var paths: PackedStringArray = get_tree().current_scene.scene_file_path.split("/")
		var scene_file_name: String = paths[paths.size() - 1]

		if (scene_file_name.begins_with("Stage_0_0")):
			return

		if Input.is_action_pressed("ui_cancel") and b_can_pause:
			get_node("esc").get_node("AnimationPlayer").play("pause_appear")

		if Input.is_action_pressed("gm_reload_current_scene"):
			self.reload_current_scene()
