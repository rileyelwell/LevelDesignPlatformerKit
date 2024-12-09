extends Node3D

@export var respawn : bool = true
@export var respawn_delay : float = 2.0
@onready var platform_falling_collision_shape_3d: CollisionShape3D = %"platform-falling_collisionShape3D"
@onready var platform_falling_2: MeshInstance3D = $"platform-falling2"
@onready var falling_platform_animation_player: AnimationPlayer = $FallingPlatformAnimationPlayer
@onready var audio_stream_player_3D: AudioStreamPlayer3D = $AudioStreamPlayer3D

var falling := false
var gravity := 0.0
var starting_pos : Vector3
var respawn_sequence_started : bool = false

func _ready() -> void:
	starting_pos = global_position

func _process(delta):
	position.y -= gravity * delta
	
	if (starting_pos.y - position.y) > 20:
		if respawn and not respawn_sequence_started:
			respawn_sequence_started = true
			platform_falling_collision_shape_3d.disabled = true
			platform_falling_2.scale = Vector3.ZERO
			visible = false
			falling = false
			gravity = 0
			await get_tree().create_timer(respawn_delay).timeout
			falling_platform_animation_player.play("respawn")
		elif not respawn:
			queue_free() # Remove platform if below threshold
	else:
		scale = scale.lerp(Vector3(1, 1, 1), delta * 10) # Animate scale

	if falling:
		gravity += 0.25

func restore_platform() -> void:
	global_position = starting_pos
	platform_falling_collision_shape_3d.disabled = false
	visible = true
	respawn_sequence_started = false

func _on_body_entered(_body):
	if !falling:
		#Audio.play("res://sounds/fall.ogg") # Play sound
		audio_stream_player_3D.play()
		scale = Vector3(1.25, 1, 1.25) # Animate scale
		
	falling = true
