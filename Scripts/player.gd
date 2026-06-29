extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound


const SPEED = 300.0
const JUMP_VELOCITY = -850.0
var alive = true
var can_move = true
const MAX_JUMPS = 2
var jumps_left = MAX_JUMPS
const WALL_SLIDE_GRAVITY_MULTIPLIER = 0.2

func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	
	if !alive:
		return
		
	if is_on_floor():
		jumps_left = MAX_JUMPS
	
	# Add the gravity.
	# Add the gravity.
	if not is_on_floor():
		if is_wall_sliding():
			velocity += get_gravity() * delta * WALL_SLIDE_GRAVITY_MULTIPLIER
		else:
			velocity += get_gravity() * delta

	if can_move:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and jumps_left > 0:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
			jump_sound.play()
			if jumps_left == 0:
				animated_sprite_2d.play("doublejumping")

		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		
		if direction == 1.0:
			animated_sprite_2d.flip_h = false
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true
		
		update_animation()

func die() -> void:
	death_sound.play()
	animated_sprite_2d.play("dying")
	alive = false

func bounce():
	velocity.y = JUMP_VELOCITY * 0.7

func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "doublejumping":
		animated_sprite_2d.play("jumping")

func update_animation() -> void:

	# Don't interrupt the double jump animation
	if animated_sprite_2d.animation == "doublejumping":
		return

	# Wall slide animation
	if is_wall_sliding():
		set_animation("wallsliding")
		return

	# Air animations
	if not is_on_floor():
		set_animation("jumping")
		return

	# Ground animations
	if abs(velocity.x) > 1:
		set_animation("running")
	else:
		set_animation("idle")

func is_wall_sliding() -> bool:
	return (
		is_on_wall_only()
		and velocity.y > 0
	)

func set_animation(name: String) -> void:
	if animated_sprite_2d.animation != name:
		animated_sprite_2d.play(name)
