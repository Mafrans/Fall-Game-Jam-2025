class_name ShakeableCamera extends Camera2D


var shaking := false
var remaining_time : float = 0
var elapsed_time : float = 0

#strength controlls the overall magnitude of the shake
#while smoothness controlls how smooth motion is, kind of "anti-strength"

var smoothness :float = 0.5 #0-1, higher values smooth out the shake motion more so that it's less jarring
var current_strength :float = 0

static var instance: ShakeableCamera

func _ready() -> void:
	instance = self

func rand_offset_from_strength()-> Vector2:
	var vec = Vector2()
	vec.x = randf_range(-current_strength, current_strength)
	vec.y = randf_range(-current_strength, current_strength)
	return vec

func shake(time:float, strength: float):
	
	#If the camera is already shaking, then
		#reset the elapsed time and remaining time of the shake
		#boost the strength of the shake, so that shakes have an additive effect
	remaining_time = time
	current_strength += strength 
	elapsed_time = 0.0
	
	
	var offset_position := Vector2(0,0)
	var offset_rotation = 0
	
	#If shakes overlap, any subsequent call only effects the shake by changing
	#the variables. The first call handles the actual shaking.
	if not shaking:
		shaking = true
		while elapsed_time < remaining_time:
			
			#gradually decay the strength
			current_strength = lerpf(current_strength, 0, elapsed_time/remaining_time)
			
			#smooth motion in the offset between random values
			offset_position = offset_position.lerp(rand_offset_from_strength(), 1-smoothness)
			
			#lerp back towards zero offset over time
			offset_position = offset_position.lerp(Vector2(0,0), elapsed_time/remaining_time)
			offset = offset_position
			
			#if you want to add rotation to the shake, uncomment the line below 
			#rotation = lerpf(randf_range(deg_to_rad(0),deg_to_rad(0)),0, elapsed_time/remaining_time)
			
			elapsed_time += get_process_delta_time()
			await get_tree().process_frame
			
		shaking = false
