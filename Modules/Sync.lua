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
	"Sync", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Get the EMA Utilities Library.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Sync"
EMA.settingsDatabaseName = "SyncProfileDB"
EMA.chatCommand = "ema-Sync"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["SYNC"]
EMA.moduleDisplayName = L["SYNC"]

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		mountWithTeam = false,
		dismountWithTeam = false,
		dismountWithMaster = false,
		mountInRange = false,

		--messageArea = EMAApi.DefaultMessageArea(),
		warningArea = EMAApi.DefaultWarningArea()
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
				usage = "/ema-sync config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["Push Settings"],
				desc = L["Push the Mount settings to all characters in the team."],
				usage = "/EMA-sync push",
				get = false,
				set = "EMASendSettings",
				order = 4,
				guiHidden = true,
			},
		},
	}
	return configuration
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

EMA.COMMAND_MOUNT_ME = "EMAMountMe"
EMA.COMMAND_MOUNT_DISMOUNT = "EMAMountDisMount"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialse the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()
	-- BlizzUI Frames
	EMA:CreateEMAInterFaceSyncFrame()	
end

-- Called when the addon is enabled.
function EMA:OnEnable()
--	EMA:RegisterEvent("PLAYER_REGEN_ENABLED")

	EMA:HookScript( InterfaceOptionsFrame, "OnShow", "InterfaceOptionsFrameOnShow" )
	EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	
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
		EMA.SettingsPushSettingsClick 
	)
	local bottomOfInfo = EMA:SettingsCreateMount( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsCreateMount( top )
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local movingTop = top
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["PH"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxMountWithTeam = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["PH"],
		EMA.SettingsToggleMountWithTeam,
		L["PH"]
	)	
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxDismountWithTeam = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["PH"],
		EMA.SettingsToggleDisMountWithTeam,
		L["PH"]
	)	
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxDismountWithMaster = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["PH"],
		EMA.SettingsToggleDisMountWithMaster,
		L["PH"]
	)	
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxMountInRange = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["PH"],
		EMA.SettingsToggleMountInRange,
		L["PH"]
	)
-- DO WE NEED THIS?
--	movingTop = movingTop - checkBoxHeight
--	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
--		EMA.settingsControl, 
--		headingWidth, 
--		left, 
--		movingTop, 
--		L["Message Area"] 
--	)
--	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
--	EMA.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", EMA.SettingsSetMessageArea )
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.dropdownWarningArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["Send Warning Area"] 
	)
	EMA.settingsControl.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownWarningArea:SetCallback( "OnValueChanged", EMA.SettingsSetWarningArea )
	movingTop = movingTop - dropdownHeight - verticalSpacing
	return movingTop	
end

function EMA:OnMessageAreasChanged( message )
	--EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:SettingsSetWarningArea( event, value )
	EMA.db.warningArea = value
	EMA:SettingsRefresh()
end

--function EMA:SettingsSetMessageArea( event, value )
--	EMA.db.messageArea = value
--	EMA:SettingsRefresh()
--end

function EMA:SettingsToggleMountWithTeam( event, checked )
	EMA.db.mountWithTeam = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDisMountWithTeam( event, checked )
	EMA.db.dismountWithTeam = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDisMountWithMaster( event, checked )
	EMA.db.dismountWithMaster = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleMountInRange( event, checked )
	EMA.db.mountInRange = checked
	EMA:SettingsRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.mountWithTeam = settings.mountWithTeam
		EMA.db.dismountWithTeam = settings.dismountWithTeam
		EMA.db.dismountWithMaster = settings.dismountWithMaster
		EMA.db.mountInRange = settings.mountInRange
		EMA.db.messageArea = settings.messageArea
		EMA.db.warningArea = settings.warningArea
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["Settings received from A."]( characterName ) )
	end
end

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	EMA.settingsControl.checkBoxMountWithTeam:SetValue( EMA.db.mountWithTeam )
	EMA.settingsControl.checkBoxDismountWithTeam:SetValue( EMA.db.dismountWithTeam )
	EMA.settingsControl.checkBoxDismountWithMaster:SetValue( EMA.db.dismountWithMaster )
	EMA.settingsControl.checkBoxMountInRange:SetValue( EMA.db.mountInRange )
	--EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.dropdownWarningArea:SetValue( EMA.db.warningArea )
	-- Set state.
	--EMA.settingsControl.checkBoxMountWithTeam:SetDisabled( not EMA.db.mountWithTeam )
	EMA.settingsControl.checkBoxDismountWithTeam:SetDisabled( not EMA.db.mountWithTeam )
	EMA.settingsControl.checkBoxDismountWithMaster:SetDisabled( not EMA.db.dismountWithTeam or not EMA.db.mountWithTeam )
	EMA.settingsControl.checkBoxMountInRange:SetDisabled( not EMA.db.mountWithTeam )
end

-------------------------------------------------------------------------------------------------------------
-- EMASync functionality.
-------------------------------------------------------------------------------------------------------------

--Frames Buttons

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


function EMA:CreateEMAInterFaceSyncFrame()
	EMAInterFaceSyncFrame = CreateFrame( "Frame", "InterFaceSyncFrame", InterfaceOptionsFrame )
    local frame = EMAInterFaceSyncFrame
	frame:SetWidth( 110 )
	frame:SetHeight( 30 )
	frame:SetFrameStrata( "HIGH" )
	frame:SetToplevel( true )
	frame:SetClampedToScreen( true )
	frame:EnableMouse( true )
	frame:SetMovable( true )	
	frame:ClearAllPoints()
	frame:SetPoint("TOPRIGHT", InterfaceOptionsFrame, "TOPRIGHT", -5, -8 )
	--[[
		frame:SetBackdrop( {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 15, edgeSize = 15, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	} )
	]]
	table.insert( UISpecialFrames, "EMAInterFaceSyncFrame" )
	local syncButton = CreateFrame( "Button", "syncButton", frame, "UIPanelButtonTemplate" )
	syncButton:SetScript( "OnClick", function()  EMA:DoSyncInterfaceSettings() end )
	syncButton:SetPoint( "TOPLEFT", frame, "TOPLEFT", 10 , -5)
	syncButton:SetHeight( 20 )
	syncButton:SetWidth( 90 )
	syncButton:SetText( L["SYNC"] )	
	syncButton:SetScript("OnEnter", function(self) EMA:ShowTooltip(syncButton, true, L["SYNC"] ) end)
	syncButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	syncButtonFrameButton = syncButton
	
end

function EMA:InterfaceOptionsFrameOnShow()
	--EMA:Print("test")
	-- This sorts out hooking on L or marcioMenu button
	--if EMA.db.showEMAQuestLogWithWoWQuestLog == true then
		if InterfaceOptionsFrame:IsVisible() then
			EMA:ToggleShowSyncInterfaceFrame( true )
		else
			EMA:ToggleShowSyncInterfaceFrame( false )
		end
	--end
end


function EMA:ToggleShowSyncInterfaceFrame( show )
    if show == true then
		EMAInterFaceSyncFrame:Show()
    else
		EMAInterFaceSyncFrame:Hide()
    end
end

function EMA:DoSyncInterfaceSettings()
    EMA:Print("[PH] Button Does Nothing" ) 
end


-- COMMS

-- A EMA command has been received.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if characterName ~= self.characterName then
		--[[
		if commandName == EMA.COMMAND_MOUNT_ME then
			--EMA:Print("command")
			EMA:TeamMount( characterName, ... ) 
		end
		]]
	end
end
