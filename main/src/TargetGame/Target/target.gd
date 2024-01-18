class_name GameTarget
extends Target

@onready var target_animator: AnimationPlayer = $AnimationPlayer

const TYPE_TEXTURES = {
	"red1":"res://assets/Objects/target_red1_outline.png",
	"red2":"res://assets/Objects/target_red2_outline.png",
	"red3":"res://assets/Objects/target_red3_outline.png",
	"white":"res://assets/Objects/target_white_outline.png",
	"color":"res://assets/Objects/target_colored_outline.png",
}

var type = "red1"
var spawn_type = "fade"

func set_type(num: int):
	match num:
		1:
			kill_score = 10
			type = "red1"
		2:
			kill_score = 20
			type = "red2"
		3:
			kill_score = 35
			type = "red3"
		4:
			kill_score = 75
			type = "white"
		5:
			kill_score = 125
			type = "color"

	$AnimatedSprite2D.animation = type
	$CPUParticles2D.texture = load(TYPE_TEXTURES[type])

func spawn_static():
	if target_animator == null:
		await ready

	is_static = true
	target_animator.play("Show_" + type)
	spawn_type = "static"

	await target_animator.animation_finished
	$GoneTimer.start()

func spawn_static_fade():
	if target_animator == null:
		await ready

	is_static = true
	target_animator.play("FadeIn")
	spawn_type = "fade"

	await target_animator.animation_finished
	$GoneTimer.start()

func spawn_normal():
	if target_animator == null:
		await ready

	target_animator.play("FadeIn")
	spawn_type = "fade"

func enemy_gone():
	match spawn_type:
		"fade":
			target_animator.play("FadeOut")
		"static":
			target_animator.play("Hide")

	await target_animator.animation_finished

	_is_dead = true

	Globals.active_script.enemy_killed()

	queue_free()

func kill(quiet_kill: bool = false):
	if not _is_dead:
		$GoneTimer.stop()
		killed.emit(self)

		_is_dead = true
		$break.play()

		hide()

		speed = 0

		$CPUParticles2D.emitting = true

		if !quiet_kill: show_score_text()

		await get_tree().create_timer(0.5).timeout

		queue_free()
