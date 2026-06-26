extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal player_died
const SPEED = 30
var direction = -1.0
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction * SPEED * delta


func _on_timer_timeout() -> void:
	direction *= -1
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h


func _on_body_entered(body: Node2D) -> void:
	if dead:
		return
	if body.name == "Player" and body.alive:
		emit_signal("player_died", body)
		


func _on_stomp_box_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	dead = true
	body.bounce()
	animated_sprite_2d.animation = "dying"
	await animated_sprite_2d.animation_finished
	queue_free()
