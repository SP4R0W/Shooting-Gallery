extends Node

@onready var settings: Dictionary = {
	"master_volume": 100,
	"music_volume": 100,
	"sfx_volume": 100,
	"auto_reload":false
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
}
