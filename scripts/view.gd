extends Node3D

@export_group("Properties")
@export var target: Node

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10
@export var default_zoom = 10
@export var camera_angle_min : float = -80
@export var camera_angle_max : float = -10

@export_group("Rotation")
@export var rotation_speed = 120

var camera_rotation:Vector3
var zoom : float = 10.0
var look_at_player : bool = true
var secondary_target : Node

@onready var camera = $Camera

func _ready():
	camera_rotation = rotation_degrees # Initial rotation
	zoom = default_zoom
	pass

func _physics_process(delta):
	#Close the app
	if Input.is_action_pressed("close_app"):
		close_app()
	
	if look_at_player:
		# Set position and rotation to targets
		
		self.position = self.position.lerp(target.position, delta * 4)
		rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
		
		camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
		
		handle_input(delta)
	else:
		if secondary_target:
			self.position = self.position.lerp(secondary_target.position, delta * 4)
			camera.look_at(secondary_target.position,Vector3.UP)
			camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)

# Handle input

func look_at_target(_target):
	get_tree().paused = true
	secondary_target = _target
	look_at_player = false
	await get_tree().create_timer(2).timeout
	get_tree().paused = false
	look_at_player = true

func handle_input(delta):
	
	# Rotation
	
	var input := Vector3.ZERO
	
	input.y = Input.get_axis("camera_right","camera_left")
	input.x = Input.get_axis("camera_down","camera_up")
	
	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, camera_angle_min, camera_angle_max)
	
	# Zooming
	
	zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)

func close_app() -> void:
	get_tree().quit()
