extends Node2D

var timer_duration: float = 60.0
var current_time: float = 0.0
var print_timer: Timer
@onready var timeText = get_node("timeText")

func _ready():
	print_timer = Timer.new()
	print_timer.wait_time = 1.0
	print_timer.one_shot = false
	print_timer.timeout.connect(_printTimeLeft)
	add_child(print_timer)

	startTimer()

func startTimer():
	current_time = timer_duration
	print_timer.start()

func _printTimeLeft():
	print("Time left:", current_time)
	timeText.text = "Time Left: " + str(current_time)
	current_time -= 1.0
	if current_time < 0:
		print_timer.stop()
		print("Timer expired!")
		# Perform your desired actions here
