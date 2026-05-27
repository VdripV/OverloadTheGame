extends Control

@export var player: CharacterBody3D
@export var weapon_manager: Node

@onready var health_bar: ProgressBar = $Components/HealthBar/ProgressBar
@onready var health_label: Label = $Components/HealthBar/Label

@onready var armor_bar: ProgressBar = $Components/ArmorBar/ProgressBar
@onready var armor_label: Label = $Components/ArmorBar/Label

@onready var ammo_current: Label = $Components/AmmoDisplay/CurrentAmmo
@onready var ammo_reserve: Label = $Components/AmmoDisplay/ReserveAmmo

@onready var weapon_name_label: Label = $Components/WeaponDisplay/WeaponName

func _ready() -> void:
	_connect_signals()
	_init_values()
	
func _connect_signals() -> void:
	player.health_changed.connect(_on_health_changed)
	player.armor_changed.connect(_on_armor_changed)
	weapon_manager.Update_Ammo.connect(_on_ammo_updated)
	weapon_manager.Weapon_Changed.connect(_on_weapon_changed)

func _init_values() -> void:
	_on_health_changed(player.health, player.max_health)
	_on_armor_changed(player.armor, player.max_armor)
	_on_weapon_changed(weapon_manager.Current_Weapon.Weapon_Name)
	_on_ammo_updated([weapon_manager.Current_Weapon.Current_Ammo, weapon_manager.Current_Weapon.Reserve_Ammo])

func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d / %d" % [current, maximum]

func _on_armor_changed(current: float, maximum: float) -> void:
	armor_bar.max_value = maximum
	armor_bar.value = current
	armor_label.text = "%d / %d" % [current, maximum]

func _on_ammo_updated(ammo_data: Array) -> void:
	ammo_current.text = str(ammo_data[0])
	ammo_reserve.text = "/ " + str(ammo_data[1])

func _on_weapon_changed(weapon_name: String) -> void:
	weapon_name_label.text = weapon_name
