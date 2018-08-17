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
	"Sell", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Load libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local AceGUI = LibStub:GetLibrary( "AceGUI-3.0" )
--local LibBagUtils = LibStub:GetLibrary( "LibBagUtils-1.0" )
local ItemUpgradeInfo = LibStub:GetLibrary( "LibItemUpgradeInfo-1.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Sell"
EMA.settingsDatabaseName = "SellProfileDB"
EMA.chatCommand = "ema-sell"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["VENDER"]
EMA.moduleDisplayName = L["VENDER"]
EMA.moduleDisplayVenderName = L["VENDER_LIST_MODULE"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\SellIcon.tga"
-- order
EMA.moduleOrder = 80
EMA.moduleListOrder	 = 1

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		sellItemOnAllWithAltKey = false,
		-- Other Items
		autoSellOtherItems = false,
		autoSellOtherItemsList = {},
		messageArea = EMAApi.DefaultMessageArea(),
		autoSellItem = false,
		-- Gray
		autoSellPoor = false,
		autoSellBoEPoor	=  false,
		-- Green	
		autoSellUncommon = false,
		autoSellIlvlUncommon = 0,
		autoSellBoEUncommon	= false,
		-- Rare
		autoSellRare = false,
		autoSellIlvlRare = 0,
		autoSellBoERare	=  false,
		-- Epic
		autoSellEpic = false,
		autoSellIlvlEpic = 0,
		autoSellBoEEpic	=  false,		
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
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/EMA-sell push",
				get = false,
				set = "EMASendSettings",
			},
		},
	}
	return configuration
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

EMA.COMMAND_SELL_ITEM = "SellItem"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Sell Management.
-------------------------------------------------------------------------------------------------------------

EMA.BAG_PLAYER_BACKPACK = 0
-- NUM_BAG_SLOTS is defined as 4 in Blizzard's FrameXML\BankFrame.lua.
EMA.BAG_PLAYER_MAXIMUM = NUM_BAG_SLOTS
-- Store ItemQuality https://wow.gamepedia.com/API_TYPE_Quality
EMA.ITEM_QUALITY_POOR = 0
EMA.ITEM_QUALITY_COMMON = 1
EMA.ITEM_QUALITY_UNCOMMON = 2
EMA.ITEM_QUALITY_RARE = 3
EMA.ITEM_QUALITY_EPIC = 4
EMA.ITEM_QUALITY_LEGENDARY = 5
EMA.ITEM_QUALITY_ARTIFACT = 6
EMA.ITEM_QUALITY_HEIRLOOM = 7
EMA.MIN_ITEM_LEVEL = 10

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	-- Sell on all with alt key.
	EMA.settingsControl.checkBoxSellItemOnAllWithAltKey:SetValue( EMA.db.sellItemOnAllWithAltKey )
	-- Auto sell Quality and Ilvl items.
	EMA.settingsControl.checkBoxAutoSellItems:SetValue( EMA.db.autoSellItem )
	-- Poor
	EMA.settingsControl.checkBoxAutoSellPoor:SetValue ( EMA.db.autoSellPoor )
	EMA.settingsControl.checkBoxAutoSellBoEPoor:SetValue ( EMA.db.autoSellBoEPoor )
	EMA.settingsControl.checkBoxAutoSellPoor:SetDisabled ( not EMA.db.autoSellItem )
	EMA.settingsControl.checkBoxAutoSellBoEPoor:SetDisabled ( not EMA.db.autoSellPoor )
	-- Uncommon
	EMA.settingsControl.checkBoxAutoSellUncommon:SetValue (EMA.db.autoSellUncommon )
	EMA.settingsControl.editBoxAutoSellIlvlUncommon:SetText (EMA.db.autoSellIlvlUncommon )
	EMA.settingsControl.checkBoxAutoSellBoEUncommon:SetValue (EMA.db.autoSellBoEUncommon )
	EMA.settingsControl.checkBoxAutoSellUncommon:SetDisabled ( not EMA.db.autoSellItem )
	EMA.settingsControl.editBoxAutoSellIlvlUncommon:SetDisabled ( not EMA.db.autoSellUncommon )
	EMA.settingsControl.checkBoxAutoSellBoEUncommon:SetDisabled ( not EMA.db.autoSellUncommon )	
	-- Rare
	EMA.settingsControl.checkBoxAutoSellRare:SetValue (EMA.db.autoSellRare )
	EMA.settingsControl.editBoxAutoSellIlvlRare:SetText (EMA.db.autoSellIlvlRare )
	EMA.settingsControl.checkBoxAutoSellBoERare:SetValue (EMA.db.autoSellBoERare )
	EMA.settingsControl.checkBoxAutoSellRare:SetDisabled ( not EMA.db.autoSellItem )
	EMA.settingsControl.editBoxAutoSellIlvlRare:SetDisabled ( not EMA.db.autoSellRare )
	EMA.settingsControl.checkBoxAutoSellBoERare:SetDisabled ( not EMA.db.autoSellRare )	
	-- Epic
	EMA.settingsControl.checkBoxAutoSellEpic:SetValue ( EMA.db.autoSellEpic )
	EMA.settingsControl.editBoxAutoSellIlvlEpic:SetText ( EMA.db.autoSellIlvlEpic)
	EMA.settingsControl.checkBoxAutoSellBoEEpic:SetValue ( EMA.db.autoSellBoEEpic )
	EMA.settingsControl.checkBoxAutoSellEpic:SetDisabled ( not EMA.db.autoSellItem )
	EMA.settingsControl.editBoxAutoSellIlvlEpic:SetDisabled ( not EMA.db.autoSellEpic )
	EMA.settingsControl.checkBoxAutoSellBoEEpic:SetDisabled ( not EMA.db.autoSellEpic )		
	-- Messages.
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	-- Others. 
	EMA.settingsControlOthers.checkBoxAutoSellOtherItems:SetValue( EMA.db.autoSellOtherItems )
	EMA.settingsControlOthers.othersEditBoxOtherTag:SetText( EMA.autoSellOtherItemTag )
	EMA.settingsControlOthers.othersEditBoxOtherItem:SetDisabled( not EMA.db.autoSellOtherItems )
	EMA.settingsControlOthers.othersEditBoxOtherTag:SetDisabled( not EMA.db.autoSellOtherItems )
	EMA.settingsControlOthers.othersButtonRemove:SetDisabled( not EMA.db.autoSellOtherItems )
	EMA.settingsControlOthers.othersButtonAdd:SetDisabled( not EMA.db.autoSellOtherItems )
	EMA:SettingsOthersScrollRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.sellItemOnAllWithAltKey = settings.sellItemOnAllWithAltKey
		EMA.db.autoSellItem = settings.autoSellItem
		EMA.db.autoSellPoor = settings.autoSellPoor
		EMA.db.autoSellBoEPoor = settings.autoSellBoEPoor
		EMA.db.autoSellUncommon = settings.autoSellUncommon
		EMA.db.autoSellIlvlUncommon = settings.autoSellIlvlUncommon
		EMA.db.autoSellBoEUncommon = settings.autoSellBoEUncommon
		EMA.db.autoSellRare = settings.autoSellRare
		EMA.db.autoSellIlvlRare = settings.autoSellIlvlRare
		EMA.db.autoSellBoERare = settings.autoSellBoERare
		EMA.db.autoSellEpic = settings.autoSellEpic
		EMA.db.autoSellIlvlEpic = settings.autoSellIlvlEpic
		EMA.db.autoSellBoEEpic = settings.autoSellBoEEpic
		EMA.db.autoSellOtherItems = settings.autoSellOtherItems
		EMA.db.messageArea = settings.messageArea
		EMA.db.autoSellOtherItemsList = EMAUtilities:CopyTable( settings.autoSellOtherItemsList )
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreateMain( top )
	-- Position and size constants.
	local buttonControlWidth = 105
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local indent = horizontalSpacing * 12
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - (horizontalSpacing * 5)) / 5
	local left2 = left + thirdWidth
	local left3 = left + halfWidth
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["SELL_ALL"], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.checkBoxSellItemOnAllWithAltKey = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["ALT_SELL_ALL"],
		EMA.SettingsToggleSellItemOnAllWithAltKey,
		L["ALT_SELL_ALL_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["SELL_ITEMS"], movingTop, false )
	
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.checkBoxAutoSellItems = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["AUTO_SELL_ITEMS"],
		EMA.SettingsToggleAutoSellItems,
		L["AUTO_SELL_ITEMS_HELP"]
	)	
-- Gray
	movingTop = movingTop - checkBoxHeight - 3
	EMA.settingsControl.checkBoxAutoSellPoor = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left,
		movingTop,
		L["SELL_GRAY"],
		EMA.SettingsToggleAutoSellPoor,
		L["SELL_GRAY_HELP"]
	)
	EMA.settingsControl.checkBoxAutoSellBoEPoor = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3,
		movingTop,
		L["ONLY_SB"],
		EMA.SettingsToggleAutoSellBoEPoor,
		L["ONLY_SB_HELP"]
	)
-- Green	
	movingTop = movingTop - checkBoxHeight - 3
	EMA.settingsControl.checkBoxAutoSellUncommon = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left,
		movingTop,
		L["SELL_GREEN"],
		EMA.SettingsToggleAutoSellUncommon,
		L["SELL_GREEN_HELP"]
	)
	EMA.settingsControl.checkBoxAutoSellBoEUncommon = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3,
		movingTop,
		L["ONLY_SB"],
		EMA.SettingsToggleAutoSellBoEUncommon,
		L["ONLY_SB_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxAutoSellIlvlUncommon = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left,
		movingTop,
		L["iLVL"],
		L["iLVL_HELP"]
	)	
	EMA.settingsControl.editBoxAutoSellIlvlUncommon:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedIlvlUncommon )	
-- Rare
	movingTop = movingTop - editBoxHeight - 3	
	EMA.settingsControl.checkBoxAutoSellRare = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left,
		movingTop,
		L["SELL_RARE"],
		EMA.SettingsToggleAutoSellRare,
		L["SELL_RARE_HELP"]
	)
	EMA.settingsControl.checkBoxAutoSellBoERare = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3,
		movingTop,
		L["ONLY_SB"],
		EMA.SettingsToggleAutoSellBoERare,
		L["ONLY_SB_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxAutoSellIlvlRare = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left,
		movingTop,
		L["iLVL"],
		L["iLVL_HELP"]
	)	
	EMA.settingsControl.editBoxAutoSellIlvlRare:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedIlvlRare )		
-- Epic
	movingTop = movingTop - editBoxHeight - 3
	EMA.settingsControl.checkBoxAutoSellEpic = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left,
		movingTop,
		L["SELL_EPIC"],
		EMA.SettingsToggleAutoSellEpic,
		L["SELL_EPIC_HELP"]
	)
	EMA.settingsControl.checkBoxAutoSellBoEEpic = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3,
		movingTop,
		L["ONLY_SB"],
		EMA.SettingsToggleAutoSellBoEEpic,
		L["ONLY_SB_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxAutoSellIlvlEpic = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left,
		movingTop,
		L["iLVL"],
		L["iLVL_HELP"]
	)	
	EMA.settingsControl.editBoxAutoSellIlvlEpic:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedIlvlEpic )		
	movingTop = movingTop - editBoxHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["SELL"]..L[" "]..L["MESSAGES_HEADER"], movingTop, false )
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
	return movingTop
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

local function SettingsCreateOthers( top )
	-- Position and size constants.
	local buttonControlWidth = 85
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local othersWidth = headingWidth
	local dropBoxWidth = (headingWidth - horizontalSpacing) / 4	
	local movingTop = top
	EMAHelperSettings:CreateHeading( EMA.settingsControlOthers, L["SELL_LIST"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControlOthers.checkBoxAutoSellOtherItems = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlOthers, 
		headingWidth, 
		left, 
		movingTop, 
		L["AUTO_SELL_ITEMS"],
		EMA.SettingsToggleAutoSellOtherItems
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlOthers.othersHighlightRow = 1
	EMA.settingsControlOthers.othersOffset = 1
	local list = {}
	list.listFrameName = "EMASellSettingsOthersFrame"
	list.parentFrame = EMA.settingsControlOthers.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = othersWidth
	list.rowHeight = 20
	list.rowsToDisplay = 15
	list.columnsToDisplay = 2
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 70
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 30
	list.columnInformation[2].alignment = "LEFT"	
	list.scrollRefreshCallback = EMA.SettingsOthersScrollRefresh
	list.rowClickCallback = EMA.SettingsOthersRowClick
	EMA.settingsControlOthers.others = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControlOthers.others )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControlOthers.othersButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControlOthers, 
		buttonControlWidth, 
		left, 
		movingTop,
		L["REMOVE"],
		EMA.SettingsOthersRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControlOthers, L["ADD_TO_LIST"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControlOthers.othersEditBoxOtherItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControlOthers,
		headingWidth,
		left,
		movingTop,
		L["SELL_LIST_DROP_ITEM"]
	)
	EMA.settingsControlOthers.othersEditBoxOtherItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedOtherItem )
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControlOthers.othersEditBoxOtherTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControlOthers, 
		dropBoxWidth,	
		left,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControlOthers.othersEditBoxOtherTag:SetList( EMAApi.GroupList() )
	EMA.settingsControlOthers.othersEditBoxOtherTag:SetCallback( "OnValueChanged",  EMA.SellOtherGroupDropDownList )	
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControlOthers.othersButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControlOthers, 
		buttonControlWidth, 
		left, 
		movingTop, 
		L["ADD"],
		EMA.SettingsOthersAddClick
	)
	movingTop = movingTop -	buttonHeight	
	return movingTop
end

local function SettingsCreate()
	EMA.settingsControl = {}

	EMA.settingsControlOthers = {}
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder		
	)
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControlOthers, 
		EMA.moduleDisplayVenderName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleListOrder		
	)	
	local bottomOfSell = SettingsCreateMain( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfSell )
	local bottomOfOthers = SettingsCreateOthers( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControlOthers.widgetSettings.content:SetHeight( -bottomOfOthers )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

-------------------------------------------------------------------------------------------------------------
-- Settings Callbacks.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsOthersScrollRefresh()
	FauxScrollFrame_Update(
		EMA.settingsControlOthers.others.listScrollFrame, 
		EMA:GetOthersMaxPosition(),
		EMA.settingsControlOthers.others.rowsToDisplay, 
		EMA.settingsControlOthers.others.rowHeight
	)
	EMA.settingsControlOthers.othersOffset = FauxScrollFrame_GetOffset( EMA.settingsControlOthers.others.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControlOthers.others.rowsToDisplay do
		-- Reset.
		EMA.settingsControlOthers.others.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControlOthers.others.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControlOthers.others.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControlOthers.others.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControlOthers.others.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControlOthers.othersOffset
		if dataRowNumber <= EMA:GetOthersMaxPosition() then
			-- Put data information into columns.
			local othersInformation = EMA:GetOtherAtPosition( dataRowNumber )
			EMA.settingsControlOthers.others.rows[iterateDisplayRows].columns[1].textString:SetText( othersInformation.name )
			EMA.settingsControlOthers.others.rows[iterateDisplayRows].columns[2].textString:SetText( othersInformation.tag )
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControlOthers.othersHighlightRow then
				EMA.settingsControlOthers.others.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingsOthersRowClick( rowNumber, columnNumber )		
	if EMA.settingsControlOthers.othersOffset + rowNumber <= EMA:GetOthersMaxPosition() then
		EMA.settingsControlOthers.othersHighlightRow = EMA.settingsControlOthers.othersOffset + rowNumber
		EMA:SettingsOthersScrollRefresh()
	end
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleSellItemOnAllWithAltKey( event, checked )
	EMA.db.sellItemOnAllWithAltKey = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoSellItems( event, checked )
	EMA.db.autoSellItem = checked
	EMA:SettingsRefresh()
end	

--  Poor
function EMA:SettingsToggleAutoSellPoor( event, checked )
	EMA.db.autoSellPoor = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleAutoSellBoEPoor( event, checked )
	EMA.db.autoSellBoEPoor = checked
	EMA:SettingsRefresh()
end	

-- Uncommon
function EMA:SettingsToggleAutoSellUncommon( event, checked )
	EMA.db.autoSellUncommon = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsEditBoxChangedIlvlUncommon( event, text )
	EMA.db.autoSellIlvlUncommon = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoSellBoEUncommon( event, checked )
	EMA.db.autoSellBoEUncommon = checked
	EMA:SettingsRefresh()
end

-- Rare
function EMA:SettingsToggleAutoSellRare( event, checked )
	EMA.db.autoSellRare = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsEditBoxChangedIlvlRare( event, text )
	EMA.db.autoSellIlvlRare = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoSellBoERare( event, checked )
	EMA.db.autoSellBoERare = checked
	EMA:SettingsRefresh()
end

-- Epic
function EMA:SettingsToggleAutoSellEpic( event, checked )
	EMA.db.autoSellEpic = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsEditBoxChangedIlvlEpic( event, text )
	EMA.db.autoSellIlvlEpic = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoSellBoEEpic( event, checked )
	EMA.db.autoSellBoEEpic = checked
	EMA:SettingsRefresh()
end

function EMA:OnGroupAreasChanged( message )
	EMA.settingsControlOthers.othersEditBoxOtherTag:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoSellOtherItems( event, checked )
	EMA.db.autoSellOtherItems = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsOthersRemoveClick( event )
	StaticPopup_Show( "EMASELL_CONFIRM_REMOVE_AUTO_SELL_OTHER_ITEMS" )
end

function EMA:SettingsEditBoxChangedOtherItem( event, text )
	EMA.autoSellOtherItemLink = text
	EMA:SettingsRefresh()
end

function EMA:SellOtherGroupDropDownList (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.autoSellOtherItemTag = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsEditBoxChangedUnusableSoulboundTag( event, text )
	if not text or text:trim() == "" or text:find( "%W" ) ~= nil then
		EMA:Print( L["ITEM_TAG_ERR"] )
		return
	end
	EMA.db.autoSellUnusableSoulboundTag = text
	EMA:SettingsRefresh()
end

function EMA:SettingsOthersAddClick( event )
	if EMA.autoSellOtherItemLink ~= nil and EMA.autoSellOtherItemTag ~= nil then
		EMA:AddOther( EMA.autoSellOtherItemLink, EMA.autoSellOtherItemTag )
		EMA.autoSellOtherItemLink = nil
		EMA.settingsControlOthers.othersEditBoxOtherItem:SetText( "" )
		EMA:SettingsRefresh()
	end
end

-------------------------------------------------------------------------------------------------------------
-- Popup Dialogs.
-------------------------------------------------------------------------------------------------------------

-- Initialize Popup Dialogs.
local function InitializePopupDialogs()
	StaticPopupDialogs["EMASELL_CONFIRM_REMOVE_AUTO_SELL_OTHER_ITEMS"] = {
        text = L["POPUP_REMOVE_ITEM"],
		button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function()
			EMA:RemoveOther()
		end,
    }
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	EMA.autoSellOtherItemLink = nil
	EMA.autoSellOtherItemTag = EMAApi.AllTag()
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
	-- Initialise the popup dialogs.
	InitializePopupDialogs()	
	
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "MERCHANT_SHOW" )
	-- Hook the item click event.
	EMA:RawHook( "ContainerFrameItemButton_OnModifiedClick", true )
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	EMA:RegisterMessage( EMAApi.GROUP_LIST_CHANGED , "OnGroupAreasChanged" )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-------------------------------------------------------------------------------------------------------------
-- EMASell functionality.
-------------------------------------------------------------------------------------------------------------

-- The ContainerFrameItemButton_OnModifiedClick hook.
function EMA:ContainerFrameItemButton_OnModifiedClick( self, event, ... )
	if EMA.db.sellItemOnAllWithAltKey == true and IsAltKeyDown() and MerchantFrame:IsVisible() then
		local bag, slot = self:GetParent():GetID(), self:GetID()
		local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo( bag, slot )
		EMA:EMASendCommandToTeam( EMA.COMMAND_SELL_ITEM, link )
	end
	return EMA.hooks["ContainerFrameItemButton_OnModifiedClick"]( self, event, ... )
end

function EMA:DoSellItem( itemlink )
	-- Iterate each bag the player has.		
	for bag = EMA.BAG_PLAYER_BACKPACK, EMA.BAG_PLAYER_MAXIMUM do 
		-- Iterate each slot in the bag.
		numSlots = GetContainerNumSlots( bag )
		for slot = 1, numSlots do 
			-- Get the item link for the item in this slot.
		--	local bagItemLink = GetContainerItemLink( bag, slot )
			local _, _, locked, _, _, _, bagItemLink, _, hasNoValue = GetContainerItemInfo(bag, slot)
			-- If there is an item...
			if bagItemLink ~= nil then
				local name = GetItemInfo( bagItemLink )
				-- Does it match the item to sell?					
				if EMAUtilities:DoItemLinksContainTheSameItem( bagItemLink, itemlink ) then
					-- Yes, sell this item.
					if 	hasNoValue == false then	
						if MerchantFrame:IsVisible() == true then	
							UseContainerItem( bag, slot ) 
							-- Tell the boss.
							EMA:EMASendMessageToTeam( EMA.db.messageArea, L["I_HAVE_SOLD_X"]( bagItemLink ), false )
						end
					end							
				end
			end
		end
	end
end

function EMA:GetOthersMaxPosition()
	return #EMA.db.autoSellOtherItemsList
end

function EMA:GetOtherAtPosition( position )
	return EMA.db.autoSellOtherItemsList[position]
end

function EMA:AddOther( itemLink, itemTag )
	-- Get some more information about the item.
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemLink )
	-- If the item could be found.
	if name ~= nil then
		local itemInformation = {}
		itemInformation.link = itemLink
		itemInformation.name = name
		itemInformation.tag = itemTag
		table.insert( EMA.db.autoSellOtherItemsList, itemInformation )
		EMA:SettingsRefresh()			
		EMA:SettingsOthersRowClick( 1, 1 )
	end	
end

function EMA:RemoveOther()
	table.remove( EMA.db.autoSellOtherItemsList, EMA.settingsControlOthers.othersHighlightRow )
	EMA:SettingsRefresh()
	EMA:SettingsOthersRowClick( 1, 1 )		
end

function EMA:MERCHANT_SHOW()
	-- Sell Items
	if EMA.db.autoSellItem == true then
		EMA:DoMerchantSellItems()
	end
	-- Sell Other Items
	if EMA.db.autoSellOtherItems == true then
		EMA:ScheduleTimer( "DoMerchantSellOtherItems", 2 )
	end
end

function EMA:DoMerchantSellItems()
	local count = 0
	local gold = 0
	-- Iterate each bag the player has.		
	for bag = EMA.BAG_PLAYER_BACKPACK, EMA.BAG_PLAYER_MAXIMUM do 
		-- Iterate each slot in the bag.
		numSlots = GetContainerNumSlots( bag )
		for slot = 1, numSlots do 
		local _, itemCount, locked, _, _, _, link, _, hasNoValue = GetContainerItemInfo(bag, slot)
	
		--for bag,slot,link in LibBagUtils:Iterate("BAGS") do
			if bag ~= nil then
				if link ~= nil then	
				local canSell = false
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, iconFileDataID, itemSellPrice = GetItemInfo( link )	
				local _, itemCount = GetContainerItemInfo( bag, slot )
				--EMA:Print("Test", itemLink, itemRarity )
					if EMA.db.autoSellPoor == true then
						if itemRarity == EMA.ITEM_QUALITY_POOR then
							canSell = true
							if EMA.db.autoSellBoEPoor == true then 
								local isBop = EMAUtilities:ToolTipBagScaner(link, bag, slot)
								if isBop ~= ITEM_SOULBOUND then
								 --EMA:Print("BoE", link )
								 canSell = false
								end
							end	
						end
					end	
					-- Green
					if EMA.db.autoSellUncommon == true then
						if itemRarity == EMA.ITEM_QUALITY_UNCOMMON then
							if itemType == WEAPON or itemType == ARMOR or itemSubType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC then
								--EMA:Print("testGreen", link, itemRarity, "a", EMA.ITEM_QUALITY_UNCOMMON )
								local num = tonumber( EMA.db.autoSellIlvlUncommon )
								local iLvl = ItemUpgradeInfo:GetUpgradedItemLevel(link)
								--EMA:Print("test", num , "vs", iLvl, "item", link )
								if num ~= nil and iLvl ~= nil and ( itemLevel > EMA.MIN_ITEM_LEVEL ) then
									--if iLvl >= num then
									if num >= iLvl then	
										--EMA:Print("ture", link )
										canSell = true
									end
								end	
								if EMA.db.autoSellBoEUncommon == true then 
									local isBop = EMAUtilities:ToolTipBagScaner( link,bag,slot )
									--EMA:Print("IsBoP", isBop)									
									if isBop ~= ITEM_SOULBOUND then
										canSell = false
									end
								end
							end
						end
					end	
						--Blue
						if EMA.db.autoSellRare == true then
							if itemRarity == EMA.ITEM_QUALITY_RARE then
								if itemType == WEAPON or itemType == ARMOR or itemSubType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC then
									local num = tonumber( EMA.db.autoSellIlvlRare )
									local iLvl = ItemUpgradeInfo:GetUpgradedItemLevel(link)
									--EMA:Print("test", iLvl, "vs", num )
									if num ~= nil and iLvl ~= nil and (itemLevel > EMA.MIN_ITEM_LEVEL ) then
										if num >= iLvl then
											canSell = true
										end
									end	
									if EMA.db.autoSellBoERare == true then 
										local isBop = EMAUtilities:ToolTipBagScaner( link,bag,slot )
										--EMA:Print("IsBoP", isBop)
										if isBop ~= ITEM_SOULBOUND then
											canSell = false									
										end
									end
								end	
							end	
						end		
						-- Epic
						if EMA.db.autoSellEpic == true then
							if itemRarity == EMA.ITEM_QUALITY_EPIC then
								if itemType == WEAPON or itemType == ARMOR or itemSubType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC then
									local num = tonumber( EMA.db.autoSellIlvlEpic )
									local iLvl = ItemUpgradeInfo:GetUpgradedItemLevel(link)
									--EMA:Print("test", iLvl, "vs", num )
									if num ~= nil and iLvl ~= nil and (itemLevel > EMA.MIN_ITEM_LEVEL ) then
										if num >= iLvl then	
											canSell = true
										end
									end	
									if EMA.db.autoSellBoEEpic == true then 
										local isBop = EMAUtilities:ToolTipBagScaner( link,bag,slot )
										--EMA:Print("IsBoP", isBop)
										if isBop ~= ITEM_SOULBOUND then
											canSell = false
										end
									end
								end
							end	
						end
						if canSell == true then 
							if itemSellPrice ~= nil and itemSellPrice > 0 then
								if MerchantFrame:IsVisible() == true then
									if itemCount > 1 then
										count = count + itemCount
										gold = gold + itemSellPrice * itemCount
									else	
										count = count + 1
										gold = gold + itemSellPrice
									end
									UseContainerItem( bag, slot )	
								end
							end	
						end
					end	
				end
			end
		end
	if count > 0 then	
		local formattedGoldAmount = GetCoinTextureString(gold)
		EMA:EMASendMessageToTeam( EMA.db.messageArea, L["I_SOLD_ITEMS_PLUS_GOLD"]( count )..formattedGoldAmount, false )
	end
end

-- Sell Other Items! 
function EMA:DoMerchantSellOtherItems()
	-- Iterate all the wanted items...
	for position, itemInformation in pairs( EMA.db.autoSellOtherItemsList ) do
		-- Does this character have the item tag?  No, don't sell.
		if EMAApi.IsCharacterInGroup( EMA.characterName, itemInformation.tag ) == true then
			-- Attempt to sell any items in the players bags.
			-- Iterate each bag the player has.		
			for bag = EMA.BAG_PLAYER_BACKPACK, EMA.BAG_PLAYER_MAXIMUM do 
				-- Iterate each slot in the bag.
				for slot = 1, GetContainerNumSlots( bag ) do 
					-- Get the item link for the item in this slot.
					local bagItemLink = GetContainerItemLink( bag, slot )
					local _, _, locked, _, _, _, bagItemLink, _, hasNoValue = GetContainerItemInfo(bag, slot)
					-- If there is an item...
					if bagItemLink ~= nil then
						-- Does it match the item to sell?					
						if EMAUtilities:DoItemLinksContainTheSameItem( bagItemLink, itemInformation.link ) then
							-- Yes, sell this item.
							if hasNoValue == false then	
								if MerchantFrame:IsVisible() == true then	
									UseContainerItem( bag, slot ) 
								end
							else
								if 	locked == false then
									PickupContainerItem(bag,slot)
									DeleteCursorItem()
									EMA:EMASendMessageToTeam( EMA.db.messageArea, L["DELETE_ITEM"]( bagItemLink ), false )	
								end	
							end							
						end
					end
				end
			end
		end
	end
end

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if commandName == EMA.COMMAND_SELL_ITEM then
		EMA:DoSellItem( ... )
	end
end