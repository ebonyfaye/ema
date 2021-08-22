-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2019 Jennifer Cally					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --


-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"ItemUse", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Get the EMA Utilities Library.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local LibActionButton = LibStub( "EMALibActionButton-1.0" )
local LibBagUtils = LibStub:GetLibrary( "LibBagUtils-1.0" )
EMA.SharedMedia = LibStub( "LibSharedMedia-3.0" )

--  Constants and Locale for this module.
EMA.moduleName = "ItemUse"
EMA.settingsDatabaseName = "ItemUseProfileDB"
EMA.chatCommand = "ema-itemuse"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core"  )
EMA.parentDisplayName = L["DISPLAY"]
EMA.moduleDisplayName = L["ITEM_USE"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\ItemUseIcon.tga"
-- order
EMA.moduleOrder = 1


-- EMA key bindings.
BINDING_HEADER_ITEMUSE = L["ITEM-USE"]
BINDING_NAME_ITEMUSE1 = L["ITEM"]..L[" "]..L["1"]
BINDING_NAME_ITEMUSE2 = L["ITEM"]..L[" "]..L["2"]
BINDING_NAME_ITEMUSE3 = L["ITEM"]..L[" "]..L["3"]
BINDING_NAME_ITEMUSE4 = L["ITEM"]..L[" "]..L["4"]
BINDING_NAME_ITEMUSE5 = L["ITEM"]..L[" "]..L["5"]
BINDING_NAME_ITEMUSE6 = L["ITEM"]..L[" "]..L["6"]
BINDING_NAME_ITEMUSE7 = L["ITEM"]..L[" "]..L["7"]
BINDING_NAME_ITEMUSE8 = L["ITEM"]..L[" "]..L["8"]
BINDING_NAME_ITEMUSE9 = L["ITEM"]..L[" "]..L["9"]
BINDING_NAME_ITEMUSE10 = L["ITEM"]..L[" "]..L["10"]
BINDING_NAME_ITEMUSE11 = L["ITEM"]..L[" "]..L["11"]
BINDING_NAME_ITEMUSE12 = L["ITEM"]..L[" "]..L["12"]
BINDING_NAME_ITEMUSE13 = L["ITEM"]..L[" "]..L["13"]
BINDING_NAME_ITEMUSE14 = L["ITEM"]..L[" "]..L["14"]
BINDING_NAME_ITEMUSE15 = L["ITEM"]..L[" "]..L["15"]
BINDING_NAME_ITEMUSE16 = L["ITEM"]..L[" "]..L["16"]
BINDING_NAME_ITEMUSE17 = L["ITEM"]..L[" "]..L["17"]
BINDING_NAME_ITEMUSE18 = L["ITEM"]..L[" "]..L["18"]
BINDING_NAME_ITEMUSE19 = L["ITEM"]..L[" "]..L["19"]
BINDING_NAME_ITEMUSE20 = L["ITEM"]..L[" "]..L["20"]

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		showItemUse = true,
		--showItemUseOnMasterOnly = false,
		--hideItemUseInCombat = false,
		showItemCount = true,
		borderStyle = L["BLIZZARD_TOOLTIP"],
		backgroundStyle = L["BLIZZARD_DIALOG_BACKGROUND"],
		itemUseScale = 1,
		itemUseTitleHeight = 3,
		itemUseVerticalSpacing = 3,
		itemUseHorizontalSpacing = 2,
		autoAddQuestItemsToBar = false,
--		autoAddArtifactItemsToBar = false,
--		autoAddSatchelsItemsToBar = false,
		hideClearButton = false,
		itemBarsSynchronized = true,
		numberOfItems = 10,
		numberOfRows = 2,
		messageArea = EMAApi.DefaultWarningArea(),
		itemsAdvanced = {},
		itemsSoted = {},
		framePoint = "BOTTOMRIGHT",
		frameRelativePoint = "BOTTOMRIGHT",
		frameXOffset = 0,
		frameYOffset = 70,
		frameAlpha = 1.0,
		frameBackgroundColourR = 1.0,
		frameBackgroundColourG = 1.0,
		frameBackgroundColourB = 1.0,
		frameBackgroundColourA = 1.0,
		frameBorderColourR = 1.0,
		frameBorderColourG = 1.0,
		frameBorderColourB = 1.0,
		frameBorderColourA = 1.0,		
	},
}

-- Configuration.
function EMA:GetConfiguration()
	local configuration = {
		name = EMA.moduleDisplayName,
		handler = EMA,
		type = 'group',
		args = {	
			config = {
				type = "input",
				name = L["OPEN_CONFIG"],
				desc = L["OPEN_CONFIG_HELP"],
				usage = "/ema-itemuse config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-itemuse push",
				get = false,
				set = "EMASendSettings",
			},											
			hide = {
				type = "input",
				name = L["HIDE_ITEM_BAR"],
				desc = L["HIDE_ITEM_BAR_HELP"],
				usage = "/ema-itemuse hide",
				get = false,
				set = "HideItemUseCommand",
			},	
			show = {
				type = "input",
				name = L["SHOW_ITEM_BAR"],
				desc = L["SHOW_ITEM_BAR_HELP"],
				usage = "/ema-itemuse show",
				get = false,
				set = "ShowItemUseCommand",
			},
			clear = {
				type = "input",
				name = L["CLEAR_ITEM_BAR"],
				desc = L["CLEAR_ITEM_BAR_HELP"],
				usage = "/ema-itemuse clear",
				get = false,
				set = "ClearItemUseCommand",
			},				
		},
	}
	return configuration
end

local function DebugMessage( ... )
	--EMA:Print( ... )
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

EMA.COMMAND_ITEMBAR_BUTTON = "EMACommandItemBarButton"
EMA.COMMAND_ITEMUSE_SYNC = "EMACommandItemBarSync"
EMA.COMMAND_ITEM_COUNT = "EMACommandItemBarCount"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Variables used by module.
-------------------------------------------------------------------------------------------------------------

EMA.globalFramePrefix = "EMAItemUse"
EMA.itemContainer = {}
EMA.itemUseCreated = false	
EMA.itemSize = 40
EMA.refreshItemUseControlsPending = false
EMA.refreshUpdateItemsInBarPending = false
EMA.refreshUpdateBindingsPending = false
EMA.updateSettingsAfterCombat = false
EMA.maximumNumberOfItems = 20
EMA.maximumNumberOfRows = 20


-------------------------------------------------------------------------------------------------------------
-- Item Bar.
-------------------------------------------------------------------------------------------------------------

local function CanDisplayItemUse()
	local canShow = false
	if EMA.db.showItemUse == true then
		--if EMA.db.showItemUseOnMasterOnly == true then
		--	if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
		--		canShow = true
		--	end
		--else
		canShow = true
		--end
	end
	return canShow
end

local function CreateEMAItemUseFrame()
	-- The frame.	EMAItemUseWindowFrame
	local frame = CreateFrame("Frame", "EMAItemUseWindowFrame", UIParent, "SecureHandlerStateTemplate") Mixin(frame, BackdropTemplateMixin or {})
	--local frame = CreateFrame( "Frame", "EMAItemUseWindowFrame" , UIParent, "SecureHandlerStateTemplate" )
	frame:SetAttribute("_onstate-page", [[
		self:SetAttribute("state", newstate)
		control:ChildUpdate("state", newstate)
	]])
	RegisterStateDriver(frame, "page", "[mod:alt]0;0")
	frame.parentObject = EMA
	frame:SetFrameStrata( "LOW" )
	frame:SetToplevel( true )
	frame:SetClampedToScreen( true )
	frame:EnableMouse( true )
	frame:SetMovable( true )	
	
	frame:RegisterForDrag( "LeftButton" )
	frame:SetScript( "OnDragStart", 
			--function( this ) 
		function( self,button )	
			if IsAltKeyDown() then
				self:StartMoving() 
			end
		end )
	frame:SetScript( "OnDragStop", 
		--function( this ) 
		function(self,button)	
			self:StopMovingOrSizing() 
			local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint()
			EMA.db.framePoint = point
			EMA.db.frameRelativePoint = relativePoint
			EMA.db.frameXOffset = xOffset
			EMA.db.frameYOffset = yOffset
		end	)	
	frame:SetBackdrop( {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
		tile = true, tileSize = 10, edgeSize = 10, 
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	} )
	frame:ClearAllPoints()
	frame:SetPoint( EMA.db.framePoint, nil, EMA.db.frameRelativePoint, EMA.db.frameXOffset, EMA.db.frameYOffset )
	-- Clear Button
		local updateButton = CreateFrame( "Button", "ButtonUpdate", frame, "UIPanelButtonTemplate" )
		updateButton:SetScript( "OnClick", function() EMA.ClearButton() end )
		updateButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", -4, -3 )
		updateButton:SetHeight( 20 )
		updateButton:SetWidth( 65 )
		updateButton:SetText( L["CLEAR_BUTT"] )	
		updateButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(updateButton, "clear", true) end)
		updateButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
		ClearUpdateButton = updateButton
	-- Sync Button	
		local syncButton = CreateFrame( "Button", "ButtonSync", frame, "UIPanelButtonTemplate" )
		syncButton:SetScript( "OnClick", function() EMA.SyncButton() end )
		syncButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", -71, -3 )
		syncButton:SetHeight( 20 )
		syncButton:SetWidth( 65 )
		syncButton:SetText( L["SYNC_BUTT"] )	
		syncButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(updateButton, "sync", true) end)
		syncButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
		SyncUpdateButton = syncButton
		

	-- Set transparency of the the frame (and all its children).
	frame:SetAlpha(EMA.db.frameAlpha)
	-- Set the global frame reference for this frame.
	EMAItemUseFrame = frame
	-- Remove unsued items --test
--	EMA:SettingsUpdateBorderStyle()	
	EMA.itemUseCreated = true
	EMA.UpdateHeight()
end

function EMA:ShowTooltip(frame, info, show)
	if show then
		GameTooltip:SetOwner(frame, "ANCHOR_TOP")
		GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT", 16, 0)
		GameTooltip:ClearLines()
		if info == "clear" then
			GameTooltip:AddLine(L["TOOLTIP_NOLONGER_IN_BAGS"], 1, 0.82, 0, 1)
		elseif info == "sync" then
			GameTooltip:AddLine(L["TOOLTIP_SYNCHRONISE"], 1, 0.82, 0, 1)
		end
		GameTooltip:Show()
	else
	GameTooltip:Hide()
	end
end

function EMA:UpdateHeight()											  
	if EMA.db.hideClearButton == false then
		EMA.db.itemUseTitleHeight = 2
		local newHeight = EMA.db.itemUseTitleHeight + 20
		ClearUpdateButton:Show()
		SyncUpdateButton:Show()
		return newHeight	
	else
		EMA.db.itemUseTitleHeight = 2
		oldHeight = EMA.db.itemUseTitleHeight
		ClearUpdateButton:Hide()
		SyncUpdateButton:Hide()
		return oldHeight
	end	
end


function EMA:ShowItemUseCommand()
	EMA.db.showItemUse = true
	EMA:SetItemUseVisibility()
	EMA:SettingsRefresh()
end

function EMA:HideItemUseCommand()
	EMA.db.showItemUse = false
	EMA:SetItemUseVisibility()
	EMA:SettingsRefresh()
end

function EMA:ClearItemUseCommand()
	EMAUtilities:ClearTable(EMA.db.itemsAdvanced)
	EMA:SettingsRefresh()
	EMA:Print(L["ITEM_BAR_CLEARED"])
end

function EMA:SetItemUseVisibility()
	local frame = EMAItemUseFrame
	if CanDisplayItemUse() == true then
		frame:ClearAllPoints()
		frame:SetPoint( EMA.db.framePoint, UIParent, EMA.db.frameRelativePoint, EMA.db.frameXOffset, EMA.db.frameYOffset )
		frame:SetAlpha( EMA.db.frameAlpha )
		frame:Show()
	else
		frame:Hide()
	end	
end

function EMA:SettingsUpdateBorderStyle()
	local borderStyle = EMA.SharedMedia:Fetch( "border", EMA.db.borderStyle )
	local backgroundStyle = EMA.SharedMedia:Fetch( "background", EMA.db.backgroundStyle )
	local frame = EMAItemUseFrame
	frame:SetBackdrop( {
		bgFile = backgroundStyle, 
		edgeFile = borderStyle, 
		tile = true, tileSize = frame:GetWidth(), edgeSize = 10, 
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	} )
	frame:SetBackdropColor( EMA.db.frameBackgroundColourR, EMA.db.frameBackgroundColourG, EMA.db.frameBackgroundColourB, EMA.db.frameBackgroundColourA )
	frame:SetBackdropBorderColor( EMA.db.frameBorderColourR, EMA.db.frameBorderColourG, EMA.db.frameBorderColourB, EMA.db.frameBorderColourA )		
end

-- updates after the quest has been handed in,
function EMA:UpdateQuestItemsInBar()
	local state = "0"
	for iterateItems = 1, EMA.maximumNumberOfItems, 1 do
		local itemContainer = EMA.itemContainer[iterateItems]
		if itemContainer == nil then
			EMA:CreateEMAItemUseItemContainer( iterateItems, parentFrame )
			itemContainer = EMA.itemContainer[iterateItems]
		end
		local containerButton = itemContainer["container"]
		local itemInfo = EMA:GetItemFromItemDatabase( iterateItems )
		local kind = itemInfo.kind
		local action = itemInfo.action
		if kind == "item" then
			--local itemLink,_,_,_,_,questItem = GetItemInfo( action )
			--local text, text2 = EMAUtilities:TooltipScaner( action )
			local _, _, _, _, _, _ , _, _, _, _, _, _, _, bindType = GetItemInfo( action )
			local canUse = GetItemSpell( action )
			--EMA:Print("Checking Item...", action, canUse, "a",  bindType )
			if ( canUse ) and ( bindType == 4 ) then
				local IsInInventory = EMA:IsInInventory( action )
				if IsInInventory == false then
					--EMA:Print("NOT IN BAGS", IsInInventory, action)
					EMA.db.itemsAdvanced[iterateItems] = nil	
					EMA:EMASendUpdate( iterateItems, "empty", nil )
				end	
			end
		end
	end	
end	

function EMA:UpdateItemsInBar()
	local state = "0"
    local parentFrame = EMAItemUseFrame
	for iterateItems = 1, EMA.maximumNumberOfItems, 1 do
		local itemContainer = EMA.itemContainer[iterateItems]
		if itemContainer == nil then
			EMA:CreateEMAItemUseItemContainer( iterateItems, parentFrame )
			itemContainer = EMA.itemContainer[iterateItems]
		end
		local containerButton = itemContainer["container"]
		local itemInfo = EMA:GetItemFromItemDatabase( iterateItems )
		local kind = itemInfo.kind
		local action = itemInfo.action
		if kind == "item" and not tonumber( action ) then
			action = action:sub(6)
		end
        --EMA:Print(state, kind, action)
		if kind == "mount" or kind == "battlepet" then
            containerButton:ClearStates()
		else
		containerButton:SetState(state, kind, action)
        end
	end
end

function EMA:AddItemToItemDatabase( itemNumber, kind, action )
    if kind == "mount" or kind == "battlepet" then
        return
    end
	if EMA.db.itemsAdvanced[itemNumber] == nil then
		EMA.db.itemsAdvanced[itemNumber] = {}
	end
	EMA.db.itemsAdvanced[itemNumber].kind = kind
	EMA.db.itemsAdvanced[itemNumber].action = action
end

function EMA:GetItemFromItemDatabase( itemNumber )
	if EMA.db.itemsAdvanced[itemNumber] == nil then
		EMA.db.itemsAdvanced[itemNumber] = {}
		EMA.db.itemsAdvanced[itemNumber].kind = "empty"
		EMA.db.itemsAdvanced[itemNumber].action = "empty"
	end
	return EMA.db.itemsAdvanced[itemNumber]
end

function EMA:OnButtonContentsChanged( event, button, state, type, value, ... )
    if type == "mount" or type == "battlepet" then
		return
    end
    EMA:AddItemToItemDatabase( button.itemNumber, type, value )
    EMA:EMASendUpdate(button.itemNumber, type, value )
	EMA:SettingsRefresh()
end

function EMA:OnButtonUpdate( event, button, ... )
	--EMA:Print( event, button, ...)
end

function EMA:OnButtonState( event, button, ... )
	--EMA:Print( event, button, ...)
end

function EMA:OnButtonUsable( event, button, ... )
	--EMA:Print( event, button, ...)
end

function EMA:CreateEMAItemUseItemContainer( itemNumber, parentFrame )
	EMA.itemContainer[itemNumber] = {}
	local itemContainer = EMA.itemContainer[itemNumber]
	local containerButtonName = EMA.globalFramePrefix.."ContainerButton"..itemNumber
    local buttonConfig = {
        outOfRangeColoring = "button",
        tooltip = "enabled",
        showGrid = true,
        colors = {
            range = { 0.8, 0.1, 0.1 },
            mana = { 0.5, 0.5, 1.0 }
        },
        hideElements = {
            macro = false,
            hotkey = false,
            equipped = false,
        },
        keyBoundTarget = false,
        clickOnDown = false,
        flyoutDirection = "UP",
    }
	local containerButton = LibActionButton:CreateButton( itemNumber, containerButtonName, EMAItemUseWindowFrame, buttonConfig )
	containerButton:SetState( "0", "empty", nil)
	containerButton.itemNumber = itemNumber
	itemContainer["container"] = containerButton	
end

--ebony test Using the wowapi and not the scanning of tooltips
function EMA:CheckForQuestItemAndAddToBar()	
	if EMAPrivate.Core.isEmaClassicBccBuild() == true then
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				local itemLink = GetContainerItemLink(bag, slot)
				if itemLink and itemLink:match("item:%d") then
					local name, itemLink,_,_,_,itemType,questItem = GetItemInfo( itemLink )
					--EMA:Print("test", itemType,questItem )
					if itemType ~= nil and itemType == "Quest" then
					local spellName, spellID = GetItemSpell( itemLink )
						if spellName then
							--EMA:Print("test", itemLink, tooltipText )
							EMA:AddAnItemToTheBarIfNotExists( itemLink, false )
						end	
					end
				end
			end
		end
	else
		local index = C_QuestLog.GetNumQuestLogEntries()
		for iterateQuests = 1, index do	
			local info =  C_QuestLog.GetInfo( iterateQuests )
			if not info.isHeader then
				--EMA:Print("test", questItemLink, iterateQuests, questLogTitleText, questID )
				local questItemLink, questItemIcon, questItemCharges = GetQuestLogSpecialItemInfo( iterateQuests )	
				if questItemLink ~= nil then
					local itemName = GetItemInfo(questItemLink)
					local questName, rank = GetItemSpell(questItemLink) -- Only means to detect if the item is usable
					if questName then
						--EMA:Print("addItem", questItemLink )
						EMA:AddAnItemToTheBarIfNotExists( questItemLink, false)						
					end
				end			
			end
		end
	end	
end

-- Removes unused items.
function EMA:ClearButton()
	local state = "0"
	for iterateItems = 1, EMA.db.numberOfItems, 1 do
		local itemContainer = EMA.itemContainer[iterateItems]
		if itemContainer == nil then
			EMA:CreateEMAItemUseItemContainer( iterateItems, parentFrame )
			itemContainer = EMA.itemContainer[iterateItems]
		end
		local containerButton = itemContainer["container"]
		local itemInfo = EMA:GetItemFromItemDatabase( iterateItems )
		local kind = itemInfo.kind
		local action = itemInfo.action
		if kind == "item" then
			local name, itemLink,_,_,_,itemType,questItem = GetItemInfo( action )
			if itemLink and itemLink:match("item:%d") then
				local _ , tooltipTextTwo = EMAUtilities:TooltipScaner( itemLink )
				if tooltipTextTwo == nil or tooltipTextTwo ~= "Unique" then
					if EMA:IsInInventory( action ) == false then
						EMA.db.itemsAdvanced[iterateItems] = nil
						EMA:EMASendUpdate( iterateItems, "empty", nil )
						EMA:SettingsRefresh()
					end		
				end
			end					
		end
	end	
end

-- Sync Buttion
function EMA:SyncButton()
	local dataTable = {}
	for iterateItems = 1, EMA.db.numberOfItems, 1 do
	local itemContainer = EMA.itemContainer[iterateItems]
		if itemContainer == nil then
			EMA:CreateEMAItemUseItemContainer( iterateItems, parentFrame )
			itemContainer = EMA.itemContainer[iterateItems]
		end
			local containerButton = itemContainer["container"]
			local itemInfo = EMA:GetItemFromItemDatabase( iterateItems )
			local kind = itemInfo.kind
			local action = itemInfo.action
			data = {}
			data.button = iterateItems
			data.type = kind
			data.action = action
			table.insert( dataTable, data )
	end
	EMA:EMASendCommandToTeam( EMA.COMMAND_ITEMUSE_SYNC, dataTable)
	if EMA.db.showItemCount == true then
		EMA:GetEMAItemCount()
	end	
end

--[[
-- Add satchels to item bar.
function EMA:CheckForSatchelsItemAndAddToBar()
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local _, _, _, _, _, lootable = GetContainerItemInfo(bag, slot)
			if link then
				local tooltipText = EMAUtilities:TooltipScaner( link )
				if lootable == true then	
					if tooltipText ~= LOCKED then
						EMA:AddAnItemToTheBarIfNotExists( link, false )
					end
				end	
			end
		end
	end
end


-- NOWW VENDER TRASH 8.0
-- Adds artifact power items to item bar.
function EMA:CheckForArtifactItemAndAddToBar()
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag, slot)
			if itemLink and itemLink:match("item:%d") then
				local tooltipText = EMAUtilities:TooltipScaner(itemLink)
				if tooltipText and tooltipText:match(ARTIFACT_POWER) then
					EMA:AddAnItemToTheBarIfNotExists( itemLink, false )
				end
			end
		end
	end
end		

]]
	
--Checks the item is in the Toon players bag 8.0.1 using min/min code!
function EMA:IsInInventory(itemID)
	local InBags = false
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1,GetContainerNumSlots( bagID ),1 do 
			--EMA:Print( "Bags OK. checking", itemLink )
			local item = Item:CreateFromBagAndSlot(bagID, slotID)
			if ( item ) then
				local bagItemID = item:GetItemID()
				if ( bagItemID ) then
					local checkItemID = "item:"..bagItemID
					--EMA:Print("Check", checkItemID, "vs", itemID )
					if checkItemID == itemID then
						--EMA:Print("We Have Item checkItemID in Bags" )
						InBags = true
						break 
					end
				end
			end
		end
	end
	return InBags
end


function EMA:AddAnItemToTheBarIfNotExists( itemLink, startsQuest)
	local itemInfo
	local barItemId
	local iterateItems
	local alreadyExists = false
	local itemId = EMAUtilities:GetItemIdFromItemLink( itemLink )
	for iterateItems = 1, EMA.db.numberOfItems, 1 do
		local itemInfo = EMA:GetItemFromItemDatabase( iterateItems )
			--EMA:Print("check", itemLink, itemInfo.action)
		if itemInfo.kind == "item" and itemInfo.action == itemId then
			alreadyExists = true
		--	EMA:Print("test", itemLink )
			return
		end
	end
	if alreadyExists == false then
		--EMA:Print("test2", itemLink )
		for iterateItems = 1, EMA.db.numberOfItems, 1 do
			itemInfo = EMA:GetItemFromItemDatabase( iterateItems )
			--Checks the items we talking about is in the bags of the player.
			if itemInfo.kind == "empty" then
				EMA:AddItemToItemDatabase( iterateItems, "item", itemId )
				EMA:EMASendUpdate( iterateItems, "item", itemId )
				EMA:SettingsRefresh()	
					-- TODO: to we need this?
					if startsQuest then
						EMA:EMASendMessageToTeam( EMA.db.messageArea, L["NEW_QUEST_ITEM"], false )
					end
				return
			end
		end
	end
end

function EMA:RefreshItemUseControls()
	if InCombatLockdown() then
		EMA.refreshItemUseControlsPending = true
		return
	end
	local parentFrame = EMAItemUseFrame
	local positionLeft
	local positionTop
	local itemsPerRow = EMA.db.numberOfItems / EMA.db.numberOfRows
	local row
	local rowLeftModifier
	for iterateItems = 1, EMA.maximumNumberOfItems, 1 do
		local itemContainer = EMA.itemContainer[iterateItems]
		if itemContainer ~= nil then
			local containerButton = itemContainer["container"]
			containerButton:Hide()
		end
	end
	for iterateItems = 1, EMA.db.numberOfItems, 1 do
		local itemContainer = EMA.itemContainer[iterateItems]
		if itemContainer == nil then
			EMA:CreateEMAItemUseItemContainer( iterateItems, parentFrame )
			itemContainer = EMA.itemContainer[iterateItems]
		end
		local containerButton = itemContainer["container"]
		row = math.floor((iterateItems - 1) / itemsPerRow)
		rowLeftModifier = math.floor((iterateItems-1) % itemsPerRow)
		positionLeft = 6 + (EMA.itemSize * rowLeftModifier) + (EMA.db.itemUseHorizontalSpacing * rowLeftModifier)
		local getHeight = EMA.UpdateHeight()
		positionTop = -getHeight - (EMA.db.itemUseVerticalSpacing * 2) - (row * EMA.itemSize) - (row * EMA.db.itemUseVerticalSpacing)
		containerButton:SetWidth( EMA.itemSize )
		containerButton:SetHeight( EMA.itemSize )
		containerButton:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", positionLeft, positionTop )
		containerButton:Show()
	end	
	EMA:UpdateEMAItemUseDimensions()
end

function EMA:UpdateEMAItemUseDimensions()
	local frame = EMAItemUseFrame
	local itemsPerRow = EMA.db.numberOfItems / EMA.db.numberOfRows
	frame:SetWidth( 5 + (EMA.db.itemUseHorizontalSpacing * (3 + itemsPerRow-1)) + (EMA.itemSize * itemsPerRow) )
	local getHeight = EMA.UpdateHeight()
	frame:SetHeight( getHeight + (EMA.itemSize * EMA.db.numberOfRows) + (EMA.db.itemUseVerticalSpacing * EMA.db.numberOfRows) + (EMA.db.itemUseVerticalSpacing * 3))
	frame:SetScale( EMA.db.itemUseScale )
end

-------------------------------------------------------------------------------------------------------------
-- Communications
-------------------------------------------------------------------------------------------------------------

function EMA:EMASendUpdate( button, type, action )
	--EMA:Print("testDataDebug", button, type, action )
	EMA:EMASendCommandToTeam( EMA.COMMAND_ITEMBAR_BUTTON, button, type, action )
end

function EMA:ReceiveButtonData(characterName, button, type, action)
	--EMA:Print("ReceiveButtonDataDebug", button, type, action )
	EMA:AddItemToItemDatabase( button, type, action )
	EMA:SettingsRefresh()
end

function EMA:ReceiveSync(characterName, data)
	--EMA:Print("ReceiveSync", data)
	for id, data in pairs( data ) do 
		--EMA:Print("ID", id, data.button, data.type, data.action )
		EMA:AddItemToItemDatabase( data.button, data.type, data.action )
		EMA:SettingsRefresh()
	end		
end	


-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreateOptions( top )
	-- Get positions.
    local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local mediaHeight = EMAHelperSettings:GetMediaHeight()
	local sliderHeight = EMAHelperSettings:GetSliderHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - (horizontalSpacing * 2)) / 3
	local column2left = left + halfWidth
	local left2 = left + thirdWidth
	local left3 = left + (thirdWidth * 2)
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ITEM_USE_OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.displayOptionsCheckBoxShowItemUse = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SHOW_ITEM_BAR"],
		EMA.SettingsToggleShowItemUse,
		L["SHOW_ITEM_BAR_HELP"]
	)
	--[[
	movingTop = movingTop - checkBoxHeight - verticalSpacing
	EMA.settingsControl.displayOptionsCheckBoxShowItemUseOnlyOnMaster = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left,
		movingTop, 
		L["ONLY_ON_MASTER"],
		EMA.SettingsToggleShowItemUseOnlyOnMaster,
		L["ONLY_ON_MASTER_HELP"]
	)
	]]
	movingTop = movingTop - checkBoxHeight - verticalSpacing
	EMA.settingsControl.displayOptionsCheckBoxShowItemCount = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left,
		movingTop, 
		L["SHOW_ITEM_COUNT"],
		EMA.SettingsToggleShowItemCount,
		L["SHOW_ITEM_COUNT_HELP"]
	)
	movingTop = movingTop - checkBoxHeight - verticalSpacing
	EMA.settingsControl.displayOptionsCheckBoxItemBarsSynchronized = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["KEEP_BARS_SYNCHRONIZED"],
		EMA.SettingsToggleItemBarsSynchronized,
		L["KEEP_BARS_SYNCHRONIZED_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight - verticalSpacing
	EMA.settingsControl.displayOptionsCheckBoxAutoAddQuestItem = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["ADD_QUEST_ITEMS_TO_BAR"],
		EMA.SettingsToggleAutoAddQuestItem,
		L["ADD_QUEST_ITEMS_TO_BAR_HELP"]
	)
	--[[
	movingTop = movingTop - checkBoxHeight - verticalSpacing
	EMA.settingsControl.displayOptionsCheckBoxAutoAddArtifactItem = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["ADD_ARTIFACT_ITEMS"],
		EMA.SettingsToggleAutoAddArtifactItem,
		L["ADD_ARTIFACT_ITEMS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight - verticalSpacing
	EMA.settingsControl.displayOptionsCheckBoxAutoAddSatchelsItem = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["ADD_SATCHEL_ITEMS"],
		EMA.SettingsToggleAutoAddSatchelsItem,
		L["ADD_SATCHEL_ITEMS_HELP"]
	)
	]]
	movingTop = movingTop - checkBoxHeight - verticalSpacing
	EMA.settingsControl.displayOptionsCheckBoxHideClearButton = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["HIDE_BUTTONS"],
		EMA.SettingsToggleHideClearButton,
		L["HIDE_BUTTONS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight - verticalSpacing	
	--[[
	EMA.settingsControl.displayOptionsCheckBoxHideItemUseInCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["HIDE_IN_COMBAT"],
		EMA.SettingsToggleHideItemUseInCombat,
		L["HIDE_IN_COMBAT_HELP_IU"]
	)	
	movingTop = movingTop - checkBoxHeight - verticalSpacing	
	]]
	EMA.settingsControl.displayOptionsItemUseNumberOfItems = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["NUMBER_OF_ITEMS"]
	)
	EMA.settingsControl.displayOptionsItemUseNumberOfItems:SetSliderValues( 1, EMA.maximumNumberOfItems, 1 )
	EMA.settingsControl.displayOptionsItemUseNumberOfItems:SetCallback( "OnValueChanged", EMA.SettingsChangeNumberOfItems )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.displayOptionsItemUseNumberOfRows = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["NUMBER_OF_ROWS"]
	)
	EMA.settingsControl.displayOptionsItemUseNumberOfRows:SetSliderValues( 1, EMA.maximumNumberOfRows, 1 )
	EMA.settingsControl.displayOptionsItemUseNumberOfRows:SetCallback( "OnValueChanged", EMA.SettingsChangeNumberOfRows )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["APPEARANCE_LAYOUT_HEALDER"], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.displayOptionsItemUseScaleSlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SCALE"]
	)
	EMA.settingsControl.displayOptionsItemUseScaleSlider:SetSliderValues( 0.5, 2, 0.01 )
	EMA.settingsControl.displayOptionsItemUseScaleSlider:SetCallback( "OnValueChanged", EMA.SettingsChangeScale )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.displayOptionsItemUseTransparencySlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["TRANSPARENCY"]
	)
	EMA.settingsControl.displayOptionsItemUseTransparencySlider:SetSliderValues( 0, 1, 0.01 )
	EMA.settingsControl.displayOptionsItemUseTransparencySlider:SetCallback( "OnValueChanged", EMA.SettingsChangeTransparency )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.displayOptionsItemUseMediaBorder = EMAHelperSettings:CreateMediaBorder( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop,
		L["BORDER_STYLE"]
	)
	EMA.settingsControl.displayOptionsItemUseMediaBorder:SetCallback( "OnValueChanged", EMA.SettingsChangeBorderStyle )
	EMA.settingsControl.displayOptionsBorderColourPicker = EMAHelperSettings:CreateColourPicker(
		EMA.settingsControl,
		halfWidth,
		column2left + 15,
		movingTop - 15,
		L["BORDER COLOUR"]
	)
	EMA.settingsControl.displayOptionsBorderColourPicker:SetHasAlpha( true )
	EMA.settingsControl.displayOptionsBorderColourPicker:SetCallback( "OnValueConfirmed", EMA.SettingsBorderColourPickerChanged )
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMA.settingsControl.displayOptionsItemUseMediaBackground = EMAHelperSettings:CreateMediaBackground( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop,
		L["BACKGROUND"]
	)
	EMA.settingsControl.displayOptionsItemUseMediaBackground:SetCallback( "OnValueChanged", EMA.SettingsChangeBackgroundStyle )
	EMA.settingsControl.displayOptionsBackgroundColourPicker = EMAHelperSettings:CreateColourPicker(
		EMA.settingsControl,
		halfWidth,
		column2left + 15,
		movingTop - 15,
		L["BG_COLOUR"]
	)
	EMA.settingsControl.displayOptionsBackgroundColourPicker:SetHasAlpha( true )
	EMA.settingsControl.displayOptionsBackgroundColourPicker:SetCallback( "OnValueConfirmed", EMA.SettingsBackgroundColourPickerChanged )	
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["MESSAGES_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["MESSAGE_AREA"] 
	)
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", EMA.SettingsSetMessageArea )
	movingTop = movingTop - dropdownHeight - verticalSpacing
    EMAHelperSettings:CreateHeading( EMA.settingsControl, L["CLEAR_ITEM_BAR"], movingTop, false )
    movingTop = movingTop - headingHeight
    EMA.settingsControl.buttonClearItemBar = EMAHelperSettings:CreateButton(
        EMA.settingsControl,
        headingWidth,
        left,
        movingTop,
        L["CLEAR_ITEM_BAR"],
        EMA.ClearItemUseCommand,
		L["CLEAR_ITEM_BAR_HELP"]
    )
    movingTop = movingTop - buttonHeight - verticalSpacing
	return movingTop
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

local function SettingsCreate()
	EMA.settingsControl = {}
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder		
	)
	local bottomOfOptions = SettingsCreateOptions( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfOptions )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

-------------------------------------------------------------------------------------------------------------
-- Settings Populate.
-------------------------------------------------------------------------------------------------------------

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	-- Values.
	EMA.settingsControl.displayOptionsCheckBoxShowItemUse:SetValue( EMA.db.showItemUse )
	--EMA.settingsControl.displayOptionsCheckBoxShowItemUseOnlyOnMaster:SetValue( EMA.db.showItemUseOnMasterOnly )
	--EMA.settingsControl.displayOptionsCheckBoxHideItemUseInCombat:SetValue( EMA.db.hideItemUseInCombat )
	EMA.settingsControl.displayOptionsCheckBoxShowItemCount:SetValue( EMA.db.showItemCount )
	EMA.settingsControl.displayOptionsItemUseNumberOfItems:SetValue( EMA.db.numberOfItems )
	EMA.settingsControl.displayOptionsItemUseNumberOfRows:SetValue( EMA.db.numberOfRows )
	EMA.settingsControl.displayOptionsCheckBoxAutoAddQuestItem:SetValue( EMA.db.autoAddQuestItemsToBar )
	--EMA.settingsControl.displayOptionsCheckBoxAutoAddArtifactItem:SetValue( EMA.db.autoAddArtifactItemsToBar )
	--EMA.settingsControl.displayOptionsCheckBoxAutoAddSatchelsItem:SetValue( EMA.db.autoAddSatchelsItemsToBar )
	EMA.settingsControl.displayOptionsCheckBoxHideClearButton:SetValue( EMA.db.hideClearButton )
	EMA.settingsControl.displayOptionsCheckBoxItemBarsSynchronized:SetValue( EMA.db.itemBarsSynchronized )
	EMA.settingsControl.displayOptionsItemUseScaleSlider:SetValue( EMA.db.itemUseScale )
	EMA.settingsControl.displayOptionsItemUseTransparencySlider:SetValue( EMA.db.frameAlpha )
	EMA.settingsControl.displayOptionsItemUseMediaBorder:SetValue( EMA.db.borderStyle )
	EMA.settingsControl.displayOptionsItemUseMediaBackground:SetValue( EMA.db.backgroundStyle )
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.displayOptionsBackgroundColourPicker:SetColor( EMA.db.frameBackgroundColourR, EMA.db.frameBackgroundColourG, EMA.db.frameBackgroundColourB, EMA.db.frameBackgroundColourA )
	EMA.settingsControl.displayOptionsBorderColourPicker:SetColor( EMA.db.frameBorderColourR, EMA.db.frameBorderColourG, EMA.db.frameBorderColourB, EMA.db.frameBorderColourA )
	-- State.
	-- Trying to change state in combat lockdown causes taint. Let's not do that. Eventually it would be nice to have a "proper state driven item list",
	-- but this workaround is enough for now.
	if not InCombatLockdown() then
		--EMA.settingsControl.displayOptionsCheckBoxShowItemUseOnlyOnMaster:SetDisabled( not EMA.db.showItemUse )
		--EMA.settingsControl.displayOptionsCheckBoxHideItemUseInCombat:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsCheckBoxShowItemCount:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsItemUseNumberOfItems:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsItemUseNumberOfRows:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsCheckBoxAutoAddQuestItem:SetDisabled( not EMA.db.showItemUse )
		--EMA.settingsControl.displayOptionsCheckBoxAutoAddArtifactItem:SetDisabled( not EMA.db.showItemUse )
		--EMA.settingsControl.displayOptionsCheckBoxAutoAddSatchelsItem:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsCheckBoxHideClearButton:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsCheckBoxItemBarsSynchronized:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsItemUseScaleSlider:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsItemUseTransparencySlider:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsItemUseMediaBorder:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsItemUseMediaBackground:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.dropdownMessageArea:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsBackgroundColourPicker:SetDisabled( not EMA.db.showItemUse )
		EMA.settingsControl.displayOptionsBorderColourPicker:SetDisabled( not EMA.db.showItemUse )		
		if EMA.itemUseCreated == true then
			EMA:RefreshItemUseControls()
	--		EMA:SettingsUpdateBorderStyle()
			EMA:SetItemUseVisibility()
			EMA:UpdateItemsInBar()
			EMA:UpdateHeight()
		end
	else
		EMA.updateSettingsAfterCombat = true
	end
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleShowItemUse( event, checked )
	EMA.db.showItemUse = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHideItemUseInCombat( event, checked )
	EMA.db.hideItemUseInCombat = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleShowItemCount( event, checked )
	EMA.db.showItemCount = checked 
	EMA:SettingsRefresh()
end	
	
function EMA:SettingsToggleShowItemUseOnlyOnMaster( event, checked )
	EMA.db.showItemUseOnMasterOnly = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoAddQuestItem( event, checked )
	EMA.db.autoAddQuestItemsToBar = checked
	EMA:SettingsRefresh()
end
--[[
function EMA:SettingsToggleAutoAddArtifactItem( event, checked )
	EMA.db.autoAddArtifactItemsToBar = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoAddSatchelsItem( event, checked )
	EMA.db.autoAddSatchelsItemsToBar = checked
	EMA:SettingsRefresh()
end
]]
function EMA:SettingsToggleHideClearButton(event, checked )
	EMA.db.hideClearButton = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleItemBarsSynchronized( event, checked )
	EMA.db.itemBarsSynchronized = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeNumberOfItems( event, value )
	EMA.db.numberOfItems = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeNumberOfRows( event, value )
	EMA.db.numberOfRows= tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeScale( event, value )
	EMA.db.itemUseScale = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeTransparency( event, value )
	EMA.db.frameAlpha = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeBorderStyle( event, value )
	EMA.db.borderStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeBackgroundStyle( event, value )
	EMA.db.backgroundStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:OnMasterChanged( message, characterName )
	EMA:SettingsRefresh()
end

function EMA:SettingsBackgroundColourPickerChanged( event, r, g, b, a )
	EMA.db.frameBackgroundColourR = r
	EMA.db.frameBackgroundColourG = g
	EMA.db.frameBackgroundColourB = b
	EMA.db.frameBackgroundColourA = a
	EMA:SettingsRefresh()
end

function EMA:SettingsBorderColourPickerChanged( event, r, g, b, a )
	EMA.db.frameBorderColourR = r
	EMA.db.frameBorderColourG = g
	EMA.db.frameBorderColourB = b
	EMA.db.frameBorderColourA = a
	EMA:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
	-- Create the item use frame.
	CreateEMAItemUseFrame()
	EMA:RefreshItemUseControls()
--	EMA:SettingsUpdateBorderStyle()
	EMA:SetItemUseVisibility()
	EMA:UpdateItemsInBar()
	EMA.sharedInvData = {}
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "PLAYER_REGEN_ENABLED" )
	EMA:RegisterEvent( "PLAYER_REGEN_DISABLED" )
	EMA:RegisterEvent( "BAG_UPDATE_DELAYED" )
	--EMA:RegisterEvent( "ITEM_PUSH" ) -- Using Bag Update this seems to be running a little more then it did < 8.0.3
	EMA:RegisterEvent( "PLAYER_ENTERING_WORLD" )
	EMA:RegisterEvent( "UNIT_QUEST_LOG_CHANGED", "QUEST_UPDATE" )
	EMA.SharedMedia.RegisterCallback( EMA, "LibSharedMedia_Registered" )
    EMA.SharedMedia.RegisterCallback( EMA, "LibSharedMedia_SetGlobal" )	
	EMA:RegisterMessage( EMAApi.MESSAGE_TEAM_MASTER_CHANGED, "OnMasterChanged" )
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	EMA:RefreshItemUseControls()
	EMA:UpdateItemsInBar()
	EMA.keyBindingFrame = CreateFrame( "Frame", nil, UIParent )
	EMA:RegisterEvent( "UPDATE_BINDINGS" )		
	EMA:UPDATE_BINDINGS()
	LibActionButton.RegisterCallback( EMA, "OnButtonContentsChanged", "OnButtonContentsChanged" )
	LibActionButton.RegisterCallback( EMA, "OnButtonUpdate", "OnButtonUpdate" )
	LibActionButton.RegisterCallback( EMA, "OnButtonState", "OnButtonState" )
	LibActionButton.RegisterCallback( EMA, "OnButtonUsable", "OnButtonUsable" )
	EMA:SecureHook( GameTooltip , "SetHyperlink", "AddTooltipInfo" )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.showItemUse = settings.showItemUse
		--EMA.db.showItemUseOnMasterOnly = settings.showItemUseOnMasterOnly
		--EMA.db.hideItemUseInCombat = settings.hideItemUseInCombat
		EMA.db.showItemCount = settings.showItemCount
		EMA.db.borderStyle = settings.borderStyle
		EMA.db.backgroundStyle = settings.backgroundStyle
		EMA.db.itemUseScale = settings.itemUseScale
		EMA.db.itemUseTitleHeight = settings.itemUseTitleHeight
		EMA.db.itemUseVerticalSpacing = settings.itemUseVerticalSpacing
		EMA.db.itemUseHorizontalSpacing = settings.itemUseHorizontalSpacing
		EMA.db.autoAddQuestItemsToBar = settings.autoAddQuestItemsToBar
		--EMA.db.autoAddArtifactItemsToBar = settings.autoAddArtifactItemsToBar
		--EMA.db.autoAddSatchelsItemsToBar = settings.autoAddSatchelsItemsToBar
		EMA.db.hideClearButton = settings.hideClearButton
		EMA.db.itemBarsSynchronized = settings.itemBarsSynchronized
		EMA.db.numberOfItems = settings.numberOfItems
		EMA.db.numberOfRows = settings.numberOfRows
		EMA.db.messageArea = settings.messageArea
		if EMA.db.itemBarsSynchronized == true then
		 EMA.db.itemsAdvanced = EMAUtilities:CopyTable( settings.itemsAdvanced )
		end
		EMA.db.frameAlpha = settings.frameAlpha
		EMA.db.framePoint = settings.framePoint
		EMA.db.frameRelativePoint = settings.frameRelativePoint
		EMA.db.frameXOffset = settings.frameXOffset
		EMA.db.frameYOffset = settings.frameYOffset
		EMA.db.frameBackgroundColourR = settings.frameBackgroundColourR
		EMA.db.frameBackgroundColourG = settings.frameBackgroundColourG
		EMA.db.frameBackgroundColourB = settings.frameBackgroundColourB
		EMA.db.frameBackgroundColourA = settings.frameBackgroundColourA
		EMA.db.frameBorderColourR = settings.frameBorderColourR
		EMA.db.frameBorderColourG = settings.frameBorderColourG
		EMA.db.frameBorderColourB = settings.frameBorderColourB
		EMA.db.frameBorderColourA = settings.frameBorderColourA				
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

function EMA:PLAYER_REGEN_ENABLED()
	if EMA.db.hideItemUseInCombat == true then
		EMA:SetItemUseVisibility()
	end
	if EMA.refreshItemUseControlsPending == true then
		EMA:RefreshItemUseControls()
		EMA.refreshItemUseControlsPending = false
	end
	if EMA.refreshUpdateItemsInBarPending == true then
		EMA:UpdateItemsInBar()
		EMA.refreshUpdateItemsInBarPending = false
	end
	if EMA.refreshUpdateBindingsPending == true then
		EMA:UPDATE_BINDINGS()
		EMA.refreshUpdateBindingsPending = false
	end
	if EMA.updateSettingsAfterCombat == true then
		EMA:SettingsRefresh()
		EMA.updateSettingsAfterCombat = false
	end 	
end

function EMA:PLAYER_REGEN_DISABLED()
	if EMA.db.hideItemUseInCombat == true then
		EMAItemUseFrame:Hide()
	end
end

function EMA:BAG_UPDATE_DELAYED()
	if EMA.db.showItemUse == false and not InCombatLockdown() then
		return
	end
	if EMA.db.autoAddQuestItemsToBar == true then
		EMA:CheckForQuestItemAndAddToBar()
	end	
	if EMA.db.showItemCount == true then 
		EMA:GetEMAItemCount()
	end
	--[[
	if EMA.db.autoAddSatchelsItemsToBar == true then
		EMA:CheckForSatchelsItemAndAddToBar()
	end	
	]]
end

function EMA:QUEST_UPDATE()
	if not InCombatLockdown() then
		EMA:UpdateQuestItemsInBar()
	end
end

-- More then Likey to be removed! using bag scan
function EMA:ITEM_PUSH()
	if EMA.db.showItemUse == false then
		return
	end
	if EMA.db.autoAddQuestItemsToBar == true then
		EMA:ScheduleTimer( "CheckForQuestItemAndAddToBar", 1 )
	end
	--[[
	if EMA.db.autoAddArtifactItemsToBar == true then
		EMA:ScheduleTimer( "CheckForArtifactItemAndAddToBar", 1 )
	end
	if EMA.db.autoAddSatchelsItemsToBar == true then
		EMA:ScheduleTimer( "CheckForSatchelsItemAndAddToBar", 1 )
	end	
	]]
end

function EMA:PLAYER_ENTERING_WORLD( event, ... )
	EMA:ScheduleTimer( "GetEMAItemCount", 0.5 )	
end		

local function GetMaxItemCountFromItemID(itemID)
	if itemID == nil then 
		return 0 
	end
	if EMA.sharedInvData == nil then 
		return 0
	end	
	local count = 0
	for itemName, data in pairs( EMA.sharedInvData ) do
		for id, itemData in pairs( data ) do
			if itemID == itemData.item then
				count = count + itemData.itemCount
			end	
		end	
	end	
	return count
end


function EMA:AddTooltipInfo( toolTip, itemID )
	if EMA.db.showItemUse == false or EMA.db.showItemCount == false then
		return
	end
	EMA:AddToTooltip( toolTip, itemID )
	toolTip:Show()
end

function EMA:AddToTooltip(toolTip, itemID)
	local totalCount = 0
	if itemID ~= nil then
		local count = GetMaxItemCountFromItemID(itemID)
		if count > 0 then 
			toolTip:AddLine(" ")
			toolTip:AddDoubleLine(L["TEAM_BAGS"], L["BAG_BANK"], 1,0.82,0,1,0.82,0)
			for characterName, position in EMAApi.TeamList() do
				local count, bankCount = EMA:GetItemCountFromItemID( characterName, itemID )
				if count ~= nil then
				toolTip:AddDoubleLine(Ambiguate(characterName, "none"), count..L[" "]..L["("]..bankCount..L[")"], 1,1,1,1,1,1)
					totalCount = totalCount + count
				end
			end
		end
	end		
	if totalCount > 1 then
		toolTip:AddLine(" ")
		toolTip:AddDoubleLine(L["TOTAL"], totalCount, 1,0.82,0,1,1,1,1)
	end					
end		

function EMA:GetEMAItemCount()
	if EMA.db.showItemUse == false or EMA.db.showItemCount == false then
		return
	end
	local iteminfo = {}
	for iterateItems , itemInfo in pairs( EMA.db.itemsAdvanced ) do
		local itemID = itemInfo.action
		if itemID ~= nil then
			local itemName = GetItemInfo( itemID )
			local countBags = GetItemCount( itemID )
			local countTotal = GetItemCount( itemID , true)
			local countBank = ( countTotal - countBags )
			if itemName ~= nil then	
				iteminfo[itemName] = {}
				table.insert( iteminfo[itemName], { itemID = itemID, countBags = countBags, countBank = countBank } )
			end	
		end
	end
	EMA:EMASendCommandToTeam( EMA.COMMAND_ITEM_COUNT, iteminfo )
end

function EMA:ReceiveItemCount( characterName, dataTable )
	if InCombatLockdown() then
		return
    end
	--EMA:Print("ReceiveItemCount", characterName )
	for itemName, info in pairs( dataTable ) do
		for i, data in pairs( info ) do
		if EMA.sharedInvData[characterName..itemName] == nil then
			EMA.sharedInvData[characterName..itemName] = {}
		else
			EMAUtilities:ClearTable( EMA.sharedInvData[characterName..itemName] )
		end
		table.insert(EMA.sharedInvData[characterName..itemName], {name = characterName, item = data.itemID, itemCount = data.countBags, bankCount = data.countBank } )
		end
	end
	LibActionButton:UpdateAllButtons()	
end

function EMA:GetItemCountFromItemID( characterName, itemID )
	if EMA.db.showItemUse == false or EMA.db.showItemCount == false then
		return
	end
	local count = nil 
	local countBank = nil
	for itemName, data in pairs( EMA.sharedInvData ) do
		for id, itemData in pairs( data ) do
			--EMA:Print("testaaa", itemID, "vs", itemData.item)
			if itemID == itemData.item and characterName == itemData.name then
				--EMA:Print("Found", characterName, itemData.itemCount )
				count = itemData.itemCount
				countBank = itemData.bankCount
			end	
		end
	end
	return count, countBank
end	

function EMA:UPDATE_BINDINGS()
	if InCombatLockdown() then
		EMA.refreshUpdateBindingsPending = true
		return
    end
	ClearOverrideBindings( EMA.keyBindingFrame )
	for iterateItems = 1, EMA.maximumNumberOfItems, 1 do
		local containerButtonName = EMA.globalFramePrefix.."ContainerButton"..iterateItems
		local key1, key2 = GetBindingKey( "ITEMUSE"..iterateItems )
		if key1 then
			SetOverrideBindingClick( EMA.keyBindingFrame, false, key1, containerButtonName ) 
		end
		if key2 then 
			SetOverrideBindingClick( EMA.keyBindingFrame, false, key2, containerButtonName ) 
		end	
	end
end

function EMA:LibSharedMedia_Registered()
end

function EMA:LibSharedMedia_SetGlobal()
end

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if EMAApi.IsCharacterInTeam(characterName) == true then  	
		if commandName == EMA.COMMAND_ITEMBAR_BUTTON then
			EMA:ReceiveButtonData( characterName, ... )
		end
		if commandName == EMA.COMMAND_ITEMUSE_SYNC then
			EMA:ReceiveSync( characterName, ... )
		end
		if commandName == EMA.COMMAND_ITEM_COUNT then
			EMA:ReceiveItemCount( characterName, ... )
		end
	end	
end	

--EMA QUEST API
EMAApi.GetMaxItemCountFromItemID = GetMaxItemCountFromItemID
--EMAApi.QuestTest = EMA.CheckForSatchelsItemAndAddToBar