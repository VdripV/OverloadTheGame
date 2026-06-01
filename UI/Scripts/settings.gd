extends Control

@onready var sens_x_slider: HSlider = $Components/Sensitivity/SensXRow/SensXSlider
@onready var sens_x_label:  Label   = $Components/Sensitivity/SensXRow/SensXLabel
@onready var sens_y_slider: HSlider = $Components/Sensitivity/SensYRow/SensYSlider
@onready var sens_y_label:  Label   = $Components/Sensitivity/SensYRow/SensYLabel
@onready var music_slider:  HSlider = $Components/Volume/MusicRow/MusicRowSlider
@onready var music_label:   Label   = $Components/Volume/MusicRow/MusicRowLabel
@onready var sfx_slider:    HSlider = $Components/Volume/SFXRow/SFXRowSlider
@onready var sfx_label:     Label   = $Components/Volume/SFXRow/SFXRowLabel
@onready var keybinds_list: VBoxContainer = $Components/Keybinds/KeybindsList
@onready var hover_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var click_sound: AudioStreamPlayer = $AudioStreamPlayer2

var keybind_buttons: Dictionary = {}
var waiting_for_input: String = ""

func _ready() -> void:
	var cursor = load("res://UI/Assets/Video/cursor.png")
	Input.set_custom_mouse_cursor(cursor)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hover_sound.stream = load("res://UI/Assets/Sounds/btnclick2.wav")
	click_sound.stream = load("res://UI/Assets/Sounds/btnclick1.wav")
	_build_keybind_buttons()
	_load_from_settings_data()
	var close_btn = $CloseButton
	close_btn.mouse_entered.connect(func(): hover_sound.play())
	close_btn.pressed.connect(_on_close_pressed)
	sens_x_slider.value_changed.connect(_on_sens_x_changed)
	sens_y_slider.value_changed.connect(_on_sens_y_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

func _build_keybind_buttons() -> void:
	var font = load("res://UI/Assets/Fonts/BuilderMono-Bold-700_0.ttf")
	var font_size = 16

	for action in SettingsData.keybinds:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)

		var label = Label.new()
		label.text = SettingsData.keybind_labels.get(action, action)
		label.custom_minimum_size.x = 200
		if font:
			label.add_theme_font_override("font", font)
			label.add_theme_font_size_override("font_size", font_size)
		row.add_child(label)

		var btn = Button.new()
		btn.text = _keycode_to_string(SettingsData.keybinds[action])
		btn.custom_minimum_size.x = 120
		if font:
			btn.add_theme_font_override("font", font)
			btn.add_theme_font_size_override("font_size", font_size)
		btn.mouse_entered.connect(func(): hover_sound.play())
		btn.pressed.connect(_on_keybind_button_pressed.bind(action, btn))
		keybind_buttons[action] = btn
		row.add_child(btn)

		keybinds_list.add_child(row)

func _load_from_settings_data() -> void:
	sens_x_slider.value = SettingsData.sensitivity_x
	sens_x_label.text   = "%.3f" % SettingsData.sensitivity_x
	sens_y_slider.value = SettingsData.sensitivity_y
	sens_y_label.text   = "%.3f" % SettingsData.sensitivity_y
	music_slider.value  = SettingsData.volume_music
	music_label.text    = "%d%%" % (SettingsData.volume_music * 100)
	sfx_slider.value    = SettingsData.volume_sfx
	sfx_label.text      = "%d%%" % (SettingsData.volume_sfx * 100)

func _keycode_to_string(keycode: int) -> String:
	if keycode == KEY_UNKNOWN or keycode == 0:
		return "—"
	return OS.get_keycode_string(keycode)

func _on_sens_x_changed(value: float) -> void:
	SettingsData.sensitivity_x = value
	sens_x_label.text = "%.3f" % value

func _on_sens_y_changed(value: float) -> void:
	SettingsData.sensitivity_y = value
	sens_y_label.text = "%.3f" % value

func _on_music_changed(value: float) -> void:
	SettingsData.volume_music = value
	music_label.text = "%d%%" % (value * 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_changed(value: float) -> void:
	SettingsData.volume_sfx = value
	sfx_label.text = "%d%%" % (value * 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_keybind_button_pressed(action: String, btn: Button) -> void:
	if waiting_for_input != "" and keybind_buttons.has(waiting_for_input):
		keybind_buttons[waiting_for_input].text = _keycode_to_string(SettingsData.keybinds[waiting_for_input])
	waiting_for_input = action
	btn.text = "[ press a key ]"

func _input(event: InputEvent) -> void:
	if waiting_for_input == "":
		return
	if event is InputEventKey and event.pressed:
		var keycode = event.physical_keycode
		if keycode == KEY_ESCAPE:
			keybind_buttons[waiting_for_input].text = _keycode_to_string(SettingsData.keybinds[waiting_for_input])
			waiting_for_input = ""
			get_viewport().set_input_as_handled()
			return
		SettingsData.keybinds[waiting_for_input] = keycode
		keybind_buttons[waiting_for_input].text = _keycode_to_string(keycode)
		SettingsData.apply_to_input_map()
		waiting_for_input = ""
		get_viewport().set_input_as_handled()

func _on_close_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	SettingsData.save_settings()
	queue_free()
