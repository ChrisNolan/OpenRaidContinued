--[[
	Database layout
	
	[step]
		Arrow:SetPoint(A1, OpenRaidFrame, A2, X, Y);
		["Arrow"] = {
			["A1"] = "TOP", 			Anchor one
			["A2"] = "TOPRIGHT", 		Anchor two
			["X"] = 0, 					X offset
			["Y"] = 0,					Y offset
			["Pos"] = "down",			Image
		},
		["Child"] = {
			["Name"] = "Add",			Name of a childframe of OpenRaidFrame to open
		},
		["Function"] = function() <code you want to run> end,
]]

local month, day, year = CalendarGetDate();
local buttons = {"OpenRaidFrameCreateRaidDataWrite", "OpenRaidFrameAddDataWrite", "OpenRaidFrameInviteDataWrite", "OpenRaidFrameInvitePlusInvite", "OpenRaidFrameRateFinalize", "OpenRaidFrameOptionsReset", }
local function CreateFakeOpenRaidEvent()
	OR_db.Raids[GetFullUnitName("player")]["1337"] = {
		"OpenRaid event",
		day,
		month,
		year,
		"20",
		"00",
		"BattleTag#1234-Personname-Realmname,BattleTag#4321-Person2name-Realm2name",
	}
	OR_db.Rate["1337"] = {};
	--Disable all buttons, so we don't accidently do stuff we dont want
	for _, v in pairs(buttons) do
		_G[v]:Disable();
	end
end

function RemoveFakeOpenRaidEvent()
	OR_db.Raids[GetFullUnitName("player")]["1337"] = nil;
	OR_db.Rate["1337"] = nil;
	for _, v in pairs(buttons) do
		_G[v]:Enable();
	end
	OR_db.Notes["battletag#1234"] = nil;
	OR_db.Notes["battletag#4321"] = nil;
end

local function SafeClick(self)
	self:Enable();
	self:Click();
	self:Disable();
end

OpenRaidTutorialSteps = {
	[1] = {
	},
	[2] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 50,
			["Y"] = 50,
			["Pos"] = "down",
		},
	},
	[3] = {
		["Function"] = function()
			CreateFakeOpenRaidEvent()
		end
	},
	[4] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = 0,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "CreateRaid",
		},
		["Function"] = function()
			OpenRaidFrameCreateRaidBorderScrollFrameEditBox:SetText(GetFullUnitName("player") .. "*1337,OpenRaid event," .. day .."," .. month .. "," .. year .. ",20,00;BattleTag#1234-Personname-Realmname,BattleTag#4321-Person2name-Realm2name")
		end,
	},
	[5] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -20,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Calendar",
		},
	},
	[6] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -40,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Add",
		},
		["Function"] = function()
			OpenRaidFrameAddRaid:Disable();
		end,
	},
	[7] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -40,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Stay",
		},
		["Function"] = function()
			SafeClick(OpenRaidFrameAddRaid);
		end,
	},
	[8] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -40,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Stay",
		},
		["Function"] = function()
			SafeClick(OpenRaidFrameAddRaid);
			OpenRaidFrameAddBorderScrollFrameEditBox:SetText(GetFullUnitName("player") .. "*1337,OpenRaid event;BattleTag#1234-Personname-Realmname,BattleTag#4321-Person2name-Realm2name");
		end,
	},
	[9] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -60,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Invite",
		},
		["Function"] = function()
			OpenRaidFrameAddRaid:Enable();
			OpenRaidFrameInviteRaid:Disable();
		end,
	},
	[10] = {	
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -60,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Stay",
		},
		["Function"] = function()
			SafeClick(OpenRaidFrameInviteRaid);
		end,
	},
	[11] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -60,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Stay",
		},
		["Function"] = function()
			SafeClick(OpenRaidFrameInviteRaid);
			OpenRaidFrameInviteBorderScrollFrameEditBox:SetText(GetFullUnitName("player") .. "*1337,OpenRaid event;BattleTag#1234-Personname-Realmname,BattleTag#4321-Person2name-Realm2name")
		end,
	},
	[12] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -60,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Stay",
		},
		["Function"] = function()
		
			local NumInvited = 0;
			local NumInvitedFailed = 2;
			local NumInvitedResponded = 1;

			local function getAmount(num)
				return (num/(NumInvited + NumInvitedFailed + NumInvitedResponded) * 200)
			end
			
			local function update()
				OpenRaidFrameInviteProgressBarFailed:SetWidth(getAmount(NumInvitedFailed));
				OpenRaidFrameInviteProgressBarResponded:SetWidth(getAmount(NumInvitedResponded));
				OpenRaidFrameInviteProgressBarInvited:SetWidth(getAmount(NumInvited));
			end
			
			OpenRaidFrameInviteBorderScrollFrameEditBox:SetText("");
			OpenRaidFrameInviteBorder:Hide();
			OpenRaidFrameInviteProgress:Show();
			OpenRaidFrameTutorialNext:Disable();
			
			OpenRaidFrameInviteProgressBarFailed:SetWidth(getAmount(NumInvitedFailed));
			OpenRaidFrameInviteProgressBarResponded:SetWidth(getAmount(NumInvitedResponded));
			OpenRaidFrameInviteProgressBarInvited:SetWidth(0.1);
			
			local S = OpenRaidFrameInviteProgressBarFailed:GetScript("OnSizeChanged");
			
			OpenRaidFrameInviteProgressBarFailed:SetScript("OnSizeChanged", nil);
			OpenRaidFrameInviteProgressBarResponded:SetScript("OnSizeChanged", nil);
			OpenRaidFrameInviteProgressBarInvited:SetScript("OnSizeChanged", nil);
			
			OpenRaidGameTooltip(OpenRaidFrameInviteProgressBarFailed, "These could not have been invited:\nPersonA-RealmName (not a BNfriend)\nPersonB-RealmName (not online)");
			OpenRaidGameTooltip(OpenRaidFrameInviteProgressBarResponded, "These could not have been invited:\nPersonA-RealmName (online on wrong character)\nPersonB-RealmName (already in a group)");
			
			local Timer = CreateFrame("FRAME");
			Timer.TimeSinceLastUpdate = 0;
			local num = 0;
			Timer:SetScript("OnUpdate", function(self, elapsed)
				Timer.TimeSinceLastUpdate = Timer.TimeSinceLastUpdate + elapsed;
				if (Timer.TimeSinceLastUpdate > 2) then
					if num < 5 then
						NumInvited = NumInvited + 1;
						OpenRaidGameTooltip(OpenRaidFrameInviteProgressBarInvited, "Already " .. NumInvited .. " attendees in raid.");
						update()
						num = num + 1;
						Timer.TimeSinceLastUpdate = 0;
					else
						NumInvitedResponded = 3;
						update();
						Timer.TimeSinceLastUpdate = 0;
						Timer:SetScript("OnUpdate", function(self, elapsed)
							Timer.TimeSinceLastUpdate = Timer.TimeSinceLastUpdate + elapsed;
							if (Timer.TimeSinceLastUpdate > 2.5) then
								OpenRaidFrameInviteProgressBarFailed:SetScript("OnSizeChanged", S);
								OpenRaidFrameInviteProgressBarResponded:SetScript("OnSizeChanged", S);
								OpenRaidFrameInviteProgressBarInvited:SetScript("OnSizeChanged", S);
								OpenRaidFrameInviteProgress:Hide();
								OpenRaidFrameInviteBorder:Show();
								OpenRaidFrameTutorialNext:Enable();
								Timer:SetScript("OnUpdate", nil);
							end
						end);
					end
				end
			end)
			
		end,
	},
	[13] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -80,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Rate",
		},
		["Function"] = function()
			OpenRaidFrameInviteRaid:Enable();
			OpenRaidFrameRateRaid:Disable();
		end,
	},
	[14] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -80,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Stay",
		},
		["Function"] = function()
			SafeClick(OpenRaidFrameRateRaid);
		end,
	},
	[15] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -80,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Stay",
		},
		["Function"] = function()
			OpenRaidFrameRateRaid:Enable();
			OpenRaidFrameRateRaid:Click();
			OpenRaidFrameRateRaid:SetText("1337,OpenRaid Event");
			UpdateRateFontStrings("1337");
			OpenRaidFrameRateRaid:Disable();
		end,
	},
	[16] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -80,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Stay",
		},
		["Function"] = function()
			RateFrameCheckbox15:Click();
			RateFrameEditbox1:SetText("Great player!");
			RateFrameCheckbox23:Click();
			RateFrameEditbox2:SetText("Good player.");
		end,
	},
	[17] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -100,
			["Pos"] = "left",
		},
		["Function"] = function()
			OpenRaidFrameRateRaid:Enable();
			OpenRaidFrameRateRaid:SetText("Raid");
		end,
	},
	[18] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -197,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Options",
		},
	},
	[19] = {
		["Arrow"] = {
			["A1"] = "TOP",
			["A2"] = "TOPRIGHT",
			["X"] = 120,
			["Y"] = -217,
			["Pos"] = "left",
		},
		["Child"] = {
			["Name"] = "Index",
		},
	},
	[20] = {
		["Function"] = function()
			RemoveFakeOpenRaidEvent();
		end,
	},
	
}