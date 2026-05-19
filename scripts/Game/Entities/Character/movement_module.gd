extends Node

@onready var MovingArea: Area2D
@onready var playerModule: Node = get_parent()
var character: CharacterBody2D

var boundryPolygon
var isMoving: bool
var outsideArea: bool = false
var inCamera: bool = false

func _movementProcess(delta):
	if not playerModule:
		playerModule = get_parent()
		return
	character = playerModule.player
	isMoving = playerModule.StatusModule.isMoving
	var oldPos = character.position
		
	if not isMoving and not playerModule.StatusModule.onAir:
		character.velocity.x /= 1.4
		character.velocity.y /= 1.4
	character.move_and_slide()
	
	if MovingArea and not Geometry2D.is_point_in_polygon(character.position, boundryPolygon):
		#position = oldPos
		outsideArea = true
		snapInsidePolygon()
	else:
		outsideArea = false
	
	if character.Camera:
		snapInsideCamera()
		

################################################################################
#####                             Functions                                #####
################################################################################

func setInputMovement(movement: Vector2, speed: Vector2):
	if movement != Vector2.ZERO:
		playerModule.StatusModule.isMoving = true
		if movement.x < 0:
			playerModule.StatusModule.setLookDir(-1)
		elif movement.x > 0:
			playerModule.StatusModule.setLookDir(1)
		moveTo(Vector2(movement.x * speed.x, movement.y * speed.y), speed)
	elif not playerModule.StatusModule.onAir: 
		playerModule.StatusModule.isMoving = false
		
func addMovement(movement: Vector2):
	setMovement(movement + character.velocity)
	
func setMovement(movement: Vector2):
	character.velocity = movement
	
func applyForce(force: Vector2, newHeightSpeed: float):
	addMovement(force)
	playerModule.HeightModule.addHeightSpeed(newHeightSpeed)
	if newHeightSpeed != 0:
		playerModule.StatusModule.isMoving = true

func applyForceV3(force: Vector3):
	applyForce(Vector2(force.x,force.z), force.y)

func setForce(force: Vector2, newHeightSpeed: float):
	applyForce(force-character.velocity, newHeightSpeed-playerModule.HeightModule.heightSpeed)

func setForceV3(force: Vector3):
	setForce(Vector2(force.x,force.z), force.y)
	

################################################################################
#####                              Utility                                 #####
################################################################################

func moveTo(movement: Vector2, maxSpeed: Vector2 = Vector2(10000,10000)):
	moveXTo(movement.x, maxSpeed.x)
	moveYTo(movement.y, maxSpeed.y)

func moveXTo(movementX: float, maxSpeedX: float):
	if playerModule.StatusModule.onAir:
		character.velocity.x = max(-maxSpeedX,min(maxSpeedX,movementX/10+character.velocity.x))
	else:
		character.velocity.x = max(-maxSpeedX,min(maxSpeedX,movementX))
	
func moveYTo(movementY: float, maxSpeedY: float):
	if playerModule.StatusModule.onAir:
		character.velocity.y = max(-maxSpeedY,min(maxSpeedY,movementY/10+character.velocity.y))
	else:
		character.velocity.y = movementY

func snapInsidePolygon():
	# If inside, distance is zero

	var min_distance := INF
	var min_distPos = null

	for i in boundryPolygon.size():
		var a = boundryPolygon[i]
		var b = boundryPolygon[(i + 1) % boundryPolygon.size()]

		var closest = Geometry2D.get_closest_point_to_segment(character.position, a, b)
		var dist = character.position.distance_to(closest)

		if dist < min_distance:
			min_distance = dist
			min_distPos = closest
			
	if min_distPos: 
		character.position = min_distPos
		character.velocity.y = 0
		#character.velocity = Vector2.ZERO

func snapInsideCamera():
	var camera = character.Camera
	var camPos = camera.global_position
	var camSize = camera.get_viewport_rect().size/2-Vector2(character.CollisionBox.shape.radius,character.CollisionBox.shape.radius)
	
	if not inCamera:
		inCamera = character.global_position.x < camPos.x+camSize.x and character.global_position.x > camPos.x-camSize.x
	else:
		if character.global_position.x > camPos.x+camSize.x:
			character.global_position.x = camPos.x+camSize.x
			character.velocity.x = 0
		elif character.global_position.x < camPos.x-camSize.x:
			character.global_position.x = camPos.x-camSize.x
			character.velocity.x = 0
