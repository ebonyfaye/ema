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
	"Toon", 
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
EMA.SharedMedia = LibStub( "LibSharedMedia-3.0" )


--  Constants and Locale for this module.
EMA.moduleName = "Toon"
EMA.settingsDatabaseName = "ToonProfileDB"
EMA.chatCommand = "ema-toon"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["TOON"]
EMA.parentDisplayNameToon = L["TOON"]
EMA.parentDisplayNameMerchant = L["VENDOR"]
EMA.moduleDisplayName = L["TOON"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\Toon.tga"
EMA.moduleIconWarnings = "Interface\\Addons\\EMA\\Media\\WarningIcon.tga"
EMA.moduleIconRepair = "Interface\\Addons\\EMA\\Media\\moduleIconRepair.tga"
-- order
EMA.moduleOrder = 40
EMA.moduleWarningsOrder = 1
EMA.moduleRepairOrder = 1

-- EMA key bindings.
BINDING_HEADER_TOON = L["TOON"]
BINDING_NAME_SETVIEW= L["SET_VIEW"]

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		warnHitFirstTimeCombat = false,
		hitFirstTimeMessage = L["ATTACKED"],
		warnTargetNotMasterEnterCombat = false,
		warnTargetNotMasterMessage = L["TARGETING"],
		warnFocusNotMasterEnterCombat = false,
		warnFocusNotMasterMessage = L["FOCUS"],
		warnWhenHealthDropsBelowX = true,
		warnWhenHealthDropsAmount = "30",
		warnHealthDropsMessage = L["LOW_HEALTH"],
		warnWhenManaDropsBelowX = true,
		warnWhenManaDropsAmount = "30",
		warnManaDropsMessage = L["LOW_MANA"],
		warnWhenDurabilityDropsBelowX = true,
		warnWhenDurabilityDropsAmount = "60",
		warnWhenBagsAlmostFullAmount = 0,
		warnDurabilityDropsMessage = L["DURABILITY_LOW_MSG"],		
		warnBagsFull = true,
		bagsFullMessage = L["BAGS_FULL"],
		bagsAlmostFullMessage = L["BAGS_ALMOST_FULL"],
		warnCC = true,
		CcMessage = L["CCED"],
		warningArea = EMAApi.DefaultWarningArea(),
		autoAcceptResurrectRequest = true,
		autoAcceptResurrectRequestOnlyFromTeam = true,
		acceptDeathRequests = true,
		autoDenyDuels = true,
		autoAcceptSummonRequest = false,
		autoDenyGuildInvites = false,
		requestArea = EMAApi.DefaultMessageArea(),
		autoRepair = true,
		autoRepairUseGuildFunds = true,
		merchantArea = EMAApi.DefaultMessageArea(),
		autoAcceptRoleCheck = false,
		enterLFGWithTeam = false,
		acceptReadyCheck = false,
		teleportLFGWithTeam = false,
		rollWithTeam = false,
		toggleWarMode = false,
		autoAcceptPartySyncRequest = false,
		setViewWithoutMaster = true,
		setView = 1,
		--Debug Suff
		testAlwaysOff = true
	},
}

-- Configuration.
function EMA:GetConfiguration()
	local configuration = {
		name = EMA.moduleDisplayName,
		handler = EMA,
		type = 'group',
		args = {
			SetView = {
				type = "input",
				name = L["SET_VIEW"],
				desc = L["SET_VIEW_HELP"],
				usage = "/ema-toon setview",
				get = false,
				set = "SetView",
			},
				config = {
				type = "input",
				name = L["OPEN_CONFIG"],
				desc = L["OPEN_CONFIG_HELP"],
				usage = "/ema-toon config",
				get = false,
				set = "",
			},
				push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_ALL_SETTINGS"],
				usage = "/ema-toon push",
				get = false,
				set = "EMASendSettings",
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

EMA.COMMAND_TEAM_DEATH = "EMAToonTeamDeath"
EMA.COMMAND_RECOVER_TEAM = "EMAToonRecoverTeam"
EMA.COMMAND_SOUL_STONE = "EMAToonSoulStone"
EMA.COMMAND_READY_CHECK = "EMAReadyCheck"
EMA.COMMAND_TELE_PORT = "EMAteleport"
EMA.COMMAND_LOOT_ROLL = "EMALootRoll"
EMA.COMMAND_WAR_MODE = "EMAWarMode"
EMA.COMMAND_SET_VIEW = "Set View Point"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreateMerchant( top )
	-- Get positions.
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - (horizontalSpacing * 2)) / 3
	local column2left = left + halfWidth
	local left2 = left + thirdWidth
	local left3 = left + (thirdWidth * 2)
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControlMerchant, "", movingTop, false )
	movingTop = movingTop - headingHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControlMerchant, L["VENDOR"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControlMerchant.checkBoxAutoRepair = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlMerchant, 
		headingWidth, 
		left, 
		movingTop, 
		L["AUTO_REPAIR"],
		EMA.SettingsToggleAutoRepair,
		L["AUTO_REPAIR_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlMerchant.checkBoxAutoRepairUseGuildFunds = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlMerchant, 
		headingWidth, 
		left, 
		movingTop, 
		L["REPAIR_GUILD_FUNDS"],
		EMA.SettingsToggleAutoRepairUseGuildFunds,
		L["REPAIR_GUILD_FUNDS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlMerchant.dropdownMerchantArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControlMerchant, 
		headingWidth, 
		left, 
		movingTop, 
		L["MESSAGE_AREA"]
	)
	EMA.settingsControlMerchant.dropdownMerchantArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControlMerchant.dropdownMerchantArea:SetCallback( "OnValueChanged", EMA.SettingsSetMerchantArea )
	movingTop = movingTop - dropdownHeight - verticalSpacing				
	return movingTop	
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControlMerchant.dropdownMerchantArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControlToon.dropdownRequestArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControlWarnings.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:OnCharactersChanged()
	EMA:SettingsRefresh()
end

local function SettingsCreateToon( top )
	-- Get positions.
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local sliderHeight = EMAHelperSettings:GetSliderHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local sectionSpacing = verticalSpacing * 4
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - (horizontalSpacing * 2)) / 3
	local halfWidthSlider = (headingWidth - horizontalSpacing) / 2
	local column2left = left + halfWidth
	local left2 = left + thirdWidth
	local left3 = left + (thirdWidth * 2)
	local movingTop = top
	EMAHelperSettings:CreateHeading( EMA.settingsControlToon, L[""], movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControlToon, L["REQUESTS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControlToon.checkBoxAutoDenyDuels = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left, 
		movingTop, 
		L["DENY_DUELS"],
		EMA.SettingsToggleAutoDenyDuels,
		L["DENY_DUELS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlToon.checkBoxAutoDenyGuildInvites = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left, 
		movingTop, 
		L["DENY_GUILD_INVITES"],
		EMA.SettingsToggleAutoDenyGuildInvites,
		L["DENY_GUILD_INVITES_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlToon.checkBoxAutoAcceptResurrectRequest = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left, 
		movingTop, 
		L["ACCEPT_RESURRECT"],
		EMA.SettingsToggleAutoAcceptResurrectRequests,
		L["ACCEPT_RESURRECT_AUTO"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlToon.checkBoxAutoAcceptResurrectRequestOnlyFromTeam = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left + 20, 
		movingTop, 
		L["ACCEPT_RESURRECT_FROM_TEAM"],
		EMA.SettingsToggleAutoAcceptResurrectRequestsOnlyFromTeam,
		L["ACCEPT_RESURRECT_FROM_TEAM_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlToon.checkBoxAcceptDeathRequests = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left, 
		movingTop, 
		L["RELEASE_PROMPTS"],
		EMA.SettingsToggleAcceptDeathRequests,
		L["RELEASE_PROMPTS_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlToon.checkBoxAutoAcceptSummonRequest = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left, 
		movingTop, 
		L["SUMMON_REQUEST"],
		EMA.SettingsToggleAutoAcceptSummonRequest,
		L["SUMMON_REQUEST_HELP"]
	)
	if EMAPrivate.Core.isEmaClassicBccBuild() == false then
		movingTop = movingTop - checkBoxHeight
		EMA.settingsControlToon.checkBoxToggleWarMode = EMAHelperSettings:CreateCheckBox( 
			EMA.settingsControlToon, 
			halfWidth, 
			left, 
			movingTop, 
			L["WAR_MODE"],
			EMA.SettingsToggleWarMode,
			L["WAR_MODE_HELP"]
		)	
		movingTop = movingTop - checkBoxHeight
		EMA.settingsControlToon.checkBoxTogglePartySyncRequest = EMAHelperSettings:CreateCheckBox( 
			EMA.settingsControlToon, 
			halfWidth, 
			left, 
			movingTop, 
			L["PARTY_SYNC"],
			EMA.SettingsTogglePartySyncRequest,
			L["PARTY_SYNC_HELP"]
		)		
	end
	movingTop = movingTop - checkBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControlToon, L["GROUPTOOLS_HEADING"], movingTop, false )
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlToon.checkBoxAcceptReadyCheck = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left, 
		movingTop,
		L["READY_CHECKS"],
		EMA.SettingsToggleAcceptReadyCheck,
		L["READY_CHECKS_HELP"]
	)
	if EMAPrivate.Core.isEmaClassicBccBuild() == false then
		movingTop = movingTop - headingHeight
		EMA.settingsControlToon.checkBoxAutoRoleCheck = EMAHelperSettings:CreateCheckBox( 
			EMA.settingsControlToon, 
			halfWidth, 
			left, 
			movingTop, 
			L["ROLE_CHECKS"],
			EMA.SettingsToggleAutoRoleCheck,
			L["ROLE_CHECKS_HELP"]
		)
		movingTop = movingTop - checkBoxHeight
		EMA.settingsControlToon.checkBoxLFGTeleport = EMAHelperSettings:CreateCheckBox( 
				EMA.settingsControlToon, 
				halfWidth, 
				left, 
				movingTop,
				L["LFG_Teleport"],
				EMA.SettingsToggleLFGTeleport,
				L["LFG_Teleport_HELP"]
			)
 	end
	movingTop = movingTop - checkBoxHeight
 	EMA.settingsControlToon.checkBoxLootWithTeam = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left, 
		movingTop,
		L["ROLL_LOOT"],
		EMA.SettingsToggleLootWithTeam,
		L["ROLL_LOOT_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControlToon, L["SET_VIEW_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControlToon.checkBoxSetViewWithWithoutMaster = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlToon, 
		halfWidth, 
		left, 
		movingTop,
		L["SET_VIEW_WITHOUT_MASTER"],
		EMA.SettingsToggleSetViewWihoutMaster,
		L["SET_VIEW_WITHOUT_MASTER_HELP"]
	)
	movingTop = movingTop - headingHeight
	EMA.settingsControlToon.SliderSetView = EMAHelperSettings:CreateSlider( 
		EMA.settingsControlToon, 
		halfWidthSlider, 
		left, 
		movingTop, 
		L["SET_VIEW"]
	)
	EMA.settingsControlToon.SliderSetView:SetSliderValues( 1, 5, 1 )
	EMA.settingsControlToon.SliderSetView:SetCallback( "OnValueChanged", EMA.SettingsChangeSetView )
	movingTop = movingTop - sliderHeight - sectionSpacing
	
	--movingTop = movingTop - checkBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControlToon, L["MESSAGES_HEADER"], movingTop, false )
	movingTop = movingTop - dropdownHeight - verticalSpacing
 	EMA.settingsControlToon.dropdownRequestArea = EMAHelperSettings:CreateDropdown( 
	EMA.settingsControlToon, 
		headingWidth, 
		left, 
		movingTop, 
		L["MESSAGE_AREA"]
	)
	EMA.settingsControlToon.dropdownRequestArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControlToon.dropdownRequestArea:SetCallback( "OnValueChanged", EMA.SettingsSetRequestArea )	
	return movingTop	
end

local function SettingsCreateWarnings( top )
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
	EMAHelperSettings:CreateHeading( EMA.settingsControlWarnings, L["COMBAT"], movingTop, true )
	movingTop = movingTop - headingHeight
	EMA.settingsControlWarnings.checkBoxWarnHitFirstTimeCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["WARN_HIT"],
		EMA.SettingsToggleWarnHitFirstTimeCombat,
		L["WARN_HIT_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWarnings.editBoxHitFirstTimeMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["WARN_HIT"]
	)	
	EMA.settingsControlWarnings.editBoxHitFirstTimeMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedHitFirstTimeMessage )

	movingTop = movingTop - editBoxHeight
	EMA.settingsControlWarnings.checkBoxWarnTargetNotMasterEnterCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["TARGET_NOT_MASTER"],
		EMA.SettingsToggleWarnTargetNotMasterEnterCombat,
		L["TARGET_NOT_MASTER_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWarnings.editBoxWarnTargetNotMasterMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["TARGETING"]
	)	
	EMA.settingsControlWarnings.editBoxWarnTargetNotMasterMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnTargetNotMasterMessage )

	movingTop = movingTop - editBoxHeight	
	EMA.settingsControlWarnings.checkBoxWarnFocusNotMasterEnterCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["FOCUS_NOT_MASTER"],
		EMA.SettingsToggleWarnFocusNotMasterEnterCombat,
		L["FOCUS_NOT_MASTER_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWarnings.editBoxWarnFocusNotMasterMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["FOCUS"]
	)	
	EMA.settingsControlWarnings.editBoxWarnFocusNotMasterMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnFocusNotMasterMessage )
	movingTop = movingTop - editBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControlWarnings, L["HEALTH_POWER"], movingTop, true )
	movingTop = movingTop - headingHeight	
	EMA.settingsControlWarnings.checkBoxWarnWhenHealthDropsBelowX = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["HEALTH_DROPS_BELOW"],
		EMA.SettingsToggleWarnWhenHealthDropsBelowX,
		L["HEALTH_DROPS_BELOW_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWarnings.editBoxWarnWhenHealthDropsAmount = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["HEALTH_PERCENTAGE"]
	)	
	EMA.settingsControlWarnings.editBoxWarnWhenHealthDropsAmount:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnWhenHealthDropsAmount )
	movingTop = movingTop - editBoxHeight
	EMA.settingsControlWarnings.editBoxWarnHealthDropsMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["LOW_HEALTH"]
	)	
	EMA.settingsControlWarnings.editBoxWarnHealthDropsMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnHealthDropsMessage )
	movingTop = movingTop - editBoxHeight
	EMA.settingsControlWarnings.checkBoxWarnWhenManaDropsBelowX = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["MANA_DROPS_BELOW"],
		EMA.SettingsToggleWarnWhenManaDropsBelowX,
		L["MANA_DROPS_BELOW_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWarnings.editBoxWarnWhenManaDropsAmount = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["MANA_PERCENTAGE"]
	)	
	EMA.settingsControlWarnings.editBoxWarnWhenManaDropsAmount:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnWhenManaDropsAmount )
	movingTop = movingTop - editBoxHeight
	EMA.settingsControlWarnings.editBoxWarnManaDropsMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["LOW_MANA"]
	)	
	EMA.settingsControlWarnings.editBoxWarnManaDropsMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnManaDropsMessage )
	movingTop = movingTop - editBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControlWarnings, L["OTHER"], movingTop, true )
	movingTop = movingTop - headingHeight	
	EMA.settingsControlWarnings.checkBoxWarnWhenDurabilityDropsBelowX = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["DURABILITY_DROPS_BELOW"],
		EMA.SettingsToggleWarnWhenDurabilityDropsBelowX,
		L["DURABILITY_DROPS_BELOW_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWarnings.editBoxWarnWhenDurabilityDropsAmount = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["DURABILITY_PERCENTAGE"]
	)	
	EMA.settingsControlWarnings.editBoxWarnWhenDurabilityDropsAmount:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnWhenDurabilityDropsAmount )
	movingTop = movingTop - editBoxHeight
	EMA.settingsControlWarnings.editBoxWarnDurabilityDropsMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["LOW_DURABILITY_TEXT"]
	)	
	EMA.settingsControlWarnings.editBoxWarnHealthDropsMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnDurabilityDropsMessage )	
	movingTop = movingTop - editBoxHeight
	EMA.settingsControlWarnings.checkBoxWarnCC = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["WARN_IF_CC"],
		EMA.SettingsToggleWarnCC,
		L["WARN_IF_CC_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWarnings.editBoxCCMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["CCED"]
	)
	EMA.settingsControlWarnings.editBoxCCMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedCCMessage )
	
	movingTop = movingTop - editBoxHeight
    EMA.settingsControlWarnings.checkBoxWarnBagsFull = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["BAGS_FULL"],
		EMA.SettingsToggleWarnBagsFull,
		L["BAGS_FULL_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWarnings.editBoxWarnWhenBagsAlmostFull = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["BAG_SLOTS_HELP"]
	)
	EMA.settingsControlWarnings.editBoxWarnWhenBagsAlmostFull:SetCallback( "OnEnterPressed", EMA.EditBoxChangedWarnWhenBagsAlmostFull )
	movingTop = movingTop - editBoxHeight
	EMA.settingsControlWarnings.editBoxBagsFullMessage = EMAHelperSettings:CreateEditBox( EMA.settingsControlWarnings,
		headingWidth,
		left,
		movingTop,
		L["BAGS_FULL"]
	)	
	EMA.settingsControlWarnings.editBoxBagsFullMessage:SetCallback( "OnEnterPressed", EMA.EditBoxChangedBagsFullMessage )
	movingTop = movingTop - editBoxHeight
	
	
	movingTop = movingTop - editBoxHeight	
	EMA.settingsControlWarnings.dropdownWarningArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControlWarnings, 
		headingWidth, 
		left, 
		movingTop, 
		L["SEND_WARNING_AREA"] 
	)
	EMA.settingsControlWarnings.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControlWarnings.dropdownWarningArea:SetCallback( "OnValueChanged", EMA.SettingsSetWarningArea )
	movingTop = movingTop - dropdownHeight - verticalSpacing		
	return movingTop	
end

local function SettingsCreate()
	EMA.settingsControlToon = {}
	EMA.settingsControlWarnings = {}
	EMA.settingsControlMerchant = {}
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControlToon,
		EMA.moduleDisplayName, 
		EMA.parentDisplayNameToon, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder
	)
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControlWarnings,
		L["WARNINGS"],
		EMA.parentDisplayNameToon, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIconWarnings,
		EMA.moduleWarningsOrder
		
	)
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControlMerchant, 
		L["REPAIR"], 
		EMA.parentDisplayNameMerchant, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIconRepair,
		EMA.moduleRepairOrder	
	)
	local bottomOfToon = SettingsCreateToon( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControlToon.widgetSettings.content:SetHeight( -bottomOfToon )
	local bottomOfWarnings = SettingsCreateWarnings( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControlWarnings.widgetSettings.content:SetHeight( -bottomOfWarnings)
	local bottomOfMerchant = SettingsCreateMerchant( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControlMerchant.widgetSettings.content:SetHeight( -bottomOfMerchant )	
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControlWarnings, helpTable, EMA:GetConfiguration() )		
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
	EMA.settingsControlWarnings.checkBoxWarnHitFirstTimeCombat:SetValue( EMA.db.warnHitFirstTimeCombat )
	EMA.settingsControlWarnings.editBoxHitFirstTimeMessage:SetText( EMA.db.hitFirstTimeMessage )
	EMA.settingsControlWarnings.checkBoxWarnTargetNotMasterEnterCombat:SetValue( EMA.db.warnTargetNotMasterEnterCombat )
	EMA.settingsControlWarnings.editBoxWarnTargetNotMasterMessage:SetText( EMA.db.warnTargetNotMasterMessage )
	EMA.settingsControlWarnings.checkBoxWarnFocusNotMasterEnterCombat:SetValue( EMA.db.warnFocusNotMasterEnterCombat )
	EMA.settingsControlWarnings.editBoxWarnFocusNotMasterMessage:SetText( EMA.db.warnFocusNotMasterMessage )
	EMA.settingsControlWarnings.checkBoxWarnWhenHealthDropsBelowX:SetValue( EMA.db.warnWhenHealthDropsBelowX )
	EMA.settingsControlWarnings.editBoxWarnWhenHealthDropsAmount:SetText( EMA.db.warnWhenHealthDropsAmount )
	EMA.settingsControlWarnings.editBoxWarnHealthDropsMessage:SetText( EMA.db.warnHealthDropsMessage )
	EMA.settingsControlWarnings.checkBoxWarnWhenManaDropsBelowX:SetValue( EMA.db.warnWhenManaDropsBelowX )
	EMA.settingsControlWarnings.editBoxWarnWhenManaDropsAmount:SetText( EMA.db.warnWhenManaDropsAmount )
	EMA.settingsControlWarnings.editBoxWarnManaDropsMessage:SetText( EMA.db.warnManaDropsMessage )		
	EMA.settingsControlWarnings.checkBoxWarnWhenDurabilityDropsBelowX:SetValue( EMA.db.warnWhenDurabilityDropsBelowX )
	EMA.settingsControlWarnings.editBoxWarnWhenDurabilityDropsAmount:SetText( EMA.db.warnWhenDurabilityDropsAmount )
	EMA.settingsControlWarnings.editBoxWarnDurabilityDropsMessage:SetText( EMA.db.warnDurabilityDropsMessage )	
	EMA.settingsControlWarnings.editBoxWarnWhenBagsAlmostFull:SetText( EMA.db.warnWhenBagsAlmostFullAmount )
	EMA.settingsControlWarnings.checkBoxWarnBagsFull:SetValue( EMA.db.warnBagsFull )
	EMA.settingsControlWarnings.editBoxBagsFullMessage:SetText( EMA.db.bagsFullMessage )
	EMA.settingsControlWarnings.checkBoxWarnCC:SetValue( EMA.db.warnCC )
	EMA.settingsControlWarnings.editBoxCCMessage:SetText( EMA.db.CcMessage ) 
	EMA.settingsControlWarnings.dropdownWarningArea:SetValue( EMA.db.warningArea )
	EMA.settingsControlToon.checkBoxAutoAcceptResurrectRequest:SetValue( EMA.db.autoAcceptResurrectRequest )
	EMA.settingsControlToon.checkBoxAutoAcceptResurrectRequestOnlyFromTeam:SetValue( EMA.db.autoAcceptResurrectRequestOnlyFromTeam )
	EMA.settingsControlToon.checkBoxAcceptDeathRequests:SetValue( EMA.db.acceptDeathRequests )
	EMA.settingsControlToon.checkBoxAutoDenyDuels:SetValue( EMA.db.autoDenyDuels )
	EMA.settingsControlToon.checkBoxAutoAcceptSummonRequest:SetValue( EMA.db.autoAcceptSummonRequest )
	EMA.settingsControlToon.checkBoxAutoDenyGuildInvites:SetValue( EMA.db.autoDenyGuildInvites )
	EMA.settingsControlToon.checkBoxAcceptReadyCheck:SetValue( EMA.db.acceptReadyCheck )
	EMA.settingsControlToon.checkBoxLootWithTeam:SetValue( EMA.db.rollWithTeam )
	if EMAPrivate.Core.isEmaClassicBccBuild() == false then
		EMA.settingsControlToon.checkBoxToggleWarMode:SetValue( EMA.db.toggleWarMode )
		EMA.settingsControlToon.checkBoxLFGTeleport:SetValue( EMA.db.teleportLFGWithTeam )
		EMA.settingsControlToon.checkBoxAutoRoleCheck:SetValue( EMA.db.autoAcceptRoleCheck )
		EMA.settingsControlToon.checkBoxTogglePartySyncRequest:SetValue( EMA.db.autoAcceptPartySyncRequest )
	end
	EMA.settingsControlToon.dropdownRequestArea:SetValue( EMA.db.requestArea )
	EMA.settingsControlToon.checkBoxSetViewWithWithoutMaster:SetValue( EMA.db.setViewWithoutMaster )
	EMA.settingsControlToon.SliderSetView:SetValue( EMA.db.setView )
	
	EMA.settingsControlMerchant.checkBoxAutoRepair:SetValue( EMA.db.autoRepair )
	EMA.settingsControlMerchant.checkBoxAutoRepairUseGuildFunds:SetValue( EMA.db.autoRepairUseGuildFunds )
	EMA.settingsControlMerchant.dropdownMerchantArea:SetValue( EMA.db.merchantArea )
	-- Set state.
	EMA.settingsControlWarnings.editBoxHitFirstTimeMessage:SetDisabled( not EMA.db.warnHitFirstTimeCombat )
	EMA.settingsControlWarnings.editBoxWarnTargetNotMasterMessage:SetDisabled( not EMA.db.warnTargetNotMasterEnterCombat )
	EMA.settingsControlWarnings.editBoxWarnFocusNotMasterMessage:SetDisabled( not EMA.db.warnFocusNotMasterEnterCombat )
	EMA.settingsControlWarnings.editBoxWarnWhenHealthDropsAmount:SetDisabled( not EMA.db.warnWhenHealthDropsBelowX )
	EMA.settingsControlWarnings.editBoxWarnHealthDropsMessage:SetDisabled( not EMA.db.warnWhenHealthDropsBelowX )
	EMA.settingsControlWarnings.editBoxWarnWhenManaDropsAmount:SetDisabled( not EMA.db.warnWhenManaDropsBelowX )
	EMA.settingsControlWarnings.editBoxWarnManaDropsMessage:SetDisabled( not EMA.db.warnWhenManaDropsBelowX )
	EMA.settingsControlWarnings.editBoxWarnWhenDurabilityDropsAmount:SetDisabled( not EMA.db.warnWhenDurabilityDropsBelowX )
	EMA.settingsControlWarnings.editBoxWarnDurabilityDropsMessage:SetDisabled( not EMA.db.warnWhenDurabilityDropsBelowX )	
	EMA.settingsControlWarnings.editBoxWarnWhenBagsAlmostFull:SetDisabled( not EMA.db.warnWhenBagsAlmostFullAmount )
	EMA.settingsControlMerchant.checkBoxAutoRepairUseGuildFunds:SetDisabled( not EMA.db.autoRepair )
	EMA.settingsControlWarnings.editBoxBagsFullMessage:SetDisabled( not EMA.db.warnBagsFull )
	EMA.settingsControlWarnings.editBoxCCMessage:SetDisabled( not EMA.db.warnCC )
	EMA.settingsControlToon.checkBoxAutoAcceptResurrectRequestOnlyFromTeam:SetDisabled( not EMA.db.autoAcceptResurrectRequest )
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleAutoRepair( event, checked )
	EMA.db.autoRepair = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoRepairUseGuildFunds( event, checked )
	EMA.db.autoRepairUseGuildFunds = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoDenyDuels( event, checked )
	EMA.db.autoDenyDuels = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoAcceptSummonRequest( event, checked )
	EMA.db.autoAcceptSummonRequest = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoDenyGuildInvites( event, checked )
	EMA.db.autoDenyGuildInvites = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoAcceptResurrectRequests( event, checked )
	EMA.db.autoAcceptResurrectRequest = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoAcceptResurrectRequestsOnlyFromTeam( event, checked )
	EMA.db.autoAcceptResurrectRequestOnlyFromTeam = checked
	EMA:SettingsRefresh()
end


function EMA:SettingsToggleAcceptDeathRequests( event, checked )
	EMA.db.acceptDeathRequests = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoRoleCheck( event, checked )
	EMA.db.autoAcceptRoleCheck = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAcceptReadyCheck( event, checked )
	EMA.db.acceptReadyCheck = checked 	
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleLFGTeleport( event, checked )
	EMA.db.teleportLFGWithTeam = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleLootWithTeam( event, checked )
	EMA.db.rollWithTeam = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarMode(event, checked )
	EMA.db.toggleWarMode = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsTogglePartySyncRequest(event, checked )
	EMA.db.autoAcceptPartySyncRequest = checked
	EMA:SettingsRefresh()
end	

-- Warnings Toggles

function EMA:SettingsToggleWarnHitFirstTimeCombat( event, checked )
	EMA.db.warnHitFirstTimeCombat = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedHitFirstTimeMessage( event, text )
	EMA.db.hitFirstTimeMessage = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnBagsFull( event, checked )
	EMA.db.warnBagsFull = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedBagsFullMessage( event, text )
	EMA.db.bagsFullMessage = text
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnWhenBagsAlmostFull( event, text )
	local amount = tonumber( text )
	amount = EMAUtilities:FixValueToRange( amount, 0, 100 )
	EMA.db.warnWhenBagsAlmostFullAmount = amount
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnCC( event, checked )
	EMA.db.warnCC = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedCCMessage( event, text )
	EMA.db.CcMessage = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnTargetNotMasterEnterCombat( event, checked )
	EMA.db.warnTargetNotMasterEnterCombat = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnTargetNotMasterMessage( event, text )
	EMA.db.warnTargetNotMasterMessage = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnFocusNotMasterEnterCombat( event, checked )
	EMA.db.warnFocusNotMasterEnterCombat = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnFocusNotMasterMessage( event, text )
	EMA.db.warnFocusNotMasterMessage = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnWhenHealthDropsBelowX( event, checked )
	EMA.db.warnWhenHealthDropsBelowX = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnWhenHealthDropsAmount( event, text )
	local amount = tonumber( text )
	amount = EMAUtilities:FixValueToRange( amount, 0, 100 )
	EMA.db.warnWhenHealthDropsAmount = tostring( amount )
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnHealthDropsMessage( event, text )
	EMA.db.warnHealthDropsMessage = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnWhenManaDropsBelowX( event, checked )
	EMA.db.warnWhenManaDropsBelowX = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnWhenManaDropsAmount( event, text )
	local amount = tonumber( text )
	amount = EMAUtilities:FixValueToRange( amount, 0, 100 )
	EMA.db.warnWhenManaDropsAmount = tostring( amount )
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnManaDropsMessage( event, text )
	EMA.db.warnManaDropsMessage = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleWarnWhenDurabilityDropsBelowX( event, checked )
	EMA.db.warnWhenDurabilityDropsBelowX = checked
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnWhenDurabilityDropsAmount( event, text )
	local amount = tonumber( text )
	amount = EMAUtilities:FixValueToRange( amount, 0, 100 )
	EMA.db.warnWhenDurabilityDropsAmount = tostring( amount )
	EMA:SettingsRefresh()
end

function EMA:EditBoxChangedWarnDurabilityDropsMessage( event, text )
	EMA.db.warnDurabilityDropsMessage = text
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleSetViewWihoutMaster( event, value )
	EMA.db.setViewWithoutMaster = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSetView( event, value )
	EMA.db.setView = tonumber( value )
	EMA:SettingsRefresh()
end	

function EMA:SettingsSetWarningArea( event, value )
	EMA.db.warningArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsSetRequestArea( event, value )
	EMA.db.requestArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsSetMerchantArea( event, value )
	EMA.db.merchantArea = value
	EMA:SettingsRefresh()
end


-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControlWarnings.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()
	-- Flag set when told the master about health falling below a certain percentage.
	EMA.toldMasterAboutHealth = false
	-- Flag set when told the master about mana falling below a certain percentage.
	EMA.toldMasterAboutMana = false
	-- Flag Set when told master About Durability
	EMA.toldMasterAboutDurability = false
	-- Have been hit flag.
	EMA.haveBeenHit = false
	-- Bags full changed count.
	EMA.previousFreeBagSlotsCount = false
	-- Key bindings.
	EMASETVIEW = CreateFrame( "CheckButton", "EMASETVIEW", nil, "SecureActionButtonTemplate" )
	EMASETVIEW:SetAttribute( "type", "macro" )
	EMASETVIEW:SetAttribute( "macrotext", "/ema-toon setview" )
	EMASETVIEW:Hide()	
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA.isInternalCommand = false
	-- WoW events.
	EMA:RegisterEvent( "UNIT_COMBAT" )
	EMA:RegisterEvent( "PLAYER_REGEN_DISABLED" )
	EMA:RegisterEvent( "PLAYER_REGEN_ENABLED" )
	EMA:RegisterEvent( "UNIT_HEALTH" )
	EMA:RegisterEvent( "UPDATE_INVENTORY_DURABILITY" )
	EMA:RegisterEvent( "UNIT_POWER_FREQUENT" )	
	EMA:RegisterEvent( "MERCHANT_SHOW" )
	EMA:RegisterEvent( "RESURRECT_REQUEST" )
	EMA:RegisterEvent( "PLAYER_DEAD" )
	EMA:RegisterEvent( "CORPSE_IN_RANGE" )
	EMA:RegisterEvent( "CORPSE_IN_INSTANCE" )
	EMA:RegisterEvent( "CORPSE_OUT_OF_RANGE" )	
	EMA:RegisterEvent( "PLAYER_UNGHOST" )
	EMA:RegisterEvent( "PLAYER_ALIVE" )
	EMA:RegisterEvent( "CONFIRM_SUMMON")
	EMA:RegisterEvent( "DUEL_REQUESTED" )
	EMA:RegisterEvent( "GUILD_INVITE_REQUEST" )
	EMA:RegisterEvent( "LFG_ROLE_CHECK_SHOW" )
	EMA:RegisterEvent( "READY_CHECK" )
	EMA:RegisterEvent("LOSS_OF_CONTROL_ADDED")
	EMA:RegisterEvent( "UI_ERROR_MESSAGE", "BAGS_FULL" )
	EMA:RegisterEvent( "BAG_UPDATE_DELAYED" )
	EMA:RegisterEvent( "PLAYER_FLAGS_CHANGED", "WARMODE" )
	EMA:RegisterEvent( "QUEST_SESSION_CREATED" )
	-- Initialise key bindings.
	EMA.keyBindingFrame = CreateFrame( "Frame", nil, UIParent )
	EMA:RegisterEvent( "UPDATE_BINDINGS" )
	EMA:UPDATE_BINDINGS()
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	EMA:RegisterMessage( EMAApi.MESSAGE_CHARACTER_ONLINE, "OnCharactersChanged" )
	EMA:RegisterMessage( EMAApi.MESSAGE_CHARACTER_OFFLINE, "OnCharactersChanged" )
	-- Ace Hooks
	EMA:SecureHook( "ConfirmReadyCheck" )
	if EMAPrivate.Core.isEmaClassicBuild == false then
		EMA:SecureHook( "LFGTeleport" )
	end
	EMA:SecureHook( "RollOnLoot" )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.warnHitFirstTimeCombat = settings.warnHitFirstTimeCombat
		EMA.db.hitFirstTimeMessage = settings.hitFirstTimeMessage
		EMA.db.warnTargetNotMasterEnterCombat = settings.warnTargetNotMasterEnterCombat
		EMA.db.warnTargetNotMasterMessage = settings.warnTargetNotMasterMessage
		EMA.db.warnFocusNotMasterEnterCombat = settings.warnFocusNotMasterEnterCombat
		EMA.db.warnFocusNotMasterMessage = settings.warnFocusNotMasterMessage
		EMA.db.warnWhenHealthDropsBelowX = settings.warnWhenHealthDropsBelowX
		EMA.db.warnWhenHealthDropsAmount = settings.warnWhenHealthDropsAmount
		EMA.db.warnHealthDropsMessage = settings.warnHealthDropsMessage
		EMA.db.warnWhenManaDropsBelowX = settings.warnWhenManaDropsBelowX
		EMA.db.warnWhenManaDropsAmount = settings.warnWhenManaDropsAmount
		EMA.db.warnManaDropsMessage = settings.warnManaDropsMessage
		EMA.db.warnWhenDurabilityDropsBelowX = settings.warnWhenDurabilityDropsBelowX
		EMA.db.warnWhenDurabilityDropsAmount = settings.warnWhenDurabilityDropsAmount
		EMA.db.warnDurabilityDropsMessage = settings.warnDurabilityDropsMessage		
		EMA.db.warnBagsFull = settings.warnBagsFull
		EMA.db.bagsFullMessage = settings.bagsFullMessage
		EMA.db.bagsAlmostFullMessage = settings.bagsAlmostFullMessage
		EMA.db.warnCC = settings.warnCC
		EMA.db.CcMessage = settings.CcMessage			
		EMA.db.autoAcceptResurrectRequest = settings.autoAcceptResurrectRequest
		EMA.db.autoAcceptResurrectRequestOnlyFromTeam = settings.autoAcceptResurrectRequestOnlyFromTeam
		EMA.db.acceptDeathRequests = settings.acceptDeathRequests
		EMA.db.autoDenyDuels = settings.autoDenyDuels
		EMA.db.autoAcceptSummonRequest = settings.autoAcceptSummonRequest
		EMA.db.autoDenyGuildInvites = settings.autoDenyGuildInvites
		EMA.db.autoAcceptRoleCheck = settings.autoAcceptRoleCheck
		EMA.db.enterLFGWithTeam = settings.enterLFGWithTeam
		EMA.db.acceptReadyCheck = settings.acceptReadyCheck
		EMA.db.teleportLFGWithTeam = settings.teleportLFGWithTeam
		EMA.db.rollWithTeam = settings.rollWithTeam
		EMA.db.toggleWarMode = settings.toggleWarMode
		EMA.db.setView = settings.setView
		EMA.db.setViewWithoutMaster = settings.setViewWithoutMaster
		EMA.db.autoAcceptPartySyncRequest = settings.autoAcceptPartySyncRequest
		EMA.db.autoRepair = settings.autoRepair
		EMA.db.autoRepairUseGuildFunds = settings.autoRepairUseGuildFunds
		EMA.db.warningArea = settings.warningArea
		EMA.db.requestArea = settings.requestArea
		EMA.db.merchantArea = settings.merchantArea
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

function EMA:UNIT_COMBAT( event, unitAffected, action )
	if EMA.db.warnHitFirstTimeCombat == false then
		return
	end
	if EMAApi.IsCharacterTheMaster( self.characterName ) == true then
		return
	end
	if InCombatLockdown() then
		if unitAffected == "player" and action ~= "HEAL" and not EMA.haveBeenHit then
			EMA.haveBeenHit = true
			EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.hitFirstTimeMessage, false )
		end
	end
end

function EMA:GUILD_INVITE_REQUEST( event, inviter, guild, ... )
	if EMA.db.autoDenyGuildInvites == true then
		DeclineGuild()
		GuildInviteFrame:Hide()
		EMA:EMASendMessageToTeam( EMA.db.requestArea, L["REFUSED_GUILD_INVITE"]( guild, inviter ), false )
	end
end

function EMA:DUEL_REQUESTED( event, challenger, ... )
	if EMA.db.autoDenyDuels == true then
		CancelDuel()
		StaticPopup_Hide( "DUEL_REQUESTED" )
		EMA:EMASendMessageToTeam( EMA.db.requestArea, L["I_REFUSED_A_DUEL_FROM_X"]( challenger ), false )
	end
end

function EMA:PLAYER_UNGHOST(event, ...)
		StaticPopup_Hide( "RECOVER_CORPSE" )
		StaticPopup_Hide( "RECOVER_CORPSE_INSTANCE" )
		StaticPopup_Hide( "XP_LOSS" )
		StaticPopup_Hide( "RECOVER_TEAM")
		StaticPopup_Hide(  "TEAMDEATH" )
end

function EMA:PLAYER_ALIVE(event, ...)
		StaticPopup_Hide( "RECOVER_CORPSE" )
		StaticPopup_Hide( "RECOVER_CORPSE_INSTANCE" )
		StaticPopup_Hide( "XP_LOSS" )
		StaticPopup_Hide( "RECOVER_TEAM" )
		StaticPopup_Hide( "TEAMDEATH" )
end

function EMA:CORPSE_IN_RANGE(event, ...)
	local teamMembers = EMAApi.GetTeamListMaximumOrderOnline()
	if teamMembers > 1 and EMA.db.acceptDeathRequests == true then
		StaticPopup_Show("RECOVER_TEAM")
	end		
end	
	
function EMA:CORPSE_IN_INSTANCE(event, ...)
		StaticPopup_Show("RECOVER_CORPSE_INSTANCE")
		StaticPopup_Hide("RECOVER_TEAM")
end
		
function EMA:CORPSE_OUT_OF_RANGE(event, ...)
		StaticPopup_Hide("RECOVER_CORPSE")
		StaticPopup_Hide("RECOVER_CORPSE_INSTANCE")
		StaticPopup_Hide("XP_LOSS")
		StaticPopup_Hide("RECOVER_TEAM")
end

function EMA:PLAYER_DEAD( event, ...)
	-- EMA Team Stuff.
	local teamMembers = EMAApi.GetTeamListMaximumOrderOnline()
	if teamMembers > 1 and EMA.db.acceptDeathRequests == true then
		StaticPopup_Show( "TEAMDEATH" )	
	end
end

-- Mosty taken from blizzard StaticPopup Code
-- 8.0 changes self Res to much to beable to work like we want it to
-- Not sure if we can do this anymore? maybe just remove it for now
StaticPopupDialogs["TEAMDEATH"] = {
	text = L["RELEASE_TEAM_Q"],
	button1 = DEATH_RELEASE,
	--button2 = USE_SOULSTONE,
	button2 = CANCEL,
	OnShow = function(self)
		--self.timeleft = GetReleaseTimeRemaining()
		--[[
		-- TODO FIX FOR 8.0
		if EMAPrivate.Core.isBetaBuild == true then
			-- Find out new code????? for now we can not use this
			local text = nil
		else 
			local text = HasSoulstone()
		end
		if ( text ) then
			self.button2:SetText(text)
		end
		if ( self.timeleft == -1 ) then
			self.text:SetText(DEATH_RELEASE_NOTIMER)
		end
		--]]
		self.button1:SetText(L["RELEASE_TEAM"])
	end,
	OnAccept = function(self)
		--EMA:Print("testRes")
		-- Do we need this???
		--if not ( CannotBeResurrected() ) then
		--	return 1
		--end
		
		EMA.teamDeath()
	end,
	OnCancel = function(self, data, reason)
		--[[
		if ( reason == "override" ) then
			return;
		end
		if ( reason == "timeout" ) then
			return;
		end
		if ( reason == "clicked" ) then
			if ( HasSoulstone() ) then
				EMA.teamSS()
			else
				EMA.teamRes()
			end
			if ( CannotBeResurrected() ) then
				return 1
			end
		end
		]]
	end,
	OnUpdate = function(self, elapsed)
		if ( IsFalling() and not IsOutOfBounds()) then
			self.button1:Disable()
			self.button2:Disable()
			--self.button3:Disable()
			return;
		end
		
		local b1_enabled = self.button1:IsEnabled()
		self.button1:SetEnabled(not IsEncounterInProgress())
		
		if ( b1_enabled ~= self.button1:IsEnabled() ) then
			if ( b1_enabled ) then
				self.text:SetText(CAN_NOT_RELEASE_IN_COMBAT)
			else
				self.text:SetText("");
				StaticPopupDialogs[self.which].OnShow(self)
			end
			StaticPopup_Resize(dialog, which)
		end
		--[[
		if( HasSoulstone() and CanUseSoulstone() ) then
			self.button2:Enable()
		else
			self.button2:Disable()
		end
		--]]
	end,
	--[[
	DisplayButton2 = function(self)
		return HasSoulstone()
	end,
	]]
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1,
	cancels = "RECOVER_TEAM"
}

StaticPopupDialogs["RECOVER_TEAM"] = {
	text = L["RECOVER_CORPSES"],
	button1 = ACCEPT,
	OnAccept = function(self)
		EMA:relaseTeam();
		return 1;
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};

function EMA:relaseTeam()
	EMA:EMASendCommandToTeam( EMA.COMMAND_RECOVER_TEAM )
end

function EMA:teamDeath()
	
	EMA:EMASendCommandToTeam( EMA.COMMAND_TEAM_DEATH )
end

--Remove
function EMA:teamSS()
	EMA:EMASendCommandToTeam( EMA.COMMAND_SOUL_STONE )
	--UseSoulstone()
end

function EMA:doRecoverTeam()
	RetrieveCorpse()
	if UnitIsGhost("player") then
		local delay = GetCorpseRecoveryDelay()	  
		if delay > 0 then
			EMA:EMASendMessageToTeam( EMA.db.requestArea, L["RELEASE_CORPSE_FOR_X"]( delay ), false )
			StaticPopup_Show("RECOVER_TEAM")
		else	
			RetrieveCorpse()
			StaticPopup_Hide("RECOVER_TEAM")
		end		
	end
end
			
function EMA:doTeamDeath()
	if UnitIsDead("player") and not UnitIsGhost("player") then
		RepopMe()
		StaticPopup_Hide("TEAMDEATH")
	end
end

--CleanUP
function EMA:doSoulStone()
	if UnitIsDead("player") and not UnitIsGhost("player") then
		-- Dead code do not use!
		--[[
		if HasSoulstone() then
			UseSoulstone()
			StaticPopup_Hide("TEAMDEATH")
		else
			EMA:EMASendMessageToTeam( EMA.db.warningArea, L["I Do not have a SoulStone"], false )
		end	
		]]
	end
end

function EMA:RESURRECT_REQUEST( event, name, ... )
	--EMA:Print("test Res From", name)
	local canResurrect = false 
	if EMA.db.autoAcceptResurrectRequest == true then
		--EMA:Print("test Res From", name)
		canResurrect = true
	end	
	if EMA.db.autoAcceptResurrectRequestOnlyFromTeam == true then
		for index, characterName in EMAApi.TeamListOrderedOnline() do
			unit = Ambiguate( characterName, "none" )
			--EMA:Print("test", name, "vs", unit )
			if unit == name then
				canResurrect = true
				break
			else
				canResurrect = false
			end
		end
	end
	if canResurrect == true then 	
		AcceptResurrect()
		StaticPopup_Hide( "RESURRECT")
		StaticPopup_Hide( "RESURRECT_NO_SICKNESS" )
		StaticPopup_Hide( "RESURRECT_NO_TIMER" )
		StaticPopup_Hide( "SKINNED" )
		StaticPopup_Hide( "SKINNED_REPOP" )
		StaticPopup_Hide( "DEATH" )
		StaticPopup_Hide( "RECOVER_TEAM" )
		StaticPopup_Hide( "TEAMDEATH" )
	end
end

--LFG stuff

function EMA:READY_CHECK( event, name, ... )
	-- Auto do Ready Check if team member is the one that does the readycheck
	if EMA.db.acceptReadyCheck == true then
		--EMA:Print("readyCheck", name )
		for index, characterName in EMAApi.TeamListOrderedOnline() do
			if name == Ambiguate( characterName, "none") then
				EMA.isInternalCommand = ture
				--EMA:Print("found in team", characterName)
				if ReadyCheckFrame:IsShown() == true then
					--EMA:Print("Ok?")
					ConfirmReadyCheck(1)
					ReadyCheckFrame:Hide()
				end	
				EMA.isInternalCommand = false
			end	
		end	
	end	
end

function EMA:ConfirmReadyCheck( ready )
	--EMA:Print("Test", ready )
	if EMA.db.acceptReadyCheck == true then	
		if EMA.isInternalCommand == false then
			EMA:EMASendCommandToTeam( EMA.COMMAND_READY_CHECK, ready)
		end	
	end		
end

function EMA:AmReadyCheck( ready )
	--EMA:Print("AmReady!", ready )
	EMA.isInternalCommand = true
		if ready == 1 then
			ConfirmReadyCheck(1)
			ReadyCheckFrame:Hide()
		else
			ConfirmReadyCheck()
			ReadyCheckFrame:Hide()
		end	
	EMA.isInternalCommand = false
end

function EMA:LFGTeleport( event, arg1, ... )
	--EMA:Print("LFGtest")
	if EMA.db.teleportLFGWithTeam == true and EMAPrivate.Core.isEmaClassicBuild() == false then
		if IsShiftKeyDown() == false then
			if EMA.isInternalCommand == false then
				if IsInLFGDungeon() == true then
					EMA:EMASendCommandToTeam( EMA.COMMAND_TELE_PORT, true )
				else
					EMA:EMASendCommandToTeam( EMA.COMMAND_TELE_PORT, false )	
				end	
			end	
		end	
	end		
end

function EMA:DoLFGTeleport(port)
	if EMAPrivate.Core.isEmaClassicBuild() == ture then return end	
	--EMA:Print("TeleCommand", port)
	EMA.isInternalCommand = true
	if IsShiftKeyDown() == false then
		if port == true then
			LFGTeleport(1)
		else
			LFGTeleport()
		end
	end		
	EMA.isInternalCommand = false
end

function EMA:LFG_ROLE_CHECK_SHOW( event, ... )
	if EMA.db.autoAcceptRoleCheck == true then	
		--EMA:Print("testPopup?")
		CompleteLFGRoleCheck("ture")
	end	
end

function EMA:RollOnLoot(id, rollType, ...)
	--EMA:Print("lootTest", id, rollType)
	local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo( id )
	--EMA:Print("lootItemTest", name)
	if EMA.db.rollWithTeam == true then
		if IsShiftKeyDown() == false then
			if EMA.isInternalCommand == false then
				EMA:EMASendCommandToTeam( EMA.COMMAND_LOOT_ROLL, id, rollType, name)
			end
		end		
	end
end

function EMA:DoLootRoll( id, rollType, name )
	--EMA:Print("i have a command to roll on item", name)
	EMA.isInternalCommand = true
	if name ~= nil then
		RollOnLoot(id, rollType)
	end	
	EMA.isInternalCommand = false
end

function EMA:CONFIRM_SUMMON( event, sender, location, ... )
	local sender, location = C_SummonInfo.GetSummonConfirmSummoner(), C_SummonInfo.GetSummonConfirmAreaName()
	if EMA.db.autoAcceptSummonRequest == true then
		if C_SummonInfo.GetSummonConfirmTimeLeft() > 0 then
		C_SummonInfo.ConfirmSummon()
		StaticPopup_Hide("CONFIRM_SUMMON")
		EMA:EMASendMessageToTeam( EMA.db.requestArea, L["SUMMON_FROM_X_TO_Y"]( sender, location ), false )
		end
	end
end

function EMA:WARMODE(event, ...)
	if EMA.db.toggleWarMode == true and EMAPrivate.Core.isEmaClassicBuild() == false then
		if C_PvP.IsWarModeFeatureEnabled() == true then
			local isWarMode = C_PvP.IsWarModeDesired()
			if C_PvP.CanToggleWarMode(isWarMode) == true then
				if EMA.isInternalCommand == false then	
					--EMA:Print("SendWarMode", isWarMode, EMA.isInternalCommand )
					EMA:EMASendCommandToTeam( EMA.COMMAND_WAR_MODE, isWarMode )
				end	
			end	
		end
	end	
end

function EMA:DoWarMode( isWarMode )
	if EMAPrivate.Core.isEmaClassicBuild() == ture then return end
	EMA.isInternalCommand = true
	if C_PvP.CanToggleWarMode( isWarMode ) == true and isWarMode ~= nil then
		--EMA:Print("testwarmode", isWarMode )
		C_PvP.SetWarModeDesired( isWarMode )
	end
	EMA.isInternalCommand = false
end	

function EMA:MERCHANT_SHOW( event, ... )	
	-- Does the user want to auto repair?
	if EMA.db.autoRepair == false then
		return
	end	
	-- Can this merchant repair?
	if not CanMerchantRepair() then
		return
	end		
	-- How much to repair?
	local repairCost, canRepair = GetRepairAllCost()
	if canRepair == nil then
		return
	end
	-- At least some cost...
	if repairCost > 0 then
		-- If allowed to use guild funds, then attempt to repair using guild funds.
-- TODO GUILD BANK STUFF FOR CLASSIC or TBC CLASSIC 
		if EMA.db.autoRepairUseGuildFunds == true then
			if IsInGuild() and CanGuildBankRepair() then
				RepairAllItems( 1 )
			end
		end
		-- After guild funds used, still need to repair?
		repairCost = GetRepairAllCost()
		-- At least some cost...
		if repairCost > 0 then
			-- How much money available?
			local moneyAvailable = GetMoney()
			-- More or equal money than cost?
			if moneyAvailable >= repairCost then
				-- Yes, repair.
				RepairAllItems()
			else
				-- Nope, tell the boss.
				 EMA:EMASendMessageToTeam( EMA.db.merchantArea, L["ERR_GOLD_TO_REPAIR"], false )
			end
		end
	end
	if repairCost > 0 then
		-- Tell the boss how much that cost.
		local costString = GetCoinTextureString( repairCost )
		EMA:EMASendMessageToTeam( EMA.db.merchantArea, L["REPAIRING_COST_ME_X"]( costString ), false )
	end
end

function EMA:UNIT_POWER_FREQUENT( event, unitAffected, power, ... )
	if EMA.db.warnWhenManaDropsBelowX == false then
		return
	end
	if unitAffected ~= "player" then
		return
	end
	if power ~= "MANA" then
		return
	end			
	local currentMana = (UnitPower( "player", 0 ) / UnitPowerMax( "player", 0 ) * 100)
	if EMA.toldMasterAboutMana == true then
		if currentMana >= tonumber( EMA.db.warnWhenManaDropsAmount ) then
			EMA.toldMasterAboutMana = false
		end
	else
		if currentMana < tonumber( EMA.db.warnWhenManaDropsAmount ) then
			EMA.toldMasterAboutMana = true
			EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.warnManaDropsMessage, false )
		end
	end
end

function EMA:UNIT_HEALTH( event, unitAffected, ... )
	if EMA.db.warnWhenHealthDropsBelowX == false then
		return
	end	
	if unitAffected ~= "player" then
		return
	end
	local currentHealth = (UnitHealth( "player" ) / UnitHealthMax( "player" ) * 100)
	if EMA.toldMasterAboutHealth == true then
		if currentHealth >= tonumber( EMA.db.warnWhenHealthDropsAmount ) then
			EMA.toldMasterAboutHealth = false
		end
	else
		if currentHealth < tonumber( EMA.db.warnWhenHealthDropsAmount ) then
			EMA.toldMasterAboutHealth = true
			EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.warnHealthDropsMessage, false )
		end
	end
end

function EMA:UPDATE_INVENTORY_DURABILITY(event, agr1)
	--EMA:Print("test")
	if EMA.db.warnWhenDurabilityDropsBelowX == false then
		return
	end
	--EMA:Print("Test Durability Fired")
	local curTotal, maxTotal, broken = 0, 0, 0
	local durability = 100
	for i = 1, 17 do
		local curItemDurability, maxItemDurability = GetInventoryItemDurability(i)
		if (curItemDurability ~= nil) and (maxItemDurability ~= nil ) then
			--EMA:Print("£test", i, curItemDurability, maxItemDurability )
			curTotal = curTotal + curItemDurability
			maxTotal = maxTotal + maxItemDurability
			if maxItemDurability > 0 and curItemDurability == 0 then
				broken = broken + 1
			end
		end
	end
	
	--EMA:Print( curTotal, maxTotal )
	local durabilityPercent = ( EMAUtilities:GetStatusPercent(curTotal, maxTotal) * 100 )
	local durabilityText = tostring(gsub( durabilityPercent, "%.[^|]+", "") )
	--EMA:Print("Test durability", durabilityPercent, durabilityText,"%")
	if EMA.toldMasterAboutDurability == true then
		if durabilityPercent >= tonumber( EMA.db.warnWhenDurabilityDropsAmount ) then
			EMA.toldMasterAboutDurability = false
			EMA:ScheduleTimer("ResetDurability", 15, nil )
		end
	else
		if durabilityPercent < tonumber( EMA.db.warnWhenDurabilityDropsAmount ) then
			EMA.toldMasterAboutDurability = true
			EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.warnDurabilityDropsMessage..L[" "]..durabilityText..L["%"], false )
		end
	end	
end

function EMA:ResetDurability()
	EMA.toldMasterAboutDurability = false
	EMA:CancelAllTimers()
end	

function EMA:PLAYER_REGEN_ENABLED( event, ... )
	EMA.haveBeenHit = false
end

function EMA:PLAYER_REGEN_DISABLED( event, ... )
	EMA.haveBeenHit = false
	if EMA.db.warnTargetNotMasterEnterCombat == true then
		if EMAApi.IsCharacterTheMaster( EMA.characterName ) == false then
			local name, realm = UnitName( "target" )
			local character = EMAUtilities:AddRealmToNameIfNotNil( name, realm )
			if character ~= EMAApi.GetMasterName() then
				EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.warnTargetNotMasterMessage, false )
			end
		end
	end
	if EMA.db.warnFocusNotMasterEnterCombat == true then
		if EMAApi.IsCharacterTheMaster( EMA.characterName ) == false then
			local name, realm = UnitName( "focus" )
			local character = EMAUtilities:AddRealmToNameIfNotNil( name, realm )
			if character ~= EMAApi.GetMasterName() then
				EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.warnFocusNotMasterMessage, false )
			end
		end
	end
end

function EMA:BAGS_FULL( event, arg1, message, ... )
   if EMA.db.warnBagsFull == true then
		if UnitIsGhost( "player" ) then 
			return 
		end
		if UnitIsDead( "player" ) then 
			return 
		end
		local numberFreeSlots, numberTotalSlots = LibBagUtils:CountSlots( "BAGS", 0 )
		if message == ERR_INV_FULL or message == INVENTORY_FULL then
			--EMA:Print("fullbag")
			if numberFreeSlots == 0 then
				if EMA.previousFreeBagSlotsCount == false then
					EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.bagsFullMessage, false )
					EMA.previousFreeBagSlotsCount = true
					EMA:ScheduleTimer("ResetBagFull", 15, nil )
				end
			end
		end	
	end
end

function EMA:BAG_UPDATE_DELAYED(event, ... )
  if EMA.db.warnBagsFull == false then	
    return
  end
  
  if EMA.previousFreeBagSlotsCount == true then
    return
  end
  
  local numberFreeSlots, numberTotalSlots = LibBagUtils:CountSlots( "BAGS", 0 )
  if numberFreeSlots > 0 and numberFreeSlots < EMA.db.warnWhenBagsAlmostFullAmount then
    local warnMsg = EMA.db.bagsAlmostFullMessage .. ' (' .. tostring(numberFreeSlots) .. ')'
    EMA:EMASendMessageToTeam( EMA.db.warningArea, warnMsg, false )
    EMA.previousFreeBagSlotsCount = true
    EMA:ScheduleTimer("ResetBagFull", 15, nil )
  elseif numberFreeSlots > 0 then
    EMA.previousFreeBagSlotsCount = false
    EMA:CancelAllTimers()
  end
end

function EMA:ResetBagFull()
	EMA.previousFreeBagSlotsCount = false
	EMA:CancelAllTimers()
end	

--Ebony CCed
function EMA:LOSS_OF_CONTROL_ADDED( event, ... )
	if EMA.db.warnCC == true then
		if EMAPrivate.Core.isEmaClassicBuild() == true then
			local eventIndex = C_LossOfControl.GetNumEvents()
			if eventIndex > 0 then
				local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(eventIndex)	
				if EMAApi.IsCharacterTheMaster( EMA.characterName ) == false then
					EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.CcMessage..L[" "]..text, false )
				end
			end
		else
			local eventIndex = C_LossOfControl.GetActiveLossOfControlDataCount()
			if eventIndex > 0 then
				local LossOfControlData = C_LossOfControl.GetActiveLossOfControlData(eventIndex)
				--local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType	
				local name, rank, icon, castTime, minRange, maxRange, spellId =  GetSpellInfo( LossOfControlData.spellID )
				--EMA:Print("test", LossOfControlData.spellID, name )
				if EMAApi.IsCharacterTheMaster( EMA.characterName ) == false and name ~= nil then
					EMA:EMASendMessageToTeam( EMA.db.warningArea, EMA.db.CcMessage..L[" "].. name, false )
				end
			end
		end
	end	
end

function EMA:QUEST_SESSION_CREATED( event, ...)
	--EMA:Print("test")
	if EMA.db.autoAcceptPartySyncRequest == true then
		C_QuestSession.SendSessionBeginResponse( "true" )
	end	
end	

function EMA:SetView()
	EMA:EMASendCommandToTeam( EMA.COMMAND_SET_VIEW )
end

function EMA:DoSetView(characterName, ...)
	if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true and EMA.db.setViewWithoutMaster == true then
		return
	end	
		
	SetView( EMA.db.setView);SetView( EMA.db.setView)
end

-- A EMA command has been received.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	--EMA:Print("Test", characterName, commandName)
	if commandName == EMA.COMMAND_RECOVER_TEAM then
		EMA:doRecoverTeam()
	end
	if commandName == EMA.COMMAND_TEAM_DEATH then
		EMA:doTeamDeath()
	end
	-- More then likey to get removed
	if commandName == EMA.COMMAND_SOUL_STONE then
		--EMA:doSoulStone()
	end
	if commandName == EMA.COMMAND_READY_CHECK then
		if characterName ~= self.characterName then
			EMA.AmReadyCheck( characterName, ... )
		end	
	end
	if commandName == EMA.COMMAND_TELE_PORT then
		if characterName ~= self.characterName then
			EMA.DoLFGTeleport( characterName, ... )
		end	
	end
	if commandName == EMA.COMMAND_LOOT_ROLL then
		if characterName ~= self.characterName then
			EMA.DoLootRoll( characterName, ... )
		end	
	end
	if commandName == EMA.COMMAND_WAR_MODE then
		if characterName ~= self.characterName then
			--EMA.isInternalCommand = false
			EMA.DoWarMode( characterName, ... )
		end	
	end
	if commandName == EMA.COMMAND_SET_VIEW then
		EMA.DoSetView( characterName, ... )
	end	
end

-------------------------------------------------------------------------------------------------------------
-- Key bindings.
-------------------------------------------------------------------------------------------------------------

function EMA:UPDATE_BINDINGS()
	if InCombatLockdown() then
		return
	end
	ClearOverrideBindings( EMA.keyBindingFrame )
	local key1, key2 = GetBindingKey( "SETVIEW" )		
	if key1 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key1, "EMASETVIEW" ) 
	end
	if key2 then 
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key2, "EMASETVIEW" ) 
	end	
end
--EMAApi.isInternalCommand = EMA.isInternalCommand
