extends Node2D

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var bg = $Background

@onready var master_label: Label = $CanvasLayer/Control/VBoxContainer/Master/Label
@onready var music_label: Label = $CanvasLayer/Control/VBoxContainer/Music/Label
@onready var sfx_label: Label = $CanvasLayer/Control/VBoxContainer/SFX/Label
@onready var auto_label: Label = $CanvasLayer/Control/VBoxContainer/AutoReload/Label

@onready var master_slider: HSlider = $CanvasLayer/Control/VBoxContainer/Master/MasterSlider
@onready var music_slider: HSlider = $CanvasLayer/Control/VBoxContainer/Music/MusicSlider
@onready var sfx_slider: HSlider = $CanvasLayer/Control/VBoxContainer/SFX/SfxSlider

@onready var is_transitioning = true

var onoff_text: Dictionary = {
	true:"on",
	false:"off"
}

func _ready():
	master_slider.value = SaveData.settings["master_volume"]
	music_slider.value = SaveData.settings["music_volume"]
	sfx_slider.value = SaveData.settings["sfx_volume"]

	master_label.text = "Master Volume: " + str(master_slider.value)
	music_label.text = "Music Volume: " + str(music_slider.value)
	sfx_label.text = "SFX Volume: " + str(sfx_slider.value)
	auto_label.text = "Auto Reload: " + onoff_text[SaveData.settings["auto_reload"]]

	bg.play_animation = false

	animator.play("CurtainUp")

	await animator.animation_finished

	is_transitioning = false
	bg.play_animation = true

func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed() \
	and animator.is_playing():
		animator.seek(2)
		animator.animation_finished.emit()

func _on_back_button_pressed():
	if is_transitioning:
		return

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Composer.goto_scene("res://src/MainMenu/MainMenu.tscn",{"is_animated":true,"animation":1})


func _on_master_slider_drag_ended(value_changed):
	if not value_changed:
		return

	SaveData.settings["master_volume"] = master_slider.value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(SaveData.settings["master_volume"]/100))
	master_label.text = "Master Volume: " + str(master_slider.value)


func _on_music_slider_drag_ended(value_changed):
	if not value_changed:
		return

	SaveData.settings["music_volume"] = music_slider.value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(SaveData.settings["music_volume"]/100))
	music_label.text = "Music Volume: " + str(music_slider.value)


func _on_sfx_slider_drag_ended(value_changed):
	if not value_changed:
		return

	SaveData.settings["sfx_volume"] = sfx_slider.value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear_to_db(SaveData.settings["sfx_volume"]/100))
	sfx_label.text = "SFX Volume: " + str(sfx_slider.value)

func _on_auto_reload_pressed():
	SaveData.settings["auto_reload"] = !SaveData.settings["auto_reload"]

	auto_label.text = "Auto Reload: " + onoff_text[SaveData.settings["auto_reload"]]

