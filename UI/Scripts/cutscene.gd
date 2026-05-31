extends Control

const CHAR_DELAY     := 0.038
const PAUSE_PERIOD   := 0.38
const PAUSE_COMMA    := 0.14
const PAUSE_NEWLINE  := 0.18
const PAUSE_BETWEEN  := 0.7

const PARAGRAPHS := [
	"YEAR 2451. OVERLOAD ERROR",
	"Climate wars erased the planet. Now we live inside. Logos — the digital matrix, humanity's last ark. But the AI failed.\n\nIt no longer stores personalities — it erases them. People become empty shells. All but one.",
	"You are a diver.\n\nYour brain underwent the «Overload Protocol».\nYou can enter the system's core\nwhere others see only walls of code."
]

@onready var label      : RichTextLabel     = $RichTextLabel
@onready var hint_label : Label             = $Label
@onready var key_sound  : AudioStreamPlayer = $AudioStreamPlayer1
@onready var hint_sound : AudioStreamPlayer = $AudioStreamPlayer2

var _para_idx    : int   = 0
var _char_idx    : int   = 0
var _shown_text  : String = ""
var _typing      : bool  = false
var _waiting     : bool  = false
var _timer       : float = 0.0
var _next_delay  : float = 0.0
var _hint_alpha  : float = 0.0
var _hint_fading : bool  = false

func _ready():
	var font_variation = FontVariation.new()
	font_variation.base_font = load("res://UI/Assets/Fonts/BuilderMono-Regular-400_0.ttf")
	font_variation.spacing_glyph = 4
	font_variation.spacing_space = 1
	label.add_theme_font_override("normal_font", font_variation)
	hint_label.add_theme_font_override("font", font_variation)

	label.text            = ""
	hint_label.visible    = false
	hint_label.modulate   = Color(1, 1, 1, 0.0)
	await get_tree().create_timer(1.0).timeout
	_start_paragraph()

func _process(delta: float):
	if _hint_fading:
		_hint_alpha += delta * 0.4
		hint_label.modulate = Color(1, 1, 1, min(_hint_alpha * 0.4, 0.4))
		if _hint_alpha * 0.4 >= 0.4:
			_hint_fading = false

	if not _typing:
		return
	_timer += delta
	if _timer < _next_delay:
		return
	_timer = 0.0
	_type_next_char()

func _type_next_char():
	var para : String = PARAGRAPHS[_para_idx]
	if _char_idx >= para.length():
		_on_paragraph_done()
		return
	var ch := para[_char_idx]
	_shown_text += ch
	_char_idx   += 1
	label.text = _shown_text + "[pulse freq=1.8 color=#ffffff66]▌[/pulse]"
	if ch != " " and ch != "\n":
		if key_sound and key_sound.stream:
			key_sound.pitch_scale = randf_range(0.85, 1.15)
			key_sound.volume_db   = randf_range(-6.0, 0.0)
			key_sound.play()
	if ch in [".", "!", "?"]:
		_next_delay = PAUSE_PERIOD
	elif ch in [",", "—", "…"]:
		_next_delay = PAUSE_COMMA
	elif ch == "\n":
		_next_delay = PAUSE_NEWLINE
	else:
		_next_delay = CHAR_DELAY

func _on_paragraph_done():
	_typing  = false
	_waiting = true
	if _para_idx < PARAGRAPHS.size() - 1:
		label.text      = _shown_text + "[pulse freq=1.8 color=#ffffff66]|[/pulse]"
		hint_label.text = "PRESS ANY KEY TO CONTINUE"
	else:
		label.text      = _shown_text
		hint_label.text = "ACCEPT THE «OVERLOAD» PROTOCOL"
		await get_tree().create_timer(1.2).timeout  
		if hint_sound and hint_sound.stream:
			hint_sound.play()
	_show_hint()

func _show_hint():
	_hint_alpha  = 0.0
	_hint_fading = true
	hint_label.modulate = Color(1, 1, 1, 0.0)
	hint_label.visible  = true


func _start_paragraph():
	_char_idx    = 0
	_typing      = true
	_waiting     = false
	_timer       = 0.0
	_hint_fading = false
	hint_label.visible  = false
	hint_label.modulate = Color(1, 1, 1, 0.0)

func _input(event: InputEvent):
	if not event.is_pressed():
		return
	if not (event is InputEventKey or event is InputEventMouseButton):
		return
	if _typing:
		_skip_current()
	elif _waiting:
		_advance()

func _skip_current():
	_typing = false
	var para : String = PARAGRAPHS[_para_idx]
	_shown_text += para.substr(_char_idx)
	_char_idx    = para.length()
	_on_paragraph_done()

func _advance():
	_waiting   = false
	_para_idx += 1
	if _para_idx >= PARAGRAPHS.size():
		get_tree().change_scene_to_file("res://UI/Scenes/menu.tscn")
		return
	_shown_text += "\n\n"
	await get_tree().create_timer(PAUSE_BETWEEN).timeout
	_start_paragraph()
