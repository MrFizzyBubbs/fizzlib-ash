import <CFStat.ash>

boolean isDuplicatable(item it) {
	boolean isStealable = is_tradeable(it) && is_discardable(it) && !it.gift;
	boolean isPotion = it.usable && !it.reusable && effect_modifier(it, 'effect') != $effect[none]; 
	return isStealable && (item_type(it) == 'food' || item_type(it) == 'booze' || item_type(it) == 'spleen item' || isPotion);
}

int maxItemID;
foreach it in $items[] {
	maxItemID = max(maxItemID, to_int(it));
}

int data_to_price(itemdata data) {
	return data.avePrice;
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
			int i = count(all);
			all[i].thing = it;
			all[i].price = data.aveprice;
			all[i].amount = data.amountsold;
		}
	}
}
sort all by -value.price;

print_html("<b>Results</b>");
for i from 1 to min(count(all), 10) {
	print(`{i}: {all[i-1].thing} ({all[i-1].amount} @ {all[i-1].price.to_string('%,d')} meat)`);
}