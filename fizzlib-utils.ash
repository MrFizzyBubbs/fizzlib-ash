import <CFStat.ash>


// Control

void assert(boolean condition, string message) {
	if (!condition) abort(message);
}

// Items

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
		if (isDuplicatable(it) && historical_price(it) > 100000) {
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