extends Control

const MissionStateScript = preload("res://scripts/mission_state.gd")
const PANEL_COLOR := Color("111722")
const CYAN := Color("61f2e4")
const PINK := Color("ff4fa3")
const AMBER := Color("ffca72")
const MUTED := Color("91a0b3")
const BACKGROUND := Color("080b12")
const WALL_CELLS := [8, 9, 15, 16, 22, 23, 25, 26, 32, 33, 39]

var mission = MissionStateScript.new()
var page: VBoxContainer
var status_label: Label
var attack_mode := false


func _ready() -> void:
	_show_hq()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
	var grid_color := Color(0.19, 0.85, 0.82, 0.045)
	for x in range(24, int(size.x), 48):
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
	for y in range(16, int(size.y), 48):
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)
	draw_line(Vector2(size.x * 0.68, 0), Vector2(size.x, size.y * 0.2), Color(0.38, 0.95, 0.88, 0.12), 2.0)
	draw_line(Vector2(size.x, size.y * 0.2), Vector2(size.x, size.y * 0.42), Color(1.0, 0.31, 0.64, 0.1), 2.0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _new_page(title: String, subtitle: String) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var safe_area := MarginContainer.new()
	safe_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_area.add_theme_constant_override("margin_left", 18)
	safe_area.add_theme_constant_override("margin_top", 20)
	safe_area.add_theme_constant_override("margin_right", 18)
	safe_area.add_theme_constant_override("margin_bottom", 20)
	add_child(safe_area)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	safe_area.add_child(scroll)
	page = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 12)
	scroll.add_child(page)

	var brand := Label.new()
	brand.text = "CHROME-BLEED MERCENARIES  ·  ₡ %s" % _format_credits(mission.credits)
	brand.add_theme_color_override("font_color", CYAN)
	brand.add_theme_font_size_override("font_size", 13)
	page.add_child(brand)

	var heading := Label.new()
	heading.text = title
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_size_override("font_size", 26)
	heading.add_theme_color_override("font_color", Color("eef7ff"))
	page.add_child(heading)

	var intro := Label.new()
	intro.text = subtitle
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_color_override("font_color", MUTED)
	page.add_child(intro)


func _add_button(label: String, callback: Callable, primary := false) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0, 54)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 16)
	var normal := StyleBoxFlat.new()
	normal.bg_color = CYAN if primary else PANEL_COLOR
	normal.border_color = CYAN if primary else Color("34445b")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	button.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("294b4d") if primary else Color("1b2838")
	button.add_theme_stylebox_override("hover", hover)
	if primary:
		button.add_theme_color_override("font_color", Color("071313"))
	button.pressed.connect(callback)
	page.add_child(button)
	return button


func _format_credits(amount: int) -> String:
	var digits := str(amount)
	var result := ""
	while digits.length() > 3:
		result = " " + digits.substr(digits.length() - 3, 3) + result
		digits = digits.substr(0, digits.length() - 3)
	return digits + result


func _show_hq() -> void:
	attack_mode = false
	_new_page(
		"A városnak mindig van egy piszkos munkája.",
		"Szabadúszó zsoldos iroda · 01. nap\nHírnév 04 · Csapat 03/04 · Adósság ₡ 8 400"
	)
	var contract := PanelContainer.new()
	contract.add_theme_stylebox_override("panel", _panel_style())
	page.add_child(contract)
	var details := VBoxContainer.new()
	contract.add_child(details)
	var mission_card := Label.new()
	mission_card.text = "ELTŰNT ADATFUTÁR\n\nHozd ki a futárt a neonpiacról. Jussatok el a kijárathoz; a megbízó ₡ 800-at fizet."
	mission_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_card.add_theme_font_size_override("font_size", 17)
	details.add_child(mission_card)

	var crew := Label.new()
	crew.text = "VEGA · Felderítő · 8 HP\nPATCH · Technikus · 7 HP\nROOK · Nehezék · 10 HP"
	crew.add_theme_color_override("font_color", MUTED)
	page.add_child(crew)
	_add_button("Bevetés indítása", _start_mission, true)
	var next_step := Label.new()
	next_step.text = "A kampány és a csapatfejlesztés a következő szakaszban épül tovább."
	next_step.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_step.add_theme_color_override("font_color", MUTED)
	page.add_child(next_step)


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = Color("28616a")
	style.set_border_width_all(1)
	style.border_width_left = 3
	style.set_corner_radius_all(12)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style


func _start_mission() -> void:
	mission.restart()
	attack_mode = false
	_show_combat()


func _show_combat() -> void:
	_new_page(
		"NEONPIAC  ·  BEVETÉS 01",
		"KÖR %d  ·  TE JÖSSZ%s" % [mission.turn, "  ·  CÉLZÁS: válassz ellenfelet" if attack_mode else ""]
	)

	var roster := HBoxContainer.new()
	roster.add_theme_constant_override("separation", 6)
	page.add_child(roster)
	for index in range(mission.units.size()):
		var unit: Dictionary = mission.units[index]
		var card := Label.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.text = "%s\n%d/%d HP\n%d AP" % [unit["name"], unit["hp"], unit["max_hp"], unit["ap"]]
		card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_theme_color_override("font_color", CYAN if index == mission.selected_unit else MUTED)
		card.add_theme_font_size_override("font_size", 12)
		roster.add_child(card)

	var board := GridContainer.new()
	board.columns = MissionStateScript.GRID_SIZE
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.add_theme_constant_override("h_separation", 3)
	board.add_theme_constant_override("v_separation", 3)
	page.add_child(board)
	for cell in range(MissionStateScript.GRID_SIZE * MissionStateScript.GRID_SIZE):
		var tile := Button.new()
		tile.custom_minimum_size = Vector2(40, 46)
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tile.text = _cell_mark(cell)
		tile.add_theme_font_size_override("font_size", 15)
		tile.add_theme_color_override("font_color", _cell_color(cell))
		tile.add_theme_stylebox_override("normal", _tile_style(cell))
		tile.pressed.connect(_on_cell_pressed.bind(cell))
		board.add_child(tile)

	status_label = Label.new()
	status_label.text = mission.last_message
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(0, 48)
	page.add_child(status_label)

	_add_button("Lövés" if not attack_mode else "Célzás visszavonása", _toggle_attack)
	_add_button("Futármentés / kivonás", _interact)
	_add_button("Kör vége", _end_turn)
	_add_button("Vissza a főhadiszállásra", _show_hq)


func _cell_mark(cell: int) -> String:
	if cell == MissionStateScript.EXTRACTION_CELL:
		return "↗"
	if cell in WALL_CELLS:
		return "▧"
	if mission.courier_rescued and mission.active_courier_cell() == cell:
		return "◎"
	if not mission.courier_rescued and mission.courier_cell == cell:
		return "▣"
	var unit_index: int = mission.unit_at(cell)
	if unit_index >= 0:
		return ["V", "P", "R"][unit_index]
	if mission.enemy_at(cell) >= 0:
		return "◆"
	return "·"


func _cell_color(cell: int) -> Color:
	if cell == MissionStateScript.EXTRACTION_CELL:
		return AMBER
	if cell in WALL_CELLS:
		return Color("b9c7d5")
	if mission.courier_rescued and mission.active_courier_cell() == cell:
		return AMBER
	if not mission.courier_rescued and mission.courier_cell == cell:
		return PINK
	if mission.unit_at(cell) == mission.selected_unit and mission.selected_unit >= 0:
		return CYAN
	if mission.enemy_at(cell) >= 0:
		return PINK
	return Color("d3deeb")


func _tile_style(cell: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("172432")
	style.border_color = Color("2c3d50")
	if cell in WALL_CELLS:
		style.bg_color = Color("384858")
		style.border_color = Color("728a9c")
	elif mission.unit_at(cell) == mission.selected_unit and mission.selected_unit >= 0:
		style.bg_color = Color("123536")
		style.border_color = CYAN
		style.set_border_width_all(2)
	elif mission.enemy_at(cell) >= 0:
		style.bg_color = Color("381c30")
		style.border_color = PINK
	elif cell == MissionStateScript.EXTRACTION_CELL:
		style.bg_color = Color("3a3020")
		style.border_color = AMBER
	elif (not mission.courier_rescued and cell == mission.courier_cell) or (mission.courier_rescued and cell == mission.active_courier_cell()):
		style.bg_color = Color("38212d")
		style.border_color = PINK
	style.set_border_width_all(1)
	if cell == MissionStateScript.EXTRACTION_CELL or (mission.unit_at(cell) == mission.selected_unit and mission.selected_unit >= 0):
		style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style


func _on_cell_pressed(cell: int) -> void:
	if mission.completed or mission.failed:
		return
	if attack_mode:
		_set_message(mission.fire_at(cell))
		attack_mode = false
		_refresh_or_finish()
		return
	var clicked_unit: int = mission.unit_at(cell)
	if clicked_unit >= 0:
		_set_message(mission.select_unit(clicked_unit))
	else:
		_set_message(mission.move_selected_to(cell))
	_refresh_or_finish()


func _toggle_attack() -> void:
	if mission.selected_unit < 0:
		_set_message("Előbb jelölj ki egy zsoldost.")
		return
	attack_mode = not attack_mode
	_set_message("Koppints a célpontra. A falak blokkolják a lövést." if attack_mode else "Célzás megszakítva.")
	_show_combat()


func _interact() -> void:
	_set_message(mission.interact())
	_refresh_or_finish()


func _end_turn() -> void:
	attack_mode = false
	_set_message(mission.end_player_turn())
	_refresh_or_finish()


func _set_message(message: String) -> void:
	mission.last_message = message


func _refresh_or_finish() -> void:
	if mission.completed or mission.failed:
		_show_outcome()
	else:
		_show_combat()


func _show_outcome() -> void:
	attack_mode = false
	if mission.completed:
		_new_page(
			"MOZGÓKÉPES ÁTVEZETŐ  ·  B-FILM HANGULAT",
			"A futár kijutott. A város figyelni kezdett rád."
		)
		_add_button("Sikeres megbízás · +₡ 800", _show_hq, true)
	else:
		_new_page(
			"MOZGÓKÉPES ÁTVEZETŐ  ·  A MELÓ FÉLREMENT",
			"A csapat harcképtelen. A végleges kampányban ezt teljes videós jelenet követi."
		)
		_add_button("Újrapróbálás", _start_mission, true)
		_add_button("Vissza a főhadiszállásra", _show_hq)

