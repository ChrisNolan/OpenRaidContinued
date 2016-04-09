local L = OpenRaid.L;
local Pname = OpenRaid.Pname;
local getn = getTableLength;

--Reconfiguring all boxes for rating
local function CreateRateElements(self, v)
	OpenRaidFrameRate.Boxes = OpenRaidFrameRate.Boxes + 1
	local B = OpenRaidFrameRate.Boxes
	local S
	if not self["RateFrameFontString" .. B] then
		self["RateFrameFontString" .. B] = OpenRaidCreateFontString("OpenRaidRateFrameFontString" .. B, _G[self:GetName() .. "RateContainer"], "TOPLEFT",
		B==1 and _G[self:GetName() .. "RateContainer"] or self["RateFrameFontString" .. (B - 1)],
		B==1 and "TOPLEFT" or "BOTTOMLEFT", B==1 and 15 or 0, B==1 and 0 or -10, DEFAULT, nil)
		S = self["RateFrameFontString" .. B];
	else
		S = self["RateFrameFontString" .. B];
	end
	S.text = v;
	S:SetTextColor(0, 0.4, 1.0, 1);
	if strlen(v) > 20 then
		v = strsub(v, 0, 20)
	end
	S:SetText(v);
	S:Show();
	local eb
	if not self["RateFrameEditbox" .. B] then
		self["RateFrameEditbox" .. B] = CreateFrame("EditBox", "RateFrameEditbox" .. B, _G[self:GetName() .. "RateContainer"], "OpenRaidEditboxTemplate");
		eb = self["RateFrameEditbox" .. B]
		eb:SetAutoFocus(false);
		eb:SetWidth(135);
		eb:SetHeight(20);
		if B == 1 then
			eb:SetPoint("TOPLEFT", _G[self:GetName() .. "RateContainer"], "TOPLEFT", 300, 0);
		else
			eb:SetPoint("TOPLEFT", _G["RateFrameEditbox" .. (B - 1)], "TOPLEFT", 0, -24);
		end
	else
		eb = self["RateFrameEditbox" .. B];
	end
	eb:SetText("");
	eb:Show();
	local T = OpenRaidGetDropdowntext(OpenRaidFrameRateRaid)
	for i=1, 5 do
		local cb
		if not self["RateFrameCheckbox" .. B .. i] then
			self["RateFrameCheckbox" .. B .. i] = CreateFrame("CheckButton", "RateFrameCheckbox" .. B .. i, _G[self:GetName() .. "RateContainer"]);
			cb = self["RateFrameCheckbox" .. B .. i]
			cb.NR = B
			cb.NR2 = i
			cb:SetSize(16,16)
			cb:SetNormalTexture("Interface\\AddOns\\OpenRaid\\Images\\Checkbox")
			cb:SetHighlightTexture("Interface\\AddOns\\OpenRaid\\Images\\CheckboxBorder", "ADD")
			cb:SetCheckedTexture("Interface\\AddOns\\OpenRaid\\Images\\CheckboxChecked")
			if i == 1 then
				if B == 1 then
					cb:SetPoint("TOPLEFT", _G[self:GetName() .. "RateContainer"], "TOPLEFT", 200, 0);
				else
					cb:SetPoint("TOPLEFT", _G["RateFrameCheckbox" .. (B - 1) .. i], "TOPLEFT", 0, -24);
				end
			else
				cb:SetPoint("RIGHT", _G["RateFrameCheckbox" .. B .. (i - 1)], "RIGHT", 20, 0);
			end
			cb:SetScript("OnClick", function(self, button, down)
				local N = OpenRaidFrame["RateFrameFontString" .. self.NR]:GetText()
				local check = self:GetChecked()
				for i=1,5 do
					_G["RateFrameCheckbox" .. self.NR .. i]:SetChecked(false);
				end
				if not OR_db.Rate[T][N] then
					OR_db.Rate[T][N] = {};
				end
				if check then
					OR_db.Rate[T][N][1] = self.NR2;
					for i=1, self.NR2 do
						_G["RateFrameCheckbox" .. self.NR .. i]:SetChecked(true);
					end
				else
					OR_db.Rate[T][N][1] = 0;
				end
			end)
		else
			cb = self["RateFrameCheckbox" .. B .. i];
		end
		local N = OpenRaidFrame["RateFrameFontString" .. cb.NR]:GetText()
		if OR_db.Rate[T][N] then
			cb:SetChecked(OR_db.Rate[T][N][1] >= cb.NR2);
		else
			cb:SetChecked(false)
		end
		cb:Show()
	end
end

--Updates text and color of all strings of the OpenRaidFrameRateFrame
function UpdateRateFontStrings(RaidID)
	OpenRaidRateBoxes(OpenRaidFrame);
	local T = RaidID or OpenRaidGetDropdowntext(OpenRaidFrameRateRaid);
	if T == "Raid" then
		return
	end
	local People = { strsplit(",", OR_db.Raids[Pname][T][7]) };
	local Attended = OR_db.Raids[Pname][T][8] or "";
	if not People or People[1] == "Own event" then
		OpenRaidAddMessageToErrorQueue( { L["Event no members rate"], } );
		return
	end
	for i=1, getn(People) do
		if People[i] and People[i] ~= "" then
			local _, Name, Realm = strsplit("-", People[i])
			CreateRateElements(OpenRaidFrame, Name .."-"..Realm);
			if secureStrFind(Attended, Name .."-"..Realm) then
				OpenRaidFrame["RateFrameFontString" .. OpenRaidFrameRate.Boxes]:SetTextColor(0, 1, 0, 1);
			else
				OpenRaidFrame["RateFrameFontString" .. OpenRaidFrameRate.Boxes]:SetTextColor(1, 0, 0, 1);
			end
		end
	end
	Attended = { strsplit(",", Attended) };
	for i=1, getn(Attended) do
		if not secureStrFind(OR_db.Raids[Pname][T][7], Attended[i]) then
			CreateRateElements(OpenRaidFrame, Attended[i]);
			OpenRaidFrame["RateFrameFontString" .. OpenRaidFrameRate.Boxes]:SetTextColor(0, 0.4, 1.0, 1);
		end
	end
	OpenRaidFrameRateContainer:SetHeight(OpenRaidFrameRate.Boxes * 24)
end


--Creating OpenRaidString to export to site/client
local function RatesToString()
	StaticPopupDialogs["OpenRaidConfirm"].OnHide = nil;
	local G = OpenRaidGetDropdowntext(OpenRaidFrameRateRaid)
	if G == "Raid" then
		OpenRaidAddMessageToErrorQueue( { L["Select raid"], } );
		return
	end
	OpenRaidFrameRateRaid:SetText("Raid")
	local String = (OR_db.String[Pname] or (Pname)) --Does it still exist or is it a fresh one?
	for i=1, OpenRaidFrameRate.Boxes do
		local S = OpenRaidFrame["RateFrameFontString" .. i].text;
		OR_db.Rate[G][S] = OR_db.Rate[G][S] or {};
		local Text = _G["RateFrameEditbox" .. i]:GetText();
		if Text and Text ~= "" then
			OR_db.Rate[G][S][2] = Text;
		else
			OR_db.Rate[G][S][2] = "None";
		end
	end
	local T = OR_db.Raids[Pname][G];
	if not strfind(String, G) then --Is this event rated already?
		String = String .. "*" .. G .. "-".. T[2] .. "-" .. T[3] .. "-" .. T[4] .. "-" .. T[5] .. "-" .. T[6];
		for k,v in pairs(OR_db.Rate[G]) do
			if k ~= "Name" then
				String = String  .. ";" .. k .. "," .. v[1] or 3 .. "," .. v[2] --Adds: ";NamePerson,1-5Rating,(Commment or None)" to string
			end
		end
		OR_db.String[Pname] = String;
		OpenRaidAddMessageToErrorQueue( { L["Visit OpenRaid.org/addon"], function(self)
		end, true, function(self)
			self.editBox:SetText(OR_db.String[Pname])
			self.editBox:HighlightText();
		end, } )
		for k,v in pairs(OR_db.Rate) do
			local N = OR_db.Rate[k].Name;
			OR_db.Rate[k] = {};
			OR_db.Rate[k].Name = N;
		end
		OpenRaidTabs(OpenRaidFrame, "None");
	else
		OpenRaidConfirmHandle(L["Already rated"], function()
			local P = { strfind(String, G) }
			local E = strfind(String, "*", P[1] + 1) or (strlen(String) + 1)
			local ReplaceString = G .. "-".. T[2] .. "-" .. T[3] .. "-" .. T[4] .. "-" .. T[5] .. "-" .. T[6];
			for k,v in pairs(OR_db.Rate[G]) do
				if k ~= "Name" then
					ReplaceString = ReplaceString  .. ";" .. k .. "," .. v[1] .. "," .. v[2] --Adds: ";NamePerson,1-5Rating,(Commment or None)" to string
				end
			end
			local s = gsub(OR_db.String[Pname], "%-", "%^") --workaround for gsub() and "-" not working properly
			s = gsub(s, string.sub(s, P[1], E), ReplaceString)
			OR_db.String[Pname] = gsub(s, "%^", "%-")
			OpenRaidAddMessageToErrorQueue( { L["Visit OpenRaid.org/addon"], function(self)
			end, true, function(self)
				self.editBox:SetText(OR_db.String[Pname])
				self.editBox:HighlightText();
			end, } )
		end)
	end
end

function OpenRaidGetRates()
	local T = OpenRaidGetDropdowntext(OpenRaidFrameRateRaid);
	for i=1, OpenRaidFrameRate.Boxes do
		if not _G["RateFrameCheckbox" .. i .. "1"]:GetChecked() then
			StaticPopup_Hide("OpenRaidConfirm");
			OpenRaidConfirmHandle(L["Not all rated"], function()
				local T = OpenRaidGetDropdowntext(OpenRaidFrameRateRaid);
				for i=1, OpenRaidFrameRate.Boxes do
					if not _G["RateFrameCheckbox" .. i .. "1"]:GetChecked() then
						if not OR_db.Rate[T][OpenRaidFrame["RateFrameFontString" .. i].text] then
							OR_db.Rate[T][OpenRaidFrame["RateFrameFontString" .. i].text] = {};
						end
						OR_db.Rate[T][OpenRaidFrame["RateFrameFontString" .. i].text][1] = 3
					end
				end
				StaticPopupDialogs["OpenRaidConfirm"].OnHide = RatesToString;
			end, function() end);
			return;
		end
	end
	RatesToString();
end

--Removing all boxes from previous rating
function OpenRaidRateBoxes(self)
	for i=1, OpenRaidFrameRate.Boxes do
		if self["RateFrameFontString" .. i] then
			self["RateFrameFontString" .. i]:SetTextColor(0, 0.4, 1.0, 1);
			self["RateFrameFontString" .. i]:Hide();
			self["RateFrameEditbox" .. i]:Hide();
			for n=1, 5 do
				self["RateFrameCheckbox" .. i .. n]:Hide();
			end
		end
	end
	OpenRaidFrameRate.Boxes = 0
end

function UpdateRaidLog()
	local G = OpenRaidGetDropdowntext(OpenRaidFrameRateRaid)
	if G ~= "Raid" then
		local backup = OR_db.Raids[Pname][G][8];
		OR_db.Raids[Pname][G][8] = "";
		for n=1, OpenRaid.LastRaidSize do
			local b = _G["OpenRaidGroupFrameCheckbox" .. n];
			if b and b:IsShown() and b:GetChecked() then
				local Player = OpenRaidFrame["OpenRaidGroupFrameFontString" .. n]:GetText();
				if not secureStrFind(pugs, Player) then
					OR_db.Raids[Pname][G][8] = OR_db.Raids[Pname][G][8] .. "," .. Player;
				end
			end
		end
		OR_db.Raids[Pname][G][8] = strsub(OR_db.Raids[Pname][G][8], -strlen(OR_db.Raids[Pname][G][8]) + 1)
		if OR_db.Raids[Pname][G][8] == "" then
			OpenRaidConfirmHandle( L["Remove attendees"], nil, function()
				OR_db.Raids[Pname][G][8] = backup;
			end);
		end
	else
		OpenRaidAddMessageToErrorQueue( { L["Select raid"], } );
	end
	UpdateRateFontStrings();
end