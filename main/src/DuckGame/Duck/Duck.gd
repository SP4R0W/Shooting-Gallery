class_name Duck
extends Target

func kill():
	if not $AnimationPlayer.is_playing() and not _is_dead:
		show_score_text()

		_is_dead = true
		$AnimationPlayer.play("shot_brown")

		await $AnimationPlayer.animation_finished

		queue_free()
