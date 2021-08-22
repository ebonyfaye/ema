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

-- Olny Load on Live!
if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_MAINLINE then
	return
end	

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
--local LibBagUtils = LibStub:GetLibrary( "LibBagUtils-1.0" )
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
	 global = {
		['**'] = {
			autoGuildItemsListGlobal = {},
		},
	 },
	profile = {
		messageArea = EMAApi.DefaultMessageArea(),
		showEMAGuildWindow = false,
		globalGuildList = false,
		blackListItem = false,
		guildBoEItems = false,
		autoGuildBankTabBoE = "1",
		guildTagName = EMAApi.AllGroup(),
		autoBoEItemTag = EMAApi.AllGroup(),	
		guildCRItems = false,
		autoGuildBankTabCR = "1",
		autoGuildCRItemTag = EMAApi.AllGroup(),
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
			config = {
				type = "input",
				name = L["OPEN_CONFIG"],
				desc = L["OPEN_CONFIG_HELP"],
				usage = "/ema-guild config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_ALL_SETTINGS"],
				usage = "/ema-guild push",
				get = false,
				set = "EMASendSettings",
				guiHidden = true,
			},
			copy = {
				type = "input",
				name = L["COPY"],
				desc = L["COPY_HELP"],
				usage = "/ema-guild copy",
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
	EMA.settingsControl.tabNumListDropDownListBoE:SetList( EMA.simpleAreaList )
	EMA.settingsControl.tabNumListDropDownListCR:SetList( EMA.simpleAreaList )
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
	EMA:RegisterEvent( "GUILDBANKFRAME_OPENED" )
	EMA:RawHook( "ContainerFrameItemButton_OnModifiedClick", true)
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
	local indentContinueLabel = horizontalSpacing * 18
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local GuildWidth = headingWidth
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
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["GUILD_LIST_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxShowEMAGuildWindow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["GUILD_LIST"],
		EMA.SettingsToggleShowEMAGuildWindow,
		L["GUILD_LIST_HELP"]
	)	
	EMA.settingsControl.checkBoxGlobalGuildList = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3, 
		movingTop, 
		L["GLOBAL_LIST"],
		EMA.SettingsToggleGlobalGuildList,
		L["GLOBAL_SETTINGS_LIST_HELP"]
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
	list.columnsToDisplay = 4
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 40
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 10
	list.columnInformation[2].alignment = "LEFT"
	list.columnInformation[3] = {}
	list.columnInformation[3].width = 10
	list.columnInformation[3].alignment = "LEFT"	
	list.columnInformation[4] = {}
	list.columnInformation[4].width = 20
	list.columnInformation[4].alignment = "LEFT"
	list.scrollRefreshCallback = EMA.SettingsScrollRefresh
	list.rowClickCallback = EMA.SettingsGuildItemsRowClick
	EMA.settingsControl.GuildItems = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.GuildItems )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.GuildItemsButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50,  
		movingTop,
		L["REMOVE"],
		EMA.SettingsGuildItemsRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ADD_ITEMS"], movingTop, false )
	
	movingTop = movingTop - headingHeight
	EMA.settingsControl.GuildItemsEditBoxGuildItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		thirdWidth,
		left2,
		movingTop,
		L["ITEM_DROP"]
	)
	EMA.settingsControl.GuildItemsEditBoxGuildItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedGuildItem )
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
	
	EMA.settingsControl.tabNumListDropDownList = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["GB_TAB_LIST"]
	)
	EMA.settingsControl.tabNumListDropDownList:SetList( EMA.TabAreaList() )
	EMA.settingsControl.tabNumListDropDownList:SetCallback( "OnValueChanged",  EMA.GBTabDropDownList )
	--Group
	EMA.settingsControl.GuildItemsEditBoxGuildTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetCallback( "OnValueChanged",  EMA.GroupListDropDownList )
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.GuildItemsButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop, 
		L["ADD"],
		EMA.SettingsGuildItemsAddClick
	)
	movingTop = movingTop -	buttonHeight		
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["GB_OPTIONS"], movingTop, false )
	movingTop = movingTop - editBoxHeight - 3
	
	EMA.settingsControl.checkBoxGuildBoEItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop + movingTopEdit,
		L["GUILD_BOE_ITEMS"],
		EMA.SettingsToggleGuildBoEItems,
		L["GUILD_BOE_ITEMS_HELP"]
	)	
	EMA.settingsControl.tabNumListDropDownListBoE = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["GB_TAB_LIST"]
	)
	EMA.settingsControl.tabNumListDropDownListBoE:SetList( EMA.TabAreaList() )
	EMA.settingsControl.tabNumListDropDownListBoE:SetCallback( "OnValueChanged",  EMA.GBTabDropDownListBoE )	
	EMA.settingsControl.guildTradeBoEItemsTagBoE = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.guildTradeBoEItemsTagBoE:SetList( EMAApi.GroupList() )
	EMA.settingsControl.guildTradeBoEItemsTagBoE:SetCallback( "OnValueChanged",  EMA.GroupListDropDownListBoE)	
	
	movingTop = movingTop - editBoxHeight - 3
	EMA.settingsControl.checkBoxGuildCRItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop + movingTopEdit, 
		L["GUILD_REAGENTS"],
		EMA.SettingsToggleGuildCRItems,
		L["GUILD_REAGENTS_HELP"]
	)
	EMA.settingsControl.tabNumListDropDownListCR = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["GB_TAB_LIST"]
	)
	EMA.settingsControl.tabNumListDropDownListCR:SetList( EMA.TabAreaList() )
	EMA.settingsControl.tabNumListDropDownListCR:SetCallback( "OnValueChanged",  EMA.GBTabDropDownListCR )	
	EMA.settingsControl.guildTradeCRItemsTagCR = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.guildTradeCRItemsTagCR:SetList( EMAApi.GroupList() )
	EMA.settingsControl.guildTradeCRItemsTagCR:SetCallback( "OnValueChanged",  EMA.GroupListDropDownListCR )	
		
	movingTop = movingTop - editBoxHeight

	EMA.settingsControl.checkBoxAdjustMoneyOnToonViaGuildBank = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left + 110, 
		movingTop, 
		L["GB_GOLD"],
		EMA.SettingsToggleAdjustMoneyOnToonViaGuildBank,
		L["GB_GOLD_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		dropBoxWidth,
		left2,
		movingTop,
		L["GOLD_TO_KEEP"]
	)
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetCallback( "OnEnterPressed", EMA.EditBoxChangedGoldAmountToLeaveOnToon )
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
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[4].textString:SetText( "" )
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[4].textString:SetTextColor( 1.0, 0, 0, 1.0 )		
		EMA.settingsControl.GuildItems.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.GuildItemsOffset
		if dataRowNumber <= EMA:GetGuildItemsMaxPosition() then
			-- Put data information into columns.
			local guildItemsInformation = EMA:GetGuildItemsAtPosition( dataRowNumber )
			local blackListText = ""
			if guildItemsInformation.blackList == true then
				blackListText = L["ITEM_ON_BLACKLIST"]
			end
			EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[1].textString:SetText( guildItemsInformation.name )
			EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[2].textString:SetText( guildItemsInformation.GBTab )
			EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[3].textString:SetText( guildItemsInformation.tag )
			EMA.settingsControl.GuildItems.rows[iterateDisplayRows].columns[4].textString:SetText( blackListText )
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

function EMA:SettingsGuildItemsAddClick( event )
	if EMA.autoGuildItemLink ~= nil and EMA.autoGuildBankTab ~= nil and EMA.db.guildTagName ~= nil then
		EMA:AddItem( EMA.autoGuildItemLink, EMA.autoGuildBankTab, EMA.db.guildTagName, EMA.db.blackListItem )
		EMA.autoGuildItemLink = nil
		EMA.settingsControl.GuildItemsEditBoxGuildItem:SetText( "" )
		EMA:SettingsRefresh()
	end
end

function EMA:GroupListDropDownList (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.db.guildTagName = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleBlackListItem( event, checked ) 
	EMA.db.blackListItem = checked
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

function EMA:SettingsToggleGuildBoEItems(event, checked )
	EMA.db.guildBoEItems = checked
	EMA:SettingsRefresh()
end


function EMA:GBTabDropDownListBoE (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.db.autoGuildBankTabBoE = value
	EMA:SettingsRefresh()
end


function EMA:GroupListDropDownListBoE (event, value )
	-- if nil or the blank group then don't get Name.
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


function EMA:SettingsToggleGuildCRItems(event, checked )
	EMA.db.guildCRItems = checked
	EMA:SettingsRefresh()
end

function EMA:GBTabDropDownListCR (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.db.autoGuildBankTabCR = tonumber(value)
	EMA:SettingsRefresh()
end

function EMA:GroupListDropDownListCR (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.db.autoGuildCRItemTag = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:OnGroupAreasChanged( message )
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.guildTradeBoEItemsTagBoE:SetList( EMAApi.GroupList() )
	EMA.settingsControl.guildTradeCRItemsTagCR:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleGlobalGuildList( event, checked )
	EMA.db.globalGuildList = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleShowEMAGuildWindow( event, checked )
	EMA.db.showEMAGuildWindow = checked
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

function EMA:CopyListCommmand()
	EMA:Print("Copying Local List To Global List")
	EMA.db.global.autoGuildItemsListGlobal = EMAUtilities:CopyTable( EMA.db.autoGuildItemsList )
	EMA:SettingsRefresh()
end


-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.messageArea = settings.messageArea
		EMA.db.showEMAGuildWindow = settings.showEMAGuildWindow
		EMA.db.globalGuildList = settings.globalGuildList
		EMA.db.guildTagName = settings.guildTagName
		EMA.db.guildBoEItems = settings.guildBoEItems
		EMA.db.autoGuildBankTabBoE = settings.autoGuildBankTabBoE
		EMA.db.autoBoEItemTag = settings.autoBoEItemTag
		EMA.db.guildCRItems = settings.guildCRItems
		EMA.db.autoGuildBankTabCR = settings.autoGuildBankTabCR
		EMA.db.autoGuildCRItemTag = settings.autoGuildCRItemTag
		EMA.db.autoGuildItemsList = EMAUtilities:CopyTable( settings.autoGuildItemsList )
		EMA.db.global.autoGuildItemsListGlobal = EMAUtilities:CopyTable( settings.global.autoGuildItemsListGlobal )
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
	-- global CheckBox
	EMA.settingsControl.checkBoxGlobalGuildList:SetValue( EMA.db.globalGuildList )
	EMA.settingsControl.checkBoxGlobalGuildList:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetText( EMA.db.guildTagName )
	EMA.settingsControl.checkBoxGuildBoEItems:SetValue( EMA.db.guildBoEItems )
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetValue( EMA.db.blackListItem )
	EMA.settingsControl.tabNumListDropDownListBoE:SetText( EMA.db.autoGuildBankTabBoE )
	EMA.settingsControl.guildTradeBoEItemsTagBoE:SetText( EMA.db.autoBoEItemTag )
	EMA.settingsControl.checkBoxGuildCRItems:SetValue( EMA.db.guildCRItems )
	EMA.settingsControl.tabNumListDropDownListCR:SetText( EMA.db.autoGuildBankTabCR )
	EMA.settingsControl.guildTradeCRItemsTagCR:SetText( EMA.db.autoGuildCRItemTag )
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.checkBoxAdjustMoneyOnToonViaGuildBank:SetValue( EMA.db.adjustMoneyWithGuildBank )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetText( tostring( EMA.db.goldAmountToKeepOnToon ) )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetDisabled( not EMA.db.adjustMoneyWithGuildBank )
	EMA.settingsControl.GuildItemsEditBoxGuildItem:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.GuildItemsEditBoxGuildTag:SetDisabled( not EMA.db.showEMAGuildWindow )	
	EMA.settingsControl.tabNumListDropDownList:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.GuildItemsButtonRemove:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.GuildItemsButtonAdd:SetDisabled( not EMA.db.showEMAGuildWindow )	
	EMA.settingsControl.checkBoxGuildBoEItems:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.tabNumListDropDownListBoE:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.guildTradeBoEItemsTagBoE:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.checkBoxGuildCRItems:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.tabNumListDropDownListCR:SetDisabled( not EMA.db.showEMAGuildWindow )
	EMA.settingsControl.guildTradeCRItemsTagCR:SetDisabled( not EMA.db.showEMAGuildWindow )
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

function EMA:ContainerFrameItemButton_OnClick(self, event, ... )
	--EMA:Print("tester")
	if EMAPrivate.SettingsFrame.Widget:IsVisible() == true then	
		local GUIPanel = EMAPrivate.SettingsFrame.TreeGroupStatus.selected
		local currentModule = string.find(GUIPanel, EMA.moduleDisplayName) 
		--EMA:Print("test2", GUIPanel, "vs", currentModule )
		if currentModule ~= nil then
			local itemID, itemLink = GameTooltip:GetItem()
				--EMA:Print("test1", itemID, itemLink )
			if itemLink ~= nil then
				EMA.settingsControl.GuildItemsEditBoxGuildItem:SetText( itemLink )
				EMA.autoGuildItemLink = itemLink	
			end
		else
			return EMA.hooks["ContainerFrameItemButton_OnClick"]( self, event, ... )
		end
	else
		return EMA.hooks["ContainerFrameItemButton_OnClick"]( self, event, ... )
	end		
end

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
				EMA.settingsControl.GuildItemsEditBoxGuildItem:SetText( "" )
				EMA.settingsControl.GuildItemsEditBoxGuildItem:SetText( itemLink )
				EMA.autoGuildItemLink = itemLink
				return
			end
		end	
	end	
	return EMA.hooks["ContainerFrameItemButton_OnModifiedClick"]( self, event, ... )
end


function EMA:GetGuildItemsMaxPosition()
	if EMA.db.globalGuildList == true then
		return #EMA.db.global.autoGuildItemsListGlobal
	else
		return #EMA.db.autoGuildItemsList
	end	
end

function EMA:GetGuildItemsAtPosition( position )
	if EMA.db.globalGuildList == true then
		return EMA.db.global.autoGuildItemsListGlobal[position]
	else
		return EMA.db.autoGuildItemsList[position]
	end	
end

function EMA:AddItem( itemLink, GBTab, itemTag, blackList )
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
		itemInformation.blackList = blackList
		if EMA.db.globalGuildList == true then
			table.insert( EMA.db.global.autoGuildItemsListGlobal, itemInformation )
		else	
			table.insert( EMA.db.autoGuildItemsList, itemInformation )
		end
		EMA:SettingsRefresh()			
		EMA:SettingsGuildItemsRowClick( 1, 1 )
	end	
end

function EMA:RemoveItem()
	if EMA.db.globalGuildList == true then
		table.remove( EMA.db.global.autoGuildItemsListGlobal, EMA.settingsControl.GuildItemsHighlightRow )
	else
		table.remove( EMA.db.autoGuildItemsList, EMA.settingsControl.GuildItemsHighlightRow )
	end
	EMA:SettingsRefresh()
	EMA:SettingsGuildItemsRowClick( EMA.settingsControl.GuildItemsHighlightRow  - 1, 1 )		
end

function EMA:GUILDBANKFRAME_OPENED()
	if 	EMA.db.showEMAGuildWindow == true then
		if not IsShiftKeyDown() then
			EMA:AddAllToGuildBank()
		end	
	end
	if EMA.db.adjustMoneyWithGuildBank == true then
		if not IsShiftKeyDown() then
			AddGoldToGuildBank()
		end	
	end
end

function EMA:AddAllToGuildBank()
	local delay = 0
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1,GetContainerNumSlots( bagID ),1 do 
			--EMA:Print( "Bags OK. checking", itemLink )
			local item = Item:CreateFromBagAndSlot(bagID, slotID)
			if ( item ) then
				local bagItemLink = item:GetItemLink()
				if ( bagItemLink ) then	
					local itemLink = item:GetItemLink()
					local location = item:GetItemLocation()
					local itemType = C_Item.GetItemInventoryType( location )
					local isBop = C_Item.IsBound( location )
					local itemRarity =  C_Item.GetItemQuality( location )
					local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,isCraftingReagent = GetItemInfo( bagItemLink )
					local canPlace = false
					local bankTab = 0
					if EMA.db.guildBoEItems == true then
						if itemType ~= 0 then
							if EMAApi.IsCharacterInGroup(  EMA.characterName, EMA.db.autoBoEItemTag ) == true then
								if isBop == false then
									if itemRarity == 2 or itemRarity == 3 or itemRarity == 4 then	
										canPlace = true
										bankTab = EMA.db.autoGuildBankTabBoE
									end			
								end
							end										
						end									
					end	
					if EMA.db.guildCRItems == true then
						if isCraftingReagent == true then
							if EMAApi.IsCharacterInGroup(  EMA.characterName, EMA.db.autoGuildCRItemTag ) == true then
								if isBop == false then
									canPlace = true
									bankTab = EMA.db.autoGuildBankTabCR
								end
							end										
						end
					end
				
					if EMA.db.globalGuildList == true then
						itemTable = EMA.db.global.autoGuildItemsListGlobal
					else
						itemTable = EMA.db.autoGuildItemsList
					end
					for position, itemInformation in pairs( itemTable  ) do
						if EMAUtilities:DoItemLinksContainTheSameItem( itemLink, itemInformation.link ) then
							if EMAApi.IsCharacterInGroup(  EMA.characterName, itemInformation.tag ) == true then
								--EMA:Print("DataTest", itemInformation.link, itemInformation.blackList )
								--EMA:Print("test", itemLink)
								canPlace = true
								bankTab = itemInformation.GBTab
							end
							if itemInformation.blackList == true then
								canPlace = false
							end
						end
					end	
					--	EMA:Print("tester", canPlace, bankTab, itemLink, "a", bagID, slotID )
					if canPlace == true and bankTab ~= 0 then
						delay = delay + 1
						EMA:ScheduleTimer("PlaceItemInGuildBank", delay , bagID, slotID, bankTab )	
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

function EMA:PlaceItemInGuildBank(bagID, slotID, tab)
	if GuildBankFrame:IsVisible() == true then
		EMA:SelectBankTab( tab )				
		if GetCurrentGuildBankTab() == tab then
			local name, icon, isViewable, canDeposit = GetGuildBankTabInfo(tab)
			if canDeposit then
				for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do 
					local texture, count, locked = GetGuildBankItemInfo(tab, slot)
					if not locked then
						--PickupContainerItem( bagID ,slotID  )
						UseContainerItem( bagID ,slotID  )
					end
				end				
			end
		end	
	end
end

-- gold

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
	local formattedGoldAmount = GetCoinTextureString(money)
	EMA:EMASendMessageToTeam( EMA.db.messageArea, L["I_HAVE_DEPOSITED_X_TO_GB"]( formattedGoldAmount ), false )
end

function EMA:TakeMoneyOut( money )
	WithdrawGuildBankMoney( money )	
end