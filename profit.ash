import <fizzlib/ascend.ash>


static {
	string[coinmaster, string, int, item] cm_txt;
	file_to_map('data/coinmasters.txt', cm_txt);
	item [item] itemsFromTokens {
		$item[Freddy Kruegerand]: $item[Dreadsylvanian skeleton key],
		$item[Beach Buck]: $item[one-day ticket to Spring Break Beach],
		$item[Coinspiracy]: $item[Merc Core deployment orders],
		$item[FunFunds&trade;]: $item[one-day ticket to Dinseylandfill],
		$item[Volcoino]: $item[one-day ticket to That 70s Volcano],
		$item[Wal-Mart gift certificate]: $item[shoulder-warming lotion],
		$item[Rubee&trade;]: $item[LyleCo Contractor's Manual]
	};
}

int totalAmount(item it) {
	int amount = item_amount(it) + equipped_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it);
	foreach fam in $familiars[] {
		if (have_familiar(fam) && my_familiar() != fam && familiar_equipped_equipment(fam) == it) {
			amount++;
		}
	}
	if ((gardens contains it || worksheds contains it) && get_campground() contains it) {
		amount++;
	}
	return amount;
}

int mallValue(item it) {
	if (!it.tradeable) // untradeable items don't have mall value
		return 0;
	else if (historical_age(it) < 7.0) // one week sounds about right
		return historical_price(it);
	else if (mall_price(it) > 0)
		return mall_price(it);
	else if (mall_price(it) < 0) { // items that are not in the mall return -1
		if (is_npc_item(it) || is_coinmaster_item(it)) // includes items such as lucky lindy, which are marked tradable, but can never be owned
			return 0;
		else if (historical_age(it) < 4015) // historical age returns infinite for items that have never been seen before: 11 years should do it
			return historical_price(it);
		else
			return 1000000000;
	}
	else {
		abort(`No idea how to price item {it}`);
		return -1;
	}
}

int itemValue(item it) {
	int coinmasterValue(item token) {
		if (itemsFromTokens contains token) {
			foreach c, direction, price, it, row in cm_txt {
				if (c.item == token && direction == 'buy' && it == itemsFromTokens[token])
					return (itemValue(it).to_float() / price.to_float()).to_int();
			}
			abort(`Item {itemsFromTokens[token]} cannot be purchased with token {token}`);
			return -1;
		} else
			return 0;
	}

	int specialValue(item it) {
		switch (it) {
			case $item[Merc Core deployment orders]:
				return itemValue($item[one-day ticket to Conspiracy Island]);
			case $item[empty Rain-Doh can]:
				return itemValue($item[can of Rain-Doh]);
			default:
				return npc_price(it);
		}
	}

	int singularValue(item it) {
		if (mallValue(it) <= max(100, 2 * autosell_price(it)))
			return max(specialValue(it), coinmasterValue(it), autosell_price(it));
		else
			return max(specialValue(it), coinmasterValue(it), mallValue(it));
	}
	
	int maxValue = singularValue(it);
	if (count(get_related(it, 'fold')) > 0)
		foreach j in get_related(it, 'fold')
			maxValue = min(maxValue, singularValue(j));
	if (count(get_related(it, 'zap')) > 0)
		foreach j in get_related(it, 'zap')
			maxValue = min(maxValue, singularValue(j));
	
	return maxValue;
}

void logItems(string date, string event) {
	int [item] itemList;
	file_to_map(`/Profit Tracking/{my_name()}/inventory/{date} {event}.txt`, itemList);
	if (count(itemList) > 0)
		print(`Profit: already logged items for event {event}`, 'orange');
	else {
		cli_execute('refresh shop');
		cli_execute('refresh storage');
		if (can_interact() && get_property('lastEmptiedStorage').to_int() < 0)
			cli_execute('pull all');
		cli_execute('refresh inv');	
		print('Profit: Logging Items...', 'fuchsia');
		foreach it in $items[]
			if (totalAmount(it) != 0) 
				itemList[it] = totalAmount(it);
		print(`Profit: {count(itemList).to_string('%,d')} items logged for event {event}`, 'fuchsia');
		map_to_file(itemList, `/Profit Tracking/{my_name()}/inventory/{date} {event}.txt`);
	}
}

void logMeat(string date, string event) {
	record logevent { int adv; int meat; };
	logevent [string, string] meatlist;
	file_to_map(`/Profit Tracking/{my_name()}/meat.txt`, meatlist);
	if (meatlist[date] contains event)
		print(`Profit: already logged meat for event {event}`, 'orange');
	else {
		logevent newest;
		newest.meat = my_meat() + my_storage_meat() + my_closet_meat(); 
		newest.adv = total_turns_played(); 
		meatlist[date, event] = newest;
		boolean success = map_to_file(meatlist, `/Profit Tracking/{my_name()}/meat.txt`);
		if (!success) abort("Profit: Aaah, we didn't write the file somehow");
		print(`Profit: {newest.meat.to_string('%,d')} meat logged for event {event}`, 'fuchsia');
	}
}

void logProfit(string date, string event) {
	print(`Profit: logging items and meat for event {event}...`);
	logItems(date, event);
	logMeat(date, event);
}

void logProfit(string event) {
	logProfit(today_to_string(), event);
}

void compareProfit(string date1, string event1, string date2, string event2, boolean silent) {
	int [item] itemList1, itemList2;
	file_to_map(`/Profit Tracking/{my_name()}/inventory/{date1} {event1}.txt`, itemList1);
	file_to_map(`/Profit Tracking/{my_name()}/inventory/{date2} {event2}.txt`, itemList2);
	
	record itemcount { item it; int amount; };
	itemcount [int] diff;
	int difference;
	int profit;
	foreach it in $items[] {
		if (itemList1[it] != itemList2[it]) {
			difference = itemList2[it] - itemList1[it];
			diff[diff.count()] = new itemcount(it, difference);
			profit += difference * itemValue(it);
		}
	}
	
	record logevent { int adv; int meat; string activity; };
	logevent [string, string] meatlist;
	file_to_map(`/Profit Tracking/{my_name()}/meat.txt`, meatlist);
	int meat = meatlist[date2, event2].meat - meatlist[date1, event1].meat;
	int adv  = meatlist[date2, event2].adv - meatlist[date1, event1].adv;
	int total = profit + meat;
	
	print(`You've earned {profit.to_string('%,d')} in item differences and {meat.to_string('%,d')} liquid meat`, 'blue');
	if (!silent) {
		sort diff by value.amount * itemValue(value.it);
		print("top 10s (this includes items that disappeared from my mall store):");
		for i from 0 to 10
			if (diff[i].amount < 0)
				print(`{diff[i].amount.to_string('%,d')} {diff[i].it} : {(diff[i].amount * itemValue(diff[i].it)).to_string('%,d')}`);
		print("...");
		for i from count(diff) - 11 to count(diff) - 1
			if (diff[i].amount > 0)
				print(`{diff[i].amount.to_string('%,d')} {diff[i].it} : {(diff[i].amount * itemValue(diff[i].it)).to_string('%,d')}`);
	}
	print(`You've earned a total of {total.to_string('%,d')} meat between {date1} {event1} and {date2} {event2}`, 'blue');
	print("");
}

void compareProfit(string event1, string event2, boolean silent) {
	compareProfit(today_to_string(), event1, today_to_string(), event2, silent);
}

void main() {
	logProfit("Begin");
	
	logProfit("BeforeFirstGarbo");
}