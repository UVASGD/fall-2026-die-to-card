extends Level

var dice: Array

func enter():
	pass

func exit():
	pass

func add_die(die):
	dice.append(die)
	return dice

func remove_rightmost_die():
	return dice.pop_back()

func remove_leftmost_die():
	return dice.pop_front()

func remove_die(die):
	return 
