record ascension {
	string date;
	boolean casual;
};

ascension [int] get_history() {
	string page = visit_url(`ascensionhistory.php?back=self&who={my_id()}`);
	matcher match = create_matcher('(\\d{2}\\/\\d{2}\\/\\d{2}).+?(?:title="([\\w\\s]+)"><\\/td>)?<\\/tr>', page);

	ascension [int] history;
	while (find(match)) {
		string date = match.group(1);
		string restriction = match.group(2);
		history[count(history)] = new ascension(date, restriction == "Casual");
	}
	
	return history;
}

boolean can_ascend(boolean casual) {
	if (!can_interact() || !get_property("kingLiberated").to_boolean()) return false;
	
	string page = visit_url(`ascensionhistory.php?back=self&who={my_id()}`);
	string today = now_to_string("MM/dd/yy");
	
	foreach i, asc in get_history() {
		if (asc.date == today && asc.casual == casual) return False;
	}
	return True;
}

boolean can_ascend() {
	return can_ascend(False);
}

void main() {
	print(`can ascend non-casual: {can_ascend(False)}`);
	print(`can ascend casual: {can_ascend(True)}`);
}

// <td class=small valign=center>([\d,]+)\s+<\/td><td height=30 class=small valign=center>([\d\/]+)\s+<\/td><td class=small valign=center><span title="Level at Ascension: (?:[\d,]+|\?)">(\d+)<\/span>\s+<\/td><td class=small valign=center><img src="[\w\d:\.\/]+" width=30 height=30 alt="[\w\s]+" title="([\w\s]+)"><\/td><td class=small valign=center>(\(none\)|\w+)\s+<\/td><td class=small valign=center>(?:<span title='Total Turns: [\d,]+'>)?([\d,]+)(?:<\/span>)?<\/td><td class=small valign=center>(?:<span title='Total Days: [\d,]+'>)?([\d,]+)(?:<\/span>)?
// <td class=small valign=center>1\s+<\/td><td height=30 class=small valign=center>([\d\/]+)  <\/td><td class=small valign=center><span title="Level at Ascension: 15">14<\/span>   <\/td><td class=small valign=center><img src="([\w\d:\.\/]+)" width=30 height=30 alt="Seal Clubber" title="Seal Clubber"><\/td><td class=small valign=center>(none)  <\/td><td class=small valign=center><span title='Total Turns: 2,589'>2,007<\/span><\/td><td class=small valign=center><span title='Total Days: 10'>8<\/span><\/td><td><img alt="Smiling Rat (67.2%) - Total Run: Smiling Rat (51%)" title="Smiling Rat (67.2%) - Total Run: Smiling Rat (51%)" src="([\w\d:\.\/]+)" width=30 height=30 border=0><\/td><td class=small valign=center><img src="([\w\d:\.\/]+)" width=30 height=30><\/td>