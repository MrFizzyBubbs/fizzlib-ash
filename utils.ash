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

void closet_pvpable() {
	int minimum_value = 10000; // Closet everything stealable worth more than this; 0 = closet everything stealable.
	int verbose = 1; //0 = don't print individual items; 1 = print closeted items; 2 = also too cheap to closet; 3 = also unstealable.

    if (minimum_value < 0) abort ("A minimum_value less than zero makes no sense at all.");
    int count_cheap, count_closet, count_total, count_unstealable;
    int [item] inv = get_inventory();
    boolean [item] pvp_unimportant = $items[tenderizing hammer, dramatic range, Queue Du Coq cocktailcrafting kit];
    boolean is_stealable(item it) { return is_tradeable(it) && is_discardable(it); }
    foreach it, qty in inv {
        int price = -1;
        if (is_stealable(it) && !(pvp_unimportant contains it)) price = historical_price(it);
        if (price < 0) {
            count_unstealable += 1;
        } else if (price < minimum_value) {
            count_cheap += 1;
        } else if (price >= minimum_value) {
            count_closet += 1;
		print(`Closet {qty} {it} @ {historical_price(it).to_string('%,d')} each in the mall`, "blue");
            put_closet(qty, it);
        }
        
    }
    count_total = count_closet + count_cheap + count_unstealable;
    print(""); //linebreak
    if (count_closet > 0) print("+ " + count_closet + " closeted", "teal");
    if (count_cheap > 0) print("+ " + count_cheap + " worth less than " + minimum_value.to_string('%,d') + " meat", "red");
    if (count_unstealable > 0) print("+ " + count_unstealable + " unstealable", "green");
    if (count_total > 0) print(" = " +  count_total + " of " + count(inv) + " items accounted for.");
    print_html("<b>Done! <a href=\"http://kolmafia.us/showthread.php?10059\">discussion thread link</a></b>");
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

boolean isKingFree() {
	return get_property("kingLiberated").to_boolean();
}

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
	suggestDmtDupes();
}