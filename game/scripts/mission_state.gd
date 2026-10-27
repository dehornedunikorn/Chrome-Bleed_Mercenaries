extends RefCounted
class_name MissionState

## Data and rules for the first playable mission. UI remains in main.gd.

const GRID_SIZE := 7
const MOVE_RANGE := 3
const ATTACK_RANGE := 5
const EXTRACTION_CELL := 48
const WALLS := [8, 9, 15, 16, 22, 23, 25, 26, 32, 33, 39]

var units: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var selected_unit := -1
var courier_cell := 3
var courier_rescued := false
var carrier_index := -1
var turn := 1
var credits := 1250
var completed := false
var failed := false
var last_message := "Válassz ki egy zsoldost."
var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()
	restart()


func restart() -> void:
	units = [
		{"name": "Vega", "role": "Felderítő", "cell": 29, "hp": 8, "max_hp": 8, "ap": 2},
		{"name": "Patch", "role": "Technikus", "cell": 36, "hp": 7, "max_hp": 7, "ap": 2},
		{"name": "Rook", "role": "Nehezék", "cell": 43, "hp": 10, "max_hp": 10, "ap": 2},
	]
	enemies = [
		{"name": "Piacőr", "cell": 12, "hp": 2},
		{"name": "Piacőr", "cell": 17, "hp": 2},
	]
	selected_unit = -1
	courier_cell = 3
	courier_rescued = false
	carrier_index = -1
	turn = 1
	completed = false
	failed = false
	last_message = "Válassz ki egy zsoldost, majd tervezzétek meg az előrenyomulást."


func unit_at(cell: int) -> int:
	for index in range(units.size()):
		if int(units[index]["cell"]) == cell and int(units[index]["hp"]) > 0:
			return index
	return -1


func enemy_at(cell: int) -> int:
	for index in range(enemies.size()):
		if int(enemies[index]["cell"]) == cell and int(enemies[index]["hp"]) > 0:
			return index
	return -1


func active_courier_cell() -> int:
	if courier_rescued and carrier_index >= 0:
		return int(units[carrier_index]["cell"])
	return courier_cell


func select_unit(index: int) -> String:
	if index < 0 or index >= units.size() or int(units[index]["hp"]) <= 0:
		return "Ez a zsoldos harcképtelen."
	selected_unit = index
	var unit: Dictionary = units[index]
	last_message = "%s kijelölve · %d HP · %d AP." % [unit["name"], unit["hp"], unit["ap"]]
	return last_message


func move_selected_to(destination: int) -> String:
	if completed or failed:
		return last_message
	if selected_unit < 0:
		return "Előbb jelölj ki egy zsoldost."
	var unit: Dictionary = units[selected_unit]
	if int(unit["hp"]) <= 0:
		return "Ez a zsoldos harcképtelen."
	if int(unit["ap"]) < 1:
		return "%s kifogyott az akciópontokból. Zárd le a kört." % unit["name"]
	if destination < 0 or destination >= GRID_SIZE * GRID_SIZE:
		return "Ez a mező nem érhető el."
	if destination == active_courier_cell() and not courier_rescued:
		return "A futár mezőjére nem léphetsz. Használd a mentés akciót mellette."
	if destination in WALLS or enemy_at(destination) >= 0 or unit_at(destination) >= 0:
		return "Az út vagy a célmező foglalt."
	var distance := _path_distance(int(unit["cell"]), destination, selected_unit)
	if distance < 1 or distance > MOVE_RANGE:
		return "A célmező nincs mozgástávon belül, vagy nincs járható út."
	unit["cell"] = destination
	unit["ap"] = int(unit["ap"]) - 1
	last_message = "%s fedezékbe mozgott (%d mező, 1 AP)." % [unit["name"], distance]
	return last_message


func fire_at(target_cell: int) -> String:
	if completed or failed:
		return last_message
	if selected_unit < 0:
		return "Előbb jelölj ki egy zsoldost."
	var target_index := enemy_at(target_cell)
	if target_index < 0:
		return "Válassz egy látható ellenfelet."
	var shooter: Dictionary = units[selected_unit]
	var enemy: Dictionary = enemies[target_index]
	if int(shooter["hp"]) <= 0:
		return "Ez a zsoldos harcképtelen."
	if int(shooter["ap"]) < 1:
		return "%s kifogyott az akciópontokból." % shooter["name"]
	var distance := _distance(int(shooter["cell"]), int(enemy["cell"]))
	if distance > ATTACK_RANGE or not _has_line_of_sight(int(shooter["cell"]), int(enemy["cell"])):
		return "Nincs tiszta lövés: túl messze van vagy takarásban áll."
	shooter["ap"] = int(shooter["ap"]) - 1
	var hit_chance := 0.75
	if _has_adjacent_cover(int(enemy["cell"])):
		hit_chance -= 0.20
	if rng.randf() <= hit_chance:
		enemy["hp"] = int(enemy["hp"]) - 1
		if int(enemy["hp"]) <= 0:
			last_message = "%s lövése harcképtelenné tette a %s-t." % [shooter["name"], enemy["name"]]
		else:
			last_message = "%s eltalálta a %s-t. Még %d HP-ja van." % [shooter["name"], enemy["name"], enemy["hp"]]
	else:
		last_message = "%s lövése célt tévesztett." % shooter["name"]
	return last_message


func interact() -> String:
	if completed or failed:
		return last_message
	if selected_unit < 0:
		return "Előbb jelölj ki egy zsoldost."
	var unit: Dictionary = units[selected_unit]
	if int(unit["hp"]) <= 0:
		return "Ez a zsoldos harcképtelen."
	if int(unit["ap"]) < 1:
		return "%s kifogyott az akciópontokból." % unit["name"]
	if not courier_rescued:
		if _distance(int(unit["cell"]), courier_cell) > 1:
			return "A futár nincs karnyújtásnyira. Vidd mellé az egyik zsoldost."
		unit["ap"] = int(unit["ap"]) - 1
		courier_rescued = true
		carrier_index = selected_unit
		last_message = "%s kimentette a futárt. Jussatok el a kijárathoz (↗)." % unit["name"]
		return last_message
	if selected_unit != carrier_index:
		return "A futárt vivő zsoldost válaszd ki a kivonuláshoz."
	if int(unit["cell"]) != EXTRACTION_CELL:
		return "Vidd a futárt a térkép kijáratához (↗)."
	unit["ap"] = int(unit["ap"]) - 1
	completed = true
	credits += 800
	last_message = "Sikeres kivonás. A megbízó átutalta a ₡ 800 jutalmat."
	return last_message


func end_player_turn() -> String:
	if completed or failed:
		return last_message
	var events: Array[String] = []
	for enemy_index in range(enemies.size()):
		var enemy: Dictionary = enemies[enemy_index]
		if int(enemy["hp"]) <= 0:
			continue
		var target_index := _nearest_living_unit(int(enemy["cell"]))
		if target_index < 0:
			failed = true
			last_message = "A teljes csapat harcképtelen. A bevetés elbukott."
			return last_message
		var target: Dictionary = units[target_index]
		if _distance(int(enemy["cell"]), int(target["cell"])) <= 4 and _has_line_of_sight(int(enemy["cell"]), int(target["cell"])):
			var chance := 0.55 if _has_adjacent_cover(int(target["cell"])) else 0.70
			if rng.randf() <= chance:
				target["hp"] = maxi(0, int(target["hp"]) - 2)
				events.append("%s találata: %s %d HP-n." % [enemy["name"], target["name"], target["hp"]])
			else:
				events.append("%s lövése célt tévesztett." % enemy["name"])
		else:
			var next_cell := _step_toward(int(enemy["cell"]), int(target["cell"]))
			if next_cell >= 0:
				enemy["cell"] = next_cell
				events.append("%s előrenyomult." % enemy["name"])
	if _nearest_living_unit(0) < 0:
		failed = true
		last_message = "A teljes csapat harcképtelen. A bevetés elbukott."
		return last_message
	turn += 1
	for unit in units:
		if int(unit["hp"]) > 0:
			unit["ap"] = 2
	selected_unit = -1
	var event_summary := "Az ellenfelek nem jutottak lövéshez."
	if not events.is_empty():
		event_summary = ""
		for event in events:
			event_summary += event + " "
	last_message = "Kör %d. %s" % [turn, event_summary]
	return last_message


func _nearest_living_unit(from_cell: int) -> int:
	var result := -1
	var best_distance := 999
	for index in range(units.size()):
		var unit: Dictionary = units[index]
		if int(unit["hp"]) <= 0:
			continue
		var distance := _distance(from_cell, int(unit["cell"]))
		if distance < best_distance:
			best_distance = distance
			result = index
	return result


func _step_toward(from_cell: int, target_cell: int) -> int:
	var best_cell := -1
	var best_distance := _distance(from_cell, target_cell)
	for candidate in _neighbors(from_cell):
		if candidate in WALLS or enemy_at(candidate) >= 0 or unit_at(candidate) >= 0:
			continue
		if not courier_rescued and candidate == courier_cell:
			continue
		var distance := _distance(candidate, target_cell)
		if distance < best_distance:
			best_distance = distance
			best_cell = candidate
	return best_cell


func _path_distance(start: int, destination: int, moving_unit: int) -> int:
	var queue: Array[int] = [start]
	var distances: Dictionary = {start: 0}
	while not queue.is_empty():
		var current: int = queue.pop_front()
		if current == destination:
			return int(distances[current])
		if int(distances[current]) >= MOVE_RANGE:
			continue
		for neighbor in _neighbors(current):
			if distances.has(neighbor) or neighbor in WALLS or enemy_at(neighbor) >= 0:
				continue
			if not courier_rescued and neighbor == courier_cell:
				continue
			var occupant := unit_at(neighbor)
			if occupant >= 0 and occupant != moving_unit:
				continue
			distances[neighbor] = int(distances[current]) + 1
			queue.append(neighbor)
	return 999


func _neighbors(cell: int) -> Array[int]:
	var result: Array[int] = []
	var x := cell % GRID_SIZE
	var y := floori(float(cell) / GRID_SIZE)
	for delta in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		var next_x: int = x + delta.x
		var next_y: int = y + delta.y
		if next_x >= 0 and next_x < GRID_SIZE and next_y >= 0 and next_y < GRID_SIZE:
			result.append(next_y * GRID_SIZE + next_x)
	return result


func _distance(first: int, second: int) -> int:
	return absi(first % GRID_SIZE - second % GRID_SIZE) + absi(floori(float(first) / GRID_SIZE) - floori(float(second) / GRID_SIZE))


func _has_line_of_sight(first: int, second: int) -> bool:
	var x0 := first % GRID_SIZE
	var y0 := floori(float(first) / GRID_SIZE)
	var x1 := second % GRID_SIZE
	var y1 := floori(float(second) / GRID_SIZE)
	var dx := absi(x1 - x0)
	var sx := 1 if x0 < x1 else -1
	var dy := -absi(y1 - y0)
	var sy := 1 if y0 < y1 else -1
	var error := dx + dy
	while true:
		var cell := y0 * GRID_SIZE + x0
		if cell != first and cell != second and cell in WALLS:
			return false
		if x0 == x1 and y0 == y1:
			return true
		var twice_error := 2 * error
		if twice_error >= dy:
			error += dy
			x0 += sx
		if twice_error <= dx:
			error += dx
			y0 += sy
	return true


func _has_adjacent_cover(cell: int) -> bool:
	for neighbor in _neighbors(cell):
		if neighbor in WALLS:
			return true
	return false
