extends CPUParticles2D

func start():
	emitting = true
	$Timer.start()

func _on_timer_timeout():
	queue_free()
