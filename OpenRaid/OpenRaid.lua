--[[
	This addon is written by Jeremybell EU - Grim Batol for the site OpenRaid.org
	The contents of this addon may not be redistributed without the express permission of the staff and developers of OpenRaid.
	For questions and suggestions, plz go to http://OpenRaid.org/forum/ or contact our staff by mailing them at addon@OpenRaid.org or support@OpenRaid.org.
	All rights reserved.
]]

--[[
	----------------------------------------------------------------------
	--				Changelog updated to version 2.0					--
	----------------------------------------------------------------------
	Version 2.0
		--Initial release of revamped AddOn

]]

--[[
	----------------------------------------------------------------------
	--							ToDo-list								--
	----------------------------------------------------------------------
	
]]

--Declaring all locals (out-of-scope)		--functions the self-made locals are used in
local abs = abs;
local BNGetFriendInfo = BNGetFriendInfo;
local BNGetNumFriends = BNGetNumFriends;
local BNInviteFriend = BNInviteFriend;
local BNSetFriendNote = BNSetFriendNote;
local BNGetToonInfo = BNGetToonInfo;
local floor = floor;
local format = string.format;
local getn = getTableLength;
local GetNumGroupMembers = GetNumGroupMembers;
local GetNumSubgroupMembers = GetNumSubgroupMembers;
local GetRealmName = GetRealmName;
local gsub = gsub;
OpenRaid.HasStartedInvites = false;			--OpenRaidInvite, OpenRaidFrameOnEvent
local IsInGroup = IsInGroup;
local IsInRaid = IsInRaid;
local IsInTutorial = false;					--OpenRaidTutorial, OpenRaidTutorialNext, OpenRaidTabs
local IsLooting = false;					--BonusRollDropdown, BonusRollLoot
local L = OpenRaid.L;						--Table containing all localised strings
local mod = mod;
local next = next;
local pairs = pairs;
local Pname = OpenRaid.Pname;
local Prefix = "OpenRaid";
local print = print;
local Rolls = {};							--OpenRaidFrameOnEvent, AssignLoot
local select = select;
local strfind = strfind;
local strlen = strlen;
local strlower = strlower;
local strmatch = strmatch;
local type = type;
local tonumber = tonumber;
local UnitName = UnitName;
local UpdateAvailble = false;
local Whisperword;							--OpenRaidToggleWordInvite, OpenRaidDisableWordInvite, OpenRaidTabs

--Default database
local defaults = {
	["Rate"] = {
		["Raid"] = {
			["Name"] = "Raid",
		},
	},
	["Notes"] = {
		--["Battletag"] = "Charactername-Server",
		--["ID"] = "presenceName",
	},
	["Raids"] = {
		--[GetUnitName("player")] = {
--[[		["Even number"] = {
				"Name", -- [1]
				"day", -- [2]
				"month", -- [3]
				"year", -- [4]
				"hour", -- [5]
				"minutes", -- [6]
				"Battletag-Charactername-Server", -- [7]
			},	]]
		--},
	},
	["Leader"] = {
--[[	["Recurring event name"] = {
			["Bonus"] = {
				["Charactername-server"] = Bonus,
			},
		},	
	["News"] = {
	{
			"Title",
			"Text",
			"Imagepath",
		},	
		{
			"Come Get Your Cross Realm MSV, HoF, and ToES!",
			"At long last Mogu'shan Vaults, Heart of Fear, and Terrace of Endless Spring are available for cross realm - patch 5.2 is live after maintenance on March 5, 2013! OpenRaid is the place to catch up on loot and achievements for these raids. Check out the Events\npage for searching for, or creating your",
			"Interface\\AddOns\\OpenRaid\\Images\\OR52",
		},
		{
			"OpenRaid's 1st Annual Pet Battle Competition!",
			"OpenRaids 1st Annual Pet Battle Competition (2013)\nDATES: Rounds 1-3 March 9th; Quarter Finals, Semi Finals, and Finals\non March 16thTIME: US - 10PM EST\nREALM: US Region - Argent Dawn (anyone able to create toons on\nUS realms may participate, i.e.Oceanic, Latin America, & Brazil, \nas level one toons will be involved)",
			"Interface\\AddOns\\OpenRaid\\Images\\OR51",
		},
		{
			"OpenRaid Special Event: An Evening with Slootbag",
			"Hey there Alliance! :D\nJoin us for a special one-time event where you can raid with Slootbag,\nMain Tank from US-Alliance #1 Midwinter, and be part of a Q and A after!\nWe will be running through Black Temple and Sunwell Plateau.\nWe will be choosing the lucky members to attend this raid at random\nfrom all those eligible US-Alliance members who sign up.\nDetails regarding this process will be highlighted on the Event page.",
			"Interface\\AddOns\\OpenRaid\\Images\\OR53",
		},
		{
			"OpenRaid Special Event: Naxx Fun Run with AskMrRobot",
			"OpenRaid is proud to announce a new friendship with AskMrRobot!\nIn celebration of this partnership, we'd like to invite members to join us\non a Naxxramas Fun Runwith the AskMrRobot staff, which will be followed\nby a Q&A session where users can ask about the website itself and\ngear optimization in general. Please note, you are required to submit\nyour questions forthe Q&A in advance.\nPlease post your questions in the comment section of this news story.",
			"Interface\\AddOns\\OpenRaid\\Images\\OR54",
		},
	},]]
	},
	["Options"] = {
		--Version (A.BCD)					Status:
		--A: Major revamps/recodes 			RELEASE
		--B: Big features/additions 		RELEASE
		--C: Minor features/major bug fixes BETA
		--D: Minor bug fixes/typos 			ALPHA
		["Version"] = 2.1,
		["Tutorial"] = true,
		["Defaultpage"] = "Index",
		["Auto enable sent"] = false,
		["Auto enable accept"] = false,
		["Personal send message"] = L["Request sent text"],
		["Whisperword"] = false,
		["Clean up time"] = 7,
		["Filter have invited"] = true,
		["Filter already in group"] = true,
		["Filter joined your group"] = false,
		["Automatically send requests"] = false,
		["Clear raids after X days"] = false,
		["DontCheckForChar"] = false,
		["Ignore when removing"] = {},
		["Specialnote"] = false,
	},
	["String"] = {
	},
}
OR_db = defaults;

--[[
	----------------------------------------------------------------------
	--					Whisperinvite implementation					--
	----------------------------------------------------------------------
]]

do
	local Whisperinvite = false
	local RemBNMessage
	--Enables/disables Whisper event number invite
	function OpenRaidToggleWordInvite()
		if OpenRaidFrameInvitePlusInvite:GetText() == L["Use whisper invite"] then
			Whisperinvite = true;
			local N;
			local G = OpenRaidGetDropdowntext(OpenRaidFrameInviteRaid);
			local own = OR_db.Options["Whisperword"]
			if G and G ~= "Raid" then
				Whisperword = (not own and G) or own;
				N = OR_db.Raids[Pname][G][1];
			else
				local Text = OpenRaidFrameInviteBorderScrollFrameEditBox:GetText();
				if Text[1] == Pname then
					if Text[2] and Text[2] ~= "" then
						Whisperword, N = strsplit(",", Text[2]);
						if own then
							Whisperword = own;
						end
					end
				elseif Text ~= "" then
					OpenRaidAddMessageToErrorQueue( { L["Not correct character"], } );
				end
			end
			if N then
				RemBNMessage = select(4, BNGetInfo());
				if not own then
					BNSetCustomMessage(format(L["BN whisperinvite message"], N));
				else
					BNSetCustomMessage(format(L["BN whisperinvite message own"], OR_db.Options["Whisperword"], N));
				end
				OpenRaidFrameInvitePlusInvite:SetText(L["Stop whisper invite"]);
			end
			OpenRaidFrame.CHAT_MSG_BN_WHISPER = true;
		else
			OpenRaidFrame.CHAT_MSG_BN_WHISPER = false;
			OpenRaidDisableWordInvite();
		end
	end

	--Disables Whisper event number invite
	function OpenRaidDisableWordInvite()
		Whisperword = nil;
		if RemBNMessage then
			BNSetCustomMessage(RemBNMessage);
		elseif Whisperinvite then
			BNSetCustomMessage("")
		end
		RemBNMessage = nil;
		Whisperinvite = false;
		OpenRaidFrameInvitePlusInvite:SetText(L["Use whisper invite"]);
	end
end

--[[
	----------------------------------------------------------------------
	--					Remove friends function							--
	----------------------------------------------------------------------
]]

do
	local removefriends = {};
	local function OpenRaidRemoveFriendScrollBar_Update()
		local line, lineplusoffset;
		if getn(removefriends) > 5 then
			FauxScrollFrame_Update(OpenRaidRemoveFriendsScrollFrame, getn(removefriends), 5, 234/5);
		end
		for line=1,5 do
			_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "Popup"]:Hide()
			lineplusoffset = line + FauxScrollFrame_GetOffset(OpenRaidRemoveFriendsScrollFrame);
			local Fontstring = _G["OpenRaidRemoveFriendsFrameEntry" .. line .. "FontString"];
			if lineplusoffset <= getn(removefriends) then
				_G[_G["OpenRaidRemoveFriendsFrameEntry" .. line]:GetName() .. "Text"]:SetText(removefriends[lineplusoffset][1]);
				_G["OpenRaidRemoveFriendsFrameEntry" .. line]:Show();
				_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "Ignore"]:Show();
				_G["OpenRaidRemoveFriendsFrameEntry" .. line]:SetChecked(removefriends[lineplusoffset][2])
				local count = 0;
				local Raids = ":";
				for k,v in pairs(OR_db.Raids[Pname]) do
					if strfind(v[7], _G[_G["OpenRaidRemoveFriendsFrameEntry" .. line]:GetName() .. "Text"]:GetText()) then
						count = count + 1;
						if count <= 3 then
							Raids = Raids .. "\n" .. v[1];
						end
					end
				end
				if count > 3 then
					Raids = Raids .. format(L["More raids"], (count - 3));
				end
				Fontstring:SetText(format(L["Joined your raids"], count));
				Fontstring:Show();
				_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "FontstringFrame"]:Show();
				_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "PopupFontString"]:SetText(format(L["Joined your raids"] .. "%s", count, Raids));
				if count > 0 then
					_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "FontstringFrame"]:SetScript("OnEnter", function()
						_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "Popup"]:Show()
					end)
				else
					_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "FontstringFrame"]:SetScript("OnEnter", nil)
				end
			else
				Fontstring:Hide();
				_G["OpenRaidRemoveFriendsFrameEntry" .. line]:Hide();
				_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "FontstringFrame"]:Hide();
				_G["OpenRaidRemoveFriendsFrameEntry" .. line .. "Ignore"]:Hide();
			end
		end
	end
	
	local function removefriendsupdate()
		removefriends = {};
		for i=1, BNGetNumFriends() do
			local ID, _, battleTag, _, _, _, _, _, lastOnline, _, _, _, noteText = BNGetFriendInfo(i);
			if noteText and noteText ~= "" then
				if strfind(noteText, "#OpenRaid") then
					if not OR_db.Options["Ignore when removing"][battleTag] then
						tinsert(removefriends, {battleTag, false, ID, lastOnline });
					end
				end
			end
		end
		table.sort(removefriends, function(a,b)
			return a[4] > b[4];
		end)
	end
	
	function OpenRaidRemoveFriendsFrameAllOnClick(self)
		self:GetParent():Hide();
		local attendees = OR_db.Raids[Pname][strsplit(",", self:GetText())][7];
		for k,v in pairs(removefriends) do
			if strfind(attendees, v[1]) then
				removefriends[k][2] = true;
			end
		end
		OpenRaidRemoveFriendScrollBar_Update();
	end

	function OpenRaidRemoveFriends()
		local Frame
		if not _G["OpenRaidRemoveFriendsFrame"] then
			Frame = CreateFrame("Frame", "OpenRaidRemoveFriendsFrame", OpenRaidFrame);
			Frame:SetBackdrop( {
				bgFile = "Interface\\AddOns\\OpenRaid\\Images\\FrameBackground", 
				edgeFile = "Interface\\AddOns\\OpenRaid\\Images\\FrameBorder", 
				tile = true, tileSize = 16, edgeSize = 16, 
				insets = { left = 4, right = 4, top = 4, bottom = 4 }
			});
			Frame:SetBackdropColor(0,0,0,1);
			Frame:SetSize(350,250);
			Frame:SetPoint("TOPLEFT", OpenRaidFrame, "TOPLEFT", 0, 250);
			local ScrollFrame = CreateFrame("ScrollFrame", "OpenRaidRemoveFriendsScrollFrame", OpenRaidRemoveFriendsFrame, "OpenRaidScrollFrameTemplate");
			ScrollFrame:SetPoint("TOPLEFT", OpenRaidRemoveFriendsFrame, "TOPLEFT", 5, -5);
			ScrollFrame:SetSize(320,234);
			for i=1,5 do
				local Entry = CreateFrame("CheckButton", "OpenRaidRemoveFriendsFrameEntry" .. i, OpenRaidRemoveFriendsScrollFrame, "OptionsCheckButtonTemplate");
				if i == 1 then
					Entry:SetPoint("TOPLEFT", OpenRaidRemoveFriendsScrollFrame, "TOPLEFT", 25, 0);
				else
					Entry:SetPoint("TOPLEFT", _G["OpenRaidRemoveFriendsFrameEntry" .. (i - 1)], "BOTTOMLEFT", 0, -15);
				end
				_G[Entry:GetName() .. "Text"]:SetText(DEFAULT);
				Entry:SetScript("OnClick", function(self, button, down)
					for k,v in pairs(removefriends) do
						if v[1] == _G[self:GetName() .. "Text"]:GetText() then
							if self:GetChecked() then
								removefriends[k][2] = true;
							else
								removefriends[k][2] = false
							end
						end
					end
				end);
				Entry:Show();
				
				local Ignore = CreateFrame("Button", "OpenRaidRemoveFriendsFrameEntry" .. i .. "Ignore", OpenRaidRemoveFriendsScrollFrame);
				Ignore:SetSize(20, 20);
				Ignore:SetPoint("RIGHT", _G["OpenRaidRemoveFriendsFrameEntry" .. i], "LEFT", 0, 0);
				Ignore:SetNormalTexture("Interface/Buttons/UI-GroupLoot-Pass-Up");
				Ignore:SetHighlightTexture("Interface/Buttons/UI-GroupLoot-Pass-Highlight", "ADD");
				Ignore:SetPushedTexture("Interface/Buttons/UI-GroupLoot-Pass-Down");
				Ignore:SetScript("OnClick", function(self, button, down)
					OpenRaidConfirmHandle(L["Confirm remove friend"], function()
						OR_db.Options["Ignore when removing"][_G[Entry:GetName() .. "Text"]:GetText()] = true;
						removefriendsupdate();
						OpenRaidRemoveFriendScrollBar_Update();
					end);
				end);
				OpenRaidGameTooltip(Ignore, L["Confirm remove friend tooltip"]);
				Ignore:Show();
				
				local FontstringFrame = CreateFrame("Frame", "OpenRaidRemoveFriendsFrameEntry" .. i .. "FontstringFrame", OpenRaidRemoveFriendsScrollFrame);
				OpenRaidFakebackdrop(FontstringFrame);
				FontstringFrame:SetSize(200, 20)
				FontstringFrame:SetPoint("TOPLEFT", _G["OpenRaidRemoveFriendsFrameEntry" .. i], "TOPLEFT", 20, -25)
				FontstringFrame:Show();
				
				local Fontstring = OpenRaidCreateFontString("OpenRaidRemoveFriendsFrameEntry" .. i .. "FontString", FontstringFrame:GetName(), "TOPLEFT", FontstringFrame:GetName(), "TOPLEFT", 0, 0, DEFAULT, nil)
				
				local FontPopup = CreateFrame("Frame", "OpenRaidRemoveFriendsFrameEntry" .. i .. "Popup", OpenRaidRemoveFriendsScrollFrame);
				FontPopup:SetBackdrop( {
					bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
					edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
					tile = true, tileSize = 16, edgeSize = 16, 
					insets = { left = 4, right = 4, top = 4, bottom = 4 }
				});
				FontPopup:SetBackdropColor(0,0,0,1);
				FontPopup:SetSize(250,52)
				FontPopup:SetPoint("TOPLEFT", _G["OpenRaidRemoveFriendsFrameEntry" .. i], "TOPLEFT", 15, -20)
				FontPopup:SetFrameStrata("TOOLTIP")
				FontPopup:Hide()
				
				local PopupFontString = OpenRaidCreateFontString("OpenRaidRemoveFriendsFrameEntry" .. i .. "PopupFontString", FontPopup:GetName(), "TOPLEFT", FontPopup:GetName(), "TOPLEFT", 5, -4, DEFAULT, "LEFT")
				
				FontstringFrame:SetScript("OnEnter", function()
					_G["OpenRaidRemoveFriendsFrameEntry" .. i .. "Popup"]:Show()
				end)
				FontstringFrame:SetScript("OnLeave", function()
					_G["OpenRaidRemoveFriendsFrameEntry" .. i .. "Popup"]:Hide()
				end)
			end
			ScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
				FauxScrollFrame_OnVerticalScroll(self, offset, 234/5, OpenRaidRemoveFriendScrollBar_Update)
			end)
			
			local Accept = CreateFrame("Button", "OpenRaidRemoveFriendsFrameAccept", OpenRaidRemoveFriendsFrame, "OpenRaidButtonTemplate")
			Accept:SetPoint("BOTTOMLEFT", OpenRaidRemoveFriendsFrame, "BOTTOMLEFT", 8, 8)
			Accept:SetText(ACCEPT)
			Accept:SetScript("OnClick", function()
				local count = 0
				for i,v in ipairs(removefriends) do
					if v[2] then
						count = count + 1;
					end
				end
				OpenRaidConfirmHandle(format(L["Remove friends?"], count), function()
					for i,v in ipairs(removefriends) do
						if v[2] then
							BNRemoveFriend(v[3])
						end
					end
					_G["OpenRaidRemoveFriendsFrame"]:Hide();
				end, function() end)
			end)
			Accept:Show();
			
			local All = CreateFrame("Button", "OpenRaidRemoveFriendsFrameAll", OpenRaidRemoveFriendsFrame, "OpenRaidRaidDropDownTemplate")
			All:ClearAllPoints();
			All:SetPoint("LEFT", OpenRaidRemoveFriendsFrameAccept, "RIGHT", 20, 0)
			All:SetSize(86,20)
			All:SetText(ALL)
			local script = All:GetScript("OnClick");
			All:RegisterForClicks("RightButtonUp", "LeftButtonUp");
			local toggle = false;
			All:SetScript("OnClick", function(self, button)
				if button == "RightButton" then
					script(self);
				else
					self.list:Hide();
					toggle = not toggle;
					for i,v in ipairs(removefriends) do
						removefriends[i][2] = toggle;
					end
					for i=1, 5 do
						_G["OpenRaidRemoveFriendsFrameEntry" .. i]:SetChecked(toggle)
					end
				end
			end)
			OpenRaidGameTooltip(All, L["Remove friends all tooltip"]);
			All:Show();
			
			local Close = CreateFrame("Button", "OpenRaidRemoveFriendsFrameClose", OpenRaidRemoveFriendsFrame, "OpenRaidButtonTemplate")
			Close:SetPoint("LEFT", OpenRaidRemoveFriendsFrameAll, "RIGHT", 20, 0)
			Close:SetText(CLOSE)
			Close:SetScript("OnClick", function()
				_G["OpenRaidRemoveFriendsFrame"]:Hide();
				removefriends = {};
			end)
			Close:Show();
		else
			Frame = _G["OpenRaidRemoveFriendsFrame"];
		end
		
		removefriendsupdate();
		OpenRaidRemoveFriendScrollBar_Update()
		Frame:Show();
	end
end

--[[
	----------------------------------------------------------------------
	--					OpenRaid calendar								--
	----------------------------------------------------------------------
]]
do
	local CurrentMonth, CurrentStartday, CurrentYear, day, LastDay, month, weekday, year;
	local Months = {{"JANUARY", 31, },{"FEBRUARY", 28, },{"MARCH", 31, },{"APRIL", 30, },{"MAY", 31, },{"JUNE", 30, },{"JULY", 31, },{"AUGUST", 31, },{"SEPTEMBER", 30, },{"OCTOBER", 31, },{"NOVEMBER", 30, },{"DECEMBER", 31, },};
	local Weekdays = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday",}
	
	--Configuring in-AddOn calendar
	local function OpenRaidCalendarReset()
		OpenRaidFrameCalendarPopup:Hide();
		for i=1, 6 do
			for n=1, 7 do
				local D
				if not _G["OpenRaidFrameCalendar" .. i .. n] then
					D = CreateFrame("Button", "OpenRaidFrameCalendar" .. i .. n, OpenRaidFrameCalendar, "OpenRaidCalendarButtonTemplate");
					if n == 1 then
						if i == 1 then
							D:SetPoint("TOPLEFT", "OpenRaidFrameCalendar", "TOPLEFT", 35, -15);
						else
							D:SetPoint("TOPLEFT", "OpenRaidFrameCalendar" .. (i - 1) .. n, "TOPLEFT", 0, -40);
						end
					else
						D:SetPoint("RIGHT", "OpenRaidFrameCalendar" .. i .. (n - 1), "RIGHT", 40, 0);
					end
					D:SetScript("OnLeave", function(self)
						GameTooltip:Hide();
					end)
				end
				D = _G["OpenRaidFrameCalendar" .. i .. n]
				D:SetScript("OnEnter", nil)
				D:SetScript("OnClick", nil)
				D:Enable();
				D:SetText("");
				D:Show();
				D:UnlockHighlight();
			end
		end
	end

	local function OpenRaidCalendarUpdate()
		OpenRaidCalendarReset();
		OpenRaidFrameCalendarTitle:SetText(_G["FULLDATE_MONTH_" .. Months[CurrentMonth][1]] .. "   " .. CurrentYear);
		local LastMonth = CurrentMonth;
		if LastMonth - 1 < 1 then --Previous month is from last year
			LastMonth = LastMonth + 12;
		end
		for i=1, (CurrentStartday - 1) do --Last days of previous month
			if CurrentStartday - i > 0 then
				_G["OpenRaidFrameCalendar1" .. (CurrentStartday - i)]:SetText(Months[LastMonth - 1][2] - i + 1);
				_G["OpenRaidFrameCalendar1" .. (CurrentStartday - i)]:Disable();
			end
		end
		local CurrentDate = CurrentStartday;
		local Weeks = 1;
		for i=1, Months[CurrentMonth][2] do
			if CurrentDate > 7 then
				CurrentDate = CurrentDate - 7;
				Weeks = Weeks + 1;
			end
			_G["OpenRaidFrameCalendar" .. Weeks .. CurrentDate]:SetText(i);
			
			local RaidIDs = {};
			
			local Raids = "All raids this day:";
			for k,v in pairs(OR_db.Raids[Pname]) do --Implementing tooltips for imported raids
				if i == tonumber(v[2]) and CurrentMonth == tonumber(v[3]) and CurrentYear == tonumber(v[4]) then
					Raids = Raids .. "\n" .. v[5] .. ":" .. v[6] .. "  " .. v[1];
					RaidIDs[k] = v;
				end
			end
			
			if Raids ~= "All raids this day:" then
				_G["OpenRaidFrameCalendar" .. Weeks .. CurrentDate]:SetScript("OnEnter", function(self)
					GameTooltip:ClearLines();
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
					GameTooltip:AddLine(Raids);
					GameTooltip:Show();
				end)
				
				local info = "";
				for k,v in pairs(RaidIDs) do
					info = info .. "\n|cffFF4500" .. k .. " " .. v[1] .. "|r\n\n";
					local people = { strsplit(",", OR_db.Raids[Pname][k][7]) };
					for i=1, getn(people) do
						info = info .. people[i] .. "\n";
					end
				end
				
				_G["OpenRaidFrameCalendar" .. Weeks .. CurrentDate]:LockHighlight();
				_G["OpenRaidFrameCalendar" .. Weeks .. CurrentDate]:SetScript("OnClick", function()
					OpenRaidFrameCalendarPopup:Show();
					OpenRaidFrameCalendarPopupListTextInfo:SetText(info);
				end)
			elseif i == day and CurrentMonth == month then --Calculated day is the current date
				_G["OpenRaidFrameCalendar" .. Weeks .. CurrentDate]:LockHighlight();
				_G["OpenRaidFrameCalendar" .. Weeks .. CurrentDate]:SetScript("OnEnter", function(self)
					GameTooltip:ClearLines();
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
					GameTooltip:AddLine("Today");
					GameTooltip:Show();
				end)
			end
			
			LastDay = CurrentDate;
			CurrentDate = CurrentDate + 1;
		end
		local DatesLeft = 42 - ((Weeks - 1) * 7) - (CurrentDate - 1); --Leftovers filled with days of next month
		for i=1, DatesLeft do
			if DatesLeft - i >= 0 then
				if CurrentDate > 7 then
					CurrentDate = CurrentDate - 7;
					Weeks = Weeks + 1;
				end
				_G["OpenRaidFrameCalendar" .. Weeks .. CurrentDate]:SetText(i);
				_G["OpenRaidFrameCalendar" .. Weeks .. CurrentDate]:Disable();
				CurrentDate = CurrentDate + 1;
			end
		end
	end

	function OpenRaidCalendarCurrentUpdate()
		weekday, month, day, year = CalendarGetDate(); --The current date of the year
		CurrentMonth = month; --Month to show = current one
		CurrentYear = year; -- year to show = current one
		local Offset = day - 1; -- calculating number of weekday of 1st of month
		Offset = mod(Offset, 7);
		local Startday = weekday - Offset - 1; --number of startday for table Weekdays
		if Startday <= 0 then
			Startday = Startday + 7;
		end
		CurrentStartday = Startday --Startday of shown month
		OpenRaidCalendarUpdate()
	end

	function OpenRaidCalendarNext()
		CurrentMonth = CurrentMonth + 1; --Next month
		if CurrentMonth > 12 then --December -> January
			CurrentMonth = CurrentMonth - 12;
			CurrentYear = CurrentYear + 1;
		end
		if LastDay > 6 then --Monday of next week
			LastDay = LastDay - 7;
		end
		CurrentStartday = LastDay + 1
		OpenRaidCalendarUpdate()
	end

	function OpenRaidCalendarPrev()
		CurrentMonth = CurrentMonth - 1; --Previous month
		if CurrentMonth <= 0 then --January -> December
			CurrentMonth = CurrentMonth + 12;
			CurrentYear = CurrentYear - 1;
		end
		CurrentStartday = CurrentStartday - Months[CurrentMonth][2] --Calculating startday back of the current month
		while CurrentStartday < 1 do
			CurrentStartday = CurrentStartday + 7
		end
		OpenRaidCalendarUpdate()
	end
end

--[[
	----------------------------------------------------------------------
	--					Custom OpenRaid tutorial						--
	----------------------------------------------------------------------
]]

local Arrow;
do
	local S, step
	local TutorialDB = {}; 
	
	local function OpenRaidTutorialNext()
		S:SetText("");
		Arrow:Hide();
		step = step + 1;
		local Step = TutorialDB[step]
		local arrow = Step.Arrow;
		if arrow then
			Arrow:SetPoint(arrow.A1, OpenRaidFrame, arrow.A2, arrow.X, arrow.Y);
			Arrow:SetTexture("Interface\\AddOns\\OpenRaid\\Images\\arrow" .. arrow.Pos);
			Arrow:Show();
		end
		S:SetText(L["Tutorial"][step]);
		if Step.Child then
			if Step.Child.Name ~= "Stay" then
				OpenRaidTabs(OpenRaidFrame, Step.Child.Name, nil, true)
			end
		else
			OpenRaidTabs(OpenRaidFrame, nil, nil, true)
		end
		if Step.Function then
			local Func = Step.Function
			Func()
		end
		if step == getn(TutorialDB) then --We reached the end of the tutorial
			OpenRaidFrameTutorialNext:SetText(L["End"])
			OpenRaidFrameTutorialNext:SetScript("OnClick", function()
				IsInTutorial = false;
				OpenRaidFrameTutorial:Hide();
				Arrow:Hide();
				OpenRaidTabs(OpenRaidFrame, OR_db.Options["Defaultpage"]);
			end)
		end
	end

	function OpenRaidTutorial()
		OpenRaidFrame:Show();
		IsInTutorial = true;
		OpenRaidFrameTutorialNext:SetText("Next step")
		OpenRaidFrameTutorial:Show();
		OpenRaidFrameTutorialNext:SetScript("OnClick", function() OpenRaidTutorialNext() end)
		TutorialDB = OpenRaidTutorialSteps;
		step = 0
		local self = OpenRaidFrameTutorial;
		if not self["TutorialFontString"] then
			self["TutorialFontString"] = OpenRaidCreateFontString("OpenRaidTutorialFontString", OpenRaidFrameTutorial, "TOPLEFT", OpenRaidFrameTutorial, "TOPLEFT", 15, -15, DEFAULT, "LEFT")
			S = self["TutorialFontString"];
		else
			S = self["TutorialFontString"];
		end
		S:SetText(L["Tutorial welcome"]);
		Arrow = OpenRaidFrame:CreateTexture(OpenRaidFrame, "Overlay")
		Arrow:SetPoint("TOP", OpenRaidFrame, "TOPRIGHT", 50, 50);
		Arrow:SetTexture("Interface\\AddOns\\OpenRaid\\Images\\arrowdown");
		Arrow:Hide();
	end
end

--[[
	----------------------------------------------------------------------
	--						Bonus rolls									--
	----------------------------------------------------------------------
]]

local BonusRollDropdown, AssignLoot
do
	AssignLoot = function(Loot)
		local chan = GetOutputChannel()
		SendChatMessage(L["Loot roll end"], chan);
		if not next(Rolls) then
			SendChatMessage(L["No loot roll"], chan);
			DoMasterLootRoll(Loot);
			return
		end
		local Highest = 0;
		local Winner
		local SameRoll = {}
		for k,v in pairs(Rolls) do
			if Highest < tonumber(v) + (Bonus[k] or 0) then
				Highest = tonumber(v) + (Bonus[k] or 0);
				Winner = k;
			elseif Highest == tonumber(v) + (Bonus[k] or 0) then
				Winner = "No one";
				SameRoll[getn(SameRoll) + 1] = k;
			end
			SendChatMessage(k .. " rolled " .. v .. "+" .. (Bonus[k] or 0) .. " = " .. tostring(v + (Bonus[k] or 0)), chan);
		end
		if Winner == "No one" then
			SendChatMessage(L["Same roll"], chan);
			for i=1, getn(SameRoll) do
				SendChatMessage(SameRoll[i], chan);
			end
		else
			SendChatMessage(format(L["Highest roll"], Highest) .. Winner, chan);
			for k,v in pairs(Bonus) do
				if k ~= Winner then
					Bonus[k] = Bonus[k] + 5;
				end
			end
			Bonus[Winner] = 0;
		end
		for i = 1, GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) do
			if GetMasterLootCandidate(Loot, i) == Winner then
				GiveMasterLoot(Loot, i);
			end
		end
		Rolls = {};
		OpenRaidFrame:UnregisterEvent("CHAT_MSG_SYSTEM");
	end

	local function BonusRollLoot(Loot)
		if IsLooting then
			print(L["Already looting"])
			return
		end
		IsLooting = Loot;
		OpenRaidFrame:RegisterEvent("CHAT_MSG_SYSTEM");
		SendChatMessage(format(L["Loot roll start"],GetLootSlotLink(Loot)), GetOutputChannel());
		local Frame = OpenRaidBonusTimer or CreateFrame("FRAME", "OpenRaidBonusTimer")
		OpenRaidBonusTimer.TimeSinceLastUpdate = 0;
		OpenRaidBonusTimer:SetScript("OnUpdate", function(self, elapsed)
			OpenRaidBonusTimer.TimeSinceLastUpdate = OpenRaidBonusTimer.TimeSinceLastUpdate + elapsed;
			if not LootFrame:IsShown() then
				OpenRaidBonusTimer.TimeSinceLastUpdate = 0;
				OpenRaidBonusTimer:SetScript("OnUpdate", function()end)
				IsLooting = nil;
				print("weg gegaan");
			end
			if OpenRaidBonusTimer.TimeSinceLastUpdate > 60 then
				AssignLoot(LootFrame.selectedSlot)
				OpenRaidBonusTimer.TimeSinceLastUpdate = OpenRaidBonusTimer.TimeSinceLastUpdate - 60;
				OpenRaidBonusTimer:SetScript("OnUpdate", function()end)
				IsLooting = nil;
			end
		end)
	end
	
	--[[Override master looter function from LootFrame.lua
	BonusRollDropdown = function()
		local info = UIDropDownMenu_CreateInfo();
		info.isTitle = 1;
		info.text = MASTER_LOOTER;
		info.fontObject = GameFontNormalLeft;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
		 
		info = UIDropDownMenu_CreateInfo();
		info.notCheckable = 1;  
		info.text = ASSIGN_LOOT;
		info.func = function() if not (IsLooting == LootFrame.selectedSlot) then MasterLooterFrame_Show(); end end;
		UIDropDownMenu_AddButton(info); 
		info.text = REQUEST_ROLL;
		info.func = function() if not (IsLooting == LootFrame.selectedSlot) then DoMasterLootRoll(LootFrame.selectedSlot); end end;
		UIDropDownMenu_AddButton(info);
		--And add our own button
		info.text = L["Bonus roll"];
		info.func = function() BonusRollLoot(LootFrame.selectedSlot); end;
		UIDropDownMenu_AddButton(info);
	end]]
end

--[[
	----------------------------------------------------------------------
	--			Functions exclusively used in OpenRaid.xml				--
	----------------------------------------------------------------------
]]

do
	function OpenRaidCreateRaid()
		local Text = OpenRaidFrameCreateRaidBorderScrollFrameEditBox:GetText()	--Jeremybell-Realm*19002,Testraid3,19,1,2013,18,00;Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
		Text = { strsplit("*", Text) } 											--Jeremybell-Realm 	19002,Testraid3,19,1,2013,18,00;Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
		if Text and Text[1] and (Text[1] == Pname or OR_db.Options["DontCheckForChar"]) then
			OpenRaidFrameCreateRaidBorderScrollFrameEditBox:SetText("")
			local Times
			local events = {};
			for i=2, getn(Text) do
				if Text[i] and Text[i] ~= "" then
					local Data = { strsplit(";", Text[i]) }						--19002,Testraid3,19,1,2013,18,00		Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
					Times = { strsplit(",", Data[1]) }							--19002		Testraid3		19		1		2013	18		00
					if getn(Times) ~= 7 then
						OpenRaidAddMessageToErrorQueue( { L["Import string corrupt"], } );
						return
					end
					if Data[2] and Data[2] ~= "" then
						local People = { strsplit(",", Data[2]) }					--Unknown#2101-Pinque-Darksorrow		Unknown#2838-Pinque-Darksorrowz
						local Number = tostring(Times[1])							--19002
						OR_db.Raids[Pname][Number] = OR_db.Raids[Pname][Number] or {};
						for i=1, 6 do
							OR_db.Raids[Pname][Number][i] = Times[i + 1]
						end
						OR_db.Raids[Pname][Number][7] = People[1];
						for i=2, getn(People) do
							if not strfind(OR_db.Raids[Pname][Number][7], People[i]) then
								OR_db.Raids[Pname][Number][7] = OR_db.Raids[Pname][Number][7] .. "," .. People[i]
							end
						end
					else
						tinsert(events, Times);
					end
				end
			end
			if getn(events) > 0 then
				OpenRaidConfirmHandle(L["Event no members import"], function()
					for k,v in pairs(events) do
						local Number = tostring(v[1])
						OR_db.Raids[Pname][Number] = OR_db.Raids[Pname][Number] or {};
						for i=1, 6 do
							OR_db.Raids[Pname][Number][i] = v[i + 1]
						end
						OR_db.Raids[Pname][Number][7] = "Own event";
					end
					OpenRaidAddMessageToErrorQueue( { L["Raid succesfully imported"], } );
				end);
				return;
			end
			OpenRaidAddMessageToErrorQueue( { L["Raid succesfully imported"], } );
			if OR_db.Options["Automatically send requests"] then
				OpenRaidFrameAddRaid:SetText(tostring(Times[1]) .. "," .. Times[2]) --Hacky but working
				OpenRaidSendRequests()
			end
		else
			OpenRaidAddMessageToErrorQueue( { L["Not correct character"], } );
		end
	end

	function OpenRaidSendRequests()
		local G = OpenRaidGetDropdowntext(OpenRaidFrameAddRaid)
		local RaidName;
		local People;
		if G ~= "Raid" then
			People = { strsplit(",", OR_db.Raids[Pname][G][7]) };
			RaidName = OR_db.Raids[Pname][G][1];
			OpenRaidFrameAddRaid:SetText("Raid");
		else
			local Text = OpenRaidFrameAddBorderScrollFrameEditBox:GetText()						--Jeremybell-Realm*19002,Testraid3;Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
			OpenRaidFrameAddBorderScrollFrameEditBox:SetText("")
			if Text == "" then
				OpenRaidAddMessageToErrorQueue( { L["No raid selected"], } );
				return
			end
			local Data = { strsplit("*", Text, 3) };									--Jeremybell-Realm		19002,Testraid3;Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
			if Data[1] == Pname then
				local Signups = { strsplit(";", Data[2]) }								--19002,Testraid3		Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
				RaidName = Signups[1];
				People = { strsplit(",", Signups[2]) };									--Unknown#2101-Pinque-Darksorrow		Unknown#2838-Pinque-Darksorrowz
			else
				OpenRaidAddMessageToErrorQueue( { L["Not correct character"], } );
				return;
			end
		end
		
		if not People or People[1] == "Own event" then
			OpenRaidAddMessageToErrorQueue( { L["Event no members send"], } );
			return
		end
		
		local n = getn(People);
		local i = 1;
		while (i < n) do
			local BNInfo = { strsplit("-", People[i]) };
			if IsAlreadyBattleTagFriend(BNInfo[1]) then
				tremove(People, i);
				n = n - 1;
				i = i - 1;
			end
			i = i + 1;
		end
		
		if getn(People) + BNGetNumFriends() > 200 then --Blizzard battlenet friends cap check
			OpenRaidConfirmHandle(L["Too many BN friends"], function() OpenRaidRemoveFriends() end)
			return
		end
		print(L["Sending battletag requests"]);
		for i=1, getn(People) do
			if People[i] and People[i] ~= "" then
				local Battle, Name, Server = strsplit("-", People[i])
				--We ignore people of our own realm.
				if Battle ~= "" then
					if not isBattleTag(Battle) then
						OpenRaidAddMessageToErrorQueue( { format(L["Bad battletag"], Battle), } )
						break
					end
					--Since 6.0 we have to throttle requests once/10 seconds
					C_Timer.After((i-1)*10, function() BNSendFriendInvite(Battle, format(L["Request sent text"], G, OR_db.Raids[Pname][G][1])) end);
					if not OR_db.Notes[strlower(Battle)] then
						OR_db.Notes[strlower(Battle)] =  date("*t").year .. "^" .. date("*t").month .. "^" .. date("*t").day .. "^" .. Name .. (OR_db.Options["Specialnote"] and ";" .. G .. "," .. RaidName or "");
					elseif type(OR_db.Notes[strlower(Battle)]) ~= "boolean" and not strfind(OR_db.Notes[strlower(Battle)], Name) then
						OR_db.Notes[strlower(Battle)] = OR_db.Notes[strlower(Battle)] .. "," .. Name .. (OR_db.Options["Specialnote"] and ";" .. G .. "," .. RaidName or "");
					end
				end
			end
		end
		
		OpenRaidAddMessageToErrorQueue( { L["Raid request sent"], } );
	end
end

--[[
	----------------------------------------------------------------------
	--					Initilization OpenRaid AddOn					--
	--				All these functions are only called once			--
	----------------------------------------------------------------------
]]

local Init
do
	--[[
		----------------------------------------------------------------------
		--						Create Options								--
		----------------------------------------------------------------------
	]]

	local CreateOptions
	do
		--Functions to create our options using the OpenRaidOptions table in Options.lua
		local function CreateOption(v, previous, xoffset, yoffset)
			local Frame = CreateFrame(v.type, "OpenRaidFrameOptionsContainer" .. v.name, OpenRaidFrameOptionsContainer, v.inherits);
			if v.size then
				Frame:SetSize(v.size.X, v.size.Y)
			end
			--These 2 get anchored in a strange way, fixed by xoffseting
			if v.type == "EditBox" then
				xoffset = 10;
			end
			Frame:ClearAllPoints();
			Frame:SetPoint("TOPLEFT", previous or OpenRaidFrameOptionsContainer, "TOPLEFT", previous and  0 + (xoffset or 0) or 7, previous and -30 - (yoffset or 0) or -7)
			if v.tooltip then
				OpenRaidGameTooltip(_G[Frame:GetName()], v.tooltip)
			end
			if v.inherits == "OptionsCheckButtonTemplate" then --Is it a checkbutton
				_G[Frame:GetName() .. "Text"]:SetText(v.text)
				local Func = v.func
				_G[Frame:GetName()]:SetScript("OnClick", Func)
				if v.scripts then
					for k,v in pairs(v.scripts) do
						_G[Frame:GetName()]:SetScript(k, v)
					end
				else
					_G[Frame:GetName()]:SetChecked(OR_db.Options[v.text])
				end
			elseif v.inherits == "OpenRaidEditboxTemplate" then --Is it an editbox
				_G[Frame:GetName()]:SetText(OR_db.Options[v.text] or "")
				for k,v in pairs(v.scripts) do
					_G[Frame:GetName()]:SetScript(k, v)
				end
			elseif v.special == "choose" then --Is it a couple of options to choose from
				local ParentFrame = CreateFrame("FRAME", "OpenRaidFrameOptionsContainer" .. v.name .. "Frame", OpenRaidFrameOptionsContainer);
				OpenRaidFakebackdrop(ParentFrame);
				OpenRaidGameTooltip(ParentFrame, v.tooltip);
				ParentFrame:SetSize(100,50);
				ParentFrame:SetPoint("TOPLEFT", previous, "TOPLEFT", 0, -40);
				OpenRaidCreateFontString("OpenRaidFrameOptionsContainer" .. v.name .. "String", "OpenRaidFrameOptionsContainer" .. v.name .. "Frame", "TOPLEFT", ParentFrame, "TOPLEFT", 0, 0, v.text);
				local Prev = previous;
				local xOffset, yOffset = 30, 30;
				for k,v in pairs(v.Options) do
					Prev = CreateOption(v, Prev, xOffset, yOffset);
					--HARDCODED BECAUSE WE ONLY HAVE WHISPERWORD. NEEDS FIXING IF WE ADD MORE.
					OpenRaidCreateFontString("OpenRaidFrameOptionsContainer" .. v.name .. "String", "OpenRaidFrameOptionsContainer", "TOPLEFT", OpenRaidFrameOptionsContainer, "TOPLEFT", 10, -100 - 30 * k, k);
					yOffset = 0;
					if v.type == "EditBox" then
						xOffset = xOffset - 10;
					else
						xOffset = 0;
					end
				end
			end
			return Frame
		end

		CreateOptions = function()
			local previous
			local xoffset = 0;
			local height = -10;
			for k,v in pairs(OpenRaidOptions) do
				local Frame = CreateOption(v, previous, xoffset)
				previous = Frame;
				if v.type == "EditBox" then
					xoffset = xoffset - 10;
				elseif v.special == "choose" then
					if v.Options[getn(v.Options)]["type"] == "EditBox" then
						xoffset = xoffset - 40;
					else
						xoffset = xoffset - 30;
					end
					previous = _G["OpenRaidFrameOptionsContainer" .. v.Options[getn(v.Options)].name];
				else
					xoffset = 0;
				end
				height = height + 30
				Frame:Show()
			end
			if height > 250 then
				OpenRaidFrameOptionsContainer:SetHeight(height)
			end
			OpenRaidOptions = nil;
		end
	end

	--[[
		----------------------------------------------------------------------
		--					Send and accept buttons							--
		----------------------------------------------------------------------
	]]

	local FriendsFramePendingOpenRaidButtons, AddFriendFrameOpenRaidButtonCreate
	do
		local LastBNNumFriends
		
		--Setting notes next to your friends. *FriendGroups implementation*
		local function OpenRaidFriendListUpdate()
			if InCombatLockdown() then return end
			local check = getn(OR_db.Notes) > 0;
			if BNGetNumFriends() == 0 or (LastBNNumFriends and (BNGetNumFriends() == LastBNNumFriends or not check)) then --Login lagg causes this or saving cpu, we don't check if there's no reason to
				return
			else
				LastBNNumFriends = BNGetNumFriends();
			end
			local count;
			for i=1, LastBNNumFriends do
				local ID, battleTag, noteText;
				if check then
					ID, _, battleTag, _, _, _, _, _, _, _, _, _, noteText = BNGetFriendInfo(i);
				end
				if battleTag or ID then
					if OR_db.Notes[strlower(battleTag or "")] or OR_db.Notes[tostring(ID)] then
						if not noteText or not strfind(noteText, "#OpenRaid") then
							local note = OR_db.Notes[strlower(battleTag or "")] or OR_db.Notes[tostring(ID)];
							if (type(note) == "string") and strfind(note, ";") then
								note = "#OpenRaid #" .. gsub(select(2, strsplit(";", note)), "#", "");
							else
								note = "#OpenRaid ";
							end
							BNSetFriendNote(ID, note .. (noteText or ""));
						end
						if OR_db.Notes[strlower(battleTag)] then
							OR_db.Notes[strlower(battleTag)] = nil;
						else
							OR_db.Notes[tostring(ID)] = nil;
						end
					end
				end
				_, _, _, _, _, _, _, _, _, _, _, _, noteText = BNGetFriendInfo(i);
				if noteText and noteText ~= "" then
					if strfind(noteText, "#OpenRaid") then
						count = (count or 0) + 1
					end
				end
			end
			if count then
				OpenRaidGameTooltip(_G["RealIDCounterFrame"], format(L["# OpenRaid friends"], count));
			end
		end

		local function AddFriendFrameOpenRaidButtonOnShow()
			AddFriendFrameOpenRaidButton:Show()
			AddFriendNameEditBox:SetWidth(200)
			AddFriendNameEditBox:SetPoint("TOP", AddFriendFrame, -40, -130);
			AddFriendFrameOpenRaidButton:SetChecked(OR_db.Options["Auto enable sent"])
		end

		local function AddFriendFrameOpenRaidButtonOnHide()
			AddFriendFrameOpenRaidButton:Hide()
			AddFriendNameEditBox:SetWidth(280)
			AddFriendNameEditBox:SetPoint("TOP", AddFriendFrame, 0, -130);
			AddFriendFrameOpenRaidButton:SetChecked(false)
		end

		local function AddFriendFrameOpenRaidButtonOnAccept(battletag, text)
			if AddFriendFrameOpenRaidButton:GetChecked() then
				OR_db.Notes[strlower(battletag)] = date("*t").year .. "^" .. date("*t").month .. "^" .. date("*t").day .. "^" .. text;
				AddFriendFrameOpenRaidButton:SetChecked(false)
				OR_db.Notes[strlower(battletag)] = true;
			end
		end

		local function FriendsFramePendingButtonOpenRaidOnAccept(i, inviteID)
			local ID, Name = BNGetFriendInviteInfo(i);
			if ID == inviteID then --We doublecheck if everything went alright
				OR_db.Notes[tostring(ID)] = Name;
			end
		end

		FriendsFramePendingOpenRaidButtons = function()
			for i=1,4 do
				local CB = CreateFrame("CheckButton", "FriendsFramePendingButton" .. i .. "OpenRaidButton", _G["FriendsFramePendingButton" .. i], "OptionsCheckButtonTemplate")
				_G[CB:GetName() .. "Text"]:SetText("OpenRaid")
				CB:SetPoint("TOPRIGHT", _G["FriendsFramePendingButton" .. i .. "DeclineButton"], -100, 55)
				_G["FriendsFramePendingButton" .. i .. "AcceptButton"]:SetScript("OnClick", function(self)
					if _G["FriendsFramePendingButton" .. i .. "OpenRaidButton"]:GetChecked() then
						FriendsFramePendingButtonOpenRaidOnAccept(i, self:GetParent().inviteID)
					end
					BNAcceptFriendInvite(self:GetParent().inviteID);
					PlaySound("igMainMenuOptionCheckBoxOn");
				end)
				_G["FriendsFramePendingButton" .. i .. "OpenRaidButton"]:SetScript("OnShow", function(self)
					self:SetChecked(OR_db.Options["Auto enable accept"]);
				end)
			end
		end

		--Add a button next to the AddFriendFrame if the invited person is from OpenRaid
		AddFriendFrameOpenRaidButtonCreate = function()
			if not _G["AddFriendFrameOpenRaidButton"] then
				local button = CreateFrame("CheckButton", "AddFriendFrameOpenRaidButton", AddFriendFrame, "OptionsCheckButtonTemplate");
				_G[button:GetName() .. "Text"]:SetText("OpenRaid");
				button:SetPoint("RIGHT", AddFriendNameEditBox, "RIGHT", 50, 0);
				OpenRaidGameTooltip(_G["AddFriendFrameOpenRaidButton"], L["Found on OpenRaid?"])
			end
			local Hooks = {
				["AddFriendEntryFrame_Expand"] = AddFriendFrameOpenRaidButtonOnShow,
				["AddFriendEntryFrame_Collapse"] = AddFriendFrameOpenRaidButtonOnHide,
				["BNSendFriendInvite"] = AddFriendFrameOpenRaidButtonOnAccept,
				["FriendsList_Update"] = OpenRaidFriendListUpdate,
			}
			for k,v in pairs(Hooks) do
				hooksecurefunc(k, v);
			end
		end
	end

	--[[
		----------------------------------------------------------------------
		--					News feed implementation						--
		----------------------------------------------------------------------
	
	local NewsInit
	do
		local ag1, ag2
		local Tab = 1;
		local widthOR = 0;
		
		local function NewsUpdate()
			OR_db.News = defaults.News;
		end

		--Updates Newsfeed
		function OpenRaidNewsfeedupdate(offset)
			if ag1:IsPlaying() or ag2:IsPlaying() then
				return
			end
			widthOR = (widthOR or 0)  + offset;
			if widthOR < 0 then
				widthOR = 0
				return
			elseif widthOR > OpenRaidFrameIndexNewsFeed:GetWidth() then
				widthOR = widthOR - offset;
				return
			end
			if offset < 0 then
				Tab = Tab - 1;
				ag2:Play();
			else
				Tab = Tab + 1;
				ag1:Play()
			end
			OpenRaidFrameIndexTitle:SetText(OR_db.News[Tab][1])
		end

		NewsInit = function()
			if next(OR_db.News) == nil then
				return
			end
			local SF = OpenRaidFrameIndexNews or CreateFrame("ScrollFrame", "OpenRaidFrameIndexNews", OpenRaidFrameIndex, "OpenRaidNewsTemplate")
			local SC = OpenRaidFrameIndexNewsFeed or CreateFrame("Frame", "OpenRaidFrameIndexNewsFeed", OpenRaidFrameIndexNews)
			
			local height = 0;
			local width = 0;
			local padding = 5;
			local NR = 1
			
			for i, v in ipairs(OR_db.News) do
				if not SC["NI" ..i] then
					SC["NI" .. i] = CreateFrame("Frame", "OpenRaidFrameIndexNewsFeedNI" .. i, OpenRaidFrameIndexNewsFeed);
					SC["NI" ..i]:SetSize(450, 215)
				end
				local NI = SC["NI" .. i];
				if i == 1 then
					NI:SetPoint("TOPLEFT", 0, 0);
					OpenRaidFrameIndexTitle:SetText(OR_db.News[1][1])
					width = width + 450;
				else
					NI:SetPoint("RIGHT", SC["NI" .. (i - 1)], "RIGHT", 455, 0);
					width = width + 450 + padding;
				end
				SC["NI" .. i .. "Image"] = SC["NI" .. i .. "Image"] or SC:CreateTexture(nil, "Overlay")
				local I = SC["NI" .. i .. "Image"]
				I:SetParent(SC["NI" .. i]);
				I:SetPoint("TOPLEFT", SC["NI" .. i], "TOPLEFT", 20, -7);
				I:SetTexture(v[3]);
				I:Show()
				
				SC["NI" .. i .. "String"] = SC["NI" .. i .. "String"] or OpenRaidCreateFontString(SC["NI" .. i .. "String"], SC["NI" .. i], "TOPLEFT", SC["NI" .. i .. "Image"], "TOPLEFT", 0, -75, v[2], "LEFT")
			end
			SC:SetSize(width, 215)
			
			ag1 = SC:CreateAnimationGroup()
			a1 = ag1:CreateAnimation("Translation")
			a1:SetOffset(-323.5, 0)
			a1:SetDuration(1)
			a1:SetSmoothing("IN_OUT")
			a1:SetScript("OnUpdate", function(self)
				if self:GetProgress() == 1 then
					a1:Stop();
				end
			end)
			a1:SetScript("OnStop", function(self)
				OpenRaidFrameIndexNews:SetHorizontalScroll(widthOR);
			end)
			
			ag2 = SC:CreateAnimationGroup()
			a2 = ag2:CreateAnimation("Translation")
			a2:SetOffset(323.5, 0)
			a2:SetDuration(1)
			a2:SetSmoothing("IN_OUT")
			a2:SetScript("OnUpdate", function(self)
				if self:GetProgress() == 1 then
					a2:Stop();
				end
			end)
			a2:SetScript("OnStop", function(self)
				OpenRaidFrameIndexNews:SetHorizontalScroll(widthOR);
			end)
			
			SF:SetSize(450, 215)
			SF:SetParent(OpenRaidFrameIndex)
			SF:SetPoint("TOPLEFT", OpenRaidFrameIndex, "TOPLEFT", 0, -35)
			SF:SetScrollChild(SC)
			SF:Show()
		end
	end
	]]
	
	--Function to override database when a newer version is found, but securely saves the previous data and implements that again
	local function OpenRaid_defaults()
		local CV = defaults.Options.Version
		local Options_temp = defaults;
		if not OR_db or not OR_db.Options.Version then
			print(L["Generating options"])
			OR_db = {};
			OR_db = defaults;
		elseif OR_db.Options.Version < CV then
			for k,v in pairs(OR_db) do
				Options_temp[k] = Options_temp[k] or {};
				if type(v) == "table" and k ~= "Raids" and k~= "Rate" then --These handle i,v tables
					for k2,v2 in pairs(OR_db[k]) do
						Options_temp[k][k2] = Options_temp[k][k2] or {};
						if type(v2) == "table" then
							for k3,v3 in pairs(OR_db[k][k2]) do
								Options_temp[k][k2][k3] = v3;
							end
						else
							Options_temp[k][k2] = v2;
						end
					end
				else
					Options_temp[k] = v;
				end
			end
			Options_temp.Options.Version = CV;
			OR_db = {};
			OR_db = Options_temp;
		end
		if not OR_db.Raids[Pname] then
			OR_db.Raids[Pname] = {};
		end
	end

	--Clear friend information when not been your friend for OR_db.Options["Clean up time"] (default 7) days while in database
	local function ClearDatabase()
		for k,v in pairs(OR_db.Notes) do
			if type(k) == "number" then
				OR_db.Notes[k] = nil
			elseif type(v) == "string" then
				local year, month, day = strsplit("^", v)
				local today = date("*t")
				if (tonumber(year) ~=  today.year or tonumber(month) ~= today.month) and today.day > OR_db.Options["Clean up time"] then
					OR_db.Notes[k] = nil;
				elseif today.day - tonumber(day) > OR_db.Options["Clean up time"] then
					OR_db.Notes[k] = nil;
				end
			else
				OR_db.Notes[k] = nil;
			end
		end
		if OR_db.Options["Clear raids after X days"] then
			for k,v in pairs(OR_db.Raids[Pname]) do
				local year, month, day = v[4], v[3], v[2];
				local today = date("*t")
				if (year and month and day) then
					if (tonumber(year) ~=  today.year or tonumber(month) ~= today.month) and today.day > OR_db.Options["Clean up time"] then
						OR_db.Raids[Pname][k] = nil;
						OR_db.Rate[k] = nil;
					elseif today.day - tonumber(day) > OR_db.Options["Clean up time"] then
						OR_db.Raids[Pname][k] = nil;
						OR_db.Rate[k] = nil;
					end
				end
			end
		end
	end
	
	--We filter our own send message. Anti-spam =]
	local function FilterWhisper(self, event, msg, author, ...)
		return strmatch(msg, L["Invite for event"]) or strmatch(msg, L["Invite for event wrong character"])
	end
	
	local function UIErrorsFrame_OnEventFiltered(self, event, ...)
		local arg1 = select(1, ...)
		if arg1 == L["Friend request has been sent"] or arg1 == L["This person is already your friend"] then
			self:Clear();
		end
	end
	
	Init = function()
		OpenRaid_defaults();
		OpenRaid_defaults = nil;
		ClearDatabase();
		ClearDatabase = nil;
		CreateOptions();
		CreateOptions = nil;
		
		--UIDropDownMenu_Initialize(GroupLootDropDown, BonusRollDropdown)
		AddFriendFrameOpenRaidButtonCreate();
		AddFriendFrameOpenRaidButtonCreate = nil;
		FriendsFramePendingOpenRaidButtons();
		FriendsFramePendingOpenRaidButtons = nil;
		--NewsInit();
		--NewsInit = nil;
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", FilterWhisper)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", FilterWhisper)
		UIErrorsFrame:HookScript("OnEvent", UIErrorsFrame_OnEventFiltered)
		tinsert(UISpecialFrames, OpenRaidFrame:GetName()) --We make OpenRaidFrame closeable by escape key
		collectgarbage();
		print("OpenRaid loaded. Typ /openraid info for help.")
	end
end

--[[
	----------------------------------------------------------------------
	--						Core global functions						--
	----------------------------------------------------------------------
]]

do
	OpenRaid.LastRaidSize = 1;
	
	--Updating OpenRaidGroupFrameFontStrings. Target = "party" or "raid", i = Number of group member
	local function GroupFontString(self, n, Target, i)
		local cb
		if not self["OpenRaidGroupFrameCheckbox" .. i] then
			self["OpenRaidGroupFrameCheckbox" .. i] = CreateFrame("CheckButton", "OpenRaidGroupFrameCheckbox" .. i, _G[self:GetName() .. "RateGroupContainer"], "InterfaceOptionsCheckButtonTemplate");
			cb = self["OpenRaidGroupFrameCheckbox" .. i]
			cb:SetSize(20,20);
			cb:SetPoint("TOPLEFT", i==1 and _G[self:GetName() .. "RateGroupContainer"] or "OpenRaidGroupFrameCheckbox" .. (i - 1),
			i==1 and "TOPLEFT" or "BOTTOMLEFT",i==1 and 5 or 0,i==1 and -10 or 1);
		end
		cb = self["OpenRaidGroupFrameCheckbox" .. i]
		cb:Show();
		if not self["OpenRaidGroupFrameFontString" .. i] then
			self["OpenRaidGroupFrameFontString" .. i] = OpenRaidCreateFontString("OpenRaidGroupFrameFontString" .. i, _G[self:GetName() .. "RateGroupContainer"], "TOPLEFT",
			i==1 and _G[self:GetName() .. "RateGroupContainer"] or _G[self["OpenRaidGroupFrameFontString" .. (i - 1)]:GetName()],
			i==1 and "TOPLEFT" or "BOTTOMLEFT", i==1 and 25 or 0, i==1 and -12 or -5, DEFAULT, nil)
		end
		local S = self["OpenRaidGroupFrameFontString" .. i]
		
		S:SetText(GetFullUnitName(Target .. n));
		S:Show();
		
		OpenRaidFrameRateGroupContainer:SetHeight(20 * i + 7);
	end
	
	local function OpenRaidAddonMessages(target)
		SendAddonMessage(Prefix, OR_db.Options.Version, target);
	end
	
	function GroupUpdate()
		if InCombatLockdown() then return end
		for i=1, OpenRaid.LastRaidSize do
			if OpenRaidFrame["OpenRaidGroupFrameCheckbox" .. i] then
				OpenRaidFrame["OpenRaidGroupFrameCheckbox" .. i]:Hide();
			end
			if OpenRaidFrame["OpenRaidGroupFrameFontString" .. i] then
				OpenRaidFrame["OpenRaidGroupFrameFontString" .. i]:Hide();
			end
		end
		if IsInRaid(LE_PARTY_CATEGORY_HOME) and (select(2, GetInstanceInfo()) == "none" or select(2, GetInstanceInfo()) == "raid") then --Apparently IsInRaid() returns true in arenas
			OpenRaidAddonMessages("RAID")
			local filter = {};
			for i=1, GetNumGroupMembers() do
				if GetFullUnitName("raid" .. i) == Pname or UnitName("raid" .. i) == "UNKNOWN" then
					tinsert(filter, i)
				else
					GroupFontString(OpenRaidFrame, i , "raid", i - getn(filter));
				end
			end
			if GetNumGroupMembers() > OpenRaid.LastRaidSize then
				OpenRaid.LastRaidSize = GetNumGroupMembers()
			end
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
			OpenRaidAddonMessages("PARTY")
			local filter = {};
			for i=1, GetNumSubgroupMembers() do
				if GetFullUnitName("party" .. i) == Pname or UnitName("party" .. i) == "UNKNOWN" then
					tinsert(filter, i)
				else
					GroupFontString(OpenRaidFrame, i, "party", i - getn(filter));
				end
			end
			if GetNumSubgroupMembers() > OpenRaid.LastRaidSize then
				OpenRaid.LastRaidSize = GetNumSubgroupMembers()
			end
			if OpenRaid.HasStartedInvites then
				OpenRaid.HasStartedInvites = false;
				ConvertToRaid();
			end
		end
	end
	
	--Event functions and initializing AddOn
	function OpenRaidFrameOnEvent(self, event, ...)
		--Loading Database and configuring settings
		if event == "ADDON_LOADED" then
			if select(1, ...) == "OpenRaid" then
				Init();
				OpenRaidFrame:UnregisterEvent("ADDON_LOADED");
			end
		elseif event == "PLAYER_REGEN_ENABLED" then
			if InCombatLockdown() then return end
			GroupUpdate()
			OpenRaidFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		--Updating OpenRaidGroupFrame
		elseif event == "GROUP_ROSTER_UPDATE" then
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			else
				GroupUpdate()
			end
		--Whisper correct event number for party invite
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local message = select(1, ...);
			local ID = select(13, ...);
			if (self.CHAT_MSG_BN_WHISPER) then
				if message and message == Whisperword then
					if not IsInRaid() and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 3  then --When someone wants an invite and party is full, converts to raid
						ConvertToRaid();
					end
					local toonID = select(16, BNGetToonInfo(ID));
					BNInviteFriend(toonID);
				end
			end
			if strfind(message, "vent") or strfind(message, "or") then
				BNSendWhisper(ID, "OpenRaid ventrilo details");
				BNSendWhisper(ID, "Hostname: openraid.typefrag.com");
				BNSendWhisper(ID, "Port: 3784");
				BNSendWhisper(ID, "Password: raidopen");
			end
		elseif event == "CHAT_MSG_SYSTEM" then
			local arg1 = select(1, ...);
			if strmatch(arg1, L["Roll match"]) then
				if not Rolls[strmatch(arg1, "%a+")] then
					Rolls[strmatch(arg1, "%a+")] = strmatch(arg1, "%d+");
					local Done = true;
					if not Rolls[Pname] then
						Done = false;
					end
					if IsInRaid() then
						for i = 1, GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) do
							if GetFullUnitName("raid" .. i) then
								if not Rolls[GetFullUnitName("raid" .. i)] then
									Done = false;
									break;
								end
							end
						end
					else
						for i = 1, GetNumSubgroupMembers(LE_PARTY_CATEGORY_HOME) do
							if GetFullUnitName("party" .. i) then
								if not Rolls[GetFullUnitName("party" .. i)] then
									Done = false;
									break;
								end
							end
						end
					end
					if Done then
						AssignLoot(LootFrame.selectedSlot)
						OpenRaidBonusTimer.TimeSinceLastUpdate = 0;
						OpenRaidBonusTimer:SetScript("OnUpdate", function()end)
					end
				end
			end
		elseif event == "PLAYER_ENTERING_WORLD" then
			local ok = RegisterAddonMessagePrefix(Prefix);
			if not ok then
				print("Prefix already used. Please notify the addon developer with a full list of all your addons.");
			end
			if IsInGuild() then
				OpenRaidAddonMessages("GUILD");
			end
		elseif event == "CHAT_MSG_ADDON" then
			if arg1 == Prefix then
				if arg2 > OR_db.Options.Version and not UpdateAvailble then
					print("OpenRaid addOn is out of date. Please visit OpenRaid.org/addon and download the newest version.");
					if IsInGuild() then
						OpenRaidAddonMessages("GUILD");
					end
					UpdateAvailble = true;
				end
			end
		end
	end
	
	-- Make OpenRaid slash commands (/OpenRaid) to open the main window.
	SLASH_OpenRaid1, SLASH_OpenRaid2, SLASH_OpenRaid3 = '/oraid', '/OpenRaid', '/or';
	function SlashCmdList.OpenRaid(msg, editbox)
		local msg = strlower(msg); --If people use capitalized characters
		if not msg or msg == "" then
			OpenRaidTabs(OpenRaidFrame, OR_db.Options.Defaultpage);
		elseif msg == "create" then
			OpenRaidTabs(OpenRaidFrame, "CreateRaid");
		elseif msg == "invite" or msg == "inv" or msg == "qr" or msg == "quickraid" then
			OpenRaidTabs(OpenRaidFrame, "Invite");
		elseif msg == "add" then
			OpenRaidTabs(OpenRaidFrame, "Add");
		elseif msg == "rate" then
			OpenRaidTabs(OpenRaidFrame, "Rate");
		elseif msg == "tut" or msg == "tutorial" then
			OpenRaidTutorial();
		elseif msg == "info" then
			print(L["OpenRaid Info"]);
		end
	end

	--@@USAGE
	--OpenRaidTabs( <ParentFrame> [, <Childframe> [, nr of tab][,Forced]]) Childframe, nr of tab and Forced are OPTIONAL
	--OpenRaidTabs(OpenRaidFrame) Opens OpenRaidFrame
	--OpenRaidTabs(OpenRaidFrame, "CreateRaid") Opens OpenRaidFrameCreateRaid
	--OpenRaidTabs(OpenRaidFrame, "CreateRaid", 1) Opens OpenRaidFrameCreateRaidTab1
	function OpenRaidTabs(self, Child, Tab, Forced)
		if InCombatLockdown() then
			print("You are in combat, the window can't be opened.")
			return
		end
		OpenRaidDisableWordInvite() --We disable it to be sure the user doesn't accidently auto-invite anyone
		if IsInTutorial and not Forced then
			if self:IsShown() then --Are we in a tutorial and do we call it of the tutorial function or not?
				return
			else	--Apparently the frame was hidden by external measures.
				IsInTutorial = false;
				OpenRaidFrameTutorial:Hide();
				Arrow:Hide();
				RemoveFakeOpenRaidEvent();
			end
		end
		if OR_db.Options.Tutorial then
			OR_db.Options.Tutorial = false;
			--If the player doesn't want the tutorial it opens the normal frame again
			--local SaveChild = Child;
			--local SaveTab = Tab;
			OpenRaidConfirmHandle(L["First time"], function() OpenRaidTutorial() end, function() OpenRaidTabs(OpenRaidFrame, Child, Tab) end);
			return;
		end
		local F = self:GetName();
		if Child ~= "None" and not self.Close then
			if OpenRaidRemoveFriendsFrame then
				OpenRaidRemoveFriendsFrame:Hide();
			end
			local NumTab = self.NumTab;
			if self.CurrentTab then --If tab is displayed
				if Child == "Next" and NumTab then --If we want to go to the next tab
					_G[F .. self.CurrentTab .. "Tab" .. NumTab]:Hide(); --We hide the previous tab
				else
					_G[F .. self.CurrentTab]:Hide(); --We hide the previous childtab
				end
			end
			if Child == "Next" then --If we want to go to the next tab
				NumTab = (NumTab or 1) + 1;
				_G[F .. self.CurrentTab .. "Tab" .. NumTab]:Show();
				if NumTab == self[self.CurrentTab .. "Max"] then --If this is the last tab
					self.Close = true;
					_G[F .. "Next"]:SetText("Close");
				end
			else
				self.NumTab = nil;
				_G[F]:Show(); --Show the parentframe
				_G[F .. "Next"]:Hide();
				if Child then
					_G[F .. Child]:Show(); --Show the childframe
					self.CurrentTab = Child;
					if Tab then
						_G[F .. Child .. "Tab" .. Tab]:Show(); --Show the childframe tab
						self.NumTab = Tab;
						_G[F .. "Next"]:Show();
					end
				end
			end
		else --None = close window and reset Tabs
			if self.CurrentTab then
				if self.NumTab then
					_G[F .. self.CurrentTab .. "Tab" .. self.NumTab]:Hide();
				end
				_G[F .. self.CurrentTab]:Hide();
			end
			--Reset variables
			self.CurrentTab = nil;
			self.NumTab = nil;
			self.Close = false;
			_G[F .. "Next"]:SetText("Next");
			_G[F]:Hide();
		end
	end

end

--[[ OpenRaid string format:
	--    <CharName>;<RaidName>,<Month>,<Day>,<Year>,<Hour>,<Minute>;...repeat raids
	--
	-- Example of the format:
	--		
			Jeremybell-Realm*19003,Testraid,19,1,2013,18,00;Unknown#2855-Pinque-Darksorrow,Unknown#2472-Pinque-Darksorrowz
			Jeremybell-Realm*19001,Testraid2,19,1,2013,18,00;Unknown#2311-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
			Jeremybell-Realm*19002,Testraid3,19,1,2013,18,00;Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
			Jeremybell-Grim Batol*19002,Testraid3,19,1,2013,18,00;Unknown#2102-Pinque-Darksorrow,Unknown#2839-Pinque-Darksorrowz
			Jeremybell-Grim Batol*19002,Testraid3;Unknown#2103-Pinque-Darksorrow,Unknown#2837-Pinque-Darksorrowz
			
			Jeremybell-Grim Batol*107994,MSV HC2,19,6,2013,19,00;Unknown#2699-Taxén-Shadowsong,Unknown#2344-Krawuzî-Ulduar,Unknown#2199-Jsinghelfjr-Magtheridon,Unknown#2685-Comfort-Sylvanas,Unknown#2880-Holybobman-Sylvanas,Unknown#2328-Infamous-Kul Tiras,Unknown#2230-Фугу-Gordunni,Unknown#2297-Joqee-Outland,Unknown#2500-Spreewell-Ravencres
	
	plain enters to have the above code in the middle of my screen <3
	
	
	
	
end]]