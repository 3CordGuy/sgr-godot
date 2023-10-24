extends CharacterBody2D


const SPEED = 80
const SPRINT_SPEED = 120
const JUMP_VELOCITY = -235.0
const SUPER_JUMP_VELOCITY = -280

var cur_jump_velocity = JUMP_VELOCITY
var cur_speed = SPEED
var has_double_jump = true
var milestone_count = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("AnimatedSprite2D")


func _on_milestone_collected():
	print("collected 1")
	milestone_count += 1


func jump(is_super: bool):
	if is_super:
		cur_jump_velocity = SUPER_JUMP_VELOCITY
		$SuperJumpWAV.play()
	else:
		$JumpWAV.play()
		cur_jump_velocity = JUMP_VELOCITY
	velocity.y = cur_jump_velocity
	anim.play("jump")
	$CoyoteTime.stop()
	$JumpTimer.stop()

func _ready():
	#get_parent().get_node("Level1").connect("milestone_collected", _on_milestone_collected) 
	anim.play('idle')

func _physics_process(delta):
	# Add the gravity. 
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# Handle grace period jump
		if velocity.y > 0 and Input.is_action_just_pressed("jump"):
			$JumpTimer.start()
			
	# Land on floor
	if is_on_floor():
		has_double_jump = true
		$CoyoteTime.start()
		if $JumpTimer.time_left > 0: 
			jump(false)

	# Handle Jumps
	if Input.is_action_just_pressed("jump") and (is_on_floor() or $CoyoteTime.time_left > 0):
		if Input.is_action_pressed("down"):
			jump(true)
		else:
			jump(false)
			
	if Input.is_action_just_pressed("jump") and velocity.y > 0 and has_double_jump:
		jump(false)
		has_double_jump = false
		
	# Handle sprint modifier
	if Input.is_action_pressed("sprint"):
		cur_speed = SPRINT_SPEED
		anim.speed_scale = 1.5
	else:
		cur_speed = SPEED
		anim.speed_scale = 1
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false

	if direction:
		velocity.x = direction * cur_speed
		if velocity.y == 0:
			anim.play("walk")
	else:
		if velocity.y == 0:
			if Input.is_action_pressed("down"):
				anim.play("duck")
			else:
				anim.play("idle")
			
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.y > 0:
		anim.play("fall")
		
	# Handle Poofs
	if is_on_floor() and velocity.x != 0:
		$Poof.emitting = true
	else:
		$Poof.emitting = false
		
		
	if self.position.y > 256:
		get_tree().change_scene_to_file("res://summary.tscn")
		
	move_and_slide()



func _on_goal_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://summary.tscn")
	


func _on_milestone_body_entered(body):
	if body.name == "Player":
		print(body)
