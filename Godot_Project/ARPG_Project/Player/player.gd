extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var ACCELERATTON =500
export var MAX_SPEED =80
export var FOLL_SPEED =120
export var FRICTION =500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state =MOVE
var velocity =Vector2.ZERO
var roll_vector =Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer =$AnimationPlayer
onready var animaionTree = $AnimationTree
onready var animationState = animaionTree.get("parameters/playback")
onready var swordHitbox =$HltboxPlvot/SwordHltbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnlmationPlayer

func _ready():
	randomize()
	stats.connect("no_health",self,"queue_free")
	animaionTree.active =true
	swordHitbox.knockback_vector = roll_vector
	

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
			
		ROLL:
			roll_state(delta)
			
		ATTACK:
			attack_state(delta)


func move_state(delta):
	var input_vector =Vector2.ZERO
	input_vector.x=Input.get_action_strength("ui_right") -Input.get_action_strength("ui_left")
	input_vector.y=Input.get_action_strength("ui_down") -Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector=input_vector
	
		animaionTree.set("parameters/Idle/blend_position",input_vector)
		animaionTree.set("parameters/Run/blend_position",input_vector)
		animaionTree.set("parameters/Attack/blend_position",input_vector)
		animaionTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		velocity =velocity.move_toward(input_vector * MAX_SPEED,ACCELERATTON * delta)

	else:
		animationState.travel("Idle")
		velocity=velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state =ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func roll_state(delta):
	velocity =roll_vector * FOLL_SPEED
	animationState.travel("Roll")
	move()
	
func attack_state(delta):
	velocity =Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity * 0.8
	state =MOVE
	
func attack_animation_finished():
	state =MOVE


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
