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
	 global = {
		['**'] = {
			autoSellOtherItemsListGlobal = {},
		},
	 },	
	profile = {
		sellItemOnAllWithAltKey = false,
		-- Other Items
		autoSellOtherItemsList = {},
		messageArea = EMAApi.DefaultMessageArea(),
		globalSellList = false,
		autoSellItem = false,
		blackListItem = false,
		--destroyItem = false,
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
		-- Toys
		autoSellToys = false,
		autoSellMounts = false,
		-- 9.0.3
		alreadyWipedLists = false	
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
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-sell push",
				get = false,
				set = "EMASendSettings",
			},
			copy = {
				type = "input",
				name = L["COPY"],
				desc = L["COPY_HELP"],
				usage = "/ema-sell copy",
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
EMA.MIN_ITEM_LEVEL = 5

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	-- Sell on all with alt key.
	EMA.settingsControl.checkBoxSellItemOnAllWithAltKey:SetValue( EMA.db.sellItemOnAllWithAltKey )
	-- global Sell CheckBox
	EMA.settingsControl.checkBoxGlobalSellList:SetValue( EMA.db.globalSellList )
	EMA.settingsControl.checkBoxGlobalSellList:SetDisabled( not EMA.db.autoSellItem )
	-- Auto sell Quality and Ilvl items.
	EMA.settingsControl.checkBoxAutoSellItems:SetValue( EMA.db.autoSellItem )	
	-- Poor
	EMA.settingsControl.checkBoxAutoSellPoor:SetValue ( EMA.db.autoSellPoor )
	EMA.settingsControl.checkBoxAutoSellBoEPoor:SetValue ( EMA.db.autoSellBoEPoor )
	EMA.settingsControl.checkBoxAutoSellPoor:SetDisabled ( not EMA.db.autoSellItem or not EMA.db.autoSellItem )
	EMA.settingsControl.checkBoxAutoSellBoEPoor:SetDisabled ( not EMA.db.autoSellPoor or not EMA.db.autoSellItem )
	-- Uncommon
	EMA.settingsControl.checkBoxAutoSellUncommon:SetValue (EMA.db.autoSellUncommon )
	EMA.settingsControl.editBoxAutoSellIlvlUncommon:SetText (EMA.db.autoSellIlvlUncommon )
	EMA.settingsControl.checkBoxAutoSellBoEUncommon:SetValue (EMA.db.autoSellBoEUncommon )
	EMA.settingsControl.checkBoxAutoSellUncommon:SetDisabled ( not EMA.db.autoSellItem )
	EMA.settingsControl.editBoxAutoSellIlvlUncommon:SetDisabled ( not EMA.db.autoSellUncommon or not EMA.db.autoSellItem )
	EMA.settingsControl.checkBoxAutoSellBoEUncommon:SetDisabled ( not EMA.db.autoSellUncommon or not EMA.db.autoSellItem )	
	-- Rare
	EMA.settingsControl.checkBoxAutoSellRare:SetValue (EMA.db.autoSellRare )
	EMA.settingsControl.editBoxAutoSellIlvlRare:SetText (EMA.db.autoSellIlvlRare )
	EMA.settingsControl.checkBoxAutoSellBoERare:SetValue (EMA.db.autoSellBoERare )
	EMA.settingsControl.checkBoxAutoSellRare:SetDisabled ( not EMA.db.autoSellItem )
	EMA.settingsControl.editBoxAutoSellIlvlRare:SetDisabled ( not EMA.db.autoSellRare or not EMA.db.autoSellItem  )
	EMA.settingsControl.checkBoxAutoSellBoERare:SetDisabled ( not EMA.db.autoSellRare or not EMA.db.autoSellItem )	
	-- Epic
	EMA.settingsControl.checkBoxAutoSellEpic:SetValue ( EMA.db.autoSellEpic )
	EMA.settingsControl.editBoxAutoSellIlvlEpic:SetText ( EMA.db.autoSellIlvlEpic)
	EMA.settingsControl.checkBoxAutoSellBoEEpic:SetValue ( EMA.db.autoSellBoEEpic )
	EMA.settingsControl.checkBoxAutoSellEpic:SetDisabled ( not EMA.db.autoSellItem )
	EMA.settingsControl.editBoxAutoSellIlvlEpic:SetDisabled ( not EMA.db.autoSellEpic or not EMA.db.autoSellItem )
	EMA.settingsControl.checkBoxAutoSellBoEEpic:SetDisabled ( not EMA.db.autoSellEpic or not EMA.db.autoSellItem )		
	-- Toys
	EMA.settingsControl.checkBoxAutoSellToys:SetValue( EMA.db.autoSellToys )
	EMA.settingsControl.checkBoxAutoSellToys:SetDisabled ( not EMA.db.autoSellItem )
EMA.settingsControl.checkBoxAutoSellMounts:SetValue( EMA.db.autoSellMounts )
	EMA.settingsControl.checkBoxAutoSellMounts:SetDisabled ( not EMA.db.autoSellItem )	
	-- Messages.
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	-- list. 
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetValue( EMA.db.blackListItem )
	--EMA.settingsControl.listCheckBoxBoxOtherDestroy:SetValue( EMA.db.destroyItem )
	EMA.settingsControl.listEditBoxOtherTag:SetText( EMA.autoSellOtherItemTag )
	EMA.settingsControl.listEditBoxOtherItem:SetDisabled( not EMA.db.autoSellItem )
	EMA.settingsControl.listEditBoxOtherTag:SetDisabled( not EMA.db.autoSellItem )
	EMA.settingsControl.listButtonRemove:SetDisabled( not EMA.db.autoSellItem )
	EMA.settingsControl.listButtonAdd:SetDisabled( not EMA.db.autoSellItem )
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetDisabled( not EMA.db.autoSellItem or not EMA.db.autoSellItem )
	--EMA.settingsControl.listCheckBoxBoxOtherDestroy:SetDisabled( not EMA.db.autoSellItem or not EMA.db.autoSellItem )
	--EMA.settingsControl.listEditBoxOtherItem:RegisterForClicks( "RightButtonDown" )
	
	
	EMA:SettingslistScrollRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.sellItemOnAllWithAltKey = settings.sellItemOnAllWithAltKey
		EMA.db.globalSellList = settings.globalSellList
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
		EMA.db.autoSellToys = settings.autoSellToys
		EMA.db.autoSellMounts = settings.autoSellMounts
		EMA.db.blackListItem = settings.blackListItem
		EMA.db.destroyItem = settings.destroyItem 
		EMA.db.messageArea = settings.messageArea
		EMA.db.autoSellOtherItemsList = EMAUtilities:CopyTable( settings.autoSellOtherItemsList )
		EMA.db.global.autoSellOtherItemsListGlobal = EMAUtilities:CopyTable( settings.global.autoSellOtherItemsListGlobal )
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
	local indentContinueLabel = horizontalSpacing * 18
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local dropBoxWidth = (headingWidth - horizontalSpacing) / 4
	local listWidth = headingWidth
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - indentContinueLabel) / 3
	local left2 = left + thirdWidth +  horizontalSpacing
	local left3 = left2 + thirdWidth +  horizontalSpacing
	local movingTop = top
	local movingTopEdit = - 10
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
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["SELL_LIST"], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.checkBoxAutoSellItems = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["AUTO_SELL_ITEMS"],
		EMA.SettingsToggleAutoSellItems,
		L["AUTO_SELL_ITEMS_HELP"]
	)	
	EMA.settingsControl.checkBoxGlobalSellList = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3, 
		movingTop, 
		L["GLOBAL_LIST"],
		EMA.SettingsToggleGlobalSellList,
		L["GLOBAL_SETTINGS_LIST_HELP"]
	)	
	
	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.listHighlightRow = 1
	EMA.settingsControl.listOffset = 1
	local list = {}
	list.listFrameName = "EMASellSettingslistFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = listWidth
	list.rowHeight = 15
	list.rowsToDisplay = 8
	list.columnsToDisplay = 3
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 60
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 20
	list.columnInformation[2].alignment = "LEFT"
	list.columnInformation[3] = {}
	list.columnInformation[3].width = 20
	list.columnInformation[3].alignment = "LEFT"
	--[[
	list.columnInformation[4] = {}
	list.columnInformation[4].width = 20
	list.columnInformation[4].alignment = "LEFT"	
	]]
	list.scrollRefreshCallback = EMA.SettingslistScrollRefresh
	list.rowClickCallback = EMA.SettingslistRowClick
	EMA.settingsControl.list = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.list )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.listButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop,
		L["REMOVE"],
		EMA.SettingslistRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ADD_TO_LIST"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.listEditBoxOtherItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		thirdWidth,
		left2,
		movingTop,
		L["ITEM_DROP"]
	)
	EMA.settingsControl.listEditBoxOtherItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedOtherItem )
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
	--[[
	EMA.settingsControl.listCheckBoxBoxOtherDestroy = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2,
		movingTop + movingTopEdit,
		L["DESTROY_ITEM"],
		EMA.SettingsToggleDestroyItem,
		L["DESTROY_ITEM_HELP"]
	)
	]]
	EMA.settingsControl.listEditBoxOtherTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		dropBoxWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.listEditBoxOtherTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.listEditBoxOtherTag:SetCallback( "OnValueChanged",  EMA.SellOtherGroupDropDownList )	
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.listButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop, 
		L["ADD"],
		EMA.SettingslistAddClick
	)
	movingTop = movingTop -	buttonHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["SELL_ITEMS"], movingTop, false )
	--movingTop = movingTop - headingHeight
	-- Gray
	movingTop = movingTop - checkBoxHeight - 3
	EMA.settingsControl.checkBoxAutoSellPoor = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left,
		movingTop,
		L["SELL_GRAY"],
		EMA.SettingsToggleAutoSellPoor,
		L["SELL_GRAY_HELP"]
	)
	EMA.settingsControl.checkBoxAutoSellBoEPoor = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2,
		movingTop,
		L["ONLY_SB"],
		EMA.SettingsToggleAutoSellBoEPoor,
		L["ONLY_SB_HELP"]
	)
-- Green	
	movingTop = movingTop - checkBoxHeight - 3
	EMA.settingsControl.checkBoxAutoSellUncommon = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left,
		movingTop + movingTopEdit,
		L["SELL_GREEN"],
		EMA.SettingsToggleAutoSellUncommon,
		L["SELL_GREEN_HELP"]
	)
	EMA.settingsControl.checkBoxAutoSellBoEUncommon = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2,
		movingTop + movingTopEdit,
		L["ONLY_SB"],
		EMA.SettingsToggleAutoSellBoEUncommon,
		L["ONLY_SB_HELP"]
	)
	EMA.settingsControl.editBoxAutoSellIlvlUncommon = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left3,
		movingTop,
		L["iLVL"],
		L["iLVL_HELP"]
	)	
	EMA.settingsControl.editBoxAutoSellIlvlUncommon:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedIlvlUncommon )	
-- Rare
	movingTop = movingTop - editBoxHeight - 3	
	EMA.settingsControl.checkBoxAutoSellRare = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left,
		movingTop + movingTopEdit,
		L["SELL_RARE"],
		EMA.SettingsToggleAutoSellRare,
		L["SELL_RARE_HELP"]
	)
	EMA.settingsControl.checkBoxAutoSellBoERare = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2,
		movingTop + movingTopEdit,
		L["ONLY_SB"],
		EMA.SettingsToggleAutoSellBoERare,
		L["ONLY_SB_HELP"]
	)
	EMA.settingsControl.editBoxAutoSellIlvlRare = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left3,
		movingTop,
		L["iLVL"],
		L["iLVL_HELP"]
	)	
	EMA.settingsControl.editBoxAutoSellIlvlRare:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedIlvlRare )		
-- Epic
	movingTop = movingTop - editBoxHeight - 3
	EMA.settingsControl.checkBoxAutoSellEpic = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left,
		movingTop + movingTopEdit,
		L["SELL_EPIC"],
		EMA.SettingsToggleAutoSellEpic,
		L["SELL_EPIC_HELP"]
	)
	EMA.settingsControl.checkBoxAutoSellBoEEpic = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2,
		movingTop + movingTopEdit,
		L["ONLY_SB"],
		EMA.SettingsToggleAutoSellBoEEpic,
		L["ONLY_SB_HELP"]
	)
	EMA.settingsControl.editBoxAutoSellIlvlEpic = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left3,
		movingTop,
		L["iLVL"],
		L["iLVL_HELP"]
	)	
	EMA.settingsControl.editBoxAutoSellIlvlEpic:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedIlvlEpic )		
-- Toy	
	movingTop = movingTop - editBoxHeight - 3	
	EMA.settingsControl.checkBoxAutoSellToys = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop + movingTopEdit, 
		L["AUTO_SELL_TOYS"],
		EMA.SettingsToggleAutoSellToys,
		L["AUTO_SELL_TOYS_HELP"]
	)
EMA.settingsControl.checkBoxAutoSellMounts = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		thirdWidth, 
		left2, 
		movingTop + movingTopEdit, 
		L["AUTO_SELL_MOUNTS"],
		EMA.SettingsToggleAutoSellMounts,
		L["AUTO_SELL_MOUNTS_HELP"]
	)		
	movingTop = movingTop - editBoxHeight - 3	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["SELL"]..L[" "]..L["MESSAGES_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		thirdWidth, 
		left2, 
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
	local bottomOfSell = SettingsCreateMain( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfSell )
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

-------------------------------------------------------------------------------------------------------------
-- Settings Callbacks.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingslistScrollRefresh()
	FauxScrollFrame_Update(
		EMA.settingsControl.list.listScrollFrame, 
		EMA:GetlistMaxPosition(),
		EMA.settingsControl.list.rowsToDisplay, 
		EMA.settingsControl.list.rowHeight
	)
	EMA.settingsControl.listOffset = FauxScrollFrame_GetOffset( EMA.settingsControl.list.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.list.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[3].textString:SetText( "" )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[3].textString:SetTextColor( 1.0, 0, 0, 1.0 )
		--EMA.settingsControl.list.rows[iterateDisplayRows].columns[4].textString:SetText( "" )
		--EMA.settingsControl.list.rows[iterateDisplayRows].columns[4].textString:SetTextColor( 1.0, 0, 0, 1.0 )
		
		EMA.settingsControl.list.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.listOffset
		if dataRowNumber <= EMA:GetlistMaxPosition() then
			-- Put data information into columns
			local listInformation = EMA:GetOtherAtPosition( dataRowNumber )
			local blackListText = ""
			local destroyText = ""
			if listInformation.blackList == true then
				blackListText = L["ITEM_ON_BLACKLIST"]
			end
			if 	listInformation.destroyItem == true then
				destroyText = L["DESTROY_ITEM"]
			end
			EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetText( listInformation.name )
			EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetText( listInformation.tag )
			EMA.settingsControl.list.rows[iterateDisplayRows].columns[3].textString:SetText( blackListText )
			--EMA.settingsControl.list.rows[iterateDisplayRows].columns[4].textString:SetText( destroyText )	
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.listHighlightRow then
				EMA.settingsControl.list.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingslistRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.listOffset + rowNumber <= EMA:GetlistMaxPosition() then
		EMA.settingsControl.listHighlightRow = EMA.settingsControl.listOffset + rowNumber
		EMA:SettingslistScrollRefresh()
	end
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleSellItemOnAllWithAltKey( event, checked )
	EMA.db.sellItemOnAllWithAltKey = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoSellToys( event, checked )
	EMA.db.autoSellToys = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleAutoSellMounts( event, checked )
	EMA.db.autoSellMounts = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleAutoSellItems( event, checked )
	EMA.db.autoSellItem = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleGlobalSellList( event, checked )
	EMA.db.globalSellList = checked
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
	EMA.settingsControl.listEditBoxOtherTag:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingslistRemoveClick( event )
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

function EMA:SettingsToggleBlackListItem( event, checked ) 
	EMA.db.blackListItem = checked
	EMA:SettingsRefresh()
end	

--[[
function EMA:SettingsToggleDestroyItem( event, checked )
	EMA.db.destroyItem = checked
	EMA:SettingsRefresh()
end	
]]

function EMA:SettingslistAddClick( event )
	--EMA:Print("test",  EMA.autoSellOtherItemLink, EMA.autoSellOtherItemTag )
	if EMA.autoSellOtherItemLink ~= nil and EMA.autoSellOtherItemTag ~= nil then
		EMA:AddOther( EMA.autoSellOtherItemLink, EMA.autoSellOtherItemTag, EMA.db.blackListItem ) --,  EMA.db.destroyItem  )
		EMA.autoSellOtherItemLink = nil
		EMA.settingsControl.listEditBoxOtherItem:SetText( "" )
		EMA:SettingsRefresh()
	end
end

function EMA:CopyListCommmand()
	EMA:Print("Copying Local List To Global List")
	EMA.db.global.autoSellOtherItemsListGlobal = EMAUtilities:CopyTable( EMA.db.autoSellOtherItemsList )
	EMA:SettingsRefresh()
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
	EMA.autoSellOtherItemTag = EMAApi.AllGroup()
	EMA.TrySellIAgainCount = 15
	EMA.sellCountTotal = 0
	EMA.sellGoldTotal = 0
	EMA.SellFristTime = true
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	-- 9.0.3 Remove DESTROY_ITEM
	EMA:ClearList()
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "MERCHANT_SHOW" )
	EMA:RegisterEvent( "MERCHANT_CLOSED" )
	-- Hook the item click event.
	EMA:RawHook( "ContainerFrameItemButton_OnModifiedClick", true )
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	EMA:RegisterMessage( EMAApi.GROUP_LIST_CHANGED , "OnGroupAreasChanged" )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-------------------------------------------------------------------------------------------------------------
-- Sell functionality.
-------------------------------------------------------------------------------------------------------------

-- The ContainerFrameItemButton_OnModifiedClick hook.
function EMA:ContainerFrameItemButton_OnModifiedClick( self, event, ... )
	if EMA.db.sellItemOnAllWithAltKey == true and IsAltKeyDown() and EMAUtilities:MerchantFrameIsShown() then
		local bag, slot = self:GetParent():GetID(), self:GetID()
		local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo( bag, slot )
		EMA:EMASendCommandToTeam( EMA.COMMAND_SELL_ITEM, link )
	end
	local isConfigOpen = EMAPrivate.SettingsFrame.Widget:IsVisible()
	if isConfigOpen == true and IsShiftKeyDown() == true then
		local GUIPanel = EMAPrivate.SettingsFrame.TreeGroupStatus.selected
		local currentModule = string.find(GUIPanel, EMA.moduleDisplayName) 
		--EMA:Print("test2", GUIPanel, "vs", currentModule )
		if currentModule ~= nil then
			local itemID, itemLink = GameTooltip:GetItem()
			--EMA:Print("test1", itemID, itemLink )
			if itemLink ~= nil then
				EMA.settingsControl.listEditBoxOtherItem:SetText( "" )
				EMA.settingsControl.listEditBoxOtherItem:SetText( itemLink )
				EMA.autoSellOtherItemLink = itemLink
				return
			end
		end	
	end	
	return EMA.hooks["ContainerFrameItemButton_OnModifiedClick"]( self, event, ... )
end

function EMA:DoSellItem( itemlink )
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1,GetContainerNumSlots( bagID ),1 do 
			--EMA:Print( "Bags OK. checking", itemLink )
			local item = Item:CreateFromBagAndSlot(bagID, slotID)
			if ( item ) then
				local bagItemLink = item:GetItemLink()
				local bagItemName = item:GetItemName()
				if (bagItemLink ) then
					if EMAUtilities:DoItemLinksContainTheSameItem( bagItemLink, itemlink ) then
						if EMAUtilities:MerchantFrameIsShown() == true then	
							UseContainerItem( bagID, slotID ) 
							-- Tell the Boss.
							EMA:EMASendMessageToTeam( EMA.db.messageArea, L["I_HAVE_SOLD_X"]( bagItemLink ), false )
						end
					end
				end
			end
		end
	end
end	

function EMA:GetlistMaxPosition()
	if EMA.db.globalSellList == true then
		return #EMA.db.global.autoSellOtherItemsListGlobal
	else
		return #EMA.db.autoSellOtherItemsList
	end
end

function EMA:GetOtherAtPosition( position )
	if EMA.db.globalSellList == true then
		return EMA.db.global.autoSellOtherItemsListGlobal[position]
	else
		return EMA.db.autoSellOtherItemsList[position]
	end
end

function EMA:AddOther( itemLink, itemTag, blackList) --, destroy )
	--EMA:Print( itemLink, itemTag, blackList, destroy )
	-- Get some more information about the item.
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemLink )
	-- If the item could be found.
	if name ~= nil then
		local itemInformation = {}
		itemInformation.link = itemLink
		itemInformation.name = name
		itemInformation.tag = itemTag
		itemInformation.blackList = blackList
		itemInformation.destroyItem = destroy
		if EMA.db.globalSellList == true then
			table.insert( EMA.db.global.autoSellOtherItemsListGlobal, itemInformation )
		else
			table.insert( EMA.db.autoSellOtherItemsList, itemInformation )
		end
		EMA:SettingsRefresh()
		EMA:SettingslistRowClick( EMA:GetlistMaxPosition() , 1 )
	end	
end

function EMA:RemoveOther()
	--EMA:Print("test", EMA.settingsControl.listHighlightRow)
	if EMA.db.globalSellList == true then
		table.remove( EMA.db.global.autoSellOtherItemsListGlobal, EMA.settingsControl.listHighlightRow )
	else
		table.remove( EMA.db.autoSellOtherItemsList, EMA.settingsControl.listHighlightRow )
	end
	EMA:SettingsRefresh()
	EMA:SettingslistRowClick( EMA.settingsControl.listHighlightRow -1,  1 )		
end

function EMA:MERCHANT_SHOW()
	-- Sell Items
	if EMA.db.autoSellItem == true then
		EMA:ScheduleTimer("DoMerchantSellItems", 0.5 ) 
	end
end

function EMA:MERCHANT_CLOSED()
	if EMA.db.autoSellItem == true then
		EMA.TrySellIAgainCount = 10
		EMA.sellCountTotal = 0
		EMA.sellGoldTotal = 0
		EMA.SellFristTime = true
	end
end	


function EMA:DoMerchantSellItems()
	local count = 0
	local sellCount = 0
	local gold = 0
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1,GetContainerNumSlots( bagID ) do 
			--EMA:Print( "Bags OK. checking", itemLink )
			local item = Item:CreateFromBagAndSlot(bagID, slotID)
			if ( item ) then
				local bagItemID = item:GetItemID()
				if ( bagItemID ) then
					local itemLink = item:GetItemLink()
					local location = item:GetItemLocation()
					local itemType = C_Item.GetItemInventoryType( location )
					local isBop = C_Item.IsBound( location )
					local itemRarity =  C_Item.GetItemQuality( location )
					local iLvl = C_Item.GetCurrentItemLevel( location )
					local _, itemCount = GetContainerItemInfo( bagID, slotID )
					local itemName, _, _, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo( itemLink )
					local hasToy = PlayerHasToy(bagItemID)
					--EMA:Print("ItemTest", bagItemID, itemLink, itemRarity, itemType, isBop, itemRarity, iLvl, itemSellPrice)
					local canSell = false
					local canDestroy = false
					if EMA.db.autoSellPoor == true then
						if itemRarity == EMA.ITEM_QUALITY_POOR then
							canSell = true
							if EMA.db.autoSellBoEPoor == true then 
								if isBop == false then
								 canSell = false
								end
							end	
						end
					end	
					-- Green
					if EMA.db.autoSellUncommon == true then
						if itemRarity == EMA.ITEM_QUALITY_UNCOMMON then
							if itemType ~= 0 then
								--EMA:Print("testGreen", itemLink, itemRarity, "a", EMA.ITEM_QUALITY_UNCOMMON )
								local num = tonumber( EMA.db.autoSellIlvlUncommon )
								--EMA:Print("testGreen", num , "vs", iLvl, "item", link )
								if num ~= nil and iLvl ~= nil and ( iLvl > EMA.MIN_ITEM_LEVEL ) then
									if num >= iLvl then	
										--EMA:Print("canSell" )
										canSell = true
									end
								end	
								if EMA.db.autoSellBoEUncommon == true then 
									--EMA:Print("IsBoP", isBop)									
									if isBop == false then
										canSell = false
									end
								end
							end
						end
					end	
					--Blue
					if EMA.db.autoSellRare == true then
						if itemRarity == EMA.ITEM_QUALITY_RARE then
							if itemType ~= 0 then
								--EMA:Print("testGreen", itemLink, itemRarity, "a", EMA.ITEM_QUALITY_RARE )
								local num = tonumber( EMA.db.autoSellIlvlRare )
								--EMA:Print("testGreen", num , "vs", iLvl, "item", link )
								if num ~= nil and iLvl ~= nil and ( iLvl > EMA.MIN_ITEM_LEVEL ) then
									if num >= iLvl then	
										--EMA:Print("canSell" )
										canSell = true
									end
								end	
								if EMA.db.autoSellBoERare == true then 
									--EMA:Print("IsBoP", isBop)									
									if isBop == false then
										canSell = false
									end
								
								end
							end
						end
					end	
					-- Epic
					if EMA.db.autoSellEpic == true then
						if itemRarity == EMA.ITEM_QUALITY_EPIC then
							if itemType ~= 0 then
								--EMA:Print("testGreen", itemLink, itemRarity, "a", EMA.ITEM_QUALITY_EPIC )
								local num = tonumber( EMA.db.autoSellIlvlEpic )
								--EMA:Print("testGreen", num , "vs", iLvl, "item", link )
								if num ~= nil and iLvl ~= nil and ( iLvl > EMA.MIN_ITEM_LEVEL ) then
									if num >= iLvl then	
										--EMA:Print("canSell")
										canSell = true
									end
								end	
								if EMA.db.autoSellBoEEpic == true then 
									--local isBop = EMAUtilities:ToolTipBagScaner( link,bag,slot )
									--EMA:Print("IsBoP", isBop)									
									if isBop == false then
										canSell = false
									end
								end
							end
						end
					end		
					-- Toys
					if EMA.db.autoSellToys == true then
						if hasToy == true and isBop == true then
							--EMA:Print("ToyTest", hasToy, itemSellPrice )
							if itemSellPrice > 0 then 
								--EMA:Print("canSellToy")
								canSell = true
							else
								--EMA:Print("canNotSellToy")
								canSell = true
								--canDestroy = true
							end						
						end
					end
					-- Mounts
					if EMA.db.autoSellMounts == true then	
						local mountIDs = C_MountJournal.GetMountIDs()	
						for i = 1, #mountIDs do
							local creatureName,mountSpellID,_,_,_,_,_,_,_,_, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountIDs[i])
							if itemName == creatureName then
								--EMA:Print("found a mount", creatureName)
								if isCollected == true and isBop == true then
									--EMA:Print("Mount is Known!", creatureName )
									if itemSellPrice > 0 then 
										--EMA:Print("canSellToy")
										canSell = true
									else
										--EMA:Print("canNotSellToy")
										canSell = true
										--canDestroy = true
									end				
								end
							end
						end		
					end
					-- Sell List/BackList
					if EMA.db.globalSellList == true then
						itemTable = EMA.db.global.autoSellOtherItemsListGlobal
					else
						itemTable = EMA.db.autoSellOtherItemsList
					end	
						for position, itemInformation in pairs( itemTable ) do
						if EMAApi.IsCharacterInGroup( EMA.characterName, itemInformation.tag ) == true then
							if EMAUtilities:DoItemLinksContainTheSameItem( itemLink, itemInformation.link ) then
								--EMA:Print("DataTest", itemInformation.blackList, itemInformation.destroyItem )
								--EMA:Print("test", itemLink)
								canSell = true
								if itemInformation.blackList == true then
									canSell = false
								end
							end
						end
					end
					if canSell == true then 
						--EMA:Print("END OF LOOT", canSell, itemLink, itemCount)
						if itemSellPrice ~= nil and itemSellPrice > 0 then
							if EMAUtilities:MerchantFrameIsShown() == true then	
								if itemCount > 1 then
									count = count + itemCount
									gold = gold + itemSellPrice * itemCount
								else	
									count = count + 1
									gold = gold + itemSellPrice
								end
								sellCount = sellCount + 0.4
								--UseContainerItem( bagID, slotID )	
								
								--EMA:Print("can sell now", bagID, slotID )
								EMA:ScheduleTimer("SellItem", sellCount, bagID, slotID, itemCount )
							end
						end	
					end
				end	
			end
		end
	end	
	if count > 0 then
		EMA:ScheduleTimer("TellTeam", sellCount + 1 , count, gold )
	end
end


function EMA:SellItem( bagID, slotID, itemCount )
	--EMA:Print("sellItem", bagID, slotID )
	if EMAUtilities:MerchantFrameIsShown() == true then	
		UseContainerItem( bagID, slotID )		
	end	
end


function EMA:TellTeam( count, gold  )
	--EMA:Print("tellTeam", count, gold )
	if count > 0 then 
		local formattedGoldAmount = GetCoinTextureString(gold)
		EMA:EMASendMessageToTeam( EMA.db.messageArea, L["I_SOLD_ITEMS_PLUS_GOLD"]( count )..formattedGoldAmount, false )	
	end
end

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if commandName == EMA.COMMAND_SELL_ITEM then
		EMA:DoSellItem( ... )
	end
end

-- 9.0.3 Remove destroyItem from the tables
function EMA:ClearList()
	if EMA.db.alreadyWipedLists	== false then	
		local itemTable = EMA.db.global.autoSellOtherItemsListGlobal
		local itemTableTwo = EMA.db.autoSellOtherItemsList
		for position, itemInformation in pairs( itemTable ) do
			if itemInformation.destroyItem == true then
				table.remove( EMA.db.global.autoSellOtherItemsListGlobal, position )
			end
		end
		for position, itemInformation in pairs( itemTableTwo ) do
			if itemInformation.destroyItem == true then
				table.remove( EMA.db.autoSellOtherItemsList, position )
			end
		end
		EMA:SettingsRefresh()
		EMA.db.alreadyWipedLists = true
	end
end	

EMAApi.ClearList = EMA.ClearList