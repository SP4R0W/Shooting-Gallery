extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	randomize()

	SaveData.load_game()

	Globals.root = self

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(SaveData.settings["master_volume"]/100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(SaveData.settings["music_volume"]/100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear_to_db(SaveData.settings["sfx_volume"]/100))

	ComposerGD.AddScene("MainMenu","res://src/MainMenu/MainMenu.tscn",{
		"instant_load":true,
	})

	ComposerGD.AddScene("LevelSelect","res://src/LevelSelect/LevelSelect.tscn",{
		"instant_load":true,
	})

	ComposerGD.AddScene("Shop","res://src/Shop/Shop.tscn",{
		"instant_load":true,
	})

	ComposerGD.AddScene("Credits","res://src/Credits/Credits.tscn",{
		"instant_load":true,
	})

	ComposerGD.AddScene("Options","res://src/Options/Options.tscn",{
		"instant_load":true,
	})

	ComposerGD.AddScene("DuckGame","res://src/DuckGame/DuckGame.tscn",{
		"instant_load":true,
	})

	ComposerGD.AddScene("TargetGame","res://src/TargetGame/TargetGame.tscn",{
		"instant_load":true,
	})

	ComposerGD.AddScene("GameOver","res://src/GameOver/GameOver.tscn",{
		"instant_load":true,
	})

	await ComposerGD.SceneLoaded

	animation_player.play("FadeOut")

	ComposerGD.CreateScene("MainMenu",{
		"scene_parent":self
	})

func change_scene(scene1, scene2):
	animation_player.play("FadeIn")

	await animation_player.animation_finished

	ComposerGD.RemoveScene(scene1)

	animation_player.play("FadeOut")

	ComposerGD.CreateScene(scene2,{
		"scene_parent":self
	})
