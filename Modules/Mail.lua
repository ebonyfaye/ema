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
	"Mail", 
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
EMA.moduleName = "Mail"
EMA.settingsDatabaseName = "MailProfileDB"
EMA.chatCommand = "ema-Mail"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["INTERACTION"]
EMA.moduleDisplayName = L["Mail"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\MailIcon.tga"
-- order
EMA.moduleOrder = 20

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	 global = {
		['**'] = {
			autoMailItemsListGlobal = {},
		},
	 },	
	profile = {
		messageArea = EMAApi.DefaultMessageArea(),
		showEMAMailWindow = false,
		globalMailList = false,
		blackListItem = false,
		MailBoEItems = false,
		autoMailToonNameBoE = "",
		MailTagName = EMAApi.AllGroup(),
		autoBoEItemTag = EMAApi.AllGroup(),	
		MailCRItems = false,
		autoMailToonNameCR = "",
		autoCRItemTag = EMAApi.AllGroup(),
		MailRecipeFItems = false,
		autoMailToonNameRecipeF = "",
		autoRecipeFItemTag = EMAApi.AllGroup(),
		autoMailItemsList = {},
		
		adjustMoneyWithMail = false,
		goldAmountToKeepOnToon = 250,
		autoMailToonNameGold = "",
		autoMailMoneyTag = EMAApi.AllGroup(),
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
				usage = "/ema-mail config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_ALL_SETTINGS"],
				usage = "/ema-mail push",
				get = false,
				set = "EMASendSettings",
				guiHidden = true,
			},
			copy = {
				type = "input",
				name = L["COPY"],
				desc = L["COPY_HELP"],
				usage = "/ema-mail copy",
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
	StaticPopupDialogs["EMAMail_CONFIRM_REMOVE_MAIL_ITEMS"] = {
        text = L["REMOVE_MAIL_LIST"],
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

------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	EMA.autoMailItemLink = nil
	EMA.autoMailToonName = nil
	EMA.MailItemTable = {}
	EMA.ShiftkeyDown = false
	EMA.OldMailName = ""
	EMA.Count = 0
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialse the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "MAIL_SHOW" )
	EMA:RegisterEvent( "MAIL_CLOSED" )
	EMA:RegisterEvent( "MAIL_SEND_SUCCESS")
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
	local bottomOfInfo = EMA:SettingsCreateMail( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsCreateMail( top )
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
	local MailWidth = headingWidth
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
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["MAIL_LIST_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxShowEMAMailWindow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["MAIL_LIST"],
		EMA.SettingsToggleShowEMAMailWindow,
		L["MAIL_LIST_HELP"]
	)	
	EMA.settingsControl.checkBoxGlobalMailList = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3, 
		movingTop, 
		L["GLOBAL_LIST"],
		EMA.SettingsToggleGlobalMailList,
		L["GLOBAL_SETTINGS_LIST_HELP"]
	)		
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.MailItemsHighlightRow = 1
	EMA.settingsControl.MailItemsOffset = 1
	local list = {}
	list.listFrameName = "EMAMailIteamsSettingsFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = MailWidth
	list.rowHeight = 15
	list.rowsToDisplay = 10
	list.columnsToDisplay = 4
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
	list.columnInformation[4] = {}
	list.columnInformation[4].width = 20
	list.columnInformation[4].alignment = "LEFT"
	list.scrollRefreshCallback = EMA.SettingsScrollRefresh
	list.rowClickCallback = EMA.SettingsMailItemsRowClick
	EMA.settingsControl.MailItems = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.MailItems )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.MailItemsButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50,  
		movingTop,
		L["REMOVE"],
		EMA.SettingsMailItemsRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ADD_ITEMS"], movingTop, false )
	
	movingTop = movingTop - headingHeight
	EMA.settingsControl.MailItemsEditBoxMailItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		thirdWidth,
		left2,
		movingTop,
		L["ITEM_DROP"]
	)
	EMA.settingsControl.MailItemsEditBoxMailItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedMailItem )
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
	
	EMA.settingsControl.tabNumListDropDownList = EMAHelperSettings:CreateEditBox(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["MAILTOON"]
	)
	EMA.settingsControl.tabNumListDropDownList:SetCallback( "OnEnterPressed",  EMA.EditMailToonName )
	--Group
	EMA.settingsControl.MailItemsEditBoxMailTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.MailItemsEditBoxMailTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.MailItemsEditBoxMailTag:SetCallback( "OnValueChanged",  EMA.GroupListDropDownList )
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.MailItemsButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop, 
		L["ADD"],
		EMA.SettingsMailItemsAddClick
	)
	movingTop = movingTop -	buttonHeight		
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["Mail_OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
	
	EMA.settingsControl.checkBoxMailBoEItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop + movingTopEdit,
		L["MAIL_BOE_ITEMS"],
		EMA.SettingsToggleMailBoEItems,
		L["MAIL_BOE_ITEMS_HELP"]
	)	
	EMA.settingsControl.tabNumListDropDownListBoE = EMAHelperSettings:CreateEditBox(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["MAILTOON"]
	)
	EMA.settingsControl.tabNumListDropDownListBoE:SetCallback( "OnEnterPressed",  EMA.EditMailToonNameBoE )	
	EMA.settingsControl.MailTradeBoEItemsTagBoE = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.MailTradeBoEItemsTagBoE:SetList( EMAApi.GroupList() )
	EMA.settingsControl.MailTradeBoEItemsTagBoE:SetCallback( "OnValueChanged",  EMA.GroupListDropDownListBoE)	
	
	movingTop = movingTop - editBoxHeight - 3
	EMA.settingsControl.checkBoxMailCRItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop + movingTopEdit, 
		L["MAIL_REAGENTS"],
		EMA.SettingsToggleMailCRItems,
		L["MAIL_REAGENTS_HELP"]
	)
	EMA.settingsControl.tabNumListDropDownListCR = EMAHelperSettings:CreateEditBox(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["MAILTOON"]
	)
	EMA.settingsControl.tabNumListDropDownListCR:SetCallback( "OnEnterPressed",  EMA.EditMailToonNameCR )	
	EMA.settingsControl.MailTradeCRItemsTagCR = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.MailTradeCRItemsTagCR:SetList( EMAApi.GroupList() )
	EMA.settingsControl.MailTradeCRItemsTagCR:SetCallback( "OnValueChanged",  EMA.GroupListDropDownListCR )	
	-- Recipes & Formulas
	movingTop = movingTop - editBoxHeight - 3
	EMA.settingsControl.checkBoxMailRecipeFItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop + movingTopEdit, 
		L["MAIL_RECIPES"],
		EMA.SettingsToggleMailRecipeF,
		L["MAIL_RECIPES_HELP"]
	)
	EMA.settingsControl.tabNumListDropDownListRecipeF = EMAHelperSettings:CreateEditBox(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["MAILTOON"]
	)
	EMA.settingsControl.tabNumListDropDownListRecipeF:SetCallback( "OnEnterPressed",  EMA.SettingsToggleMailRecipeFName )	
	EMA.settingsControl.MailTradeRecipeFItemsTagRecipeF = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.MailTradeRecipeFItemsTagRecipeF:SetList( EMAApi.GroupList() )
	EMA.settingsControl.MailTradeRecipeFItemsTagRecipeF:SetCallback( "OnValueChanged",  EMA.EditMailToonNameRecipeFGroup )	
		
	movingTop = movingTop - editBoxHeight - headingHeight
--	movingTop = movingTop - editBoxHeight

	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["MAIL_GOLD_OPTIONS"] , movingTop, false )
	movingTop = movingTop - headingHeight
	
	EMA.settingsControl.checkBoxAdjustMoneyOnToonViaMail = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["MAIL_GOLD"],
		EMA.SettingsToggleAdjustMoneyOnToonViaMail,
		L["MAIL_GOLD_HELP"]
	)
	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		dropBoxWidth,
		left,
		movingTop,
		L["GOLD_TO_KEEP"]
	)
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetCallback( "OnEnterPressed", EMA.EditBoxChangedGoldAmountToLeaveOnToon )
	
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonName = EMAHelperSettings:CreateEditBox(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["MAILTOON"]
	)
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonName:SetCallback( "OnEnterPressed",  EMA.EditMailToonNameGold )		
	
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonTag:SetCallback( "OnValueChanged",  EMA.GroupListDropDownListGold )		
	
	

	
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
		EMA.settingsControl.MailItems.listScrollFrame, 
		EMA:GetMailItemsMaxPosition(),
		EMA.settingsControl.MailItems.rowsToDisplay, 
		EMA.settingsControl.MailItems.rowHeight
	)
	EMA.settingsControl.MailItemsOffset = FauxScrollFrame_GetOffset( EMA.settingsControl.MailItems.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.MailItems.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[3].textString:SetText( "" )
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[3].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[4].textString:SetText( "" )
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[4].textString:SetTextColor( 1.0, 0, 0, 1.0 )		
		EMA.settingsControl.MailItems.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.MailItemsOffset
		if dataRowNumber <= EMA:GetMailItemsMaxPosition() then
			-- Put data information into columns.
			local MailItemsInformation = EMA:GetMailItemsAtPosition( dataRowNumber )
			local blackListText = ""
			if MailItemsInformation.blackList == true then
				blackListText = L["ITEM_ON_BLACKLIST"]
			end
			EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[1].textString:SetText( MailItemsInformation.name )
			EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[2].textString:SetText( MailItemsInformation.GBTab )
			EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[3].textString:SetText( MailItemsInformation.tag )
			EMA.settingsControl.MailItems.rows[iterateDisplayRows].columns[4].textString:SetText( blackListText )
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.MailItemsHighlightRow then
				EMA.settingsControl.MailItems.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingsMailItemsRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.MailItemsOffset + rowNumber <= EMA:GetMailItemsMaxPosition() then
		EMA.settingsControl.MailItemsHighlightRow = EMA.settingsControl.MailItemsOffset + rowNumber
		EMA:SettingsScrollRefresh()
	end
end

function EMA:SettingsMailItemsRemoveClick( event )
	StaticPopup_Show( "EMAMail_CONFIRM_REMOVE_MAIL_ITEMS" )
end

function EMA:SettingsEditBoxChangedMailItem( event, text )
	EMA.autoMailItemLink = text
	EMA:SettingsRefresh()
end

function EMA:SettingsMailItemsAddClick( event )
	if EMA.autoMailItemLink ~= nil and EMA.autoMailToonName ~= nil and EMA.db.MailTagName ~= nil then
		EMA:AddItem( EMA.autoMailItemLink, EMA.autoMailToonName, EMA.db.MailTagName, EMA.db.blackListItem )
		EMA.autoMailItemLink = nil
		EMA.settingsControl.MailItemsEditBoxMailItem:SetText( "" )
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
			EMA.db.MailTagName = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleBlackListItem( event, checked ) 
	EMA.db.blackListItem = checked
	EMA:SettingsRefresh()
end	


function EMA:EditMailToonName (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.autoMailToonName = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleMailBoEItems(event, checked )
	EMA.db.MailBoEItems = checked
	EMA:SettingsRefresh()
end


function EMA:EditMailToonNameBoE (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.db.autoMailToonNameBoE = value
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


function EMA:SettingsToggleMailCRItems(event, checked )
	EMA.db.MailCRItems = checked
	EMA:SettingsRefresh()
end

function EMA:EditMailToonNameCR (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.db.autoMailToonNameCR = value
	EMA:SettingsRefresh()
end

function EMA:GroupListDropDownListCR (event, value )
	-- if nil or the blank group then don't get Name.
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

function EMA:SettingsToggleMailRecipeF(event, checked )
	EMA.db.MailRecipeFItems = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleMailRecipeFName (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.db.autoMailToonNameRecipeF = value
	EMA:SettingsRefresh()
end

function EMA:EditMailToonNameRecipeFGroup (event, value )
	-- if nil or the blank group then don't get Name.
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

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:OnGroupAreasChanged( message )
	EMA.settingsControl.MailItemsEditBoxMailTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.MailTradeBoEItemsTagBoE:SetList( EMAApi.GroupList() )
	EMA.settingsControl.MailTradeCRItemsTagCR:SetList( EMAApi.GroupList() )
	EMA.settingsControl.MailTradeRecipeFItemsTagRecipeF:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleShowEMAMailWindow( event, checked )
	EMA.db.showEMAMailWindow = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleGlobalMailList( event, checked )
	EMA.db.globalMailList = checked
	EMA:SettingsRefresh()
end	

-- Gold Stuff!

function EMA:SettingsToggleAdjustMoneyOnToonViaMail( event, checked )
	EMA.db.adjustMoneyWithMail = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedGoldAmountToLeaveOnToon( event, text )
	EMA.db.goldAmountToKeepOnToon = tonumber( text )
	if EMA.db.goldAmountToKeepOnToon == nil then
		EMA.db.goldAmountToKeepOnToon = 0
	end
	EMA:SettingsRefresh()
end

function EMA:GroupListDropDownListGold (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	for index, groupName in ipairs( EMAApi.GroupList() ) do
		if index == value then
			EMA.db.autoMailMoneyTag = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:EditMailToonNameGold (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.db.autoMailToonNameGold = value
	EMA:SettingsRefresh()
end

function EMA:CopyListCommmand()
	EMA:Print("Copying Local List To Global List")
	EMA.db.global.autoMailItemsListGlobal = EMAUtilities:CopyTable( EMA.db.autoMailItemsList )
	EMA:SettingsRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.messageArea = settings.messageArea
		EMA.db.showEMAMailWindow = settings.showEMAMailWindow
		EMA.db.globalMailList = settings.globalMailList
		EMA.db.MailTagName = settings.MailTagName
		EMA.db.MailBoEItems = settings.MailBoEItems
		EMA.db.autoMailToonNameBoE = settings.autoMailToonNameBoE
		EMA.db.autoBoEItemTag = settings.autoBoEItemTag
		EMA.db.MailCRItems = settings.MailCRItems
		EMA.db.autoMailToonNameCR = settings.autoMailToonNameCR
		EMA.db.autoCRItemTag = settings.autoCRItemTag
		EMA.db.MailRecipeFItems = settings.MailRecipeFItems
		EMA.db.autoMailToonNameRecipeF = settings.autoMailToonNameRecipeF
		EMA.db.autoRecipeFItemTag = settings.autoRecipeFItemTag
		EMA.db.autoMailItemsList = EMAUtilities:CopyTable( settings.autoMailItemsList )
		EMA.db.global.autoMailItemsListGlobal = EMAUtilities:CopyTable( settings.global.autoMailItemsListGlobal )
		EMA.db.adjustMoneyWithMail = settings.adjustMoneyWithMail
		EMA.db.goldAmountToKeepOnToon = settings.goldAmountToKeepOnToon
		EMA.db.autoMailToonNameGold = settings.autoMailToonNameGold
		EMA.db.autoMailMoneyTag = settings.autoMailMoneyTag
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
	EMA.settingsControl.checkBoxShowEMAMailWindow:SetValue( EMA.db.showEMAMailWindow )
-- global CheckBox
	EMA.settingsControl.checkBoxGlobalMailList:SetValue( EMA.db.globalMailList )
	EMA.settingsControl.checkBoxGlobalMailList:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.MailItemsEditBoxMailTag:SetText( EMA.db.MailTagName )
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetValue( EMA.db.blackListItem )
	EMA.settingsControl.checkBoxMailBoEItems:SetValue( EMA.db.MailBoEItems )
	EMA.settingsControl.tabNumListDropDownListBoE:SetText( EMA.db.autoMailToonNameBoE )
	EMA.settingsControl.MailTradeBoEItemsTagBoE:SetText( EMA.db.autoBoEItemTag )
	EMA.settingsControl.checkBoxMailCRItems:SetValue( EMA.db.MailCRItems )
	EMA.settingsControl.tabNumListDropDownListCR:SetText( EMA.db.autoMailToonNameCR )
	EMA.settingsControl.MailTradeCRItemsTagCR:SetText( EMA.db.autoCRItemTag )

	EMA.settingsControl.checkBoxMailRecipeFItems:SetValue( EMA.db.MailRecipeFItems )
	EMA.settingsControl.tabNumListDropDownListRecipeF:SetText( EMA.db.autoMailToonNameRecipeF )
	EMA.settingsControl.MailTradeRecipeFItemsTagRecipeF:SetText( EMA.db.autoRecipeFItemTag )
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.checkBoxAdjustMoneyOnToonViaMail:SetValue( EMA.db.adjustMoneyWithMail )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetText( tostring( EMA.db.goldAmountToKeepOnToon ) )
	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetDisabled( not EMA.db.adjustMoneyWithMail )
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonName:SetText( EMA.db.autoMailToonNameGold )
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonName:SetDisabled( not EMA.db.adjustMoneyWithMail )
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonTag:SetText( EMA.db.autoMailMoneyTag )
	EMA.settingsControl.SettingsToggleAdjustMoneyOnToonTag:SetDisabled( not EMA.db.adjustMoneyWithMail )
	
	EMA.settingsControl.MailItemsEditBoxMailItem:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.MailItemsEditBoxMailTag:SetDisabled( not EMA.db.showEMAMailWindow )	
	EMA.settingsControl.tabNumListDropDownList:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.MailItemsButtonRemove:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.MailItemsButtonAdd:SetDisabled( not EMA.db.showEMAMailWindow )	
	EMA.settingsControl.checkBoxMailBoEItems:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.tabNumListDropDownListBoE:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.MailTradeBoEItemsTagBoE:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.checkBoxMailCRItems:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.tabNumListDropDownListCR:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.MailTradeCRItemsTagCR:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.checkBoxMailRecipeFItems:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.tabNumListDropDownListRecipeF:SetDisabled( not EMA.db.showEMAMailWindow )
	EMA.settingsControl.MailTradeRecipeFItemsTagRecipeF:SetDisabled( not EMA.db.showEMAMailWindow )
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
-- Mail functionality.
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
				EMA.settingsControl.MailItemsEditBoxMailItem:SetText( "" )
				EMA.settingsControl.MailItemsEditBoxMailItem:SetText( itemLink )
				EMA.autoMailItemLink = itemLink	
				return
			end
		end	
	end	
	return EMA.hooks["ContainerFrameItemButton_OnModifiedClick"]( self, event, ... )
end



function EMA:GetMailItemsMaxPosition()
	if EMA.db.globalMailList == true then
		return #EMA.db.global.autoMailItemsListGlobal
	else
		return #EMA.db.autoMailItemsList
	end	
end

function EMA:GetMailItemsAtPosition( position )
	if EMA.db.globalMailList == true then
		return EMA.db.global.autoMailItemsListGlobal[position]
	else	
		return EMA.db.autoMailItemsList[position]
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
		if EMA.db.globalMailList == true then
			table.insert( EMA.db.global.autoMailItemsListGlobal, itemInformation )
		else	
			table.insert( EMA.db.autoMailItemsList, itemInformation )
		end	
		EMA:SettingsRefresh()			
		EMA:SettingsMailItemsRowClick( 1, 1 )
	end	
end

function EMA:RemoveItem()
	if EMA.db.globalMailList == true then
		table.remove( EMA.db.global.autoMailItemsListGlobal, EMA.settingsControl.MailItemsHighlightRow )
	else
		table.remove( EMA.db.autoMailItemsList, EMA.settingsControl.MailItemsHighlightRow )
	end
	EMA:SettingsRefresh()
	EMA:SettingsMailItemsRowClick( EMA.settingsControl.MailItemsHighlightRow  - 1, 1 )		
end


function EMA:MAIL_SHOW(event, ...)
	--EMA:Print("test")
	if EMA.db.showEMAMailWindow == true then
		if not IsShiftKeyDown() then
			EMA:AddAllToMailBox()
		else 
			EMA.ShiftkeyDown = true
		end	
	end
	if EMA.db.adjustMoneyWithMail == true and EMA.db.showEMAMailWindow == true then
		EMA:ScheduleTimer( "AddGoldToMailBox", 0.3 )
	end
end

function EMA:MAIL_CLOSED(event, ...)
	EMA.ShiftkeyDown = false
end

function EMA:AddAllToMailBox()
	--EMA:Print("run")
	MailFrameTab_OnClick(nil, "2")
	--EMA.OldMailName = SendMailNameEditBox:GetText()
	SendMailNameEditBox:SetText( "" )	
	SendMailMoneyGold:SetText( "" )
	SendMailMoneySilver:SetText( "" )
	SendMailMoneyCopper:SetText( "" )
	SendMailNameEditBox:ClearFocus()
	EMA.Count = 1 
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1,GetContainerNumSlots( bagID ),1 do 
			
			local item = Item:CreateFromBagAndSlot(bagID, slotID)
			if ( item ) then
				local bagItemLink = item:GetItemLink()
				if ( bagItemLink ) then	
					--EMA:Print( "Bags OK. checking", itemLink )
					local itemLink = item:GetItemLink()
					local location = item:GetItemLocation()
					local itemTypeNew = C_Item.GetItemInventoryType( location )
					local isBop = C_Item.IsBound( location )
					local itemRarity =  C_Item.GetItemQuality( location )
					local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo( bagItemLink )
					local canSend = false
					local toonName = nil
					if EMA.db.MailBoEItems == true then
						if itemTypeNew ~= 0 then
							if EMAApi.IsCharacterInGroup(  EMA.characterName, EMA.db.autoBoEItemTag ) == true then
								if isBop == false then
									if itemRarity == 2 or itemRarity == 3 or itemRarity == 4 then	
										canSend = true
										toonName = EMA.db.autoMailToonNameBoE
									end			
								end
							end										
						end									
					end	
					if EMA.db.MailCRItems == true then
						if isCraftingReagent == true then
							if EMAApi.IsCharacterInGroup(  EMA.characterName, EMA.db.autoCRItemTag ) == true then
								--EMA:Print("testCR", classID, bagItemLink)
								if isBop == false then
									canSend = true
									toonName = EMA.db.autoMailToonNameCR		
								end
							end										
						end
					end
					if EMA.db.MailRecipeFItems == true then
						if itemClassID == 9 then
							--EMA:Print("testRF", itemClassID, bagItemLink)
							if EMAApi.IsCharacterInGroup(  EMA.characterName, EMA.db.autoRecipeFItemTag ) == true then
								if isBop == false then
									canSend = true
									toonName = EMA.db.autoMailToonNameRecipeF		
								end
							end										
						end
					end
					if EMA.db.globalMailList == true then
						itemTable = EMA.db.global.autoMailItemsListGlobal
					else
						itemTable = EMA.db.autoMailItemsList
					end
					for position, itemInformation in pairs( itemTable ) do
						if EMAUtilities:DoItemLinksContainTheSameItem( itemLink, itemInformation.link ) then
							if EMAApi.IsCharacterInGroup(  EMA.characterName, itemInformation.tag ) == true then
								--EMA:Print("DataTest", itemInformation.link, itemInformation.blackList )
								--EMA:Print("test", itemLink)
								canSend = true
								toonName = itemInformation.GBTab
							end
							if itemInformation.blackList == true then
								canSend = false
							end
						end
					end
					if canSend == true and toonName ~= "" and toonName ~= nil then	
						local currentMailToon = SendMailNameEditBox:GetText()
						local characterName = EMAUtilities:AddRealmToNameIfMissing( toonName )
						if toonName == currentMailToon or currentMailToon == "" and characterName ~= EMA.characterName then
							if EMA.Count <= ATTACHMENTS_MAX_SEND then	
								--EMA:Print("sending Mail:", count)
								EMA.Count = EMA.Count + 1
								SendMailNameEditBox:SetText( toonName )
								SendMailSubjectEditBox:SetText( L["SENT_AUTO_MAILER"] )
								PickupContainerItem( bagID, slotID )
								UseContainerItem( bagID , slotID  )
							end	
						end				
					end
				end	
			end
		end
	end	
	EMA:ScheduleTimer( "DoSendMail", 2, nil )
end

function EMA:MAIL_SEND_SUCCESS( event, ... )
	--EMA:Print("try sendMail Again")
	if EMA.db.showEMAMailWindow == true then	
		if EMA.ShiftkeyDown == false and EMA.Count < 1 then
			EMA:ScheduleTimer( "AddAllToMailBox", 1.55, nil )
		end
	end	
	if EMA.db.adjustMoneyWithMail == true and EMA.db.showEMAMailWindow == true then
		EMA:ScheduleTimer( "AddGoldToMailBox", 2 )
	end	
end

function EMA:DoSendMail( gold )
	--EMA:Print("newSendRun")
	for iterateMailSlots = 1, ATTACHMENTS_MAX_SEND do
		if HasSendMailItem( iterateMailSlots ) == true or gold == true then
			--EMA:Print("canSend")
			SendMailMailButton:Click() 
			EMA.Count = 0		
			break
		end
	end	
	local gold =  SendMailMoneyCopper:GetText()
	--EMA:Print("test", gold)
	if HasSendMailItem( "1" ) == false and gold == "" then
		MailFrameTab_OnClick(nil, 1)
	end	
end	

-- gold
function EMA:AddGoldToMailBox()
	if EMA.ShiftkeyDown == true then
		return
	end
	local moneyToKeepOnToon = tonumber( EMA.db.goldAmountToKeepOnToon ) * 10000
	local moneyOnToon = GetMoney() - 30
	local moneyToDepositOrWithdraw = moneyOnToon - moneyToKeepOnToon
	local toonName = EMA.db.autoMailToonNameGold
	--EMA:Print("i have", moneyOnToon, "keep", moneyToKeepOnToon, "send", moneyToDepositOrWithdraw )
	if moneyToDepositOrWithdraw == 0 then
		return
	end
	if moneyToDepositOrWithdraw > 0 and HasSendMailItem("1") == false then
		local currentMailToon = SendMailNameEditBox:GetText()
		local characterName = EMAUtilities:AddRealmToNameIfMissing( toonName )
		if MailFrame:IsVisible() == true then
			--EMA:Print("blizzardFarme")
			if toonName == currentMailToon or currentMailToon == "" and characterName ~= EMA.characterName then
				if EMAApi.IsCharacterInGroup(  EMA.characterName, EMA.db.autoMailMoneyTag ) == true then	
					local gold, silver, copper = EMAUtilities:MoneyString( moneyToDepositOrWithdraw )
					local coinText = GetCoinText( moneyToDepositOrWithdraw )
					--EMA:Print("Send", "gold", gold, "silver", silver, "copper", copper )
					MailFrameTab_OnClick(nil, "2")
					SendMailSubjectEditBox:SetText( (L["SENT_AUTO_MAILER_GOLD"](coinText) ) )
					SendMailNameEditBox:SetText( toonName )
					SendMailMoneyGold:SetText(gold)
					SendMailMoneySilver:SetText(silver)
					SendMailMoneyCopper:SetText(copper)
					EMA:ScheduleTimer( "DoSendMail", 2, true )
				end
			end	
		else
			EMA:Print("[PH] Can Only Send Mail From BlizzardUI Mail Frame!")
		end
	end	
end
