extends Control
@onready var levels_list: VBoxContainer = $ScrollContainer/LevelsList
@onready var close_button: Button = $CloseButton
@onready var hover_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var click_sound: AudioStreamPlayer = $AudioStreamPlayer2

const MENU_SCENE = "res://UI/Scenes/menu.tscn"

func _ready() -> void:
	var cursor = load("res://UI/Assets/Video/cursor.png")
	Input.set_custom_mouse_cursor(cursor)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hover_sound.stream = load("res://UI/Assets/Sounds/btnclick2.wav")
	click_sound.stream = load("res://UI/Assets/Sounds/btnclick1.wav")
	close_button.mouse_entered.connect(func(): hover_sound.play())
	close_button.pressed.connect(_on_close_pressed)
	_build_stats()

func _build_stats() -> void:
	var font = load("res://UI/Assets/Fonts/BuilderMono-Bold-700_0.ttf")
	var font_size = 24

	if StatsData.stats.is_empty():
		var label = Label.new()
		label.text = "No data — complete at least one level"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", font_size)
		levels_list.add_child(label)
		return

	for level in StatsData.stats:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 30)
		row.alignment = BoxContainer.ALIGNMENT_CENTER

		var name_label = Label.new()
		name_label.text = level
		name_label.custom_minimum_size.x = 150
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_override("font", font)
		name_label.add_theme_font_size_override("font_size", font_size)
		row.add_child(name_label)

		var time_label = Label.new()
		time_label.text = StatsData.format_time(StatsData.stats[level]["best_time"])
		time_label.custom_minimum_size.x = 100
		time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		time_label.add_theme_font_override("font", font)
		time_label.add_theme_font_size_override("font_size", font_size)
		row.add_child(time_label)

		var date_label = Label.new()
		date_label.text = StatsData.stats[level]["date"]
		date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		date_label.add_theme_font_override("font", font)
		date_label.add_theme_font_size_override("font_size", font_size)
		row.add_child(date_label)

		levels_list.add_child(row)

func _on_close_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	get_tree().change_scene_to_file(MENU_SCENE)
