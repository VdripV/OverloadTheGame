extends Control

@onready var levels_list: VBoxContainer = $ScrollContainer/LevelsList
@onready var close_button: Button = $CloseButton

const MENU_SCENE = "res://UI/Scenes/menu.tscn"

func _ready() -> void:
	$CloseButton.pressed.connect(_on_close_pressed)
	_build_stats()

func _build_stats() -> void:
	if StatsData.stats.is_empty():
		var label = Label.new()
		label.text = "Нет данных — пройди хотя бы один уровень"
		levels_list.add_child(label)
		return
	
	for level in StatsData.stats:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 30)
		
		var name_label = Label.new()
		name_label.text = level
		name_label.custom_minimum_size.x = 150
		row.add_child(name_label)
		
		var time_label = Label.new()
		time_label.text = StatsData.format_time(StatsData.stats[level]["best_time"])
		time_label.custom_minimum_size.x = 100
		row.add_child(time_label)
		
		var date_label = Label.new()
		date_label.text = StatsData.stats[level]["date"]
		row.add_child(date_label)
		
		levels_list.add_child(row)

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
