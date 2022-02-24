import <CFStat.ash>


// Control

void assert(boolean condition, string message) {
	if (!condition) abort(message);
}

// Items

boolean to_boolean(item it) {
	return it != $item[none];
}

boolean have(item it, int amount) {
	return available_amount(it) >= amount;
}

boolean have(item it) {
	return have(it, 1);
}

void tryUse(item it) {
	if (available_amount(it) > 0) use(1, it);
}

boolean isDmtDupable(item it) {
	boolean isStealable = is_tradeable(it) && is_discardable(it) && !it.gift;
	boolean isPotion = it.usable && !it.reusable && effect_modifier(it, "effect") != $effect[none]; 
	return isStealable && (item_type(it) == "food" || item_type(it) == "booze" || item_type(it) == "spleen item" || isPotion);
}

void suggestDmtDupes() {
	int maxItemID;
	foreach it in $items[] {
		maxItemID = max(maxItemID, to_int(it));
	}

	record entry {
		item thing;
		int price;
		int amount;
	};
	entry [int] all;

	foreach it in $items[] {
		if (isDmtDupable(it) && historical_price(it) > 100000) {
			itemdata data = salesVolume(it.to_int());
			if (data.amountsold > 1) {
				all[count(all)] = new entry(it, data.aveprice, data.amountsold);
			}
		}
	}
	sort all by -value.price;

	print_html("<b>Suggested DMT Dupes</b>");
	for i from 0 to min(count(all)-1, 9) {
		print(`{i+1}: {all[i].thing} ({all[i].amount} @ {all[i].price.to_string('%,d')} meat)`);
	}
}

// Effects

boolean have(effect ef, int amount) {
	return have_effect(ef) >= amount;
}

boolean have(effect ef) {
	return have(ef, 1);
}

void acquire(effect ef) {
	if (ef != $effect[none]) {
		assert(have(ef) || !ef.default.starts_with("cargo"), `Can't obtain effect {ef}`);
		if (!have(ef)) cli_execute(ef.default);
		assert(have(ef), `Failed to acquire effect {ef}`);
	}
}

// Character

boolean haveOrganSpace() {
	return my_spleen_use() < spleen_limit() || my_fullness() < fullness_limit() || my_inebriety() < inebriety_limit();
}

void summarizeResourceUsage() {
	void print_(string name, int used, int total) {
		string color;
		if (used == 0) color = "green";
		else if (used <= total * 0.5 || total == 0) color = "olive";
		else color = "maroon";
		
		print(`{name}: {used}/{total > 0 ? total.to_string() : "?"}`, color);
	}

	print_html("<b>Organs</b>");
	print_("Stomach", my_fullness(), fullness_limit());
	print_("Liver", my_inebriety(), inebriety_limit());
	print_("Spleen", my_spleen_use(), spleen_limit());
	print("");
	
	print_html("<b>Copiers</b>");
	print_("Fax", get_property("_photocopyUsed").to_boolean().to_int(), 1);
	print_("Chateau Painting", get_property("_chateauMonsterFought").to_boolean().to_int(), 1);
	print_("Digitize", get_property("_sourceTerminalDigitizeUses").to_int(), 3);
	print_("Macrometeorite", get_property("_macrometeoriteUses").to_int(), 10);
	print_("Lectures", get_property("_pocketProfessorLectures").to_int(), 0);
	print_("Free Pillkeeper", get_property("_freePillKeeperUsed").to_boolean().to_int(), 1);
	print_("Powerful Glove Battery", get_property("_powerfulGloveBatteryPowerUsed").to_int(), 100);
	print_("Backups", get_property("_backUpUses").to_int(), 11);
	print_("Combat Lover's Locket", get_property("_locketMonstersFought") == "" ? 0 : get_property("_locketMonstersFought").split_string(",").count(), 3);
	print("");
	
	print_html("<b>Other</b>");
	print_("Bander Runaways", get_property("_banderRunaways").to_int(), 0);
	print_("Deck Draws", get_property("_deckCardsDrawn").to_int(), 15);
	print_("Potted Tea Tree", get_property("_pottedTeaTreeUsed").to_boolean().to_int(), 1);
	print_("Time-Spinner Minutes", get_property("_timeSpinnerMinutesUsed").to_int(), 10);
	print_("Genie Wishes", get_property("_genieWishesUsed").to_int(), 3);
	print_("Fortune Buff", get_property("_clanFortuneBuffUsed").to_boolean().to_int(), 1);
	print_("Cosplay Saber", get_property("_saberForceUses").to_int(), 5);
	print_("Cold Medicine Consults", get_property("_coldMedicineConsults").to_int(), 5);
	print_("Cargo Pocket", get_property("_cargoPocketEmptied").to_boolean().to_int(), 1);
	print("");
}

void main() {
	summarizeResourceUsage();
}