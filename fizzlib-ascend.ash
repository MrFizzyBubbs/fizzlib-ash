import <fizzlib-utils.ash>


boolean canAscend(boolean casual) {
	if (!get_property("kingLiberated").to_boolean())
		return false;
	
	string page = visit_url(`ascensionhistory.php?back=self&who={my_id()}`);
	string today = now_to_string("MM/dd/yy");
	
	string pattern;
	if (casual)
		pattern = `{today}(?:(?!<\/tr>).)+title="Casual"><\/td><\/tr>`;
	else
		pattern = `{today}(?:(?!<\/tr>|title="Casual"><\/td>).)+<\/tr>`;
	
	matcher match = create_matcher(pattern, page);
	return !find(match);
}

boolean canAscendNoncasual() {
	return canAscend(false);
}

boolean canAscendCasual() {
	return canAscend(true);
}

record pathInfo {
	string name;
	int id;
	boolean [class] classes;
};

// Sourced from https://github.com/kolmafia/kolmafia/blob/main/src/net/sourceforge/kolmafia/pathInfo.java
pathInfo [string] paths = {
	"NONE": new pathInfo("None", 0),
	"BOOZETAFARIAN": new pathInfo("Boozetafarian", 1),
	"TEETOTALER": new pathInfo("Teetotaler", 2),
	"OXYGENARIAN": new pathInfo("Oxygenarian", 3),
	"BEES_HATE_YOU": new pathInfo("Bees Hate You", 4),
	"SURPRISING_FIST": new pathInfo("Way of the Surprising Fist", 6),
	"TRENDY": new pathInfo("Trendy", 7),
	"AVATAR_OF_BORIS": new pathInfo("Avatar of Boris", 8, $classes[Avatar of Boris]),
	"BUGBEAR_INVASION": new pathInfo("Bugbear Invasion", 9),
	"ZOMBIE_SLAYER": new pathInfo("Zombie Slayer", 10, $classes[Zombie Master]),
	"CLASS_ACT": new pathInfo("Class Act", 11),
	"AVATAR_OF_JARLSBERG": new pathInfo("Avatar of Jarlsberg", 12, $classes[Avatar of Jarlsberg]),
	"BIG": new pathInfo("BIG!", 14),
	"KOLHS": new pathInfo("KOLHS", 15),
	"CLASS_ACT_II": new pathInfo("Class Act II: A Class For Pigs", 16),
	"AVATAR_OF_SNEAKY_PETE": new pathInfo("Avatar of Sneaky Pete", 17, $classes[Avatar of Sneaky Pete]),
	"SLOW_AND_STEADY": new pathInfo("Slow and Steady", 18),
	"HEAVY_RAINS": new pathInfo("Heavy Rains", 19),
	"PICKY": new pathInfo("Picky", 21),
	"STANDARD": new pathInfo("Standard", 22),
	"ACTUALLY_ED_THE_UNDYING": new pathInfo("Actually Ed the Undying", 23, $classes[Ed the Undying]),
	"CRAZY_RANDOM_SUMMER": new pathInfo("One Crazy Random Summer", 24),
	"COMMUNITY_SERVICE": new pathInfo("Community Service", 25),
	"AVATAR_OF_WEST_OF_LOATHING": new pathInfo("Avatar of West of Loathing", 26, $classes[Cow Puncher, Beanslinger, Snake Oiler]),
	"THE_SOURCE": new pathInfo("The Source", 27),
	"NUCLEAR_AUTUMN": new pathInfo("Nuclear Autumn", 28),
	"GELATINOUS_NOOB": new pathInfo("Gelatinous Noob", 29, $classes[Gelatinous Noob]),
	"LICENSE_TO_ADVENTURE": new pathInfo("License to Adventure", 30),
	"LIVE_ASCEND_REPEAT": new pathInfo("Live. Ascend. Repeat.", 31),
	"POKEFAM": new pathInfo("Pocket Familiars", 32),
	"GLOVER": new pathInfo("G-Lover", 33),
	"DISGUISES_DELIMIT": new pathInfo("Disguises Delimit", 34),
	"DARK_GYFFTE": new pathInfo("Dark Gyffte", 35, $classes[Vampyre]),
	"CRAZY_RANDOM_SUMMER_TWO": new pathInfo("Two Crazy Random Summer", 36),
	"KINGDOM_OF_EXPLOATHING": new pathInfo("Kingdom of Exploathing", 37),
	"PATH_OF_THE_PLUMBER": new pathInfo("Path of the Plumber", 38, $classes[Plumber]),
	"LOWKEY": new pathInfo("Low Key Summer", 39),
	"GREY_GOO": new pathInfo("Grey Goo", 40),
	"YOU_ROBOT": new pathInfo("You, Robot", 41),
	"QUANTUM": new pathInfo("Quantum Terrarium", 42),
	"WILDFIRE": new pathInfo("Wildfire", 43),
	"GREY_YOU": new pathInfo("Grey You", 44),
};

// Assign the regular six classes if classes are not specified
foreach _, path in paths {
	if (count(path.classes) == 0) {
		path.classes = $classes[Seal Clubber, Turtle Tamer, Pastamancer, Sauceror, Disco Bandit, Accordion Thief];
	}
}

int toLifestyleId(string lifestyle) {
	switch (lifestyle) {
		case "casual": return 1;
		case "softcore":
		case "normal": return 2;
		case "hardcore": return 3;
		default:
			abort(`Invalid lifestyle "{lifestyle}"`);
			return -1;
	}
}

int toMoonId(string moon) {
	switch (moon) {
		case "Mongoose": return 1;
		case "Wallaby": return 2;
		case "Vole": return 3;
		case "Platypus": return 4;
		case "Opossum": return 5;
		case "Marmot": return 6;
		case "Wombat": return 7;
		case "Blendar": return 8;
		case "Packrat": return 9;
		default: 
			abort(`Invalid moon "{moon}"`);
			return -1;
	}
}

void ascend(pathInfo path, class playerClass, string lifestyle, string moon, item consumable, item pet) {
	int lifestyleId = toLifestyleId(lifestyle);
	if (!visit_url("charpane.php").contains_text("Astral Spirit")) {
		assert(!haveOrganSpace(), "Organ space available");
		assert(my_adventures() == 0, "Adventures available");
		assert(pvp_attacks_left() == 0, "PvP fites available");
		assert(lifestyleId != 1 || canAscendCasual(), "Already ascended into a casual run today");
		assert(lifestyleId == 1 || canAscendNoncasual(), "Already ascended into a non-casual run today");
		visit_url("ascend.php?action=ascend&confirm=on&confirm2=on");
	}
	assert(visit_url("charpane.php").contains_text("Astral Spirit"), "Failed to ascend");
	assert(path.classes contains playerClass, `Invalid class "{playerClass}" for path "{path.name}"`);
	
	int moonId = toMoonId(moon);
	assert(
		$items[none, astral six-pack, astral hot dog dinner, [10882]carton of astral energy drinks] contains consumable,
		`Invalid consumable "{consumable}"`
	);
	assert(
		$items[none, astral bludgeon, astral shield, astral chapeau, astral bracer, astral longbow, astral shorts, astral mace, astral ring, astral statuette, astral pistol, astral mask, astral pet sweater, astral shirt, astral belt] contains pet,
		`Invalid astral item "{pet}"`
	);
	
	visit_url("afterlife.php?action=pearlygates");
	if (consumable != $item[none]) visit_url(`afterlife.php?action=buydeli&whichitem={consumable.to_int()}`);
	if (pet != $item[none]) visit_url(`afterlife.php?action=buyarmory&whichitem={pet.to_int()}`);

	visit_url(`afterlife.php?action=ascend&confirmascend=1&whichsign=${moonId}&gender=1&whichclass={playerClass.to_int()}&whichpath={path.id}&asctype={lifestyleId}&nopetok=1&noskillsok=1&pwd`, true); // &lamepathok=1&lamesignok=1
}

boolean [item] worksheds = $items[
	warbear lp-rom burner,
	warbear jackhammer drill press,
	warbear induction oven,
	warbear high-efficiency still,
	warbear chemistry lab,
	warbear auto-anvil,
	spinning wheel,
	snow machine,
	Little Geneticist DNA-Splicing Lab,
	portable Mayo Clinic,
	Asdon Martin keyfob,
	diabolic pizza cube,
	cold medicine cabinet,
];

boolean [item] gardens = $items[
	packet of pumpkin seeds,
	Peppermint Pip Packet, 
	packet of dragon's teeth, 
	packet of beer seeds, 
	packet of winter seeds, 
	packet of thanksgarden seeds, 
	packet of tall grass seeds, 
	packet of mushroom spores,
];

boolean [item] eudorae = $items[
	My Own Pen Pal kit,
	GameInformPowerDailyPro subscription card,
	Xi Receiver Unit,
	New-You Club Membership Form,
	Our Daily Candles&trade; order form,
];

boolean [item] chateauDesks = $items[fancy stationery set, Swiss piggy bank, continental juice bar];
boolean [item] chateauCeilings = $items[antler chandelier, ceiling fan, artificial skylight];
boolean [item] chateauNightstands = $items[foreign language tapes, bowl of potpourri, electric muscle stimulator];

void prepareAscension(item workshed, item garden, item eudora, item chateauDesk, item chateauCeiling, item chateauNightstand) {
	if (workshed != $item[none] && get_workshed() != workshed) {
		assert(worksheds contains workshed, `Invalid workshed "{workshed}"`);
		use(1, workshed);
		assert(get_workshed() == workshed, `Failed to change workshed to {workshed}`);
	}
	
	if (garden != $item[none] && !(get_campground() contains garden)) {
		assert(gardens contains garden, `Invalid garden "{garden}"`);
		use(1, garden);
		assert(get_campground() contains garden, `Failed to change garden to {garden}`);
	}
	
	if (eudora != $item[none] && eudora_item() != eudora) {
		assert(eudorae contains eudora, `Invalid eudora "{eudora}"`);
		eudora(eudora.name);
		assert(eudora_item() == eudora, `Failed to change eudora to {eudora}`);
	}
	
	if (get_property("chateauAvailable").to_boolean()) {
		if (!(get_chateau() contains chateauDesk)) {
			assert(chateauDesks contains chateauDesk, `Invalid chateau desk "{chateauDesk}"`);
			buy(1, chateauDesk);
			assert(get_chateau() contains chateauDesk, `Failed to change chateau desk to {chateauDesk}`);
		}
		
		if (!(get_chateau() contains chateauCeiling)) {
			assert(chateauCeilings contains chateauCeiling, `Invalid chateau ceiling "{chateauCeiling}"`);
			buy(1, chateauCeiling);
			assert(get_chateau() contains chateauCeiling, `Failed to change chateau ceiling to {chateauCeiling}`);
		}
		
		if (!(get_chateau() contains chateauNightstand)) {
			assert(chateauNightstands contains chateauNightstand, `Invalid chateau nightstand "{chateauNightstand}"`);
			buy(1, chateauNightstand);
			assert(get_chateau() contains chateauNightstand, `Failed to change chateau nightstand to {chateauNightstand}`);
		}
	}
}

void main() {
	dump(eudorae);
}