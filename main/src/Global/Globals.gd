extends Node

@onready var root: Node2D = null
@onready var game: Game = null
@onready var active_script: GameScript = null

const LEVEL_PATHS = {
	"duck":"DuckGame",
	"target":"TargetGame",
}

var ta_game: bool = false

var level_id: String = ""
var end_time: int = 0
var end_score: int = 0
var end_rank: String = "NONE"
var end_level: String = "Duck Hunt"
var end_shot: int = 0
