extends Control

const GAME_SCENE: String = "res://scenes/Game/Gametest.tscn"

# Cada entrada tiene:
# "image"   → ruta a la imagen (res://images/cutscenes/CutsceneX.png)
# "es"      → texto en español
# "en"      → texto en inglés
var cutscene_data: Array[Dictionary] = [
	{
		"image": "res://images/Cutscene/Cutscene1.png",
		"es": "Este mundo es un lugar muy vasto, desde tiempos inmemoriales no había manera de descifrar cómo de entre toda esta barbarie y descontrol de alguna manera todo se equilibraba de vuelta y hacía de nuestro mundo un lugar habitable.\n\nLos elementos, fuerzas más allá de nuestra comprensión que fueron los vestigios que nuestros dioses dejaron atrás en aquella época donde el planeta empezó a brotar sus primeras señales de vida, una infinidad en el pasado.\n\nEsta fuerza de los elementos fue lo que permitió dar inicio a la vida, la voluntad de aquellas entidades que ya no están con nosotros, dejándonos a nuestra voluntad de cuidar de este mundo y evolucionar junto a él.\n\nPero ahora que no hay nadie que vigile el desarrollo de todas las criaturas, cada día brotan más 'anomalías' que no somos capaces de explicar, las hemos denominado por un nuevo elemento: 'CAOS'.",
		"en": "Within this vast world, there has never been a way to understand how it is that among all this madness and havoc there seemed to be a balance that put everything together and somehow made these lands a liveable place.\n\nThe elements, concepts beyond our comprehension that are but vestiges left behind by our gods an infinity ago, back when the planet was but only starting to bloom its very first signs of life.\n\nThese elements are what allowed life itself to grow and prosper, the will of those beings that are no longer with us, leaving us to our own devices to care for this world and evolve along with it.\n\nBut now that there's nobody to watch over our growth, each day new 'anomalies' which we are unable to explain are discovered, we believe this is due to a new unknown and dangerous element: 'CHAOS'."
	},
	{
		"image": "res://images/Cutscene/Cutscene2.png",
		"es": "De entre todas estas anomalías, una destaca como la más temible; el Señor Oscuro, una entidad de un poder inimaginable sobre la oscuridad y lo desconocido.\n\nUn día apareció de la nada junto con su temible palacio, estableciendo su territorio y sembrando el terror con su mera presencia, tanta fue que ninguna criatura se atrevió a plantarle cara durante años. Nadie ha visto al Señor Oscuro en persona, se rumorea que carga con una enorme armadura que esconde su verdadero rostro, pero nadie que haya ido a enfrentarlo ha sido capaz de volver como para contarlo.\n\nSin embargo… Recientemente, un acontecimiento de lo más chocante ha cambiado las tornas en esta historia.\n\nUn rumor, en el que se cuenta de que aquel que logre acabar con la vida del Señor Oscuro recibirá no solo todo su poder, sino que también un deseo con el que podrán hacer realidad lo que su alma quisiera.",
		"en": "Among all of these anomalies, one sticks out as the most fearsome; the Dark Lord, an entity with an unimaginable amount of power over darkness and the unknown.\n\nHe appeared one day out of nowhere alongside his palace, claiming his domain and spreading fear with his mere presence, so much so that nobody dared to face him for years. Nobody has seen the Dark Lord in person, it is said that he wears a massive armor that hides his true face, but nobody that has faced him has been able to come back to tell the tale.\n\nHowever… Recently, a most shocking event has changed this story as we know it.\n\nA rumor, in which it is said that whoever is capable of ending his life will not only gain his powers, but also a wish with which they'll be able to make whatever their soul wishes come true."
	},
	{
		"image": "res://images/Cutscene/Cutscene3.png",
		"es": "Estas palabras se esparcieron como pólvora a lo largo y ancho del mundo, llegando a tal punto que lo impensable sucedió: le pusieron precio a la cabeza del Señor Oscuro, la más alta jamás vista.\n\nUn deseo, poder, riqueza, todo por acabar con la vida del ser más poderoso del mundo.\n\nMuchos creyeron que no era más que un bulo, pero incluso así, muchas personas pusieron rumbo hacia su palacio para darle caza, pero por ahora nadie ha sido capaz de vencerle, y muchos menos siquiera pudieron llegar a las puertas del palacio.",
		"en": "These words were spread all over the world, to the point that something unbelievable happened: a bounty was put on the Dark Lord's head, the largest sum of treasures ever seen.\n\nA wish, power, riches, all for whoever is able to kill the most powerful being in the world.\n\nMany believed this to be no more than a hoax, but even so, many people marched on to the Dark Lord's palace to hunt him down, yet nobody has been able to defeat him to this day, and many more couldn't even make it to his palace gates."
	},
	{
		"image": "res://images/Cutscene/Cutscene4.png",
		"es": "Nadie sabe con certeza quién fue el que puso este precio a su cabeza, pero los carteles aparecieron por todas partes, por lo que se sospecha que debe ser alguien con gran influencia.\n\nFue tal el alcance de la noticia que llegaron hasta los rincones más recónditos del mundo, incluso de aquellos que se refugiaban del exterior.\n\nAsí fue como una seta de un bosque del sur llegó a toparse con uno de estos carteles, tal fue su sorpresa que se llevó el cartel para mostrárselo a sus compañeros.",
		"en": "Nobody knows for sure who put the bounty on the Dark Lord's head, yet the wanted posters popped up everywhere, so it is believed it must be someone of great influence and power.\n\nThe magnitude of the news was such that it managed to reach even the most hidden and cramped crannies of the planet, even reaching those who shut themselves away from the rest of the world.\n\nThat was how a mushroom from a forest to the south ended up coming across one of these wanted posters, his shock was such that he ran back to show the poster to his two friends."
	},
	{
		"image": "res://images/Cutscene/Cutscene5.png",
		"es": "Esta seta, de nombre Glyke, presentó el cartel a las otras dos setas con las que vivía: Ovie, su amigo cercano de la infancia, y Cynner, la bruja del bosque y dueña de la casa en la que se alojaban.\n\nGlyke insistió que esto se trataba de un tema de lo más importante, a pesar de que sus dos compañeros no mostraban mucho interés inicialmente…",
		"en": "This mushroom named Glyke showed the poster to the other two mushrooms that he lived with: Ovie, his closest friend since childhood, and Cynner, the witch of this forest and owner of the house they were staying at.\n\nGlyke insisted that this was a very serious situation, despite neither of his friends showing much interest initially…"
	},
	{
		"image": "res://images/Cutscene/Cutscene 6.png",
		"es": "Los tres miraron el cartel con detenimiento para confirmar sus sospechas, no podían creerlo, ¡alguien verdaderamente había puesto precio a la cabeza del Señor Oscuro!\n\nGlyke echaba ascuas de la rabia, ya era hora de que alguien plantara cara a este representante de la impureza y el mal en el mundo, esto era una señal de que debía de actuar y marchar para acabar con él con sus propias manos.\n\nSería un viaje largo y terriblemente duro, el exterior era peligroso y completamente desconocido para unas setas, pero por su honor como paladín estaba dispuesto a plantarle cara a la muerte para proclamar justicia sobre este villano.",
		"en": "The three of them observed the poster with detail to confirm their suspicions, they couldn't believe it, somebody really put a bounty on the Dark Lord's head!\n\nGlyke was seething with rage, it was about time that somebody faced this embodiment of all the impurity and evil in the world, this was a sign that he had to act and put an end to him with his own hands.\n\nIt'd be a long and arduous journey, the rest of the world was dangerous and completely unknown to shrooms like them, but by his honor as a paladin he was willing to face death head on and bring this fiend to justice."
	},
	{
		"image": "res://images/Cutscene/Cutscene 7.png",
		"es": "Por su cuenta, Ovie y Cynner estaban más enfocados en la recompensa por el Señor Oscuro, no podían creer la cantidad de dinero que ofrecían por la cabeza de este tipo.\n\n'¡Un deseo sin límites! ¿¡Te das cuenta de lo que podríamos hacer con tal poder Ovie!?' exclamó Cynner a su compañero, animándolo a unirse a ella en fantasear sobre todo lo que conseguirán una vez cacen al Señor Oscuro.\n\nOvie por fin podrá ser conocido como un héroe popular como siempre quiso, Cynner por fin podrá hacer lo que quiera con todo el dinero que conseguirá, ¡serán las dos personas con más poder e influencia de todo el planeta!",
		"en": "Meanwhile, Ovie and Cynner were more focused on the reward for the Dark Lord; they couldn't believe the sheer amount of money that they offered for this dude's head.\n\n'A wish with no limits! Do you realize all the stuff we could do with such power Ovie?!' Cynner squealed, hyping him up to join her in this daydreaming venture as they thought of all they'd gain by killing the Dark Lord.\n\nOvie would finally be known as the popular hero he'd always wished to be, Cynner would finally be able to do whatever she pleased with that insane amount of riches, they'd be the most powerful and influential people in the world!"
	},
	{
		"image": "res://images/Cutscene/Cutscene 8.png",
		"es": "Su sesión de fantaseo fue concluida por Glyke de manera repentina, quien les recordó lo seria que era la situación con 'amabilidad', esto era un viaje de vida o muerte no unas vacaciones.\n\nTras una bronca no demasiado larga entre Cynner y Glyke, los tres compañeros cogieron todo su equipaje para poner rumbo hacia el norte y plantarle cara al Señor Oscuro, prometiendo 'intentar' trabajar en equipo para poder cumplir su objetivo.",
		"en": "Their daydreaming session was cut short by Glyke all of a sudden, who 'kindly' reminded them of their current situation, this was a journey where their lives would be at stake not some vacations.\n\nAfter a not too long argument between Cynner and Glyke, the three friends grabbed all their stuff to begin their journey to the north so they could face the Dark Lord, promising to 'try' and work together as a team to get that wish."
	},
	{
		"image": "res://images/Cutscene/Cutscene 9.png",
		"es": "Debido a su manera de vivir, ninguno de los tres estaba muy acostumbrado a viajar más allá del bosque, por miedo a lo que se puedan encontrar en tierras remotas, pero no tendrán más remedio que hacerlo por primera vez si quieren llegar al palacio.\n\nSu primer obstáculo será superar el enorme pantano que se encuentra entre su hogar en el bosque y el resto del mundo, el pantano Mohruma, plagado de criaturas territoriales que pondrán a prueba su fuerza.\n\nSi no son capaces de superar las pruebas del pantano no tendrán oportunidad contra el resto del mundo. ¡Toca demostrar que estas setas son más capaces de lo que aparentan!",
		"en": "Due to their way of living, none of them were all too used to journeying beyond the forest out of fear of whatever they may encounter within unknown territory, but they have no choice but face this fear head on if they wanted to reach that palace.\n\nTheir first obstacle would be to go through the massive swamp that separated their forest from the rest of the world, Mohruma Swamp, filled to the brim with very territorial creatures that would put their strength to the test.\n\nIf they weren't able to overcome the trials of the swamp they'd stand no chance against whatever lies out there. It was time for them to show that these mushrooms were more capable than they look!"
	},
]

var current_index: int = 0

@onready var cutscene_image: TextureRect = $CutsceneImage
@onready var subtitle_label: Label       = $SubtitleBar/SubtitleLabel
@onready var arrow_right: Control        = $ArrowRight
@onready var arrow_left: Control         = $ArrowLeft
@onready var btn_next: Button            = $BtnNext
@onready var btn_prev: Button            = $BtnPrev
@onready var fade_overlay: ColorRect     = $FadeOverlay


func _ready() -> void:
	fade_overlay.modulate.a = 1.0
	_show_cutscene(current_index)
	_fade_in()


func _get_text(data: Dictionary) -> String:
	# Detecta el idioma activo en el motor
	var lang: String = TranslationServer.get_locale().substr(0, 2)
	if lang == "es" and data.has("es"):
		return data["es"]
	elif data.has("en"):
		return data["en"]
	return ""


func _show_cutscene(index: int) -> void:
	var data: Dictionary = cutscene_data[index]

	# Imagen
	var img_path: String = data.get("image", "")
	if img_path != "" and ResourceLoader.exists(img_path):
		cutscene_image.texture = load(img_path)
		cutscene_image.visible = true
	else:
		cutscene_image.texture = null
		cutscene_image.visible = false

	# Texto según idioma
	subtitle_label.text = _get_text(data)

	# Flechas: derecha siempre visible, izquierda solo desde cutscene 2
	arrow_right.visible = true
	arrow_left.visible = (index > 0)

	# Botones invisibles: primera cutscene → next ocupa toda la pantalla
	# resto → next mitad derecha, prev mitad izquierda
	if index == 0:
		btn_next.anchor_left = 0.0
	else:
		btn_next.anchor_left = 0.5

	btn_prev.visible = (index > 0)


func _fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.6)


func _fade_and_go(callback: Callable) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.4)
	tween.tween_callback(callback)


func _on_btn_next_pressed() -> void:
	if current_index < cutscene_data.size() - 1:
		current_index += 1
		_fade_and_go(_after_fade_next)
	else:
		_fade_and_go(_go_to_game)


func _after_fade_next() -> void:
	_show_cutscene(current_index)
	_fade_in()


func _on_btn_prev_pressed() -> void:
	if current_index > 0:
		current_index -= 1
		_fade_and_go(_after_fade_prev)


func _after_fade_prev() -> void:
	_show_cutscene(current_index)
	_fade_in()


func _go_to_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
