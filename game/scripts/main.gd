extends Control

## Mobile-first native prototype shell. Keep game rules out of UI code as the
## prototype grows; see ../docs/ANDROID_GAME_PRODUCTION.md for the architecture.

const PANEL := Color("111722")
const CYAN := Color("61f2e4")
const MUTED := Color("91a0b3")

var page: VBoxContainer
var turn_number := 1
var selected_unit := -1
var unit_positions := [29, 36, 43]
var enemy_positions := [12, 17]
var enemy_health := [2, 2]
var courier_position := 3
var shot_mode := false


func _ready() -> void:
	_show_hq()


func _new_page(title: String, subtitle: String) -> VBoxContainer:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var safe_area := MarginContainer.new()
	safe_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_area.add_theme_constant_override("margin_left", 20)
	safe_area.add_theme_constant_override("margin_top", 22)
	safe_area.add_theme_constant_override("margin_right", 20)
	safe_area.add_theme_constant_override("margin_bottom", 22)
	add_child(safe_area)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	safe_area.add_child(scroll)
	page = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 14)
	scroll.add_child(page)

	var brand := Label.new()
	brand.text = "CHROME-BLEED MERCENARIES  ·  ₡ 1 250"
	brand.add_theme_color_override("font_color", CYAN)
	page.add_child(brand)
	var heading := Label.new()
	heading.text = title
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_size_override("font_size", 28)
	page.add_child(heading)
	var intro := Label.new()
	intro.text = subtitle
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_color_override("font_color", MUTED)
	page.add_child(intro)
	return page


func _add_button(label: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0, 54)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	page.add_child(button)
	return button


func _show_hq() -> void:
	_new_page("A városnak mindig van egy piszkos munkája.", "Szabadúszó zsoldos iroda · 01. nap\n\nHírnév 04   ·   Csapat 03/04   ·   Adósság ₡ 8 400")
	var contract := PanelContainer.new()
	contract.add_theme_stylebox_override("panel", _panel_style())
	page.add_child(contract)
	var details := VBoxContainer.new()
	contract.add_child(details)
	var mission := Label.new()
	mission.text = "ELTŰNT ADATFUTÁR\n\nHozd ki a futárt a neonpiacról. A megbízó ₡ 800-at fizet."
	mission.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission.add_theme_constant_override("margin_left", 14)
	mission.add_theme_constant_override("margin_right", 14)
	details.add_child(mission)
	_add_button("Bevetés indítása", _show_combat)
	_add_button("Csapat és felszerelés  ·  hamarosan", _show_stub)
	_add_button("Küldetések és várostérkép  ·  hamarosan", _show_stub)


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = Color("263244")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style


func _show_combat() -> void:
	_new_page("NEONPIAC  ·  BEVETÉS 01", "KÖR %d  ·  TE JÖSSZ\nJelölj ki egy zsoldost, majd egy mezőt." % turn_number)
	var board := GridContainer.new()
	board.columns = 7
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.add_theme_constant_override("h_separation", 4)
	board.add_theme_constant_override("v_separation", 4)
	page.add_child(board)
	for cell in range(49):
		var tile := Button.new()
		tile.custom_minimum_size = Vector2(38, 48)
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tile.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tile.text = _cell_mark(cell)
		if selected_unit >= 0 and cell == unit_positions[selected_unit]:
			tile.modulate = CYAN
		tile.pressed.connect(_on_cell_pressed.bind(cell))
		board.add_child(tile)
	_add_button("Célzás visszavonása" if shot_mode else "Lövés", _toggle_shot)
	_add_button("Futár kimentése", _rescue_courier)
	_add_button("Kör vége", _end_turn)
	_add_button("Vissza a főhadiszállásra", _show_hq)


func _cell_mark(cell: int) -> String:
	if cell in [8, 9, 15, 16, 22, 23, 25, 26, 32, 33, 39]:
		return "▧"
	if cell == courier_position:
		return "▣"
	if cell in enemy_positions:
		return "◆"
	if cell == unit_positions[0]:
		return "V"
	if cell == unit_positions[1]:
		return "P"
	if cell == unit_positions[2]:
		return "R"
	return "·"


func _on_cell_pressed(cell: int) -> void:
	if shot_mode:
		var enemy_index := enemy_positions.find(cell)
		if enemy_index >= 0:
			enemy_health[enemy_index] -= 1
			if enemy_health[enemy_index] <= 0:
				enemy_positions.remove_at(enemy_index)
				enemy_health.remove_at(enemy_index)
			shot_mode = false
			_show_combat()
		return
	var unit_index := unit_positions.find(cell)
	if unit_index >= 0:
		selected_unit = unit_index
		_show_combat()
		return
	if selected_unit >= 0 and cell != courier_position and not cell in [8, 9, 15, 16, 22, 23, 25, 26, 32, 33, 39] and not cell in enemy_positions and not cell in unit_positions:
		var old_pos: int = unit_positions[selected_unit]
		var distance: int = absi(cell % 7 - old_pos % 7) + absi(floori(cell / 7.0) - floori(old_pos / 7.0))
		if distance > 3:
			return
		unit_positions[selected_unit] = cell
		selected_unit = -1
		_show_combat()


func _end_turn() -> void:
	turn_number += 1
	_show_combat()


func _toggle_shot() -> void:
	if selected_unit < 0:
		return
	shot_mode = not shot_mode
	_show_combat()


func _rescue_courier() -> void:
	if selected_unit < 0:
		return
	var position: int = unit_positions[selected_unit]
	var distance: int = absi(position % 7 - courier_position % 7) + absi(floori(position / 7.0) - floori(courier_position / 7.0))
	if distance <= 1:
		_new_page("A futár kijutott.", "A csapat teljesítette az első megbízást. A város most már tudja, hogy létezel.\n\nA filmes átvezetők a kampány teljes változatában élőszereplős videók lesznek.")
		_add_button("Vissza a főhadiszállásra", _show_hq)


func _show_stub() -> void:
	_new_page("Ez a játékrendszer következik", "A csapatkezelés, a részletes taktikai szabályok és a kampány a gyártási terv szerint kerül be. A mostani natív alap a telefonos méretezést és az Android exportot célozza.")
	_add_button("Vissza", _show_hq)
