extends CanvasLayer

@onready var healthLabel = $Control/MarginContainer/Health
@onready var healthBar = $Control/MarginContainer/HealthBar
@onready var overheatA = $Control/MarginContainer2/OverheatA
@onready var overheat_bara = $Control/MarginContainer2/OverheatBarA
@onready var overheatB = $Control/MarginContainer3/OverheatB
@onready var overheat_barb = $Control/MarginContainer3/OverheatBarB
@onready var overheatC = $Control/MarginContainer4/OverheatC
@onready var overheat_barc = $Control/MarginContainer4/OverheatBarC
@onready var overheatD = $Control/MarginContainer5/OverheatD
@onready var overheat_bard = $Control/MarginContainer5/OverheatBarD

func update_health(value: float):
	if value >= 0:
		healthLabel.text = "Health: " + str(value)
		healthBar.value = value
		healthBar.self_modulate = Color(1, value, value)  # Fica mais vermelho conforme perde vida

func update_heat_a(heat, overheat, max_overheat):
	overheatA.text = "Heat: " + str(heat)
	overheat_bara.max_value = max_overheat
	overheat_bara.value = heat
	overheat_bara.self_modulate = Color(1, 0.5, 0) if overheat else Color(0, 1, 1) 

func update_heat_b(heat, overheat, max_overheat):
	overheatB.text = "Heat: " + str(heat)
	overheat_barb.max_value = max_overheat
	overheat_barb.value = heat
	overheat_barb.self_modulate = Color(1, 0.5, 0) if overheat else Color(0, 1, 1) 
	
func update_heat_c(heat, overheat, max_overheat):
	overheatC.text = "Heat: " + str(heat)
	overheat_barc.max_value = max_overheat
	overheat_barc.value = heat
	overheat_barc.self_modulate = Color(1, 0.5, 0) if overheat else Color(0, 1, 1) 
	
func update_heat_d(heat, overheat, max_overheat):
	overheatD.text = "Heat: " + str(heat)
	overheat_bard.max_value = max_overheat
	overheat_bard.value = heat
	overheat_bard.self_modulate = Color(1, 0.5, 0) if overheat else Color(0, 1, 1) 
