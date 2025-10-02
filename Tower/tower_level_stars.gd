class_name TowerLevelStars extends VBoxContainer

@export var star_texture: Texture2D
@export var max_stars: int = 3
@export var hat_after_max_stars: Texture2D

var num_stars: int = 0
var star_images: Array[TextureRect] = []
var has_star_hat: bool = false


func _ready() -> void:
	for _x in range(num_stars):
		add_star()


func _process(_delta: float) -> void:
	if num_stars > len(star_images):
		if len(star_images) < max_stars:
			add_star()
		else:
			add_star_hat()


func add_star() -> void:
	var star_image = add_texture_rect_child(star_texture)
	star_images.append(star_image)
	add_child(star_image)


func add_star_hat() -> void:
	if has_star_hat:
		return
	has_star_hat = true
	var star_hat = add_texture_rect_child(hat_after_max_stars)
	move_child(star_hat, 0)


func add_texture_rect_child(texture: Texture2D) -> TextureRect:
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.ExpandMode.EXPAND_FIT_HEIGHT_PROPORTIONAL
	add_child(texture_rect)
	return texture_rect
