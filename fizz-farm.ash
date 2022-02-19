import <fizz-sccs-lib.ash>
import <fizz-sccs-combat.ash>
import <fizz-sccs-ascend.ash>
import <ascension-history.ash>
import <profit-tracking.ash>

boolean isDuplicatable(item it) {
	boolean isStealable = is_tradeable(it) && is_discardable(it) && !it.gift;
	boolean isPotion = it.usable && !it.reusable && effect_modifier(it, "effect") != $effect[none]; 
	return isStealable && (item_type(it) == "food" || item_type(it) == "booze" || item_type(it) == "spleen item" || isPotion);
}

void dupeInDmt(item it) {
	assert(isDuplicatable(it), `Item {it} is not duplicatable in the DMT`);
	assert(item_amount(it) > 0, `Missing item {it} in inventory to duplicate`);
	
	if (get_property("lastDMTDuplication").to_int() != my_ascensions()) {
		assert(get_property("encountersUntilDMTChoice").to_int() == 0, "DMT chocie adv is not ready");
		//if (!get_property("_claraBellUsed").to_boolean()) use(1, $item[Clara"s bell]);
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
		ensureHp(0.8);
		ensureMp(8);
		adv1($location[The Bubblin' Caldera], -1, mNew().mCursing().mAttackRepeat());
		if ($location[The Bubblin' Caldera].noncombat_queue.contains_text("Lava Dogs"))
			set_property("lastDoghouseVolcoino", my_ascensions());
	}
	
	if (have($effect[Drenched in Lava])) 
		cli_execute("hottub");
		assert(!have($effect[Drenched in Lava]), "Failed to get rid of Drenched in Lava");
}

void afterPrismBreak() {
	cli_execute("pull all");
	put_closet(my_meat() - 2000000);
	cli_execute("uneffect Feeling Lost; counters clear; peevpee.php?action=smashstone&confirm=on; breakfast; Detective Solver.ash; backupcamera reverser on");
	if (get_property("boomBoxSong") != "Total Eclipse of Your Meat") 
		cli_execute("boombox meat");
	tryUse($item[can of Rain-Doh]);
	
	equip($slot[hat], $item[Daylight Shavings Helmet]);
	equip($slot[weapon], $item[Fourth of May Cosplay Saber]);
	equip($slot[off-hand], $item[KoL Con 13 snowglobe]);
	equip($slot[back], $item[Buddy Bjorn]);
	bjornify_familiar($familiar[Warbear Drone]);
	//equip($slot[shirt], $item[Sneaky Pete's leather jacket]);
	equip($slot[pants], $item[Cargo Cultist Shorts]);
	equip($slot[acc1], $item[lucky gold ring]);
	equip($slot[acc2], $item[Mr. Screege's spectacles]);
	equip($slot[acc3], $item[mafia thumb ring]);
	use_familiar($familiar[machine elf]);
	equip($slot[familiar], $item[self-dribbling basketball]);
	
	dupeInDmt($item[very fancy whiskey]);
	getCalderaCoin();
}

void main() {
	logProfit("Begin");
	
	logProfit("BeforeFirstGarbo");
	if (can_ascend()) {
		assert(can_interact(), "Still in run after day 1");
		cli_execute("breakfast, Detective Solver.ash");
		if (my_inebriety() <= inebriety_limit())
			cli_execute("garbo ascend; CONSUME NIGHTCAP VALUE 4000");
		cli_execute(`combo {my_adventures()}, pvp fame 1`);
		// TODO handle swapping to DNA lab and creating 3 tonics?
	}
	logProfit("AfterFirstGarbo");
	
	logProfit("BeforeCS");
	if (can_ascend() || my_path() == "Community Service") 
		abort("Manually ascend CS to perm skills");
		assert(my_daycount() == 1, "Still in run after day 1");
		cli_execute("fizz-sccs.ash");
	logProfit("AfterCS");
	
	logProfit("BeforeSecondGarbo");
	if (can_ascend(true)) {
		afterPrismBreak();
		if (my_inebriety() <= inebriety_limit())
			cli_execute("garbo ascend; CONSUME NIGHTCAP VALUE 4000");
		cli_execute(`combo {my_adventures()}, pvp fame 1`);
	}
	logProfit("AfterSecondGarbo");
	
	logProfit("BeforeCasual");
	if (can_ascend(true)) {
		class playerClass = $class[Seal Clubber];
		
		string moon;
		item nightstand;
		switch (playerClass.primestat) {
			case $stat[Muscle]:
				moon = "Mongoose";
				nightstand = $item[electric muscle stimulator];
			case $stat[Mysticality]:
				moon = "Wallaby";
				nightstand = $item[foreign language tapes];
			case $stat[Moxie]:
				moon = "Vole";
				nightstand = $item[bowl of potpourri];
		}
		
		if (get_workshed() != $item[Asdon Martin keyfob])
			use(1, $item[Asdon Martin keyfob]);
		
		if (!(get_chateau() contains nightstand)) {
			retrieve_item(1, nightstand)
			use(1, nightstand)
		}
		
		// change garden?
		ascend("Unrestricted", playerClass, "casual", moon, $item[astral six-pack], $item[astral pet sweater]);
	}
	
	if (!get_property("kingLiberated").to_boolean()) {
		cli_execute("loopcasual");
	}
	logProfit("AfterCasual");
	
	logProfit("BeforeThirdGarbo");
	assert(!can_ascend() && !can_ascend(True), "We should've already ascended twice today");
	afterPrismBreak();
	if (my_inebriety() <= inebriety_limit())
		cli_execute("garbo; CONSUME NIGHTCAP");
	cli_execute("maximize adv; terminal enquiry familiar.enq");
	if (!(get_campground() contains $item[clockwork maid])) {
		if (!have($item[clockwork maid])) 
			buy(1, $item[clockwork maid], 8 * get_property("valueOfAdventure").to_int());
		tryUse($item[clockwork maid]);
	logProfit("AfterThirdGarbo");
	
	logProfit("End");
	compareProfit("Begin", "End", false);
}