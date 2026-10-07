extends CanvasLayer

# 预加载三张像素爱心贴图，改成你自己图片路径
var tex_full: Texture2D = preload("res://assets/kenney/tiles/tile_0044.png")
var tex_half: Texture2D = preload("res://assets/kenney/tiles/tile_0045.png")
var tex_empty: Texture2D = preload("res://assets/kenney/tiles/tile_0046.png")

# 5颗爱心节点数组
@onready var heart_nodes: Array[TextureRect] = [
	$HeartContainer/heart0,
	$HeartContainer/heart1,
	$HeartContainer/heart2,
	$HeartContainer/heart3,
	$HeartContainer/heart4
]

# 玩家节点路径！！
@onready var _player: CharacterBody2D = $"../Level/ActorsAndCharacters/Player"

func _ready() -> void:
	is_dead = false
	if _player == null:
		print("找不到玩家！检查节点路径！")
		return
	_player.health_changed.connect(update_hearts)
	_player.died.connect(on_player_dead) # 绑定死亡信号
	update_hearts(_player.current_health, _player.MAX_HEALTH)

# 更新爱心UI的核心函数
func update_hearts(hp: float, _max_hp: float) -> void:
	for i in range(5):
		# 当前爱心对应的血量区间
		var heart_start = i * 2.0
		var heart_end = (i+1) * 2.0
		if hp >= heart_end:
			# 满血爱心
			heart_nodes[i].texture = tex_full
		elif hp > heart_start:
			# 半颗爱心
			heart_nodes[i].texture = tex_half
		else:
			# 空爱心
			heart_nodes[i].texture = tex_empty


var is_dead: bool = false  # 新增：死亡标记

# 玩家死亡触发
func on_player_dead():
	is_dead = true
	print("玩家死亡，按F重新开始")

# 检测按键
func _input(_event: InputEvent):
	if is_dead and Input.is_key_pressed(KEY_F):
		get_tree().reload_current_scene()
