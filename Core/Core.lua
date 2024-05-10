-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2023 Jennifer Calladine					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- The global private table for EMA.
EMAPrivate = {}
EMAPrivate.Core = {}
EMAPrivate.Communications = {}
EMAPrivate.Message = {}
EMAPrivate.Team = {}
EMAPrivate.Tag = {}

-- The global public API table for EMA.
_G.EMAApi = {}

local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"EMACore", 
	"AceConsole-3.0" 
)

-- EMACore is not a module, but the same naming convention for these values is convenient.
EMA.moduleName = "EMA-Core"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.moduleDisplayName = L["NEWS"]
EMA.settingsDatabaseName = "CoreProfileDB"
EMA.parentDisplayName = L["NEWS"]
EMA.chatCommand = "ema"
EMA.teamModuleName = "Team"
-- Icon's
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\NewsIcon.tga"
EMA.pofileIcon = "Interface\\Addons\\EMA\\Media\\SettingsIcon.tga"
-- order
EMA.moduleOrder = 1
local version = GetAddOnMetadata("EMA", "version")

-- Load libraries.
local AceGUI = LibStub("AceGUI-3.0")
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )

-- Create frame for EMA Settings.
EMAPrivate.SettingsFrame = {}
EMAPrivate.SettingsFrame.Widget = AceGUI:Create( "EMAWindow" )
EMAPrivate.SettingsFrame.Widget:SetTitle( "" )
EMAPrivate.SettingsFrame.Widget:SetStatusText(L["STATUSTEXT"])
EMAPrivate.SettingsFrame.Widget:EnableResize( false )
EMAPrivate.SettingsFrame.Widget:SetWidth(800)
EMAPrivate.SettingsFrame.Widget:SetHeight(700)
EMAPrivate.SettingsFrame.Widget:SetLayout( "Fill" )
EMAPrivate.SettingsFrame.WidgetTree = AceGUI:Create( "EMATreeGroup" )
EMAPrivate.SettingsFrame.WidgetTree:SetLayout( "Fill" )
EMAPrivate.SettingsFrame.TreeGroupStatus = { treesizable = false, groups = {} }
EMAPrivate.SettingsFrame.WidgetTree:SetStatusTable( EMAPrivate.SettingsFrame.TreeGroupStatus )
EMAPrivate.SettingsFrame.WidgetTree:EnableButtonTooltips( false )
EMAPrivate.SettingsFrame.Widget:AddChild( EMAPrivate.SettingsFrame.WidgetTree )


function EMA:OnEnable()
	local Jamba = IsAddOnLoaded("Jamba")
	if Jamba == true then
		StaticPopup_Show( "CAN_NOT_RUN_JAMBA_AND_EMA" )
	end
	--[[
	if EMA.db.global.showStartupMessage8000 then
		StaticPopup_Show( "ALL_SETTINGS HAVE BEEN RESET" )
	end
	]]
	if EMA.db.global.showStartupMessage3000 then
		StaticPopup_Show( "UpgradeTo_v2" )
	end
end

function EMA:OnDisable()
end

local function InitializePopupDialogs()
	StaticPopupDialogs["ALL_SETTINGS HAVE BEEN RESET"] = {
		text = L["ALL_SETTINGS_RESET"],
		button1 = OKAY,
		OnAccept = function()
			EMA.db.global.showStartupMessage8000 = false
		end,
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		hideOnEscape = 1,
		whileDead = 1,	
	}	
	StaticPopupDialogs["CAN_NOT_RUN_JAMBA_AND_EMA"] = {
		text = L["CAN_NOT_RUN_JAMBA_AND_EMA"],
		button1 = OKAY,
		OnAccept = function()
			DisableAddOn("jamba")
			ReloadUI()
		end,
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		hideOnEscape = 0,
		whileDead = 1,	
	}	
	StaticPopupDialogs["UpgradeTo_v2"] = {
		text = L["v2_NEWS"],
		button1 = OKAY,
		OnAccept = function()
			EMA.db.global.showStartupMessage3000 = false
		end,
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		hideOnEscape = 0,
		whileDead = 1,	
	}
end

local function EmaSettingsTreeSort( a, b )
	local aText = ""
	local bText = ""
	local aEMAOrder = 0
	local bEMAOrder = 0
	if a ~= nil then
		aText = a.text
		aEMAOrder = a.EMAOrder
	end	
	if b ~= nil then
		bText = b.text
		bEMAOrder = b.EMAOrder
	end
	if aText == L["EMA"] or bText == L["EMA"] then
		if aText == L["EMA"] then
			return true
		end
		if bText == L["EMA"] then
			return false
		end
	end
	if aEMAOrder == bEMAOrder then
		return aText < bText
	end
	return aEMAOrder < bEMAOrder
end

local function EmaTreeGroupTreeGetParent( parentName )
	local parent
	for index, tableInfo in ipairs( EMAPrivate.SettingsFrame.Tree.Data ) do
		if tableInfo.value == parentName then
			parent = tableInfo			
		end
	end
	return parent
end

local function EmaAddModuleToSettings( childName, parentName, moduleIcon, order, moduleFrame )
	-- 	childName is the parentName then make the child the parent.
	if childName == parentName then
		local parent = EmaTreeGroupTreeGetParent( parentName )
		if parent == nil then
			table.insert( EMAPrivate.SettingsFrame.Tree.Data, { value = childName, text = childName, EMAOrder = order, icon = moduleIcon } )
			table.sort( EMAPrivate.SettingsFrame.Tree.Data, EmaSettingsTreeSort )
			EMAPrivate.SettingsFrame.Tree.ModuleFrames[childName] = moduleFrame
		end	

	else
	local parent = EmaTreeGroupTreeGetParent( parentName )
	if parent == nil then
		table.insert( EMAPrivate.SettingsFrame.Tree.Data, { value = parentName, text = parentName, EMAOrder = order } )
	end
	local parent = EmaTreeGroupTreeGetParent( parentName )
	if parent.children == nil then
		parent.children = {}
	end	
		table.insert( parent.children, { value = childName, text = childName, EMAOrder = order, icon = moduleIcon } )
		table.sort( EMAPrivate.SettingsFrame.Tree.Data, EmaSettingsTreeSort )
		table.sort( parent.children, EmaSettingsTreeSort )
		EMAPrivate.SettingsFrame.Tree.ModuleFrames[childName] = moduleFrame
	end
end



local function EmaModuleSelected( tree, event, treeValue, selected )
	--EMA:Print("test", tree, event, treeValue, selected)
	local parentValue, value = strsplit( "\001", treeValue )
	if tree == nil and event == nil then
		-- Came from chat command.
		value = treeValue
	end
	if value == nil then
		value = parentValue
	end
	EMAPrivate.SettingsFrame.Widget:Show()
	if EMAPrivate.SettingsFrame.Tree.CurrentChild ~= nil then
		EMAPrivate.SettingsFrame.Tree.CurrentChild.frame:Hide()
		EMAPrivate.SettingsFrame.Tree.CurrentChild = nil
	end
	for moduleValue, moduleFrame in pairs( EMAPrivate.SettingsFrame.Tree.ModuleFrames ) do	
		if 	moduleValue == value then
			moduleFrame:SetParent( EMAPrivate.SettingsFrame.WidgetTree )
			moduleFrame:SetWidth( EMAPrivate.SettingsFrame.WidgetTree.content:GetWidth() or 0 )
			moduleFrame:SetHeight( EMAPrivate.SettingsFrame.WidgetTree.content:GetHeight() or 0 )
			moduleFrame.frame:SetAllPoints() 
			moduleFrame.frame:Show()	
			EMAPrivate.SettingsFrame.Tree.CurrentChild = moduleFrame
		if value == L["OPTIONS"] then
				LibStub( "AceConfigDialog-3.0" ):Open( EMA.moduleName..L["OPTIONS"], moduleFrame )
		end			
			return
		end
	end
end

EMAPrivate.SettingsFrame.Tree = {}
EMAPrivate.SettingsFrame.Tree.Data = {}
EMAPrivate.SettingsFrame.Tree.ModuleFrames = {}
EMAPrivate.SettingsFrame.Tree.CurrentChild = nil
EMAPrivate.SettingsFrame.Tree.Add = EmaAddModuleToSettings
EMAPrivate.SettingsFrame.Tree.ButtonClick = EmaModuleSelected
EMAPrivate.SettingsFrame.WidgetTree:SetTree( EMAPrivate.SettingsFrame.Tree.Data )
EMAPrivate.SettingsFrame.WidgetTree:SetCallback( "OnClick", EMAPrivate.SettingsFrame.Tree.ButtonClick )
EMAPrivate.SettingsFrame.Widget:Hide()

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	global = {
		showStartupMessage8000 = false,
		showStartupMessage2000 = false,
		showStartupMessage3000 = false,
	 },	
	profile = {
		useGlobalSettings = true,
	},	
}

-- Configuration.
local function GetConfiguration()
	local configuration = {
		name = "EMA",
		handler = EMA,
		type = 'group',
		childGroups  = "tab",
		get = "ConfigurationGetSetting",
		set = "ConfigurationSetSetting",
		args = {	
			config = {
				type = "input",
				name = L["OPEN_CONFIG"],
				desc = L["OPEN_CONFIG_HELP"],
				usage = "/ema config",
				get = false,
				set = "",
				order = 5,
				guiHidden = true,				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema push",
				get = false,
				set = "SendSettingsAllModules",
				order = 4,
				guiHidden = true,
			},
			resetsettingsframe = {
				type = "input",
				name = L["RESET_SETTINGS_FRAME"],
				desc = L["RESET_SETTINGS_FRAME"],
				usage = "/ema resetsettingsframe",
				get = false,
				set = "ResetSettingsFrame",
				order = 5,
				guiHidden = true,				
			},
		},
	}
	return configuration
end
-- Get a settings value.
function EMA:ConfigurationGetSetting( key )
	return EMA.db[key[#key]]
end

-- Set a settings value.
function EMA:ConfigurationSetSetting( key, value )
	EMA.db[key[#key]] = value
end

local function DebugMessage( ... )
	EMA:Print( ... )
end

--Ema Alpha
local function isEmaAlphaBuild()
	local EMAVersion = GetAddOnMetadata("EMA", "version")
	-- EMA Alpha Build
	local Alpha = EMAVersion:find( "Alpha" )
	if Alpha then
		return true
	else
		return false
	end	
end
-- WoW 10.0
local function isEmaBetaBuild()
	local beta = false
	local WoW10 = select(4, GetBuildInfo()) >= 100002
	if WoW10 == true then
		beta = true
	end
	return beta
end

-- EMA classic build
local function isEmaClassicBuild()
	local classic = false
	-- Classic
	local classicBuild  = select(4, GetBuildInfo()) <= 11403
	if 	classicBuild  == true then
		classic = true
	end
	return 	classic
end	

-- EMA WOTLK Build
local function isEmaClassicBccBuild()
	--EMA:Print("t", _G.WOW_PROJECT_ID)
	local classic = false
	if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
		classic = true
	end
	-- Classic
	if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC then
		classic = true
	end
	if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC then
		classic = true
	end
	if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC then
		classic = true
	end	
 	return classic
end	

-------------------------------------------------------------------------------------------------------------
-- Module management.
-------------------------------------------------------------------------------------------------------------

local function globalSetting()
	return EMA.db.useGlobalSettings
end

-- Register a EMA module.
local function RegisterModule( moduleAddress, moduleName )
	if EMA.registeredModulesByName == nil then
		EMA.registeredModulesByName = {}
	end
	if EMA.registeredModulesByAddress == nil then
		EMA.registeredModulesByAddress = {}
	end
	EMA.registeredModulesByName[moduleName] = moduleAddress
	EMA.registeredModulesByAddress[moduleAddress] = moduleName
end

local function UnRegisterModule( moduleAddress, moduleName )
	print("unRegister", moduleAddress, moduleName )
	if EMA.registeredModulesByName == nil then
		EMA.registeredModulesByName = {}
	end
	if EMA.registeredModulesByAddress == nil then
		EMA.registeredModulesByAddress = {}
	end
	
	EMA.registeredModulesByName[moduleName] = nil
	EMA.registeredModulesByAddress[moduleAddress] = nil
end


-------------------------------------------------------------------------------------------------------------
-- Settings sending and receiving.
-------------------------------------------------------------------------------------------------------------

-- Send the settings for the module specified (using its address) to other EMA Team characters.
local function SendSettings( moduleAddress, settings )
	-- Get the name of the module.
	local moduleName = EMA.registeredModulesByAddress[moduleAddress]
	-- Send the settings identified by the module name.
	EMAPrivate.Communications.SendSettings( moduleName, settings )
end

-- Settings are received, pass them to the relevant module.
local function OnSettingsReceived( sender, moduleName, settings )
	sender = EMAUtilities:AddRealmToNameIfMissing( sender )
	--EMA:Print("onsettings", sender, moduleName )
	-- Get the address of the module.
	local moduleAddress = EMA.registeredModulesByName[moduleName]	
	-- can not receive a message from a Module not Loaded so ignore it. Better tell them its not loaded --ebony.
	if moduleAddress == nil then 
		EMA:Print(L["MODULE_NOT_LOADED"], moduleName)
		return
	else
	-- loaded? Pass the module its settings.
		moduleAddress:EMAOnSettingsReceived( sender, settings )
	end	
end

function EMA:SendSettingsAllModules()
	EMA:Print( "Sending settings for all modules." )
	for moduleName, moduleAddress in pairs( EMA.registeredModulesByName ) do
		EMA:Print( "Sending settings for: ", moduleName )
		moduleAddress:EMASendSettings()
	end
end

-------------------------------------------------------------------------------------------------------------
-- Commands sending and receiving.
-------------------------------------------------------------------------------------------------------------

-- Send a command for the module specified (using its address) to other EMA Team characters.
local function SendCommandToTeam( moduleAddress, commandName, ... )
	--EMA:Print("test", moduleAddress, commandName)
	-- Get the name of the module.
	local moduleName = EMA.registeredModulesByAddress[moduleAddress]
	-- Send the command identified by the module name.
	if moduleAddress == nil then 
		EMA:Print(L["MODULE_NOT_LOADED"], moduleName)
		return
	else	
	EMAPrivate.Communications.SendCommandAll( moduleName, commandName, ... )
	end
end

-- Send a command for the module specified (using its address) to the master character.
local function SendCommandToMaster( moduleAddress, commandName, ... )
	-- Get the name of the module.
	local moduleName = EMA.registeredModulesByAddress[moduleAddress]
	-- Send the command identified by the module name.
	if moduleAddress == nil then 
		EMA:Print(L["MODULE_NOT_LOADED"], moduleName)
		return
	else	
	EMAPrivate.Communications.SendCommandMaster( moduleName, commandName, ... )
	end
end

local function SendCommandToToon( moduleAddress, characterName, commandName, ... )
	-- Get the name of the module.
	local moduleName = EMA.registeredModulesByAddress[moduleAddress]
	-- Send the command identified by the module name.
	if moduleAddress == nil then 
		EMA:Print(L["MODULE_NOT_LOADED"], moduleName)
		return
	else
	EMAPrivate.Communications.SendCommandToon( moduleName, characterName, commandName, ... )
	end
end

-- A command is received, pass it to the relevant module.
local function OnCommandReceived( sender, moduleName, commandName, ... )
	sender = EMAUtilities:AddRealmToNameIfMissing( sender )
	-- Get the address of the module.
	local moduleAddress = EMA.registeredModulesByName[moduleName]
	-- Pass the module its settings.
	if moduleAddress == nil then 
		EMA:Print(L["MODULE_NOT_LOADED"], moduleName)
		return
	else
		moduleAddress:EMAOnCommandReceived( sender, commandName, ... )
	end		
end

-------------------------------------------------------------------------------------------------------------
-- EMA Core Profile Support.
-------------------------------------------------------------------------------------------------------------

function EMA:FireBeforeProfileChangedEvent()
	for moduleName, moduleAddress in pairs( EMA.registeredModulesByName ) do
		if moduleName ~= EMA.moduleName then		
			moduleAddress:BeforeEMAProfileChanged()
		end
	end
end

function EMA:CanChangeProfileForModule( moduleName )
	if (moduleName ~= EMA.moduleName) and (moduleName ~= EMA.teamModuleName) then		
		return true
	end
	return false
end

function EMA:FireOnProfileChangedEvent( moduleAddress )
	moduleAddress.db = moduleAddress.completeDatabase.profile
	moduleAddress:OnEMAProfileChanged()
end

function EMA:OnProfileChanged( event, database, newProfileKey, ... )
	EMA:Print( "Profile changed - iterating all modules.")	
	EMA:FireBeforeProfileChangedEvent()
	-- Do the team module before all the others.
	local teamModuleAddress = EMA.registeredModulesByName[EMA.teamModuleName]
	EMA:Print( "Changing profile: ", EMA.teamModuleName )
	teamModuleAddress.completeDatabase:SetProfile( newProfileKey )
	EMA:FireOnProfileChangedEvent( teamModuleAddress )
	-- Do the other modules.
	for moduleName, moduleAddress in pairs( EMA.registeredModulesByName ) do
		if EMA:CanChangeProfileForModule( moduleName ) == true then		
			EMA:Print( L["CHANGING_PROFILE"] , moduleName )
			moduleAddress.completeDatabase:SetProfile( newProfileKey )
			EMA:FireOnProfileChangedEvent( moduleAddress )
		end
	end
end

function EMA:OnProfileCopied( event, database, sourceProfileKey )
	EMA:Print( "Profile copied - iterating all modules." )
	EMA:FireBeforeProfileChangedEvent()
	-- Do the team module before all the others.
	local teamModuleAddress = EMA.registeredModulesByName[EMA.teamModuleName]
	EMA:Print( L["COPYING_PROFILE"], EMA.teamModuleName )
	teamModuleAddress.completeDatabase:CopyProfile( sourceProfileKey, true )
	EMA:FireOnProfileChangedEvent( teamModuleAddress )	
	-- Do the other modules.
	for moduleName, moduleAddress in pairs( EMA.registeredModulesByName ) do
		if EMA:CanChangeProfileForModule( moduleName ) == true then		
			EMA:Print( L["COPYING_PROFILE"], moduleName )
			moduleAddress.completeDatabase:CopyProfile( sourceProfileKey, true )
			EMA:FireOnProfileChangedEvent( moduleAddress )
		end
	end
end

function EMA:OnProfileReset( event, database )
	EMA:Print( L["PROFILE_RESET"] )
	EMA:FireBeforeProfileChangedEvent()
	-- Do the team module before all the others.
	local teamModuleAddress = EMA.registeredModulesByName[EMA.teamModuleName]
	EMA:Print( L["RESETTING_PROFILE"], EMA.teamModuleName )
	teamModuleAddress.completeDatabase:ResetProfile()
	EMA:FireOnProfileChangedEvent( teamModuleAddress )	
	-- Do the other modules.	
	for moduleName, moduleAddress in pairs( EMA.registeredModulesByName ) do
		if EMA:CanChangeProfileForModule( moduleName ) == true then		
			EMA:Print( L["RESETTING_PROFILE"], moduleName )
			moduleAddress.completeDatabase:ResetProfile()
			EMA:FireOnProfileChangedEvent( moduleAddress )
		end
	end
end

function EMA:OnProfileDeleted( event, database, profileKey )
	EMA:Print( L["PROFILE_DELETED"] )
	EMA:FireBeforeProfileChangedEvent()
	-- Do the team module before all the others.
	local teamModuleAddress = EMA.registeredModulesByName[EMA.teamModuleName]
	EMA:Print( L["DELETING_PROFILE"], EMA.teamModuleName )
	teamModuleAddress.completeDatabase:DeleteProfile( profileKey, true )
	EMA:FireOnProfileChangedEvent( teamModuleAddress )	
	-- Do the other modules.		
	for moduleName, moduleAddress in pairs( EMA.registeredModulesByName ) do
		if EMA:CanChangeProfileForModule( moduleName ) == true then		
			EMA:Print( L["DELETING_PROFILE"], moduleName )
			moduleAddress.completeDatabase:DeleteProfile( profileKey, true )
			EMA:FireOnProfileChangedEvent( moduleAddress )
		end
	end
end

-------------------------------------------------------------------------------------------------------------
-- EMA Core Initialization.
-------------------------------------------------------------------------------------------------------------

-- Initialize the addon.
function EMA:OnInitialize()
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	-- Tables to hold registered modules - lookups by name and by address.  
	-- By name is used for communication between clients and by address for communication between addons on the same client.
	EMA.registeredModulesByName = {}
	EMA.registeredModulesByAddress = {}
	-- Create the settings database supplying the settings values along with defaults.
    EMA.completeDatabase = LibStub( "AceDB-3.0" ):New( EMA.settingsDatabaseName, EMA.settings )
	EMA.completeDatabase.RegisterCallback( EMA, "OnProfileChanged", "OnProfileChanged" )
	EMA.completeDatabase.RegisterCallback( EMA, "OnProfileCopied", "OnProfileCopied" )	
	EMA.completeDatabase.RegisterCallback( EMA, "OnProfileReset", "OnProfileReset" )	
	EMA.completeDatabase.RegisterCallback( EMA, "OnProfileDeleted", "OnProfileDeleted" )	

	EMA.db = EMA.completeDatabase.profile
	EMA.db.global = EMA.completeDatabase.global
	-- Create the settings.
	LibStub( "AceConfig-3.0" ):RegisterOptionsTable( 
		EMA.moduleName, 
		GetConfiguration() 
	)
	
	-- Create the settings frame.
	EMA:CoreSettingsCreate()
	EMA.settingsFrame = EMA.settingsControl.widgetSettings.frame
	-- Create the settings profile support.
	LibStub( "AceConfig-3.0" ):RegisterOptionsTable( 
		EMA.moduleName..L["OPTIONS"],
		LibStub( "AceDBOptions-3.0" ):GetOptionsTable( EMA.completeDatabase ) 
	)
	local profileContainerWidget = AceGUI:Create( "ScrollFrame" )
	--local profileContainerWidget = AceGUI:Create( "Frame" )
	profileContainerWidget:SetLayout( "Fill" )
	-- We need this to make it a working Module
	local order  = 10
	EMAPrivate.SettingsFrame.Tree.Add( L["OPTIONS"], L["OPTIONS"], EMA.pofileIcon, order, profileContainerWidget )
	
	-- Register the core as a module.
	RegisterModule( EMA, EMA.moduleName )
	-- Register the chat command.
	EMA:RegisterChatCommand( EMA.chatCommand, "EMAChatCommand" )
	-- Populate the settings.
	--EMA:SettingsRefresh()
end
--[[
function EMA:LoadEMAModule( moduleName )
	local loaded, reason = LoadAddOn( moduleName )
	if not loaded then
		if reason ~= "DISABLED" and reason ~= "MISSING" then
			EMA:Print(L["Failed_LOAD_MODULE"]..moduleName.."' ["..reason.."]." )
		end
	end
end
]]
function EMA:CoreSettingsCreateInfo( top )
	-- Get positions and dimensions.
	local buttonWidth = 200
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local radioBoxHeight = EMAHelperSettings:GetRadioBoxHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local labelContinueHeight = EMAHelperSettings:GetContinueLabelHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local indent = horizontalSpacing * 10
	local indentContinueLabel = horizontalSpacing * 18
	local indentSpecial = indentContinueLabel + 9
	local checkBoxThirdWidth = (headingWidth - indentContinueLabel) / 3
	local column1Left = left
	local column2Left = column1Left + checkBoxThirdWidth + horizontalSpacing - 35
	local column1LeftIndent = left + indentContinueLabel
	local column2LeftIndent = column1LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local column3LeftIndent = column2LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	
	--Main Heading
	movingTop = movingTop - checkBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["STATUSTEXT"], movingTop, false )
	movingTop = movingTop - headingHeight
		EMA.settingsControl.labelInformation2 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["VERSION"]..L[": "]..version
	)
	movingTop = movingTop - labelHeight
	EMA.settingsControl.labelInformation1 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["ME"]
	)
	movingTop = movingTop - labelHeight
	EMA.settingsControl.labelInformation2 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["ME_TWITTER"]
	)
	
	movingTop = movingTop - labelHeight * 14
	--[[
	if EMAPrivate.Core.isEmaClassicBccBuild() == true then
		EMA.settingsControl.buttonKeyBindings = EMAHelperSettings:CreateButton( 
			EMA.settingsControl, 
			buttonWidth, 
			left, 
			movingTop,
			L["KEY_BINDINGS"],
			EMA.SettingsKeyBindingsCommandClick
		)	
	end
	]]
	-- Special thanks Heading
	movingTop = movingTop - buttonHeight * 1
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["SPECIAL_THANKS"], movingTop, false )	
	movingTop = movingTop - headingHeight
	EMA.settingsControl.labelInformation20 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["THANKS1"]
	)	
	--CopyRight heading
	movingTop = movingTop - labelContinueHeight * 3
	EMA.settingsControl.labelInformation40 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["COPYRIGHT"]
	)
	movingTop = movingTop - labelContinueHeight
	EMA.settingsControl.labelInformation41 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["COPYRIGHTTWO"]
	)	
	movingTop = movingTop - labelContinueHeight
	return movingTop	
end

function EMA:CoreSettingsCreate()
	EMA.settingsControl = {}
	-- Create the settings panel.
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SendSettingsAllModules,
		EMA.moduleIcon,
		EMA.moduleOrder	
	)
	local bottomOfInfo = EMA:CoreSettingsCreateInfo( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
end

-- Send core settings.
function EMA:EMASendSettings()
	EMAPrivate.Communications.SendSettings( EMA.moduleName, EMA.db )
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	--EMA.settingsControl.checkBoxGlobalSettings:SetValue( EMA.db.useGlobalSettings )
end

-- Core settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )
	--Checks character is not the the character that send the settings. Now checks the character has a realm on there name to match EMA team list.
	--characterName = EMAUtilities:AddRealmToNameIfMissing( characterName )
	if characterName ~= EMA.characterName then
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

function EMA:SettingsKeyBindingsCommandClick( event )
	KeyBindingFrame_LoadUI()
	ShowUIPanel(KeyBindingFrame)
end

--	Does the Chat Command Exist
local function DoesTheChatCommandExist( configuration, command )
	local exist = false
	for key, info in pairs( configuration ) do
		if info.type == "input" then
			if key == command then	
				exist = true
				break
			end
		end
	end
	return exist	
end

-- Handle the chat command.
function EMA:EMAChatCommand( inputBefore )
	input = string.lower( inputBefore )
	--EMA:Print("test", input )
	local inputString, tag = strsplit( " ", inputBefore )
	local CommandExist = DoesTheChatCommandExist( GetConfiguration().args, inputString ) 
	if input == "config" then
		if InCombatLockdown() then
			print( L["CANNOT_OPEN_IN_COMBAT"] )
		return
	end
		-- Show Config
		EMAPrivate.SettingsFrame.Widget:Show()
		EMAPrivate.SettingsFrame.WidgetTree:SelectByValue( L["NEWS"] )
		EMAPrivate.SettingsFrame.Tree.ButtonClick( nil, nil, EMA.moduleDisplayName, false)
	elseif CommandExist then			
		--Command Found now Handle IT!
		--print("Command Found", input )
		LibStub( "AceConfigCmd-3.0" ):HandleCommand( EMA.chatCommand, EMA.moduleName, input )
	else	
		-- hell knows what to do so HELP!!!
		--print("No found Command Found HELP", input )
		for key, info in pairs( GetConfiguration().args ) do
			if info.type == "input" then
				print("|cFFFFFF00"..info.usage, "|cFFFFFFFF".." [ "..info.desc.." ]" )
			end
		end
		print( L["MODULE_LIST"] )
		for moduleName, moduleAddress in pairs( EMA.registeredModulesByName ) do
			print("|cFFFFFF00/"..EMA.chatCommand.."-"..moduleName )
		end	
	end 
end

function EMA:ResetSettingsFrame()
	EMA:Print( L["FRAME_RESET"] )
	EMAPrivate.SettingsFrame.Widget:SetPoint("CENTER", 0, 0)
	EMAPrivate.SettingsFrame.Widget:SetWidth(800)
	EMAPrivate.SettingsFrame.Widget:SetHeight(700)
	EMAPrivate.SettingsFrame.Widget:Show()
end

function EMA:SettingsToggleGlobalSettings( event, checked )
	EMA.db.useGlobalSettings = checked
	StaticPopup_Show( "MUST_RELOAD_UI" )
	EMA:SettingsRefresh()
end
	
function EMA:SettingsTestBox( event, checked )
	print("test", checked , EMA.db.testBox)
	EMA.db.testBox = checked
	EMA:SettingsRefresh()

end

-- Functions available from EMA Core for other EMA internal objects.
EMAPrivate.Core.globalSetting = globalSetting
EMAPrivate.Core.RegisterModule = RegisterModule
EMAPrivate.Core.UnRegisterModule = UnRegisterModule
EMAPrivate.Core.SendSettings = SendSettings
EMAPrivate.Core.OnSettingsReceived = OnSettingsReceived
EMAPrivate.Core.SendCommandToTeam = SendCommandToTeam
EMAPrivate.Core.SendCommandToMaster = SendCommandToMaster
EMAPrivate.Core.SendCommandToToon = SendCommandToToon
EMAPrivate.Core.OnCommandReceived = OnCommandReceived
EMAPrivate.Core.isEmaClassicBuild = isEmaClassicBuild
EMAPrivate.Core.isEmaClassicBccBuild = isEmaClassicBccBuild
EMAPrivate.Core.isEmaBetaBuild = isEmaBetaBuild
EMAPrivate.Core.isEmaAlphaBuild = isEmaAlphaBuild
EMAPrivate.Core.SendSettingsAllModules = EMA.SendSettingsAllModules
EMAPrivate.Core.RefreshSettingsAllModules = EMA.RefreshSettingsAllModules
