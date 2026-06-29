extends Node2D
@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var fade: ColorRect = $HUD/Fade
@onready var screen_root: CanvasLayer = $ScreenRoot

var level: int = 1
var score: int = 0
var current_level_root: Node = null

const MAIN_MENU = preload("res://Scenes/Screens/main_menu.tscn")

var current_screen: Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade.modulate.a = 1.0
	current_level_root = get_node("LevelRoot")

	_show_main_menu()

	#await _load_level(level, true, false)

func _show_main_menu() -> void:
	_show_screen(MAIN_MENU)

	current_screen.play_pressed.connect(_on_play_pressed)
	current_screen.quit_pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	_hide_current_screen()

	await _load_level(level, true, false)


func _on_quit_pressed():
	get_tree().quit()

func _hide_current_screen() -> void:
	if current_screen:
		current_screen.queue_free()
		current_screen = null

func _show_screen(screen_scene: PackedScene) -> void:
	_hide_current_screen()

	current_screen = screen_scene.instantiate()

	$HUD.add_child(current_screen)

#--------------------------
# LEVEL MANAGEMENT
#--------------------------

func _load_level(level_number: int, first_load: bool, reset_score: bool) -> void:	
	# Fade out
	if not first_load:
		await _fade(1.0)
		
	if reset_score:
		score = 0
		score_label.text = "SCORE: 0"
	
	if current_level_root:
		current_level_root.queue_free()
	
	# Change level
	var level_path = "res://Scenes/levels/level%s.tscn" %level_number
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)
	
	# Fade in
	await _fade(0.0)

func _setup_level(level_root: Node) -> void:
	# Connect exit
	var exit = level_root.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	
	# Connect oranges
	var oranges = level_root.get_node_or_null("Oranges")
	if oranges:
		for orange in oranges.get_children():
			orange.collected.connect(increase_score)
			
	# Connect enemies
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)
			
	# Connect spikes
	var traps = level_root.get_node_or_null("Traps")
	if traps:
		for trap in traps.get_children():
			trap.player_died.connect(_on_player_died)


#--------------------------
# SIGNAL HANDLERS
#--------------------------
func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		level = level + 1
		body.can_move = false
		await _load_level(level, false, false)


func _on_player_died(body):
	body.die()
	await _load_level(level, false, true)


#--------------------------
# SCORE
#--------------------------

func increase_score() -> void:
	score += 1
	score_label.text = "SCORE: %s" % score


#--------------------------
# FADE
#--------------------------

func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished
