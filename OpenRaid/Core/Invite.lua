local L = OpenRaid.L;
local Pname = OpenRaid.Pname;

local BNGetToonInfo = BNGetToonInfo;
local getn = getTableLength;

local Timer = CreateFrame("Frame");
Timer.TimeSinceLastUpdate = 0;

local NumInvited = 0;
local NumInvitedFailed = {};
local NumInvitedResponded = {};

local function getAmount(num)
	return (num/(NumInvited + getn(NumInvitedFailed) + getn(NumInvitedResponded)) * 200)
end

local function UpdateProgressBar()
	OpenRaidFrameInviteProgressBarFailed:SetWidth(getAmount(getn(NumInvitedFailed)));
	OpenRaidFrameInviteProgressBarResponded:SetWidth(getAmount(getn(NumInvitedResponded)));
	OpenRaidFrameInviteProgressBarInvited:SetWidth(getAmount(NumInvited));
	OpenRaidInviteListUpdate();
end

local Pending
local GetSlackers = CreateFrame("Frame"); -- (A)
GetSlackers:SetScript("OnEvent", function(self, event, ...)
	local ID = ...;
	local _, _, battleTag, _, _, toonID = BNGetFriendInfoByID(ID)
	if not battleTag then return end
	local _, toonName, _, realmName = BNGetToonInfo(toonID)
	for k,v in pairs(Pending) do
		local BNInfo = { strsplit("-", k) }
		if strlower(BNInfo[1]) == strlower(battleTag) then
			NumInvitedFailed[battleTag] = nil;
			OpenRaidFrameInviteProgressBarFailed:SetWidth(getAmount(getn(NumInvitedFailed)));
			if toonName == BNInfo[2] and realmName == BNInfo[3] then
				BNInviteFriend(toonID)
				BNSendWhisper(ID, L["Invite for event"])
				Timer.TimeSinceLastUpdate = 0; --We have invited someone again and we should wait till he responds
				Pending[k] = nil;
			else
				BNSendWhisper(ID, L["Invite for event wrong character"])
				NumInvitedResponded[battleTag] = toonName .. "-" .. realmName .. " (online on wrong character)";
			end
			UpdateProgressBar();
			return
		end
	end
end)

local function subMatcher(var)
	return "^" .. gsub(var, "%%s", ".%+") .. "$"
end

local function FilterInviteSpam(self, event, msg, author, ...)

	local function match(var)
		return strmatch(msg, subMatcher(var))
	end

	if match(ERR_INVITE_PLAYER_S) then									--"You have invited %s to join your group."
		return OR_db.Options["Filter have invited"]
	elseif match(ERR_ALREADY_IN_GROUP_S) then							--"%s is already in a group."
		NumInvitedResponded[strmatch(msg, "%a+")] = " (already in a group)";
		UpdateProgressBar();
		return OR_db.Options["Filter already in group"]
	elseif match(ERR_DECLINE_GROUP_S) then								--"%s declines your group invitation."
		NumInvitedResponded[strmatch(msg, "%a+")] = " (declined invitation)";
		UpdateProgressBar();
		return false
	elseif match(ERR_JOINED_GROUP_S) or									--"%s joins the party."
		match(ERR_RAID_MEMBER_ADDED_S) then								--"%s has joined the raid group."
		NumInvited = NumInvited + 1;
		UpdateProgressBar();
		return OR_db.Options["Filter joined your group"]
	else
		return false
	end
end

local function AfterInvite(self, elapsed)
	Timer.TimeSinceLastUpdate = Timer.TimeSinceLastUpdate + elapsed;
	
	if (Timer.TimeSinceLastUpdate > 60) or (NumInvited + getn(NumInvitedFailed) + getn(NumInvitedResponded) == NumInvitedTotal) then
	
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", FilterInviteSpam);
		for k,v in pairs(Pending) do
			NumInvitedResponded[k] = k .. " (no response)";
		end;
		
		GetSlackers:UnregisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
		
		Timer.TimeSinceLastUpdate = 0;
		Timer:SetScript("OnUpdate", function(self, elapsed)
			Timer.TimeSinceLastUpdate = Timer.TimeSinceLastUpdate + elapsed;
			if (Timer.TimeSinceLastUpdate > 10) then --10 second timeout after everything is done
				OpenRaidFrameInviteProgress:Hide();
				OpenRaidFrameInviteList:Show();
				Timer:SetScript("OnUpdate", function() end)
				OpenRaidFrameInviteDataWrite:Enable();
			end
		end)
		OpenRaidAddMessageToErrorQueue( { L["Friends invited"], } )
	end
end

local NotFoundError = "";
local function AppendBNInfo(person, text)
	NotFoundError = NotFoundError .. " " .. person[2] .. "-" .. person[3] .. text;
end

local function IsCurrentlyIngroup(givenName)
	local BNInfo = { strsplit("-", givenName) }
	local Name = BNInfo[2] .. "-" .. BNInfo[3];
	if IsInRaid(LE_PARTY_CATEGORY_HOME) and (select(2, GetInstanceInfo()) == "none" or select(2, GetInstanceInfo()) == "raid") then --Apparently IsInRaid() returns true in arenas
		for i=1, GetNumGroupMembers() do
			if GetFullUnitName("raid" .. i) == Name then
				return true;
			end
		end
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		for i=1, GetNumSubgroupMembers() do
			if GetFullUnitName("party" .. i) == Name then
				return true;
			end
		end
	end
	return false;
end

local function TryInviteBNFriend(BNFriend)
	local BNInfo = { strsplit("-", BNFriend) }
	if BNInfo[3] == GetRealmName() then	--He is from our own realm
		InviteUnit(BNInfo[2])
		SendChatMessage(L["Invite for event"], "WHISPER", nil, BNInfo[2]);
	elseif BNInfo[1] ~= "" then
		for n=1, BNGetNumFriends() do
			local ID, _, battleTag, _, _, toonID, _, isOnline = BNGetFriendInfo(n)
			if strlower(BNInfo[1]) == strlower(battleTag or "") then
				Pending[BNFriend] = nil;
				if isOnline then
					local _, toonName, _, realmName = BNGetToonInfo(toonID)
					if toonName == BNInfo[2] and realmName == BNInfo[3] then
						BNInviteFriend(toonID)
						BNSendWhisper(ID, L["Invite for event"])
					else
						AppendBNInfo(BNInfo, " (online on wrong character)\n")
						BNSendWhisper(ID, L["Invite for event wrong character"])
						NumInvitedResponded[BNInfo[1]] = BNFriend .. " (wrong character)";
					end
				else
					NumInvitedFailed[BNInfo[1]] = BNFriend .. " (not online)";
					AppendBNInfo(BNInfo, " (not online)\n")
				end
			end
		end
		if Pending[BNFriend] then
			NumInvitedFailed[BNInfo[1]] = BNFriend .. " (no BNfriend)";
			AppendBNInfo(BNInfo, " (not a BNfriend)\n")
		end
	end
end

function OpenRaidInvite()
	local G = OpenRaidGetDropdowntext(OpenRaidFrameInviteRaid)
	NotFoundError = L["Not found error"];
	NumInvited = 0;					--Accepted invites and are in your group
	NumInvitedFailed = {};			--Are not online or not a friend
	NumInvitedResponded = {}; 		--Are online, but not on correct character or already in group or didn't accept the invite
	NumInvitedTotal = {};			--Total amount of people trying to invite
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", FilterInviteSpam)
	
	local People;
	if G ~= "Raid" then
		People = { strsplit(",", OR_db.Raids[Pname][G][7]) }
		OpenRaidFrameInviteRaid:SetText("Raid");
	else
		local Text = OpenRaidFrameInviteBorderScrollFrameEditBox:GetText()				--Jeremybell-Realm*19002,Testraid3;Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
		if Text == "" then
			OpenRaidAddMessageToErrorQueue( { L["No raid selected"], } );
			return
		end
		local Data = { strsplit("*", Text) }											--Jeremybell-Realm	19002,Testraid3;Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
		if Data[1] == Pname then
			if Text[2] and Text[2] ~= "" then
				local Signups = { strsplit(";", Data[2]) }								--19002,Testraid3		Unknown#2101-Pinque-Darksorrow,Unknown#2838-Pinque-Darksorrowz
				People = { strsplit(",", People[2]) };									--Unknown#2101-Pinque-Darksorrow		Unknown#2838-Pinque-Darksorrowz
			end
		else
			OpenRaidAddMessageToErrorQueue( { L["Not correct character"], } )
			return
		end
	end
	
	if not People or People[1] == "Own event" then
		OpenRaidAddMessageToErrorQueue( { L["Event no members invites"], } );
		return
	end
	
	if getn(People) > 4 and IsInGroup(LE_PARTY_CATEGORY_HOME) then
		OpenRaidAddMessageToErrorQueue( { L["Convert to raid"], } );
	end
	
	Timer.TimeSinceLastUpdate = 0;
	Timer:SetScript("OnUpdate", AfterInvite);
	
	OpenRaid.HasStartedInvites = (not UnitInRaid("player") and getn(People) + GetNumSubgroupMembers() > 5)
	NumInvitedTotal = getn(People);
	
	Pending = {};
	for i=1, getn(People) do
		if not IsCurrentlyIngroup(People[i]) then
			Pending[People[i]] = true;
			TryInviteBNFriend(People[i])
		end
	end
	
	if NotFoundError ~= L["Not found error"] then
		OpenRaidAddMessageToErrorQueue( { NotFoundError, } )
	end
	
	OpenRaidFrameInviteProgressBarFailed:SetWidth(getAmount(getn(NumInvitedFailed)) + 0.1);
	OpenRaidFrameInviteProgressBarResponded:SetWidth(0.1)
	OpenRaidFrameInviteProgressBarInvited:SetWidth(0.1)
	OpenRaidFrameInviteBorder:Hide();
	OpenRaidFrameInviteProgress:Show();
	OpenRaidFrameInviteDataWrite:Disable();
	UpdateProgressBar()
	if getn(Pending) > 0 then
		GetSlackers:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	end
end

local function getMessage(t)
	local Message = "These could not have been invited:";
	
	for k,v in pairs(t) do
		Message = Message .. "\n" .. v;
	end
	
	return Message;
end

function OpenRaidGetInviteTooltip(name)
	if name == "OpenRaidFrameInviteProgressBarInvited" then
		return "Already " .. NumInvited .. " attendees in raid.";
	elseif name == "OpenRaidFrameInviteProgressBarResponded" then
		return getMessage(NumInvitedResponded or {})
	else
		return getMessage(NumInvitedFailed or {})
	end
end

local function getStatus(Text)
	local first = strfind(Text, "%(");
	local second = strfind(Text, "%)", first);
	return strsub(Text, first + 1, second - 1);
end

local function hideEntries()
	if not OpenRaidFrameRate.ListEntries or OpenRaidFrameRate.ListEntries <= 0 then return end
	for i=1, OpenRaidFrameRate.ListEntries do
		OpenRaidFrame["InviteListStatusFontString" .. i]:Hide();
		OpenRaidFrame["InviteListNameFontString" .. i]:Hide();
		OpenRaidFrame["InviteListBtagFontString" .. i]:Hide();
		_G["OpenRaidInviteListButton" .. i]:Hide();
	end
end

local function createInviteListEntry(self, status, btag, button)
	OpenRaidFrameRate.ListEntries = OpenRaidFrameRate.ListEntries + 1
	if OpenRaidFrameRate.ListEntries > 8 then return end
	local B = OpenRaidFrameRate.ListEntries;
	local S;
	if not self["InviteListStatusFontString" .. B] then
		self["InviteListStatusFontString" .. B] = OpenRaidCreateFontString("OpenRaidInviteListFontString" .. B, _G[self:GetName() .. "InviteListBorder"], "TOPLEFT",
		B==1 and _G[self:GetName() .. "InviteListBorder"] or self["InviteListStatusFontString" .. (B - 1)],
		B==1 and "TOPLEFT" or "BOTTOMLEFT", B==1 and 10 or 0, B==1 and -7 or -10, DEFAULT, nil)
		S = self["InviteListStatusFontString" .. B];
	else
		S = self["InviteListStatusFontString" .. B];
	end
	S:SetText(getStatus(status));
	S:Show();
	
	if not self["InviteListNameFontString" .. B] then
		self["InviteListNameFontString" .. B] = OpenRaidCreateFontString("OpenRaidInviteListFontString" .. B, _G[self:GetName() .. "InviteListBorder"], "TOPLEFT",
		B==1 and _G[self:GetName() .. "InviteListBorder"] or self["InviteListNameFontString" .. (B - 1)],
		B==1 and "TOPLEFT" or "BOTTOMLEFT", B==1 and 130 or 0, B==1 and -7 or -10, DEFAULT, nil)
		S = self["InviteListNameFontString" .. B];
	else
		S = self["InviteListNameFontString" .. B];
	end
	name = strsub(status, 1, strfind(status, "%(") - 1);
	S:SetText(strsub(strsub(name, strfind(name, "-") + 1), 1, 20));
	S:Show();
	
	if not self["InviteListBtagFontString" .. B] then
		self["InviteListBtagFontString" .. B] = OpenRaidCreateFontString("OpenRaidInviteListFontString" .. B, _G[self:GetName() .. "InviteListBorder"], "TOPLEFT",
		B==1 and _G[self:GetName() .. "InviteListBorder"] or self["InviteListBtagFontString" .. (B - 1)],
		B==1 and "TOPLEFT" or "BOTTOMLEFT", B==1 and 275 or 0, B==1 and -7 or -10, DEFAULT, nil)
		S = self["InviteListBtagFontString" .. B];
	else
		S = self["InviteListBtagFontString" .. B];
	end
	S:SetText(btag);
	S:Show();
	
	local Button;
	if not _G["OpenRaidInviteListButton" .. B] then
		Button = CreateFrame("BUTTON", "OpenRaidInviteListButton" .. B, _G[self:GetName() .. "InviteListBorder"], "OpenRaidButtonTemplate");
		if B == 1 then
			Button:SetPoint("TOPRIGHT", _G[self:GetName() .. "InviteListBorder"], "TOPRIGHT", -5, -5);
		else
			Button:SetPoint("TOPRIGHT", "OpenRaidInviteListButton" .. (B - 1), "BOTTOMRIGHT", 0, -4);
		end
	end
	
	if getStatus(status) == "wrong character" then
		Button:SetText("Whisper");
		Button:SetScript("OnClick", function()
			for n=1, BNGetNumFriends() do
				local ID, _, battleTag, _, _, _, _, isOnline = BNGetFriendInfo(n)
				if isOnline and strlower(btag) == strlower(battleTag or "") then
					BNSendWhisper(ID, L["Invite for event wrong character"])
					break;
				end
			end
		end)
		Button:Show();
	elseif button then
		Button:SetText("Invite");
		Button:SetScript("OnClick", function()
			TryInviteBNFriend(name);
		end)
		Button:Show();
	else
		Button:Hide();
	end
end

function OpenRaidInviteListUpdate()
	hideEntries();
	OpenRaidFrameRate.ListEntries = 0;
	for k,v in pairs(NumInvitedFailed) do
		createInviteListEntry(OpenRaidFrame, v, k, false);
	end
	for k,v in pairs(NumInvitedResponded) do
		createInviteListEntry(OpenRaidFrame, v, k, true);
	end
end