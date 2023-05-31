extends Node

@onready var current_scene: Node2D = null
@onready var is_entering_scene: bool = false

enum ANIMATIONS {
	NONE=0,
	FADE=1
}

func goto_scene(scene: String,args: Dictionary = {}) -> void:
	if is_entering_scene:
		return

	is_entering_scene = true
	call_deferred("deffered_goto_scene",scene,args)

func deffered_goto_scene(scene: String,args: Dictionary = {}) -> void:
	var is_animated: bool = args["is_animated"] if args.has("is_animated") else false
	var animation_value: int = args["animation"] if args.has("animation") else 0

	var control: Control = Globals.root.get_node("CanvasLayer/Control")
	control.show()

	if not is_animated:
		if current_scene != null:
			Globals.root.get_node(NodePath(current_scene.name)).queue_free()

		var new_scene: PackedScene = load(scene)
		Globals.root.add_child(new_scene.instantiate())

	elif is_animated && animation_value == ANIMATIONS.FADE:
		var transition_rect: ColorRect = control.get_node("TransitionRect")
		transition_rect.show()
		transition_rect.color = Color(0,0,0,1)

		if current_scene != null:
			var fade_in_tween: Tween = get_tree().create_tween()
			var fade_in_duration: float = args["fade_in_duration"] if args.has("fade_in_duration") else 0.5

			transition_rect.color = Color(0,0,0,0)

			fade_in_tween.tween_property(transition_rect,"color",Color(0,0,0,1),fade_in_duration)

			await fade_in_tween.finished

			fade_in_tween.kill()
			Globals.root.get_node(NodePath(current_scene.name)).queue_free()

		var new_scene: PackedScene = load(scene)
		Globals.root.add_child(new_scene.instantiate())

		var fade_out_tween: Tween = get_tree().create_tween()
		var fade_out_duration: float = args["fade_out_duration"] if args.has("fade_out_duration") else 0.5

		fade_out_tween.tween_property(transition_rect,"color",Color(0,0,0,0),fade_out_duration)

		await fade_out_tween.finished

		transition_rect.hide()

	current_scene = Globals.root.get_child(Globals.root.get_child_count() - 1)

	control.hide()
	is_entering_scene = false
