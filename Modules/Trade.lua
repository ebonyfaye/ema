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
	 global = {
		['**'] = {
			autoTradeItemsListGlobal = {},
		},
	 },		
	profile = {
		messageArea = EMAApi.DefaultMessageArea(),
		showEMATradeWindow = false,
		globalTadeList = false,
		blackListItem = false,
		tradeBoEItems = false,
		tradeCRItems = false,
		tradeRecipeFItems = false,
		autoSellOtherItemTag = EMAApi.MasterGroup(),
		autoBoEItemTag = EMAApi.MasterGroup(),
		autoCRItemTag = EMAApi.MasterGroup(),
		autoRecipeFItemTag = EMAApi.MasterGroup(),
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
			config = {
				type = "input",
				name = L["OPEN_CONFIG"],
				desc = L["OPEN_CONFIG_HELP"],
				usage = "/ema-team config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_ALL_SETTINGS"],
				usage = "/ema-trade push",
				get = false,
				set = "EMASendSettings",
				guiHidden = true,
			},
			copy = {
				type = "input",
				name = L["COPY"],
				desc = L["COPY_HELP"],
				usage = "/ema-trade copy",
				get = false,
				set = "CopyListCommmand",
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
	--EMA.autoSellOtherItemTag = EMAApi.MasterGroup ()
	--EMA.autoTradeItemTag = EMAApi.MasterGroup ()
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
	EMA:RawHook( "ContainerFrameItemButton_OnModifiedClick", true)
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
	local indentContinueLabel = horizontalSpacing * 18
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local tradeWidth = headingWidth
	local dropBoxWidth = (headingWidth - horizontalSpacing) / 4
	
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - indentContinueLabel) / 3
	local left2 = left + thirdWidth +  horizontalSpacing
	local left3 = left2 + thirdWidth +  horizontalSpacing
	local movingTop = top
	local movingTopEdit = - 10
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["TRADE_LIST_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxShowEMATradeWindow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, --+ 130, 
		movingTop, 
		L["TRADE_LIST"],
		EMA.SettingsToggleShowEMATradeWindow,
		L["TRADE_LIST_HELP"]
	)	
	EMA.settingsControl.checkBoxGlobalTradeList = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3, 
		movingTop, 
		L["GLOBAL_LIST"],
		EMA.SettingsToggleGlobalTradeList,
		L["GLOBAL_SETTINGS_LIST_HELP"]
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
	list.columnsToDisplay = 3
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 40
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 20
	list.columnInformation[2].alignment = "LEFT"
	list.columnInformation[3] = {}
	list.columnInformation[3].width = 20
	list.columnInformation[3].alignment = "LEFT"		
	list.scrollRefreshCallback = EMA.SettingsScrollRefresh
	list.rowClickCallback = EMA.SettingsTradeItemsRowClick
	EMA.settingsControl.tradeItems = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.tradeItems )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.tradeItemsButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop,
		L["REMOVE"],
		EMA.SettingsTradeItemsRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ADD_ITEMS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.tradeItemsEditBoxTradeItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		thirdWidth,
		left2,
		movingTop,
		L["ITEM_DROP"]
	)
	EMA.settingsControl.tradeItemsEditBoxTradeItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedTradeItem )
	movingTop = movingTop - editBoxHeight
		EMA.settingsControl.listCheckBoxBoxOtherBlackListItem = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left,
		movingTop + movingTopEdit,
		L["BLACKLIST_ITEM"],
		EMA.SettingsToggleBlackListItem,
		L["BLACKLIST_ITEM_HELP"]
	)
	EMA.settingsControl.tradeItemsEditBoxToonTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3 ,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.tradeItemsEditBoxToonTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.tradeItemsEditBoxToonTag:SetCallback( "OnValueChanged",  EMA.TradeGroupListDropDownList )
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.tradeItemsButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop, 
		L["ADD"],
		EMA.SettingsTradeItemsAddClick
	)
	movingTop = movingTop -	buttonHeight		
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["TRADE_OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxTradeBoEItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop + movingTopEdit, 
		L["TRADE_BOE_ITEMS"],
		EMA.SettingsToggleTradeBoEItems,
		L["TRADE_BOE_ITEMS_HELP"]
	)
	EMA.settingsControl.tradeTradeBoEItemsTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		dropBoxWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.tradeTradeBoEItemsTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.tradeTradeBoEItemsTag:SetCallback( "OnValueChanged",  EMA.TradeGroupListItemsBoEDropDown )
	movingTop = movingTop - editBoxHeight - 3
	EMA.settingsControl.checkBoxTradeCRItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop + movingTopEdit, 
		L["TRADE_REAGENTS"],
		EMA.SettingsToggleTradeCRItems,
		L["TRADE_REAGENTS_HELP"]
	)
	EMA.settingsControl.tradeTradeCRItemsTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		dropBoxWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.tradeTradeCRItemsTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.tradeTradeCRItemsTag:SetCallback( "OnValueChanged",  EMA.TradeGroupListItemsCRDropDown )
	-- NEW AKANDESH THING
	movingTop = movingTop - editBoxHeight - 3
	EMA.settingsControl.checkBoxTradeRecipeFItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop + movingTopEdit, 
		L["TRADE_RECIPE_FORMULA"],
		EMA.SettingsToggleTradeRecipeFItems,
		L["TRADE_RECIPE_FORMULA_HELP"]
	)
	EMA.settingsControl.tradeTradeRecipeFItemsTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		dropBoxWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.tradeTradeRecipeFItemsTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.tradeTradeRecipeFItemsTag:SetCallback( "OnValueChanged",  EMA.TradeGroupListItemsRecipeFDropDown )
	-- Trade Gold! Keep
	movingTop = movingTop - editBoxHeight
	EMA.settingsControl.checkBoxAdjustMoneyWithMasterOnTrade = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left + 150, 
		movingTop, 
		L["TRADE_GOLD"],
		EMA.SettingsToggleAdjustMoneyWithMasterOnTrade,
		L["TRADE_GOLD_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToonTrade = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		dropBoxWidth,
		left2,
		movingTop,
		L["GOLD_TO_KEEP"]
	)	
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToonTrade:SetCallback( "OnEnterPressed", EMA.EditBoxChangedGoldAmountToLeaveOnToonTrade )
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		dropBoxWidth, 
		left2, 
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
		EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[3].textString:SetText( "" )
		EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[3].textString:SetTextColor( 1.0, 0, 00, 1.0 )	
		EMA.settingsControl.tradeItems.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.tradeItemsOffset
		if dataRowNumber <= EMA:GetTradeItemsMaxPosition() then
			-- Put data information into columns.
			local tradeItemsInformation = EMA:GetTradeItemsAtPosition( dataRowNumber )
			local blackListText = ""
			if tradeItemsInformation.blackList == true then
				blackListText = L["ITEM_ON_BLACKLIST"]
			end
			EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[1].textString:SetText( tradeItemsInformation.name )
			EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[2].textString:SetText( tradeItemsInformation.tag )
			EMA.settingsControl.tradeItems.rows[iterateDisplayRows].columns[3].textString:SetText( blackListText )
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
			EMA.db.autoSellOtherItemTag = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleBlackListItem( event, checked ) 
	EMA.db.blackListItem = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsTradeItemsAddClick( event )
	if EMA.autoTradeItemLink ~= nil and EMA.db.autoSellOtherItemTag ~= nil then
		--EMA:Print("test",  EMA.db.blackListItem )
		EMA:AddItem( EMA.autoTradeItemLink, EMA.db.autoSellOtherItemTag, EMA.db.blackListItem )
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
	EMA.settingsControl.tradeTradeCRItemsTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.tradeTradeRecipeFItemsTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.tradeTradeBoEItemsTag:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleGlobalTradeList( event, checked )
	EMA.db.globalTradeList = checked
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

function EMA:TradeGroupListItemsBoEDropDown(event, value )
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.db.autoBoEItemTag = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTradeCRItems(event, checked )
	EMA.db.tradeCRItems = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTradeRecipeFItems(event, checked )
	EMA.db.tradeRecipeFItems = checked
	EMA:SettingsRefresh()
end

function EMA:TradeGroupListItemsCRDropDown(event, value )
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.db.autoCRItemTag = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:TradeGroupListItemsRecipeFDropDown(event, value )
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.db.autoRecipeFItemTag = groupName
			break
		end
	end
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

function EMA:CopyListCommmand()
	EMA:Print("Copying Local List To Global List")
	EMA.db.global.autoTradeItemsListGlobal = EMAUtilities:CopyTable( EMA.db.autoTradeItemsList )
	EMA:SettingsRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.messageArea = settings.messageArea
		EMA.db.showEMATradeWindow = settings.showEMATradeWindow
		EMA.db.globalTradeList = settings.globalTradeList
		EMA.db.autoSellOtherItemTag = settings.autoSellOtherItemTag
		EMA.db.blackListItem = settings.blackListItem
		EMA.db.tradeBoEItems = settings.tradeBoEItems
		EMA.db.tradeCRItems = settings.tradeCRItems
		EMA.db.tradeRecipeFItems = settings.tradeRecipeFItems
		EMA.db.autoBoEItemTag = settings.autoBoEItemTag
		EMA.db.autoCRItemTag = settings.autoCRItemTag
		EMA.db.autoTradeItemsList = EMAUtilities:CopyTable( settings.autoTradeItemsList )
		EMA.db.global.autoTradeItemsListGlobal = EMAUtilities:CopyTable( settings.global.autoTradeItemsListGlobal )
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
	-- global CheckBox
	EMA.settingsControl.checkBoxGlobalTradeList:SetValue( EMA.db.globalTradeList )
	EMA.settingsControl.checkBoxGlobalTradeList:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetValue( EMA.db.blackListItem )
	EMA.settingsControl.checkBoxTradeBoEItems:SetValue( EMA.db.tradeBoEItems)
	EMA.settingsControl.checkBoxTradeCRItems:SetValue( EMA.db.tradeCRItems)
	EMA.settingsControl.checkBoxTradeRecipeFItems:SetValue( EMA.db.tradeRecipeFItems)
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.tradeItemsEditBoxToonTag:SetText( EMA.db.autoSellOtherItemTag )
	EMA.settingsControl.tradeTradeBoEItemsTag:SetText( EMA.db.autoBoEItemTag )
	EMA.settingsControl.tradeTradeCRItemsTag:SetText( EMA.db.autoCRItemTag )
	EMA.settingsControl.tradeTradeRecipeFItemsTag:SetText( EMA.db.autoRecipeFItemTag )
	EMA.settingsControl.checkBoxAdjustMoneyWithMasterOnTrade:SetValue( EMA.db.adjustMoneyWithMasterOnTrade )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToonTrade:SetText( tostring( EMA.db.goldAmountToKeepOnToonTrade ) )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToonTrade:SetDisabled( not EMA.db.adjustMoneyWithMasterOnTrade )
	EMA.settingsControl.tradeItemsEditBoxTradeItem:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.tradeItemsEditBoxToonTag:SetDisabled( not EMA.db.showEMATradeWindow )	
	EMA.settingsControl.tradeItemsButtonRemove:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.tradeItemsButtonAdd:SetDisabled( not EMA.db.showEMATradeWindow )	
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.checkBoxTradeBoEItems:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.tradeTradeBoEItemsTag:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.checkBoxTradeCRItems:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.tradeTradeCRItemsTag:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.checkBoxTradeRecipeFItems:SetDisabled( not EMA.db.showEMATradeWindow )
	EMA.settingsControl.tradeTradeRecipeFItemsTag:SetDisabled( not EMA.db.showEMATradeWindow )
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

function EMA:ContainerFrameItemButton_OnModifiedClick( self, event, ... )
	local isConfigOpen = EMAPrivate.SettingsFrame.Widget:IsVisible()
	if isConfigOpen == true and IsShiftKeyDown() == true then
		local GUIPanel = EMAPrivate.SettingsFrame.TreeGroupStatus.selected
		local currentModule = string.find(GUIPanel, EMA.moduleDisplayName) 
		--EMA:Print("test2", GUIPanel, "vs", currentModule )
		if currentModule ~= nil then
			local itemID, itemLink = GameTooltip:GetItem()
			--EMA:Print("test1", itemID, itemLink )
			if itemLink ~= nil then
				EMA.settingsControl.tradeItemsEditBoxTradeItem:SetText( "" )
				EMA.settingsControl.tradeItemsEditBoxTradeItem:SetText( itemLink )
				EMA.autoTradeItemLink = itemLink	
				return
			end
		end	
	end	
	return EMA.hooks["ContainerFrameItemButton_OnModifiedClick"]( self, event, ... )
end


-- New Trade stuff
function EMA:GetTradeItemsMaxPosition()
	if EMA.db.globalTradeList == true then
		return #EMA.db.global.autoTradeItemsListGlobal
	else
		return #EMA.db.autoTradeItemsList
	end	
end

function EMA:GetTradeItemsAtPosition( position )
	if EMA.db.globalTradeList == true then
		return EMA.db.global.autoTradeItemsListGlobal[position]
	else
		return EMA.db.autoTradeItemsList[position]
	end	
end

function EMA:AddItem( itemLink, itemTag, blackList )
	-- Get some more information about the item.
	--EMA:Print("test", itemLink, itemTag, blackList )
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemLink )
	-- If the item could be found.
	if name ~= nil then
		local itemInformation = {}
		itemInformation.link = link
		itemInformation.name = name
		itemInformation.tag = itemTag
		itemInformation.blackList = blackList
		if EMA.db.globalTradeList == true then
			table.insert( EMA.db.global.autoTradeItemsListGlobal, itemInformation )
		else
			table.insert( EMA.db.autoTradeItemsList, itemInformation )
		end
		EMA:SettingsRefresh()			
		EMA:SettingsTradeItemsRowClick( 1 , 1 )
	end	
end

function EMA:RemoveItem()
	if EMA.db.globalTradeList == true then
		table.remove( EMA.db.global.autoTradeItemsListGlobal,  EMA.settingsControl.tradeItemsHighlightRow )
	else	
		table.remove( EMA.db.autoTradeItemsList, EMA.settingsControl.tradeItemsHighlightRow )
	end
	EMA:SettingsRefresh()
	EMA:SettingsTradeItemsRowClick( EMA.settingsControl.tradeItemsHighlightRow -1 , 1 )		
end

function EMA:TRADE_SHOW( event, ... )	
	--Keep for tradeing gold!
	if EMA.db.adjustMoneyWithMasterOnTrade == true then
		if not IsShiftKeyDown() then
			EMA:ScheduleTimer( "TradeShowAdjustMoneyWithMaster", 0.3 )
		end	
	end	
	-- do trade list with Gold!
	if EMA.db.showEMATradeWindow == true then
		if not IsShiftKeyDown() then
			EMA:ScheduleTimer("TradeAllItems", 0.5 )
		end
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
		local tradePlayersName = GetUnitName("NPC", true)
		local characterName = EMAUtilities:AddRealmToNameIfMissing( tradePlayersName )
		if EMAApi.IsCharacterTheMaster(characterName) == true and EMAUtilities:CheckIsFromMyRealm(characterName) == true then	
			MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, moneyToDepositOrWithdraw)
		end
	end
end

function EMA:TradeAllItems()	
	local tradePlayersName = GetUnitName("NPC", true)
	local characterName = EMAUtilities:AddRealmToNameIfMissing( tradePlayersName )
	--EMA:Print("testTradeName", characterName)
	if EMAApi.IsCharacterInTeam ( characterName ) == false and EMAUtilities:CheckIsFromMyRealm(characterName) == false then
		return
	end
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1,GetContainerNumSlots( bagID ),1 do 
			--EMA:Print( "Bags OK. checking", itemLink )
			local item = Item:CreateFromBagAndSlot(bagID, slotID)
			if ( item ) then
				local bagItemLink = item:GetItemLink()
				if ( bagItemLink ) then	
					local itemLink = item:GetItemLink()
					local location = item:GetItemLocation()
					local inventoryType = C_Item.GetItemInventoryType( location )
					local isBop = C_Item.IsBound( location )
					local itemRarity =  C_Item.GetItemQuality( location )
					--itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent
					local itemClassID = select(12, GetItemInfo(bagItemLink) )
					local isCraftingReagent = select(17, GetItemInfo(bagItemLink) )
					local canTrade = false
					if EMA.db.tradeBoEItems == true then
						if inventoryType ~= 0 then
							if EMAApi.IsCharacterInGroup( characterName, EMA.db.autoBoEItemTag ) == true then
								if isBop == false then
									if itemRarity == 2 or itemRarity == 3 or itemRarity == 4 then	
										canTrade = true	
									end	
								end
							end										
						end									
					end	
					if EMA.db.tradeCRItems == true then
						if isCraftingReagent == true then
							if EMAApi.IsCharacterInGroup( characterName, EMA.db.autoCRItemTag ) == true then
								if isBop == false then
									canTrade = true	
								end
							end										
						end
					end
					if EMA.db.tradeRecipeFItems == true then
						if itemClassID == 9 then -- LE_ITEM_CLASS_RECIPE
							if EMAApi.IsCharacterInGroup( characterName, EMA.db.autoRecipeFItemTag ) == true then
								if isBop == false then
									canTrade = true	
								end
							end		
						end
					end
					if EMA.db.globalTradeList == true then
						itemTable = EMA.db.global.autoTradeItemsListGlobal
					else
						itemTable = EMA.db.autoTradeItemsList
					end
					for position, itemInformation in pairs( itemTable ) do
						if EMAApi.IsCharacterInGroup( characterName, itemInformation.tag ) == true then	
							if EMAUtilities:DoItemLinksContainTheSameItem( itemLink, itemInformation.link ) then
								--EMA:Print("DataTest", itemInformation.link, itemInformation.blackList )
								--EMA:Print("test", itemLink)
								canTrade = true
								if itemInformation.blackList == true then
									canTrade = false
								end
							end
						end
					end	
					if canTrade == true then
						for iterateTradeSlots = 1, ( MAX_TRADE_ITEMS - 1 ) do	
							if GetTradePlayerItemLink( iterateTradeSlots ) == nil then
								PickupContainerItem( bagID, slotID )
								ClickTradeButton( iterateTradeSlots )	
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
