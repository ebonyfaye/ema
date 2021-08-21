-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2021 Jennifer Calladine					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- With Help From Jabberie, EMA Edit By Jennifer

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("EMA" .." ".. "Ebony's Multiboxing Assistant", {
	type = "data source",
	text = "EMA",
	OnLeave = dataObject_OnLeave
})

local LibSharedMedia = LibStub('LibSharedMedia-3.0')
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )


local baseFont = CreateFont("baseFont")

-- Check for ElvUI
if (ElvUI == nil) or (ElvUI == '') then 
	baseFont:SetFont(GameTooltipText:GetFont(), 10)
elseif LibSharedMedia:IsValid('font', ElvUI[1].db.general.font) then
	baseFont:SetFont(LibSharedMedia:Fetch('font', ElvUI[1].db.general.font), 10)
else
	baseFont:SetFont(GameTooltipText:GetFont(), 10)
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	dataobj.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end

function dataobj:OnTooltipShow()
	self:AddDoubleLine( L["LDBBAR_LEFT_CLICK"], L["LDBBAR_CONFIG"], 1, 0.82, 0, 1, 1, 1 )
	self:AddDoubleLine( L["LDBBAR_MIDDLE_CLICK"], L["LDBBAR_CONFIG_TEAM"], 1, 0.82, 0, 1, 1, 1 )
	self:AddDoubleLine( L["LDBBAR_RIGHT_CLICK"], L["LDBBAR_PUSH"], 1, 0.82, 0, 1, 1, 1 )
end

local function dataObject_OnLeave(self)
	GameTooltip:Hide()
end

function dataobj:OnLeave()
	dataObject_OnLeave(self)
end

function dataobj:OnClick(button)
	if button == "LeftButton" then	
		EMAPrivate.SettingsFrame.Widget:Show()
		EMAPrivate.SettingsFrame.WidgetTree:SelectByValue( L["NEWS"] )
		EMAPrivate.SettingsFrame.Tree.ButtonClick( nil, nil, L["NEWS"], false)		
	elseif button == "MiddleButton" then
		EMAPrivate.SettingsFrame.Widget:Show()
		EMAPrivate.SettingsFrame.WidgetTree:SelectByValue( L["TEAM"] )
		EMAPrivate.SettingsFrame.Tree.ButtonClick( nil, nil, L["TEAM"], false)
	elseif button == "RightButton" then
		EMAPrivate.Core.SendSettingsAllModules()
  end
end