extends Node2D

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var bg = $Background

@onready var money_text: Label = $CanvasLayer/Control/MoneyPanel/HBoxContainer/Label

@onready var mag_upgrade: Label = $CanvasLayer/Control/VBoxContainer/Mag/TextureRect/Items/Upgrade
@onready var mag_price: Label = $CanvasLayer/Control/VBoxContainer/Mag/TextureRect/Items/HBoxContainer/Price
@onready var mag_button: TextureButton = $CanvasLayer/Control/VBoxContainer/Mag/TextureRect/Items/BuyButton
@onready var mag_max: Label = $CanvasLayer/Control/VBoxContainer/Mag/TextureRect/Items/No

@onready var reload_upgrade: Label = $CanvasLayer/Control/VBoxContainer/Reload/TextureRect/Items/Upgrade
@onready var reload_price: Label = $CanvasLayer/Control/VBoxContainer/Reload/TextureRect/Items/HBoxContainer/Price
@onready var reload_button: TextureButton = $CanvasLayer/Control/VBoxContainer/Reload/TextureRect/Items/BuyButton
@onready var reload_max: Label = $CanvasLayer/Control/VBoxContainer/Reload/TextureRect/Items/No

@onready var fire_upgrade: Label = $CanvasLayer/Control/VBoxContainer/Firerate/TextureRect/Items/Upgrade
@onready var fire_price: Label = $CanvasLayer/Control/VBoxContainer/Firerate/TextureRect/Items/HBoxContainer/Price
@onready var fire_button: TextureButton = $CanvasLayer/Control/VBoxContainer/Firerate/TextureRect/Items/BuyButton
@onready var fire_max: Label = $CanvasLayer/Control/VBoxContainer/Firerate/TextureRect/Items/No

@onready var particles_scene = preload("res://src/Shop/Particles.tscn")

@onready var is_transitioning = true

const MAX_UPGRADE = 3

const MAG_PRICE_BASE = 100
const RELOAD_PRICE_BASE = 150
const FIRE_PRICE_BASE = 125

const MAG_PRICE_BOOST = 125
const RELOAD_PRICE_BOOST = 200
const FIRERATE_PRICE_BOOST = 150

var mag_cur_price: int = MAG_PRICE_BASE
var reload_cur_price: int = RELOAD_PRICE_BASE
var fire_cur_price: int = FIRE_PRICE_BASE

func _ready():
	bg.play_animation = false

	animator.play("CurtainUp")

	update_shop()

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

	Globals.root.get_node("Click").play()

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Globals.root.change_scene("Shop","MainMenu")

func update_shop():
	money_text.text = "x" + str(SaveData.stats["money"])
	var cur_upgrade

################################################################################

	cur_upgrade = SaveData.stats["upgrade_mag"]
	mag_cur_price = MAG_PRICE_BASE + cur_upgrade * MAG_PRICE_BOOST

	mag_upgrade.text = "CURRENT UPGRADE: " + str(cur_upgrade) + "/3"
	if cur_upgrade == 3:
		mag_button.hide()
		mag_max.show()

		mag_price.text = "PRICE: -"
	else:
		mag_button.show()
		mag_max.hide()

		mag_price.text = "PRICE: " + str(mag_cur_price)

################################################################################

	cur_upgrade = SaveData.stats["upgrade_reload"]
	reload_cur_price = RELOAD_PRICE_BASE + cur_upgrade * RELOAD_PRICE_BOOST

	reload_upgrade.text = "CURRENT UPGRADE: " + str(cur_upgrade) + "/3"
	if cur_upgrade == 3:
		reload_button.hide()
		reload_max.show()

		reload_price.text = "PRICE: -"
	else:
		reload_button.show()
		reload_max.hide()

		reload_price.text = "PRICE: " + str(reload_cur_price)

################################################################################

	cur_upgrade = SaveData.stats["upgrade_firerate"]
	fire_cur_price = FIRE_PRICE_BASE + cur_upgrade * FIRERATE_PRICE_BOOST

	fire_upgrade.text = "CURRENT UPGRADE: " + str(cur_upgrade) + "/3"
	if cur_upgrade == 3:
		fire_button.hide()
		fire_max.show()

		fire_price.text = "PRICE: -"
	else:
		fire_button.show()
		fire_max.hide()

		fire_price.text = "PRICE: " + str(fire_cur_price)

################################################################################

func _on_buy_reload_button_pressed():
	var money = SaveData.stats["money"]
	if money < reload_cur_price:
		return

	var particles = particles_scene.instantiate()
	$CanvasLayer/Control/VBoxContainer/Reload/TextureRect.add_child(particles)
	particles.position = Vector2(540,196)
	particles.start()

	SaveData.stats["money"] -= reload_cur_price
	SaveData.stats["upgrade_reload"] += 1

	SaveData.save_game()
	update_shop()

func _on_buy_mag_button_pressed():
	var money = SaveData.stats["money"]
	if money < mag_cur_price:
		return

	var particles = particles_scene.instantiate()
	$CanvasLayer/Control/VBoxContainer/Mag/TextureRect.add_child(particles)
	particles.position = Vector2(540,196)
	particles.start()

	SaveData.stats["money"] -= mag_cur_price
	SaveData.stats["upgrade_mag"] += 1

	SaveData.save_game()
	update_shop()

func _on_buy_fire_button_pressed():
	var money = SaveData.stats["money"]
	if money < fire_cur_price:
		return

	var particles = particles_scene.instantiate()
	$CanvasLayer/Control/VBoxContainer/Firerate/TextureRect.add_child(particles)
	particles.position = Vector2(540,196)
	particles.start()

	SaveData.stats["money"] -= fire_cur_price
	SaveData.stats["upgrade_firerate"] += 1

	SaveData.save_game()
	update_shop()
