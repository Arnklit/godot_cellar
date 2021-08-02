extends Spatial


export var ammount := 0.006
var timer := 0.0


func _ready() -> void:
	timer += rand_range(0.0, 10.0)


func _process(delta: float) -> void:
	timer += delta * 5.0;
	transform.origin += Vector3(
		sin(timer * 3.75) * ammount * 0.02 + sin(timer * 6.7) * ammount * .00235, 
		sin(timer * 4.0) * ammount * 0.08 + sin(timer * 7.7) * ammount * .0356, 
		sin(timer * 5.195) * ammount * 0.02 + sin(timer * 8.9) * ammount * .00315
	)
