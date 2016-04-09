if OpenRaid.Pname ~= "Jeremybell-Grim Batol" then return end;

--[[
	This file will contain various debugging tools for programming.
	Since this is only for debugging purposes, we don't want to
	load it for every user.
]]

local Frames = {};
local function undoChanges()
	for k,v in pairs(Frames) do
		_G[k]:SetBackdropBorderColor(v[1]);
	end
end

function ORChangeBorders()
	local Frame = GetMouseFocus();
	if not Frame then return end;
	
	Frame:HookScript("OnLeave", undoChanges);
	while(Frame and Frame:GetName() ~= "UIParent") do
		local Name = Frame:GetName() or "Frame with no global name";
		print(Name);
		if (Name ~= "Frame with no global name") then
			print(Frame:GetBackdropBorderColor())
			Frames[Name] = {
				Frame:GetBackdropBorderColor(),
			};
			Frame:SetBackdropBorderColor(1, 1, 1, 1)
		end
		Frame = Frame:GetParent();
	end
end

SLASH_ChangeBorder1 = "/border";
SlashCmdList.ChangeBorder = ORChangeBorders;