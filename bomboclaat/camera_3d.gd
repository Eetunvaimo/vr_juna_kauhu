extends Camera3D

const LOOKAROUND_SPEED = 0.01

var rot_x = 0.0 # horizontal rotation (yaw)
var rot_y = 0.0 # vertical rotation (pitch)

var bobbing_speed = 8.0
var bobbing_amount = 0.05
var bob_timer = 0.0
var default_position := Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_position = transform.origin

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rot_x -= event.relative.x * LOOKAROUND_SPEED
		rot_y -= event.relative.y * LOOKAROUND_SPEED
		rot_y = clamp(rot_y, deg_to_rad(-89), deg_to_rad(89))

		# Apply rotation: yaw on Y, then pitch on X
		rotation = Vector3(rot_y, rot_x, 0)

func _process(delta):
	# --- HEAD BOB ---
	var player = get_parent()
	if player.has_method("is_on_floor") and player.is_on_floor():
		var velocity = player.velocity if player.has_variable("velocity") else Vector3.ZERO
		var is_moving = velocity.length() > 0.1
		
		if is_moving:
			bob_timer += delta * bobbing_speed
			var bob_offset = sin(bob_timer) * bobbing_amount
			var new_pos = default_position
			new_pos.y += bob_offset
			transform.origin = new_pos
		else:
			# Reset position
			bob_timer = 0.0
			transform.origin.y = lerp(transform.origin.y, default_position.y, delta * 10)
