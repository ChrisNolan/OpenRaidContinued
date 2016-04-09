--Replacement of getn()
function getTableLength(T)
	if type(T) ~= "table" then return 0 end
	local c = 0
	for _ in pairs(T) do c = c + 1 end
	return c
end

--Get the current text of the dropdownmenu
function OpenRaidGetDropdowntext(DD)
	return strsplit(",", DD:GetText());
end

function isBattleTag(battleTag)
	return strmatch(battleTag, "^.+%#%d%d%d%d$") or strmatch(battleTag, "^.+#%d%d%d%d%d$")
end

StaticPopupDialogs["OpenRaidConfirm"] = {
	text = "This confirmation message is custom.",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

local ErrorMessages = {};
StaticPopupDialogs["OpenRaidError"] = {
	text = "This error message is custom.",
	button1 = OKAY,
	OnAccept = function()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	hasEditBox = false,
	sound = "AutoQuestComplete",
	showAlert = true,
	OnHide = function()
		tremove(ErrorMessages, 1)
		if ErrorMessages[1] then
			OpenRaidReportError(ErrorMessages[1])
		end
	end,
}

--Custom OpenRaid error message
function OpenRaidReportError(t)
	StaticPopupDialogs["OpenRaidError"].text = t[1] or "";
	StaticPopupDialogs["OpenRaidError"].OnAccept = t[2] or nil;
	StaticPopupDialogs["OpenRaidError"].hasEditBox = t[3] or nil;
	StaticPopupDialogs["OpenRaidError"].OnShow = t[4] or nil;
	StaticPopupDialogs["OpenRaidError"].EditBoxOnTextChanged = t[5] or nil;
	StaticPopup_Show("OpenRaidError");
end

function OpenRaidAddMessageToErrorQueue(v)
	tinsert(ErrorMessages, v)
	if getTableLength(ErrorMessages) == 1 then
		OpenRaidReportError(ErrorMessages[1])
	end
end

--Custom OpenRaid confirm message
function OpenRaidConfirmHandle(text, Accept, Cancel)
	StaticPopupDialogs["OpenRaidConfirm"].text = text;
	StaticPopupDialogs["OpenRaidConfirm"].OnAccept = Accept;
	StaticPopupDialogs["OpenRaidConfirm"].OnCancel = Cancel or nil;
	StaticPopup_Show("OpenRaidConfirm");
end

--Get the current output channel
function GetOutputChannel()
	return IsInRaid(LE_PARTY_CATEGORY_HOME) and "RAID" or IsInGroup(LE_PARTY_CATEGORY_HOME) and "PARTY"
end

local OwnRealm = GetRealmName();
function GetFullUnitName(Unit)
	local name, realm = UnitName(Unit);
	return name .. "-" .. (realm ~= "" and realm or OwnRealm);
end
OpenRaid.Pname = GetFullUnitName("player");

function OpenRaidCreateFontString(name, parent, anchor1, anchor, anchor2, xoffset, yoffset, text, JustifyH)
	local Fontstring = OpenRaidFrame:CreateFontString(name, "Overlay", nil);
	Fontstring:SetParent(parent);
	Fontstring:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE, MONOCHROME");
	Fontstring:SetPoint(anchor1, anchor, anchor2, (xoffset or 0), (yoffset or 0));
	Fontstring:SetText(text);
	if JustifyH then
		Fontstring:SetJustifyH(JustifyH);
	end
	Fontstring:Show();
	return Fontstring;
end

--Create a fake backdrop to get rid of green boxes
function OpenRaidFakebackdrop(self)
	self:SetBackdrop( {
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	});
	self:SetBackdropColor(0,0,0,0);
	self:SetBackdropBorderColor(0,0,0,0);
end

--Set a tooltip for an element
function OpenRaidGameTooltip(self, text)
	self:SetScript("OnEnter", function()
		GameTooltip:ClearLines();
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip:AddLine(text);
		GameTooltip:Show();
	end)
	self:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
end

--workaround for strfind() and "-" not working properly
function secureStrFind(text, pattern, begin, last)
	text = gsub(text or "", "%-", "%^")
	pattern = gsub(pattern, "%-", "%^")
	return strfind(text, pattern, begin, last)
end

function IsAlreadyBattleTagFriend(btag)
	for n=1, BNGetNumFriends() do
		local _, _, battleTag = BNGetFriendInfo(n);
		if battleTag == btag then
			return true;
		end
	end
	return false;
end