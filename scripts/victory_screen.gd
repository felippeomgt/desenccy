extends Control

@onready var back_button = $BackButton
@onready var fade_rect = $ColorRect
@onready var button_hover = $ButtonHover
@onready var game_ending = $GameEnding

var loaded = false;

func _ready():
	back_button.hide()
	fade_rect.hide()
	
func _process(delta):
	if (!loaded):
		game_ending.play()
		fade_to_gray(4.5)
		loaded = true
		await get_tree().create_timer(4.5).timeout
		back_button.visible = true

func fade_to_gray(duration: float):
	fade_rect.visible = true
	var tween = fade_rect.create_tween()
	tween.tween_property(fade_rect, "color:a", 0, duration)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_back_button_mouse_entered() -> void:
	button_hover.play()
