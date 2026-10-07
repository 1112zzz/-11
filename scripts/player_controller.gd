extends CharacterBody2D
signal health_changed
signal died
@export_category("移动参数")
@export var move_speed: float = 75.0
@export var acceleration: float = 600.0
@export var deceleration: float = 800.0
@export var jump_velocity: float = -190.0
@export var speed: float = 300.0
@export var jump_force: float = 400.0
@export var gravity: float = 1800.0
@export var max_jumps: int = 2 # 二连跳，最多跳2次

var jumps_left: int = max_jumps

@onready var sprite: Sprite2D = $Sprite2D
var has_key = false
var flying : bool = false
var last_space_press_time := -1000
# ========== 冲刺新增变量 ==========
var dash_speed = 1500.0      # 冲刺速度
var dash_duration = 0.12    # 冲刺持续时间（秒）
var dash_cooldown = 0.8     # 冲刺冷却
var dash_timer = 0.0
var dash_cd_timer = 0.0
var is_dashing = false
# ==================================


func _physics_process(delta: float) -> void:
# 左右移动
	var input_dir: float = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * speed
	# 冲刺冷却计时
	if dash_cd_timer > 0:
		dash_cd_timer -= delta
		# 冲刺逻辑
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		# 按下冲刺按键，并且冷却结束
		if Input.is_action_just_pressed("dash") and dash_cd_timer <= 0:
			is_dashing = true
			dash_timer = dash_duration
			dash_cd_timer = dash_cooldown
			# 冲刺方向，和玩家面朝方向一致
			var dir = Input.get_axis("move_left", "move_right")
			if dir == 0: # 原地冲刺默认向右
				dir = 1
				velocity.x = dir * dash_speed

	# 【原有左右移动逻辑】只有不在冲刺的时候，才可以正常走路
	if not is_dashing:
		var horizontal_input = Input.get_axis("move_left", "move_right")
		velocity.x = horizontal_input * speed
	
	# 重力、跳跃（你原来的代码保留不动）
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	move_and_slide()
	# 重力
	velocity.y += gravity * delta

	# 跳跃逻辑
	if Input.is_action_just_pressed("jump"):
		if jumps_left > 0:
			velocity.y = -jump_force
			jumps_left -= 1

	# 落地重置跳跃次数
	if is_on_floor():
		jumps_left = max_jumps

   
	if !flying:
		apply_gravity(delta)
		handle_jump()
	else:
		handle_vertical_movement(delta)
	
	handle_horizontal_movement(delta)
	update_sprite_direction()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_vertical_movement(delta:float) -> void:
	var direction := Input.get_axis("squat", "jump")
	var target_speed := direction * jump_velocity
	
	if direction != 0.0:
		velocity.y = move_toward(
				velocity.y,
				target_speed,
				acceleration * delta
		)
	else:
		velocity.y = move_toward(
				velocity.y,
				0.0,
				acceleration * delta
		)
	
func handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var target_speed := direction * move_speed

	if direction != 0.0:
		velocity.x = move_toward(
				velocity.x,
				target_speed,
				acceleration * delta
		)
	else:
		velocity.x = move_toward(
				velocity.x,
				0.0,
				deceleration * delta
		)


func update_sprite_direction() -> void:
	if velocity.x != 0.0:
		sprite.flip_h = velocity.x < 0.0
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fly") and !event.is_echo():
		handle_space_pressed()
	
func handle_space_pressed() -> void:
	handle_jump()


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		if jumps_left > 0:
			velocity.y = -jump_force
			jumps_left -= 1
	if is_on_floor():
		jumps_left = 2

const MAX_HEALTH := 10.0
var current_health: float = MAX_HEALTH

func _update_health():
	current_health = clampf(current_health, 0.0, MAX_HEALTH)
	health_changed.emit(current_health, MAX_HEALTH)

func take_damage(amount: float) -> void:
	if current_health <= 0.0:
		return
	current_health -= amount
	_update_health()
	if current_health <= 0.0:
		died.emit()
		get_tree().change_scene_to_file.call_deferred("res://assets/game/jieshu/game_over1.tscn")

func heal(amount: float) -> void:
	current_health += amount
	_update_health()



func _on_key_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.


	
	
