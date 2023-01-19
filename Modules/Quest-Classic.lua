-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Calladine (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2020 Jennifer Calladine					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- Only Load for Classic/TBC
if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE then
	return
end

-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Quest", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Load libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local AceGUI = LibStub( "AceGUI-3.0" )
EMA.SharedMedia = LibStub( "LibSharedMedia-3.0" )


--  Constants and Locale for this module.
EMA.moduleName = "Quest"
EMA.settingsDatabaseName = "QuestProfileDB"
EMA.chatCommand = "ema-quest"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["QUEST"]
EMA.moduleDisplayName = L["QUEST"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\QuestIcon.tga"
EMA.moduleCompletionIcon = "Interface\\Addons\\EMA\\Media\\QuestCompletionIcon.tga"
-- order
EMA.moduleOrder = 50
EMA.moduleCompletionOrder = 1

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		mirrorMasterQuestSelectionAndDeclining = true,
		acceptQuests = true,
		slaveMirrorMasterAccept = true,
		allAutoSelectQuests = false,
		doNotAutoAccept = true,
		allAcceptAnyQuest = false,
		onlyAcceptQuestsFrom = false,
		hideStaticPopup = false,
		acceptFromTeam = false,
		acceptFromNpc = false,
		acceptFromFriends = false,
		acceptFromParty = false,
		acceptFromRaid = false,
		acceptFromGuild = false,
		masterAutoShareQuestOnAccept = false,
		slaveAutoAcceptEscortQuest = true,
		showEMAQuestLogWithWoWQuestLog = true,
		enableAutoQuestCompletion = true,
		noChoiceAllDoNothing = false,
		noChoiceSlaveCompleteQuestWithMaster = true,
		noChoiceAllAutoCompleteQuest = false,
		hasChoiceSlaveDoNothing = false,
		hasChoiceSlaveCompleteQuestWithMaster = true,
		hasChoiceSlaveChooseSameRewardAsMaster = false,
		hasChoiceSlaveMustChooseOwnReward = true,
		hasChoiceAquireBestQuestRewardForCharacter = false, 
		hasChoiceSlaveRewardChoiceModifierConditional = false,
		hasChoiceCtrlKeyModifier = false,
		hasChoiceShiftKeyModifier = false,
		hasChoiceAltKeyModifier = false,
		hasChoiceOverrideUseSlaveRewardSelected = true,
		messageArea = EMAApi.DefaultMessageArea(),
		warningArea = EMAApi.DefaultWarningArea(),
		framePoint = "CENTER",
		frameRelativePoint = "CENTER",
		frameXOffset = 0,
		frameYOffset = 0,
		overrideQuestAutoSelectAndComplete = false,
	},
}

-- Configuration.
function EMA:GetConfiguration()
	local configuration = {
		name = EMA.moduleDisplayName,
		handler = EMA,
		type = "group",
		get = "EMAConfigurationGetSetting",
		set = "EMAConfigurationSetSetting",
		args = {	
			config = {
				type = "input",
				name = L["OPEN_CONFIG"],
				desc = L["OPEN_CONFIG_HELP"],
				usage = "/ema-quest config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-quest push",
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

EMA.COMMAND_SELECT_GOSSIP_OPTION = "EMASelectGossipOption"
EMA.COMMAND_SELECT_GOSSIP_ACTIVE_QUEST = "EMASelectGossipActiveQuest"
EMA.COMMAND_SELECT_GOSSIP_AVAILABLE_QUEST = "EMASelectGossipAvailableQuest"
EMA.COMMAND_SELECT_ACTIVE_QUEST = "EMASelectActiveQuest"
EMA.COMMAND_SELECT_AVAILABLE_QUEST = "EMASelectAvailableQuest"
EMA.COMMAND_ACCEPT_QUEST = "EMAAcceptQuest"
EMA.COMMAND_COMPLETE_QUEST = "EMACompleteQuest"
EMA.COMMAND_CHOOSE_QUEST_REWARD = "EMAChooseQuestReward"
EMA.COMMAND_DECLINE_QUEST = "EMADeclineQuest"
EMA.COMMAND_SELECT_QUEST_LOG_ENTRY = "EMASelectQuestLogEntry"
EMA.COMMAND_QUEST_TRACK = "EMAQuestTrack"
EMA.COMMAND_ABANDON_QUEST = "EMAAbandonQuest"
EMA.COMMAND_ABANDON_ALL_QUESTS = "EMAAbandonAllQuests"
EMA.COMMAND_TRACK_ALL_QUESTS = "EMATrackAllQuests"
EMA.COMMAND_UNTRACK_ALL_QUESTS = "EMAUnTrackAllQuests"
EMA.COMMAND_SHARE_ALL_QUESTS = "EMAShareAllQuests"
EMA.COMMAND_TOGGLE_AUTO_SELECT = "EMAToggleAutoSelect"
EMA.COMMAND_LOG_COMPLETE_QUEST = "EMALogCompleteQuest"
EMA.COMMAND_ACCEPT_QUEST_FAKE = "EMAAcceptQuestFake"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
-- Popup Dialogs.
-------------------------------------------------------------------------------------------------------------

-- Initialize Popup Dialogs.
local function InitializePopupDialogs()
   -- Asks If you like to Abandon on all toons
   StaticPopupDialogs["EMAQUEST_ABANDON_ALL_TOONS"] = {
        text = L["ABANDON_QUESTS_TEAM"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function( self, data )
		--	EMA:Print("button1", data.questID, data.title )
			EMA:EMASendCommandToTeam( EMA.COMMAND_ABANDON_QUEST, data.questID, data.title)
		end,
		OnCancel = function( self )
		end,	
    }
   -- Asks If you like to Track on all toons
   StaticPopupDialogs["EMA_QUEST_TRACK_ALL_TOONS"] = {
        text = L["TRACK_QUEST_ON_TEAM"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function( self, data )
			EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, data.questID, data.title, true )
		end,
		OnCancel = function( self )
		end,		
    }
	StaticPopupDialogs["EMA_QUEST_UNTRACK_ALL_TOONS"] = {
        text = L["UNTRACK_QUEST_ON_TEAM"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function( self, data )
			EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, data.questID, data.title, false )
		end,
		OnCancel = function( self )
		end,		
    }
	StaticPopupDialogs["EMA_ABANDON_ALL_TOON_QUEST"] = {
        text = L["ABANDON_ALL_QUESTS"],
        button1 = L["YES_IAM_SURE"],
        button2 = NO,
        timeout = 0,
		showAlert = 1,
		whileDead = true,
		hideOnEscape = true,
		OnAccept = function()
			EMA:DoAbandonAllQuestsFromAllToons()
		end,
    }
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

function EMA:DebugMessage( ... )
	--EMA:Print( ... )
end

-- Initialise the module.
function EMA:OnInitialize()
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	-- Create the EMA Quest Log frame.
	EMA:CreateEMAMiniQuestLogFrame()
	-- An empty table to hold the available and active quests at an npc.
	EMA.gossipQuests = {}
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	-- No internal commands active.
	EMA.isInternalCommand = false
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
    -- Quest events.
	EMA:RegisterEvent( "QUEST_ACCEPTED" )
    EMA:RegisterEvent( "QUEST_DETAIL" )
    EMA:RegisterEvent( "QUEST_COMPLETE" )
    EMA:RegisterEvent( "QUEST_ACCEPT_CONFIRM" )
	EMA:RegisterEvent( "GOSSIP_SHOW" )
	EMA:RegisterEvent( "QUEST_GREETING" )
	EMA:RegisterEvent( "QUEST_PROGRESS" )
	EMA:RegisterEvent( "CHAT_MSG_SYSTEM", "QUEST_FAIL" )
   -- Quest post hooks.
    EMA:SecureHook( "SelectGossipOption" )
    if EMAPrivate.Core.isEmaClassicBuild() == true then
		EMA:SecureHook( "SelectGossipActiveQuest" )
		EMA:SecureHook( "SelectGossipAvailableQuest" )
	else	
		EMA:SecureHook( C_GossipInfo, "SelectActiveQuest" )
		EMA:SecureHook( C_GossipInfo, "SelectAvailableQuest" )
    end
    EMA:SecureHook( "SelectActiveQuest" )
    EMA:SecureHook( "SelectAvailableQuest" )
    EMA:SecureHook( "AcceptQuest" )
    EMA:SecureHook( "CompleteQuest" )
	EMA:SecureHook( "GetQuestReward" )
	EMA:SecureHook( "ToggleFrame" )
	EMA:SecureHook( "ToggleQuestLog" )
	EMA:SecureHook( "ShowQuestComplete" )
	EMA:SecureHook( "AbandonQuest" )
--	EMA:SecureHook( "QuestWatch_Update" )
--	EMA:SecureHook( "QuestMapQuestOptions_TrackQuest" )
--	EMA:SecureHook( "QuestLog" )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
	-- AceHook-3.0 will tidy up the hooks for us. 
end

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsCreate()
	EMA.settingsControl = {}
	EMA.settingsControlCompletion = {}
	-- Create the settings panels.
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder		
	)
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControlCompletion, 
		L["COMPLETION"], 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleCompletionIcon,
		EMA.moduleCompletionOrder			
	)
	-- Create the quest controls.
	local bottomOfQuestOptions = EMA:SettingsCreateQuestControl( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfQuestOptions )
	local bottomOfQuestCompletionOptions = EMA:SettingsCreateQuestCompletionControl( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControlCompletion.widgetSettings.content:SetHeight( -bottomOfQuestCompletionOptions )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

function EMA:SettingsCreateQuestControl( top )
	-- Get positions and dimensions.
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local radioBoxHeight = EMAHelperSettings:GetRadioBoxHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local labelContinueHeight = EMAHelperSettings:GetContinueLabelHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local indent = horizontalSpacing * 10
	local indentContinueLabel = horizontalSpacing * 22
	local checkBoxThirdWidth = (headingWidth - indentContinueLabel) / 3
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local middle = left + halfWidth
	local column1Left = left
	local column1LeftIndent = left + indentContinueLabel
	local column2LeftIndent = column1LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local column3LeftIndent = column2LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, "", movingTop, false )
	movingTop = movingTop - headingHeight
	-- Create a heading for information.
	EMAHelperSettings:CreateHeading( EMA.settingsControl, EMA.moduleDisplayName..L[" "]..L["INFORMATION"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Information line 1.
	EMA.settingsControl.labelQuestInformation1 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["QUESTINFORMATIONONE"] 
	)	
	movingTop = movingTop - labelContinueHeight		
	-- Information line 2.
	EMA.settingsControl.labelQuestInformation2 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["QUESTINFORMATIONTWO"] 
	)	
	movingTop = movingTop - labelContinueHeight		
	-- Information line 3.
	EMA.settingsControl.labelQuestInformation3 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["QUESTINFORMATIONTHREE"] 
	)	
	movingTop = movingTop - labelContinueHeight				
	-- Create a heading for quest selection.
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["QUEST_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Radio box: Minion select, accept and decline quest with master.
	EMA.settingsControl.checkBoxMirrorMasterQuestSelectionAndDeclining = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["MIRROR_QUEST"],
		EMA.SettingsToggleMirrorMasterQuestSelectionAndDeclining,
		L["MIRROR_QUEST_HELP"]
	)	
	EMA.settingsControl.checkBoxMirrorMasterQuestSelectionAndDeclining:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: All auto select quests.
	EMA.settingsControl.checkBoxAllAutoSelectQuests = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["AUTO_SELECT_QUESTS"],
		EMA.SettingsToggleAllAutoSelectQuests,
		L["AUTO_SELECT_QUESTS_HELP"]
	)	
	EMA.settingsControl.checkBoxAllAutoSelectQuests:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Check box: Accept quests.
	EMA.settingsControl.checkBoxAcceptQuests = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["ACCEPT_QUESTS"],
		EMA.SettingsToggleAcceptQuests,
		L["ACCEPT_QUESTS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight		
	-- Radio box: Minion accept quest with master.
	EMA.settingsControl.checkBoxMinionMirrorMasterAccept = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["ACCEPT_QUEST_WITH_TEAM"],
		EMA.SettingsToggleMinionMirrorMasterAccept,
		L["ACCEPT_QUEST_WITH_TEAM_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight				
	-- Information line 3.
	EMA.settingsControl.labelQuestInformationAuto = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["QUEST_INFORMATION_AUTO"] 
	)	
	movingTop = movingTop - labelContinueHeight
	-- Radio box: All auto accept any quest.
	EMA.settingsControl.checkBoxDoNotAutoAccept = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["DONOT_AUTO_ACCEPT_QUESTS"],
		EMA.SettingsToggleDoNotAutoAccept
	)	
	EMA.settingsControl.checkBoxDoNotAutoAccept:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight		
	-- Radio box: All auto accept any quest.
	EMA.settingsControl.checkBoxAllAcceptAnyQuest = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["AUTO_ACCEPT_QUESTS"],
		EMA.SettingsToggleAllAcceptAnyQuest,
		L["AUTO_ACCEPT_QUESTS_HELP"]
	)	
	EMA.settingsControl.checkBoxAllAcceptAnyQuest:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight		
	-- Radio box: Choose who to auto accept quests from.
	EMA.settingsControl.checkBoxOnlyAcceptQuestsFrom = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["AUTO_ACCEPT_QUESTS_LIST"],
		EMA.SettingsToggleOnlyAcceptQuestsFrom,
		L["AUTO_ACCEPT_QUESTS_LIST_HELP"]
	)	
	EMA.settingsControl.checkBoxOnlyAcceptQuestsFrom:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Check box: Team.
	EMA.settingsControl.checkBoxAcceptFromTeam = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		checkBoxThirdWidth, 
		column1LeftIndent, 
		movingTop,
		L["TEAM"],
		EMA.SettingsToggleAcceptFromTeam,
		L["TEAM_QUEST_HELP"]
	)	
	-- Check box: NPC.
	EMA.settingsControl.checkBoxAcceptFromNpc = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		checkBoxThirdWidth, 
		column2LeftIndent, 
		movingTop,
		L["NPC"],
		EMA.SettingsToggleAcceptFromNpc,
		L["NPC_HELP"]
	)	
	-- Check box: Friends.
	EMA.settingsControl.checkBoxAcceptFromFriends = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		checkBoxThirdWidth, 
		column3LeftIndent, 
		movingTop,
		L["FRIENDS"],
		EMA.SettingsToggleAcceptFromFriends,
		L["FRIENDS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	-- Check box: Party.
	EMA.settingsControl.checkBoxAcceptFromParty = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		checkBoxThirdWidth, 
		column1LeftIndent, 
		movingTop,
		L["PARTY"],
		EMA.SettingsToggleAcceptFromParty,
		L["QUEST_GROUP_HELP"]
		
	)	
	-- Check box: Guild.
	--movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxAcceptFromGuild = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		checkBoxThirdWidth, 
		column2LeftIndent, 
		movingTop,
		L["GUILD"],
		EMA.SettingsToggleAcceptFromGuild,
		L["GUILD_HELP"]
	)	
-- TODO Change To Community's
	-- Check box: Raid. 
	EMA.settingsControl.checkBoxAcceptFromRaid = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		checkBoxThirdWidth, 
		column3LeftIndent, 
		movingTop,
		L["PH_RAID"],
		EMA.SettingsToggleAcceptFromRaid,
		L["PH_RAID_HELP"]
	)		
	-- Check box: Master auto share quest on accept.
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxMasterAutoShareQuestOnAccept = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["MASTER_SHARE_QUESTS"],
		EMA.SettingsToggleMasterAutoShareQuestOnAccept,
		L["MASTER_SHARE_QUESTS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight			
	-- Check box: Minion auto accept escort quest from master.
	EMA.settingsControl.checkBoxMinionAutoAcceptEscortQuest = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["ACCEPT_ESCORT_QUEST"],
		EMA.SettingsToggleMinionAutoAcceptEscortQuest,
		L["ACCEPT_ESCORT_QUEST_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	-- Create a heading for other options.
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["OTHER"]..L[" "]..L["OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Check box: Override quest auto select and auto complete.
	EMA.settingsControl.checkBoxOverrideQuestAutoSelectAndComplete = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["HOLD_SHIFT_TO_OVERRIDE"],
		EMA.SettingsToggleOverrideQuestAutoSelectAndComplete,
		L["HOLD_SHIFT_TO_OVERRIDE_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	-- Check box: Show EMA quest log with WoW quest log.
	EMA.settingsControl.checkBoxShowEMAQuestLogWithWoWQuestLog = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["SHOW_PANEL_UNDER_QUESTLOG"],
		EMA.SettingsToggleShowEMAQuestLogWithWoWQuestLog,
		L["SHOW_PANEL_UNDER_QUESTLOG_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	-- Message area.
	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop, 
		L["MESSAGE_AREA"] 
	)
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", EMA.SettingsSetMessageArea )
	movingTop = movingTop - dropdownHeight
	-- Warning area.
	EMA.settingsControl.dropdownWarningArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop, 
		L["SEND_WARNING_AREA"] 
	)
	EMA.settingsControl.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownWarningArea:SetCallback( "OnValueChanged", EMA.SettingsSetWarningArea )
	movingTop = movingTop - dropdownHeight
	return movingTop	
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:SettingsCreateQuestCompletionControl( top )
	-- Get positions and dimensions.
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
	local column1LeftIndent = left + indentContinueLabel
	local column2LeftIndent = column1LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local column3LeftIndent = column2LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControlCompletion, "", movingTop, false )
	movingTop = movingTop - headingHeight
	-- Create a heading for quest completion.
	EMAHelperSettings:CreateHeading( EMA.settingsControlCompletion, L["QUEST_COMPLETION"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Check box: Enable auto quest completion.
	EMA.settingsControlCompletion.checkBoxEnableAutoQuestCompletion = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["ENABLE_QUEST_COMPLETION"],
		EMA.SettingsToggleEnableAutoQuestCompletion,
		L["ENABLE_QUEST_COMPLETION_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControlCompletion, L["NOREWARDS_OR_ONEREWARD"], movingTop, false )
	movingTop = movingTop - headingHeight	
	-- Radio box: No choice, minion do nothing.
	EMA.settingsControlCompletion.checkBoxNoChoiceAllDoNothing = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["QUEST_DO_NOTHING"],
		EMA.SettingsToggleNoChoiceAllDoNothing,
		L["QUEST_DO_NOTHING_HELP"]
	)	
	EMA.settingsControlCompletion.checkBoxNoChoiceAllDoNothing:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight	
	-- Radio box: No choice, minion complete quest with master.
	EMA.settingsControlCompletion.checkBoxNoChoiceMinionCompleteQuestWithMaster = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["COMPLETE_QUEST_WITH_TEAM"],
		EMA.SettingsToggleNoChoiceMinionCompleteQuestWithMaster,
		L["COMPLETE_QUEST_WITH_TEAM_HELP"]
	)
	EMA.settingsControlCompletion.checkBoxNoChoiceMinionCompleteQuestWithMaster:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: No Choice, all automatically complete quest.
	EMA.settingsControlCompletion.checkBoxNoChoiceAllAutoCompleteQuest = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["AUTO_COMPLETE_QUEST"],
		EMA.SettingsToggleNoChoiceAllAutoCompleteQuest,
		L["AUTO_COMPLETE_QUEST_HELP"]
	)	
	EMA.settingsControlCompletion.checkBoxNoChoiceAllAutoCompleteQuest:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControlCompletion, L["MORE_THEN_ONE_REWARD"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Radio box: Has choice, minion do nothing.
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionDoNothing = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["QUEST_DO_NOTHING"] ,
		EMA.SettingsToggleHasChoiceMinionDoNothing,
		L["QUEST_DO_NOTHING_HELP"]
	)	
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionDoNothing:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: Has choice, minion complete quest with master.
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionCompleteQuestWithMaster = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["COMPLETE_QUEST_WITH_TEAM"],
		EMA.SettingsToggleHasChoiceMinionCompleteQuestWithMaster,
		L["COMPLETE_QUEST_WITH_TEAM_HELP"]
	)	
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionCompleteQuestWithMaster:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: Has choice, minion must choose own reward.
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionMustChooseOwnReward = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["MUST_CHOOSE_OWN_REWARD"],
		EMA.SettingsToggleHasChoiceMinionMustChooseOwnReward,
		L["MUST_CHOOSE_OWN_REWARD_HELP"]
	)	
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionMustChooseOwnReward:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight	
	-- Radio box: Has choice, minion choose same reward as master.
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionChooseSameRewardAsMaster = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["CHOOSE_SAME_REWARD"],
		EMA.SettingsToggleHasChoiceMinionChooseSameRewardAsMaster,
		L["CHOOSE_SAME_REWARD_HELP"] 
	)	
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionChooseSameRewardAsMaster:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight	
	-- Radio box: Has choice, minion choose same reward as master.
	EMA.settingsControlCompletion.checkBoxHasChoiceAquireBestQuestRewardForCharacter = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["CHOOSE_BEST_REWARD"],
		EMA.SettingsToggleHasChoiceAquireBestQuestRewardForCharacter,
		L["CHOOSE_BEST_REWARD_HELP"] 
	)	
	EMA.settingsControlCompletion.checkBoxHasChoiceAquireBestQuestRewardForCharacter:SetType( "radio" )
	movingTop = movingTop - radioBoxHeight
	-- Radio box: Has choice, minion reward choice depends on modifier key pressed down.
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionRewardChoiceModifierConditional = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["MODIFIER_CHOOSE_SAME_REWARD"],
		EMA.SettingsToggleHasChoiceMinionRewardChoiceModifierConditional,
		L["MODIFIER_CHOOSE_SAME_REWARD_HELP"]
	)	
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionRewardChoiceModifierConditional:SetType( "radio" )
	
	movingTop = movingTop - radioBoxHeight
	-- Check box: Ctrl modifier key.
	EMA.settingsControlCompletion.checkBoxHasChoiceCtrlKeyModifier = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlCompletion, 
		checkBoxThirdWidth, 
		column1LeftIndent, 
		movingTop,
		L["CTRL"],
		EMA.SettingsToggleHasChoiceCtrlKeyModifier
	)	
	-- Check box: Shift modifier key.
	EMA.settingsControlCompletion.checkBoxHasChoiceShiftKeyModifier = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlCompletion, 
		checkBoxThirdWidth, 
		column2LeftIndent, 
		movingTop,
		L["SHIFT"],
		EMA.SettingsToggleHasChoiceShiftKeyModifier
	)	
	-- Check box: Alt modifier key.
	EMA.settingsControlCompletion.checkBoxHasChoiceAltKeyModifier = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlCompletion, 
		checkBoxThirdWidth, 
		column3LeftIndent, 
		movingTop,
		L["ALT"],
		EMA.SettingsToggleHasChoiceAltKeyModifier
	)	
	movingTop = movingTop - checkBoxHeight
	-- Check box: Has choice, override, if minion already has reward selected, choose that reward.
	EMA.settingsControlCompletion.checkBoxHasChoiceOverrideUseMinionRewardSelected = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControlCompletion, 
		headingWidth, 
		column1Left + indent, 
		movingTop,
		L["OVERRIDE_REWARD_SELECTED"],
		EMA.SettingsToggleHasChoiceOverrideUseMinionRewardSelected,
		L["OVERRIDE_REWARD_SELECTED_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	return movingTop	
end

-------------------------------------------------------------------------------------------------------------
-- Settings functionality.
-------------------------------------------------------------------------------------------------------------

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.mirrorMasterQuestSelectionAndDeclining = settings.mirrorMasterQuestSelectionAndDeclining
		EMA.db.allAutoSelectQuests = settings.allAutoSelectQuests
		EMA.db.acceptQuests = settings.acceptQuests
		EMA.db.slaveMirrorMasterAccept = settings.slaveMirrorMasterAccept
		EMA.db.doNotAutoAccept = settings.doNotAutoAccept 
		EMA.db.allAcceptAnyQuest = settings.allAcceptAnyQuest
		EMA.db.onlyAcceptQuestsFrom = settings.onlyAcceptQuestsFrom
		EMA.db.acceptFromTeam = settings.acceptFromTeam
		EMA.db.acceptFromNpc = settings.acceptFromNpc
		EMA.db.acceptFromFriends = settings.acceptFromFriends
		EMA.db.acceptFromParty = settings.acceptFromParty
		EMA.db.acceptFromRaid = settings.acceptFromRaid
		EMA.db.acceptFromGuild = settings.acceptFromGuild
		EMA.db.masterAutoShareQuestOnAccept = settings.masterAutoShareQuestOnAccept
		EMA.db.slaveAutoAcceptEscortQuest = settings.slaveAutoAcceptEscortQuest
		EMA.db.showEMAQuestLogWithWoWQuestLog = settings.showEMAQuestLogWithWoWQuestLog
		EMA.db.enableAutoQuestCompletion = settings.enableAutoQuestCompletion
		EMA.db.noChoiceAllDoNothing = settings.noChoiceAllDoNothing
		EMA.db.noChoiceSlaveCompleteQuestWithMaster = settings.noChoiceSlaveCompleteQuestWithMaster
		EMA.db.noChoiceAllAutoCompleteQuest = settings.noChoiceAllAutoCompleteQuest
		EMA.db.hasChoiceSlaveDoNothing = settings.hasChoiceSlaveDoNothing
		EMA.db.hasChoiceSlaveCompleteQuestWithMaster = settings.hasChoiceSlaveCompleteQuestWithMaster
		EMA.db.hasChoiceSlaveChooseSameRewardAsMaster = settings.hasChoiceSlaveChooseSameRewardAsMaster
		EMA.db.hasChoiceAquireBestQuestRewardForCharacter = settings.hasChoiceAquireBestQuestRewardForCharacter
		EMA.db.hasChoiceSlaveMustChooseOwnReward = settings.hasChoiceSlaveMustChooseOwnReward
		EMA.db.hasChoiceSlaveRewardChoiceModifierConditional = settings.hasChoiceSlaveRewardChoiceModifierConditional
		EMA.db.hasChoiceCtrlKeyModifier = settings.hasChoiceCtrlKeyModifier
		EMA.db.hasChoiceShiftKeyModifier = settings.hasChoiceShiftKeyModifier
		EMA.db.hasChoiceAltKeyModifier = settings.hasChoiceAltKeyModifier
		EMA.db.hasChoiceOverrideUseSlaveRewardSelected = settings.hasChoiceOverrideUseSlaveRewardSelected
		EMA.db.messageArea = settings.messageArea
		EMA.db.warningArea = settings.warningArea
		EMA.db.overrideQuestAutoSelectAndComplete = settings.overrideQuestAutoSelectAndComplete
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
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
	-- Quest general and acceptance options.
	EMA.settingsControl.checkBoxMirrorMasterQuestSelectionAndDeclining:SetValue( EMA.db.mirrorMasterQuestSelectionAndDeclining )
	EMA.settingsControl.checkBoxAllAutoSelectQuests:SetValue( EMA.db.allAutoSelectQuests )
	EMA.settingsControl.checkBoxAcceptQuests:SetValue( EMA.db.acceptQuests )
	EMA.settingsControl.checkBoxMinionMirrorMasterAccept:SetValue( EMA.db.slaveMirrorMasterAccept )
	EMA.settingsControl.checkBoxDoNotAutoAccept:SetValue( EMA.db.doNotAutoAccept )
	EMA.settingsControl.checkBoxAllAcceptAnyQuest:SetValue( EMA.db.allAcceptAnyQuest )
	EMA.settingsControl.checkBoxOnlyAcceptQuestsFrom:SetValue( EMA.db.onlyAcceptQuestsFrom )
	EMA.settingsControl.checkBoxAcceptFromTeam:SetValue( EMA.db.acceptFromTeam )
	EMA.settingsControl.checkBoxAcceptFromNpc:SetValue( EMA.db.acceptFromNpc )
	EMA.settingsControl.checkBoxAcceptFromFriends:SetValue( EMA.db.acceptFromFriends )
	EMA.settingsControl.checkBoxAcceptFromParty:SetValue( EMA.db.acceptFromParty )
	EMA.settingsControl.checkBoxAcceptFromRaid:SetValue( EMA.db.acceptFromRaid )
	EMA.settingsControl.checkBoxAcceptFromGuild:SetValue( EMA.db.acceptFromGuild )
	EMA.settingsControl.checkBoxMasterAutoShareQuestOnAccept:SetValue( EMA.db.masterAutoShareQuestOnAccept )
	EMA.settingsControl.checkBoxMinionAutoAcceptEscortQuest:SetValue( EMA.db.slaveAutoAcceptEscortQuest )
	EMA.settingsControl.checkBoxShowEMAQuestLogWithWoWQuestLog:SetValue( EMA.db.showEMAQuestLogWithWoWQuestLog )
	EMA.settingsControl.checkBoxOverrideQuestAutoSelectAndComplete:SetValue( EMA.db.overrideQuestAutoSelectAndComplete )
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.dropdownWarningArea:SetValue( EMA.db.warningArea )
	-- Quest completion options.
	EMA.settingsControlCompletion.checkBoxEnableAutoQuestCompletion:SetValue( EMA.db.enableAutoQuestCompletion )
	EMA.settingsControlCompletion.checkBoxNoChoiceAllDoNothing:SetValue( EMA.db.noChoiceAllDoNothing )
	EMA.settingsControlCompletion.checkBoxNoChoiceMinionCompleteQuestWithMaster:SetValue( EMA.db.noChoiceSlaveCompleteQuestWithMaster )
	EMA.settingsControlCompletion.checkBoxNoChoiceAllAutoCompleteQuest:SetValue( EMA.db.noChoiceAllAutoCompleteQuest )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionDoNothing:SetValue( EMA.db.hasChoiceSlaveDoNothing )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionCompleteQuestWithMaster:SetValue( EMA.db.hasChoiceSlaveCompleteQuestWithMaster )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionChooseSameRewardAsMaster:SetValue( EMA.db.hasChoiceSlaveChooseSameRewardAsMaster )
	EMA.settingsControlCompletion.checkBoxHasChoiceAquireBestQuestRewardForCharacter:SetValue ( EMA.db.hasChoiceAquireBestQuestRewardForCharacter )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionMustChooseOwnReward:SetValue( EMA.db.hasChoiceSlaveMustChooseOwnReward )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionRewardChoiceModifierConditional:SetValue( EMA.db.hasChoiceSlaveRewardChoiceModifierConditional )
	EMA.settingsControlCompletion.checkBoxHasChoiceCtrlKeyModifier:SetValue( EMA.db.hasChoiceCtrlKeyModifier )
	EMA.settingsControlCompletion.checkBoxHasChoiceShiftKeyModifier:SetValue( EMA.db.hasChoiceShiftKeyModifier )
	EMA.settingsControlCompletion.checkBoxHasChoiceAltKeyModifier:SetValue( EMA.db.hasChoiceAltKeyModifier )
	EMA.settingsControlCompletion.checkBoxHasChoiceOverrideUseMinionRewardSelected:SetValue( EMA.db.hasChoiceOverrideUseSlaveRewardSelected )
	-- Ensure correct state (general and acceptance options).
	EMA.settingsControl.checkBoxMinionMirrorMasterAccept:SetDisabled( not EMA.db.acceptQuests )
	EMA.settingsControl.checkBoxDoNotAutoAccept:SetDisabled( not EMA.db.acceptQuests )
	EMA.settingsControl.checkBoxAllAcceptAnyQuest:SetDisabled( not EMA.db.acceptQuests )
	EMA.settingsControl.checkBoxOnlyAcceptQuestsFrom:SetDisabled( not EMA.db.acceptQuests )
	EMA.settingsControl.checkBoxAcceptFromTeam:SetDisabled( not EMA.db.acceptQuests or not EMA.db.onlyAcceptQuestsFrom )
	EMA.settingsControl.checkBoxAcceptFromNpc:SetDisabled( not EMA.db.acceptQuests or not EMA.db.onlyAcceptQuestsFrom )
	EMA.settingsControl.checkBoxAcceptFromFriends:SetDisabled( not EMA.db.acceptQuests or not EMA.db.onlyAcceptQuestsFrom )
	EMA.settingsControl.checkBoxAcceptFromParty:SetDisabled( not EMA.db.acceptQuests or not EMA.db.onlyAcceptQuestsFrom )
	EMA.settingsControl.checkBoxAcceptFromRaid:SetDisabled( not EMA.db.acceptQuests or not EMA.db.onlyAcceptQuestsFrom )
	EMA.settingsControl.checkBoxAcceptFromGuild:SetDisabled( not EMA.db.acceptQuests or not EMA.db.onlyAcceptQuestsFrom )
	-- Ensure correct state (completion options). 
	EMA.settingsControlCompletion.checkBoxNoChoiceAllDoNothing:SetDisabled( not EMA.db.enableAutoQuestCompletion )
	EMA.settingsControlCompletion.checkBoxNoChoiceMinionCompleteQuestWithMaster:SetDisabled( not EMA.db.enableAutoQuestCompletion )
	EMA.settingsControlCompletion.checkBoxNoChoiceAllAutoCompleteQuest:SetDisabled( not EMA.db.enableAutoQuestCompletion )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionDoNothing:SetDisabled( not EMA.db.enableAutoQuestCompletion )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionCompleteQuestWithMaster:SetDisabled( not EMA.db.enableAutoQuestCompletion )
	
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionChooseSameRewardAsMaster:SetDisabled( not EMA.db.enableAutoQuestCompletion or not EMA.db.hasChoiceSlaveCompleteQuestWithMaster )
	EMA.settingsControlCompletion.checkBoxHasChoiceAquireBestQuestRewardForCharacter:SetDisabled( not EMA.db.enableAutoQuestCompletion or not EMA.db.hasChoiceSlaveCompleteQuestWithMaster )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionMustChooseOwnReward:SetDisabled( not EMA.db.enableAutoQuestCompletion or not EMA.db.hasChoiceSlaveCompleteQuestWithMaster )
	EMA.settingsControlCompletion.checkBoxHasChoiceMinionRewardChoiceModifierConditional:SetDisabled( not EMA.db.enableAutoQuestCompletion or not EMA.db.hasChoiceSlaveCompleteQuestWithMaster )
	
	EMA.settingsControlCompletion.checkBoxHasChoiceCtrlKeyModifier:SetDisabled( not EMA.db.enableAutoQuestCompletion or not EMA.db.hasChoiceSlaveCompleteQuestWithMaster or not EMA.db.hasChoiceSlaveRewardChoiceModifierConditional )
	EMA.settingsControlCompletion.checkBoxHasChoiceShiftKeyModifier:SetDisabled( not EMA.db.enableAutoQuestCompletion or not EMA.db.hasChoiceSlaveCompleteQuestWithMaster or not EMA.db.hasChoiceSlaveRewardChoiceModifierConditional )
	EMA.settingsControlCompletion.checkBoxHasChoiceAltKeyModifier:SetDisabled( not EMA.db.enableAutoQuestCompletion or not EMA.db.hasChoiceSlaveCompleteQuestWithMaster or not EMA.db.hasChoiceSlaveRewardChoiceModifierConditional )
	EMA.settingsControlCompletion.checkBoxHasChoiceOverrideUseMinionRewardSelected:SetDisabled( not EMA.db.enableAutoQuestCompletion or not EMA.db.hasChoiceSlaveCompleteQuestWithMaster )
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleMirrorMasterQuestSelectionAndDeclining( event, checked )
	EMA.db.mirrorMasterQuestSelectionAndDeclining = checked
	EMA.db.allAutoSelectQuests = not checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAllAutoSelectQuests( event, checked )
	EMA.db.allAutoSelectQuests = checked
	EMA.db.mirrorMasterQuestSelectionAndDeclining = not checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAcceptQuests( event, checked )
	EMA.db.acceptQuests = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleMinionMirrorMasterAccept( event, checked )
	EMA.db.slaveMirrorMasterAccept = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleOverrideQuestAutoSelectAndComplete( event, checked )
	EMA.db.overrideQuestAutoSelectAndComplete = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDoNotAutoAccept( event, checked )
	EMA.db.doNotAutoAccept = checked
	EMA.db.allAcceptAnyQuest = not checked
	EMA.db.onlyAcceptQuestsFrom = not checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAllAcceptAnyQuest( event, checked )
	EMA.db.allAcceptAnyQuest = checked
	EMA.db.onlyAcceptQuestsFrom = not checked
	EMA.db.doNotAutoAccept = not checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleOnlyAcceptQuestsFrom( event, checked )
	EMA.db.onlyAcceptQuestsFrom = checked
	EMA.db.allAcceptAnyQuest = not checked
	EMA.db.doNotAutoAccept = not checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAcceptFromTeam( event, checked )
	EMA.db.acceptFromTeam = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAcceptFromNpc( event, checked )
	EMA.db.acceptFromNpc = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAcceptFromFriends( event, checked )
	EMA.db.acceptFromFriends = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAcceptFromParty( event, checked )
	EMA.db.acceptFromParty = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAcceptFromRaid( event, checked )
	EMA.db.acceptFromRaid = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAcceptFromGuild( event, checked )
	EMA.db.acceptFromGuild = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleMasterAutoShareQuestOnAccept( event, checked )
	EMA.db.masterAutoShareQuestOnAccept = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleMinionAutoAcceptEscortQuest( event, checked )
	EMA.db.slaveAutoAcceptEscortQuest = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleShowEMAQuestLogWithWoWQuestLog( event, checked )
	EMA.db.showEMAQuestLogWithWoWQuestLog = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleEnableAutoQuestCompletion( event, checked )
	EMA.db.enableAutoQuestCompletion = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleNoChoiceAllDoNothing( event, checked )
	EMA.db.noChoiceAllDoNothing = checked
	EMA.db.noChoiceSlaveCompleteQuestWithMaster = not checked
	EMA.db.noChoiceAllAutoCompleteQuest = not checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleNoChoiceMinionCompleteQuestWithMaster( event, checked )
	EMA.db.noChoiceSlaveCompleteQuestWithMaster = checked
	EMA.db.noChoiceAllDoNothing = not checked
	EMA.db.noChoiceAllAutoCompleteQuest = not checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleNoChoiceAllAutoCompleteQuest( event, checked )
	EMA.db.noChoiceAllAutoCompleteQuest = checked
	EMA.db.noChoiceAllDoNothing = not checked
	EMA.db.noChoiceSlaveCompleteQuestWithMaster = not checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceMinionDoNothing( event, checked )
	EMA.db.hasChoiceSlaveDoNothing = checked
	if checked ~= false then
		EMA.db.hasChoiceSlaveCompleteQuestWithMaster = not checked
		EMA.db.hasChoiceSlaveMustChooseOwnReward = not checked
		EMA.db.hasChoiceAquireBestQuestRewardForCharacter = not checked
		EMA.db.hasChoiceSlaveRewardChoiceModifierConditional = not checked
	end	
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceMinionCompleteQuestWithMaster( event, checked )
	EMA.db.hasChoiceSlaveCompleteQuestWithMaster = checked
	if checked ~= false then
		EMA.db.hasChoiceSlaveDoNothing = not checked
		EMA.db.hasChoiceSlaveMustChooseOwnReward = not checked
		EMA.db.hasChoiceAquireBestQuestRewardForCharacter = not checked
		EMA.db.hasChoiceSlaveRewardChoiceModifierConditional = not checked
	end	
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceAquireBestQuestRewardForCharacter( event, checked )
	--EMA:Print("test")
	EMA.db.hasChoiceAquireBestQuestRewardForCharacter = checked
	if checked ~= false then
		EMA.db.hasChoiceSlaveMustChooseOwnReward = not checked
		EMA.db.hasChoiceSlaveChooseSameRewardAsMaster = not checked
		EMA.db.hasChoiceSlaveRewardChoiceModifierConditional = not checked
	end	
	
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceMinionChooseSameRewardAsMaster( event, checked )
	EMA.db.hasChoiceSlaveChooseSameRewardAsMaster = checked
	if checked ~= false then
		EMA.db.hasChoiceSlaveMustChooseOwnReward = not checked
		EMA.db.hasChoiceAquireBestQuestRewardForCharacter = not checked
		EMA.db.hasChoiceSlaveRewardChoiceModifierConditional = not checked
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceMinionMustChooseOwnReward( event, checked )
	EMA.db.hasChoiceSlaveMustChooseOwnReward = checked
	if checked ~= false then
		EMA.db.hasChoiceSlaveChooseSameRewardAsMaster = not checked
		EMA.db.hasChoiceAquireBestQuestRewardForCharacter = not checked
		EMA.db.hasChoiceSlaveRewardChoiceModifierConditional = not checked
	end
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceMinionRewardChoiceModifierConditional( event, checked )
	EMA.db.hasChoiceSlaveRewardChoiceModifierConditional = checked
	if checked ~= false then
		EMA.db.hasChoiceSlaveChooseSameRewardAsMaster = not checked
		EMA.db.hasChoiceSlaveMustChooseOwnReward = not checked
		EMA.db.hasChoiceAquireBestQuestRewardForCharacter = not checked
	end	
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceCtrlKeyModifier( event, checked )
	EMA.db.hasChoiceCtrlKeyModifier = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceShiftKeyModifier( event, checked )
	EMA.db.hasChoiceShiftKeyModifier = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceAltKeyModifier( event, checked )
	EMA.db.hasChoiceAltKeyModifier = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHasChoiceOverrideUseMinionRewardSelected( event, checked )
	EMA.db.hasChoiceOverrideUseSlaveRewardSelected = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsSetMessageArea( event, messageAreaValue )
	EMA:DebugMessage( event, messageAreaValue )
	EMA.db.messageArea = messageAreaValue
	EMA:SettingsRefresh()
end

function EMA:SettingsSetWarningArea( event, messageAreaValue )
	EMA.db.warningArea = messageAreaValue
	EMA:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- NPC QUEST PROCESSING - SELECTING AND DECLINING
-------------------------------------------------------------------------------------------------------------

function EMA:ChurnNpcGossip()
    EMA:DebugMessage( "ChurnNpcGossip" )
	-- GetGossipAvailableQuests and GetGossipActiveQuests are returning nil in some cases, so do this as well.
	-- GetGossipAvailableQuests() now returns 6 elements per quest and GetGossipActiveQuests() returns 4. title, level, isTrivial, isDaily, ...
	-- Patch 5.0.4 added isLegendary.
	-- title1, level1, isLowLevel1, isDaily1, isRepeatable1, isLegendary1, title2, level2, isLowLevel2, isDaily2, isRepeatable2, isLegendary2 = GetGossipAvailableQuests()
	-- title1, level1, isLowLevel1, isComplete1, isLegendary1, title2, level2, isLowLevel2, isComplete2, isLegendary2 = GetGossipActiveQuests()
	local numberAvailableQuestInfo = 6
	local numberActiveQuestInfo = 5
    local index
    EMA:DebugMessage( "GetNumAvailableQuests", GetNumAvailableQuests() )
    EMA:DebugMessage( "GetNumActiveQuests", GetNumActiveQuests() )
    EMA:DebugMessage( "GetGossipAvailableQuests", GetGossipAvailableQuests() )
    EMA:DebugMessage( "GetGossipActiveQuests", GetGossipActiveQuests() )
    for index = 0, GetNumAvailableQuests() do
		SelectAvailableQuest( index )
	end
    for index = 0, GetNumActiveQuests() do
		SelectActiveQuest( index )
	end
	EMAUtilities:ClearTable( EMA.gossipQuests )
	local availableQuestsData = { GetGossipAvailableQuests() }
	local iterateQuests = 1
	local questIndex = 1
	while( availableQuestsData[iterateQuests] ) do
		local questInformation = {}
		questInformation.type = "available"
		questInformation.index = questIndex
		questInformation.name = availableQuestsData[iterateQuests]
		questInformation.level = availableQuestsData[iterateQuests + 1]
		table.insert( EMA.gossipQuests, questInformation )
		iterateQuests = iterateQuests + numberAvailableQuestInfo
		questIndex = questIndex + 1
	end
	local activeQuestsData = { GetGossipActiveQuests() }
	iterateQuests = 1
	while( activeQuestsData[iterateQuests] ) do
		local questInformation = {}
		questInformation.type = "active"
		questInformation.index = questIndex
		questInformation.name = activeQuestsData[iterateQuests]
		questInformation.level = activeQuestsData[iterateQuests + 1]
		questInformation.isComplete = activeQuestsData[iterateQuests + 3]
		table.insert( EMA.gossipQuests, questInformation )
		iterateQuests = iterateQuests + numberActiveQuestInfo
		questIndex = questIndex + 1
	end
	for index, questInformation in ipairs( EMA.gossipQuests ) do
		if questInformation.type == "available" then
			SelectGossipAvailableQuest( questInformation.index )
		end
		-- If this is an active quest...
		if questInformation.type == "active" then
			-- If this quest has been completed...
			if questInformation.isComplete then
				-- Complete it.
				SelectGossipActiveQuest( questInformation.index )
			end
		end			
	end

end

function EMA:CanAutomateAutoSelectAndComplete()
	if EMA.db.overrideQuestAutoSelectAndComplete == true then
		if IsShiftKeyDown() then
		   return false
		else
		   return true
		end
	end
	return true
 end

function EMA:GOSSIP_SHOW()
	if EMA.db.allAutoSelectQuests == true and EMA:CanAutomateAutoSelectAndComplete() == true then
        EMA:ChurnNpcGossip()
	end
end

function EMA:QUEST_GREETING()
	if EMA.db.allAutoSelectQuests == true and EMA:CanAutomateAutoSelectAndComplete() == true then
		EMA:ChurnNpcGossip()
	end
end

function EMA:QUEST_PROGRESS()
	if EMA.db.allAutoSelectQuests == true and EMA:CanAutomateAutoSelectAndComplete() == true then
		if IsQuestCompletable() then
			
			if QuestFrame:IsShown() == true then
				EMA.isInternalCommand = true
				CompleteQuest()
				EMA.isInternalCommand = false
			else
				EMA:Print( "NO QUEST PAGE CAN NOT HAND IN" ) 
			end		
		end
	end
end

function EMA:SelectGossipOption( gossipIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		if EMA.isInternalCommand == false then
            EMA:DebugMessage( "SelectGossipOption" )
			EMA:EMASendCommandToTeam( EMA.COMMAND_SELECT_GOSSIP_OPTION, gossipIndex )
		end
	end		
end

function EMA:DoSelectGossipOption( sender, gossipIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		EMA.isInternalCommand = true
        EMA:DebugMessage( "DoSelectGossipOption" )
		SelectGossipOption( gossipIndex )
		EMA.isInternalCommand = false
	end		
end

function EMA:SelectGossipActiveQuest( gossipIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		if EMA.isInternalCommand == false then
            EMA:DebugMessage( "SelectGossipActiveQuest" )
			EMA:EMASendCommandToTeam( EMA.COMMAND_SELECT_GOSSIP_ACTIVE_QUEST, gossipIndex )		
		end
	end		
end

function EMA:DoSelectGossipActiveQuest( sender, gossipIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		EMA.isInternalCommand = true
        EMA:DebugMessage( "DoSelectGossipActiveQuest" )
		SelectGossipActiveQuest( gossipIndex )
		EMA.isInternalCommand = false
	end
end

function EMA:SelectGossipAvailableQuest( gossipIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		if EMA.isInternalCommand == false then
            EMA:DebugMessage( "SelectGossipAvailableQuest" )
			EMA:EMASendCommandToTeam( EMA.COMMAND_SELECT_GOSSIP_AVAILABLE_QUEST, gossipIndex )
		end
	end
end

function EMA:DoSelectGossipAvailableQuest( sender, gossipIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		EMA.isInternalCommand = true
        EMA:DebugMessage( "DoSelectGossipAvailableQuest" )
		SelectGossipAvailableQuest( gossipIndex )
		EMA.isInternalCommand = false
	end
end

function EMA:SelectActiveQuest( questIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		if EMA.isInternalCommand == false then
            EMA:DebugMessage( "SelectActiveQuest" )
			EMA:EMASendCommandToTeam( EMA.COMMAND_SELECT_ACTIVE_QUEST, questIndex )
		end
	end		
end

function EMA:DoSelectActiveQuest( sender, questIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		EMA.isInternalCommand = true
        EMA:DebugMessage( "DoSelectActiveQuest" )
		SelectActiveQuest( questIndex )
		EMA.isInternalCommand = false
	end
end

function EMA:SelectAvailableQuest( questIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then	
		if EMA.isInternalCommand == false then
            EMA:DebugMessage( "SelectAvailableQuest" )
			EMA:EMASendCommandToTeam( EMA.COMMAND_SELECT_AVAILABLE_QUEST, questIndex )
		end
	end		
end

function EMA:DoSelectAvailableQuest( sender, questIndex )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		EMA.isInternalCommand = true
        EMA:DebugMessage( "DoSelectAvailableQuest" )
		SelectAvailableQuest( questIndex )
		EMA.isInternalCommand = false
	end
end

function EMA:QUEST_FINISHED(...)
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		if EMA.isInternalCommand == false then
			--EMA:Print( "DeclineQuest" )           
			EMA:DebugMessage( "DeclineQuest" )
			EMA:ScheduleTimer("EMASendCommandToTeam", 0.5, EMA.COMMAND_DECLINE_QUEST )
		end
	end		
end

function EMA:DoDeclineQuest( sender )
	if EMA.db.mirrorMasterQuestSelectionAndDeclining == true then
		--EMA:Print("DoDeclineQuest", sender )
		EMA.isInternalCommand = true
        EMA:DebugMessage( "DoDeclineQuest" )
		HideUIPanel(QuestFrame)
		EMA.isInternalCommand = false
	end
end

-------------------------------------------------------------------------------------------------------------
-- NPC QUEST PROCESSING - COMPLETING
-------------------------------------------------------------------------------------------------------------

function EMA:CompleteQuest()  
	if EMA.db.enableAutoQuestCompletion == true then
		if EMA.isInternalCommand == false then
            EMA:DebugMessage( "CompleteQuest" )
			EMA:EMASendCommandToTeam( EMA.COMMAND_COMPLETE_QUEST )
		end
	end
end

function EMA:DoCompleteQuest( sender )
	if EMA.db.enableAutoQuestCompletion == true then
		EMA.isInternalCommand = true
        EMA:DebugMessage( "DoCompleteQuest" )
		CompleteQuest()
		EMA.isInternalCommand = false
	end	
end

function EMA:QUEST_COMPLETE()
    EMA:DebugMessage( "QUEST_COMPLETE" )
	if EMA.db.enableAutoQuestCompletion == true then
		if EMA.db.hasChoiceAquireBestQuestRewardForCharacter == true then
			EMA:ChooseBestRewardForCharacter()
		elseif (EMA.db.hasChoiceAquireBestQuestRewardForCharacter == true) and (GetNumQuestChoices() > 1) then
			local bestQuestItemIndex = nil
			if bestQuestItemIndex ~= nil and bestQuestItemIndex > 0 then
				local questItemChoice = _G["QuestInfoItem"..bestQuestItemIndex]
				QuestInfoItem_OnClick( questItemChoice )
				QuestInfoFrame.itemChoice = bestQuestItemIndex
				if EMA.db.hasChoiceAquireBestQuestRewardForCharacterAndGet == true then
					GetQuestReward( bestQuestItemIndex )
				end
			end
		elseif (EMA.db.noChoiceAllAutoCompleteQuest == true) and (GetNumQuestChoices() <= 1) then
			GetQuestReward( GetNumQuestChoices() )
		end		
	end
end


function EMA:QUEST_FAIL( event, message, ... )
	--EMA:Print("QUEST_FAIL", message )
	local questName = GetTitleText()
	if questName ~= nil then
		local questInvFull = string.format( ERR_QUEST_FAILED_BAG_FULL_S, questName ) 
		--EMA:Print("A", questInvFull )
		if  message == questInvFull  then
			--EMA:Print("test")
			EMA:EMASendMessageToTeam( EMA.db.warningArea, L["INVENTORY_IS_FULL_CAN_NOT_HAND_IN_QUEST"]( questName ), false )
		end
	end	
end

-------------------------------------------------------------------------------------------------------------
-- IN THE FIELD QUEST PROCESSING - COMPLETING
-------------------------------------------------------------------------------------------------------------

function EMA:ShowQuestComplete( questIndex )
    EMA:DebugMessage( "ShowQuestComplete" )
	if EMA.db.enableAutoQuestCompletion == false then
		return
	end
	if EMA.isInternalCommand == true then
		return
	end
	local questName = select( 1, GetQuestLogTitle( questIndex ) )
	EMA:EMASendCommandToTeam( EMA.COMMAND_LOG_COMPLETE_QUEST, questName )
end

function EMA:DoShowQuestComplete( sender, questName )
    EMA:DebugMessage( "DoShowQuestComplete" )
	if EMA.db.enableAutoQuestCompletion == false then
		return
	end
	EMA.isInternalCommand = true
	local questIndex = EMA:GetQuestLogIndexByName( questName )
	if questIndex ~= 0 then
		ShowQuestComplete( questIndex )
	end
	EMA.isInternalCommand = false	
end

-------------------------------------------------------------------------------------------------------------
-- NPC QUEST PROCESSING - REWARDS
-------------------------------------------------------------------------------------------------------------

function EMA:CheckForOverrideAndChooseQuestReward( questIndex )
	-- Yes, override if minion has reward selected?
	if (EMA.db.hasChoiceOverrideUseSlaveRewardSelected == true) and (QuestInfoFrame.itemChoice > 0) then
		-- Yes, choose minions reward.
		GetQuestReward( QuestInfoFrame.itemChoice )
	else
		-- No, choose masters reward.
		GetQuestReward( questIndex )
	end
end

function EMA:CheckForOverrideAndDoNotChooseQuestReward( questIndex )
	-- Yes, override if minion has reward selected?
	if QuestInfoFrame.itemChoice ~= nil then
		if (EMA.db.hasChoiceOverrideUseSlaveRewardSelected == true) and (QuestInfoFrame.itemChoice > 0) then
			-- Yes, choose minions reward.
			GetQuestReward( QuestInfoFrame.itemChoice )
		end
	end
end

function EMA:AreCorrectConditionalKeysPressed()	
	local failTest = false
	if EMA.db.hasChoiceCtrlKeyModifier == true and not IsControlKeyDown() then
		failTest = true
	end
	if EMA.db.hasChoiceShiftKeyModifier == true and not IsShiftKeyDown() then
		failTest = true
	end
	if EMA.db.hasChoiceAltKeyModifier == true and not IsAltKeyDown() then
		failTest = true
	end
	return not failTest
end

function EMA:GetQuestReward( questIndex )
	if EMA.db.enableAutoQuestCompletion == true then
		if (EMA.db.noChoiceSlaveCompleteQuestWithMaster == true) or (EMA.db.hasChoiceSlaveCompleteQuestWithMaster == true) or (EMA.db.hasChoiceAquireBestQuestRewardForCharacter == true) then
			if EMA.isInternalCommand == false then
                EMA:DebugMessage( "GetQuestReward" )
				EMA:EMASendCommandToTeam( EMA.COMMAND_CHOOSE_QUEST_REWARD, questIndex, EMA:AreCorrectConditionalKeysPressed(), EMA.db.hasChoiceAquireBestQuestRewardForCharacter )
			end
		end
	end		
end

function EMA:DoChooseQuestReward( sender, questIndex, modifierKeysPressed, rewardPickedAlready )
	local numberOfQuestRewards = GetNumQuestChoices()
	if EMA.db.enableAutoQuestCompletion == true then
		if (EMA.db.noChoiceSlaveCompleteQuestWithMaster == true) or (EMA.db.hasChoiceSlaveCompleteQuestWithMaster == true) or (EMA.db.hasChoiceAquireBestQuestRewardForCharacter == true) then
			EMA.isInternalCommand = true
            EMA:DebugMessage( "DoChooseQuestReward" )
            EMA:DebugMessage( "Quest has ", numberOfQuestRewards, " reward choices." )
			-- How many reward choices does this quest have?
			if numberOfQuestRewards <= 1 then
				-- One or less.
				if EMA.db.noChoiceSlaveCompleteQuestWithMaster == true then
					QuestInfoFrame.itemChoice = 1
					--GetQuestReward( 1 )
					GetQuestReward( QuestInfoFrame.itemChoice )
				end
			else
				-- More than one.
				if EMA.db.hasChoiceSlaveCompleteQuestWithMaster == true then
					-- Choose same as master?
					if EMA.db.hasChoiceSlaveChooseSameRewardAsMaster == true then
						EMA:CheckForOverrideAndChooseQuestReward( questIndex )
					-- Choose same as master, conditional keys?
					elseif EMA.db.hasChoiceSlaveRewardChoiceModifierConditional == true then
						if modifierKeysPressed == true then
							EMA:CheckForOverrideAndChooseQuestReward( questIndex )
						else
							EMA:CheckForOverrideAndDoNotChooseQuestReward( questIndex )
						end
					end
				end
				if (EMA.db.hasChoiceAquireBestQuestRewardForCharacter == true) and (rewardPickedAlready == true) then
					if QuestInfoFrame.itemChoice > 0 then
						-- Yes, choose minions reward.
						GetQuestReward( QuestInfoFrame.itemChoice )
					end
				end
			end
			EMA.isInternalCommand = false
		end
	end
end

function EMA:ChooseBestRewardForCharacter()
	-- Idea by loop: http://www.dual-boxing.com/showpost.php?p=257610&postcount=1505
	-- Choose the best item for this character, otherwise choose the most valuable to vendor:
	-- Fixed for classic/tbc by ebony
	local numberOfQuestRewards = GetNumQuestChoices()
	local mostValuableQuestItemIndex, mostValuableQuestItemValue, bestQuestItemIndex, bestQuestItemArmorWeight = 1, 0, -1, -1
	local name = nil
	local armorWeights = { Plate = 4, Mail = 2, Leather = 1, Cloth = 0 }    
	-- Yanked this from LibItemUtils; sucks that we need this lookup table, but GetItemInfo only 
	-- returns an equipment location, which must first be converted to a slot value that GetInventoryItemLink understands:
	local equipmentSlotLookup = {
		INVTYPE_HEAD = {"HeadSlot", nil},
		INVTYPE_NECK = {"NeckSlot", nil},
		INVTYPE_SHOULDER = {"ShoulderSlot", nil},
		INVTYPE_CLOAK = {"BackSlot", nil},
		INVTYPE_CHEST = {"ChestSlot", nil},
		INVTYPE_WRIST = {"WristSlot", nil},
		INVTYPE_HAND = {"HandsSlot", nil},
		INVTYPE_WAIST = {"WaistSlot", nil},
		INVTYPE_LEGS = {"LegsSlot", nil},
		INVTYPE_FEET = {"FeetSlot", nil},
		INVTYPE_SHIELD = {"SecondaryHandSlot", nil},
		INVTYPE_ROBE = {"ChestSlot", nil},
		INVTYPE_2HWEAPON = {"MainHandSlot", "SecondaryHandSlot"},
		INVTYPE_WEAPONMAINHAND = {"MainHandSlot", nil},
		INVTYPE_WEAPONOFFHAND = {"SecondaryHandSlot", "MainHandSlot"},
		INVTYPE_WEAPON = {"MainHandSlot","SecondaryHandSlot"},
		INVTYPE_THROWN = {"RangedSlot", nil},
		INVTYPE_RANGED = {"RangedSlot", nil},
		INVTYPE_RANGEDRIGHT = {"RangedSlot", nil},
		INVTYPE_FINGER = {"Finger0Slot", "Finger1Slot"},
		INVTYPE_HOLDABLE = {"SecondaryHandSlot", "MainHandSlot"},
		INVTYPE_TRINKET = {"Trinket0Slot", "Trinket1Slot"}
	} 
                        
	for questItemIndex = 1, numberOfQuestRewards do
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(GetQuestItemLink("choice", questItemIndex))
		--EMA:Print("PickReward", itemName, itemRarity )
		-- If there is a rare item as a reward, bail and let the player choose.
		if itemRarity >= 3 then
			return
		end
		local itemId = itemLink:match("|Hitem:(%d+)")
		local isItemEquippable = IsEquippableItem(itemId)
		local _, _, _, _, isItemUsable = GetQuestItemInfo("choice", questItemIndex)
                
		if itemSellPrice > mostValuableQuestItemValue then
			-- Keep track of which item is most valuable:
			mostValuableQuestItemIndex = questItemIndex
			mostValuableQuestItemValue = itemSellPrice
		end
        --EMA:Print("Sell", itemSellPrice,mostValuableQuestItemValue )               
		--EMA:Print("testcanuse", isItemEquippable,isItemUsable )
		if isItemEquippable == true and isItemUsable ~= nil then
			-- NPC is offering us an item we can actually wear:
			local currentEquippedItemLinksInSlots = {}
			local currentWorstEquippedItemInSlot = nil
			
			-- Figure out what we already have equipped:
			for _, itemSlot in ipairs(equipmentSlotLookup[itemEquipLoc]) do 
				if itemSlot ~= nil then
					local currentEquippedItemLinkInSlot = GetInventoryItemLink("player", GetInventorySlotInfo(itemSlot))
					
					if currentEquippedItemLinkInSlot == nil then
						-- Of the n item slots available, at least one of them has nothing equipped. Ergo, it is the worst:
						currentWorstEquippedItemInSlot = nil
						break
					else
						-- There's an item in this slot, get some details on it:
						local _, _, _, currentEquippedItemLevelInSlot, _, _, currentEquippedItemSubTypeInSlot = GetItemInfo(currentEquippedItemLinkInSlot)
						
						-- We haven't yet determined the worst item, or the item we see in this slot happens to be worse than the other item
						-- we saw in this partner slot (ie. a ring in one slot is worse than a ring in another slot):
						if currentWorstEquippedItemInSlot == nil or currentWorstEquippedItemInSlot.itemLevel > currentEquippedItemLevelInSlot then
							currentWorstEquippedItemInSlot = { 
								itemLink = currentEquippedItemLinkInSlot,
								itemLevel = currentEquippedItemLevelInSlot,
								itemSubType = currentEquippedItemSubTypeInSlot
							}
						end
					end
				end
			end

			if currentWorstEquippedItemInSlot == nil then
				-- We're not even wearing an item in this slot, and the vendor has something we can use, take it:
				bestQuestItemIndex = questItemIndex
			else
				if itemLevel > currentWorstEquippedItemInSlot.itemLevel then
					-- NPC is providing us with an better item than what we currently have in this slot:
					if armorWeights[itemSubType] ~= nil then
						-- Armor subtype is one which we care to select based on some priority order:
						if armorWeights[itemSubType] > bestQuestItemArmorWeight then
							-- If this piece of armor is a better subtype (ie. Plate is better than Cloth if we can wear it):
							bestQuestItemIndex = questItemIndex
							bestQuestItemArmorWeight = armorWeights[itemSubType]
						end
					elseif currentWorstEquippedItemInSlot.itemSubType == itemSubType then
						-- This isn't a piece of armor (ie. might be a weapon) - only take it if it's the same 
						-- subtype as the item we are already wearing (if we're wearing a staff, and NPC offers
						--  a staff and a dagger, we'll take the staff):
						bestQuestItemIndex = questItemIndex
						bestQuestItemArmorWeight = -1
					end
				end
			end
		end
	end
	if bestQuestItemIndex < 0 then
		-- If we haven't determined an item upgrade by now, just choose the one that we can vendor for the most gold:
		bestQuestItemIndex = mostValuableQuestItemIndex
	end
	-- DebugCode
		local _, name = GetItemInfo(GetQuestItemLink("choice", bestQuestItemIndex) )
	EMA:Print("PickQuestReward", bestQuestItemIndex, name )
	-- DoStuff
	--GetQuestReward(bestQuestItemIndex)

end

-------------------------------------------------------------------------------------------------------------
-- NPC QUEST PROCESSING - ACCEPTING
-------------------------------------------------------------------------------------------------------------

function EMA:QUEST_ACCEPTED( ... )
	local event, questIndex =  ...
	if EMA.db.acceptQuests == true then
		if EMA.db.masterAutoShareQuestOnAccept == true then	
			if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
				if EMA.isInternalCommand == false then
					SelectQuestLogEntry( questIndex )
						if GetQuestLogPushable() and GetNumSubgroupMembers() > 0 then
							EMA:EMASendMessageToTeam( EMA.db.messageArea, "Pushing newly accepted quest.", false )
							QuestLogPushQuest()
						end
				end	
			end
		end
	end
end

function EMA:AcceptQuest()
	if EMA.db.acceptQuests == true then
		if EMA.db.slaveMirrorMasterAccept == true then
			if EMA.isInternalCommand == false then
                EMA:DebugMessage( "AcceptQuest" )
				EMA:EMASendCommandToTeam( EMA.COMMAND_ACCEPT_QUEST )
			end		
		end
	end
end

function EMA:DoAcceptQuest( sender )
	if EMA.db.acceptQuests == true and EMA.db.slaveMirrorMasterAccept == true then
	local questName = GetTitleText()
	local questIndex = EMA:GetQuestLogIndexByName( questName )
	
		--Only works if the quest frame is open. Stops sending a blank quest. Tell the team a char not got the quest window open???? <<<<<< TODO
		if QuestFrame:IsShown() == true then
			--EMA:Print( "DoAcceptQuest", questName, questIndex, sender) 
			EMA.isInternalCommand = true
			EMA:DebugMessage( "DoAcceptQuest" )
			EMA:EMASendMessageToTeam( EMA.db.messageArea, L["ACCEPTED_QUEST_QN"]( questName ), false )
			AcceptQuest()
			HideUIPanel( QuestFrame )
			AcceptQuest()
			EMA.isInternalCommand = false
		end		
	end
end

-- Auto quest magic!
function EMA:AcknowledgeAutoAcceptQuest()
	if EMA.db.acceptQuests == true then
		if EMA.db.slaveMirrorMasterAccept == true then
			if EMA.isInternalCommand == false then
                EMA:DebugMessage( "MagicAutoAcceptQuestGrrrr", QuestGetAutoAccept() )
				EMA:EMASendCommandToTeam( EMA.COMMAND_ACCEPT_QUEST_FAKE )
			end	
		end
	end
end

function EMA:DoMagicAutoAcceptQuestGrrrr()
	if EMA.db.acceptQuests == true and EMA.db.slaveMirrorMasterAccept == true and QuestFrame:IsVisible() then
	local questIndex = EMA:GetQuestLogIndexByName( questName )
		EMA.isInternalCommand = true
		EMA:DebugMessage( "DoMagicAutoAcceptQuestGrrrr" )
		EMA:EMASendMessageToTeam( EMA.db.messageArea, L["AUTO_ACCEPTED_PICKUPQUEST_QN"]( GetTitleText() ), false )
	--	AcknowledgeAutoAcceptQuest()
		HideUIPanel( QuestFrame )
		EMA.isInternalCommand = false
	end
end

-------------------------------------------------------------------------------------------------------------
-- QUEST PROCESSING - AUTO ACCEPTING
-------------------------------------------------------------------------------------------------------------

--TODO: this could do with some work with Friends.
function EMA:CanAutoAcceptSharedQuestFromPlayer()
	local canAccept = false
	if EMA.db.allAcceptAnyQuest == true then
		canAccept = true
	elseif EMA.db.onlyAcceptQuestsFrom == true then
		local questSourceName, questSourceRealm = UnitName( "questnpc" )
		--EMA:Print("test", questSourceName, questSourceRealm, canAccept )
		local character = EMAUtilities:AddRealmToNameIfNotNil( questSourceName, questSourceRealm )
		if EMA.db.acceptFromTeam == true then	
			if EMAApi.IsCharacterInTeam( character ) == true then
				canAccept = true
			end
		end
		if EMA.db.acceptFromFriends == true then	
			for friendIndex = 1, GetNumFriends() do
				local friendName = GetFriendInfo( friendIndex )
				if questSourceName == friendName then
					canAccept = true
					break
				end
			end	
		end
		if EMA.db.acceptFromParty == true then	
			if UnitInParty( "questnpc" ) then
				EMA:DebugMessage( "test" )
				canAccept = true
			end
		end
		if EMA.db.acceptFromRaid == true then	
			if UnitInRaid( "questnpc" ) then
				canAccept = true
			end
		end
		if EMA.db.acceptFromGuild == true then
			if UnitIsInMyGuild( "questnpc" ) then
				canAccept = true
			end
		end			
	end
	return canAccept
end

function EMA:QUEST_DETAIL()
    EMA:DebugMessage( "QUEST_DETAIL" )
	if EMA.db.acceptQuests == true then
		-- Who is this quest from.
		if UnitIsPlayer( "npc" ) then
			-- Quest is shared from a player.
			if EMA:CanAutoAcceptSharedQuestFromPlayer() == true then		
					EMA.isInternalCommand = true
					EMA:EMASendMessageToTeam( EMA.db.messageArea, L["AUTOMATICALLY_ACCEPTED_QUEST"]( GetTitleText() ), false )
					AcceptQuest()
					EMA.isInternalCommand = false	
			end			
		else
			-- Quest is from an NPC.
			if (EMA.db.allAcceptAnyQuest == true) or ((EMA.db.onlyAcceptQuestsFrom == true) and (EMA.db.acceptFromNpc == true)) then		
				EMA.isInternalCommand = true
				--EMA:DebugMessage( "QUEST_DETAIL - auto accept is: ", QuestGetAutoAccept() )
				EMA:EMASendMessageToTeam( EMA.db.messageArea, L["AUTOMATICALLY_ACCEPTED_QUEST"]( GetTitleText() ), false )
				AcceptQuest()
				HideUIPanel( QuestFrame )
				EMA.isInternalCommand = false
			end
		end
	end	
end

-------------------------------------------------------------------------------------------------------------
-- EMA QUEST CONTEXT MENU
-------------------------------------------------------------------------------------------------------------

function EMA:QuestWatch_Update()
	local lastQuestIndex = GetQuestLogSelection()
	local title, _, _, _, _, _, _, questID = GetQuestLogTitle(lastQuestIndex)
	--EMA:Print("test", questID )
	if ( IsQuestWatched(lastQuestIndex) ) then
		--EMA:Print("TrackingQuest")
		EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, questID, title, true )	
	else
		--EMA:Print("UnTrackQuest")
		EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, questID, title, false )	
	end
end

local function EMAApiAbandonQuests(questID, questText)
	--EMA:Print(questID, questText)
	title = questText
	local data = {}
	data.questID = questID
	data.title = questText
	StaticPopup_Hide( "ABANDON_QUEST" )
	StaticPopup_Hide( "ABANDON_QUEST_WITH_ITEMS" )	
	StaticPopup_Show( "EMAQUEST_ABANDON_ALL_TOONS", title, nil, data )
end

local function EMAApiUnTrackQuests(questID, questText)
	--EMA:Print("test", questID, questText)
	EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, questID, questText, false )
end

local function EMAApiTrackAllQuests()
	EMA:DoTrackAllQuestsFromThisToon()
	EMA:ScheduleTimer("EMASendCommandToTeam", 1, EMA.COMMAND_TRACK_ALL_QUESTS)
end	


function EMA:AbandonQuest ()                      
	if EMAApi.GetTeamListMaximumOrderOnline() > 1 then	
		local lastQuestIndex = GetQuestLogSelection()
		local _, _, _, _, _, _, _, questID = GetQuestLogTitle(lastQuestIndex)
		--EMA:Print("SetAbandonQuest", lastQuestIndex, questID)
		title = GetAbandonQuestName()
		local data = {}
		data.questID = questID
		data.title = title
		StaticPopup_Show( "EMAQUEST_ABANDON_ALL_TOONS", title, nil, data )
	end	
	
end

function EMA:QuestObjectiveTracker_UntrackQuest(dropDownButton, questID)
	--EMA:Print("test", questID)
	EMA:QuestMapQuestOptions_TrackQuest(questID)
end

function EMA:QuestMapQuestOptions_TrackQuest(questID)
	if EMAApi.GetTeamListMaximumOrderOnline() > 1 then
		--EMA:Print("test", questID)
		local questLogIndex = GetQuestLogIndexByID(questID)
		local title = GetQuestLogTitle( questLogIndex )
		local data = {}
		data.questID = questID
		data.title = title
		if ( IsQuestWatched(questLogIndex) ) then
			--EMA:Print("TrackingQuest")
			StaticPopup_Show( "EMA_QUEST_TRACK_ALL_TOONS", title, nil, data )
		else
			--EMA:Print("UnTrackQuest")
			StaticPopup_Show( "EMA_QUEST_UNTRACK_ALL_TOONS", title, nil, data )	
		end
	end			
end

function EMA:QuestMapQuestOptions_EMA_DoQuestTrack( sender, questID, title, track )
	--EMA:Print("test1.5", sender, questID, title, track)
	local questLogIndex = GetQuestLogIndexByID( questID )
	if questLogIndex ~= 0 then
		if track then
			isInternalCommand = true
			EMA:EMADoQuest_TrackQuest( questID, questLogIndex )
		else
			isInternalCommand = true
			EMA:EMADoQuest_UnTrackQuest( questID, questLogIndex )
		end
	else
	--	EMA:EMASendMessageToTeam( EMA.db.messageArea, L["QUESTLOG_DO_NOT_HAVE_QUEST"]( title ), false )
	end		
end

function EMA:EMADoQuest_TrackQuest(questID, questLogIndex)
	--EMA:Print("test", questID, questLogIndex )
	if EMA.isInternalCommand == false then
		if ( not IsQuestWatched(questID) ) then
			AddQuestWatch(questLogIndex, true)
			local _, _, _, tocversion = GetBuildInfo()
			if tocversion >= 30000 and tocversion <= 40000 then
				AddQuestWatch( questIndex )
			else	
				AutoQuestWatch_Insert(questLogIndex, QUEST_WATCH_NO_EXPIRE)
				QuestWatch_Update()
			end
		end
		local _, _, _, tocversion = GetBuildInfo()
		if tocversion <= 30000 then
			QuestLog_SetSelection(questLogIndex)
			QuestLog_Update()
		end	
	end	
end


function EMA:EMADoQuest_UnTrackQuest(questID, questLogIndex)
	--EMA:Print("test2", questID, questLogIndex )
	if ( IsQuestWatched(questLogIndex) ) then
		local _, _, _, tocversion = GetBuildInfo()
		if tocversion >= 30000 and tocversion <= 40000 then
			RemoveQuestWatch( questIndex )
		else
			RemoveQuestWatch(questLogIndex)
			QuestWatch_Update()
		end	
	end
	local _, _, _, tocversion = GetBuildInfo()
	if tocversion <= 30000 then
		QuestLog_SetSelection(questLogIndex)
		QuestLog_Update()
	end	
end

function EMA:QuestMapQuestOptions_EMA_DoAbandonQuest( sender, questID, title )
	local questLogIndex = GetQuestLogIndexByID( questID )
	if questLogIndex ~= 0 then
		EMA:Unhook( "AbandonQuest" )
		local lastQuestIndex = GetQuestLogSelection();
		SelectQuestLogEntry(GetQuestLogIndexByID(questID));
		SetAbandonQuest();
		AbandonQuest();
		SelectQuestLogEntry(lastQuestIndex);	
		EMA:EMASendMessageToTeam( EMA.db.messageArea, L["QUESTLOG_HAVE_ABANDONED_QUEST"]( title ), false )
		EMA:SecureHook( "AbandonQuest" )
	end		
end

-- EMA ALL menu at the bottom of quest WorldMap Quest Log


function EMA:CreateEMAMiniQuestLogFrame()
    EMAMiniQuestLogFrame = CreateFrame( "Frame", "EMAMiniQuestLogFrame", QuestLogFrame, BackdropTemplateMixin and "BackdropTemplate" or nil )
    local frame = EMAMiniQuestLogFrame
	frame:SetWidth( 270 )
	frame:SetHeight( 80 )
	frame:SetFrameStrata( "HIGH" )
	frame:SetToplevel( true )
	frame:SetClampedToScreen( true )
	frame:EnableMouse( true )
	frame:SetMovable( true )	
	frame:ClearAllPoints()
	if IsAddOnLoaded("ElvUI" ) == true then  
		frame:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 40, -80)
	else
		local _, _, _, tocversion = GetBuildInfo()
		if tocversion >= 30000 and tocversion <= 40000 then
			frame:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 10 , -70 )--40, -30)
		else
			frame:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 40, -30)
		end	
	end	
		frame:SetBackdrop( {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 15, edgeSize = 15, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	} )
	table.insert( UISpecialFrames, "EMAQuestLogWindowFrame" )
	-- Single Track Button
	local singleTrackButton = CreateFrame( "Button", "singleTrackButton", frame, "UIPanelButtonTemplate" )
	singleTrackButton:SetScript( "OnClick", function() local lastQuestIndex = GetQuestLogSelection() local title, _, _, _, _, _, _, questID = GetQuestLogTitle(lastQuestIndex) EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, questID, title, true )  end )
	singleTrackButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 30 , -10)
	singleTrackButton:SetHeight( 20 )
	singleTrackButton:SetWidth( 100 )
	singleTrackButton:SetText( L["TRACK_SINGLE_QUEST"] )	
	singleTrackButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(trackButton, true, L["TRACK_SINGLE_QUEST_TOOLTIP"]) end)
	singleTrackButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	singleTrackQuestLogWindowAbandonFrameButton = singleTrackButton
	-- Single unTrack Button
	local singleUnTrackButton = CreateFrame( "Button", "singleUnTrackButton", frame, "UIPanelButtonTemplate" )
	singleUnTrackButton:SetScript( "OnClick", function() local lastQuestIndex = GetQuestLogSelection() local title, _, _, _, _, _, _, questID = GetQuestLogTitle(lastQuestIndex) EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, questID, title, false )  end )
	singleUnTrackButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 140 , -10)
	singleUnTrackButton:SetHeight( 20 )
	singleUnTrackButton:SetWidth( 120 )
	singleUnTrackButton:SetText( L["UNTRACK_SINGLE_QUEST"] )	
	singleUnTrackButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(trackButton, true, L["UNTRACK_SINGLE_QUEST_TOOLTIP"]) end)
	singleUnTrackButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	singleUnTrackQuestLogWindowAbandonFrameButton = singleUnTrackButton
	-- abandon ALL button
	local abandonButton = CreateFrame( "Button", "abandonButton", frame, "UIPanelButtonTemplate" )
	abandonButton:SetScript( "OnClick", function()  StaticPopup_Show("EMA_ABANDON_ALL_TOON_QUEST") end )
	abandonButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 10 , -30)
	abandonButton:SetHeight( 20 )
	abandonButton:SetWidth( 150 )
	abandonButton:SetText( L["ABANDON_ALL"] )	
	abandonButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(trackButton, true, L["ABANDON_ALL_TOOLTIP"]) end)
	abandonButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	abandonQuestLogWindowAbandonFrameButton = abandonButton
	-- Share All Button
	local shareButton = CreateFrame( "Button", "shareButton", frame, "UIPanelButtonTemplate" )
	shareButton:SetScript( "OnClick", function()  EMA:DoShareAllQuestsFromAllToons() end )
	shareButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 160, -30)
	shareButton:SetHeight( 20 )
	shareButton:SetWidth( 100 )
	shareButton:SetText( L["SHARE_ALL"] )	
	shareButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(shareButton, true, L["SHARE_ALL_TOOLTIP"]) end)
	shareButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	shareQuestLogWindowFrameShareButton = shareButton
	--Track All Button
	local trackButton = CreateFrame( "Button", "trackButton", frame, "UIPanelButtonTemplate" )
	trackButton:SetScript( "OnClick", function()  EMA:DoTrackAllQuestsFromAllToons() end )
	trackButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 35, -50)
	trackButton:SetHeight( 20 )
	trackButton:SetWidth( 100 )
	trackButton:SetText( L["TRACK_ALL"] )	
	trackButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(trackButton, true, L["TRACK_ALL_TOOLTIP"]) end)
	trackButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	EMAQuestLogWindowFrameTrackButton = trackButton
	-- Untrack All
	local unTrackButton = CreateFrame( "Button", "unTrackButton", frame, "UIPanelButtonTemplate" )
	unTrackButton:SetScript( "OnClick", function()  EMA:DoUnTrackAllQuestsFromAllToons() end )
	unTrackButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 160, -50)
	unTrackButton:SetHeight( 20 )
	unTrackButton:SetWidth( 100 )
	unTrackButton:SetText( L["UNTRACK_ALL"] )	
	unTrackButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(trackButton, true, L["UNTRACK_ALL_TOOLTIP"]) end)
	unTrackButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	EMAQuestLogWindowFrameUnTrackButton = unTrackButton
end


function EMA:ShowTooltip(frame, show, text)
	if show then
		GameTooltip:SetOwner(frame, "ANCHOR_TOP")
		GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT", 16, 0)
		GameTooltip:ClearLines()
		GameTooltip:AddLine( text , 1, 0.82, 0, 1)
		GameTooltip:Show()
	else
	GameTooltip:Hide()
	end
end

function EMA:DoAbandonAllQuestsFromAllToons()
	EMA:EMASendMessageToTeam( EMA.db.messageArea, L["ABANDONING_ALLQUEST"], false )
	EMA:DoAbandonAllQuestsFromThisToon()	
	EMA:ScheduleTimer("EMASendCommandToTeam" , 2, EMA.COMMAND_ABANDON_ALL_QUESTS)
end

function EMA:DoAbandonAllQuestsFromThisToon()
	EMA.iterateQuests = 0
	EMA:IterateQuests("AbandonNextQuest", 0.5)
end

function EMA.AbandonNextQuest()
	local title, isHeader, questID = EMA:GetRelevantQuestInfo(EMA.iterateQuests)
	if isHeader == false and questID ~= 0 then
		local canAbandon = CanAbandonQuest(questID)
		if canAbandon then
			EMA:EMASendCommandToTeam( EMA.COMMAND_ABANDON_QUEST, questID, title)
			if (EMA.iterateQuests ~= GetNumQuestLogEntries()) then
				-- decrement quest count as we have removed one if not last quest
				EMA.iterateQuests = EMA.iterateQuests - 1
			end
		end
	end
	EMA:IterateQuests("AbandonNextQuest", 0.5)
end

function EMA.DoShareAllQuestsFromAllToons()
	EMA:EMASendMessageToTeam( EMA.db.messageArea, L["SHARING_QUEST_TO_ALLMINIONS"], false )
	EMA:DoShareAllQuestsFromThisToon()	
	EMA:ScheduleTimer("EMASendCommandToTeam" , 2,  EMA.COMMAND_SHARE_ALL_QUESTS)
end

function EMA.DoShareAllQuestsFromThisToon()
	EMA.iterateQuests = 0
	EMA:IterateQuests("ShareNextQuest", 1)
end

function EMA.ShareNextQuest()
	local title, isHeader, questID = EMA:GetRelevantQuestInfo(EMA.iterateQuests)
	if GetQuestLogPushable() then
		if isHeader == false and questID ~= 0 then
			EMA:Print("test", questID )
			QuestLogPushQuest()
		end
	end	
	EMA:IterateQuests("ShareNextQuest", 1)
end


function EMA:DoTrackAllQuestsFromAllToons()
	EMA:EMASendMessageToTeam( EMA.db.messageArea, L["TRACKING_QUEST_TO_ALLMINIONS"], false )
	EMA:DoTrackAllQuestsFromThisToon()
	EMA:ScheduleTimer("EMASendCommandToTeam", 1, EMA.COMMAND_TRACK_ALL_QUESTS)
end

function EMA:DoTrackAllQuestsFromThisToon()
	EMA.iterateQuests = 0
	EMA:IterateQuests("TrackNextQuest", 0.5)
end

function EMA.TrackNextQuest()

	local title, isHeader, questID = EMA:GetRelevantQuestInfo(EMA.iterateQuests)

	if isHeader == false and questID ~= 0 then
		EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, questID, title, true )
	end

	EMA:IterateQuests("TrackNextQuest", 0.5)
end

function EMA:DoUnTrackAllQuestsFromAllToons()
	EMA:EMASendMessageToTeam( EMA.db.messageArea, L["UNTRACKING_QUESTS_ALLMINIONS"], false )
	EMA:DoUnTrackAllQuestsFromThisToon()
	EMA:ScheduleTimer("EMASendCommandToTeam", 1, EMA.COMMAND_UNTRACK_ALL_QUESTS)
end

function EMA:DoUnTrackAllQuestsFromThisToon()
	EMA.iterateQuests = 0
	EMA:IterateQuests("UnTrackNextQuest", 0.5)
end


function EMA.UnTrackNextQuest()
	local title, isHeader, questID = EMA:GetRelevantQuestInfo(EMA.iterateQuests)
		if isHeader == false and questID ~= 0 then
			EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_TRACK, questID, title, false )
		end
	EMA:IterateQuests("UnTrackNextQuest", 0.5)
end

function EMA:IterateQuests(methodToCall, timer)
	EMA.iterateQuests = EMA.iterateQuests + 1
		if EMA.iterateQuests <= GetNumQuestLogEntries() then
			EMA:ScheduleTimer( methodToCall, timer )
		end
end

function EMA:GetRelevantQuestInfo(questLogIndex)
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle( questLogIndex )
	return title, isHeader, questID
end

function EMA:ToggleFrame( frame )
	if frame == QuestLogFrame then
		EMA:ToggleQuestLog()
	end
end

function EMA:ToggleQuestLog()
	-- This sorts out hooking on L or marcioMenu button
	if EMA.db.showEMAQuestLogWithWoWQuestLog == true then
		if QuestLogFrame:IsVisible() then
			EMA:ToggleShowQuestCommandWindow( true )
		else
			EMA:ToggleShowQuestCommandWindow( false )
		end
	end
end

function EMA:QuestLogFrameHide()
	if EMA.db.showEMAQuestLogWithWoWQuestLog == true then
		EMA:ToggleShowQuestCommandWindow( false )
	end
end

function EMA:ToggleShowQuestCommandWindow( show )
    if show == true then
		EMAMiniQuestLogFrame:Show()
    else
		EMAMiniQuestLogFrame:Hide()
    end
end


-------------------------------------------------------------------------------------------------------------
-- ESCORT QUEST
-------------------------------------------------------------------------------------------------------------

function EMA:QUEST_ACCEPT_CONFIRM( event, senderName, questName )
    EMA:DebugMessage( "QUEST_ACCEPT_CONFIRM" )
	if EMA.db.acceptQuests == true then
		if EMA.db.slaveAutoAcceptEscortQuest == true then
			EMA:EMASendMessageToTeam( EMA.db.messageArea, L["AUTOMATICALLY_ACCEPTED_ESCORT_QUEST"]( questName ), false )
			EMA.isInternalCommand = true
			ConfirmAcceptQuest()
			EMA.isInternalCommand = false
			StaticPopup_Hide( "QUEST_ACCEPT" )
		end
	end	
end

function EMA:GetQuestLogIndexByName( questName )
	for iterateQuests = 1, GetNumQuestLogEntries() do
        local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle( iterateQuests )
		if not isHeader then
			if title == questName then
				return iterateQuests
			end
		end
	end
	return 0
end

function EMA:AutoSelectToggleCommand( info, parameters )
	local toggle, tag = strsplit( " ", parameters )
	if tag ~= nil and tag:trim() ~= "" then
		EMA:EMASendCommandToTeam( EMA.COMMAND_TOGGLE_AUTO_SELECT, toggle, tag )
	else
		EMA:AutoSelectToggle( toggle )
	end	
end

function EMA:DoAutoSelectToggle( sender, toggle, tag )
	if EMAApi.DoesCharacterHaveTag( EMA.characterName, tag ) == true then
		EMA:AutoSelectToggle( toggle )
	end
end

function EMA:AutoSelectToggle( toggle )
	if toggle == L["TOGGLE"] then
		if EMA.db.allAutoSelectQuests == true then
			toggle = L["OFF"]
		else
			toggle = L["ON"]
		end
	end
	if toggle == L["ON"] then
		EMA.db.mirrorMasterQuestSelectionAndDeclining = false
		EMA.db.allAutoSelectQuests = true
	elseif toggle == L["OFF"] then
		EMA.db.mirrorMasterQuestSelectionAndDeclining = true
		EMA.db.allAutoSelectQuests = false
	end
	EMA:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- COMMAND MANAGEMENT
-------------------------------------------------------------------------------------------------------------

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
    EMA:DebugMessage( 'got a command', characterName, commandName, ... )
	if commandName == EMA.COMMAND_TOGGLE_AUTO_SELECT then
		EMA:DoAutoSelectToggle( characterName, ... )
	end
-- Want to action track and abandon command on the same character tat sent the command.
	if commandName == EMA.COMMAND_QUEST_TRACK then
		EMA:QuestMapQuestOptions_EMA_DoQuestTrack( characterName, ... )
	end
	if commandName == EMA.COMMAND_ABANDON_QUEST then		
		EMA:QuestMapQuestOptions_EMA_DoAbandonQuest( characterName, ... )
	end
	 

	 
	 -- If this character sent this command, don't action it.
	if characterName == EMA.characterName then
		return
	end
	if commandName == EMA.COMMAND_UNTRACK_ALL_QUESTS then		
		EMA:DoUnTrackAllQuestsFromThisToon()
	end
	if commandName == EMA.COMMAND_ABANDON_ALL_QUESTS then		
		EMA:DoAbandonAllQuestsFromThisToon()
	end
	if commandName == EMA.COMMAND_TRACK_ALL_QUESTS then		
		EMA:DoTrackAllQuestsFromThisToon()
	end

	if commandName == EMA.COMMAND_SHARE_ALL_QUESTS then		
		EMA:DoShareAllQuestsFromThisToon()
	end
	if commandName == EMA.COMMAND_ACCEPT_QUEST then		
		EMA:DoAcceptQuest( characterName, ...  )
	end			
	if commandName == EMA.COMMAND_SELECT_GOSSIP_OPTION then		
		EMA:DoSelectGossipOption( characterName, ... )
	end
	if commandName == EMA.COMMAND_SELECT_GOSSIP_ACTIVE_QUEST then		
		EMA:DoSelectGossipActiveQuest( characterName, ... )
	end
	if commandName == EMA.COMMAND_SELECT_GOSSIP_AVAILABLE_QUEST then		
		EMA:DoSelectGossipAvailableQuest( characterName, ... )
	end
	if commandName == EMA.COMMAND_SELECT_ACTIVE_QUEST then		
		EMA:DoSelectActiveQuest( characterName, ... )
	end
	if commandName == EMA.COMMAND_SELECT_AVAILABLE_QUEST then		
		EMA:DoSelectAvailableQuest( characterName, ... )
	end
	if commandName == EMA.COMMAND_DECLINE_QUEST then		
		EMA:ScheduleTimer("DoDeclineQuest" , 1, characterName, ... ) 
	end
	if commandName == EMA.COMMAND_COMPLETE_QUEST then		
		EMA:DoCompleteQuest( characterName, ... )
	end
	if commandName == EMA.COMMAND_CHOOSE_QUEST_REWARD then		
		EMA:DoChooseQuestReward( characterName, ... )
	end
	if commandName == EMA.COMMAND_LOG_COMPLETE_QUEST then
		EMA:DoShowQuestComplete( characterName, ... )
	end
	if commandName == EMA.COMMAND_ACCEPT_QUEST_FAKE then
		EMA:DoMagicAutoAcceptQuestGrrrr( characterName, ... )
	end
end

EMAApi.EMAApiAbandonQuest = EMAApiAbandonQuests
EMAApi.EMAApiUnTrackQuest = EMAApiUnTrackQuests
EMAApi.EMAApiTrackAllQuests = EMAApiTrackAllQuests
