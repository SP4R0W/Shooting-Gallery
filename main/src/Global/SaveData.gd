extends Node

@onready var settings: Dictionary = {
	"master_volume": 100,
	"music_volume": 100,
	"sfx_volume": 100,
	"auto_reload":true
}

@onready var stats: Dictionary = {
	"money":0,
	"upgrade_reload":0,
	"upgrade_mag":0,
	"upgrade_firerate":0,

	"duck_hi":0,
	"duck_rank":"NONE",
	"duck_ta_hi":0,
	"duck_ta_rank":"NONE",

	"target_hi":0,
	"target_rank":"NONE",
	"target_ta_hi":0,
	"target_ta_rank":"NONE",
}

const FILE_PATH = "user://save_data.save"

func _get_save_dict() -> Dictionary:
	return {
		"settings":settings,
		"stats":stats
	}

func _get_empty_save() -> Dictionary:
	return {
		"settings":{
			"master_volume": 100,
			"music_volume": 100,
			"sfx_volume": 100,
			"auto_reload":true
		},
		"stats":{
			"money":0,
			"upgrade_reload":0,
			"upgrade_mag":0,
			"upgrade_firerate":0,

			"duck_hi":0,
			"duck_rank":"NONE",
			"duck_ta_hi":0,
			"duck_ta_rank":"NONE",
		}
	}

func _create_empty_save():
	var time = int(Time.get_unix_time_from_system())

	var file = FileAccess.open_encrypted_with_pass(FILE_PATH,FileAccess.WRITE,str(time))

	var dict = _get_empty_save()
	var data = JSON.stringify(dict)
	var _hash = data.sha256_text()
	dict["hash"] = _hash

	file.store_line(JSON.stringify(dict))
	file.close()

func reset_save_game():
	_create_empty_save()
	load_game()

func save_game():
	if !FileAccess.file_exists(FILE_PATH):
		_create_empty_save()
		return

	DirAccess.remove_absolute(FILE_PATH)

	var time = int(Time.get_unix_time_from_system())

	var file = FileAccess.open_encrypted_with_pass(FILE_PATH,FileAccess.WRITE,str(time))

	if file == null:
		_create_empty_save()
		return

	var dict = _get_save_dict()
	var data = JSON.stringify(dict)
	var _hash = data.sha256_text()
	dict["hash"] = _hash

	file.store_line(JSON.stringify(dict))
	file.close()

func load_game():
	if !FileAccess.file_exists(FILE_PATH):
		_create_empty_save()
		return

	var time = FileAccess.get_modified_time(FILE_PATH)
	var file = FileAccess.open_encrypted_with_pass(FILE_PATH,FileAccess.READ,str(time))

	if file == null:
		_create_empty_save()
		return

	var dict: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()

	var _hash = dict["hash"]
	dict.erase("hash")
	var new_hash = JSON.stringify(dict).sha256_text()

	if _hash != new_hash:
		_create_empty_save()
		return

	for setting in dict["settings"].keys():
		settings[setting] = dict["settings"][setting]

	for stat in dict["stats"].keys():
		stats[stat] = dict["stats"][stat]
