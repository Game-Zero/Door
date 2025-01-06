extends Node2D


var arr: Array[Variant]  = [[0, 0], [0, 1], [1, 1], [2, 1], [3, 1], [3, 2], [4, 1]]
var b_loaded: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func load_all_scene() -> void:
	print("[SceneLoader] start load scene ...")
	var share_instance: Node = get_node("/root/SharedInstance")
	share_instance.shared_data_map["maps"] = {}
	share_instance.shared_data_map["maps_size"] = arr.size()
	for stage in arr:
		var path: String = "res://Runtime/Scene/Stage_%d_%d.tscn" % stage
		print("[SceneLoader] start load: " + path)
		ResourceLoader.load_threaded_request(path)
	get_node("loading").visible = true
	get_node("press").visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for stage in arr:
		var path: String = "res://Runtime/Scene/Stage_%d_%d.tscn" % stage
		if (b_loaded.has(path)):
			continue
		var progress: Array[Variant] = []
		var status: int              = ResourceLoader.load_threaded_get_status(path, progress)
		if (status == ResourceLoader.THREAD_LOAD_LOADED and progress[0] == 1):
			print("[SceneLoader] load finish: " + path, ", progress: ", progress[0], ", status: ", status)
			b_loaded[path] = true
			var share_instance: Node = get_node("/root/SharedInstance")
			var maps = share_instance.shared_data_map["maps"]
			maps[path] = ResourceLoader.load_threaded_get(path)
		pass
	pass

	if (b_loaded.size() == arr.size()):
		var share_instance: Node = get_node("/root/SharedInstance")
		var maps = share_instance.shared_data_map["maps"]
		get_tree().change_scene_to_packed(maps["res://Runtime/Scene/Stage_0_1.tscn"])
		pass

func open_operation():
	get_node("./HUD/options/AnimationPlayer").play("options_appear")
