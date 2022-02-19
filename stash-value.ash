void main() {
	int [item] stash = get_stash();
	item [int] uniqueItems;
	foreach it in stash { uniqueItems[count(uniqueItems)] = it; }
	sort uniqueItems by historical_price(value);
	
	print_html("<b>Results</b>");
	foreach _, it in uniqueItems {
		print(`{it} ({stash[it]}): {historical_price(it)}`);
	}
}