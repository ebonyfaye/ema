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
	"QuestWatcher", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)



-- Load libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
EMA.SharedMedia = LibStub( "LibSharedMedia-3.0" )

local EMAQuestMapQuestOptionsDropDown = CreateFrame("Frame", "EMAQuestMapQuestOptionsDropDown", EMAQuestWatcherFrame, "UIDropDownMenuTemplate")

--  Constants and Locale for this module.
EMA.moduleName = "QuestWatcher"
EMA.settingsDatabaseName = "QuestWatcherProfileDB"
EMA.chatCommand = "ema-quest-watcher"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["QUEST"]
EMA.moduleDisplayName = L["TRACKER"]
-- Icon
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\QuestTrackerIcon.tga"
-- order
EMA.moduleOrder = 20


-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		enableQuestWatcher = true,
		watcherFramePoint = "RIGHT",
		watcherFrameRelativePoint = "RIGHT",
		watcherFrameXOffset = 0,
		watcherFrameYOffset = 50,
		watcherFrameAlpha = 1.0,
		watcherFrameScale = 1.0,
		borderStyle = L["BLIZZARD_TOOLTIP"],
		backgroundStyle = L["BLIZZARD_DIALOG_BACKGROUND"],
		watchFontStyle = L["ARIAL_NARROW"],
		watchFontSize = 14,
		hideQuestWatcherInCombat = false,
		enableQuestWatcherOnMasterOnly = false,
		watchFrameBackgroundColourR = 0.0,
		watchFrameBackgroundColourG = 0.0,
		watchFrameBackgroundColourB = 0.0,
		watchFrameBackgroundColourA = 0.0,
		watchFrameBorderColourR = 0.0,
		watchFrameBorderColourG = 0.0,
		watchFrameBorderColourB = 0.0,
		watchFrameBorderColourA = 0.0,
		watcherListLines = 20,
		watcherFrameWidth = 340,
		unlockWatcherFrame = true,
		hideBlizzardWatchFrame = true,
		doNotHideCompletedObjectives = true,
		showCompletedObjectivesAsDone = true,
		hideQuestIfAllComplete = false,
		showFrame = true,
		--messageArea = EMAApi.DefaultMessageArea(),
		--sendProgressChatMessages = false,
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
				usage = "/ema-quest-watcher config",
				get = false,
				set = "",				
			},
			show = {
				type = "input",
				name = L["SHOW_QUEST_WATCHER"],
				desc = L["SHOW_QUEST_WATCHER_HELP"],
				usage = "/ema-quest-watcher show",
				get = false,
				set = "ShowFrameCommand",
			},		
			hide = {
				type = "input",
				name = L["HIDE_QUEST_WATCHER"] ,
				desc = L["HIDE_QUEST_WATCHER_HELP"] ,
				usage = "/ema-quest-watcher hide",
				get = false,
				set = "HideFrameCommand",
			},		
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-quest-watcher push",
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

EMA.COMMAND_QUEST_WATCH_OBJECTIVE_UPDATE = "JQWObjUpd"
EMA.COMMAND_UPDATE_QUEST_WATCHER_LIST = "JQWLstUpd"
EMA.COMMAND_QUEST_WATCH_REMOVE_QUEST = "JQWRmveQst"
EMA.COMMAND_AUTO_QUEST_COMPLETE = "JQWAtQstCmplt"
EMA.COMMAND_REMOVE_AUTO_QUEST_COMPLETE = "JQWRmvAtQstCmplt"
EMA.COMMAND_AUTO_QUEST_OFFER = "JQWAqQstOfr"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

function EMA:DebugMessage( ... )
	--EMA:Print( ... )
end

-- Initialise the module.
function EMA:OnInitialize()
	EMA.QUESTWATCHUPDATING = false 
	EMA.currentAutoQuestPopups = {}
	EMA.countAutoQuestPopUpFrames = 0
	EMA.questWatcherFrameCreated = false
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControlWatcher.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
	-- Create the quest watcher frame.
	EMA:CreateQuestWatcherFrame()
	EMA:SetQuestWatcherVisibility()		
	-- Quest watcher.
	EMA.questWatchListOfQuests = {}
	EMA.questWatchCache = {}
	EMA.questWatchObjectivesList = {}
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	-- Register for the EMA master changed message.
	EMA:RegisterMessage( EMAApi.MESSAGE_TEAM_MASTER_CHANGED, "OnMasterChanged" )
	--EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
    -- Quest events.
	-- Watcher events.
	EMA:RegisterEvent( "PLAYER_REGEN_ENABLED" )
	EMA:RegisterEvent( "PLAYER_REGEN_DISABLED" )
	EMA:RegisterEvent( "QUEST_WATCH_UPDATE" )
	EMA:RegisterEvent( "QUEST_LOG_UPDATE")
	EMA:RegisterEvent( "QUEST_WATCH_LIST_CHANGED", "QUEST_WATCH_UPDATE" )
	-- For in the field auto quests. And Bonus Quests.
	EMA:RegisterEvent("QUEST_ACCEPTED", "QUEST_WATCH_UPDATE")
	EMA:RegisterEvent("QUEST_REMOVED", "RemoveQuestsNotBeingWatched")
	EMA:RegisterEvent( "QUEST_AUTOCOMPLETE" )
	EMA:RegisterEvent( "QUEST_COMPLETE" )
	EMA:RegisterEvent( "QUEST_DETAIL" )
	EMA:RegisterEvent( "SCENARIO_UPDATE" )
	EMA:RegisterEvent( "SCENARIO_CRITERIA_UPDATE" )
	EMA:RegisterEvent( "PLAYER_ENTERING_WORLD" )
   -- Quest post hooks.
    EMA:SecureHook( "SelectActiveQuest" )
	EMA:SecureHook( "GetQuestReward" )
	EMA:SecureHook( C_QuestLog, "AddQuestWatch" )
	EMA:SecureHook( C_QuestLog, "RemoveQuestWatch" )
	EMA:SecureHook( C_QuestLog, "AbandonQuest" )
	EMA:SecureHook( C_QuestLog, "SetAbandonQuest" )
	-- Update the quest watcher for watched quests.
	EMA:ScheduleTimer( "EMAQuestWatcherUpdate", 1, false, "all" )
	--EMA:ScheduleTimer( "EMAQuestWatcherScenarioUpdate", 1, false )
	EMA:UpdateUnlockWatcherFrame()
	-- To Hide After elv changes. --ebony
	EMA:ScheduleTimer( "UpdateHideBlizzardWatchFrame", 2 )
	if EMA.db.enableQuestWatcher == true then
		EMA:QuestWatcherQuestListScrollRefresh()
	end
	EMAQuestMapQuestOptionsDropDown.questID = 0
	EMAQuestMapQuestOptionsDropDown.questText = nil
	UIDropDownMenu_Initialize(EMAQuestMapQuestOptionsDropDown, EMAQuestMapQuestOptionsDropDown_Initialize, "MENU")
end

-- Called when the addon is disabled.
function EMA:OnDisable()
	-- AceHook-3.0 will tidy up the hooks for us. 
end

-------------------------------------------------------------------------------------------------------------
-- Messages.
-------------------------------------------------------------------------------------------------------------

function EMA:OnMasterChanged( message, characterName )
	if EMA.db.enableQuestWatcher == false then
		return
	end
	EMA:SetQuestWatcherVisibility()
end

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsCreate()
	EMA.settingsControlWatcher = {}
	-- Create the settings panels.
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControlWatcher, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder	
	)	
	-- Create the quest controls.
	local bottomOfQuestWatcherOptions = EMA:SettingsCreateQuestWatcherControl( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControlWatcher.widgetSettings.content:SetHeight( -bottomOfQuestWatcherOptions )
end

function EMA:SettingsCreateQuestWatcherControl( top )
	-- Get positions and dimensions.
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local radioBoxHeight = EMAHelperSettings:GetRadioBoxHeight()
	local mediaHeight = EMAHelperSettings:GetMediaHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local sliderHeight = EMAHelperSettings:GetSliderHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local labelContinueHeight = EMAHelperSettings:GetContinueLabelHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( true )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidthSlider = (headingWidth - horizontalSpacing) / 2
	local indent = horizontalSpacing * 10
	local indentContinueLabel = horizontalSpacing * 18
	local indentSpecial = indentContinueLabel + 9
	local checkBoxThirdWidth = (headingWidth - indentContinueLabel) / 3
	local column1Left = left
	local column2Left = left + halfWidthSlider
	local column1LeftIndent = left + indentContinueLabel
	local column2LeftIndent = column1LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local column3LeftIndent = column2LeftIndent + checkBoxThirdWidth + horizontalSpacing
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControlWatcher, "", movingTop, false )
	movingTop = movingTop - headingHeight	
	-- Create a heading for quest completion.
	EMAHelperSettings:CreateHeading( EMA.settingsControlWatcher, L["QUEST_TRACKER_HEADER"], movingTop, true )
	movingTop = movingTop - headingHeight
	-- Check box: Enable auto quest completion.
	EMA.settingsControlWatcher.checkBoxEnableQuestWatcher = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["ENABLE_TRACKER"],
		EMA.SettingsToggleEnableQuestWatcher,
		L["ENABLE_TRACKER_HELP"]
	)	
--[[
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWatcher.checkBoxUnlockWatcherFrame = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		left, 
		movingTop, 
		L["UNLOCK_TRACKER"],
		EMA.SettingsToggleUnlockWatcherFrame,
		L["UNLOCK_TRACKER_HELP"]
	)
]]
	movingTop = movingTop - checkBoxHeight	
	EMA.settingsControlWatcher.checkBoxHideBlizzardWatchFrame = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		left, 
		movingTop, 
		L["HIDE_BLIZZ_OBJ_TRACKER"],
		EMA.SettingsToggleHideBlizzardWatchFrame,
		L["HIDE_BLIZZ_OBJ_TRACKER_HELP"]
	)
	movingTop = movingTop - checkBoxHeight	
	EMA.settingsControlWatcher.checkBoxEnableQuestWatcherMasterOnly = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["SHOW_JOT_ON_MASTER"],
		EMA.SettingsToggleEnableQuestWatcherMasterOnly,
		L["SHOW_JOT_ON_MASTER_HELP"]
		
	)	
	movingTop = movingTop - checkBoxHeight	
	EMA.settingsControlWatcher.displayOptionsCheckBoxHideQuestWatcherInCombat = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		column1Left, 
		movingTop, 
		L["HIDE_JOT_IN_COMBAT"],
		EMA.SettingsToggleHideQuestWatcherInCombat,
		L["HIDE_JOT_IN_COMBAT_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWatcher.checkBoxShowCompletedObjectivesAsDone = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		left, 
		movingTop, 
		L["SHOW_COMPLETED_OBJ_DONE"],
		EMA.SettingsShowCompletedObjectivesAsDone,
		L["SHOW_COMPLETED_OBJ_DONE_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControlWatcher.checkBoxHideQuestIfAllComplete = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		left, 
		movingTop, 
		L["HIDE_OBJ_COMPLETED"],
		EMA.SettingsHideQuestIfAllComplete,
		L["HIDE_OBJ_COMPLETED_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
--[[	
	EMA.settingsControlWatcher.checkBoxSendProgressChatMessages = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		left, 
		movingTop, 
		L["SEND_PROGRESS_MESSAGES"],
		EMA.SettingsToggleSendProgressChatMessages,
		L["SEND_PROGRESS_MESSAGES_HELP"]
	)
	movingTop = movingTop - checkBoxHeight			
	-- Message area.
	EMA.settingsControlWatcher.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		left, 
		movingTop, 
		L["MESSAGE_AREA"]	
	)
	EMA.settingsControlWatcher.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControlWatcher.dropdownMessageArea:SetCallback( "OnValueChanged", EMA.SettingsSetMessageArea )
	
	movingTop = movingTop - dropdownHeight
]]	
	EMAHelperSettings:CreateHeading( EMA.settingsControlWatcher, L["APPEARANCE_LAYOUT_HEALDER"], movingTop, true )
	movingTop = movingTop - headingHeight - verticalSpacing
		-- Information line 1.
	EMA.settingsControlWatcher.displayOptionsQuestWatcherInformation1 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControlWatcher, 
		headingWidth, 
		left, 
		movingTop,
		L["QUESTWACHERINFORMATIONONE"] 
	)	
	movingTop = movingTop - labelContinueHeight
	EMA.settingsControlWatcher.displayOptionsQuestWatcherLinesSlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControlWatcher, 
		halfWidthSlider, 
		left, 
		movingTop, 
		L["LINES_TO_DISPLAY"]
	)
	EMA.settingsControlWatcher.displayOptionsQuestWatcherLinesSlider:SetSliderValues( 5, 50, 1 )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherLinesSlider:SetCallback( "OnValueChanged", EMA.SettingsChangeWatchLines )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherFrameWidthSlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControlWatcher, 
		halfWidthSlider, 
		column2Left, 
		movingTop, 
		L["TRACKER_WIDTH"]
	)
	EMA.settingsControlWatcher.displayOptionsQuestWatcherFrameWidthSlider:SetSliderValues( 250, 600, 5 )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherFrameWidthSlider:SetCallback( "OnValueChanged", EMA.SettingsChangeWatchFrameWidth )
	movingTop = movingTop - sliderHeight - verticalSpacing	
	EMA.settingsControlWatcher.displayOptionsQuestWatcherMediaBorder = EMAHelperSettings:CreateMediaBorder( 
		EMA.settingsControlWatcher, 
		halfWidthSlider, 
		left, 
		movingTop,
		L["BORDER_STYLE"]
	)
	EMA.settingsControlWatcher.displayOptionsQuestWatcherMediaBorder:SetCallback( "OnValueChanged", EMA.SettingsChangeBorderStyle )
	EMA.settingsControlWatcher.questWatchBorderColourPicker = EMAHelperSettings:CreateColourPicker(
		EMA.settingsControlWatcher,
		halfWidthSlider,
		column2Left + 15,
		movingTop - 15,
		L["BORDER COLOUR"]
	)
	EMA.settingsControlWatcher.questWatchBorderColourPicker:SetHasAlpha( true )
	EMA.settingsControlWatcher.questWatchBorderColourPicker:SetCallback( "OnValueConfirmed", EMA.SettingsQuestWatchBorderColourPickerChanged )
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMA.settingsControlWatcher.displayOptionsQuestWatcherMediaBackground = EMAHelperSettings:CreateMediaBackground( 
		EMA.settingsControlWatcher, 
		halfWidthSlider, 
		column1Left, 
		movingTop,
		L["BACKGROUND"]
	)
	EMA.settingsControlWatcher.displayOptionsQuestWatcherMediaBackground:SetCallback( "OnValueChanged", EMA.SettingsChangeBackgroundStyle )
	EMA.settingsControlWatcher.questWatchBackgroundColourPicker = EMAHelperSettings:CreateColourPicker(
		EMA.settingsControlWatcher,
		halfWidthSlider,
		column2Left + 15,
		movingTop - 15,
		L["BG_COLOUR"]
	)
	EMA.settingsControlWatcher.questWatchBackgroundColourPicker:SetHasAlpha( true )
	EMA.settingsControlWatcher.questWatchBackgroundColourPicker:SetCallback( "OnValueConfirmed", EMA.SettingsQuestWatchBackgroundColourPickerChanged )
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMA.settingsControlWatcher.questWatchMediaFont = EMAHelperSettings:CreateMediaFont( 
		EMA.settingsControlWatcher, 
		halfWidthSlider, 
		left, 
		movingTop,
		L["FONT"]
	)
	EMA.settingsControlWatcher.questWatchMediaFont:SetCallback( "OnValueChanged", EMA.SettingsChangeFontStyle )
	EMA.settingsControlWatcher.questWatchFontSize = EMAHelperSettings:CreateSlider( 
		EMA.settingsControlWatcher, 
		halfWidthSlider, 
		column2Left, 
		movingTop, 
		L["FONT_SIZE"]
	)	
	EMA.settingsControlWatcher.questWatchFontSize:SetSliderValues( 8, 20 , 1 )
	EMA.settingsControlWatcher.questWatchFontSize:SetCallback( "OnValueChanged", EMA.SettingsChangeFontSize )	
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMA.settingsControlWatcher.displayOptionsQuestWatcherScaleSlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControlWatcher, 
		halfWidthSlider, 
		column1Left, 
		movingTop, 
		L["SCALE"]
	)
	EMA.settingsControlWatcher.displayOptionsQuestWatcherScaleSlider:SetSliderValues( 0.5, 2, 0.01 )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherScaleSlider:SetCallback( "OnValueChanged", EMA.SettingsChangeScale )
	--movingTop = movingTop - sliderHeight - verticalSpacing	
	EMA.settingsControlWatcher.displayOptionsQuestWatcherTransparencySlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControlWatcher, 
		halfWidthSlider, 
		column2Left, 
		movingTop, 
		L["TRANSPARENCY"]
	)
	EMA.settingsControlWatcher.displayOptionsQuestWatcherTransparencySlider:SetSliderValues( 0, 1, 0.01 )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherTransparencySlider:SetCallback( "OnValueChanged", EMA.SettingsChangeTransparency )
	movingTop = movingTop - sliderHeight - verticalSpacing
	return movingTop
end
--[[
function EMA:OnMessageAreasChanged( message )
	EMA.settingsControlWatcher.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end
]]
-------------------------------------------------------------------------------------------------------------
-- Watcher frame.
-------------------------------------------------------------------------------------------------------------

function EMA:CanDisplayQuestWatcher()
	-- Do not show is quest watcher disabled.
	if EMA.db.enableQuestWatcher == false then
		return false
	end
	-- Do not show if user has hidden frame.
	if EMA.db.showFrame == false then
		return false
	end
	-- Do not show if master only and not the master.
	if EMA.db.enableQuestWatcherOnMasterOnly == true then
		if EMAApi.IsCharacterTheMaster( EMA.characterName ) == false then
			return false
		end
	end
	-- Show if at least one line in the watch list.
	if EMA:CountLinesInQuestWatchList() > 0 then
		return true
	end
	-- Show if at least one auto quest popup.
	if EMA:HasAtLeastOneAutoQuestPopup() == true then
		return true
	end
	-- Nothing to show.
	return false
end

local function Title_OnMouseDown(frame)
	if IsAltKeyDown() then
		frame:GetParent():StartMoving()
	end
end

local function MoverSizer_OnMouseUp(mover)
	local frame = mover:GetParent()
	frame:StopMovingOrSizing()
	local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
	EMA.db.watcherFramePoint = point
	EMA.db.watcherFrameRelativePoint = relativePoint
	EMA.db.watcherFrameXOffset = xOffset
	EMA.db.watcherFrameYOffset = yOffset
end


function EMA:CreateQuestWatcherFrame()
	-- The frame.
	local frame = CreateFrame( "Frame", "EMAQuestWatcherWindowFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil )
	frame.obj = EMA
	frame:SetFrameStrata( "BACKGROUND" )
	frame:SetClampedToScreen( true )
	frame:EnableMouse( false )
	frame:SetMovable( true )	
	frame:ClearAllPoints()
	frame:SetPoint( EMA.db.watcherFramePoint, UIParent, EMA.db.watcherFrameRelativePoint, EMA.db.watcherFrameXOffset, EMA.db.watcherFrameYOffset )
	frame:SetBackdrop( {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
		tile = true, tileSize = 10, edgeSize = 10, 
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	} )
	-- Create the title for the questWaster list frame.
    local titleButton = CreateFrame( "Button", "EMAQuestWatcherWindowFrameTitle", frame )
	titleButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", -5, -4 )
	titleButton:SetWidth( EMA.db.watcherFrameWidth - 100 )
	titleButton:SetHeight( 20 )	
	titleButton:SetScript("OnMouseDown", Title_OnMouseDown)	
	titleButton:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
	titleButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(titleButton, "headerMouseOver", true) end)
	titleButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	titleButton.titleName = titleButton:CreateFontString( titleButton:GetName().."Text", "OVERLAY", "GameFontNormal" )
	titleButton.titleName:SetJustifyH( "CENTER" )
	titleButton.titleName:SetAllPoints( titleButton )
	titleButton.titleName:SetTextColor( 1.00, 1.00, 1.00 )
    titleButton.titleName:SetText( L["TRACKER_TITLE_NAME"] )
	frame.titleName =  titleButton.titleName

	-- Update button.
	local updateButton = CreateFrame( "Button", "EMAQuestWatcherWindowFrameButtonUpdate", frame, "UIPanelButtonGrayTemplate" )
	updateButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", -5, -4 )
	updateButton:SetHeight( 20 )
	updateButton:SetWidth( 100 )
	updateButton:SetText( L["UPDATE"] )		
	updateButton:SetScript( "OnClick", EMA.EMAQuestWatchListUpdateButtonClicked )
	updateButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(updateButton, "update", true) end)
	updateButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	-- Add an area for the "in the field quest" notifications.
	frame.fieldNotificationsTop = -24
	frame.fieldNotifications = CreateFrame( "Frame", "EMAQuestWatcherFieldQuestFrame", frame )
	frame.fieldNotifications:SetFrameStrata( "BACKGROUND" )
	frame.fieldNotifications:SetClampedToScreen( true )
	frame.fieldNotifications:EnableMouse( false )
	frame.fieldNotifications:ClearAllPoints()
	frame.fieldNotifications:SetPoint( "TOPLEFT", frame, "TOPLEFT", 0, frame.fieldNotificationsTop )
	frame.fieldNotifications:Show()
	-- Set transparency of the the frame (and all its children).
	frame:SetAlpha( EMA.db.watcherFrameAlpha )	
	-- List.
	local topOfList = frame.fieldNotificationsTop
	local list = {}
	list.listFrameName = "EMAQuestWatcherQuestListFrame"
	list.parentFrame = frame
	list.listTop = topOfList
	list.listLeft = 2
	list.listWidth = EMA.db.watcherFrameWidth
	list.rowHeight = 19
	list.rowsToDisplay = EMA.db.watcherListLines
	list.columnsToDisplay = 2
	list.columnInformation = {}	
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 80
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 20
	list.columnInformation[2].alignment = "CENTER"
	list.scrollRefreshCallback = EMA.QuestWatcherQuestListScrollRefresh
	list.rowClickCallback = EMA.QuestWatcherQuestListRowClick
	list.rowRightClickCallback = EMA.QuestWatcherQuestListRowRightClick
	list.rowMouseOverCallBack_OnEnter = EMA.QuestWatcherQuestListRowOnEnter
	list.rowMouseOverCallBack_OnLeave = EMA.QuestWatcherQuestListRowOnLeave
	frame.questWatchList = list
	EMAHelperSettings:CreateScrollList( frame.questWatchList )
	-- Change appearance from default.
	frame.questWatchList.listFrame:SetBackdropColor( 0.0, 0.0, 0.0, 0.0 )
	frame.questWatchList.listFrame:SetBackdropBorderColor( 0.0, 0.0, 0.0, 0.0 )
	-- Disable mouse on columns so click-through works.
	for iterateDisplayRows = 1, frame.questWatchList.rowsToDisplay do
		for iterateDisplayColumns = 1, frame.questWatchList.columnsToDisplay do
			if InCombatLockdown() == false then
				frame.questWatchList.rows[iterateDisplayRows].columns[iterateDisplayColumns]:EnableMouse( false )
			end
		end
	end
	-- Position and size constants (once list height is known).
	frame.questWatchListBottom = topOfList - list.listHeight
	frame.questWatchListHeight = list.listHeight
	frame.questWatchHighlightRow = 1
	frame.questWatchListOffset = 1
	-- Set the global frame reference for this frame.
	EMAQuestWatcherFrame = frame
	EMAQuestWatcherFrame.autoQuestPopupsHeight = 0
	EMA:SettingsUpdateBorderStyle()	
	EMA:SettingsUpdateFontStyle()
	EMA.questWatcherFrameCreated = true
end

function EMA:ShowTooltip(frame, info, show)
	if show then
		GameTooltip:SetOwner(frame, "ANCHOR_TOP")
		GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT", 16, 0)
		GameTooltip:ClearLines()
		if info == "headerMouseOver" then
			GameTooltip:AddLine(L["HEADER_MOUSE_OVER_QUESTWATCHER"], 1, 0.82, 0, 1)
		elseif info == "update" then
			GameTooltip:AddLine(L["UPDATE_MOUSE_OVER_QUESTWATCHER"], 1, 0.82, 0, 1)
		end
		GameTooltip:Show()
	else
	GameTooltip:Hide()
	end
end


function EMA:SettingsUpdateBorderStyle()
	local borderStyle = EMA.SharedMedia:Fetch( "border", EMA.db.borderStyle )
	local backgroundStyle = EMA.SharedMedia:Fetch( "background", EMA.db.backgroundStyle )
	local frame = EMAQuestWatcherFrame
	frame:SetBackdrop( {
		bgFile = backgroundStyle, 
		edgeFile = borderStyle, 
		tile = true, tileSize = frame:GetWidth(), edgeSize = 10, 
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	} )
	frame:SetBackdropColor( EMA.db.watchFrameBackgroundColourR, EMA.db.watchFrameBackgroundColourG, EMA.db.watchFrameBackgroundColourB, EMA.db.watchFrameBackgroundColourA )
	frame:SetBackdropBorderColor( EMA.db.watchFrameBorderColourR, EMA.db.watchFrameBorderColourG, EMA.db.watchFrameBorderColourB, EMA.db.watchFrameBorderColourA )	
end

function EMA:SettingsUpdateFontStyle()
	local textFont = EMA.SharedMedia:Fetch( "font", EMA.db.watchFontStyle )
	local textSize = EMA.db.watchFontSize
	local frame = EMAQuestWatcherFrame
	frame.titleName:SetFont( textFont , textSize , "OUTLINE")
end	


function EMA:UpdateQuestWatcherDimensions()
	if InCombatLockdown() == true then
		return
	end		
		local frame = EMAQuestWatcherFrame
		frame:SetWidth( frame.questWatchList.listWidth + 4 )
		frame:SetHeight( frame.questWatchListHeight + 40 )
		-- Field notifications.
		frame.fieldNotifications:SetWidth( frame.questWatchList.listWidth + 4 )
		frame.fieldNotifications:SetHeight( EMAQuestWatcherFrame.autoQuestPopupsHeight )
		-- List.
		frame.questWatchList.listTop = frame.fieldNotificationsTop - EMAQuestWatcherFrame.autoQuestPopupsHeight
		frame.questWatchList.listFrame:SetPoint( "TOPLEFT", frame.questWatchList.parentFrame, "TOPLEFT", frame.questWatchList.listLeft, frame.questWatchList.listTop )
		-- Scale.
		frame:SetScale( EMA.db.watcherFrameScale )
end

function EMA:SetQuestWatcherVisibility()
	if InCombatLockdown() == true then
		return
	end
	if EMA:CanDisplayQuestWatcher() == true then
		EMA:UpdateQuestWatcherDimensions()
		EMAQuestWatcherFrame:ClearAllPoints()
		EMAQuestWatcherFrame:SetPoint( EMA.db.watcherFramePoint, UIParent, EMA.db.watcherFrameRelativePoint, EMA.db.watcherFrameXOffset, EMA.db.watcherFrameYOffset )
		EMAQuestWatcherFrame:SetAlpha( EMA.db.watcherFrameAlpha )
		EMAQuestWatcherFrame:Show()
	else
		EMAQuestWatcherFrame:Hide()
	end	
end

-------------------------------------------------------------------------------------------------------------
-- Settings functionality.
-------------------------------------------------------------------------------------------------------------

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.enableQuestWatcher = settings.enableQuestWatcher
		EMA.db.watcherFrameAlpha = settings.watcherFrameAlpha
		EMA.db.watcherFramePoint = settings.watcherFramePoint
		EMA.db.watcherFrameRelativePoint = settings.watcherFrameRelativePoint
		EMA.db.watcherFrameXOffset = settings.watcherFrameXOffset
		EMA.db.watcherFrameYOffset = settings.watcherFrameYOffset
		EMA.db.borderStyle = settings.borderStyle
		EMA.db.backgroundStyle = settings.backgroundStyle
		EMA.db.watchFontStyle = settings.watchFontStyle
		EMA.db.watchFontSize = settings.watchFontSize
		EMA.db.hideQuestWatcherInCombat = settings.hideQuestWatcherInCombat
		EMA.db.watcherFrameScale = settings.watcherFrameScale
		EMA.db.enableQuestWatcherOnMasterOnly = settings.enableQuestWatcherOnMasterOnly
		EMA.db.watchFrameBackgroundColourR = settings.watchFrameBackgroundColourR
		EMA.db.watchFrameBackgroundColourG = settings.watchFrameBackgroundColourG
		EMA.db.watchFrameBackgroundColourB = settings.watchFrameBackgroundColourB
		EMA.db.watchFrameBackgroundColourA = settings.watchFrameBackgroundColourA
		EMA.db.watchFrameBorderColourR = settings.watchFrameBorderColourR
		EMA.db.watchFrameBorderColourG = settings.watchFrameBorderColourG
		EMA.db.watchFrameBorderColourB = settings.watchFrameBorderColourB
		EMA.db.watchFrameBorderColourA = settings.watchFrameBorderColourA
		EMA.db.watcherListLines = settings.watcherListLines
		EMA.db.watcherFrameWidth = settings.watcherFrameWidth
		EMA.db.unlockWatcherFrame = settings.unlockWatcherFrame
		EMA.db.hideBlizzardWatchFrame = settings.hideBlizzardWatchFrame
		EMA.db.doNotHideCompletedObjectives = settings.doNotHideCompletedObjectives
		EMA.db.showCompletedObjectivesAsDone = settings.showCompletedObjectivesAsDone
		EMA.db.hideQuestIfAllComplete = settings.hideQuestIfAllComplete
--		EMA.db.showFrame = settings.showFrame
--		EMA.db.sendProgressChatMessages = settings.sendProgressChatMessages
--		EMA.db.messageArea = settings.messageArea
		-- Refresh the settings.
		EMA:SettingsRefresh()
		EMA:UpdateUnlockWatcherFrame()
		--EMA:UpdateHideBlizzardWatchFrame()
		EMA:ScheduleTimer( "UpdateHideBlizzardWatchFrame", 2 )
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"] ( characterName ) )
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
	-- Quest watcher options.
	EMA.settingsControlWatcher.checkBoxEnableQuestWatcher:SetValue( EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherMediaBorder:SetValue( EMA.db.borderStyle )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherMediaBackground:SetValue( EMA.db.backgroundStyle )
 
	EMA.settingsControlWatcher.questWatchMediaFont:SetValue( EMA.db.watchFontStyle )
	EMA.settingsControlWatcher.questWatchFontSize:SetValue( EMA.db.watchFontSize )

	EMA.settingsControlWatcher.displayOptionsCheckBoxHideQuestWatcherInCombat:SetValue( EMA.db.hideQuestWatcherInCombat )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherTransparencySlider:SetValue( EMA.db.watcherFrameAlpha )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherScaleSlider:SetValue( EMA.db.watcherFrameScale )
	EMA.settingsControlWatcher.checkBoxEnableQuestWatcherMasterOnly:SetValue( EMA.db.enableQuestWatcherOnMasterOnly )
	EMA.settingsControlWatcher.questWatchBackgroundColourPicker:SetColor( EMA.db.watchFrameBackgroundColourR, EMA.db.watchFrameBackgroundColourG, EMA.db.watchFrameBackgroundColourB, EMA.db.watchFrameBackgroundColourA )
	EMA.settingsControlWatcher.questWatchBorderColourPicker:SetColor( EMA.db.watchFrameBorderColourR, EMA.db.watchFrameBorderColourG, EMA.db.watchFrameBorderColourB, EMA.db.watchFrameBorderColourA )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherLinesSlider:SetValue( EMA.db.watcherListLines )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherFrameWidthSlider:SetValue( EMA.db.watcherFrameWidth )
--	EMA.settingsControlWatcher.checkBoxUnlockWatcherFrame:SetValue( EMA.db.unlockWatcherFrame )
	EMA.settingsControlWatcher.checkBoxHideBlizzardWatchFrame:SetValue( EMA.db.hideBlizzardWatchFrame )
	EMA.settingsControlWatcher.checkBoxShowCompletedObjectivesAsDone:SetValue( EMA.db.showCompletedObjectivesAsDone  )
	EMA.settingsControlWatcher.checkBoxHideQuestIfAllComplete:SetValue( EMA.db.hideQuestIfAllComplete )
--	EMA.settingsControlWatcher.dropdownMessageArea:SetValue( EMA.db.messageArea )
--	EMA.settingsControlWatcher.checkBoxSendProgressChatMessages:SetValue( EMA.db.sendProgressChatMessages )
	-- Quest watcher state.
	EMA.settingsControlWatcher.displayOptionsQuestWatcherMediaBorder:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherMediaBackground:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.questWatchMediaFont:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.questWatchFontSize:SetDisabled( not EMA.db.enableQuestWatcher )
 
	EMA.settingsControlWatcher.displayOptionsCheckBoxHideQuestWatcherInCombat:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherTransparencySlider:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherScaleSlider:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.checkBoxEnableQuestWatcherMasterOnly:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.questWatchBackgroundColourPicker:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.questWatchBorderColourPicker:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherLinesSlider:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.displayOptionsQuestWatcherFrameWidthSlider:SetDisabled( not EMA.db.enableQuestWatcher )
--	EMA.settingsControlWatcher.checkBoxUnlockWatcherFrame:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.checkBoxHideBlizzardWatchFrame:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.checkBoxShowCompletedObjectivesAsDone:SetDisabled( not EMA.db.enableQuestWatcher )
	EMA.settingsControlWatcher.checkBoxHideQuestIfAllComplete:SetDisabled( not EMA.db.enableQuestWatcher )
--	EMA.settingsControlWatcher.dropdownMessageArea:SetDisabled( not EMA.db.enableQuestWatcher )
--	EMA.settingsControlWatcher.checkBoxSendProgressChatMessages:SetDisabled( not EMA.db.enableQuestWatcher )
	if EMA.questWatcherFrameCreated == true and InCombatLockdown() == false then
		EMA:SettingsUpdateBorderStyle()
		EMA:SettingsUpdateFontStyle()
		EMA:SetQuestWatcherVisibility()
	end
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleEnableQuestWatcher( event, checked )
	EMA.db.enableQuestWatcher = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeBorderStyle( event, value )
	EMA.db.borderStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeBackgroundStyle( event, value )
	EMA.db.backgroundStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeFontStyle( event, value )
	EMA.db.watchFontStyle = value
	EMA:SettingsRefresh()
	EMA:EMAQuestWatcherUpdate( false, "all" )
end

function EMA:SettingsChangeFontSize( event, value )
	EMA.db.watchFontSize = value
	EMA:SettingsRefresh()
	EMA:EMAQuestWatcherUpdate( false, "all" )
end

function EMA:SettingsToggleHideQuestWatcherInCombat( event, checked )
	EMA.db.hideQuestWatcherInCombat = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeTransparency( event, value )
	EMA.db.watcherFrameAlpha = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeScale( event, value )
	EMA.db.watcherFrameScale = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeWatchLines( event, value )
	EMA.db.watcherListLines = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeWatchFrameWidth( event, value )
	EMA.db.watcherFrameWidth = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleEnableQuestWatcherMasterOnly( event, checked )
	EMA.db.enableQuestWatcherOnMasterOnly = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsQuestWatchBackgroundColourPickerChanged( event, r, g, b, a )
	EMA.db.watchFrameBackgroundColourR = r
	EMA.db.watchFrameBackgroundColourG = g
	EMA.db.watchFrameBackgroundColourB = b
	EMA.db.watchFrameBackgroundColourA = a
	EMA:SettingsRefresh()
end

function EMA:SettingsQuestWatchBorderColourPickerChanged( event, r, g, b, a )
	EMA.db.watchFrameBorderColourR = r
	EMA.db.watchFrameBorderColourG = g
	EMA.db.watchFrameBorderColourB = b
	EMA.db.watchFrameBorderColourA = a
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleUnlockWatcherFrame( event, checked )
	EMA.db.unlockWatcherFrame = checked
	EMA:UpdateUnlockWatcherFrame()
	EMA:SettingsRefresh()
end
--[[
function EMA:SettingsToggleSendProgressChatMessages( event, checked )
	EMA.db.sendProgressChatMessages = checked
	EMA:SettingsRefresh()
end
]]
function EMA:SettingsToggleShowFrame( event, checked )
	EMA.db.showFrame = checked
	EMA:SettingsRefresh()
end

function EMA:ShowFrameCommand( info, parameters )
	EMA.db.showFrame = true
	EMA:SettingsRefresh()
end

function EMA:HideFrameCommand( info, parameters )
	EMA.db.showFrame = false
	EMA:SettingsRefresh()
end

function EMA:SettingsSetMessageArea( event, messageAreaValue )
	EMA.db.messageArea = messageAreaValue
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleHideBlizzardWatchFrame( event, checked )
	EMA.db.hideBlizzardWatchFrame = checked
	--EMA:UpdateHideBlizzardWatchFrame()
	EMA:ScheduleTimer( "UpdateHideBlizzardWatchFrame", 2 )
	EMA:SettingsRefresh()
end

function EMA:SettingsShowCompletedObjectivesAsDone( event, checked )
	EMA.db.showCompletedObjectivesAsDone = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsHideQuestIfAllComplete( event, checked )
	EMA.db.hideQuestIfAllComplete = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsDoNotHideCompletedObjectives( event, checked )
	EMA.db.doNotHideCompletedObjectives = checked
	EMA:SettingsRefresh()
end

function EMA:UpdateUnlockWatcherFrame()
	if EMA.db.enableQuestWatcher == false then
		return
	end
	if EMA.db.unlockWatcherFrame == true then
		EMAQuestWatcherFrame:EnableMouse( true )
	else
		EMAQuestWatcherFrame:EnableMouse( false )
	end
end

function EMA:UpdateHideBlizzardWatchFrame()
	if EMA.db.enableQuestWatcher == false then
		return
	end
	if EMA.db.hideBlizzardWatchFrame == true then
		if ObjectiveTrackerFrame:IsVisible() then
            ObjectiveTrackerFrame:Hide()
		end
	else
        ObjectiveTrackerFrame:Show()
	end
end

-------------------------------------------------------------------------------------------------------------
-- QUEST WATCHING HOOKS
-------------------------------------------------------------------------------------------------------------

function EMA:SelectActiveQuest( questIndex )
    EMA:DebugMessage("select active quest", questIndex)
	if EMA.db.enableQuestWatcher == false then
		return
	end
	EMA:SetActiveQuestForQuestWatcherCache( questIndex )
end

function EMA:GetQuestReward( itemChoice )
	if EMA.db.enableQuestWatcher == false then
		return
    end
	local questJustCompletedName = GetTitleText()
    EMA:DebugMessage( "GetQuestReward: ", questIndex, questJustCompletedName )
    local questIndex = EMA:GetQuestLogIndexByName( questJustCompletedName )
    --local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle( questIndex )
    local info =  C_QuestLog.GetInfo( questIndex )
	if info ~=  nil then
		EMA:DebugMessage( "GetQuestReward after GetQuestLogTitle: ", info.questIndex, questJustCompletedName, info.questID )
		EMA:RemoveQuestFromWatchList( info.questID )
	end	
end

function EMA:AddQuestWatch( questIndex )
	if EMA.db.enableQuestWatcher == false then
		return
	end
	--EMA:UpdateHideBlizzardWatchFrame()
	EMA:ScheduleTimer( "UpdateHideBlizzardWatchFrame", 2 )
	EMA:EMAQuestWatcherUpdate( true,  "all" )
	--EMA:EMAQuestWatcherScenarioUpdate( true )
end

function EMA:RemoveQuestWatch( questID )
	if EMA.db.enableQuestWatcher == false then
		return
    end
    --EMA:Print( "RemoveQuestWatch", questID )
	--EMA:UpdateHideBlizzardWatchFrame()
    EMA:ScheduleTimer( "UpdateHideBlizzardWatchFrame", 2 )
	--local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle( questIndex )
    --local info =  C_QuestLog.GetInfo( questIndex )
	EMA:DebugMessage( "About to call RemoveQuestFromWatchList with value:", questID )
	EMA:RemoveQuestFromWatchList( questID )
end

function EMA:SetAbandonQuest()
	if EMA.db.enableQuestWatcher == false then
		return
	end
	--local questName = GetAbandonQuestName()
	local questName = QuestUtils_GetQuestName(C_QuestLog.GetAbandonQuest())
	if questName ~= nil then
		local questIndex = EMA:GetQuestLogIndexByName( questName )
		EMA:SetActiveQuestForQuestWatcherCache( questIndex )
	end
end

function EMA:AbandonQuest()
	if EMA.db.enableQuestWatcher == false then
		return
	end
	-- Wait a bit for the correct information to come through from the server...
	EMA:ScheduleTimer( "AbandonQuestDelayed", 1 )		
end


function EMA:QUEST_WATCH_UPDATE( event, ... )
	--EMA:Print("test4")
	if EMA.db.enableQuestWatcher == true then
		-- Wait a bit for the correct information to come through from the server...
		EMA:ScheduleTimer( "EMAQuestWatcherUpdate", 1, true, "all" )		
	end
end


function EMA:QUEST_LOG_UPDATE( event, ... )
	--EMA:Print("QuestTestUpdates")
	if EMA.db.enableQuestWatcher == true then
		-- Wait a bit for the correct information to come through from the server...
		EMA:ScheduleTimer( "EMAQuestWatcherUpdate", 1, true, "all" )
		-- For PopUpQuests!
		for i = 1, GetNumAutoQuestPopUps() do
			local questID, popUpType = GetAutoQuestPopUp(i);
			if ( not C_QuestLog.IsQuestBounty(questID) ) then
				local questTitle = C_QuestLog.GetTitleForQuestID(questID);
				if ( questTitle and questTitle ~= "" ) then
					if popUpType == "OFFER" then
						EMA:EMASendCommandToTeam( EMA.COMMAND_AUTO_QUEST_OFFER, questID )
					elseif popUpType == "COMPLETE" then
						EMA:EMASendCommandToTeam( EMA.COMMAND_AUTO_QUEST_COMPLETE, questID )
					end	
				end
			end
		end
	end
end

function EMA:SCENARIO_UPDATE( event, ... )
	--EMA:Print("test2")
	if EMA.db.enableQuestWatcher == true then								
		EMA:RemoveQuestsNotBeingWatched()
		EMA:ScheduleTimer( "EMAQuestWatcherUpdate", 1, true, "scenario" )
	end
end

function EMA:SCENARIO_CRITERIA_UPDATE( event, ... )
	--EMA:Print("test3.5")
	if EMA.db.enableQuestWatcher == true then
		-- Wait a bit for the correct information to come through from the server...
		EMA:ScheduleTimer( "EMAQuestWatcherUpdate", 1, true, "scenario" )	
																  
	end
end

function EMA:PLAYER_ENTERING_WORLD( event, ... )
	--EMA:Print("test4")
	if EMA.db.enableQuestWatcher == true then
		EMA:RemoveQuestsNotBeingWatched()
		EMA:ScheduleTimer( "EMAQuestWatcherUpdate", 1, false, "all" )										
	end
end


function EMA:PLAYER_REGEN_ENABLED( event, ... )
	if EMA.db.enableQuestWatcher == false then
		return
	end
	if EMA.db.hideQuestWatcherInCombat == true then
		EMA:SetQuestWatcherVisibility()
	end
end

function EMA:PLAYER_REGEN_DISABLED( event, ... )
	if EMA.db.enableQuestWatcher == false then
		return
	end
	if EMA.db.hideQuestWatcherInCombat == true then
		EMAQuestWatcherFrame:Hide()
	end
end

-------------------------------------------------------------------------------------------------------------
-- QUEST WATCHING
-------------------------------------------------------------------------------------------------------------

function EMA:AbandonQuestDelayed()
	EMA:RemoveCurrentQuestFromWatcherCache()
	EMA:RemoveQuestsNotBeingWatched()
end

function EMA:EMAQuestWatchListUpdateButtonClicked()
	EMA:RemoveQuestsNotBeingWatched()
	EMA:EMASendCommandToTeam( EMA.COMMAND_UPDATE_QUEST_WATCHER_LIST )
end

function EMA:DoQuestWatchListUpdate( characterName )
	EMA:EMAQuestWatcherUpdate( false, "all" )
	--EMA:EMAQuestWatcherScenarioUpdate( false )
end


function EMA:GetQuestObjectiveCompletion( text )
	if text == nil then
        return L["N/A"], L["N/A"]
    end

    local icount,imax = string.match(text,"(%d+)/(%d+)")
    if icount ~= nil then
        text=string.gsub(text,icount .. "/" .. imax,"")
        text=string.gsub(text,"[: ]*$","")
        text=string.gsub(text,"^[: ]*","")
        return icount..L["/"]..imax, text
    else
        return L["DONE"] , text
    end
end
	--[[
	if text == nil then
		return L["N/A"], L["N/A"]
	end
	local makeString = nil
	local dig1, dig2 = string.match( text, "(%d*)/(%d*)")
	if (dig1  and dig2) then
		local arg1, arg2 = string.match(text, "(.-%S)%s(.*)")
		--EMA:Print("testm", arg1, "A", arg2)
		makeString = dig1..L["/"]..dig2 
	end
	if makeString ~= nil then
		local arg1, arg2 = string.match(text, "(.-%S)%s(.*)")
		local textFind = string.find(arg1, "(%d*)")
		--EMA:Print("text", textFind)
		if textFind then
			return makeString, arg2
		else
			return makeString, text
		end	
	else	
		return L["DONE"] , text		
	end
end
]]

function EMA:QuestWatchGetObjectiveText( questIndex, objectiveIndex )
	local objectiveFullText, objectiveType, objectiveFinished = GetQuestLogLeaderBoard( objectiveIndex, questIndex )
	local amountCompleted, objectiveText = EMA:GetQuestObjectiveCompletion( objectiveFullText )
	return objectiveText 
end




-------------------------------------------------------------------------------------------------------------
-- QUEST WATCH CACHE
-------------------------------------------------------------------------------------------------------------

function EMA:IsQuestObjectiveInCache( questID, objectiveIndex )
	local key = questID..objectiveIndex
	if EMA.questWatchCache[key] == nil then
		return false
	end
	return true
end

function EMA:AddQuestObjectiveToCache( questID, objectiveIndex, amountCompleted, objectiveFinished )
	local key = questID..objectiveIndex
	EMA.questWatchCache[key] = {}
	EMA.questWatchCache[key].questID = questID
	EMA.questWatchCache[key].amountCompleted = amountCompleted
	EMA.questWatchCache[key].objectiveFinished = objectiveFinished
end

function EMA:GetQuestCachedValues( questID, objectiveIndex )
	local key = questID..objectiveIndex
	return EMA.questWatchCache[key].amountCompleted, EMA.questWatchCache[key].objectiveFinished
end

function EMA:UpdateQuestCachedValues( questID, objectiveIndex, amountCompleted, objectiveFinished )
	local key = questID..objectiveIndex
	EMA.questWatchCache[key].amountCompleted = amountCompleted
	EMA.questWatchCache[key].objectiveFinished = objectiveFinished
end

function EMA:QuestCacheUpdate( questID, objectiveIndex, amountCompleted, objectiveFinished )
	if EMA:IsQuestObjectiveInCache( questID, objectiveIndex ) == false then
		EMA:AddQuestObjectiveToCache( questID, objectiveIndex, amountCompleted, objectiveFinished )
		return true
	end
	local cachedAmountCompleted, cachedObjectiveFinished = EMA:GetQuestCachedValues( questID, objectiveIndex )
	if cachedAmountCompleted == amountCompleted and cachedObjectiveFinished == objectiveFinished then
		return false
	end
	EMA:UpdateQuestCachedValues( questID, objectiveIndex, amountCompleted, objectiveFinished )
	return true
end

function EMA:SetActiveQuestForQuestWatcherCache( questIndex )
	if EMA.db.enableQuestWatcher == false then
		return
	end
	if questIndex ~= nil then
        --local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle( questIndex )
		--local info =  C_QuestLog.GetInfo( questIndex )
		
		--EMA:Print("testaa", info.questID)
		EMA.currentQuestForQuestWatcherID = questIndex
	else
		EMA.currentQuestForQuestWatcherID = nil
	end
end

function EMA:RemoveQuestFromWatcherCache( questID )
    EMA:DebugMessage( "RemoveQuestFromWatcherCache", questID )
	for key, questInfo in pairs( EMA.questWatchCache ) do
		if questInfo.questID == questID then
			EMA.questWatchCache[key].questID = nil
			EMA.questWatchCache[key].amountCompleted = nil
			EMA.questWatchCache[key].objectiveFinished = nil
			EMA.questWatchCache[key] = nil
			EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_WATCH_REMOVE_QUEST, questID )
		end
	end
end

function EMA:RemoveCurrentQuestFromWatcherCache()
	if EMA.db.enableQuestWatcher == false then
		return
    end
    EMA:DebugMessage( "RemoveCurrentQuestFromWatcherCache", EMA.currentQuestForQuestWatcherID )
	if EMA.currentQuestForQuestWatcherID == nil then
		return
	end
	EMA:RemoveQuestFromWatcherCache( EMA.currentQuestForQuestWatcherID )
end

-------------------------------------------------------------------------------------------------------------
-- AUTO QUEST COMMUNICATION
-------------------------------------------------------------------------------------------------------------

function EMA:QUEST_AUTOCOMPLETE( event, questID, ... )
	-- In the field autocomplete quest event.
	if EMA.db.enableQuestWatcher == false then
		return
	end
	--EMA:Print("test")
	EMA:EMASendCommandToTeam( EMA.COMMAND_AUTO_QUEST_COMPLETE, questID )
end

function EMA:DoAutoQuestFieldComplete( characterName, questID )
	EMA:EMAAddAutoQuestPopUp( questID, "COMPLETE", characterName )
end

function EMA:QUEST_COMPLETE()
	if EMA.db.enableQuestWatcher == false then
		return
    end
	EMA:EMASendCommandToTeam( EMA.COMMAND_REMOVE_AUTO_QUEST_COMPLETE, questID )
end

function EMA:DoRemoveAutoQuestFieldComplete( characterName, questID )
	EMA:EMARemoveAutoQuestPopUp( questID, characterName )
end

function EMA:QUEST_DETAIL(event, ...)
	if EMA.db.enableQuestWatcher == false then
		return
	end
	local questStartItemID = ...
	--EMA:Print("testOffer", questStartItemID, QuestGetAutoAccept(), QuestIsFromAreaTrigger() )
    if(questStartItemID ~= nil and questStartItemID ~= 0) then
		EMA:EMASendCommandToTeam( EMA.COMMAND_AUTO_QUEST_OFFER, GetQuestID() )
		return
	end
	if ( QuestGetAutoAccept() and QuestIsFromAreaTrigger()) then
		EMA:EMASendCommandToTeam( EMA.COMMAND_AUTO_QUEST_OFFER, GetQuestID() )
		return
	end	
end		

function EMA:DoAutoQuestFieldOffer( characterName, questID )
	EMA:EMAAddAutoQuestPopUp( questID, "OFFER", characterName )
end

-------------------------------------------------------------------------------------------------------------
-- QUEST WATCH COMMUNICATION
-------------------------------------------------------------------------------------------------------------

function EMA:EMAQuestWatcherScenarioUpdate(useCache)
	-- Scenario information
	local isInScenario = C_Scenario.IsInScenario()
	if isInScenario == true then
		-- Hacky hacky to get Scenario to show at the top of the list.
		if useCache == false then 
			EMAUtilities:ClearTable( EMA.questWatchObjectivesList )
		end
		--local useCache = false
		local scenarioName, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo()
		--EMA:Print("scenario", scenarioName, currentStage, numStages)
			for StagesIndex = 1, currentStage do
				--EMA:Print("Player is on Stage", currentStage)
				local stageName, stageDescription, numCriteria, _, _, _, numSpells, spellInfo, weightedProgress = C_Scenario.GetStepInfo()
				--EMA:Print("test match", numCriteria)
				if numCriteria == 0 then
					--EMA:Print("test match 0")
					if (weightedProgress) then
						--EMA:Print("Checking Progress", weightedProgress)
						local questID = 1001	
						local criteriaIndex = 0
						local maxProgress = 100
						--Placeholder does not work on borkenshore questlines......
						--local totalQuantity = 100
						local completed = false
						local amountCompleted = tostring(weightedProgress).."/"..(maxProgress)
						local name = "Scenario:"..stageName.." "..currentStage.."/"..numStages
						--EMA:Print("scenarioProgressInfo", questID, name, criteriaIndex, stageDescription , amountCompleted , totalQuantity, completed )
						--EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_WATCH_OBJECTIVE_UPDATE, questID, name, numCriteria, stageDescription , amountCompleted , totalQuantity, completed )
						EMA:DoQuestWatchObjectiveUpdate( EMA.characterName, questID, name, numCriteria, stageDescription , amountCompleted , totalQuantity, completed )
					else
						--EMA:Print("ScenarioDONE", stageDescription)
						local questID = 1001
						local criteriaIndex = 1
						local completed = false
						local amountCompleted = tostring(0).."/"..(1)
						local name = "Scenario:"..stageName.." "..currentStage.."/"..numStages
						--EMA:Print("scenarioProgressInfo", questID, name, criteriaIndex, stageDescription , amountCompleted , totalQuantity, completed )																									 
						EMA:DoQuestWatchObjectiveUpdate( EMA.characterName, questID, name, numCriteria, stageDescription , amountCompleted , totalQuantity, completed )
					end
	 
				else
				for criteriaIndex = 1, numCriteria do																   
				local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed = C_Scenario.GetCriteriaInfo(criteriaIndex)																
				--Ebony to fix a bug with character trial quest (this might be a blizzard bug) TODO relook at somepoint in beta.
					if (criteriaString) then
						local questID = 1001
						local amountCompleted = tostring( quantity ).."/"..( totalQuantity ) 
						--EMA:Print("Stages", numStages)
						local name = nil
							if (numStages) > 1 then
								local textName = "Scenario:"..stageName.." "..currentStage.."/"..numStages
								newName = textName
							else
								local textName = "Scenario:"..stageName
								newName = textName
							end
							local name = newName																				  
							--EMA:Print("test", questID, name, criteriaIndex, criteriaString , amountCompleted , completed, completed)
							EMA:DoQuestWatchObjectiveUpdate( EMA.characterName, questID, name, criteriaIndex, criteriaString , amountCompleted , completed, completed )
						end
					end	
				end
			end
		end
	-- SCENARIO_BONUS
		local tblBonusSteps = C_Scenario.GetBonusSteps()
		if #tblBonusSteps > 0 then
			--EMA:Print("BonusTest", #tblBonusSteps )
		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i]
			--EMA:Print("bonusIndex", bonusStepIndex)
			local stageName, stageDescription, numCriteria = C_Scenario.GetStepInfo(bonusStepIndex)
			--EMA:Print("bonusInfo", numCriteria, stageName, stageDescription) 
			for criteriaIndex = 1, numCriteria do
				--EMA:Print("Player has", numCriteria, "Criterias", "and is checking", criteriaIndex)
				local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex)
				local questID = assetID
				local amountCompleted = tostring(quantity).."/"..(totalQuantity)
				local name = "ScenarioBouns:"..stageName --.." "..currentStage.."/"..numStages
				--EMA:Print("scenarioBouns", questID, name, criteriaIndexa, criteriaString , amountCompleted , totalQuantity, completed )																											
				EMA:DoQuestWatchObjectiveUpdate( EMA.characterName, questID, name, criteriaIndex, criteriaString , amountCompleted , completed, completed )							
			end
		end
	end
	EMA.QUESTWATCHUPDATING = false
end

function EMA:EMAQuestWatcherQuestLogUpdate( useCache )
		if EMA.QUESTWATCHUPDATING == true then
			return
		end	
		--EMA:Print("QUESTWATCHUPDATINGS")
		EMA.QUESTWATCHUPDATING = true
		local index = C_QuestLog.GetNumQuestLogEntries()
		for iterateQuests = 1, index do	
			local info =  C_QuestLog.GetInfo( iterateQuests )	
			if info.questID ~= nil and QuestUtils_IsQuestWatched(info.questID) == true then
				--EMA:Print("testAA", info.title, info.questLogIndex, info.questID, info.campaignID, info.level, info.difficultyLevel, info.suggestedGroup, info.frequency, info.isHeader, info.isCollapsed, info.startEvent, info.isTask, info.isBounty, info.isStory, info.isScaling, info.isOnMap, info.hasLocalPOI, info.isHidden, info.isAutoComplete, info.overridesSortOrder, info.readyForTranslation )
				local questLogIndex = C_QuestLog.GetLogIndexForQuestID(info.questID)
				local numObjectives = GetNumQuestLeaderBoards(questLogIndex )
				local isComplete = C_QuestLog.IsComplete( info.questID)
				--local isComplete = EMA:IsCompletedAutoCompleteFieldQuest( questIndex, isComplete )
				if info.isHeader == false and info.isHidden == false then
				--EMA:Print("EMAQuestData", questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI, isHidden)
				if numObjectives > 0 then							 
					for iterateObjectives = 1, numObjectives do
						--EMA:Print( "NumObjs:", numObjectives )
						local objectiveFullText, objectiveType, objectiveFinished = GetQuestLogLeaderBoard( iterateObjectives, questLogIndex )																								
						local amountCompleted, objectiveText = EMA:GetQuestObjectiveCompletion( objectiveFullText, objectiveType )
						
						if objectiveType == "progressbar" then
							local progress = GetQuestProgressBarPercent( info.questID )
							objectiveText = "ProgressBar"..": "..objectiveText 
							amountCompleted = tostring(progress)..L["%"]
						end
						if objectiveFullText ~= nil then																												
							--EMA:Print("test2", info.questID, info.title, iterateObjectives, objectiveText, amountCompleted, objectiveFinished, isComplete )
							if (EMA:QuestCacheUpdate( info.questID, iterateObjectives, amountCompleted, objectiveFinished ) == true) or (useCache == false) then
								EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_WATCH_OBJECTIVE_UPDATE, info.questID, info.title, iterateObjectives, objectiveText, amountCompleted, isComplete, isComplete )																		   
							end
						end
					end	
				else
					local objectiveFullText = GetQuestLogCompletionText(questLogIndex)
					local iterateObjectives = 0
					local amountCompleted, objectiveText = EMA:GetQuestObjectiveCompletion( objectiveFullText )
					local objectiveFinished = true
					--EMA:Print("test3", info.questID, info.title, iterateObjectives, objectiveText, amountCompleted, objectiveFinished, isComplete )
					if (EMA:QuestCacheUpdate( info.questID, info.title, amountCompleted, objectiveFinished ) == true) or (useCache == false) then
						EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_WATCH_OBJECTIVE_UPDATE, info.questID, info.title, iterateObjectives, objectiveText, amountCompleted, isComplete, isComplete )
					end
				end
			end			
		end
	end
	--EMA:Print("QUESTWATCHUPDATING DONE")
	EMA.QUESTWATCHUPDATING = false
end

function EMA:EMAQuestWatcherWorldQuestUpdate( useCache )
	--EMA:Print("fireworldquestUpdate")
	--for i = 1, GetNumQuestLogEntries() do
	local index = C_QuestLog.GetNumQuestLogEntries()
	for iterateQuests = 1, index do	
		local info =  C_QuestLog.GetInfo( iterateQuests )	
		local questIndex = C_QuestLog.GetLogIndexForQuestID(info.questID)
		---local title, level, suggestedGroup, isHeader, isCollapsed, _ , frequency, questID = GetQuestLogTitle(i)
		local isInArea, isOnMap, numObjectives = GetTaskInfo(info.questID)				  
		local isComplete = C_QuestLog.IsComplete( info.questID)
		--local isComplete = EMA:IsCompletedAutoCompleteFieldQuest( questIndex, IsComplete )		
			
			if isInArea and isOnMap then
			for iterateObjectives = 1, numObjectives do
				--EMA:Print("test", questID, iterateObjectives, isComplete)
				local objectiveFullText, objectiveType, objectiveFinished = GetQuestObjectiveInfo( info.questID, iterateObjectives, isComplete )
				local amountCompleted, objectiveText = EMA:GetQuestObjectiveCompletion( objectiveFullText )																											  
				if objectiveType == "progressbar"  then	  
					local objectiveText = "ProgressBar"
					local progress = GetQuestProgressBarPercent( info.questID )
					local amountCompleted = tostring(progress)..L["%"]																											
					--EMA:Print("QuestPercent", title, objectiveText, amountCompleted )
					local EditedQuestName = tostring("Bonus:")..(info.title)	
					--EMA:Print("BarQuest", info.questID, name, iterateObjectives, objectiveText, amountCompleted, objectiveFinished, isComplete)
					if (EMA:QuestCacheUpdate( info.questID, iterateObjectives, amountCompleted, objectiveFinished ) == true) or (useCache == false) then
						EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_WATCH_OBJECTIVE_UPDATE, info.questID, EditedQuestName, iterateObjectives, objectiveText, amountCompleted, objectiveFinished, isComplete )															 
					end
			else
				local amountCompleted, objectiveText = EMA:GetQuestObjectiveCompletion( objectiveFullText )
				if (EMA:QuestCacheUpdate( info.questID, iterateObjectives, amountCompleted, objectiveFinished ) == true) or (useCache == false) then									   
					--EMA:Print( "UPDATE:", "cache:", useCache, "QuestID", questID, "ObjectID", iterateObjectives )
					--EMA:Print("sendingquestdata", info.title, info.questID, objectiveText, amountCompleted, finished )
					local name = tostring("Bonus:")..(info.title)
					EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_WATCH_OBJECTIVE_UPDATE, info.questID, name, iterateObjectives, objectiveText, amountCompleted, objectiveFinished, isComplete )
					end
				end
			end
		end	
	end
	EMA.QUESTWATCHUPDATING = false	
end

function EMA:EMAQuestWatcherUpdate( useCache, questType )
	if EMA.db.enableQuestWatcher == false then
		return
	end
	--EMA:Print("updateQuestList", useCache, questType )
	if questType == "scenario" or "all" then
		EMA:EMAQuestWatcherScenarioUpdate(useCache)
	end
	if questType == "quest" or "all" then
		EMA:EMAQuestWatcherQuestLogUpdate( useCache )
	end
	if questType == "worldQuest" or "all" then
		EMA:EMAQuestWatcherWorldQuestUpdate( useCache )
	end
	
end

-- Gathers messages from team.
function EMA:DoQuestWatchObjectiveUpdate( characterName, questID, questName, objectiveIndex, objectiveText, amountCompleted, objectiveFinished, isComplete )
	EMA:UpdateQuestWatchList( questID, questName, objectiveIndex, objectiveText, characterName, amountCompleted, objectiveFinished, isComplete )
end

function EMA:UpdateQuestWatchList( questID, questName, objectiveIndex, objectiveText, characterName, amountCompleted, objectiveFinished, isComplete )
    --local characterName = (( Ambiguate( name, "none" ) ))
	--EMA:Print( "UpdateQuestWatchList", questID, questName, objectiveIndex, objectiveText, characterName, amountCompleted, objectiveFinished, isComplete )
	local questHeaderPosition = EMA:GetQuestHeaderInWatchList( questID, questName, characterName )
	local objectiveHeaderPosition = EMA:GetObjectiveHeaderInWatchList( questID, questName, objectiveIndex, objectiveText, "", questHeaderPosition )
	local characterPosition = EMA:GetCharacterInWatchList( questID, objectiveIndex, characterName, amountCompleted, objectiveHeaderPosition, objectiveFinished )	
	local totalAmountCompleted = EMA:GetTotalCharacterAmountFromWatchList( questID, objectiveIndex )																	
	objectiveHeaderPosition = EMA:GetObjectiveHeaderInWatchList( questID, questName, objectiveIndex, objectiveText, totalAmountCompleted, questHeaderPosition )
	-- isComplete piggybacks on the quest watch update, so we are always displaying a complete quest button (in case the QUEST_AUTOCOMPLETE event does not fire).
	if isComplete == true then
		-- Do feel we need this!
		--EMA:DoAutoQuestFieldComplete( characterName, questID )
	end
	if EMA.db.hideQuestIfAllComplete == true then
		EMA:CheckQuestForAllObjectivesCompleteAndHide( questID )
	end	
	EMA:QuestWatcherQuestListScrollRefresh()
	EMA:SetQuestWatcherVisibility()
end

-------------------------------------------------------------------------------------------------------------

function EMA:RemoveQuestFromWatchList( questID )
	EMA:RemoveQuestFromWatcherCache( questID )
	EMA:EMASendCommandToTeam( EMA.COMMAND_QUEST_WATCH_REMOVE_QUEST, questID )
end

function EMA:DoRemoveQuestFromWatchList( characterName, questID )
	-- Remove character lines for this character.
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		if questWatchInfo.questID == questID and questWatchInfo.character == characterName then
			EMA:RemoveQuestWatchInfo( questWatchInfo.key )	
		end
	end
	-- See if any character lines left, if none, then remove quest completely.
	local found = false
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		if questWatchInfo.questID == questID and questWatchInfo.type == "CHARACTER_AMOUNT" then
			found = true
		end
	end
	if found == false then
		for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
			local questWatchInfo = questWatchInfoContainer.info
			if questWatchInfo.questID == questID then
				EMA:RemoveQuestWatchInfo( questWatchInfo.key )	
			end
		end
	else
		-- Still some character lines left, update the total amount of objectives to reflect lost team member.
		-- Find any remaining quest objective headers.
		for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
			local questWatchInfo = questWatchInfoContainer.info
			if questWatchInfo.questID == questID and questWatchInfo.type == "OBJECTIVE_HEADER" then
				questWatchInfo.amount = EMA:GetTotalCharacterAmountFromWatchList( questID, questWatchInfo.objectiveIndex )
				-- If all done auto-collapse when complete, collapse objective header.
				if (questWatchInfo.amount == L["DONE"]) and (EMA.db.doNotHideCompletedObjectives == true) then
					questWatchInfo.childrenAreHidden = true
				end
			end
			if questWatchInfo.questID == questID and questWatchInfo.type == "QUEST_HEADER" then
				EMA:UpdateTeamQuestCountRemoveCharacter( questWatchInfo, characterName )
				if EMA.db.hideQuestIfAllComplete == true then
					EMA:CheckQuestForAllObjectivesCompleteAndHide( questID )
				end
			end
		end
	end
	-- Remove any auto quest buttons.
	EMA:DoRemoveAutoQuestFieldComplete( characterName, questID )
	EMA:QuestWatcherQuestListScrollRefresh()
	EMA:SetQuestWatcherVisibility()
end

-------------------------------------------------------------------------------------------------------------
-- QUEST WATCH DISPLAY LIST LOGIC
-------------------------------------------------------------------------------------------------------------

					
function EMA:GetTotalCharacterAmountFromWatchList( questID, objectiveIndex )
	local amount = 0
	local total = 0
	local countCharacters = 0
	local countDones = 0
	local questType = nil
	local amountOverTotal = nil
	local ProgressQuest = nil
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		local position = questWatchInfoContainer.position
		if questWatchInfo.questID == questID and questWatchInfo.type == "CHARACTER_AMOUNT" and questWatchInfo.objectiveIndex == objectiveIndex then
			countCharacters = countCharacters + 1
			local amountCompletedText = questWatchInfo.amount
			if amountCompletedText == L["DONE"] then
				countDones = countDones + 1
			end
			local arg1, arg2 = string.match(amountCompletedText, "(%d*)/(%d*)")										   
			if (arg1 ~= nil) and (arg2 ~= nil) then
				if strtrim( arg1 ) ~= "" and strtrim( arg2 ) ~= "" then
					amount = amount + tonumber( arg1 )
					total = total + tonumber( arg2 )
				end
			else
				local arg1 = string.match(amountCompletedText, "(%d*)")
				if (arg1 ~= nil) then
					if strtrim( arg1 ) ~= "" then
						amount = amount
						total = total + tonumber( arg1 )
						ProgressQuest = true
					end	
				end	
			end
		end
		if questWatchInfo.questID == questID and questWatchInfo.type == "OBJECTIVE_HEADER" and string.find( questWatchInfo.information, "ProgressBar" ) then
			questType = "ProgressBar"	
		end
	end
	if countCharacters == 0 then
		return L["DONE"]
	end
	if questType == "ProgressBar" and ProgressQuest == true then
		local totalChars = (100 * countCharacters)
		local maths = (total / totalChars) * 100
		amountOverTotal = maths..L["%"]
	else
		if amount == total then
			amountOverTotal = L["DONE"]
		else	
			amountOverTotal = string.format( "%s/%s", amount, total )
		end	
    end
	EMA:DebugMessage( "AMTOT:", amountOverTotal )
		if amountOverTotal == "0/0" then
			--EMA:Print("test", countDones, countCharacters)
			if countDones == countCharacters then
				amountOverTotal = L["DONE"]
			else
				amountOverTotal = L["N/A"]
			end
		end
	return amountOverTotal
end

function EMA:RemoveQuestsNotBeingWatched()
	EMA:UpdateAllQuestsInWatchList()
	for checkQuestID, value in pairs( EMA.questWatchListOfQuests ) do
		local found = false
		local IsOnQuest = C_QuestLog.IsOnQuest(checkQuestID)
		if IsOnQuest == true then
			--EMA:Print("foundQuest", checkQuestID)
			found = true
		end
		if found == false then
			EMA:RemoveQuestFromWatchList( checkQuestID )
		end
	end
end

function EMA:UpdateAllQuestsInWatchList()
	table.wipe( EMA.questWatchListOfQuests )
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		-- TODO- whats going on here?
		EMA.questWatchListOfQuests[questWatchInfoContainer.info.questID] = true
	end
end

function EMA:GetCharacterInWatchList( questID, objectiveIndex, characterName, amountCompleted, objectiveHeaderPosition, objectiveFinished )
	local characterPosition = -1
	local characterQuestWatchInfo
	if objectiveFinished then
		if EMA.db.showCompletedObjectivesAsDone == true then
			amountCompleted = L["DONE"]
		end
	end
	-- Try and find the character line.	
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		local position = questWatchInfoContainer.position
		if questWatchInfo.questID == questID and questWatchInfo.type == "CHARACTER_AMOUNT" and questWatchInfo.objectiveIndex == objectiveIndex and questWatchInfo.character == characterName then
			-- Character line found.  Update information.
			questWatchInfo.amount = amountCompleted							  
			characterQuestWatchInfo = questWatchInfo
			characterPosition = position
			break
		end
	end
	-- Was not found, add character line.
	if characterPosition == -1 then
		-- Only if not completed or user wants to show completed.
		if ((objectiveFinished == nil) or (objectiveFinished == false)) or (EMA.db.doNotHideCompletedObjectives == true) then	
			local questWatchInfo = EMA:CreateQuestWatchInfo( questID, "CHARACTER_AMOUNT", objectiveIndex, characterName, characterName, amountCompleted )
			EMA:InsertQuestWatchInfoToListAfterPosition( questWatchInfo, objectiveHeaderPosition )
			return objectiveHeaderPosition + 1
		end
		return -1
	else
		-- Character line was found.  Remove it if objective finished?
		if (objectiveFinished) and (EMA.db.doNotHideCompletedObjectives == false) then
			EMA:RemoveQuestWatchInfo( characterQuestWatchInfo.key )
			return -1
		end			
	end
	return -1
end

function EMA:GetObjectiveHeaderInWatchList( questID, questName, objectiveIndex, objectiveText, totalAmountCompleted, questHeaderPosition )
	--EMA:Print("testposition", questName, "oT", objectiveText, questHeaderPosition)
	if strtrim( objectiveText ) == "" then
		objectiveText = questName
	end
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		local position = questWatchInfoContainer.position
		if questWatchInfo.questID == questID and questWatchInfo.type == "OBJECTIVE_HEADER" and questWatchInfo.objectiveIndex == objectiveIndex then
			questWatchInfo.information = objectiveText
			questWatchInfo.amount = totalAmountCompleted
			-- If all done auto-collapse when complete, collapse objective header.
			if (questWatchInfo.amount == L["DONE"]) and (EMA.db.doNotHideCompletedObjectives == true) then
				questWatchInfo.childrenAreHidden = true
			end
			return position
		end
	end
	local questWatchInfo = EMA:CreateQuestWatchInfo( questID, "OBJECTIVE_HEADER", objectiveIndex, "", objectiveText, totalAmountCompleted )
	-- Hide the team list by default.
	questWatchInfo.childrenAreHidden = true
	EMA:InsertQuestWatchInfoToListAfterPosition( questWatchInfo, questHeaderPosition )
	return questHeaderPosition + 1	
end

function EMA:GetQuestItemFromQuestID(findQuestID)
	--for iterateQuests=1,GetNumQuestLogEntries() do
	--	local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(iterateQuests)
	local index = C_QuestLog.GetNumQuestLogEntries()
	for iterateQuests = 1, index do	
		local info =  C_QuestLog.GetInfo( iterateQuests )
		--if title ~= nil then
		if not info.isHeader then	
			if findQuestID == info.questID then
				local questItemLink, questItemIcon, questItemCharges = GetQuestLogSpecialItemInfo( iterateQuests )
				if questItemLink then
					--EMA:Print("Item", questItemLink, questItemIcon, questID)
					return questItemLink, questItemIcon
				else
					return nil, nil
				end	
			end
		end
	end
end	

local function GetInlineFactionIcon()
	local faction = UnitFactionGroup("player");
	local coords = faction == "Horde" and QUEST_TAG_TCOORDS.HORDE or QUEST_TAG_TCOORDS.ALLIANCE;
	return CreateTextureMarkup(QUEST_ICONS_FILE, QUEST_ICONS_FILE_WIDTH, QUEST_ICONS_FILE_HEIGHT, 18, 18
	, coords[1]
	, coords[2] - 0.02 -- Offset to stop bleeding from next image
	, coords[3]
	, coords[4], 0, 2);
end

function EMA:GetQuestHeaderInWatchList( questID, questName, characterName )
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		local position = questWatchInfoContainer.position
		if questWatchInfo.questID == questID and questWatchInfo.type == "QUEST_HEADER" then
			EMA:UpdateTeamQuestCountAddCharacter( questWatchInfo, characterName )
   
			if EMA.db.hideQuestIfAllComplete == true then
				EMA:CheckQuestForAllObjectivesCompleteAndHide( questID )
			end
			return position
		end
	end
	local questItemLink, questItemIcon = EMA:GetQuestItemFromQuestID(questID)
	local icon = ""
	if ( questItemIcon ~= nil ) then
		icon = strconcat(" |T"..questItemIcon..":18|t".."  ")
	end
	if (C_CampaignInfo.IsCampaignQuest(questID) ) then
			--EMA:Print("CampaignQuest", questName)
		icon = GetInlineFactionIcon()
	end	
	local questWatchInfo = EMA:CreateQuestWatchInfo( questID, "QUEST_HEADER", -1, "", questName, icon )
	
	EMA:UpdateTeamQuestCountAddCharacter( questWatchInfo, characterName )
	if EMA.db.hideQuestIfAllComplete == true then
		EMA:CheckQuestForAllObjectivesCompleteAndHide( questID )
	end	
	local newPositionAtEnd = EMA:GetQuestWatchMaximumOrder() + 1	
	EMA:AddQuestWatchInfoToListAtPosition( questWatchInfo, newPositionAtEnd )
	return newPositionAtEnd
end

function EMA:UpdateTeamQuestCount( questWatchInfo, characterName )
	local count = 0
	for character, dummy in pairs( questWatchInfo.teamCharacters ) do
		count = count + 1
	end
	questWatchInfo.questTeamCount = count
end

function EMA:UpdateTeamQuestCountAddCharacter( questWatchInfo, name )

	questWatchInfo.teamCharacters[name] = true
	EMA:UpdateTeamQuestCount( questWatchInfo, name )
end

function EMA:UpdateTeamQuestCountRemoveCharacter( questWatchInfo, characterName )
	questWatchInfo.teamCharacters[characterName] = nil
	EMA:UpdateTeamQuestCount( questWatchInfo, characterName )
end

function EMA:CheckQuestForAllObjectivesCompleteAndHide( questID )
	if EMA.db.hideQuestIfAllComplete == false then
		return
	end
	-- If all objective headers for quest say "DONE" then hide quest if hideQuestIfAllComplete option set.
	local allDone = true
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		if questWatchInfo.questID == questID and questWatchInfo.type == "OBJECTIVE_HEADER" then	
			if questWatchInfo.amount ~= L["DONE"] then
				allDone = false
			end
		end
	end	
	-- Set quest header hidden or not as appropriate.
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		if questWatchInfo.questID == questID and questWatchInfo.type == "QUEST_HEADER" then
			questWatchInfo.childrenAreHidden = allDone
		end
	end	
end

-------------------------------------------------------------------------------------------------------------
-- QUEST WATCH INFO FUNCTIONS
-------------------------------------------------------------------------------------------------------------

function EMA:CreateQuestWatchInfo( questID, type, objectiveIndex, character, information, amount )
	local questWatchInfo = {}
	questWatchInfo.key = questID..type..objectiveIndex..character
	questWatchInfo.questID = questID
	questWatchInfo.type = type
	questWatchInfo.objectiveIndex = objectiveIndex
	questWatchInfo.character = character
	questWatchInfo.information = information
	questWatchInfo.amount = amount
	questWatchInfo.childrenAreHidden = false
	questWatchInfo.questTeamCount = 0
	questWatchInfo.teamCharacters = {}
	return questWatchInfo 
end

function EMA:AddQuestWatchInfoToListAtPosition( questWatchInfo, position )
	EMA.questWatchObjectivesList[questWatchInfo.key] = {}
	EMA.questWatchObjectivesList[questWatchInfo.key].position = position
	EMA.questWatchObjectivesList[questWatchInfo.key].info = questWatchInfo
end

function EMA:InsertQuestWatchInfoToListAfterPosition( questWatchInfo, position )
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		local checkPosition = questWatchInfoContainer.position
		if checkPosition > position then
			questWatchInfoContainer.position = checkPosition + 1
		end
	end
	EMA:AddQuestWatchInfoToListAtPosition( questWatchInfo, position + 1 )
end

function EMA:RemoveQuestWatchInfo( key )
	local removedPosition = EMA.questWatchObjectivesList[key].position
	for checkKey, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local checkPosition = questWatchInfoContainer.position
		if checkPosition > removedPosition then
			questWatchInfoContainer.position = checkPosition - 1
		end
	end
	EMA.questWatchObjectivesList[key].info.key = nil
	EMA.questWatchObjectivesList[key].info.questID = nil
	EMA.questWatchObjectivesList[key].info.type = nil
	EMA.questWatchObjectivesList[key].info.objectiveIndex = nil
	EMA.questWatchObjectivesList[key].info.character = nil
	EMA.questWatchObjectivesList[key].info.information = nil
	EMA.questWatchObjectivesList[key].info.amount = nil
	EMA.questWatchObjectivesList[key].info.childrenAreHidden = nil
	EMA.questWatchObjectivesList[key].info.questTeamCount = nil
	table.wipe( EMA.questWatchObjectivesList[key].info.teamCharacters )
	table.wipe( EMA.questWatchObjectivesList[key].info )
	EMA.questWatchObjectivesList[key].info = nil
	EMA.questWatchObjectivesList[key].position = nil
	table.wipe( EMA.questWatchObjectivesList[key] )
	EMA.questWatchObjectivesList[key] = nil
end

-- Get the largest order number from the quest watch list.
function EMA:GetQuestWatchMaximumOrder()
	local largestPosition = 0
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		local position = questWatchInfoContainer.position	
		if position > largestPosition then
			largestPosition = position
		end
	end
	return largestPosition
end

function EMA:GetQuestWatchInfoFromKey( key )
	local questWatchInfo = EMA.questWatchObjectivesList[key].info
	return questWatchInfo.information, questWatchInfo.amount, questWatchInfo.type, questWatchInfo.questID, questWatchInfo.childrenAreHidden, key, questWatchInfo.objectiveIndex			
end

-- Get the quest watch info at a specific position.
function EMA:GetQuestWatchInfoAtOrderPosition( position )
	local information = ""
	local amount = ""
	local type = ""
	local questID = ""
	local childrenAreHidden = ""
	local key = ""
	local questTeamCount = ""
	local objectiveIndex = ""
	for keyStored, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		local questWatchInfo = questWatchInfoContainer.info
		local questWatchPosition = questWatchInfoContainer.position		
		if questWatchPosition == position then
			information = questWatchInfo.information
			amount = questWatchInfo.amount
			type = questWatchInfo.type
			questID = questWatchInfo.questID
			childrenAreHidden = questWatchInfo.childrenAreHidden
			key = keyStored
			questTeamCount = questWatchInfo.questTeamCount
			objectiveIndex = questWatchInfo.objectiveIndex
			break
		end
	end
	return information, amount, type, questID, childrenAreHidden, key, questTeamCount, objectiveIndex
end

function EMA:ToggleChildrenAreHiddenQuestWatchInfoByKey( key )
	local questWatchInfo = EMA.questWatchObjectivesList[key].info
	questWatchInfo.childrenAreHidden = not questWatchInfo.childrenAreHidden
end

function EMA:CountLinesInQuestWatchList()
	if EMA.questWatchObjectivesList == nil then
		return 1
	end
	local count = 1
	for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
		count = count + 1
	end
	return count
end

-------------------------------------------------------------------------------------------------------------
-- QUEST WATCH DISPLAY LIST MECHANICS
-------------------------------------------------------------------------------------------------------------

function EMA:QuestWatcherQuestListDrawLine( frame, iterateDisplayRows, type, information, amount, childrenAreHidden, key, questTeamCount, questID )
	local toggleDisplay = ""
	local padding = ""
	local teamCount = ""
	local textFont = EMA.SharedMedia:Fetch( "font", EMA.db.watchFontStyle )
	local textSize = EMA.db.watchFontSize
	if type == "CHARACTER_AMOUNT" then
		padding = "        "
	end
	if type == "OBJECTIVE_HEADER" then
		padding = "    "	
		if childrenAreHidden == true then
			toggleDisplay = "+ "
		else
			toggleDisplay = "- "
		end
	end
	if type == "QUEST_HEADER" then
		if questTeamCount ~= 0 then							  
			teamCount = " ("..questTeamCount.."/"..EMAApi.GetTeamListMaximumOrderOnline()..") "			
		end
	end	
	frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetFont( textFont , textSize , "OUTLINE")
	frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetFont( textFont , textSize , "OUTLINE")
	--EMA:Print("test2343", type, information )
	local matchData = string.find( information, "Bonus:" )
	local matchDataScenario = string.find( information, "Scenario:" )
	local matchDataScenarioBouns = string.find( information, "ScenarioBouns:" )
	-- Scenario
	if matchDataScenario then
		local name = gsub(information, "[^|]+:", "")
		frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetText( padding..toggleDisplay..name )
		frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetText( amount )
			frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 0, 1.0, 1.0, 1.0 )
			frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 0, 1.0, 1.0, 1.0 )
		if InCombatLockdown() == false then
			frame.questWatchList.rows[iterateDisplayRows].columns[1]:EnableMouse( false )
			frame.questWatchList.rows[iterateDisplayRows].columns[2]:EnableMouse( false )	
		end
	-- Scenario Bouns
	elseif matchDataScenarioBouns then
		local name = gsub(information, "[^|]+:", "")
		frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetText( padding..toggleDisplay..name )
		frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetText( amount )
			frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 0, 0.30, 1.0, 1.0, 1.0 )
			frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 0, 0.30, 1.0, 1.0, 1.0 )	
		if InCombatLockdown() == false then
			frame.questWatchList.rows[iterateDisplayRows].columns[1]:EnableMouse( false )
			frame.questWatchList.rows[iterateDisplayRows].columns[2]:EnableMouse( false )	
		end															   
	else
		frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetText( padding..toggleDisplay..teamCount..information )
		frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetText( amount )
		if type == "QUEST_HEADER" then
			if matchData then
				frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 0, 0, 1.0, 1.0 )
				frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 0, 0, 1.0, 1.0 )	
			else
				frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 0.96, 0.41, 1.0 )
				frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 0.96, 0.41, 1.0 )
			end
		
		end
		if InCombatLockdown() == false then
			frame.questWatchList.rows[iterateDisplayRows].columns[1]:EnableMouse( true )
			frame.questWatchList.rows[iterateDisplayRows].columns[2]:EnableMouse( true )	
		end		
	end

	if type == "OBJECTIVE_HEADER" then
		--EMA:Print("Match", information)
		local matchData = string.find( information, "ProgressBar" )
		if matchData then
			--EMA:Print("Match", information)
			frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 0.50, 0.50, 1.0 )
			frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 0.50, 0.50, 1.0 )
			-- Turn on the mouse for these buttons.
		else
			frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1.0 )
			frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetTextColor( NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1.0 )
			-- Turn on the mouse for these buttons.
		end
	end
	local questItemLink, questItemIcon = EMA:GetQuestItemFromQuestID(questID)
	if questItemLink ~= nil and type == "QUEST_HEADER" then
		EMA:UpdateQuestItemButton( iterateDisplayRows, questItemLink )
		
	end
	frame.questWatchList.rows[iterateDisplayRows].key = key
end

function EMA:QuestWatcherQuestListScrollRefresh()
	local frame = EMAQuestWatcherFrame
	FauxScrollFrame_Update(
		frame.questWatchList.listScrollFrame, 
		EMA:GetQuestWatchMaximumOrder(),
		frame.questWatchList.rowsToDisplay, 
		frame.questWatchList.rowHeight
	)
	frame.questWatchListOffset = FauxScrollFrame_GetOffset( frame.questWatchList.listScrollFrame )
	frame.dataRowOffset = 0
	local atLeastOneRowShowing = false
	local afterTextEdit = false
	for iterateDisplayRows = 1, frame.questWatchList.rowsToDisplay do
		-- Reset.
		frame.questWatchList.rows[iterateDisplayRows].key = ""
		frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		frame.questWatchList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		frame.questWatchList.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		frame.questWatchList.rows[iterateDisplayRows].highlight:SetTexture( 0.0, 0.0, 0.0, 1.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + frame.questWatchListOffset + frame.dataRowOffset
		local foundDataRow = false
		local finishedRows = false
		while (foundDataRow == false) and (finishedRows == false) do
			dataRowNumber = iterateDisplayRows + frame.questWatchListOffset + frame.dataRowOffset
			if dataRowNumber > EMA:GetQuestWatchMaximumOrder() then
				finishedRows = true
			else		
				local information, amount, type, questID, childrenAreHidden, key, questTeamCount, objectiveIndex = EMA:GetQuestWatchInfoAtOrderPosition( dataRowNumber )
				
				foundDataRow = true
				if type == "QUEST_HEADER" then
					-- In this case, children are hidden refers to itself as well.
					if childrenAreHidden == true then
						foundDataRow = false
						frame.dataRowOffset = frame.dataRowOffset + 1
					end
				end
				if type == "OBJECTIVE_HEADER" then
					local hideMe = false
					for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
						local questWatchInfo = questWatchInfoContainer.info
						if questWatchInfo.questID == questID and questWatchInfo.type == "QUEST_HEADER" then
							hideMe = questWatchInfo.childrenAreHidden
							break
						end
					end
					if hideMe == true then
						foundDataRow = false
						frame.dataRowOffset = frame.dataRowOffset + 1
					end				
				end
				-- If this is a character_amount type, find its parent objective header and see if its children are hidden.
				if type == "CHARACTER_AMOUNT" then
					local hideMe = false
					for key, questWatchInfoContainer in pairs( EMA.questWatchObjectivesList ) do
						local questWatchInfo = questWatchInfoContainer.info
						if questWatchInfo.questID == questID and questWatchInfo.type == "OBJECTIVE_HEADER" and questWatchInfo.objectiveIndex ==  objectiveIndex then
							hideMe = questWatchInfo.childrenAreHidden
							break
						end
					end
					if hideMe == true then
						foundDataRow = false
						frame.dataRowOffset = frame.dataRowOffset + 1
					end
				end
			end
	
			-- Put information and amount into columns.
			local information, amount, type, questID, childrenAreHidden, key, questTeamCount, objectiveIndex = EMA:GetQuestWatchInfoAtOrderPosition( dataRowNumber )
			EMA:QuestWatcherQuestListDrawLine( frame, iterateDisplayRows, type, information, amount, childrenAreHidden, key, questTeamCount, questID )
			atLeastOneRowShowing = true
		end
	end
	-- Adjust the scroll frame based on hidden rows.
	if atLeastOneRowShowing == true then
		FauxScrollFrame_Update(
			frame.questWatchList.listScrollFrame, 
			EMA:GetQuestWatchMaximumOrder() - frame.dataRowOffset,
			frame.questWatchList.rowsToDisplay, 
			frame.questWatchList.rowHeight
		)
	end
	EMA:DisplayAutoQuestPopUps()
end


function EMA:QuestWatcherQuestListRowClick( rowNumber, columnNumber )
   -- EMA:Print( "QuestWatcherQuestListRowClick", rowNumber, columnNumber )
	local frame = EMAQuestWatcherFrame
	local key = frame.questWatchList.rows[rowNumber].key
	if key ~= nil and key ~= "" then
		local information, amount, type, questID, childrenAreHidden, keyStored = EMA:GetQuestWatchInfoFromKey( key )
        EMA:DebugMessage( "GetQuestWatchInfoFromKey", information, amount, type, questID, childrenAreHidden, keyStored, key )
		if type == "QUEST_HEADER" then
            if columnNumber == 1 then
				QuestMapFrame_OpenToQuestDetails( questID )
			end
			if columnNumber == 2 then
				local questItemLink, questItemIcon = EMA:GetQuestItemFromQuestID(questID)
				if questItemLink ~= nil then
					local itemName = GetItemInfo(questItemLink)
					EMA:UpdateQuestItemButton( rowNumber, itemName )
				end
		   end	
		end
		if type == "OBJECTIVE_HEADER" then
			if columnNumber == 1 then
				EMA:ToggleChildrenAreHiddenQuestWatchInfoByKey( key )
				EMA:QuestWatcherQuestListScrollRefresh()
			end
		end
	end
end					

function EMA.QuestWatcherQuestListRowRightClick( rowNumber, columnNumber )
	--EMA:Print("testRightClick", rowNumber, columnNumber )
	local frame = EMAQuestWatcherFrame
	local key = frame.questWatchList.rows[rowNumber].key
	if key ~= nil and key ~= "" then
		local information, amount, type, questID, childrenAreHidden, keyStored = EMA:GetQuestWatchInfoFromKey( key )
		--EMA:Print("test", questID)
		if type == "QUEST_HEADER" and columnNumber == 1 then	
			EMAQuestMapQuestOptionsDropDown.questID = questID	
			EMAQuestMapQuestOptionsDropDown.questText = information
			ToggleDropDownMenu(1, nil, EMAQuestMapQuestOptionsDropDown, "cursor", 6, -6)
		end	
	end
end

function EMA.QuestWatcherQuestListRowOnEnter( rowNumber, columnNumber )
	--EMA:Print("MouseOver", rowNumber, columnNumber)
	local frame = EMAQuestWatcherFrame
	local key = frame.questWatchList.rows[rowNumber].key
	local toolTipFrame = frame.questWatchList.rows[rowNumber].columns[columnNumber]
	if key ~= nil and key ~= "" then
		local information, amount, type, questID, childrenAreHidden, keyStored = EMA:GetQuestWatchInfoFromKey( key )
		--EMA:Print("test", information, questID)
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPRIGHT", toolTipFrame, "TOPLEFT", 0, 0)
		GameTooltip:SetOwner( toolTipFrame, "ANCHOR_PRESERVE")
		if type == "QUEST_HEADER" and columnNumber == 2 then
			local questItemLink, questItemIcon = EMA:GetQuestItemFromQuestID(questID)
			if questItemLink ~= nil then
				GameTooltip:SetHyperlink(questItemLink)
				GameTooltip:Show()
			end
		end	
			if columnNumber == 1 then
				toolTipFrame:SetAlpha( 1.0 )
				if ( HaveQuestData(questID) and GetQuestLogRewardXP(questID) == 0 and GetNumQuestLogRewardCurrencies(questID) == 0
					and GetNumQuestLogRewards(questID) == 0 and GetQuestLogRewardMoney(questID) == 0 and GetQuestLogRewardArtifactXP(questID) == 0 ) then
					GameTooltip:Hide()
					return
				end
				GameTooltip:AddLine(L["REWARDS"], 1, 0.82, 0, 1)
				GameTooltip:AddLine(L["REWARDS_TEXT"],1,1,1,1)
				GameTooltip:AddLine(" ")
				if ( not HaveQuestData(questID) ) then
					GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				else
					-- Taken From Blizzard BonusObjectiveTracker_ShowRewardsTooltip
					-- xp
					local xp = GetQuestLogRewardXP(questID);
					if ( xp > 0 ) then
						GameTooltip:AddLine(string.format(BONUS_OBJECTIVE_EXPERIENCE_FORMAT, xp), 1, 1, 1);
					end
					local artifactXP = GetQuestLogRewardArtifactXP(questID);
					if ( artifactXP > 0 ) then
						GameTooltip:AddLine(string.format(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT, artifactXP), 1, 1, 1);
					end
					-- currency
					QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, GameTooltip);
					-- honor
					local honorAmount = GetQuestLogRewardHonor(questID);
					if ( honorAmount > 0 ) then
						GameTooltip:AddLine(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format("Interface\\ICONS\\Achievement_LegionPVPTier4", honorAmount, HONOR), 1, 1, 1);
					end
					-- money
					local money = GetQuestLogRewardMoney(questID);
					if ( money > 0 ) then
						SetTooltipMoney(GameTooltip, money, nil);
					end
					-- items
					local numQuestRewards = GetNumQuestLogRewards(questID);
					for i = 1, numQuestRewards do
						local name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i, questID);
						local text;
						if ( numItems > 1 ) then
							text = string.format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(numItems), name);
						elseif( texture and name ) then
							text = string.format(BONUS_OBJECTIVE_REWARD_FORMAT, texture, name);
						end
					if( text ) then
						local color = ITEM_QUALITY_COLORS[quality];
						GameTooltip:AddLine(text, color.r, color.g, color.b);
					end
				end
				GameTooltip:Show()
			end
		end
	end
end


function  EMA.QuestWatcherQuestListRowOnLeave()
	GameTooltip:Hide()
end

function EMAQuestMapQuestOptionsDropDown_Initialize(self)
	CloseDropDownMenus()
	local questID = EMAQuestMapQuestOptionsDropDown.questID
	local questText = EMAQuestMapQuestOptionsDropDown.questText
	if (questID ~= 0 ) then
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
		
		local infoTitle = UIDropDownMenu_CreateInfo()
		infoTitle.text = questText
		infoTitle.isTitle = 1
		infoTitle.notCheckable = 1
		UIDropDownMenu_AddButton(infoTitle)
		
		local info = UIDropDownMenu_CreateInfo()
		info.isNotRadio = true
		info.notCheckable = true
		info.text = OBJECTIVES_STOP_TRACKING
		
		info.func = function(_, questID) EMA:QuestMapQuestOptions_ToggleTrackQuest(questID, questText) end
		info.arg1 = self.questID
		info.checked = false
		UIDropDownMenu_AddButton(info)
		
		if ( C_QuestLog.IsPushableQuest(questID) and IsInGroup() ) then
			info.text = SHARE_QUEST
			info.func = function(_, questID) EMA:QuestMapQuestOptions_ShareQuest(questID) end
			info.arg1 = self.questID
			UIDropDownMenu_AddButton(info)
		end
		info.text = ABANDON_QUEST
		info.func = function(_, questID) EMA:QuestMapQuestOptions_AbandonQuest(questID, questText) end
		info.arg1 = self.questID
		info.disabled = nil
		
		UIDropDownMenu_AddButton(info)

	end
end

function EMA:QuestMapQuestOptions_ToggleTrackQuest(questID, questText)
	--EMA:Print("test", questID, questText)
	EMAApi.EMAApiUnTrackQuest( questID, questText )
end

function EMA:QuestMapQuestOptions_ShareQuest( questID )
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
	if questLogIndex then
		QuestLogPushQuest(questLogIndex)
	end
end	

function EMA:QuestMapQuestOptions_AbandonQuest(questID, questText)
	EMAApi.EMAApiAbandonQuest(questID, questText)
end

function EMA:UpdateQuestItemButton( rowNumber, itemName )
	if InCombatLockdown() == false then
		local frame = EMAQuestWatcherFrame
		frame.questWatchList.rows[rowNumber].columns[2]:SetAttribute("type1", "item")
		frame.questWatchList.rows[rowNumber].columns[2]:SetAttribute( "item", itemName )
	end
end

------------------------------------------------------------------------------------------------------------
-- QUEST WATCH AUTO QUEST DISPLAY - MOSTLY BORROWED FROM BLIZZARD CODE
-------------------------------------------------------------------------------------------------------------

function EMA:HasAtLeastOneAutoQuestPopup()
	if #EMA.currentAutoQuestPopups == 0 then
		return false
	end
	return true
end

function EMA:EMAAddAutoQuestPopUp( questID, popUpType, characterName )
	--EMA:Print("addPopUP", questID, popUpType, characterName)
	if EMA.currentAutoQuestPopups[questID] == nil then
		EMA.currentAutoQuestPopups[questID] = {}
	end	
	EMA.currentAutoQuestPopups[questID][characterName] = popUpType
	EMA:DisplayAutoQuestPopUps()
end

function EMA:EMARemoveAutoQuestPopUp( questID, characterName )
	if EMA.currentAutoQuestPopups[questID] == nil then
		return
	end
	EMA.currentAutoQuestPopups[questID][characterName] = nil
	if #EMA.currentAutoQuestPopups[questID] == 0 then
		table.wipe( EMA.currentAutoQuestPopups[questID] )
		EMA.currentAutoQuestPopups[questID] = nil
	end
end

function EMA:EMARemoveAllAutoQuestPopUps( questID )
	if EMA.currentAutoQuestPopups[questID] == nil then
		return
	end
	table.wipe( EMA.currentAutoQuestPopups[questID] )
	EMA.currentAutoQuestPopups[questID] = nil
end

function EMA:AutoQuestGetOrCreateFrame( parent, index )
	if _G["EMAWatchFrameAutoQuestPopUp"..index] then
		return _G["EMAWatchFrameAutoQuestPopUp"..index]
	end
	local frame = CreateFrame( "SCROLLFRAME", "EMAWatchFrameAutoQuestPopUp"..index, parent )
	frame.index = index
    frame:EnableMouse( true )
    local QuestName = frame:CreateFontString( "EMAWatchFrameAutoQuestPopUpQuestName"..index, "OVERLAY", "GameFontNormal" )
    QuestName:SetPoint( "TOP", frame, "TOP", 0, -12 )
    QuestName:SetTextColor( 1.00, 1.00, 1.00 )
    QuestName:SetText( "" )
    frame.QuestName = QuestName
    local TopText = frame:CreateFontString( "EMAWatchFrameAutoQuestPopUpTopText"..index, "OVERLAY", "GameFontNormal" )
    TopText:SetPoint( "TOP", frame, "TOP", 0, -24 )
    TopText:SetTextColor( 1.00, 1.00, 1.00 )
    TopText:SetText( "" )
    frame.TopText = TopText
    local BottomText = frame:CreateFontString( "EMAWatchFrameAutoQuestPopUpBottomText"..index, "OVERLAY", "GameFontNormal" )
    BottomText:SetPoint( "TOP", frame, "TOP", 0, -36 )
    BottomText:SetTextColor( 1.00, 1.00, 1.00 )
    BottomText:SetText( "BottomText" )
    frame.BottomText = BottomText
	EMA.countAutoQuestPopUpFrames = EMA.countAutoQuestPopUpFrames + 1
	return frame
end

function EMA:DisplayAutoQuestPopUps()
	local nextAnchor
	local countPopUps = 0
	local iterateQuestPopups = 01
	EMAQuestWatcherFrame.autoQuestPopupsHeight = 0
	local parentFrame = EMAQuestWatcherFrame.fieldNotifications
	for questID, characterInfo in pairs( EMA.currentAutoQuestPopups ) do
		local title = C_QuestLog.GetTitleForQuestID(questID)
		local isComplete = C_QuestLog.IsComplete(questID)
		--EMA:Print("test", questID, title, isComplete )
		local characterName, characterPopUpType, popUpType
		local characterList = ""
		for characterName, characterPopUpType in pairs( characterInfo ) do
			--EMA:Print("popup", characterPopUpType)
			characterList = characterList..( Ambiguate( characterName, "none" ) ).." "
			-- TODO - hack, assuming all characters have the same sort of popup.
			popUpType = characterPopUpType
		end
		-- If the current character does not have the quest, show the character names that do have it.
		--[[
		local clickToViewText = QUEST_WATCH_POPUP_CLICK_TO_VIEW
			if not (title and title ~= "") then
				title = characterList
				clickToViewText = ""
			end
		]]
		local frame = EMA:AutoQuestGetOrCreateFrame( parentFrame, countPopUps + 1 )
		frame:Show()
		frame:ClearAllPoints()
		frame:SetParent( parentFrame )
		--EMA:Print("test2", isComplete, popUpType)
			if isComplete == true and popUpType == "COMPLETE" then
				frame.TopText:SetText( QUEST_WATCH_POPUP_CLICK_TO_COMPLETE )
				frame.BottomText:Hide()
				frame:SetHeight( 32 )
				frame.type = "COMPLETED"
				frame:HookScript( "OnMouseUp", function()
					ShowQuestComplete( questID )
					EMA:EMARemoveAllAutoQuestPopUps( questID )
					--EMA:DisplayAutoQuestPopUps()
					EMA:SettingsUpdateBorderStyle()
					EMA:SettingsUpdateFontStyle()
				end )
		elseif popUpType == "OFFER" then
			frame.TopText:SetText( QUEST_WATCH_POPUP_QUEST_DISCOVERED )
			frame.BottomText:Show()
			frame.BottomText:SetText( clickToViewText )
			frame:SetHeight( 48 )
			frame.type = "OFFER"
			frame:HookScript( "OnMouseUp", function()
				ShowQuestOffer( questID )
				EMA:EMARemoveAllAutoQuestPopUps( questID )
				--EMA:DisplayAutoQuestPopUps()
				EMA:SettingsUpdateBorderStyle()
				EMA:SettingsUpdateFontStyle()
				AutoQuestPopupTracker_RemovePopUp( questID )
			end )
		end
		frame:ClearAllPoints()
			if nextAnchor ~= nil then
				if iterateQuestPopups == 1 then
					frame:SetPoint( "TOP", nextAnchor, "BOTTOM", 0, 0 ) -- -WATCHFRAME_TYPE_OFFSET
				else
					frame:SetPoint( "TOP", nextAnchor, "BOTTOM", 0, 0 )
				end
			else
				frame:SetPoint( "TOP", parentFrame, "TOP", 0, 5 ) -- -WATCHFRAME_INITIAL_OFFSET
			end
		frame:SetPoint( "LEFT", parentFrame, "LEFT", -20, 0 )
		frame.QuestName:SetText( title )
		frame.questId = questID
		--frame:UpdateScrollChildRect()
		--frame:SetVerticalScroll( floor( -9 + 0.5 ) )
		nextAnchor = frame
		countPopUps = countPopUps + 1
		EMAQuestWatcherFrame.autoQuestPopupsHeight = EMAQuestWatcherFrame.autoQuestPopupsHeight + frame:GetHeight()
		end
			for iterateQuestPopups = countPopUps + 1, EMA.countAutoQuestPopUpFrames do
				_G["EMAWatchFrameAutoQuestPopUp"..iterateQuestPopups].questId = nil
				_G["EMAWatchFrameAutoQuestPopUp"..iterateQuestPopups]:Hide()
			end
	EMA:UpdateQuestWatcherDimensions()
end

-------------------------------------------------------------------------------------------------------------
-- QUEST WATCH HELPERS
-------------------------------------------------------------------------------------------------------------

function EMA:GetQuestLogIndexByName( questName )
	for iterateQuests = 1, C_QuestLog.GetNumQuestLogEntries() do
        --local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle( iterateQuests )
		local info =  C_QuestLog.GetInfo( iterateQuests )
		if not info.isHeader then
			if info.title == questName then
				return iterateQuests
			end
		end
	end
	return 0
end

function EMA:GetQuestLogIndexByID( inQuestID )
	for iterateQuests = 1, C_QuestLog.GetNumQuestLogEntries() do
        --local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle( iterateQuests )
		local info =  C_QuestLog.GetInfo( iterateQuests )
		if not info.isHeader then
			if info.questID == inQuestID then
				return iterateQuests
			end
		end
	end
	return 0
end

-------------------------------------------------------------------------------------------------------------
-- COMMAND MANAGEMENT
-------------------------------------------------------------------------------------------------------------

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
											 
	if commandName == EMA.COMMAND_QUEST_WATCH_OBJECTIVE_UPDATE then
		EMA:DoQuestWatchObjectiveUpdate( characterName, ... )
	end
	if commandName == EMA.COMMAND_UPDATE_QUEST_WATCHER_LIST then
		EMA:DoQuestWatchListUpdate( characterName, ... )
	end
	if commandName == EMA.COMMAND_QUEST_WATCH_REMOVE_QUEST then
		EMA:DoRemoveQuestFromWatchList( characterName, ... )
	end
	if commandName == EMA.COMMAND_AUTO_QUEST_COMPLETE then
		EMA:DoAutoQuestFieldComplete( characterName, ... )
	end
	if commandName == EMA.COMMAND_REMOVE_AUTO_QUEST_COMPLETE then
		EMA:DoRemoveAutoQuestFieldComplete( characterName, ... )
	end
	if commandName == EMA.COMMAND_AUTO_QUEST_OFFER then
		EMA:DoAutoQuestFieldOffer( characterName, ... )
	 
	end
end
