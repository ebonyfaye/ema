-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: MIT License 2018 Jennifer Cally							--
--																					--
--				Some Code Used from "EMA" that is 								--
--				Released under the MIT License 										--
--				"EMA" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --


-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Guild", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Get the EMA Utilities Library.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local LibBagUtils = LibStub:GetLibrary( "LibBagUtils-1.0" )
local AceGUI = LibStub( "AceGUI-3.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Guild"
EMA.settingsDatabaseName = "GuildProfileDB"
EMA.chatCommand = "ema-guild"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["INTERACTION"]
EMA.moduleDisplayName = L["GUILD"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\GuildIcon.tga"
-- order
EMA.moduleOrder = 20

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		messageArea = EMAApi.DefaultMessageArea(),
		showEMAGuildWindow = false,
		GuildBoEItems = false,
		GuildCRItems = false,
		autoGuildItemsList = {},
		adjustMoneyWithGuildBank = false,
		goldAmountToKeepOnToon = 250,
	},
}

-- Configuration.
function EMA:GetConfiguration()
	local configuration = {
		name = EMA.moduleDisplayName,
		handler = EMA,
		type = 'group',
		childGroups  = "tab",
		get = "EMAConfigurationGetSetting",
		set = "EMAConfigurationSetSetting",
		args = {
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_ALL_SETTINGS"],
				usage = "/EMA-Guild push",
				get = false,
				set = "EMASendSettings",
				guiHidden = true,
			},
		},
	}
	return configuration
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
-- Popup Dialogs.
-------------------------------------------------------------------------------------------------------------

local function InitializePopupDialogs()
	StaticPopupDialogs["EMAGuild_CONFIRM_REMOVE_Guild_ITEMS"] = {
        text = L["REMOVE_GUILD_LIST"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function()
			EMA:RemoveItem()
		end,
    }
end

-------------------------------------------------------------------------------------------------------------
-- GBank Tab Dropdown Stuff
-------------------------------------------------------------------------------------------------------------

EMA.simpleAreaList = {}
EMA.simpleGrpAreaList = {}

function EMA:TabAreaList()
	return pairs( EMA.simpleAreaList )
end

function EMA:RefreshTabDropDownList()
	EMAUtilities:ClearTable( EMA.simpleAreaList )
	for index = 1, GetNumGuildBankTabs() do 
		EMA.simpleAreaList[index] = L["GUILDTAB"]..L[" "]..index	
	end
	table.sort( EMA.simpleAreaList )
	EMA.settingsControl.tabNumListDropDownList:SetList( EMA.simpleAreaList )
end

------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	EMA.autoGuildItemLink = nil
	EMA.autoGuildBankTab = 1
	EMA.GroupName = EMAApi.AllTag()
	EMA.putItemsInGB = {}
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialse the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "GUILDBANKFRAME_OPENED" ) -- Temp!
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	EMA:RegisterMessage( EMAApi.GROUP_LIST_CHANGED , "OnGroupAreasChanged" )
	-- Update DropDownList
	EMA:ScheduleTimer("RefreshTabDropDownList", 1 )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
	-- AceHook-3.0 will tidy up the hooks for us. 
end

function EMA:SettingsCreate()
	EMA.settingsControl = {}
	-- Create the settings panel.
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder		
	)
	local bottomOfInfo = EMA:SettingsCreateGuild( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsCreateGuild( top )
	local buttonControlWidth = 85
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local GuildWidth = headingWidth
	local movingTop = top
	local dropBoxWidth = (headingWidth - horizontalSpacing) / 4	
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["GUILD_LIST_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxShowEMAGuildWindow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["GUILD_LIST"],
		EMA.SettingsToggleShowEMAGuildWindow,
		L["GUILD_LIST_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.GuildItemsHighlightRow = 1
	EMA.settingsControl.GuildItemsOffset = 1
	local list = {}
	list.listFrameName = "EMAGuildIteamsSettingsFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = GuildWidth
	list.rowHeight = 15
	list.rowsToDisplay = 10
	list.columnsToDisplay = 3
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 40
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 30
	list.columnInformation[2].alignment = "LEFT"
	list.columnInformation[3] = {}
	list.columnInformation[3].width = 30
	list.columnInformation[3].alignment = "LEFT"	
	list.scrollRefreshCallback = EMA.SettingsScrollRefresh
	list.rowClickCallback = EMA.SettingsGuildItemsRowClick
	EMA.settingsControl.GuildItems = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.GuildItems )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.GuildItemsButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left, 
		movingTop,
		L["REMOVE"],
		EMA.SettingsGuildItemsRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ADD_ITEMS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.GuildItemsEditBoxGuildItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["ITEM_DROP"]
	)
	EMA.settingsControl.GuildItemsEditBoxGuildItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedGuildItem )
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.tabNumListDropDownList = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		dropBoxWidth,	
		left,
		movingTop,
		L["GB_TAB_LIST"]
	)
	EMA.settingsControl.tabNumListDropDownList:SetList( EMA.TabAreaList() )
	EMA.settingsControl.tabNumListDropDownList:SetCallback( "OnValueChanged",  EMA.GBTabDropDownList )
	--Group
	EMA.settingsControl.GuildItemsEditBoxGuildTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		dropBoxWidth,	
		left + dropBoxWidth + horizontalSpacing,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetCallback( "OnValueChanged",  EMA.GroupListDropDownList )
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.GuildItemsButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left, 
		movingTop, 
		L["ADD"],
		EMA.SettingsGuildItemsAddClick
	)
	movingTop = movingTop -	buttonHeight		
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["GB_OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
--[[	
	EMA.settingsControl.checkBoxGuildBoEItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["GUILD_BOE_ITEMS"],
		EMA.SettingsToggleGuildBoEItems,
		L["GUILD_BOE_ITEMS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxGuildCRItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["GUILD_REAGENTS"],
		EMA.SettingsToggleGuildCRItems,
		L["GUILD_REAGENTS_HELP"]
	)
	
	movingTop = movingTop - checkBoxHeight
]]	
	EMA.settingsControl.checkBoxAdjustMoneyOnToonViaGuildBank = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["GB_GOLD"],
		EMA.SettingsToggleAdjustMoneyOnToonViaGuildBank,
		L["GB_GOLD_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["GOLD_TO_KEEP"]
	)
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetCallback( "OnEnterPressed", EMA.EditBoxChangedGoldAmountToLeaveOnToon )
	movingTop = movingTop - editBoxHeight	
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
	return movingTop	
end


-------------------------------------------------------------------------------------------------------------
-- Settings Callbacks.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsScrollRefresh()
	FauxScrollFrame_Update(
		EMA.settingsControl.GuildItems.listScrollFrame, 
		EMA:GetGuildItemsMaxPosition(),
		EMA.settingsControl.GuildItems.rowsToDisplay, 
		EMA.settingsControl.GuildItems.rowHeight
	)
	EMA.settingsControl.GuildItemsOffset = FauxScrollFrame_GetOffset( EMA.settingsControl.GuildItems.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.GuildItems.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[3].textString:SetText( "" )
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[3].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.GuildItemsOffset
		if dataRowNumber <= EMA:GetGuildItemsMaxPosition() then
			-- Put data information into columns.
			local GuildItemsInformation = EMA:GetGuildItemsAtPosition( dataRowNumber )
			EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[1].textString:SetText( GuildItemsInformation.name )
			EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[2].textString:SetText( GuildItemsInformation.GBTab )
			EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[3].textString:SetText( GuildItemsInformation.tag )
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.GuildItemsHighlightRow then
				EMA.settingsControl.GuildItems.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingsGuildItemsRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.GuildItemsOffset + rowNumber <= EMA:GetGuildItemsMaxPosition() then
		EMA.settingsControl.GuildItemsHighlightRow = EMA.settingsControl.GuildItemsOffset + rowNumber
		EMA:SettingsScrollRefresh()
	end
end

function EMA:SettingsGuildItemsRemoveClick( event )
	StaticPopup_Show( "EMAGuild_CONFIRM_REMOVE_Guild_ITEMS" )
end

function EMA:SettingsEditBoxChangedGuildItem( event, text )
	EMA.autoGuildItemLink = text
	EMA:SettingsRefresh()
end

function EMA:GBTabDropDownList (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.autoGuildBankTab = value
	EMA:SettingsRefresh()
end

function EMA:GroupListDropDownList (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.GroupName = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsGuildItemsAddClick( event )
	if EMA.autoGuildItemLink ~= nil and EMA.autoGuildBankTab ~= nil and EMA.GroupName ~= nil then
		EMA:AddItem( EMA.autoGuildItemLink, EMA.autoGuildBankTab, EMA.GroupName )
		EMA.autoGuildItemLink = nil
		EMA:SettingsRefresh()
	end
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:OnGroupAreasChanged( message )
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleShowEMAGuildWindow( event, checked )
	EMA.db.showEMAGuildWindow = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleGuildBoEItems(event, checked )
	EMA.db.GuildBoEItems = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleGuildCRItems(event, checked )
	EMA.db.GuildCRItems = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAdjustMoneyOnToonViaGuildBank( event, checked )
	EMA.db.adjustMoneyWithGuildBank = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAdjustMoneyWithMasterOnGuild( event, checked )
	EMA.db.adjustMoneyWithMasterOnGuild = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedGoldAmountToLeaveOnToon( event, text )
	EMA.db.goldAmountToKeepOnToon = tonumber( text )
	if EMA.db.goldAmountToKeepOnToon == nil then
		EMA.db.goldAmountToKeepOnToon = 0
	end
	EMA:SettingsRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.messageArea = settings.messageArea
		EMA.db.showEMAGuildWindow = settings.showEMAGuildWindow
		EMA.db.GuildBoEItems = settings.GuildBoEItems
		EMA.db.GuildCRItems = settings.GuildCRItems
		EMA.db.autoGuildItemsList = EMAUtilities:CopyTable( settings.autoGuildItemsList )
		EMA.db.adjustMoneyWithGuildBank = settings.adjustMoneyWithGuildBank
		EMA.db.goldAmountToKeepOnToon = settings.goldAmountToKeepOnToon
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	EMA.settingsControl.checkBoxShowEMAGuildWindow:SetValue( EMA.db.showEMAGuildWindow )
--	EMA.settingsControl.checkBoxGuildBoEItems:SetValue( EMA.db.GuildBoEItems )
--	EMA.settingsControl.checkBoxGuildCRItems:SetValue( EMA.db.GuildCRItems )
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.checkBoxAdjustMoneyOnToonViaGuildBank:SetValue( EMA.db.adjustMoneyWithGuildBank )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetText( tostring( EMA.db.goldAmountToKeepOnToon ) )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetDisabled( not EMA.db.adjustMoneyWithGuildBank )
	EMA.settingsControl.GuildItemsEditBoxGuildItem:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetDisabled( not EMA.db.showEMAGuildWindow )	
	EMA.settingsControl.tabNumListDropDownList:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.GuildItemsButtonRemove:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.GuildItemsButtonAdd:SetDisabled( not EMA.db.showEMAGuildWindow )	
	EMA:SettingsScrollRefresh()

end

--Comms not sure if we going to use comms here.
-- A EMA command has been received.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if characterName == self.characterName then
		return
	end
end

-------------------------------------------------------------------------------------------------------------
-- Guild functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:GetGuildItemsMaxPosition()
	return #EMA.db.autoGuildItemsList
end

function EMA:GetGuildItemsAtPosition( position )
	return EMA.db.autoGuildItemsList[position]
end

function EMA:AddItem( itemLink, GBTab, itemTag )
	--EMA:Print("testDBAdd", itemLink, GBTab, itemTag )
	-- Get some more information about the item.
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemLink )
	-- If the item could be found.
	if name ~= nil then
		local itemInformation = {}
		itemInformation.link = link
		itemInformation.name = name
		itemInformation.GBTab = GBTab
		itemInformation.tag = itemTag
			table.insert( EMA.db.autoGuildItemsList, itemInformation )
			EMA:SettingsRefresh()			
			EMA:SettingsGuildItemsRowClick( 1, 1 )
	end	
end

function EMA:RemoveItem()
	table.remove( EMA.db.autoGuildItemsList, EMA.settingsControl.GuildItemsHighlightRow )
	EMA:SettingsRefresh()
	EMA:SettingsGuildItemsRowClick( 1, 1 )		
end


function EMA:GUILDBANKFRAME_OPENED()
	if 	EMA.db.showEMAGuildWindow == true then
		EMA:AddToGuildBankFromList()
	end
	if EMA.db.adjustMoneyWithGuildBank == true then
		AddGoldToGuildBank()
	end
end

function EMA:AddToGuildBankFromList()
	local delay = 1.5
	for position, itemInformation in pairs( EMA.db.autoGuildItemsList ) do
		if EMAApi.IsCharacterInGroup(EMA.characterName, itemInformation.tag ) == true then
			--EMA:Print("AddToGB", position, itemInformation.name, itemInformation.GBTab )
			name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(itemInformation.GBTab)
			if canDeposit == true then
				for bag,slot,link in LibBagUtils:Iterate("BAGS", itemInformation.link ) do
					if bag ~= nil then
						delay = delay + 1.5
						EMA:ScheduleTimer("PlaceItemInGuildBank", delay, bag, slot, itemInformation.GBTab )
					end
				end
			end
		end
	end
end

function EMA:SelectBankTab( tab )
	if GetCurrentGuildBankTab() == tab then
	else
		GuildBankTab_OnClick(_G["GuildBankTab" .. tab], "LeftButton", tab )
	end
end

function EMA:PlaceItemInGuildBank(bag, slot, tab)
	if GuildBankFrame:IsVisible() == true then
		EMA:SelectBankTab( tab )				
		if GetCurrentGuildBankTab() == tab then
			PickupContainerItem( bag,slot )
			UseContainerItem( bag,slot )
		end	
	end
end

---------
function EMA:GuildBoEItems()
	if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
		return
	end
	for index, character in EMAApi.TeamListOrderedOnline() do
		--EMA:Print("Team", character )
		local teamCharacterName = ( Ambiguate( character, "short" ) )
		local GuildPlayersName = GetUnitName("NPC")
		if GuildPlayersName == teamCharacterName then
			if EMAApi.IsCharacterTheMaster(character) == true and EMAUtilities:CheckIsFromMyRealm(character) == true then
				for bag,slot,link in LibBagUtils:Iterate("BAGS") do
					if bag ~= nil then			
						local _, _, locked, quality = GetContainerItemInfo(bag, slot)
						-- quality is Uncommon (green) to  Epic (purple) 2 - 3 - 4
						if quality ~= nil and locked == false then
							if quality >= 2 and quality <= 4 then 
								-- tooltips scan is the olny way to find if the item is BoE in bags!
								local isBoe = EMAUtilities:ToolTipBagScaner(link, bag, slot)
								-- if the item is boe then add it to the Guild list!
								if isBoe ~= ITEM_SOULBOUND then
									--EMA:Print("test21", link, locked)
									for iterateGuildSlots = 1, (MAX_Guild_ITEMS - 1) do
										if GetGuildPlayerItemLink( iterateGuildSlots ) == nil then
											PickupContainerItem( bag, slot )
											ClickGuildButton( iterateGuildSlots )
										end	
									end
								end	
							end	
						end	
					end	
				end
			end
		end
	end		
end

function EMA:GuildCRItems()
	if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
		return
	end
	for index, character in EMAApi.TeamListOrderedOnline() do
		--EMA:Print("Team", character )
		local teamCharacterName = ( Ambiguate( character, "short" ) )
		local GuildPlayersName = GetUnitName("NPC")
		if GuildPlayersName == teamCharacterName then
			if EMAApi.IsCharacterTheMaster(character) == true and EMAUtilities:CheckIsFromMyRealm(character) == true then
				for bag,slot,itemLink in LibBagUtils:Iterate("BAGS") do
					if itemLink then
						-- using legion CraftingReagent API, as tooltip massess up some "items"
						local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,isCraftingReagent = GetItemInfo(itemLink)
						if isCraftingReagent == true then
							--EMA:Print("GuildCraftingGoods", isCraftingReagent, itemLink)
							-- tooltips scan is the olny way to find if the item is BOP in bags!
							local isBop = EMAUtilities:TooltipScaner(itemLink)
							--EMA:Print("testBOP", itemLink, isBop)
							if isBop ~= ITEM_BIND_ON_PICKUP then
							--EMA:Print("AddToGuild", itemLink)
								for iterateGuildSlots = 1, (MAX_Guild_ITEMS - 1) do
									if GetGuildPlayerItemLink( iterateGuildSlots ) == nil then
										PickupContainerItem( bag, slot )
										ClickGuildButton( iterateGuildSlots )
									end	
								end	
							end	
						end	
					end	
				end
			end
		end
	end		
end

function AddGoldToGuildBank()
	if not CanWithdrawGuildBankMoney() then
		return
	end
	local moneyToKeepOnToon = tonumber( EMA.db.goldAmountToKeepOnToon ) * 10000
	local moneyOnToon = GetMoney()
	local moneyToDepositOrWithdraw = moneyOnToon - moneyToKeepOnToon
	--EMA:Print(" testa", moneyToDepositOrWithdraw )
	if moneyToDepositOrWithdraw == 0 then
		return
	end
	if moneyToDepositOrWithdraw > 0 then
	--	EMA:Print(" test", moneyToDepositOrWithdraw )
		--DepositGuildBankMoney( moneyToDepositOrWithdraw )
		EMA:ScheduleTimer("SendMoneyToGuild", 0.5, moneyToDepositOrWithdraw)
	else
		local takeoutmoney = -1 * moneyToDepositOrWithdraw
	--	EMA:Print("takeout", takeoutmoney)
		EMA:ScheduleTimer("TakeMoneyOut", 0.5, takeoutmoney )
	end
end


function EMA:SendMoneyToGuild( money )
	DepositGuildBankMoney( money )
end

function EMA:TakeMoneyOut( money )
	WithdrawGuildBankMoney( money )	
end