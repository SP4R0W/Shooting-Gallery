extends Node2D

func _ready() -> void:
	randomize()

	Globals.root = self

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(SaveData.settings["master_volume"]/100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(SaveData.settings["music_volume"]/100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear_to_db(SaveData.settings["sfx_volume"]/100))

	Composer.goto_scene("res://src/MainMenu/MainMenu.tscn",{"is_animated":true,"animation":1})
