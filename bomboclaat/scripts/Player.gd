extends CharacterBody3D

@onready var cam = $MeshInstance3D/Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- Head bobbing ---
var bobbing_speed = 8.0
var bobbing_amount = 0.05
var bob_timer = 0.0
var cam_default_pos := Vector3.ZERO

func _ready():
	cam_default_pos = cam.transform.origin

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Input direction from keys
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Convert input direction to world space using the camera
	var forward = cam.global_transform.basis.z
	var right = cam.global_transform.basis.x
	var direction = (right * input_dir.x + forward * input_dir.y).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# --- Head Bob Logic ---
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var speed = horizontal_velocity.length()
var is_moving = speed > 0.1 and is_on_floor()d is_on_floor()

	if is_moving:
		var move_dir = horizontal_velocity.normalized()
		var cam_forward = -cam.global_transform.basis.z.normalized()
		var dot = move_dir.dot(cam_forward) # +1 forward, -1 backward

		# Adjust bob direction: invert if going backward
		var direction_multiplier = sign(dot)

		bob_timer += delta * bobbing_speed
		var bob_offset = sin(bob_timer) * bobbing_amount * direction_multiplier

		var new_cam_pos = cam_default_pos
		new_cam_pos.y += bob_offset
		cam.transform.origin = new_cam_pos
	else:
		bob_timer = 0.0
		var reset_y = lerp(cam.transform.origin.y, cam_default_pos.y, delta * 10)
		cam.transform.origin.y = reset_y
