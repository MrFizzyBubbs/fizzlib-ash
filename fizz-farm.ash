import <fizzlib.ash>


void dupeInDmt(item it) {
	assert(isDmtDupable(it), `Item {it} is not duplicatable in the DMT`);
	assert(item_amount(it) > 0, `Need item {it} in inventory to duplicate`);
	
	if (get_property("lastDMTDuplication").to_int() != my_ascensions()) {
		assert(get_property("encountersUntilDMTChoice").to_int() == 0, "DMT choice adv is not ready");
		use_familiar($familiar[machine elf]);
		visit_url("adventure.php?snarfblat=458");
		assert(handling_choice() && last_choice() == 1119, "Failed to encounter DMT choice adv");
		visit_url("choice.php?pwd&whichchoice=1119&option=4");
		visit_url(`choice.php?whichchoice=1125&pwd&option=1&iid={it.to_int()}`);
	}
}

void getCalderaCoin() {
	while (get_property("lastDoghouseVolcoino") != my_ascensions()) {		
		acquire($effect[A Few Extra Pounds]);
		acquire($effect[Big]);
		adv1($location[The Bubblin' Caldera], -1, mNew().mAttackRepeat());
		if ($location[The Bubblin' Caldera].noncombat_queue.contains_text("Lava Dogs")) {
			set_property("lastDoghouseVolcoino", my_ascensions());
		}
		assert(!have($effect[beaten up]), "We got beaten up");
	}
	
	if (have($effect[Drenched in Lava])) cli_execute("hottub");
	assert(!have($effect[Drenched in Lava]), "Failed to get rid of Drenched in Lava");
}

void afterPrismBreak() {
	cli_execute("pull all; uneffect Feeling Lost; counters clear; peevpee.php?action=smashstone&confirm=on; backupcamera reverser on");
	put_closet(my_meat() - 2000000);
	tryUse($item[can of Rain-Doh]);
	tryUse($item[astral six-pack]);
	
	equip($slot[hat], $item[Daylight Shavings Helmet]);
	equip($slot[weapon], $item[Fourth of May Cosplay Saber]);
	equip($slot[off-hand], $item[KoL Con 13 snowglobe]);
	equip($slot[back], $item[Buddy Bjorn]);
	
	//equip($slot[shirt], $item[Sneaky Pete's leather jacket]);
	equip($slot[pants], $item[Cargo Cultist Shorts]);
	equip($slot[acc1], $item[lucky gold ring]);
	equip($slot[acc2], $item[Mr. Screege's spectacles]);
	equip($slot[acc3], $item[mafia thumb ring]);
	use_familiar($familiar[machine elf]);
	equip($slot[familiar], $item[self-dribbling basketball]);
	// `{my_primestat()}, equip Buddy Bjorn, equip Fourth of May Cosplay Saber, equip Mr. Screege's spectacles, equip mafia thumb ring, equip lucky gold ring`
	bjornify_familiar($familiar[Warbear Drone]);
	
	dupeInDmt($item[very fancy whiskey]);
	getCalderaCoin();
}

void doGarboDay(boolean ascend) {
	assert(can_interact(), "Still in run");
	cli_execute("breakfast; Detective Solver.ash");
	if (!get_property("moonTuned").to_boolean()) {
		cli_execute("spoon Opossum");
	}
	if (my_inebriety() <= inebriety_limit()) {
		cli_execute(`garbo {(ascend) ? "ascend" : ""}`);
	}
	assert(!haveOrganSpace(), "Organ space remaining");
	assert(my_adventures() == 0, "Adventures remaining");
	cli_execute(`CONSUME NIGHTCAP {(ascend) ? "NOMEAT VALUE 4000" : ""}`);
	if (ascend) {
		cli_execute(`combo {my_adventures()}; pvp loot On the Nice List`);
	} else {
		cli_execute("maximize adv; terminal enquiry familiar.enq");
		if (!(get_campground() contains $item[clockwork maid])) {
			if (!have($item[clockwork maid])) {
				buy(1, $item[clockwork maid], 8 * get_property("valueOfAdventure").to_int());
			}
			tryUse($item[clockwork maid]);
		}
	}
}

void main() {
	boolean skipCasual = false;
	logProfit("Begin");
	
	logProfit("BeforeFirstGarbo");
	if (canAscendNoncasual()) {
		doGarboDay(true);
		// TODO handle swapping to DNA lab and creating 3 tonics?
	}
	logProfit("AfterFirstGarbo");
	
	logProfit("BeforeCS");
	if (canAscendNoncasual() || my_path() == "Community Service") {
		cli_execute("fizz-sccs.ash");
	}
	logProfit("AfterCS");
	
	logProfit("BeforeSecondGarbo");
	if (canAscendCasual() && !skipCasual) {
		afterPrismBreak();	
		doGarboDay(true);
	}
	logProfit("AfterSecondGarbo");

	logProfit("BeforeCasual");
	if (canAscendCasual() && !skipCasual) {
		class playerClass = $class[Seal Clubber];
		
		string moon;
		item nightstand;
		switch (playerClass.primestat) {
			case $stat[Muscle]:
				moon = "Mongoose";
				nightstand = $item[electric muscle stimulator];
				break;
			case $stat[Mysticality]:
				moon = "Wallaby";
				nightstand = $item[foreign language tapes];
				break;
			case $stat[Moxie]:
				moon = "Vole";
				nightstand = $item[bowl of potpourri];
				break;
		}
		
		if (get_workshed() != $item[Asdon Martin keyfob]) {
			use(1, $item[Asdon Martin keyfob]);
		}
		
		if (!(get_chateau() contains nightstand)) {
			buy(1, nightstand);
		}
			
		// change garden?
		ascend(paths["NONE"], playerClass, "casual", moon, $item[astral six-pack], $item[astral pet sweater]);
		
	}
	cli_execute("loopcasual");
	logProfit("AfterCasual");
	
	logProfit("BeforeThirdGarbo");
	afterPrismBreak();
	cli_execute("gasdon observantly 1000");
	if (get_workshed() != $item[cold medicine cabinet]) {
		use(1, $item[cold medicine cabinet]);
	}
	doGarboDay(false);
	logProfit("AfterThirdGarbo");
	
	logProfit("End");
	
	compareProfit('BeforeFirstGarbo', 'AfterFirstGarbo', true);
	compareProfit('BeforeCS', 'AfterCS', true);
	compareProfit('BeforeSecondGarbo', 'AfterSecondGarbo', true);
	compareProfit('BeforeCasual', 'AfterCasual', true);
	compareProfit('BeforeThirdGarbo', 'AfterThirdGarbo', true);
	compareProfit('Begin', 'End', false);
}