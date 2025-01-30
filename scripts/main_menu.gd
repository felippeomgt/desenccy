extends Control

@onready var controls_panel = $ControlsPanel
@onready var main_buttons = $MainButtons
@onready var menu_hover_sound = $HoverMenu
@onready var start_game = $StartGame
@onready var fade_rect = $ColorRect

func _ready():
	controls_panel.hide()
	fade_rect.hide()
	
func _process(delta):
	if Input.is_action_just_pressed("esc"):
		if main_buttons.visible:
			get_tree().quit()
		elif controls_panel.visible:
			_on_controls_button_pressed()

func fade_to_white(duration: float):
	fade_rect.color.a = 0
	fade_rect.visible = true
	var tween = fade_rect.create_tween()
	tween.tween_property(fade_rect, "color:a", 1, duration)

func _on_start_button_pressed():
	start_game.play()
	fade_to_white(4.5)
	await get_tree().create_timer(4.5).timeout
	get_tree().change_scene_to_file("res://main.tscn")

func _on_controls_button_pressed():
	main_buttons.visible = !main_buttons.visible
	controls_panel.visible = !controls_panel.visible 

func _on_quit_button_pressed():
	get_tree().quit()

func play_sound():
	menu_hover_sound.play()

func _on_start_button_mouse_entered() -> void:
	play_sound()

func _on_controls_button_mouse_entered() -> void:
	play_sound()

func _on_quit_button_mouse_entered() -> void:
	play_sound()
