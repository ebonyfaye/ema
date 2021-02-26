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
	"Follow", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceTimer-3.0"
)

-- Get the EMA Utilities Library.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Follow"
EMA.settingsDatabaseName = "FollowProfileDB"
EMA.chatCommand = "ema-follow"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["TOON"]
EMA.moduleDisplayName = L["FOLLOW"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\FollowIcon.tga"
-- order
EMA.moduleOrder = 20

-- EMA key bindings.
BINDING_HEADER_FOLLOW = L["FOLLOW_BINDING_HEADER"]
BINDING_NAME_FOLLOWME = L["FOLLOW_ME"]
BINDING_NAME_FOLLOWSTROBEME = L["FOLLOW_STROBE_ME"]
BINDING_NAME_FOLLOWSTROBEOFF = L["FOLLOW_STROBE_OFF"]
BINDING_NAME_FOLLOWTEAIN = L["FOLLOW_TRAIN"]
BINDING_NAME_FOLLOWSTOP = L["FOLLOW_STOP"]

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		warnWhenFollowBreaks = true, 
		followBrokenMessage = L["FOLLOW_BROKEN_MSG"],
		autoFollowAfterCombat = false,  
		useAfterCombatDelay = false,
		afterCombatDelay = "3",
		strobeFrequencySeconds = "1",
		strobeFrequencySecondsInCombat = "1",
		warnFollowPvP = true,
		doNotWarnFollowBreakInCombat = false,
		doNotWarnFollowBreakMembersInCombat = false,
		doNotWarnFollowStrobing = false,
		strobePauseInCombat = false,
		strobePauseIfDrinking = false,
		strobePauseIfInVehicle = false,
		strobePauseIfDead = false,
		strobePauseTag = EMAApi.AllTag(),
		warningArea = EMAApi.DefaultWarningArea(),
		followMaster = "",
		useFollowMaster = false,
		overrideStrobeTargetWithMaster = false,
		onlyWarnIfOutOfFollowRange = false,
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
				usage = "/ema-follow push",
				get = false,
				set = "EMASendSettings",
			},											
			master = {
				type = "input",
				name = L["FOLLOW_MASTER"],
				desc = L["FOLLOW_MASTER_HELP"],
				usage = "/ema-follow master <group>",
				get = false,
				set = "FollowMasterCommand",
			},					
			target = {
				type = "input",
				name = L["FOLLOW_TARGET"],
				desc = L["FOLLOW_TARGET_HELP"],
				usage = "/ema-follow target <target> <group>",
				get = false,
				set = "FollowTargetCommand",
			},					
			afterCombat = {
				type = "input",
				name = L["FOLLOW_AFTER_COMBAT"],
				desc = L["FOLLOW_AFTER_COMBAT_HELP"],
				usage = "/ema-follow aftercombat <on|off> <group>",
			},															
			strobeOn = {
				type = "input",
				name = L["FOLLOW_STROBING"],
				desc = L["FOLLOW_STROBING_HELP"],
				usage = "/ema-follow strobeon <target> <group>",
				get = false,
				set = "FollowStrobeOnCommand",
			},	
			strobeOnMe = {
				type = "input",
				name = L["FOLLOW_STROBING_ME"],
				desc = L["FOLLOW_STROBING_ME_HELP"],
				usage = "/ema-follow strobeonme <group>",
				get = false,
				set = "FollowStrobeOnMeCommand",
			},												
			strobeOff = {
				type = "input",
				name = L["FOLLOW_STROBING_END"],
				desc = L["FOLLOW_STROBING_END_HELP"],
				usage = "/ema-follow strobeoff <group>",
				get = false,
				set = "FollowStrobeOffCommand",
			},	
			setmaster = {
				type = "input",
				name = L["FOLLOW_SET_MASTER"],
				desc = L["FOLLOW_SET_MASTER_HELP"],
				usage = "/ema-follow setmaster <name> <group>",
				get = false,
				set = "CommandSetFollowMaster",
			},
			train = {
				type = "input",
				name = L["TRAIN"],
				desc = L["TRAIN_HELP"],
				usage = "/ema-follow train <group>",
				get = false,
				set = "CommandFollowTrain",
			},
			me = {
				type = "input",
				name = L["FOLLOW_ME"],
				desc = L["FOLLOW_ME_HELP"],
				usage = "/ema-follow me <group>",
				get = false,
				set = "CommandFollowMe",
			},			
			snw = {
				type = "input",
				name = L["SNW"],
				desc = L["SNW_HELP"],
				usage = "/ema-follow snw",
				get = false,
				set = "SuppressNextFollowWarningCommand",
			},
			stop = {
				type = "input",
				name = L["FOLLOW_STOP"],
				desc = L["FOLLOW_STOP_HELP"],
				usage = "/ema-follow stop <group>",
				get = false,
				set = "CommandFollowStop",
			},				
		},
	}
	return configuration
end

local function DebugMessage( ... )
	--EMA:Print( ... )
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

EMA.COMMAND_FOLLOW_TARGET = "FollowTarget"
EMA.COMMAND_AUTO_FOLLOW_AFTER_COMBAT = "AutoFollowAfterCombat"
EMA.COMMAND_FOLLOW_STROBE_ON = "FollowStrobeOn"
EMA.COMMAND_FOLLOW_STROBE_OFF = "FollowStrobeOff"
EMA.COMMAND_SET_FOLLOW_MASTER = "FollowMaster"
EMA.COMMAND_FOLLOW_TRAIN = "FollowTrain"
EMA.COMMAND_FOLLOW_ME = "FollowMe"
EMA.COMMAND_FOLLOW_STOP = "FollowStop"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SortTeamListOrdered( characterA, characterB )
	local positionA = EMAApi.GetPositionForCharacterName ( characterA )
	local positionB = EMAApi.GetPositionForCharacterName ( characterB )
	return positionA < positionB
end

local function BuildAndSetTeamList()
	EMAUtilities:ClearTable( EMA.teamList )
	for characterName, order in EMAApi.TeamList() do
		table.insert( EMA.teamList, characterName )
		table.sort( EMA.teamList, SortTeamListOrdered )
	end
	EMA.settingsControl.dropdownFollowMaster:SetList( EMA.teamList )
end

local function SettingsCreateDisplayOptions( top )
	-- Get positions.
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( true )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - (horizontalSpacing * 2)) / 3
	local column2left = left + halfWidth
	local left2 = left + thirdWidth
	local left3 = left + (thirdWidth * 2)
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["FOLLOW_AFTER_COMBAT"], movingTop, true )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxAutoFollowAfterCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["FOLLOW_AFTER_COMBAT"],
		EMA.SettingsToggleAutoFollowAfterCombat,
		L["FOLLOW_AFTER_COMBAT_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxDelayAutoFollowAfterCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["DELAY_FOLLOW_AFTER_COMBAT"],
		EMA.SettingsToggleDelayAutoFollowAfterCombat
		
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxFollowAfterCombatDelaySeconds = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["TIME_DELAY_FOLLOWING"]
	)	
	EMA.settingsControl.editBoxFollowAfterCombatDelaySeconds:SetCallback( "OnEnterPressed", EMA.EditBoxChangedFollowAfterCombatDelaySeconds )
	movingTop = movingTop - editBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["FOLLOW_MASTER"], movingTop, true )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxUseFollowMaster = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["DIFFERENT_TOON_FOLLOW"],
		EMA.SettingsToggleUseFollowMaster,
		L["DIFFERENT_TOON_FOLLOW_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.dropdownFollowMaster = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["NEW_FOLLOW_MASTER"] 
	)
	BuildAndSetTeamList()
	EMA.settingsControl.dropdownFollowMaster:SetCallback( "OnValueChanged", EMA.SettingsSetFollowMaster )
	movingTop = movingTop - dropdownHeight - verticalSpacing	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["FOLLOW_BROKEN_WARNING"], movingTop, true )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxWarnWhenFollowBreaks = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["WARN_STOP_FOLLOWING"],
		EMA.SettingsToggleWarnWhenFollowBreaks,
		L["WARN_STOP_FOLLOWING_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxWarnInFollowPvP = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["WRAN_IN_PVP_COMBAT"],
		EMA.SettingsToggleWarnWhenFollowPvP,
		L["WRAN_IN_PVP_COMBAT_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxOnlyWarnIfOutOfFollowRange = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["ONLY_IF_OUTSIDE_RANGE"],
		EMA.SettingsToggleOnlyWarnIfOutOfFollowRange,
		L["ONLY_IF_OUTSIDE_RANGE_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxFollowBrokenMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["FOLLOW_BROKEN_MESSAGE"]
	)	
	EMA.settingsControl.editBoxFollowBrokenMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedFollowBrokenMessage )
	movingTop = movingTop - editBoxHeight
	EMA.settingsControl.dropdownWarningArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SEND_WARNING_AREA"] 
	)
	EMA.settingsControl.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownWarningArea:SetCallback( "OnValueChanged", EMA.SettingsSetWarningArea )
	movingTop = movingTop - dropdownHeight - verticalSpacing	
	EMA.settingsControl.labelDoNotWarnIf = EMAHelperSettings:CreateLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["DO_NOT_WARN"]
	)	
	movingTop = movingTop - labelHeight	
	EMA.settingsControl.checkBoxDoNotWarnInCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["IN_COMBAT"],
		EMA.SettingsToggleDoNotWarnInCombat,
		L["IN_COMBAT"]
	)	
	EMA.settingsControl.checkBoxDoNotWarnMembersInCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		column2left, 
		movingTop, 
		L["ANY_MEMBER_IN_COMBAT"],
		EMA.SettingsToggleDoNotWarnMembersInCombat
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxDoNotWarnFollowStrobing = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["FOLLOW_STROBING"],
		EMA.SettingsToggleDoNotWarnFollowStrobing
	)		
	movingTop = movingTop - checkBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["FOLLOW_STROBING"], movingTop, true )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.labelStrobeHelp = EMAHelperSettings:CreateLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["FOLLOW_STROBING_EMA_FOLLOW_COMMANDS."]
	)	
	movingTop = movingTop - labelHeight	
	EMA.settingsControl.checkBoxOverrideStrobeTargetWithMaster = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["USE_MASTER_STROBE_TARGET"],
		EMA.SettingsToggleOverrideStrobeTargetWithMaster
	)	
	movingTop = movingTop - checkBoxHeight	
	EMA.settingsControl.labelPauseStrobeHelp = EMAHelperSettings:CreateLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["PAUSE_FOLLOW_STROBING"]
	)	
	movingTop = movingTop - labelHeight	
	EMA.settingsControl.checkBoxPauseInCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["IN_COMBAT"],
		EMA.SettingsTogglePauseInCombat
	)	
	EMA.settingsControl.checkBoxPauseDrinking = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		column2left, --left, 
		movingTop, 
		L["DRINKING_EATING"],
		EMA.SettingsTogglePauseDrinking
	)		
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxPauseIfInVehicle = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		left, 
		movingTop, 
		L["IN_A_VEHICLE"],
		EMA.SettingsTogglePauseIfInVehicle
	)
	EMA.settingsControl.checkBoxPauseIfDead = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		halfWidth, 
		column2left, 
		movingTop, 
		L["PLAYER_DEAD"],
		EMA.SettingsTogglePauseIfDead
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.editBoxFollowStrobePauseTag = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["GROUP_FOLLOW_STROBE"]
	)	
	EMA.settingsControl.editBoxFollowStrobePauseTag:SetCallback( "OnEnterPressed", EMA.EditBoxChangedFollowStrobePauseTag )
	movingTop = movingTop - editBoxHeight
	EMA.settingsControl.editBoxFollowStrobeDelaySeconds = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		halfWidth,
		left,
		movingTop,
		L["FREQUENCY"]
	)	
	EMA.settingsControl.editBoxFollowStrobeDelaySeconds:SetCallback( "OnEnterPressed", EMA.EditBoxChangedFollowStrobeDelaySeconds )
	EMA.settingsControl.editBoxFollowStrobeDelaySecondsInCombat = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		halfWidth,
		column2left,
		movingTop,
		L["FREQUENCY_COMABT"]
	)	
	EMA.settingsControl.editBoxFollowStrobeDelaySecondsInCombat:SetCallback( "OnEnterPressed", EMA.EditBoxChangedFollowStrobeDelaySecondsInCombat )	
	movingTop = movingTop - editBoxHeight
	return movingTop	
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
end

local function SettingsCreate()
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
	local bottomOfDisplayOptions = SettingsCreateDisplayOptions( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfDisplayOptions )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

-------------------------------------------------------------------------------------------------------------
-- Settings Populate.
-------------------------------------------------------------------------------------------------------------

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	-- Set values.
	EMA.settingsControl.checkBoxAutoFollowAfterCombat:SetValue( EMA.db.autoFollowAfterCombat )
	EMA.settingsControl.checkBoxDelayAutoFollowAfterCombat:SetValue( EMA.db.useAfterCombatDelay )
	EMA.settingsControl.editBoxFollowAfterCombatDelaySeconds:SetText( EMA.db.afterCombatDelay )
	EMA.settingsControl.checkBoxWarnWhenFollowBreaks:SetValue( EMA.db.warnWhenFollowBreaks )
	EMA.settingsControl.checkBoxWarnInFollowPvP:SetValue( EMA.db.warnFollowPvP )
	EMA.settingsControl.checkBoxOnlyWarnIfOutOfFollowRange:SetValue( EMA.db.onlyWarnIfOutOfFollowRange )
	EMA.settingsControl.editBoxFollowBrokenMessage:SetText( EMA.db.followBrokenMessage )
	EMA.settingsControl.checkBoxDoNotWarnInCombat:SetValue( EMA.db.doNotWarnFollowBreakInCombat )
	EMA.settingsControl.checkBoxDoNotWarnMembersInCombat:SetValue( EMA.db.doNotWarnFollowBreakMembersInCombat )
	EMA.settingsControl.checkBoxDoNotWarnFollowStrobing:SetValue( EMA.db.doNotWarnFollowStrobing )
	EMA.settingsControl.checkBoxOverrideStrobeTargetWithMaster:SetValue( EMA.db.overrideStrobeTargetWithMaster )
	EMA.settingsControl.checkBoxPauseInCombat:SetValue( EMA.db.strobePauseInCombat )
	EMA.settingsControl.checkBoxPauseDrinking:SetValue( EMA.db.strobePauseIfDrinking )
	EMA.settingsControl.checkBoxPauseIfInVehicle:SetValue( EMA.db.strobePauseIfInVehicle )
	EMA.settingsControl.checkBoxPauseIfDead:SetValue( EMA.db.strobePauseIfDead )
	EMA.settingsControl.editBoxFollowStrobePauseTag:SetText( EMA.db.strobePauseTag )
	EMA.settingsControl.editBoxFollowStrobeDelaySeconds:SetText( EMA.db.strobeFrequencySeconds )
	EMA.settingsControl.editBoxFollowStrobeDelaySecondsInCombat:SetText( EMA.db.strobeFrequencySecondsInCombat )
	EMA.settingsControl.dropdownWarningArea:SetValue( EMA.db.warningArea )
	EMA.settingsControl.dropdownFollowMaster:SetValue( EMA.db.followMaster )
	EMA.settingsControl.checkBoxUseFollowMaster:SetValue( EMA.db.useFollowMaster )
	-- Set state.
	EMA.settingsControl.checkBoxDelayAutoFollowAfterCombat:SetDisabled( not EMA.db.autoFollowAfterCombat )
	EMA.settingsControl.editBoxFollowAfterCombatDelaySeconds:SetDisabled( not EMA.db.autoFollowAfterCombat or not EMA.db.useAfterCombatDelay )
	EMA.settingsControl.dropdownFollowMaster:SetDisabled( not EMA.db.useFollowMaster )
	EMA.settingsControl.editBoxFollowBrokenMessage:SetDisabled( not EMA.db.warnWhenFollowBreaks )
	EMA.settingsControl.checkBoxWarnInFollowPvP:SetDisabled( not EMA.db.warnWhenFollowBreaks )
	EMA.settingsControl.checkBoxOnlyWarnIfOutOfFollowRange:SetDisabled( not EMA.db.warnWhenFollowBreaks )
	EMA.settingsControl.checkBoxDoNotWarnInCombat:SetDisabled( not EMA.db.warnWhenFollowBreaks )
	EMA.settingsControl.checkBoxDoNotWarnMembersInCombat:SetDisabled( not EMA.db.warnWhenFollowBreaks )
	EMA.settingsControl.checkBoxDoNotWarnFollowStrobing:SetDisabled( not EMA.db.warnWhenFollowBreaks )
	EMA.settingsControl.dropdownWarningArea:SetDisabled( not EMA.db.warnWhenFollowBreaks )
	EMA.settingsControl.labelDoNotWarnIf:SetDisabled( not EMA.db.warnWhenFollowBreaks )
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleUseFollowMaster( event, checked )
	EMA.db.useFollowMaster = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoFollowAfterCombat( event, checked )
	EMA.db.autoFollowAfterCombat = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDelayAutoFollowAfterCombat( event, checked )
	EMA.db.useAfterCombatDelay = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedFollowAfterCombatDelaySeconds( event, text )
	EMA.db.afterCombatDelay = tonumber( text )
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnWhenFollowBreaks( event, checked )
	EMA.db.warnWhenFollowBreaks = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnWhenFollowPvP( event, checked )
	EMA.db.warnFollowPvP = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleOnlyWarnIfOutOfFollowRange( event, checked )
	EMA.db.onlyWarnIfOutOfFollowRange = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedFollowBrokenMessage( event, text )
	EMA.db.followBrokenMessage = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDoNotWarnInCombat( event, checked )
	EMA.db.doNotWarnFollowBreakInCombat = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDoNotWarnMembersInCombat( event, checked )
	EMA.db.doNotWarnFollowBreakMembersInCombat = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDoNotWarnFollowStrobing( event, checked )
	EMA.db.doNotWarnFollowStrobing = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleOverrideStrobeTargetWithMaster( event, checked )
	EMA.db.overrideStrobeTargetWithMaster = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsTogglePauseInCombat( event, checked )
	EMA.db.strobePauseInCombat = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsTogglePauseDrinking( event, checked )
	EMA.db.strobePauseIfDrinking = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsTogglePauseIfInVehicle( event, checked )
	EMA.db.strobePauseIfInVehicle = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsTogglePauseIfDead( event, checked )
	EMA.db.strobePauseIfDead = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedFollowStrobePauseTag( event, text )
	EMA.db.strobePauseTag = text
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedFollowStrobeDelaySeconds( event, text )
	EMA.db.strobeFrequencySeconds = text
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedFollowStrobeDelaySecondsInCombat( event, text )
	EMA.db.strobeFrequencySecondsInCombat = text
	EMA:SettingsRefresh()
end

function EMA:SettingsSetWarningArea( event, value )
	EMA.db.warningArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsSetFollowMaster( event, value )
	EMA.db.followMaster = value
	EMA:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- Key bindings.
-------------------------------------------------------------------------------------------------------------

function EMA:UPDATE_BINDINGS()
	if InCombatLockdown() then
		return
	end
	ClearOverrideBindings( EMA.keyBindingFrame )
	local key1, key2 = GetBindingKey( "FOLLOWME" )		
	if key1 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key1, "EMAFollowMe" ) 
	end
	if key2 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key2, "EMAFollowMe" ) 
	end	
	local key1, key2 = GetBindingKey( "FOLLOWSTROBEME" )		
	if key1 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key1, "EMAFollowStrobeMe" ) 
	end
	if key2 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key2, "EMAFollowStrobeMe" ) 
	end
	local key1, key2 = GetBindingKey( "FOLLOWSTROBEOFF" )		
	if key1 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key1, "EMAFollowStrobeOff" ) 
	end
	if key2 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key2, "EMAFollowStrobeOff" ) 
	end
	local key1, key2 = GetBindingKey( "FOLLOWTEAIN" )		
	if key1 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key1, "EMAFollowTrain" ) 
	end
	if key2 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key2, "EMAFollowTrain" ) 
	end
	local key1, key2 = GetBindingKey( "FOLLOWSTOP" )		
	if key1 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key1, "EMAFollowStop" ) 
	end
	if key2 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key2, "EMAFollowStop" ) 
	end	
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	EMA.EMAExternalNoWarnNextBreak = false
	EMA.EMAExternalNoWarnNextSecondBreak = false	
	-- An empty team list.
	EMA.teamList = {}
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
	-- Current follow target.
	EMA.currentFollowTarget = EMAApi.GetMasterName()
	EMA:UpdateFollowTargetToFollowMaster()
	-- Set to true if EMA initiated a follow.
	EMA.EMASetFollowTarget = false
	-- Following flag.
	EMA.isFollowing = false
	EMA.warnFollowPvPCombat = true
	EMA.PvPTimerReset = nil
	-- Strobing follow.
	EMA.currentFollowStrobeTarget = EMAApi.GetMasterName()
	EMA.followingStrobing = false
	EMA.followStrobeTimer = nil
	EMA.followingStrobingPaused = false	
	-- Not in combat flag.
	EMA.outOfCombat = true
	-- Character on taxi flag.
	EMA.characterIsOnTaxi = false
-- Key bindings.
	EMAFollowMe = CreateFrame( "CheckButton", "EMAFollowMe", nil, "SecureActionButtonTemplate" )
	EMAFollowMe:SetAttribute( "type", "macro" )
	EMAFollowMe:SetAttribute( "macrotext", "/ema-follow me all" )
	EMAFollowMe:Hide()
	EMAFollowStrobeMe = CreateFrame( "CheckButton", "EMAFollowStrobeMe", nil, "SecureActionButtonTemplate" )
	EMAFollowStrobeMe:SetAttribute( "type", "macro" )
	EMAFollowStrobeMe:SetAttribute( "macrotext", "/ema-follow strobeonme all" )
	EMAFollowStrobeMe:Hide()
	EMAFollowStrobeOff = CreateFrame( "CheckButton", "EMAFollowStrobeOff", nil, "SecureActionButtonTemplate" )
	EMAFollowStrobeOff:SetAttribute( "type", "macro" )
	EMAFollowStrobeOff:SetAttribute( "macrotext", "/ema-follow strobeoff all" )
	EMAFollowStrobeOff:Hide()
	EMAFollowTrain = CreateFrame( "CheckButton", "EMAFollowTrain", nil, "SecureActionButtonTemplate" )
	EMAFollowTrain:SetAttribute( "type", "macro" )
	EMAFollowTrain:SetAttribute( "macrotext", "/ema-follow train all" )
	EMAFollowTrain:Hide()
	EMAFollowStop = CreateFrame( "CheckButton", "EMAFollowStop", nil, "SecureActionButtonTemplate" )
	EMAFollowStop:SetAttribute( "type", "macro" )
	EMAFollowStop:SetAttribute( "macrotext", "/ema-follow stop all" )
	EMAFollowStop:Hide()
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	-- WoW events.
	EMA:RegisterEvent( "AUTOFOLLOW_BEGIN" )
	EMA:RegisterEvent( "AUTOFOLLOW_END" )
	EMA:RegisterEvent( "PLAYER_REGEN_DISABLED" )
	EMA:RegisterEvent( "PLAYER_REGEN_ENABLED" )	
	EMA:RegisterEvent( "PLAYER_CONTROL_GAINED" )
	EMA:RegisterEvent( "UNIT_ENTERING_VEHICLE" )
	EMA:RegisterEvent( "UNIT_EXITING_VEHICLE" )
	EMA:RegisterEvent( "UI_ERROR_MESSAGE", "PVP_FOLLOW" )
	-- Initialise key bindings.
	EMA.keyBindingFrame = CreateFrame( "Frame", nil, UIParent )
	EMA:RegisterEvent( "UPDATE_BINDINGS" )		
	EMA:UPDATE_BINDINGS()
	-- EMA events.
	if EMAApi.Taxi ~= nil then
		EMA:RegisterMessage( EMAApi.Taxi.MESSAGE_TAXI_TAKEN, "CharacterOnTaxi" )	
	end
	EMA:RegisterMessage( EMAApi.MESSAGE_TEAM_MASTER_CHANGED, "OnMasterChanged" )
	EMA:RegisterMessage( EMAApi.MESSAGE_TEAM_CHARACTER_ADDED, "OnTeamChanged" )
	EMA:RegisterMessage( EMAApi.MESSAGE_TEAM_CHARACTER_REMOVED, "OnTeamChanged" )
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
end


-- Called when the addon is disabled.
function EMA:OnDisable()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.warnWhenFollowBreaks = settings.warnWhenFollowBreaks
		EMA.db.followBrokenMessage = settings.followBrokenMessage
		EMA.db.autoFollowAfterCombat = settings.autoFollowAfterCombat
		EMA.db.strobeFrequencySeconds = settings.strobeFrequencySeconds
		EMA.db.strobeFrequencySecondsInCombat = settings.strobeFrequencySecondsInCombat
		EMA.db.doNotWarnFollowBreakInCombat = settings.doNotWarnFollowBreakInCombat
		EMA.db.doNotWarnFollowBreakMembersInCombat = settings.doNotWarnFollowBreakMembersInCombat
		EMA.db.warnFollowPvP = settings.warnFollowPvP
		EMA.db.strobePauseInCombat = settings.strobePauseInCombat
		EMA.db.strobePauseIfInVehicle = settings.strobePauseIfInVehicle
		EMA.db.strobePauseIfDead = settings.strobePauseIfDead
		EMA.db.strobePauseIfDrinking = settings.strobePauseIfDrinking
		EMA.db.strobePauseTag = settings.strobePauseTag
		EMA.db.doNotWarnFollowStrobing = settings.doNotWarnFollowStrobing
		EMA.db.warningArea = settings.warningArea
		EMA.db.followMaster = settings.followMaster
		EMA.db.useFollowMaster = settings.useFollowMaster
		EMA.db.overrideStrobeTargetWithMaster = settings.overrideStrobeTargetWithMaster
		EMA.db.useAfterCombatDelay = settings.useAfterCombatDelay
		EMA.db.afterCombatDelay = settings.afterCombatDelay
		EMA.db.onlyWarnIfOutOfFollowRange = settings.onlyWarnIfOutOfFollowRange
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

-------------------------------------------------------------------------------------------------------------
-- Follow functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:UNIT_ENTERING_VEHICLE()
	if EMA.db.strobePauseIfInVehicle == true then
		if EMA.followingStrobing == true then
			if EMA.followingStrobingPaused == false then
				EMA:FollowStrobingPause( true )
			end
		end
	end
end

function EMA:UNIT_EXITING_VEHICLE()
	if EMA.db.strobePauseIfInVehicle == true then
		if EMA.followingStrobing == true then
			if EMA.followingStrobingPaused == true then
				EMA:FollowStrobingPause( false )
			end
		end
	end
end

function EMA:AreTeamMembersInCombat()
	local inCombat = false
	for index, characterName in EMAApi.TeamListOrdered() do
		-- Is the team member online?
		if EMAApi.GetCharacterOnlineStatus( characterName ) == true then
			-- Yes, is the character in combat?
			if UnitAffectingCombat( Ambiguate( characterName, "none" ) ) then
			inCombat = true
				break
			end
		end
	end
	return inCombat
end

function EMA:IsFollowingStrobing()
	return EMA.followingStrobing
end

function EMA:IsFollowingStrobingPaused()
	return EMA.followingStrobingPaused
end


function EMA:CharacterOnTaxi()
	EMA:SetNoFollowBrokenWarningNextBreak()
	if EMA:IsFollowingStrobing() == true then
		if EMA:IsFollowingStrobingPaused() == false then
			EMA:FollowStrobingPause( true )
			EMA.characterIsOnTaxi = true
		end
	end
end


function EMA:PLAYER_CONTROL_GAINED()
	if EMA.characterIsOnTaxi == true then
		EMA.characterIsOnTaxi = false
		if EMA:IsFollowingStrobing() == true then
			if EMA:IsFollowingStrobingPaused() == true then
				EMA:FollowStrobingPause( false )
			end
		end
	end
end


function EMA:SuppressNextFollowWarningCommand( info, parameters )
	EMA:SuppressNextFollowWarning()
end

function EMA:SuppressNextFollowWarning()
	-- Events are fired as follows for a /follow command.
	--EMA:Print("testfollow", EMA.isFollowing)
	if EMA.isFollowing == true then
		EMA:SetNoFollowBrokenWarningNextBreak()
		EMA:SetNoFollowBrokenWarningNextSecondBreak()
	else
		EMA:SetNoFollowBrokenWarningNextBreak()
	end
end

function EMA:SetNoFollowBrokenWarningNextBreak()
	EMA.EMAExternalNoWarnNextBreak = true	
end

function EMA:SetNoFollowBrokenWarningNextSecondBreak()
	EMA.EMAExternalNoWarnNextSecondBreak = true	
end


function EMA:AUTOFOLLOW_BEGIN( event, target, ... )	
	EMA.currentFollowTarget = target
	EMA.isFollowing = true	
end

function EMA:AUTOFOLLOW_END( event, ... )
	EMA.isFollowing = false
	EMA:ScheduleTimer( "AutoFollowEndUpdate", 0.5 )
end

-- checks the follow system Msg, is there under 1 always 1 unless it fadeing.
function EMA:AutoFollowEndUpdate()
	local alpha = AutoFollowStatus:GetAlpha()
	--EMA:Print("updatetest", test)
	if alpha < 1 then
		--EMA:Print("canSend")
		EMA:AutoFollowEndSend()
	end
end

function EMA:AutoFollowEndSend()
	-- If warn if auto follow breaks is on...
	local canWarn = false
	if EMA.db.warnWhenFollowBreaks == true then
		if EMA.EMASetFollowTarget == false then
			canWarn = true			
		end
	end
	-- Do not warn if on Taxi
	if UnitOnTaxi("player") == true then
		--EMA:Print("taxi")
		canWarn = false
	end	
	--Do not warn if in combat?
	if EMA.db.doNotWarnFollowBreakInCombat == true and EMA.outOfCombat == false then
		--EMA:Print("Do Not warn in comabt")
		canWarn = false
	end
	--Do not warn if a passenger in a vehicle.
	if UnitInVehicle("Player") == true and UnitControllingVehicle("player") == false then
		--EMA:Print("UnitInVehicle")
		canWarn = false
	end
	-- Do not warn if any other members in combat?
	if EMA.db.doNotWarnFollowBreakMembersInCombat == true and EMA:AreTeamMembersInCombat() == true or UnitAffectingCombat("player") == true then
		--EMA:Print("doNotWarnFollowBreakMembersInCombat")
		canWarn = false
	end
	-- Don't warn about follow breaking if follow strobing is on or paused.
	if EMA.db.doNotWarnFollowStrobing == true then
		if EMA.followingStrobing == true or EMA.followStrobingPaused == true then
			--EMA:Print("FollowStrobing")
			canWarn = false
		end
	end
	-- Check to see if range warning is in effect. This olny works in a party it seems!!
	if EMA.db.onlyWarnIfOutOfFollowRange == true then
		if CheckInteractDistance( EMA.currentFollowTarget, 4 ) then
			--EMA:Print("CheckInteractDistance")
			canWarn = false
		end
	end	
	if EMA.EMAExternalNoWarnNextBreak == true then
		--EMA:Print("test", EMA.EMAExternalNoWarnNextBreak )
		canWarn = false		
		EMA.EMAExternalNoWarnNextBreak = false
	end
	-- If allowed to warn, then warn.
	if canWarn == true then
		EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.followBrokenMessage, false )
	end
	EMA.EMASetFollowTarget = false		
end

function EMA:PLAYER_REGEN_ENABLED()
	EMA.outOfCombat = true
	-- Is auto follow after combat on?
	if EMA.db.autoFollowAfterCombat == true then
		if EMA.db.useAfterCombatDelay == false then
			EMA:FollowTarget( EMA.currentFollowTarget )
		else
			EMA:ScheduleTimer( "FollowTarget", tonumber( EMA.db.afterCombatDelay ), EMA.currentFollowTarget )
		end
	end
	-- Is follow strobing on?
	if EMA:IsFollowingStrobing() == true then
		-- Pause follow strobing while in combat?
		if EMA.db.strobePauseInCombat == true then
			-- Un-pause follow strobing.
			EMA:FollowStrobingPause( false )
		else
			-- Not pausing, so check strobe rate.
			if EMA.db.strobeFrequencySeconds ~= EMA.db.strobeFrequencySecondsInCombat then
				EMA:FollowStrobeOn( EMA.currentFollowStrobeTarget )
			end
		end	
	end
end

function EMA:PLAYER_REGEN_DISABLED()
	EMA.outOfCombat = false
	-- Is follow strobing on?
	if EMA:IsFollowingStrobing() == true then
		-- Pause follow strobing while in combat?
		if EMA.db.strobePauseInCombat == true then
			-- Pause follow strobing.
			EMA:FollowStrobingPause( true )
		else
			-- Not pausing, so check strobe rate.
			if EMA.db.strobeFrequencySeconds ~= EMA.db.strobeFrequencySecondsInCombat then
				EMA:FollowStrobeOn( EMA.currentFollowStrobeTarget )
			end
		end
	end
	if EMA.db.warnFollowPvP == true then
		EMA.warnFollowPvPCombat = true
	end	
end

function EMA:PVP_FOLLOW(event, arg1, message, ...  )
	--EMA:Print("test", message, EMA.warnFollowPvPCombat )
	if EMA.db.warnFollowPvP == false and EMA.db.warnWhenFollowBreaks == false then
		return
	end
	if message == ERR_INVALID_FOLLOW_TARGET_PVP_COMBAT or message == ERR_INVALID_FOLLOW_PVP_COMBAT then
		
		if EMA.warnFollowPvPCombat == true then
			EMA:EMASendMessageToTeam( EMA.db.warningArea, L["PVP_FOLLOW_ERR"], false )
			EMA.warnFollowPvPCombat = false
			EMA:ScheduleTimer("ResetPvpWarn", 10, nil )
			EMA.PvPTimerReset = EMA:EMASendMessageToTeam( EMA.db.warningArea, L["PVP_FOLLOW_ERR"], false )
		end
	end
end

function EMA:ResetPvpWarn()
	EMA.warnFollowPvPCombat = true
	EMA:CancelTimer( EMA.PvPTimerReset )
end	

function EMA:AutoFollowAfterCombatCommand( info, parameters )
	-- Get the on/off state and the tag of who to send to.
	local state, tag = strsplit( " ", parameters )			
	if tag ~= nil and tag:trim() ~= "" then
		EMA:AutoFollowAfterCombatSendCommand( state, tag )
	else
		EMA:DoToggleAutoFollowAfterCombat( state )
	end	
end

function EMA:AutoFollowAfterCombatSendCommand( state, tag )
	EMA:EMASendCommandToTeam( EMA.COMMAND_AUTO_FOLLOW_AFTER_COMBAT, state, tag )
end

function EMA:AutoFollowAfterCombatReceiveCommand( state, tag )
	-- If this character responds to this tag...
	if EMAApi.DoesCharacterHaveTag( EMA.characterName, tag ) then
		EMA:DoToggleAutoFollowAfterCombat( state )
	end
end

function EMA:DoToggleAutoFollowAfterCombat( state )
	-- Translate the on/off state from string to boolean/nil.
	local setToOn = EMAUtilities:GetOnOrOffFromCommand( state, L["ON"], L["OFF"] )	
	-- If nil, then assume false.
	if setToOn == nil then
		setToOn = false
	end		
	-- Then set the flag appropriately.
	EMA:SettingsToggleAutoFollowAfterCombat( nil, setToOn )
	-- Refresh the settings.
	EMA:SettingsRefresh()
end

function EMA:GetCurrentFollowTarget()
	return EMA.currentFollowTarget
end

function EMA:GetCurrentFollowStrobeTarget()
	return EMA.currentFollowStrobeTarget
end

function EMA:UpdateFollowTargetToFollowMaster()
	if EMA.db.useFollowMaster == true then
		EMA.currentFollowTarget = EMAApi.GetMasterName()
		if EMA.db.followMaster ~= "" then
			if EMAApi.GetCharacterOnlineStatus( EMA.db.followMaster ) == true then
				EMA.currentFollowTarget = EMA.db.followMaster
			end
		end
	end
end

function EMA:OnMasterChanged()
	if EMA.db.autoFollowAfterCombat == true then
		EMA.currentFollowTarget = EMAApi.GetMasterName()	
		EMA:UpdateFollowTargetToFollowMaster()
	end
	if EMA.followingStrobing == true then
		if EMA.db.overrideStrobeTargetWithMaster == true then
			EMA.currentFollowStrobeTarget = EMAApi.GetMasterName()
			EMA:FollowStrobeOn( EMA.currentFollowStrobeTarget )
		end
	end
end

function EMA:OnTeamChanged()
	BuildAndSetTeamList()
end

function EMA:CommandFollowTrain( info, parameters )
	local tag = parameters
	if tag ~= nil and tag:trim() ~= "" then 
		EMA:EMASendCommandToTeam( EMA.COMMAND_FOLLOW_TRAIN, tag )
	end
end

function EMA:ReceiveCommandFollowTrain( tag )
	if EMAApi.DoesCharacterHaveTag( EMA.characterName, tag ) then
		local characterInFront = nil
		for index, character in EMAApi.TeamListOrderedOnline() do
			if character == EMA.characterName then
				if characterInFront ~= nil then
					FollowUnit( Ambiguate( characterInFront, "none" ), true )
				end
				return
			else
				if EMAApi.DoesCharacterHaveTag( character, tag ) then
					characterInFront = character
				end
			end
		end
	end
end

function EMA:CommandFollowMe( info, parameters )
	local tag = parameters
	if tag ~= nil and tag:trim() ~= "" then 
		EMA.SuppressNextFollowWarning()
		EMA:EMASendCommandToTeam( EMA.COMMAND_FOLLOW_ME, tag )
	end
end

function EMA:ReceiveCommandFollowMe( characterName, tag )
	--EMA:Print("testfollowme", characterName, tag )
	if EMAApi.DoesCharacterHaveTag( EMA.characterName, tag ) and characterName ~= EMA.characterName then
		--EMA:Print("works")
		FollowUnit( Ambiguate( characterName, "none" ), true )	
	end
end

function EMA:CommandSetFollowMaster( info, parameters )
	local target, tag = strsplit( " ", parameters )
	if tag ~= nil and tag:trim() ~= "" then 
		EMA:EMASendCommandToTeam( EMA.COMMAND_SET_FOLLOW_MASTER, target, tag )
	else
		EMA.db.followMaster = target
		EMA:UpdateFollowTargetToFollowMaster()
	end
end

function EMA:ReceiveCommandSetFollowMaster( target, tag )
	if EMAPrivate.Tag.DoesCharacterHaveTag( EMA.characterName, tag ) then
		EMA.db.followMaster = target
		EMA:UpdateFollowTargetToFollowMaster()
	end
end

function EMA:FollowMasterCommand( info, parameters )
	-- The only parameter for this command is tag.  If there is a tag, send the command to all
	-- the members, otherwise just this character.
	local tag = parameters
	-- Set the current follow target to the master.
	EMA.currentFollowTarget = EMAApi.GetMasterName()
	EMA:UpdateFollowTargetToFollowMaster()
	if tag ~= nil and tag:trim() ~= "" then
		EMA:FollowTargetSendCommand( EMA.currentFollowTarget, tag )
	else
		EMA:SuppressNextFollowWarning()
		EMA:FollowTarget( EMA.currentFollowTarget )
	end	
end

function EMA:FollowTargetCommand( info, parameters )
	local target, tag = strsplit( " ", parameters )
	if tag ~= nil and tag:trim() ~= "" then
		EMA:FollowTargetSendCommand( target, tag )
	else
		EMA.currentFollowTarget = target
		EMA:SuppressNextFollowWarning()
		EMA:FollowTarget( EMA.currentFollowTarget )
	end	
end

function EMA:FollowTargetSendCommand( target, tag )
	EMA:EMASendCommandToTeam( EMA.COMMAND_FOLLOW_TARGET, target, tag )
end

function EMA:FollowTargetReceiveCommand( target, tag )
	-- If this character responds to this tag...
	if EMAApi.DoesCharacterHaveTag( EMA.characterName, tag ) then
		-- Then follow the target specified.
		EMA.currentFollowTarget = target
		EMA:SuppressNextFollowWarning()
		EMA:FollowTarget( EMA.currentFollowTarget )
	end
end

local function FollowStrobeOnMeCommandIsboxer( tag )
	--EMA:Print("testaa", tag )
	if tag ~= nil and tag:trim() ~= "" then
		EMA:FollowStrobeOnSendCommand( EMA.characterName, tag )
	else
		EMA:FollowStrobeOn( EMA.characterName )
	end
end


function EMA:FollowStrobeOnMeCommand( info, parameters )
	local tag = parameters
	if tag ~= nil and tag:trim() ~= "" then
		EMA:FollowStrobeOnSendCommand( EMA.characterName, tag )
	else
		EMA:FollowStrobeOn( EMA.characterName )
	end	
end

function EMA:FollowStrobeOnLastCommand( info, parameters )
	local tag = parameters
	if tag ~= nil and tag:trim() ~= "" then
		EMA:FollowStrobeOnSendCommand( EMA.currentFollowStrobeTarget, tag )
	else
		EMA:FollowStrobeOn( EMA.currentFollowStrobeTarget )
	end	
end

function EMA:FollowStrobeOnCommand( info, parameters )
	local target, tag = strsplit( " ", parameters )
	if tag ~= nil and tag:trim() ~= "" then
		EMA:FollowStrobeOnSendCommand( target, tag )
	else
		EMA:FollowStrobeOn( target )
	end	
end

function EMA:FollowStrobeOnSendCommand( target, tag )
	EMA:EMASendCommandToTeam( EMA.COMMAND_FOLLOW_STROBE_ON, target, tag )
end

function EMA:FollowStrobeOnReceiveCommand( target, tag )
	-- If this character responds to this tag...
	if EMAApi.DoesCharacterHaveTag( EMA.characterName, tag ) then
		-- Then follow the target specified - strobing.
		EMA:FollowStrobeOn( target )
	end
end

local function FollowStrobeOffCommandIsboxer( tag )
	if tag ~= nil and tag:trim() ~= "" then
		EMA:FollowStrobeOffSendCommand( tag )
	else		
		EMA:FollowStrobeOffSendCommand( "all" )
	end	
end

function EMA:FollowStrobeOffCommand( info, parameters )
	local tag = parameters
	if tag ~= nil and tag:trim() ~= "" then
		EMA:FollowStrobeOffSendCommand( tag )
	else		
		EMA:FollowStrobeOffSendCommand( "all" )
	end	
end

function EMA:FollowStrobeOffSendCommand( tag )
	EMA:EMASendCommandToTeam( EMA.COMMAND_FOLLOW_STROBE_OFF, tag )
end

function EMA:FollowStrobeOffReceiveCommand( tag )
	-- If this character responds to this tag...
	if EMAApi.DoesCharacterHaveTag( EMA.characterName, tag ) then
		-- Then follow the target specified - turn off strobing.
		EMA:FollowStrobeOff()
	end
end	

function EMA:FollowTarget( target )
	-- Attempting to follow self?  Note: if target ever is party1, etc, then this will not catch the same character.
	if target == EMA.characterName then
		return
	end
	local canFollowTarget = true
	-- If follow strobing and pause strobing if drinking then...
	if EMA.followingStrobing == true and EMA.db.strobePauseIfDrinking == true then
		-- And the character has the pause tag...
		if EMAApi.DoesCharacterHaveTag( EMA.characterName, EMA.db.strobePauseTag ) == true then
			-- Check player for drinking buff.
			if EMAUtilities:DoesThisCharacterHaveBuff( L["DRINK"] ) == true then
				-- Have drinking buff, do not allow follow.
				canFollowTarget = false
			end
			if EMAUtilities:DoesThisCharacterHaveBuff( L["FOOD"] ) == true then
				-- Have eating buff, do not allow follow.
				canFollowTarget = false
			end
			if EMAUtilities:DoesThisCharacterHaveBuff( L["REFRESHMENT"] ) == true then
				-- Eating Mage food Yum Yum Yum.
				canFollowTarget = false
			end
		end
	end
	if EMA.followingStrobing == true and EMA.db.strobePauseIfDead == true then
		local isDeadOrGhost = UnitIsDeadOrGhost("player")
		if isDeadOrGhost == true then 
			canFollowTarget = false
		end	
	end	
	-- If follow strobing and strobing paused.
	if EMA.followingStrobing == true and EMA.followingStrobingPaused == true then
		-- Follow strobing is paused, do not follow target.
		canFollowTarget = false		
	end
	-- If allowed to follow the target, then...
	if canFollowTarget == true then
		-- Set the EMA set this flag toggle, so not to complain about follow broken after combat.
		--if (EMA.db.autoFollowAfterCombat == true) or (EMA.followingStrobing == true) then
		if 	EMA.followingStrobing == true then
			EMA.EMASetFollowTarget = true	
		end
		--EMA:Print( target )
		-- Follow unit only works when in a party or raid for resolving against player names.
		FollowUnit( Ambiguate( target, "none" ), true )
	end	
end

function EMA:FollowStrobeOn( target )
	EMA.currentFollowStrobeTarget = target
	-- Do the initial follow.
    EMA:FollowTarget( EMA.currentFollowStrobeTarget )
	-- If the timer is running, then 
	if EMA.followingStrobing == true then
		EMA:FollowStrobeOff()
	end
	-- Set up a timer to do another follow command.
	EMA.followingStrobing = true
	local seconds = EMA.db.strobeFrequencySeconds
	if InCombatLockdown() then
		seconds = EMA.db.strobeFrequencySecondsInCombat
	end
	EMA.followStrobeTimer = EMA:ScheduleRepeatingTimer( "FollowTarget", tonumber( seconds ), EMA.currentFollowStrobeTarget )
end

function EMA:FollowStrobeOff()
	-- Stop the timer from doing another follow command.
	if EMA.followingStrobing == true then
		EMA.followingStrobing = false
		--FollowUnit("player")
		EMA:CancelTimer( EMA.followStrobeTimer )
	end	
end

function EMA:FollowStrobingPause( pause )
	if pause == true then
		-- Is follow strobing on?
		if EMA.followingStrobing == true then
			-- Yes, turn it off, if this character has a tag that matches the pause follow strobe tag.
			if EMAApi.DoesCharacterHaveTag( EMA.characterName, EMA.db.strobePauseTag ) == true then
				EMA.followingStrobingPaused = true
			end
		end
	else
		-- Is follow strobing paused?
		if EMA.followingStrobingPaused == true then
			-- Yes, turn it on, if this character has a tag that matches the pause follow strobe tag.
			if EMAApi.DoesCharacterHaveTag( EMA.characterName, EMA.db.strobePauseTag ) == true then
				EMA.followingStrobingPaused = false
			end
		end
	end	
end

function EMA:CommandFollowStop( info, parameters )
	local tag = parameters
	if tag ~= nil and tag:trim() ~= "" then 
		EMA:EMASendCommandToTeam( EMA.COMMAND_FOLLOW_STOP, tag )
	end
end

function EMA:ReceiveCommandFollowStop( characterName, tag )
	--EMA:Print("testfollowStop", characterName, tag ) 
	if EMAApi.DoesCharacterHaveTag( EMA.characterName, tag ) and characterName ~= EMA.characterName then
		FollowUnit( "player" )
	end
end

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if commandName == EMA.COMMAND_FOLLOW_TARGET then
		EMA:FollowTargetReceiveCommand( ... )
	end
	if commandName == EMA.COMMAND_AUTO_FOLLOW_AFTER_COMBAT then
		EMA:AutoFollowAfterCombatReceiveCommand( ... )
	end
	if commandName == EMA.COMMAND_FOLLOW_STROBE_ON then
		EMA:FollowStrobeOnReceiveCommand( ... )
	end
	if commandName == EMA.COMMAND_FOLLOW_STROBE_OFF then
		EMA:FollowStrobeOffReceiveCommand( ... )
	end
	if commandName == EMA.COMMAND_SET_FOLLOW_MASTER then
		EMA:ReceiveCommandSetFollowMaster( ... )
	end
	if commandName == EMA.COMMAND_FOLLOW_TRAIN then
		EMA:ReceiveCommandFollowTrain( ... )
	end
	if commandName == EMA.COMMAND_FOLLOW_ME then
		EMA:ReceiveCommandFollowMe( characterName, ... )
	end
	if commandName == EMA.COMMAND_FOLLOW_STOP then
		EMA:ReceiveCommandFollowStop( characterName, ... )
	end
end

EMAApi.Follow = {}
EMAApi.Follow.IsFollowingStrobing = EMA.IsFollowingStrobing
EMAApi.Follow.IsFollowingStrobingPaused = EMA.IsFollowingStrobingPaused
EMAApi.Follow.GetCurrentFollowTarget = EMA.GetCurrentFollowTarget
EMAApi.Follow.GetCurrentFollowStrobeTarget = EMA.GetCurrentFollowStrobeTarget
EMAApi.Follow.SuppressNextFollowWarning = EMA.SuppressNextFollowWarning
EMAApi.Follow.StrobeOnMeCommand = FollowStrobeOnMeCommandIsboxer
EMAApi.Follow.StrobeOffCommand = FollowStrobeOffCommandIsboxer