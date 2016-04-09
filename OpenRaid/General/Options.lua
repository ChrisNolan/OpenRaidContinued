local L = OpenRaid.L;

OpenRaidOptions = {
	["Default start page"] = {
		["name"] = "Startpage",
		["type"] = "Button",
		["inherits"] = "OpenRaidOptionsDropDownTemplate",
		["tooltip"] = L["Default start page tooltip"],
	},
	["Auto enable sent"] = {
		["name"] = "AutoEnableSent",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Automatically enable sent"],
		["tooltip"] = L["Automatically enable sent tooltip"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["Auto enable sent"] = true;
			else
				OR_db.Options["Auto enable sent"] = false;
			end
		end,
	},
	["Auto enable accept"] = {
		["name"] = "AutoEnableAccept",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Automatically accept friend requests"],
		["tooltip"] = L["Automatically accept friend requests tooltip"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["Auto enable accept"] = true;
			else
				OR_db.Options["Auto enable accept"] = false;
			end
		end,
	},
	["Personal send message"] = {
		["name"] = "PersonalSendMessage",
		["type"] = "EditBox",
		["inherits"] = "OpenRaidEditboxTemplate",
		["size"] = {
			["X"] = 250,
			["Y"] = 20,
		},
		["text"] = L["Personal send message"],
		["scripts"] = {
			["OnEnterPressed"] = function(self)
				self:ClearFocus();
				if strfind(self:GetText(), "%%d") and strfind(self:GetText(), "%%s") then
					OR_db.Options["Personal send message"] = self:GetText();
				else
					OpenRaidErrorHandle(L["Must contain error"], function() end)
				end
			end,
		},
		["tooltip"] = L["Must contain tooltip"],
	},
	["Whisperword"] = {
		["name"] = "PersonalWhisperWord",
		["type"] = "Frame",
		["special"] = "choose",
		["text"] = "Whisper words",
		["tooltip"] = L["Whisper word tooltip"],
		["Options"] = {
			[1] = {
				["name"] = "EventNumber",
				["type"] = "CheckButton",
				["inherits"] = "OptionsCheckButtonTemplate",
				["text"] = "Event Number",
				["variable"] = "Whisperword",
				["func"] = function(self)
					if self:GetChecked() then
						OR_db.Options["Whisperword"] = false;
					end
					self:SetChecked(not OR_db.Options["Whisperword"]);
					OpenRaidFrameOptionsContainerOwnWhisperWord:SetText("");
				end,
				["scripts"] = {
					["OnShow"] = function(self)
						self:SetChecked(not OR_db.Options["Whisperword"])
					end,
				},
			},
			[2] = {
				["name"] = "OwnWhisperWord",
				["type"] = "EditBox",
				["inherits"] = "OpenRaidEditboxTemplate",
				["size"] = {
					["X"] = 250,
					["Y"] = 20,
				},
				["text"] = "WhisperWord",
				["tooltip"] = L["EditBox Enter confirm"],
				["scripts"] = {
					["OnEnterPressed"] = function(self)
						if self:GetText() ~= "" then
							OR_db.Options["Whisperword"] = self:GetText();
							OpenRaidFrameOptionsContainerEventNumber:SetChecked(false);
						else
							OR_db.Options["Whisperword"] = false;
							OpenRaidFrameOptionsContainerEventNumber:SetChecked(true);
						end
						self.hasEnterPressed = true;
						self:ClearFocus();
						self.hasEnterPressed = false;
					end,
					["OnShow"] = function(self)
						if OR_db.Options["Whisperword"] then
							self:SetText(OR_db.Options["Whisperword"])
						else
							self:SetText("");
						end
					end,
					["OnEditFocusLost"] = function(self)
						if not self.hasEnterPressed and self:GetText() ~= OR_db.Options["Whisperword"] then
							self:SetText(OR_db.Options["Whisperword"] or "")
						end
					end,
				},
			},
		},
	},
	["Clean up time"] = {
		["name"] = "CleanUpTime",
		["type"] = "EditBox",
		["inherits"] = "OpenRaidEditboxTemplate",
		["size"] = {
			["X"] = 20,
			["Y"] = 20,
		},
		["text"] = L["Clean up time"],
		["scripts"] = {
			["OnEnterPressed"] = function(self)
				if not strmatch(self:GetText(), "%D") and self:GetText() ~= "" then
					if math.floor((self:GetText())) < 1 then
						OR_db.Options["Clean up time"] = 1
					else
						OR_db.Options["Clean up time"] = math.floor(tonumber(self:GetText()));
					end
				else
					self:SetText(OR_db.Options["Clean up time"]);
				end
				self.hasEnterPressed = true;
				self:ClearFocus();
				self.hasEnterPressed = false;
			end,
			["OnEditFocusLost"] = function(self)
				if not self.hasEnterPressed and (strmatch(self:GetText(), "%D") or self:GetText() == "") then
					self:SetText(OR_db.Options["Clean up time"])
				end
			end,
		},
		["tooltip"] = L["Clean up time tooltip"],
	},
	["Filter have invited"] = {
		["name"] = "Filter have invited",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Filter have invited"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["Filter have invited"] = true;
			else
				OR_db.Options["Filter have invited"] = false;
			end
		end,
		["scripts"] = {
			["OnShow"] = function(self)
				self:SetChecked(OR_db.Options["Filter have invited"])
			end,
		},
		["tooltip"] = L["Filter have invited tooltip"],
	},
	["Filter already in group"] = {
		["name"] = "Filter already in group",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Filter already in group"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["Filter already in group"] = true;
			else
				OR_db.Options["Filter already in group"] = false;
			end
		end,
		["scripts"] = {
			["OnShow"] = function(self)
				self:SetChecked(OR_db.Options["Filter already in group"])
			end,
		},
		["tooltip"] = L["Filter already in group tooltip"],
	},
	["Filter joined your group"] = {
		["name"] = "Filter joined your group",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Filter joined your group"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["Filter joined your group"] = true;
			else
				OR_db.Options["Filter joined your group"] = false;
			end
		end,
		["scripts"] = {
			["OnShow"] = function(self)
				self:SetChecked(OR_db.Options["Filter joined your group"])
			end,
		},
		["tooltip"] = L["Filter joined your group tooltip"],
	},
	["Automatically send requests"] = {
		["name"] = "Automatically send requests",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Automatically send requests"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["Automatically send requests"] = true;
			else
				OR_db.Options["Automatically send requests"] = false;
			end
		end,
		["tooltip"] = L["Automatically send requests tooltip"],
	},
	["Clear raids after X days"] = {
		["name"] = "Clear raids after X days",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Also clean up raids"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["Clear raids after X days"] = true;
			else
				OR_db.Options["Clear raids after X days"] = false;
			end
		end,
		["scripts"] = {
			["OnShow"] = function(self)
				self:SetChecked(OR_db.Options["Clear raids after X days"])
			end,
		},
		["tooltip"] = L["Clear raids after X days tooltip"],
	},
	["Dont check for char"] = {
		["name"] = "DontCheckForChar",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Dont check character"],
		["tooltip"] = L["Dont check character tooltip"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["DontCheckForChar"] = true;
			else
				OR_db.Options["DontCheckForChar"] = false;
			end
		end,
	},
	["Remove old raid"] = {
		["name"] = "RemoveRaid",
		["type"] = "Button",
		["inherits"] = "OpenRaidRemoveRaidDropDownTemplate",
		["tooltip"] = L["Default start page tooltip"],
	},
	["Set special note"] = {
		["name"] = "Set special note",
		["type"] = "CheckButton",
		["inherits"] = "OptionsCheckButtonTemplate",
		["text"] = L["Set special note"],
		["tooltip"] = L["Set special note tooltip"],
		["func"] = function(self)
			if self:GetChecked() then
				OR_db.Options["Specialnote"] = true;
			else
				OR_db.Options["Specialnote"] = false;
			end
		end,
	},
}