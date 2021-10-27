extends CanvasLayer

onready var healthBar : ColorRect = $HealthBar

func _updateHealth(percentage):
	var maxWidth = 700.0
	var newWidth = 700.0 * (percentage / 100.0)
	healthBar.set_size(Vector2(newWidth, 40))


