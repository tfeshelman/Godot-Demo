extends CharacterBody2D

# Set up variables/constants
const SPEED = 450
const GRAVITY = 80
const JUMP_FORCE = -1300
var isFirstJump = true
const CAMERA_OFFSET_HORIZONTAL = 100.0
const CAMERA_OFFSET_VERTICAL = 200.0
var currentCamPos = Vector2()
var isLookingUp

func _physics_process(_delta):
	
	isLookingUp = false

	# Sets floor check for double jump
	if is_on_floor(): isFirstJump = true
	
	# Controls pressed Right
	if Input.is_action_pressed("right"):
		velocity.x = SPEED
		$Sprite2D.play("walk")
		$Sprite2D.flip_h = false
	# Controls pressed Left
	elif Input.is_action_pressed("left"):
		velocity.x = -SPEED
		$Sprite2D.play("walk")
		$Sprite2D.flip_h = true
	else: 
		$Sprite2D.play("idle")


	# Look up mechanic
#	if Input.is_action_pressed("look up"):
#		await get_tree().create_timer(0.2).timeout
#		isLookingUp = true
#		currentCamPos.y = $TheCamera.position.y
#		$TheCamera.position.y = lerp($TheCamera.position.y, -CAMERA_OFFSET_VERTICAL, 0.08)
	
	

	# Gives smoothed, forward leeway on camera based on facing direction
	if !$Sprite2D.flip_h:
		$TheCamera.position.x = lerp($TheCamera.position.x, CAMERA_OFFSET_HORIZONTAL, 0.08)
	if $Sprite2D.flip_h:
		$TheCamera.position.x = lerp($TheCamera.position.x, -CAMERA_OFFSET_HORIZONTAL, 0.08)
	
	# Performs *First* jump
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_FORCE
		isFirstJump = true
	# Checks if first jump or not, then does allows for double jump
	elif Input.is_action_just_pressed("jump") && isFirstJump:
		velocity.y = (JUMP_FORCE * 0.8)
		isFirstJump = false
	
	# Checks air position based on speed, then applies correct animation
	if !is_on_floor():
		if velocity.y <= 50:
			$Sprite2D.play("air")
		if velocity.y >= 50:
			$Sprite2D.play("crouch")
	
	# Applies gravity
	velocity.y += GRAVITY
	move_and_slide()
	
	# Applies walking deceleration
	velocity.x = lerp(velocity.x, 0.0, 0.8)

	# Reloads the scene if a fall is detected
func _on_fall_zone_body_entered(body:Node2D) -> void:
	get_tree().call_deferred("reload_current_scene")