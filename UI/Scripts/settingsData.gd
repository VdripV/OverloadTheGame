extends Node

const SAVE_PATH = "user://settings.cfg"

# Чувствительность
var sensitivity_x: float = 0.05
var sensitivity_y: float = 0.05

# Громкость
var volume_music: float = 1.0
var volume_sfx: float = 1.0

var keybinds: Dictionary = {
	# PlayerCharacter
	"play_char_move_forward_action":  KEY_W,
	"play_char_move_backward_action": KEY_S,
	"play_char_move_left_ation":      KEY_A, 
	"play_char_move_right_action":    KEY_D,
	"play_char_run_action":           KEY_SHIFT,
	"play_char_crouch_action":        KEY_C,
	"play_char_jump_action":          KEY_SPACE,
	"play_char_slide_action":         KEY_C,
	"play_char_dash_action":          KEY_CTRL,
	"play_char_fly_action":           KEY_F,
	# WeaponManager
	"shoot":                          KEY_UNKNOWN,
	"reload":                         KEY_R,
	"drop":                           KEY_G,
	"weapon_up":                      KEY_E,
	"weapon_down":                    KEY_Q,
}

var keybind_labels: Dictionary = {
	"play_char_move_forward_action":  "Вперёд",
	"play_char_move_backward_action": "Назад",
	"play_char_move_left_ation":      "Влево",
	"play_char_move_right_action":    "Вправо",
	"play_char_run_action":           "Спринт",
	"play_char_crouch_action":        "Присед",
	"play_char_jump_action":          "Прыжок",
	"play_char_slide_action":         "Слайд",
	"play_char_dash_action":          "Рывок",
	"play_char_fly_action":           "Полёт",
	"shoot":                          "Выстрел",
	"reload":                         "Перезарядка",
	"drop":                           "Выбросить оружие",
	"weapon_up":                      "Следующее оружие",
	"weapon_down":                    "Предыдущее оружие",
}

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("sensitivity", "x", sensitivity_x)
	config.set_value("sensitivity", "y", sensitivity_y)
	config.set_value("volume", "music", volume_music)
	config.set_value("volume", "sfx", volume_sfx)
	for action in keybinds:
		config.set_value("keybinds", action, keybinds[action])
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		apply_to_input_map() 
		return
	sensitivity_x = config.get_value("sensitivity", "x", sensitivity_x)
	sensitivity_y = config.get_value("sensitivity", "y", sensitivity_y)
	volume_music  = config.get_value("volume", "music", volume_music)
	volume_sfx    = config.get_value("volume", "sfx", volume_sfx)
	for action in keybinds:
		keybinds[action] = config.get_value("keybinds", action, keybinds[action])
	apply_to_input_map()

func apply_to_input_map() -> void:
	for action in keybinds:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		else:
			var events = InputMap.action_get_events(action)
			for event in events:
				if event is InputEventKey:
					InputMap.action_erase_event(action, event)
		
		if keybinds[action] != KEY_UNKNOWN and keybinds[action] != 0:
			var key_event = InputEventKey.new()
			key_event.physical_keycode = keybinds[action]
			InputMap.action_add_event(action, key_event)
