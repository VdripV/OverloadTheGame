extends Node

const SAVE_PATH = "user://stats.cfg"

var stats: Dictionary = {}

func save_best_time(level_name: String, time: float) -> void:
	var date = Time.get_date_string_from_system()
	
	if not stats.has(level_name):
		stats[level_name] = {"best_time": time, "date": date}
		_save()
	elif time < stats[level_name]["best_time"]:
		stats[level_name]["best_time"] = time
		stats[level_name]["date"] = date
		_save()

func _save() -> void:
	var config = ConfigFile.new()
	for level in stats:
		config.set_value(level, "best_time", stats[level]["best_time"])
		config.set_value(level, "date", stats[level]["date"])
	config.save(SAVE_PATH)

func _load() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	for level in config.get_sections():
		stats[level] = {
			"best_time": config.get_value(level, "best_time", 0.0),
			"date": config.get_value(level, "date", "")
		}

func _ready() -> void:
	_load()

func format_time(time: float) -> String:
	var seconds: int = int(time)
	var milliseconds: int = int(fmod(time, 1.0) * 100)
	return "%d:%02d" % [seconds, milliseconds]
