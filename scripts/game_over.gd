extends Control
@onready var white = $White
@onready var main_buttons = $MainButtons
@onready var menu_hover_sound = $HoverMenu
@onready var start_game = $StartGame


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	white.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
			get_tree().quit()
			
func fade_to_white(duration: float):
	white.color.a = 0
	white.visible = true
	var tween = white.create_tween()
	tween.tween_property(white, "color:a", 1, duration)
	
func play_sound():
	menu_hover_sound.play()

func _on_retry_button_pressed() -> void:	
	start_game.play()
	fade_to_white(4.5)
	await get_tree().create_timer(4.5).timeout
	get_tree().change_scene_to_file("res://main.tscn")

func _on_retry_button_mouse_entered() -> void:
	play_sound()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_exit_button_mouse_entered() -> void:
	play_sound()
