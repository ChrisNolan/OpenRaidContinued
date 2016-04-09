OpenRaidLocales = {
	["enUS"] = { --English (United Kingdom) and English (United States) **Default locales**
		["# OpenRaid friends"] = "You have %d OpenRaid friends",
		["Add Tooltip"] = "This will send all the invites to the attendees of the selected raid.",
		["Already looting"] = "You are already looting an item with bonus applied",
		["Already rated"] = "You have already rated this raid. Do you want to override this?",
		["Also clean up raids"] = "Also clean up raids",
		["Automatically accept friend requests"] = "Automatically accept friend requests",
		["Automatically accept friend requests tooltip"] = "Sets the default of the button presented\nwhen accepting pending requests in the FriendsFrame",
		["Automatically enable sent"] = "Tag new Battletag friends as OpenRaid friend by default",
		["Automatically enable sent tooltip"] = "Checks the checkbox when manually adding people using Battletags.",
		["Automatically send requests"] = "Automatically send requests (when importing raids)",
		["Automatically send requests tooltip"] = "Automatically send requests when importing raids",
		["Bad battletag"] = "Your string is incorrect. It contains %s which is not a battletag.",
		["BN whisperinvite message"] = "Whisper me with the correct event number (listed on the event page) to get auto-invited for %s.",
		["BN whisperinvite message own"] = "Whisper me with \34%s\34 to get auto-invited for %s.",
		["Bonus roll"] = "Bonus roll",
		["Clean up time"] = "Clean up time",
		["Clean up time tooltip"] = "How many days imported information should remain in the database. Excludes all raids.",
		["Clear raids after X days tooltip"] = "Also clean up the raid data when cleaning up database.",
		["Confirm remove friend"] = "Are you completely sure you want to ignore this friend in the remove friends function?\nThis change is permanent and can't be reverted.\nManual removal is necessary in case you accidently clicked this.",
		["Confirm remove friend tooltip"] = "If you don't want this person to be ever listed here.\nKeep in mind this change is PERMANENT.\nIf you want to remove a person even though you ignored him from this list,\nyou should do it manually.",
		["Convert to raid"] = "You need to convert to a raid first before trying to re-invite the attendees.",
		["Create Raid Tooltip"] = "This will import the raid into the database.\nMust have attendees to be able to be imported.",
		["Default start page tooltip"] = "The default start page when typing /or.",
		["Dont check character"] = "Don't check if you are logged on the correct character.",
		["Dont check character tooltip"] = "Don't check if you are logged on the correct character.\nKeep in mind you still have to log on the character\nyou are attending the event when importing raids.",
		["EditBox Enter confirm"] = "Press enter to confirm the change.",
		["End"] = "End",
		["Event no members import"] = "This event has no members attending. Do you still want to import this raid?",
		["Event no members invites"] = "Unable to send invites for event because this event has no members attending",
		["Event no members rate"] = "This event has no members attending, so you can't give ratings for this raid",
		["Event no members send"] = "Unable to send requests for event because this event has no members attending",
		["Filter already in group"] = "Filter out/hide the system message " .. ERR_ALREADY_IN_GROUP_S,
		["Filter already in group tooltip"] = "Filter out/hide the system message \34" .. ERR_ALREADY_IN_GROUP_S .. "\34 when inviting",
		["Filter have invited"] = "Filter out/hide the system message " .. ERR_INVITE_PLAYER_S,
		["Filter have invited tooltip"] = "Filter out/hide the system message \34" .. ERR_INVITE_PLAYER_S .. "\34 when inviting",
		["Filter joined your group"] = "Filter out/hide the system messages " .. ERR_JOINED_GROUP_S .. " and " .. ERR_RAID_MEMBER_ADDED_S,
		["Filter joined your group tooltip"] = "Filter out/hide the system messages \34" .. ERR_JOINED_GROUP_S .. "\34\nand \34" .. ERR_RAID_MEMBER_ADDED_S .. "\34 when inviting",
		["Finalize ratings tooltip"] = "Click when you finished rating every person attending and optionally left a comment about their performance.",
		["First time"] = "It appears that this is the first time you use the OpenRaid addon. Do you want to start a tutorial to get familair with the addon?",
		["Found on OpenRaid?"] = "Is this someone you are inviting for an OpenRaid event?",
		["Friend request has been sent"] = "Friend request has been sent",
		["Friends invited"] = "All your Battletag friends have been invited.",
		["Generating options"] = "Generating options, because version was too low or options were not created yet.",
		["Happening on"] = "Happening on",
		["Highest roll"] = "The highest roll is %d from ",
		["Import data"] = "Import raid data to update your time events and signed people",
		["Import string corrupt"] = "The string you were trying to import is incorrect or corrupt.",
		["Invite for event wrong character"] = "I wanted to invite you for my OpenRaid event, but you are on the wrong character. Please log your character you signed up with.",
		["Invite for event"] = "Inviting you for OpenRaid event.",
		["Invite people"] = "Invite the people who signed up for your event in your group.",
		["Invite Tooltip"] = "This will send BN whispers and invites to everyone of the selected raid.\nIt will also set your BN message. This message will be removed when you are finished inviting.",
		["Invited person not friend"] = "The person with battletag %s who signed up with %s-%s is not a friend of you.",
		["Invited person not online"] = "The person with battletag %s who signed up with %s-%s is not online atm.",
		["Joined your raids"] = "Joined you in %d OpenRaid |4event:events;",
		["Loot roll end"] = "Loot roll time expired. Calculating winner.",
		["Loot roll start"] = "Rolling loot for: %s You have 1 minute to /roll for a chance to loot this item. Bonus roll applied.",
		["More raids"] = " and %d more",
		["Must contain error"] = "Your message when sending invites to people. Must contain %%d (the event number) and %%s (the event name) to work properly.",
		["Must contain tooltip"] = "Your message when sending invites to people. Must contain %d (the event number) and %s (the event name) to work properly.",
		["No loot roll"] = "No one rolled. The loot will be need-greeded.",
		["No raid selected"] = "Please select a raid first",
		["No raids in database"] = "No raids are currently in the database",
		["Not all rated"] = "You have not rated everyone yet for this event. If you continue, the unrated raid members will receive a rating of 3 stars.",
		["Not correct character"] = "Please import a string with raids for your currently logged in character",
		["Not found error"] = "The following people could not be invited:\n",
		["OpenRaid Info"] = [[    OpenRaid Info:
-------------------------------------------
Slashcommands: /or, /oraid or /OpenRaid
/or create to import raid data
/or add to send battlenet friendrequests of imported data
/or invite/quickraid to automatically invite the signed people
/or tut to start the tutorial
/or rate to start rating
-------------------------------------------
Please report bugs on curse.com or on our fora]],
		["Options"] = "Options page",
		["OptionsDropdown"] = {
			["Index"] = "News page",
			["Rate"] = "Rate people",
			["Add"] = "Send requests",
			["CreateRaid"] = "Import data",
			["Invite"] = "Invite people",
		},
		["Personal send message"] = "Personal send message",
		["PlusInvite Tooltip"] = "Set your broadcast message to inform everyone that you are inviting people\nwhen they whisper you with a specific word.\nYou can set the word in the options.",
		["Raid overwrite tooltip"] = "Everytime an already existing raid is imported, should it update or completely overwrite the persons attending.",
		["Raid request sent"] = "All the request have been sent.",
		["Raid succesfully imported"] = "Succesfully imported the raid(s)",
		["Rate people"] = "Rate the people you selected for rating and people who signed for the original event",
		["Remove attendees"] = "Are you sure you want to remove all attendees from this raid?",
		["Remove friends"] = "Remove the friends you invited with this AddOn",
		["Remove friends all tooltip"] = "Left click to toggle the removal status of every person in the list.\nRight click to choose an event and only check the persons who were attending that event.",
		["Remove friends?"] = "Are you sure you want to remove %d battletag friends of your friendlist?",
		["Remove raid confirm"] = "Are you sure you want to remove the raid from the database?",
		["Request sent text"] = "Adding you as friend for OpenRaid event %d named %s",
		["Roll match"] = "%a+ rolls %d+ %(1%-100%)",
		["Same roll"] = "There are people with the same roll:",
		["Select raid"] = "Please select a raid to rate",
		["Send requests"] = "Send battlenet friend requests to the people who signed up for your event",
		["Sending battletag requests"] = "Battlenet friend requests are being sent out with an interval of 10 seconds.",
		["Set special note"] = "Use specific notes for each event",
		["Set special note tooltip"] = "Append after #OpenRaid the event title in the friend notes. Use the AddOn Friendgroups to see them in a different group.",
		["Stop whisper invite"] = "Stop whisper invite",
		["This person is already your friend"] = "This person is already your friend",
		["Too many BN friends"] = "You are trying to add more friends than Blizzard allows. Do you want to remove some friends first?",
		["Tutorial welcome"] = "Welcome to the OpenRaid AddOn tutorial.\nIn this tutorial we will show you every function of\nthe AddOn and what it does.",
		["Tutorial"] = {
			[1] = "We are going to go through all different steps\nto succesfully run an OpenRaid event",
			[2] = "This is the menu frame, which you can use to navigate\nall the different parts of the AddOn",
			[3] = "Whenever you see a black box, you can copy/paste data\nfrom OpenRaid into it.",
			[4] = "Import your events here. You can use the 'Addon' button on\nthe event page. This is the first step to start your raid.",
			[5] = "This calendar shows all your OpenRaid events.",
			[6] = "You can start an imported event here by sending\nthe Battletag invites.",
			[7] = "Click the dropdown if you have already imported a raid.",
			[8] = "Click the dropdown if you have already imported a raid.\nElse paste the string given by the site into the box.",
			[9] = "If you want to invite people to your raid now, use this tab.\nYou can also use it to start QuickRaid events.",
			[10] = "Click the dropdown if you have already imported a raid.",
			[11] = "Click the dropdown if you have already imported a raid.\nElse paste the string given by the site into the box.",
			[12] = "As the AddOn invites your attendees the bar fills up.\nRed are the people that are not online or arent your friend.\nOrange are the people who are online,\nbut on the wrong character or already in a group.\nGreen are the people who are in your group.",
			[13] = "You can evaluate your events using this tab.\nVisit http://OpenRaid.org/addon to upload your ratings.",
			[14] = "Click the dropdown to view the raids you can rate.",
			[15] = "Click the raid and view all the attendees.",
			[16] = "Give the attendees the amount of stars deserve.\nIf you want to you can also leave feedback in the box.",
			[17] = "Remove any friends that you added just for OpenRaid events\nhere. This keeps your friends list clean.",
			[18] = "This tab contains options used throughout the addon.",
			[19] = "This is the home tab, which is where we started out.",
			[20] = "Thank you for using OpenRaid and our addon.\nTo form a group right away, we invite you\nto use QuickRaid on OpenRaid.org!"
		},
		["Use whisper invite"] = "Use whisper invite",
		["Whisper word tooltip"] = "When using whisper invite you can either choose to use the event ID\nor a custom message as keyword.\nWhen people Bnet-whisper you with the correct word they automatically invited.",
		["Visit OpenRaid.org/addon"] = "Please go to OpenRaid.org/addon to paste the information",
	},
	["deDE"] = { --German (Germany)
		["Roll match"] = "%a+ würfelt. Ergebnis: %d+ %(1%-100%)",
	},
	["esES"] = { --Spanish (Spain)
		["Roll match"] = "%a+ tira los dados y obtiene %d+ %(1%-100%)",
	},
	["esMX"] = { --Spanish (Mexico)
	},
	["frFR"] = { --French (France)
		["Roll match"] = "%a+ obtient un %d+ %(1%-100%)",
	},
	["itIT"] = { --Italian (Italy)
		["Roll match"] = "%a+ tira %d+ %(1%-100%)",
	},
	["koKR"] = { --Korean (Korea)
	},
	["ptBR"] = { --Portuguese (Brazil)
		["Roll match"] = "%a+ tira %d+ %(1%-100%)",
	},
	["ruRU"] = { --Russian (Russia)
		["Roll match"] = "%s выбрасывает %d (%d-%d)",
	},
	["zhCN"] = { --Chinese (Simplified, PRC)
	},
	["zhTW"] = { --Chinese (Traditional, Taiwan)
	},
}

OpenRaid = {};

OpenRaid.L = {};
local L = GetLocale();
do
	for k,v in pairs(OpenRaidLocales.enUS) do
		if not OpenRaidLocales[L][k] or OpenRaidLocales[L][k] == false then
			OpenRaid.L[k] = OpenRaidLocales.enUS[k]; --We use the default enUS localization
		else
			OpenRaid.L[k] = OpenRaidLocales[L][k];
		end
	end
end