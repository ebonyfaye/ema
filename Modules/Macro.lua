-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2020 Jennifer Cally					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Macro", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0"
)

-- Load libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Macro"
EMA.settingsDatabaseName = "MacroProfileDB"
EMA.chatCommand = "ema-macro"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["TOON"]
EMA.moduleDisplayName = L["MACRO"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\MacroIcon.tga"
-- order
EMA.moduleOrder = 99


-- Settings - the values to store and their defaults for the settings database.
local myMacros = {}
local currentMacro = {isLocal=false}
local teamNames = {}
local minionNames = {}
local currentToonValue = ''


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
				usage = "/ema-macro config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_ALL_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-macro push",
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

EMA.COMMAND_SEND_MACRO = "SEND_MACRO"
EMA.COMMAND_DELETE_EMA_MACRO = "DELETE_EMA_MACRO"
EMA.MACRO_TAIL = '_EMA_AUTO'

-------------------------------------------------------------------------------------------------------------
-- Macro Management.
-------------------------------------------------------------------------------------------------------------

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	-- Set values.
	-- EMA.settingsControl.checkBoxForwardWhispers:SetValue( EMA.db.forwardWhispers )
	-- Set state.
	EMA.settingsControl.buttonRefreshMacroList:SetDisabled( false )
	EMA.settingsControl.checkBoxisLocal:SetValue( currentMacro.isLocal )
--	EMA:SettingsScrollRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
		end
end

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreateOptions( top )
	-- Position and size constants.
	local buttonControlWidth = 130
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight() - 8
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local left2 = left + halfWidth + horizontalSpacing
	local indent = horizontalSpacing * 10
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, "", movingTop, false )
	movingTop = movingTop - headingHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, "Duplicate Macros", movingTop, false )
	movingTop = movingTop - headingHeight

	EMA.settingsControl.dropDownMacroSelect = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		(headingWidth - indent) / 2, 
		left + indent, 
		movingTop, 
		"Select macro to edit and clone" 
	)
	EMA.settingsControl.dropDownMacroSelect:SetList( myMacros )
	EMA.settingsControl.dropDownMacroSelect:SetCallback( "OnValueChanged", EMA.EditCurrentMacroValue )

	EMA.settingsControl.buttonRefreshMacroList = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left + indent + (headingWidth - indent) / 2 + horizontalSpacing, 
		movingTop - buttonHeight,
		"Load macros",
		EMA.RefreshMacroList,
		"Get current character macros"
	)
	movingTop = movingTop - dropdownHeight - verticalSpacing

	EMA.settingsControl.editCurrentMacro = EMAHelperSettings:CreateMultiEditBox( 
		EMA.settingsControl,
		headingWidth,
		left + indent,
		movingTop,
		"Macro Content",
		10
	)
	EMA.settingsControl.editCurrentMacro.button:SetText( "Save macro to send" )
	EMA.settingsControl.editCurrentMacro.button:SetWidth( 180 )
	EMA.settingsControl.editCurrentMacro:SetCallback( "OnEnterPressed", EMA.SaveCurrentMacroValue )
	movingTop = movingTop - editBoxHeight * 3.7

	EMA.settingsControl.checkBoxisLocal = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left + indent + halfWidth, 
		movingTop, 
		"Local Macro ?",
		EMA.setCurrentMacroIsLocal,
		"If not local, it's global"
	)	
	movingTop = movingTop - checkBoxHeight - 5

	EMA.settingsControl.dropDownMacroToonSelect = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		(headingWidth - indent) / 3, 
		left + indent, 
		movingTop, 
		"Select toon" 
	)

	for characterName, position in EMAApi.TeamList() do
		table.insert( teamNames, characterName )
	end
	EMA.settingsControl.dropDownMacroToonSelect:SetList( teamNames )
	EMA.settingsControl.dropDownMacroToonSelect:SetCallback( "OnValueChanged", EMA.EditCurrentToonValue )

	EMA.settingsControl.buttonSendToonMacro = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		160, 
		left + indent + (headingWidth - indent) / 3 + horizontalSpacing, 
		movingTop - buttonHeight,
		"Send Macro to toon",
		EMA.SendMacroToToon
	)
	EMA.settingsControl.buttonSendToonMacro = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		140, 
		385, 
		movingTop - buttonHeight,
		"Send to all Toons",
		EMA.SendMacroAllMinions
	)
	movingTop = movingTop - dropdownHeight - verticalSpacing

	EMA.settingsControl.buttonSendToonMacro = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		140, 
		385, 
		movingTop - buttonHeight,
		"Delete ALL EMA macros",
		EMA.DeleteMacroTeam
	)
	movingTop = movingTop - dropdownHeight - verticalSpacing

	return movingTop
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
	local bottomOfSettings = SettingsCreateOptions( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfSettings )	
end


function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.whisperMessageArea = value
	EMA:SettingsRefresh()
end


function EMA:RefreshMacroList()
	print(GetNumMacros())
	local name, icon, body, isLocal
	local macrosNames = {}
	myMacros = {}
	local nbGalobalMacro, nbLocalMacro = GetNumMacros()

	-- Global Macros
	for macroIndex = 1, nbGalobalMacro do
		name, icon, body = GetMacroInfo(macroIndex)
		myMacros[#macrosNames+1] = {
			name=name, 
			body=body, 
			icon=icon, 
			isLocal=false
		} 
		macrosNames[#macrosNames+1] = name
	end

	-- Local macros
	for macroIndex = 1, nbLocalMacro do
		-- local macros start at 121 
		name, icon, body = GetMacroInfo( 120  + macroIndex)
		myMacros[#macrosNames+1] = {
			name=name, 
			body=body, 
			icon=icon, 
			isLocal=true
		} 
		macrosNames[#macrosNames+1] = name
	end

	EMA.settingsControl.dropDownMacroSelect:SetList( macrosNames )
end

function EMA:EditCurrentMacroValue ( event, value )
	currentMacro.isLocal = myMacros[value].isLocal
	currentMacro.body = myMacros[value].body
	currentMacro.name = myMacros[value].name
	currentMacro.icon = myMacros[value].icon
	currentMacro.id = value
	EMA.settingsControl.editCurrentMacro:SetText( currentMacro.body )
	EMA.settingsControl.checkBoxisLocal:SetValue( currentMacro.isLocal )
end

function EMA:EditCurrentToonValue(event, value) 
	currentToonValue = teamNames[value]
end

function EMA:SaveCurrentMacroValue(event, value)
	print(event, value)
	currentMacro.body = value
end

function EMA:setCurrentMacroIsLocal (event, checked)
	print(event, checked)
	currentMacro.isLocal = checked
end

function EMA:SendMacroToToon()
	EMA:Print("Sending Macro " .. currentMacro.name .. " To " .. currentToonValue)
	EMA:EMASendCommandToToon( currentToonValue, EMA.COMMAND_SEND_MACRO, currentMacro )
end

function EMA:SendMacroAllMinions()
	for minionName, position in EMAApi.MinionsList() do
		EMA:Print("Sending Macro " .. currentMacro.name .. " To " .. minionName)
		EMA:EMASendCommandToToon( minionName, EMA.COMMAND_SEND_MACRO, currentMacro )
	end
end

function EMA:DeleteMacroTeam()
	for characterName, position in EMAApi.TeamList() do
		EMA:Print("Deleteing Macros on " .. characterName)
		EMA:EMASendCommandToToon( characterName, EMA.COMMAND_DELETE_EMA_MACRO )
	end
end

local function create_macro( macro )
	local macro_name = macro.name .. EMA.MACRO_TAIL
	CreateMacro( macro_name, macro.icon, macro.body, macro.isLocal )
end


local function delete_macros()
	local name, icon, body, isLocal
	local macrosToDelete = {}
	local nbGalobalMacro, nbLocalMacro = GetNumMacros()

	-- Global Macros
	for macroIndex = 1, nbGalobalMacro do
		name, icon, body = GetMacroInfo(macroIndex)
		if EMAUtilities:endsWith(name, EMA.MACRO_TAIL) then
			EMA:Print("Deleting Macro " .. name)
			table.insert( macrosToDelete, name)
		end
	end

	-- Local macros
	for macroIndex = 1, nbLocalMacro do
		-- local macros start at 121 
		name, icon, body = GetMacroInfo( 120  + macroIndex)
		if EMAUtilities:endsWith(name, EMA.MACRO_TAIL) then
			EMA:Print("Deleting Macro " .. name)
			table.insert( macrosToDelete, name)
		end
	end

	for id, name in pairs(macrosToDelete) do
		DeleteMacro(name)
	end
end

function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if commandName == EMA.COMMAND_SEND_MACRO then
		currentMacro = ...
		EMA:Print("Macro " .. currentMacro.name .. " received from " .. characterName)
		create_macro(currentMacro)
	end
	if commandName == EMA.COMMAND_DELETE_EMA_MACRO then
		delete_macros()
	end
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
end

-- Called when the addon is enabled.
function EMA:OnEnable()
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end
