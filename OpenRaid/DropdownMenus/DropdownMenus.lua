local Pname = OpenRaid.Pname;
local L = OpenRaid.L;

local function removeRaid(self)
	self:GetParent():Hide();
	if self:GetText() == L["No raids in database"] then
		return
	end
	OpenRaidConfirmHandle(L["Remove raid confirm"], function()
		OR_db.Raids[Pname][strsplit(",", self:GetText())] = nil;
	end);
end

local function switchRaidRate()
	OR_db.Group = {}
	for n=1, OpenRaid.LastRaidSize do
		if _G["OpenRaidGroupFrameCheckbox" .. n] then
			_G["OpenRaidGroupFrameCheckbox" .. n]:SetChecked(false);
		end
	end
	local n = OpenRaidGetDropdowntext(OpenRaidFrameRateRaid);
	OR_db.Rate[n] = OR_db.Rate[n] or {};
	UpdateRateFontStrings()
end

function OpenRaidDropDownListUpdate(self)
	if self.num then
		if self.num == 0 then
			self:Hide();
			return
		end
		for i=1, self.num do
			self["Option" .. i]:Hide();
		end
	end
	if next(OR_db.Raids[Pname]) then
		local i = 0;
		for k, v in pairs(OR_db.Raids[Pname]) do
			i = i + 1;
			if not self["Option" .. i] then
				self["Option" .. i] = CreateFrame("Button", nil, self, "OpenRaidDropDownButtonTemplate");
				self["Option" .. i]:SetPoint("TOPLEFT", i==1 and self or self["Option" .. (i - 1)], "TOPLEFT", i==1 and 15 or 0, i==1 and -12 or -20)
			end
			self["Option" .. i].tooltip = v[1] .. "\n" .. L["Happening on"] .. " " .. v[2] .. "-" .. v[3] .. "-" .. v[4] .. ".";
			self["Option" .. i]:SetText(strsub(k .. "," .. v[1], 1, 20));
			if self:GetParent() == OpenRaidFrameRateRaid then
				self["Option" .. i]:SetScript("PostClick", function() switchRaidRate() end)
			end
			if self:GetParent() == OpenRaidRemoveFriendsFrameAll then
				self["Option" .. i]:SetScript("OnClick", OpenRaidRemoveFriendsFrameAllOnClick);
			elseif self == OpenRaidFrameOptionsContainerRemoveRaidList then
				self["Option" .. i]:SetScript("OnClick", removeRaid);
			end
			self["Option" .. i]:Show();
		end
		self.num = i;
	else
		if not self["Option1"] then
			self["Option1"] = CreateFrame("Button", nil, self, "OpenRaidDropDownButtonTemplate");
			self["Option1"]:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -12)
		end
		self["Option1"]:SetText(strsub(L["No raids in database"], 1, 22));
		self["Option1"]:Show();
		self["Option1"].tooltip = L["No raids in database"];
		self["Option1"]:SetScript("OnClick", function(self)
			self:GetParent():Hide()
		end);
		self.num = 1;
	end
	self:SetHeight(self.num * 20 + 20);
end

function OpenRaidOptionsDropDownListUpdate(self)
	local Children = {
		["Index"] = L["OptionsDropdown"]["Index"],
		["Rate"] = L["OptionsDropdown"]["Rate"],
		["Add"] = L["OptionsDropdown"]["Add"],
		["CreateRaid"] = L["OptionsDropdown"]["CreateRaid"],
		["Invite"] = L["OptionsDropdown"]["Invite"],
	}
	
	local i = 0
	for k, v in pairs(Children) do
		i = i + 1;
		self["Option" .. i] = CreateFrame("Button", nil, self, "OpenRaidDropDownButtonTemplate");
		self["Option" .. i]:SetPoint("TOPLEFT", i==1 and self or self["Option" .. (i - 1)], "TOPLEFT", i==1 and 15 or 0, i==1 and -12 or -20)
		self["Option" .. i]:SetText(v);
		self["Option" .. i]:SetScript("OnClick", function(self)
			OpenRaidFrameOptionsContainerStartpage:SetText(v);
			OR_db.Options.Defaultpage = k;
			self:GetParent():Hide();
		end)
		self["Option" .. i]:Show();
	end
	self:SetHeight(120);
end