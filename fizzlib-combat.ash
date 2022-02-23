buffer mNew() {
	buffer macro;
	return macro;
}

buffer mStep(buffer macro, string next) {
	return macro.append(next).append(";");
}

buffer mAbort(buffer macro, string message) {
	return macro.mStep(`abort "{message}"`);
}

buffer mRepeat(buffer macro) {
	return macro.mStep("repeat");
}

buffer mRunaway(buffer macro) {
	return macro.mStep("runaway");
}

buffer mAttackRepeat(buffer macro) {
	return macro.mStep("attack").mRepeat();
}

buffer mSkill(buffer macro, skill sk) {
	return macro.mStep(`skill {sk.to_int()}`);
}

buffer mTrySkill(buffer macro, skill sk) {
	return macro.mStep(`if hasskill {sk.to_int()}`).mSkill(sk).mStep("endif");
}

buffer mItem(buffer macro, item it) {
	return macro.mStep(`use {it.to_int()}`);
}

buffer mBanish(buffer macro, monster mon, skill banisher) {
	return macro.mStep(`if monsterid {mon.id}`).mSkill(banisher).mStep("endif");
}

buffer mIfMonster(buffer macro, monster mon, buffer action) {
	return macro.mStep(`if monsterid {mon.id}`).append(action).mStep("endif");
}

buffer mEnsureMonster(buffer macro, monster mon) {
	return macro.mStep(`if !monsterid {mon.id}`).mAbort(`Expected {mon.name}`).mStep("endif");
}

buffer mEnsureMonster(buffer macro, boolean [monster] mons) {
	buffer predicate;
	foreach mon in mons {
		if (predicate.length() > 0) {
			predicate.append(" || ");
		}
		predicate.append(`monsterid {mon.id}`);
	}
	return macro.mStep(`if !({predicate})`).mAbort("Unexpected monster encountered").mStep("endif");
}

buffer mEnsureMonster(buffer macro, location loc) {
	boolean [monster] mons;
	foreach _, mon in get_monsters(loc) { mons[mon] = true; }
	return macro.mEnsureMonster(mons);
}

buffer mFind(buffer macro, monster mon) {
	return macro.mStep(`while !monsterid {mon.id}`).mSkill($skill[Macrometeorite]).mStep("endwhile");
}

buffer mReplace(buffer macro, monster mon) {
	return macro.mStep(`if monsterid {mon.id}`).mSkill($skill[Macrometeorite]).mStep("endif");
}

buffer mCursing(buffer macro) {
	return macro.mSkill($skill[Curse of Weaksauce]).mSkill($skill[Sing Along]);
}

buffer mCandyKill(buffer macro) {
	return macro.mSkill($skill[Candyblast]).mRepeat();
}

buffer mBustGhost(buffer macro) {
	return macro
		.mEnsureMonster($monsters[
			boneless blobghost,
			Emily Koops\, a spooky lime,
			The ghost of Ebenoozer Screege,
			The ghost of Jim Unfortunato,
			The ghost of Lord Montague Spookyraven,
			the ghost of Monsieur Baguelle,
			the ghost of Oily McBindle,
			The ghost of Richard Cockingham,
			the ghost of Sam McGee,
			the ghost of Vanillica "Trashblossom" Gorton,
			The ghost of Waldo the Carpathian,
			The Headless Horseman,
			The Icewoman
		])
		.mSkill($skill[Summon Love Gnats])
		.mSkill($skill[Sing Along])
		.mSkill($skill[Shoot Ghost])
		.mSkill($skill[Shoot Ghost])
		.mSkill($skill[Shoot Ghost])
		.mSkill($skill[Trap Ghost]);
}