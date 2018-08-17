-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: MIT License 2018 Jennifer Cally							--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --
-- Create the addon using AceAddon-3.0 and embed some libraries.

local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Trade", 
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
EMA.moduleName = "Trade"
EMA.settingsDatabaseName = "TradeProfileDB"
EMA.chatCommand = "ema-trade"

local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["INTERACTION"]
EMA.moduleDisplayName = L["TRADE"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\TradeIcon.tga"
-- order
EMA.moduleOrder = 10

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		messageArea = EMAApi.DefaultMessageArea(),
		showEMATradeWindow = false,
		tradeBoEItems = false,
		tradeCRItems = false,
		autoTradeItemsList = {},
		adjustMoneyWithMasterOnTrade = false,
		goldAmountToKeepOnToonTrade = 200,
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
				usage = "/EMA-trade push",
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
	StaticPopupDialogs["EMATRADE_CONFIRM_REMOVE_TRADE_ITEMS"] = {
        text = L["REMOVE_TRADE_LIST"],
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
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	EMA.autoTradeItemLink = nil
	EMA.autoTradeItemTag = EMAApi.AllTag()
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialse the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "TRADE_SHOW" )
	EMA:RegisterEvent( "TRADE_CLOSED" ) -- Unsued but we keep it for now!
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	EMA:RegisterMessage( EMAApi.GROUP_LIST_CHANGED , "OnGroupAreasChanged" )
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
	local bottomOfInfo = EMA:SettingsCreateTrade( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsCreateTrade( top )
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
	local tradeWidth = headingWidth
	local dropBoxWidth = (headingWidth - horizontalSpacing) / 4
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["TRADE_LIST_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxShowEMATradeWindow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["TRADE_LIST"],
		EMA.SettingsToggleShowEMATradeWindow,
		L["TRADE_LIST_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.tradeItemsHighlightRow = 1
	EMA.settingsControl.tradeItemsOffset = 1
	local list = {}
	list.listFrameName = "EMATradeIteamsSettingsFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = tradeWidth
	list.rowHeight = 15
	list.rowsToDisplay = 10
	list.columnsToDisplay = 2
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 70
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 30
	list.columnInformation[2].alignment = "LEFT"	
	list.scrollRefreshCallback = EMA.SettingsScrollRefresh
	list.rowClickCallback = EMA.SettingsTradeItemsRowClick
	EMA.settingsControl.tradeItems = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.tradeItems )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.tradeItemsButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left, 
		movingTop,
		L["REMOVE"],
		EMA.SettingsTradeItemsRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ADD_ITEMS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.tradeItemsEditBoxTradeItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["ITEM_DROP"]
	)

	EMA.settingsControl.tradeItemsEditBoxTradeItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedTradeItem )
	movingTop = movingTop - editBoxHeight
	EMA.settingsControl.tradeItemsEditBoxToonTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		dropBoxWidth,	
		left,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.tradeItemsEditBoxToonTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.tradeItemsEditBoxToonTag:SetCallback( "OnValueChanged",  EMA.TradeGroupListDropDownList )

	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.tradeItemsButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left, 
		movingTop, 
		L["ADD"],
		EMA.SettingsTradeItemsAddClick
	)
	movingTop = movingTop -	buttonHeight		
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["TRADE_OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxTradeBoEItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["TRADE_BOE_ITEMS"],
		EMA.SettingsToggleTradeBoEItems,
		L["TRADE_BOE_ITEMS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxTradeCRItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["TRADE_REAGENTS"],
		EMA.SettingsToggleTradeCRItems,
		L["TRADE_REAGENTS_HELP"]
	)	
	-- Trade Gold! Keep
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxAdjustMoneyWithMasterOnTrade = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["TRADE_GOLD"],
		EMA.SettingsToggleAdjustMoneyWithMasterOnTrade,
		L["TRADE_GOLD_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToonTrade = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["GOLD_TO_KEEP"]
	)	
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToonTrade:SetCallback( "OnEnterPressed", EMA.EditBoxChangedGoldAmountToLeaveOnToonTrade )
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
		EMA.settingsControl.tradeItems.listScrollFrame, 
		EMA:GetTradeItemsMaxPosition(),
		EMA.settingsControl.tradeItems.rowsToDisplay, 
		EMA.settingsControl.tradeItems.rowHeight
	)
	EMA.settingsControl.tradeItemsOffset = FauxScrollFrame_GetOffset( EMA.settingsControl.tradeItems.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.tradeItems.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.tradeItems.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.tradeItemsOffset
		if dataRowNumber <= EMA:GetTradeItemsMaxPosition() then
			-- Put data information into columns.
			local tradeItemsInformation = EMA:GetTradeItemsAtPosition( dataRowNumber )
			EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[1].textString:SetText( tradeItemsInformation.name )
			EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[2].textString:SetText( tradeItemsInformation.tag )
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.tradeItemsHighlightRow then
				EMA.settingsControl.tradeItems.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingsTradeItemsRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.tradeItemsOffset + rowNumber <= EMA:GetTradeItemsMaxPosition() then
		EMA.settingsControl.tradeItemsHighlightRow = EMA.settingsControl.tradeItemsOffset + rowNumber
		EMA:SettingsScrollRefresh()
	end
end

function EMA:SettingsTradeItemsRemoveClick( event )
	StaticPopup_Show( "EMATRADE_CONFIRM_REMOVE_TRADE_ITEMS" )
end

function EMA:SettingsEditBoxChangedTradeItem( event, text )
	EMA.autoTradeItemLink = text
	EMA:SettingsRefresh()
end

function EMA:TradeGroupListDropDownList (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.autoTradeItemTag = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end


function EMA:SettingsTradeItemsAddClick( event )
	if EMA.autoTradeItemLink ~= nil and EMA.autoTradeItemTag ~= nil then
		EMA:AddItem( EMA.autoTradeItemLink, EMA.autoTradeItemTag )
		EMA.autoTradeItemLink = nil
		EMA.settingsControl.tradeItemsEditBoxTradeItem:SetText( "" )
		EMA:SettingsRefresh()
	end
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:OnGroupAreasChanged( message )
	EMA.settingsControl.tradeItemsEditBoxToonTag:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleShowEMATradeWindow( event, checked )
	EMA.db.showEMATradeWindow = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTradeBoEItems(event, checked )
	EMA.db.tradeBoEItems = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTradeCRItems(event, checked )
	EMA.db.tradeCRItems = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAdjustMoneyOnToonViaGuildBank( event, checked )
	EMA.db.adjustMoneyWithGuildBank = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAdjustMoneyWithMasterOnTrade( event, checked )
	EMA.db.adjustMoneyWithMasterOnTrade = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedGoldAmountToLeaveOnToon( event, text )
	EMA.db.goldAmountToKeepOnToon = tonumber( text )
	if EMA.db.goldAmountToKeepOnToon == nil then
		EMA.db.goldAmountToKeepOnToon = 0
	end
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedGoldAmountToLeaveOnToonTrade( event, text )
	EMA.db.goldAmountToKeepOnToonTrade = tonumber( text )
	if EMA.db.goldAmountToKeepOnToonTrade == nil then
		EMA.db.goldAmountToKeepOnToonTrade = 0
	end
	EMA:SettingsRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.messageArea = settings.messageArea
		EMA.db.showEMATradeWindow = settings.showEMATradeWindow
		EMA.db.tradeBoEItems = settings.tradeBoEItems
		EMA.db.tradeCRItems = settings.tradeCRItems
		EMA.db.autoTradeItemsList = EMAUtilities:CopyTable( settings.autoTradeItemsList )
		EMA.db.adjustMoneyWithGuildBank = settings.adjustMoneyWithGuildBank
		EMA.db.goldAmountToKeepOnToon = settings.goldAmountToKeepOnToon
		EMA.db.adjustMoneyWithMasterOnTrade = settings.adjustMoneyWithMasterOnTrade
		EMA.db.goldAmountToKeepOnToonTrade = settings.goldAmountToKeepOnToonTrade
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
	EMA.settingsControl.checkBoxShowEMATradeWindow:SetValue( EMA.db.showEMATradeWindow )
	EMA.settingsControl.checkBoxTradeBoEItems:SetValue( EMA.db.tradeBoEItems)
	EMA.settingsControl.checkBoxTradeCRItems:SetValue( EMA.db.tradeCRItems)
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.checkBoxAdjustMoneyWithMasterOnTrade:SetValue( EMA.db.adjustMoneyWithMasterOnTrade )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToonTrade:SetText( tostring( EMA.db.goldAmountToKeepOnToonTrade ) )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToonTrade:SetDisabled( not EMA.db.adjustMoneyWithMasterOnTrade )
	EMA.settingsControl.tradeItemsEditBoxTradeItem:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.tradeItemsEditBoxToonTag:SetDisabled( not EMA.db.showEMATradeWindow )	
	EMA.settingsControl.tradeItemsButtonRemove:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.tradeItemsButtonAdd:SetDisabled( not EMA.db.showEMATradeWindow )	
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
-- Trade functionality.
-------------------------------------------------------------------------------------------------------------

-- New Trade stuff


function EMA:GetTradeItemsMaxPosition()
	return #EMA.db.autoTradeItemsList
end

function EMA:GetTradeItemsAtPosition( position )
	return EMA.db.autoTradeItemsList[position]
end

function EMA:AddItem( itemLink, itemTag )
	-- Get some more information about the item.
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemLink )
	-- If the item could be found.
	if name ~= nil then
		local itemInformation = {}
		itemInformation.link = link
		itemInformation.name = name
		itemInformation.tag = itemTag
		table.insert( EMA.db.autoTradeItemsList, itemInformation )
		EMA:SettingsRefresh()			
		EMA:SettingsTradeItemsRowClick( 1, 1 )
	end	
end

function EMA:RemoveItem()
	table.remove( EMA.db.autoTradeItemsList, EMA.settingsControl.tradeItemsHighlightRow )
	EMA:SettingsRefresh()
	EMA:SettingsTradeItemsRowClick( 1, 1 )		
end


function EMA:TRADE_SHOW( event, ... )	
	--Keep for tradeing gold!
	if EMA.db.adjustMoneyWithMasterOnTrade == true then
		EMA:ScheduleTimer( "TradeShowAdjustMoneyWithMaster", 0.3 )
	end	
	-- do trade list with Gold!
	if EMA.db.showEMATradeWindow == true then
		EMA:ScheduleTimer("TradeItemsFromList", 0.5 )
	end
	if EMA.db.tradeBoEItems == true then
		EMA:ScheduleTimer("TradeBoEItems", 1.0 )
	end	
	if EMA.db.tradeCRItems == true then
		EMA:ScheduleTimer("TradeCRItems", 1.5 )
	end	
end


function EMA:TradeShowAdjustMoneyWithMaster()
	if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
		return
	end
	local moneyToKeepOnToon = tonumber( EMA.db.goldAmountToKeepOnToonTrade ) * 10000
	local moneyOnToon = GetMoney()
	local moneyToDepositOrWithdraw = moneyOnToon - moneyToKeepOnToon
	if moneyToDepositOrWithdraw == 0 then
		return
	end
	if moneyToDepositOrWithdraw > 0 then
		for index, character in EMAApi.TeamListOrderedOnline() do
			--EMA:Print("Team", character )
			local teamCharacterName = ( Ambiguate( character, "short" ) )
			local tradePlayersName = GetUnitName("NPC")
			if tradePlayersName == teamCharacterName then
					--EMA:Print("found", tradePlayersName, teamCharacterName, character )
					if EMAApi.IsCharacterTheMaster(character) == true and EMAUtilities:CheckIsFromMyRealm(character) == true then	
						MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, moneyToDepositOrWithdraw)
						break
					end	
			else
				--EMA:Print(tradePlayersName, L["Is Not a Member of the team, Will not trade Gold."])
			end
		end
		
	end
end


function EMA:TradeItemsFromList()
	for index, character in EMAApi.TeamListOrderedOnline() do
		--EMA:Print("Team", character )
		local teamCharacterName = ( Ambiguate( character, "short" ) )
		local tradePlayersName = GetUnitName("NPC")
		if tradePlayersName == teamCharacterName then
			--EMA:Print("found", tradePlayersName, teamCharacterName, character )
			--Checks the D_B for any items in the list.
			for position, itemInformation in pairs( EMA.db.autoTradeItemsList ) do	
				if EMAApi.IsCharacterInGroup(EMA.characterName, itemInformation.tag ) == true and EMAUtilities:CheckIsFromMyRealm(character) == true then
				--EMA:Print("Items in list", itemInformation.link )
					for bag,slot,link in LibBagUtils:Iterate("BAGS", itemInformation.link ) do
						if bag ~= nil then
							--EMA:Print("found", bag, slot)
							for iterateTradeSlots = 1, (MAX_TRADE_ITEMS - 1) do
								if GetTradePlayerItemLink( iterateTradeSlots ) == nil then
									PickupContainerItem( bag, slot )
									ClickTradeButton( iterateTradeSlots )
								end		
							end
						end		
					end	
				end				
			end			
		else
			--EMA:Print(tradePlayersName, L["ERR_WILL_NOT_TRADE"])
		end	
	end	
end

function EMA:TradeBoEItems()
	if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
		return
	end
	for index, character in EMAApi.TeamListOrderedOnline() do
		--EMA:Print("Team", character )
		local teamCharacterName = ( Ambiguate( character, "short" ) )
		local tradePlayersName = GetUnitName("NPC")
		if tradePlayersName == teamCharacterName then
			if EMAApi.IsCharacterTheMaster(character) == true and EMAUtilities:CheckIsFromMyRealm(character) == true then
				for bag,slot,link in LibBagUtils:Iterate("BAGS") do
					if bag ~= nil then			
						local _, _, locked, quality = GetContainerItemInfo(bag, slot)
						-- quality is Uncommon (green) to  Epic (purple) 2 - 3 - 4
						if quality ~= nil and locked == false then
							if quality >= 2 and quality <= 4 then 
								-- tooltips scan is the olny way to find if the item is BoE in bags!
								local isBoe = EMAUtilities:ToolTipBagScaner(link, bag, slot)
								-- if the item is boe then add it to the trade list!
								if isBoe ~= ITEM_SOULBOUND then
									--EMA:Print("test21", link, locked)
									for iterateTradeSlots = 1, (MAX_TRADE_ITEMS - 1) do
										if GetTradePlayerItemLink( iterateTradeSlots ) == nil then
											PickupContainerItem( bag, slot )
											ClickTradeButton( iterateTradeSlots )
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


function EMA:TradeCRItems()
	if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
		return
	end
	for index, character in EMAApi.TeamListOrderedOnline() do
		--EMA:Print("Team", character )
		local teamCharacterName = ( Ambiguate( character, "short" ) )
		local tradePlayersName = GetUnitName("NPC")
		if tradePlayersName == teamCharacterName then
			if EMAApi.IsCharacterTheMaster(character) == true and EMAUtilities:CheckIsFromMyRealm(character) == true then
				for bag,slot,itemLink in LibBagUtils:Iterate("BAGS") do
					if itemLink then
						-- using legion CraftingReagent API, as tooltip massess up some "items"
						local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,isCraftingReagent = GetItemInfo(itemLink)
						if isCraftingReagent == true then
							--EMA:Print("TradeCraftingGoods", isCraftingReagent, itemLink)
							-- tooltips scan is the olny way to find if the item is BOP in bags!
							local isBop = EMAUtilities:TooltipScaner(itemLink)
							--EMA:Print("testBOP", itemLink, isBop)
							if isBop ~= ITEM_BIND_ON_PICKUP then
							--EMA:Print("AddToTrade", itemLink)
								for iterateTradeSlots = 1, (MAX_TRADE_ITEMS - 1) do
									if GetTradePlayerItemLink( iterateTradeSlots ) == nil then
										PickupContainerItem( bag, slot )
										ClickTradeButton( iterateTradeSlots )
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


function EMA:TRADE_CLOSED()
	
end