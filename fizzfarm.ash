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
		foreach ef in $effects[A Few Extra Pounds, Big, Feeling Excited, Power Ballad of the Arrowsmith] {
			acquire(ef);
		}
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
	cli_execute("pull all; uneffect Feeling Lost; peevpee.php?action=smashstone&confirm=on; backupcamera reverser on");
	put_closet(my_meat() - 2000000);
	tryUse($item[can of Rain-Doh]);
	tryUse($item[astral six-pack]);

	use_familiar($familiar[machine elf]);
	maximize(`{my_primestat()}, equip Buddy Bjorn, equip Fourth of May Cosplay Saber, equip Mr. Screege's spectacles, equip mafia thumb ring, equip lucky gold ring`, false);
	bjornify_familiar($familiar[Warbear Drone]);
	
	dupeInDmt($item[very fancy whiskey]);
	getCalderaCoin();
}

void doGarbo(boolean ascend) {
	assert(can_interact(), "Still in run");
	cli_execute("breakfast; Detective Solver.ash");
	if (!get_property("moonTuned").to_boolean()) {
		cli_execute("spoon Opossum");
	}
	if (haveOrganSpace() || my_adventures() >= 0) {
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
	boolean abortAfterCasual = false;
	class casualClass = $class[Seal Clubber];
	assert(my_class() != $class[none], "Unexpectedly in Valhalla, manual intervention requested");
	
	logProfit("Begin");
	
	logProfit("BeforeFirstGarbo");
	if (canAscendNoncasual()) {
		doGarbo(true);
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
		doGarbo(true);
	}
	logProfit("AfterSecondGarbo");

	logProfit("BeforeCasual");
	if (canAscendCasual() && !skipCasual) {
		string moon;
		item nightstand;
		switch (casualClass.primestat) {
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
			
		// TODO change garden?
		prepareAscension($item[Asdon Martin keyfob], $item[none], $item[none], $item[none], $item[none], nightstand);
		ascend(paths["NONE"], casualClass, "casual", moon, $item[astral six-pack], $item[astral pet sweater]);
	}
	cli_execute("loopcasual");
	logProfit("AfterCasual");
	
	logProfit("BeforeThirdGarbo");
	afterPrismBreak();
	assert(!abortAfterCasual, "User requested abort after casual");
	if (get_workshed() == $item[Asdon Martin keyfob]) {
		cli_execute("gasdon observantly 1000");
	}
	if (get_workshed() != $item[cold medicine cabinet]) {
		use(1, $item[cold medicine cabinet]);
	}
	doGarbo(false);
	logProfit("AfterThirdGarbo");
	
	logProfit("End");
	
	compareProfit("BeforeFirstGarbo", "AfterFirstGarbo", true);
	compareProfit("BeforeCS", "AfterCS", true);
	compareProfit("BeforeSecondGarbo", "AfterSecondGarbo", true);
	compareProfit("BeforeCasual", "AfterCasual", true);
	compareProfit("BeforeThirdGarbo", "AfterThirdGarbo", true);
	compareProfit("Begin", "End", false);
}