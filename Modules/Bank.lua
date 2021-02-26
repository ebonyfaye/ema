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
	"Bank", 
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
EMA.moduleName = "Bank"
EMA.settingsDatabaseName = "BankProfileDB"
EMA.chatCommand = "ema-Bank"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["INTERACTION"]
EMA.moduleDisplayName = L["BANK"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\BankIcon.tga"
-- order
EMA.moduleOrder = 20

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	global = {
		['**'] = {
			autoBankItemsListGlobal = {},
		},
	 },
	profile = {
		messageArea = EMAApi.DefaultMessageArea(),
		showEMABankWindow = false,
		globalBankList = false,
		blackListItem = false,
		BankBoEItems = false,
--		autoBankToonNameBoE = "",
		BankTagName = EMAApi.AllGroup(),
		autoBoEItemTag = EMAApi.AllGroup(),	
		BankCRItems = false,
--		autoBankToonNameCR = "",
		autoCRItemTag = EMAApi.AllGroup(),
		autoBankItemsList = {},
--		autoBankItemsAmount = "",
--		adjustMoneyWithBankBank = false,
--		goldAmountToKeepOnToon = 250,
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
				usage = "/ema-bank config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_ALL_SETTINGS"],
				usage = "/ema-Bank push",
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
	StaticPopupDialogs["EMABANK_CONFIRM_REMOVE_BANK_ITEMS"] = {
        text = L["REMOVE_BANK_LIST"],
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
	EMA.autoBankItemLink = nil
--	EMA.autoBankToonName = nil
--	EMA.autoBankItemsAmount = nil
	EMA.BankItemTable = {}
	EMA.ShiftkeyDown = false
	--EMA.putItemsInGB = {}
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialse the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "BANKFRAME_OPENED" )
	EMA:RegisterEvent( "BANKFRAME_CLOSED" )
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
	local bottomOfInfo = EMA:SettingsCreateBank( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsCreateBank( top )
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
	local BankWidth = headingWidth
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
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["BANK_LIST_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxShowEMABankWindow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["BANK_LIST"],
		EMA.SettingsToggleShowEMABankWindow,
		L["BANK_LIST_HELP"]
	)	
	EMA.settingsControl.checkBoxGlobalBankList = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left3, 
		movingTop, 
		L["GLOBAL_LIST"],
		EMA.SettingsToggleGlobalBankList,
		L["GLOBAL_SETTINGS_LIST_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.BankItemsHighlightRow = 1
	EMA.settingsControl.BankItemsOffset = 1
	local list = {}
	list.listFrameName = "EMABankIteamsSettingsFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = BankWidth
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
	list.rowClickCallback = EMA.SettingsBankItemsRowClick
	EMA.settingsControl.BankItems = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.BankItems )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.BankItemsButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50,  
		movingTop,
		L["REMOVE"],
		EMA.SettingsBankItemsRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ADD_ITEMS"], movingTop, false )
	
	movingTop = movingTop - headingHeight
	EMA.settingsControl.BankItemsEditBoxBankItem = EMAHelperSettings:CreateEditBox( 
		EMA.settingsControl,
		thirdWidth,
		left2,
		movingTop,
		L["ITEM_DROP"]
	)
	EMA.settingsControl.BankItemsEditBoxBankItem:SetCallback( "OnEnterPressed", EMA.SettingsEditBoxChangedBankItem )
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
	EMA.settingsControl.autoBankItemsAmount = EMAHelperSettings:CreateEditBox(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["AMOUNT"]
	)	
	EMA.settingsControl.autoBankItemsAmount:SetCallback( "OnEnterPressed",  EMA.EditBankItemsAmount )
]]	
	--Group
	EMA.settingsControl.BankItemsEditBoxBankTag = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.BankItemsEditBoxBankTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.BankItemsEditBoxBankTag:SetCallback( "OnValueChanged",  EMA.GroupListDropDownList )
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControl.BankItemsButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left2 + 50, 
		movingTop, 
		L["ADD"],
		EMA.SettingsBankItemsAddClick
	)
	movingTop = movingTop -	buttonHeight		
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["BANK_OPTIONS"], movingTop, false )
	movingTop = movingTop - editBoxHeight - 3
	
	EMA.settingsControl.checkBoxBankBoEItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop + movingTopEdit,
		L["BANK_BOE_ITEMS"],
		EMA.SettingsToggleBankBoEItems,
		L["BANK_BOE_ITEMS_HELP"]
	)	
--[[	
	EMA.settingsControl.tabNumListDropDownListBoE = EMAHelperSettings:CreateEditBox(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["BankTOON"]
	)	
	EMA.settingsControl.tabNumListDropDownListBoE:SetCallback( "OnEnterPressed",  EMA.EditBankToonNameBoE )	
--]]	
	EMA.settingsControl.BankTradeBoEItemsTagBoE = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.BankTradeBoEItemsTagBoE:SetList( EMAApi.GroupList() )
	EMA.settingsControl.BankTradeBoEItemsTagBoE:SetCallback( "OnValueChanged",  EMA.GroupListDropDownListBoE)	
	
	movingTop = movingTop - editBoxHeight - 3
	EMA.settingsControl.checkBoxBankCRItems = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		thirdWidth, 
		left, 
		movingTop + movingTopEdit, 
		L["BANK_REAGENTS"],
		EMA.SettingsToggleBankCRItems,
		L["BANK_REAGENTS_HELP"]
	)
--[[	
	EMA.settingsControl.tabNumListDropDownListCR = EMAHelperSettings:CreateEditBox(
		EMA.settingsControl, 
		thirdWidth,	
		left2,
		movingTop,
		L["BankTOON"]
	)
	
	EMA.settingsControl.tabNumListDropDownListCR:SetCallback( "OnEnterPressed",  EMA.EditBankToonNameCR )	
]]	
	EMA.settingsControl.BankTradeCRItemsTagCR = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl, 
		thirdWidth,	
		left3,
		movingTop, 
		L["GROUP_LIST"]
	)
	EMA.settingsControl.BankTradeCRItemsTagCR:SetList( EMAApi.GroupList() )
	EMA.settingsControl.BankTradeCRItemsTagCR:SetCallback( "OnValueChanged",  EMA.GroupListDropDownListCR )	
		
	movingTop = movingTop - editBoxHeight
	movingTop = movingTop - editBoxHeight
--[[	
	EMA.settingsControl.labelComingSoon = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left2, 
		movingTop,
		L["Bank_GOLD_COMING_SOON"] 
	)	
	EMA.settingsControl.checkBoxAdjustMoneyOnToonViaBankBank = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left + 110, 
		movingTop, 
		L["Bank_GOLD"],
		EMA.SettingsToggleAdjustMoneyOnToonViaBankBank,
		L["Bank_GOLD_HELP"]
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
]]	
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
		EMA.settingsControl.BankItems.listScrollFrame, 
		EMA:GetBankItemsMaxPosition(),
		EMA.settingsControl.BankItems.rowsToDisplay, 
		EMA.settingsControl.BankItems.rowHeight
	)
	EMA.settingsControl.BankItemsOffset = FauxScrollFrame_GetOffset( EMA.settingsControl.BankItems.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.BankItems.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[3].textString:SetText( "" )
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[3].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[4].textString:SetText( "" )
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[4].textString:SetTextColor( 1.0, 0, 0, 1.0 )		
		EMA.settingsControl.BankItems.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.BankItemsOffset
		if dataRowNumber <= EMA:GetBankItemsMaxPosition() then
			-- Put data information into columns.
			local BankItemsInformation = EMA:GetBankItemsAtPosition( dataRowNumber )
			local blackListText = ""
			if BankItemsInformation.blackList == true then
				blackListText = L["ITEM_ON_BLACKLIST"]
			end
			EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[1].textString:SetText( BankItemsInformation.name )
			EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[2].textString:SetText( BankItemsInformation.amount )
			EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[3].textString:SetText( BankItemsInformation.tag )
			EMA.settingsControl.BankItems.rows[iterateDisplayRows].columns[4].textString:SetText( blackListText )
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.BankItemsHighlightRow then
				EMA.settingsControl.BankItems.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingsBankItemsRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.BankItemsOffset + rowNumber <= EMA:GetBankItemsMaxPosition() then
		EMA.settingsControl.BankItemsHighlightRow = EMA.settingsControl.BankItemsOffset + rowNumber
		EMA:SettingsScrollRefresh()
	end
end

function EMA:SettingsBankItemsRemoveClick( event )
	StaticPopup_Show( "EMABANK_CONFIRM_REMOVE_BANK_ITEMS" )
end

function EMA:SettingsToggleGlobalBankList( event, checked )
	EMA.db.globalBankList = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsEditBoxChangedBankItem( event, text )
	EMA.autoBankItemLink = text
	EMA:SettingsRefresh()
end

function EMA:SettingsBankItemsAddClick( event )
	if EMA.autoBankItemLink ~= nil and EMA.db.BankTagName ~= nil then
		EMA:AddItem( EMA.autoBankItemLink, EMA.db.BankTagName, EMA.db.blackListItem )
		EMA.autoBankItemLink = nil
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
			EMA.db.BankTagName = groupName
			break
		end
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleBlackListItem( event, checked ) 
	EMA.db.blackListItem = checked
	EMA:SettingsRefresh()
end	


function EMA:EditBankItemsAmount (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.autoBankItemsAmount = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleBankBoEItems(event, checked )
	EMA.db.BankBoEItems = checked
	EMA:SettingsRefresh()
end

--[[
function EMA:EditBankToonNameBoE (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
--	EMA.db.autoBankToonNameBoE = value
	EMA:SettingsRefresh()
end
]]
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


function EMA:SettingsToggleBankCRItems(event, checked )
	EMA.db.BankCRItems = checked
	EMA:SettingsRefresh()
end
--[[
function EMA:EditBankToonNameCR (event, value )
	-- if nil or the blank group then don't get Name.
	if value == " " or value == nil then 
		return 
	end
	EMA.db.autoBankToonNameCR = value
	EMA:SettingsRefresh()
end
]]
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

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:OnGroupAreasChanged( message )
	EMA.settingsControl.BankItemsEditBoxBankTag:SetList( EMAApi.GroupList() )
	EMA.settingsControl.BankTradeBoEItemsTagBoE:SetList( EMAApi.GroupList() )
	EMA.settingsControl.BankTradeCRItemsTagCR:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleShowEMABankWindow( event, checked )
	EMA.db.showEMABankWindow = checked
	EMA:SettingsRefresh()
end
--[[
function EMA:SettingsToggleAdjustMoneyOnToonViaBankBank( event, checked )
	EMA.db.adjustMoneyWithBankBank = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAdjustMoneyWithMasterOnBank( event, checked )
	EMA.db.adjustMoneyWithMasterOnBank = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedGoldAmountToLeaveOnToon( event, text )
	EMA.db.goldAmountToKeepOnToon = tonumber( text )
	if EMA.db.goldAmountToKeepOnToon == nil then
		EMA.db.goldAmountToKeepOnToon = 0
	end
	EMA:SettingsRefresh()
end
]]
-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.messageArea = settings.messageArea
		EMA.db.globalBankdList = settings.globalBankList
		EMA.db.showEMABankWindow = settings.showEMABankWindow
		EMA.db.BankTagName = settings.BankTagName
		EMA.db.BankBoEItems = settings.BankBoEItems
--		EMA.db.autoBankItemsAmount = settings.autoBankItemsAmount
--		EMA.db.autoBankToonNameBoE = settings.autoBankToonNameBoE
		EMA.db.autoBoEItemTag = settings.autoBoEItemTag
		EMA.db.BankCRItems = settings.BankCRItems
--		EMA.db.autoBankToonNameCR = settings.autoBankToonNameCR
		EMA.db.autoCRItemTag = settings.autoCRItemTag
		EMA.db.autoBankItemsList = EMAUtilities:CopyTable( settings.autoBankItemsList )
		EMA.db.adjustMoneyWithBankBank = settings.adjustMoneyWithBankBank
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
	EMA.settingsControl.checkBoxShowEMABankWindow:SetValue( EMA.db.showEMABankWindow )
	EMA.settingsControl.checkBoxGlobalBankList:SetValue( EMA.db.globalBankList )
	EMA.settingsControl.checkBoxGlobalBankList:SetDisabled( not EMA.db.showEMABankWindow )
	EMA.settingsControl.BankItemsEditBoxBankTag:SetText( EMA.db.BankTagName )
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetValue( EMA.db.blackListItem )
--	EMA.settingsControl.autoBankItemsAmount:SetText( EMA.db.autoBankItemsAmount ) 
	EMA.settingsControl.checkBoxBankBoEItems:SetValue( EMA.db.BankBoEItems )
--	EMA.settingsControl.tabNumListDropDownListBoE:SetText( EMA.db.autoBankToonNameBoE )
	EMA.settingsControl.BankTradeBoEItemsTagBoE:SetText( EMA.db.autoBoEItemTag )
	EMA.settingsControl.checkBoxBankCRItems:SetValue( EMA.db.BankCRItems )
--	EMA.settingsControl.tabNumListDropDownListCR:SetText( EMA.db.autoBankToonNameCR )
	EMA.settingsControl.BankTradeCRItemsTagCR:SetText( EMA.db.autoCRItemTag )
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
--	EMA.settingsControl.checkBoxAdjustMoneyOnToonViaBankBank:SetValue( EMA.db.adjustMoneyWithBankBank )
--	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetText( tostring( EMA.db.goldAmountToKeepOnToon ) )
--	EMA.settingsControl.editBoxGoldAmountToLeaveOnToon:SetDisabled( not EMA.db.adjustMoneyWithBankBank )
	EMA.settingsControl.BankItemsEditBoxBankItem:SetDisabled( not EMA.db.showEMABankWindow )
	EMA.settingsControl.listCheckBoxBoxOtherBlackListItem:SetDisabled( not EMA.db.showEMABankWindow )
--	EMA.settingsControl.autoBankItemsAmount:SetDisabled( not EMA.db.showEMABankWindow )
	EMA.settingsControl.BankItemsEditBoxBankTag:SetDisabled( not EMA.db.showEMABankWindow )	
--	EMA.settingsControl.tabNumListDropDownList:SetDisabled( not EMA.db.showEMABankWindow )
	EMA.settingsControl.BankItemsButtonRemove:SetDisabled( not EMA.db.showEMABankWindow )
	EMA.settingsControl.BankItemsButtonAdd:SetDisabled( not EMA.db.showEMABankWindow )	
	EMA.settingsControl.checkBoxBankBoEItems:SetDisabled( not EMA.db.showEMABankWindow )
--	EMA.settingsControl.tabNumListDropDownListBoE:SetDisabled( not EMA.db.showEMABankWindow )
	EMA.settingsControl.BankTradeBoEItemsTagBoE:SetDisabled( not EMA.db.showEMABankWindow )
	EMA.settingsControl.checkBoxBankCRItems:SetDisabled( not EMA.db.showEMABankWindow )
--	EMA.settingsControl.tabNumListDropDownListCR:SetDisabled( not EMA.db.showEMABankWindow )
	EMA.settingsControl.BankTradeCRItemsTagCR:SetDisabled( not EMA.db.showEMABankWindow )
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
-- Bank functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:GetBankItemsMaxPosition()
	if EMA.db.globalBankList == true then
		return #EMA.db.global.autoBankItemsListGlobal
	else
		return #EMA.db.autoBankItemsList
	end	
end

function EMA:GetBankItemsAtPosition( position )
	if EMA.db.globalBankList == true then
		return EMA.db.global.autoBankItemsListGlobal[position]
	else
		return EMA.db.autoBankItemsList[position]
	end	
end

function EMA:AddItem( itemLink, itemTag, blackList )
	--EMA:Print("testDBAdd", itemLink, itemTag )
	-- Get some more information about the item.
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo( itemLink )
	-- If the item could be found.
	if name ~= nil then
		local itemInformation = {}
		itemInformation.link = link
		itemInformation.name = name
		itemInformation.tag = itemTag
		itemInformation.blackList = blackList
		if EMA.db.globalBankList == true then
			table.insert( EMA.db.global.autoBankItemsListGlobal, itemInformation )
		else	
			table.insert( EMA.db.autoBankItemsList, itemInformation )
		end	
			
		EMA:SettingsRefresh()			
		EMA:SettingsBankItemsRowClick( 1, 1 )
	end	
end

function EMA:RemoveItem()
	if EMA.db.globalBankList == true then
		table.remove( EMA.db.global.autoBankItemsListGlobal, EMA.settingsControl.BankItemsHighlightRow )
	else
		table.remove( EMA.db.autoBankItemsList, EMA.settingsControl.BankItemsHighlightRow )
	end
	EMA:SettingsRefresh()
	EMA:SettingsBankItemsRowClick( EMA.settingsControl.BankItemsHighlightRow  - 1, 1 )		
end


function EMA:BANKFRAME_OPENED(event, ...)
	--EMA:Print("test")
	if EMA.db.showEMABankWindow == true then
		if not IsShiftKeyDown() then
			EMA:AddAllToBank()
		else 
			EMA.ShiftkeyDown = true
		end	
	end
end

function EMA:BANKFRAME_CLOSED(event, ...)
	EMA.ShiftkeyDown = false
end

function EMA:AmountInBank( itemLink )
	EMA:Print("test", itemLink )
	local countBags = GetItemCount( itemLink )
	local countTotal = GetItemCount( itemLink , true)
	local countBank = countTotal - countBags
	EMA:Print("test2", countBags, countTotal, countBank )
	
	return countBank


end

function EMA:AddAllToBank()
	--EMA:Print("run")
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1,GetContainerNumSlots( bagID ),1 do 
			--EMA:Print( "Bags OK. checking", itemLink )
			local item = Item:CreateFromBagAndSlot(bagID, slotID)
			if ( item ) then
				local bagItemLink = item:GetItemLink()
				if ( bagItemLink ) then	
					local canSend = false
					local itemLink = item:GetItemLink()
					local location = item:GetItemLocation()
					local itemType = C_Item.GetItemInventoryType( location )
					local isBop = C_Item.IsBound( location )
					local itemRarity =  C_Item.GetItemQuality( location )
					local _,_,_,_,_,_,_, itemStackCount,_,_,_,_,_,_,_,_,isCraftingReagent = GetItemInfo( bagItemLink )
				--local countBank = EMA:AmountInBank( itemLink )
				--EMA:Print("I have", itemLink, countBank, "inMyBank")
					if EMA.db.BankBoEItems == true then
						if itemType ~= 0 then
							if EMAApi.IsCharacterInGroup(  EMA.characterName, EMA.db.autoBoEItemTag ) == true then
								if isBop == false then
									if itemRarity == 2 or itemRarity == 3 or itemRarity == 4 then	
										canSend = true
									end			
								end
							end										
						end									
					end	
					if EMA.db.BankCRItems == true then
						if isCraftingReagent == true then
							if EMAApi.IsCharacterInGroup(  EMA.characterName, EMA.db.autoCRItemTag ) == true then
								if isBop == false then
									canSend = true		
								end
							end										
						end
					end
					if EMA.db.globalBankList == true then
						itemTable = EMA.db.global.autoBankItemsListGlobal
					else
						itemTable = EMA.db.autoBankItemsList
					end
					for position, itemInformation in pairs( itemTable ) do
					--	EMA:Print("test2", itemInformation.tag, itemInformation.link, "vs", itemLink )
						if EMAUtilities:DoItemLinksContainTheSameItem( itemLink, itemInformation.link ) then
							local dataAmount = tonumber( itemInformation.amount )
							if EMAApi.IsCharacterInGroup(  EMA.characterName, itemInformation.tag ) == true then
								canSend = true
								if itemInformation.blackList == true then
									canSend = false
								end
							end	
						end
					end
					
					if canSend == true then
						PickupContainerItem( bagID, slotID )
						--EMA:Print("test", isCraftingReagent )
						if isCraftingReagent == true then
							UseContainerItem( bagID , slotID, nil, true )
						else
							UseContainerItem( bagID , slotID )
						end						
					end
				end	
			end
		end
	end
end