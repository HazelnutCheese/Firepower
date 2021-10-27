extends Spatial

onready var healthBar3d : Sprite3D = $HealthBar3d
onready var viewport : Viewport = $HealthBar3d/Viewport
onready var healthBar : TextureProgress = $HealthBar3d/Viewport/HealthBar

func _ready():
	healthBar3d.texture = viewport.get_texture()

func _updateHealth(percentage):
	healthBar.value = percentage
