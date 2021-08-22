-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2019 Jennifer Cally					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon(
	"Interaction",
	"Module-1.0",
	"AceConsole-3.0",
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Get the EMA Utilities Library.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local LibAuras = LibStub:GetLibrary("LibAuras")

--  Constants and Locale for this module.
EMA.moduleName = "Interaction"
EMA.settingsDatabaseName = "InteractionProfileDB"
EMA.chatCommand = "ema-Interaction"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["INTERACTION"]
EMA.moduleDisplayName = L["INTERACTION"]
-- Icon
 EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\InteractionIcon.tga"
-- order
EMA.moduleOrder = 60

-- EMA key bindings.
--if EMAPrivate.Core.isEmaClassicBccBuild() == false then
	BINDING_HEADER_MOUNT = L["MOUNT"]
	BINDING_NAME_TEAMMOUNT = L["MOUNT_WITH_TEAM"]
--end

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	global = {
		takeMastersTaxi = true,
		requestTaxiStop = true,
		changeTexiTime = 2,
		--Mount
		mountWithTeam = false,
		dismountWithTeam = false,
		dismountWithMaster = false,
		mountInRange = false,
		--Loot
		autoLoot = false,
		tellBoERare = false,
		tellBoEEpic = false,
		tellBoEMount = false,
		messageArea = EMAApi.DefaultMessageArea(),
		warningArea = EMAApi.DefaultWarningArea()
	},
	profile = {
		takeMastersTaxi = true,
		requestTaxiStop = true,
		changeTexiTime = 2,
		--Mount
		mountWithTeam = false,
		dismountWithTeam = false,
		dismountWithMaster = false,
		mountInRange = false,
		--Loot
		autoLoot = false,
		tellBoERare = false,
		tellBoEEpic = false,
		tellBoEMount = false,
		messageArea = EMAApi.DefaultMessageArea(),
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
				usage = "/ema-interaction config",
				get = false,
				set = "",
			},
			mount = {
				type = "input",
				name = L["MOUNT"],
				desc = L["MOUNT_HELP"],
				usage = "/ema-interaction mount <tag>",
				get = false,
				set = "RandomMountWithTeam",
				order = 3,
				guiHidden = true,
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-interaction push",
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

EMA.COMMAND_TAKE_TAXI = "EMATaxiTakeTaxi"
EMA.COMMAND_EXIT_TAXI = "EMATaxiExitTaxi"
EMA.COMMAND_CLOSE_TAXI = "EMACloseTaxi"
EMA.COMMAND_MOUNT_ME = "EMAMountMe"
EMA.COMMAND_MOUNT_COMMAND = "EMAMountCommand"
EMA.COMMAND_MOUNT_DISMOUNT = "EMAMountDisMount"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-- Taxi has been taken, no parameters.
EMA.MESSAGE_TAXI_TAKEN = "EMATaxiTaxiTaken"

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	--EMA.config = nil
	-- Taxi
	EMA.TakesTaxi = false
	EMA.LeavsTaxi = false
	EMA.TaxiFrameName = TaxiFrame
	-- Mount
	EMA.castingMount = nil
	EMA.isMounted = nil
	EMA.responding = false
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialse the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()
	if InCombatLockdown()  == false then
		EMATeamSecureButtonMount = CreateFrame( "CheckButton", "EMATeamSecureButtonMount", nil, "SecureActionButtonTemplate" )
		EMATeamSecureButtonMount:SetAttribute( "type", "macro" )
		EMATeamSecureButtonMount:SetAttribute( "macrotext", "/ema-interaction mount all" )
		EMATeamSecureButtonMount:Hide()
	end
end

-- Called when the addon is enabled.
function EMA:OnEnable()

	-- Hook the TaketaxiNode function.
	EMA:SecureHook( "TakeTaxiNode" )
	EMA:SecureHook( "TaxiRequestEarlyLanding" )
	EMA:RegisterEvent( "PLAYER_ENTERING_WORLD" )
	if EMAPrivate.Core.isEmaClassicBccBuild == false then
		EMA:RegisterEvent( "UNIT_SPELLCAST_START" )
		EMA:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" )
	end
	EMA:RegisterEvent( "LOOT_READY" )
	EMA:RegisterEvent( "TAXIMAP_OPENED" )
	EMA:RegisterEvent( "TAXIMAP_CLOSED" )
	-- Initialise key bindings.
	EMA.keyBindingFrame = CreateFrame( "Frame", nil, UIParent )
	EMA:RegisterEvent( "UPDATE_BINDINGS" )
	EMA:UPDATE_BINDINGS()
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
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder
	)
	local bottomOfInfo = EMA:SettingsCreateTaxi( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsCreateTaxi( top )
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local iconSize = EMAHelperSettings:GetIconHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local sliderHeight = EMAHelperSettings:GetSliderHeight()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local halfWidthSlider = (headingWidth - horizontalSpacing) / 2
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local leftIcon = left + iconSize
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["TAXI_OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxTakeMastersTaxi = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["TAKE_TEAMS_TAXI"],
		EMA.SettingsToggleTakeTaxi,
		L["TAKE_TEAMS_TAXI_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxrequestStop = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["REQUEST_TAXI_STOP"],
		EMA.SettingsTogglerequestStop,
		L["REQUEST_TAXI_STOP_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.changeTexiTime = EMAHelperSettings:CreateSlider(
		EMA.settingsControl,
		halfWidthSlider,
		left,
		movingTop,
		L["CLONES_TO_TAKE_TAXI_AFTER"]
	)
	EMA.settingsControl.changeTexiTime:SetSliderValues( 0, 5, 0.5 )
	EMA.settingsControl.changeTexiTime:SetCallback( "OnValueChanged", EMA.SettingsChangeTaxiTimer )
	movingTop = movingTop - sliderHeight
	if EMAPrivate.Core.isEmaClassicBccBuild() == false then
	-- Mount
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["MOUNT_OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
	--Disabled in classic note
		EMA.settingsControl.checkBoxMountWithTeam = EMAHelperSettings:CreateCheckBox(
			EMA.settingsControl,
			headingWidth,
			left,
			movingTop,
			L["MOUNT_WITH_TEAM"],
			EMA.SettingsToggleMountWithTeam,
			L["MOUNT_WITH_TEAM_HELP"]
		)
		movingTop = movingTop - checkBoxHeight
		EMA.settingsControl.checkBoxDismountWithTeam = EMAHelperSettings:CreateCheckBox(
			EMA.settingsControl,
			headingWidth,
			left,
			movingTop,
			L["DISMOUNT_WITH_TEAM"],
			EMA.SettingsToggleDisMountWithTeam,
			L["DISMOUNT_WITH_TEAM_HELP"]
		)
		movingTop = movingTop - checkBoxHeight
		EMA.settingsControl.checkBoxDismountWithMaster = EMAHelperSettings:CreateCheckBox(
			EMA.settingsControl,
			headingWidth,
			left,
			movingTop,
			L["ONLY_DISMOUNT_WITH_MASTER"],
			EMA.SettingsToggleDisMountWithMaster,
			L["ONLY_DISMOUNT_WITH_MASTER_HELP"]
		)
		--[[
		movingTop = movingTop - checkBoxHeight
		EMA.settingsControl.checkBoxMountInRange = EMAHelperSettings:CreateCheckBox(
			EMA.settingsControl,
			headingWidth,
			left,
			movingTop,
			L["ONLY_MOUNT_WHEN_IN_RANGE"],
			EMA.SettingsToggleMountInRange,
			L["ONLY_MOUNT_WHEN_IN_RANGE_HELP"]
		)
		]]
	end	
	-- Loot
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["LOOT_OPTIONS"] , movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxAutoLoot = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["ENABLE_AUTO_LOOT"],
		EMA.SettingsToggleAutoLoot,
		L["ENABLE_AUTO_LOOT_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxTellBoERare = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["TELL_TEAM_BOE_RARE"],
		EMA.SettingsToggleTellBoERare,
		L["TELL_TEAM_BOE_RARE_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxTellBoEEpic = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["TELL_TEAM_BOE_EPIC"] ,
		EMA.SettingsToggleTellBoEEpic,
		L["TELL_TEAM_BOE_EPIC_HELP"]
	)
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxTellBoEMount = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["TELL_TEAM_BOE_MOUNT"] ,
		EMA.SettingsToggleTellBoEMount,
		L["TELL_TEAM_BOE_MOUNT_HELP"]
	)
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["MESSAGE_AREA"]
	)
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", EMA.SettingsSetMessageArea )
	movingTop = movingTop - dropdownHeight - verticalSpacing
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
	return movingTop
end

function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownWarningArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsSetWarningArea( event, value )
	EMA.db.warningArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTakeTaxi( event, checked )
	EMA.db.takeMastersTaxi = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsTogglerequestStop( event, checked )
	EMA.db.requestTaxiStop = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeTaxiTimer( event, value )
	EMA.db.changeTexiTime = tonumber( value )
	EMA:SettingsRefresh()
end

-- Mount
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

function EMA:SettingsToggleAutoLoot( event, checked )
	EMA.db.autoLoot = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTellBoERare( event, checked )
	EMA.db.tellBoERare = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTellBoEEpic( event, checked )
	EMA.db.tellBoEEpic = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTellBoEMount( event, checked )
	EMA.db.tellBoEMount = checked
	EMA:SettingsRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.takeMastersTaxi = settings.takeMastersTaxi
		EMA.db.requestTaxiStop = settings.requestTaxiStop
		EMA.db.changeTexiTime = settings.changeTexiTime

		EMA.db.mountWithTeam = settings.mountWithTeam
		EMA.db.dismountWithTeam = settings.dismountWithTeam
		EMA.db.dismountWithMaster = settings.dismountWithMaster
		--EMA.db.mountInRange = settings.mountInRange

		EMA.db.autoLoot = settings.autoLoot
		EMA.db.tellBoERare = settings.tellBoERare
		EMA.db.tellBoEEpic = settings.tellBoEEpic
		EMA.db.tellBoEMount = settings.tellBoEMount
		EMA.db.messageArea = settings.messageArea
		EMA.db.warningArea = settings.warningArea
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
--	EMA:Print("test", EMA.db, "vs",  EMA.db.global )
	EMA.settingsControl.checkBoxTakeMastersTaxi:SetValue( EMA.db.takeMastersTaxi )
	EMA.settingsControl.checkBoxrequestStop:SetValue( EMA.db.requestTaxiStop )
	EMA.settingsControl.changeTexiTime:SetValue( EMA.db.changeTexiTime )
	if EMAPrivate.Core.isEmaClassicBccBuild() == false then
		EMA.settingsControl.checkBoxMountWithTeam:SetValue( EMA.db.mountWithTeam )
		EMA.settingsControl.checkBoxDismountWithTeam:SetValue( EMA.db.dismountWithTeam )
		EMA.settingsControl.checkBoxDismountWithMaster:SetValue( EMA.db.dismountWithMaster )
		--EMA.settingsControl.checkBoxMountInRange:SetValue( EMA.db.mountInRange )
	end
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
	EMA.settingsControl.dropdownWarningArea:SetValue( EMA.db.warningArea )
	EMA.settingsControl.checkBoxAutoLoot:SetValue( EMA.db.autoLoot )
	EMA.settingsControl.checkBoxTellBoERare:SetValue( EMA.db.tellBoERare )
	EMA.settingsControl.checkBoxTellBoEEpic:SetValue( EMA.db.tellBoEEpic )
	EMA.settingsControl.checkBoxTellBoEMount:SetValue( EMA.db.tellBoEMount )
end

-------------------------------------------------------------------------------------------------------------
-- Taxi Functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:TAXIMAP_OPENED(event, ...)
	local uiMapSystem = ...
	if (uiMapSystem == Enum.UIMapSystem.Taxi) then
		EMA.TaxiFrameName = TaxiFrame
	else
		EMA.TaxiFrameName = FlightMapFrame
	end
end

-- Take a taxi.
local function TakeTaxi( sender, nodeName, taxiNodeIndex )
	-- If the take masters taxi option is on.
	if EMA.db.takeMastersTaxi == true then
		-- If the sender was not this character and is the master then...
		if sender ~= EMA.characterName then
			-- Find the index of the taxi node to fly to.
			local nodeIndex = nil
			--EMA:Print("test23", nodeName )
			for iterateNodes = 1, NumTaxiNodes() do
				local mapNodeName = TaxiNodeName( iterateNodes )
				if EMA.TaxiFrameName == FlightMapFrame then
					--EMA:Print("test240", nodeName, "vs", mapNodeName, "ID", iterateNodes)
					if mapNodeName == nodeName and iterateNodes == taxiNodeIndex then
						--EMA:Print("test24", nodeName, "vs", mapNodeName, "ID", iterateNodes)
						nodeIndex = iterateNodes
						break
					end
				else
					if mapNodeName == nodeName then
					--EMA:Print("test24", nodeName, "vs", mapNodeName, "ID", iterateNodes)
						nodeIndex = iterateNodes
						break
					end
				end
			end
			-- If a node index was found...
			if nodeIndex ~= nil then
				-- Send a message to any listeners that a taxi is being taken.
				EMA:SendMessage( EMA.MESSAGE_TAXI_TAKEN )
				-- Take a taxi.
				EMA.TakesTaxi = true
				EMA:ScheduleTimer( "TakeTimedTaxi", EMA.db.changeTexiTime , nodeIndex )
			else
				-- Tell the master that this character could not take the same flight.
				EMA:EMASendMessageToTeam( EMA.db.messageArea,  L["I_AM_UNABLE_TO_FLY_TO_A"]( nodeName ), false )
			end
		end
	end
end

function EMA.TakeTimedTaxi( event, nodeIndex, ...)
	if nodeIndex ~= nil then
		GetNumRoutes( nodeIndex )
		TakeTaxiNode( nodeIndex )
	end
end

-- Called after the character has just taken a flight (hooked function).
function EMA:TakeTaxiNode( taxiNodeIndex )
	-- If the take masters taxi option is on.
	if EMA.db.takeMastersTaxi == true then
		-- Get the name of the node flown to.
		local nodeName = TaxiNodeName( taxiNodeIndex )
		--EMA:Print("testTake", taxiNodeIndex, nodeName )
		if EMA.TakesTaxi == false then
			-- Tell the other characters about the taxi.
			EMA:EMASendCommandToTeam( EMA.COMMAND_TAKE_TAXI, nodeName, taxiNodeIndex )
		end
		EMA.TakesTaxi = false
	end
end

local function LeaveTaxi ( sender )
	if EMA.db.requestTaxiStop == true then
		if sender ~= EMA.characterName then
			EMA.LeavsTaxi = true
			TaxiRequestEarlyLanding()
			EMA:EMASendMessageToTeam( EMA.db.messageArea,  L["REQUESTED_STOP_X"]( sender ), false )
		end
	end
end

function EMA.TaxiRequestEarlyLanding( sender )
	-- If the take masters taxi option is on.
	--EMA:Print("test")
	if EMA.db.requestTaxiStop == true then
		if UnitOnTaxi( "player" ) and CanExitVehicle() == true then
			if EMA.LeavsTaxi == false then
				-- Send a message to any listeners that a taxi is being taken.
				EMA:EMASendCommandToTeam ( EMA.COMMAND_EXIT_TAXI )
			end
		end
		EMA.LeavsTaxi = false
	end
end

function EMA:TAXIMAP_CLOSED( event, ... )
	local TaxiFrame = EMA.TaxiFrameName
	if not TaxiFrame:IsVisible() then
		EMA:EMASendCommandToTeam ( EMA.COMMAND_CLOSE_TAXI )
	end
end

local function CloseTaxiMapFrame()
	if EMA.TakesTaxi == false then
		CloseTaxiMap()
	end
end

-------------------------------------------------------------------------------------------------------------
-- Mount Functionality.
-------------------------------------------------------------------------------------------------------------
-- Pre 8.0 used to give spall Name. --  UNIT_SPELLCAST_START - no longer provide spell name and rank.
--EMA:UNIT_SPELLCAST_START(event, unitID, spell, rank, lineID, spellID, ...  )

function EMA:PLAYER_ENTERING_WORLD(event, ... )
	if EMA.db.autoLoot == true then
		EMA:EnableAutoLoot()
	end
	if IsMounted() and EMAPrivate.Core.isEmaClassicBccBuild() == false then
		local mountIDs = C_MountJournal.GetMountIDs()
		for i = 1, #mountIDs do
			local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(mountIDs[i])
			if active then
				--EMA:Print("alreadyMounted", spellID )
				EMA.isMounted = spellID
				EMA:RegisterEvent("UNIT_AURA")
			end
		end
	end
end

function EMA:UNIT_SPELLCAST_START(event, unitID, lineID, spellID,  ...  )
	if EMAPrivate.Core.isEmaClassicBccBuild() == true then return end
	--EMA:Print("Looking for Spells.", unitID, spellID)
	if unitID == "player" then
	local mountIDs = C_MountJournal.GetMountIDs()
		for i = 1, #mountIDs do
			--local name , id, icon, active = C_MountJournal.GetMountInfoByID(i)
			local creatureName,mountSpellID,_,_,_,_,_,_,_,_,_,mountID = C_MountJournal.GetMountInfoByID(mountIDs[i])
			--EMA:Print("Test", spellID, "vs", mountSpellID, "name", creatureName)
			if spellID == mountSpellID then
				--EMA:Print("SendtoTeam", "name", creatureName, "id", mountID)
				if IsShiftKeyDown() == false then
					if EMA.responding == false then
						EMA:EMASendCommandToTeam( EMA.COMMAND_MOUNT_ME, creatureName, mountID )
						EMA.castingMount = spellID
						break
					end
				end
			end
		end
	end
end


function EMA:UNIT_SPELLCAST_SUCCEEDED(event, unitID, lineID, spellID, ... )
	if EMAPrivate.Core.isEmaClassicBccBuild() == true then return end
	if EMA.db.mountWithTeam == false  or EMA.castingMount == nil or unitID ~= "player" or EMA.CommandLineMount == true then
		return
	end
	--EMA:Print("Looking for Spells Done", spellID, EMA.castingMount)
	if spellID == EMA.castingMount then
		--EMA:Print("Mounted!", EMA.isMounted)
		EMA.isMounted = spellID
		EMA.mountName = spell
		EMA:RegisterEvent("UNIT_AURA")
	end
end


function EMA:UNIT_AURA(event, unitID, ... )
	if EMAPrivate.Core.isEmaClassicBccBuild() == true then return end
	--EMA:Print("tester", unitID, EMA.isMounted)
	if unitID ~= "player" or EMA.isMounted == nil then
        return
    end
	--EMA:Print("auraTrack", unitID, EMA.isMounted, EMA.mountName )
	if not LibAuras:UnitAura(unitID, EMA.isMounted ) then
		--EMA:Print("I have Dismounted - Send to team!")
		if EMA.db.dismountWithMaster == true then
			if EMAApi.IsCharacterTheMaster( EMA.characterName ) == true then
				if IsShiftKeyDown() == false then
					--EMA:Print("test")
					EMA:EMASendCommandToTeam( EMA.COMMAND_MOUNT_DISMOUNT )
					EMA:UnregisterEvent("UNIT_AURA")
				end
			end
		else
			if EMA.db.dismountWithTeam == true then
				if IsShiftKeyDown() == false then
					EMA:EMASendCommandToTeam( EMA.COMMAND_MOUNT_DISMOUNT )
					EMA:UnregisterEvent("UNIT_AURA")
				end
			end
		end
	end
end

function EMA:TeamMount(characterName, name, mountID)
	if EMAPrivate.Core.isEmaClassicBccBuild() == true then return end
	--EMA:Print("testTeamMount", characterName, name, mountID )
	EMA.responding = true
	--mount with team truned off.
	if EMA.db.mountWithTeam == false then
		return
	end
	-- already mounted.
	if IsMounted() then
		return
	end
	-- Checks if character is in range.
	if EMA.db.mountInRange == true then
		if UnitIsVisible(Ambiguate(characterName, "none") ) == false then
			--EMA:Print("UnitIsNotVisible", characterName)
			return
		end
	end
	-- Checks done now the fun stuff!
	--Do i have the same mount as master?
	hasMount = false
	local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountID)
	local x_creatureDisplayID, x_descriptionText, x_sourceText, x_isSelfMount, x_mountTypeID, x_uiModelSceneID = C_MountJournal.GetMountInfoExtraByID(mountID)
	if isUsable == true then
		--EMA:Print("i have this Mount", creatureName)
		hasMount = true
		mount = mountID
	else
		--EMA:Print("i DO NOT have Mount", creatureName)
		for i = 1, C_MountJournal.GetNumMounts() do
			local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected,   mountID = C_MountJournal.GetMountInfoByID(i)
			--EMA:Print("looking for a mount i can use", i)
			if isUsable == true then
				local creatureDisplayID, descriptionText, sourceText, isSelfMount, mountTypeID, uiModelSceneID = C_MountJournal.GetMountInfoExtraByID(mountID)
				-- EMA:Print("looking for a mount i can use of type", x_mountTypeID, mountTypeID, i, creatureName, spellID)
				-- mount a similar type of mount, e.g. if mounting a flying mount, also mount a flying mount
				if x_mountTypeID == mountTypeID then
					mount = mountID
					hasMount = true
					break
				end
			end
		end
	end

	--EMA:Print("test1420", mount, name)
	-- for unsupported mounts.
	if hasMount == true then
		--EMA:Print("test14550", mount, name )
		if name == "Random" then  -- name doesn't seem to be set anywhere...
			C_MountJournal.SummonByID(0)
			EMA.responding = false
		else
			--EMA:Print("test1054" )
			C_MountJournal.SummonByID( mount )
			EMA.responding = false
		end
		if IsMounted() == false then
			EMA:ScheduleTimer( "AmNotMounted", 2 )
		end
	end
end

function EMA:AmNotMounted()
	if IsMounted() == false then
		--EMA:Print("test")
		EMA:EMASendMessageToTeam( EMA.db.warningArea, L["I_AM_UNABLE_TO_MOUNT"], false )
	end
end

function EMA:RandomMountWithTeam( info, parameters )
	if EMAPrivate.Core.isEmaClassicBccBuild() == true then return end
	local tag = parameters
	--EMA:Print("test", tag )
	EMA:EMASendCommandToTeam( EMA.COMMAND_MOUNT_COMMAND, tag )
end

function EMA:ReceiveRandomMountWithTeam( characterName, tag)
	if EMAPrivate.Core.isEmaClassicBccBuild() == true then return end
	--EMA:Print("test", characterName, tag )
	if EMAApi.IsCharacterInGroup( EMA.characterName, tag ) == true then
		if IsMounted() == false then
			C_MountJournal.SummonByID(0)
		else
			if EMA.db.dismountWithTeam == true then
				Dismount()
			end
		end
	end
end



-------------------------------------------------------------------------------------------------------------
-- Loot Functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:LOOT_READY( event, ... )
	if EMA.db.autoLoot == true then
		EMA:doLoot()
	end
end

function EMA:doLoot( tries )
	if tries == nil then
		tries = 0
	end
	local numloot = GetNumLootItems()
	if numloot ~= 0 then
		for slot = 1, numloot do
			local _, name, _, _, lootQuality, locked = GetLootSlotInfo(slot)
			--EMA:Print("items", slot, locked, name, tries)
			if locked ~= nil and ( not locked ) then
				--DEBUG
					--EMA:ScheduleTimer( "TellTeamEpicBoE", 1 , "Minion of Grumpus")
				--
				if EMA.db.tellBoERare == true then
					if lootQuality == 3 then
						EMA:ScheduleTimer( "TellTeamEpicBoE", 1 , name)
					end
				end
				if EMA.db.tellBoEEpic == true or EMA.db.tellBoEMount == true then
					if lootQuality == 4 then
						--EMA:Print("Can Tell")
						EMA:ScheduleTimer( "TellTeamEpicBoE", 1 , name)
					end
				end
				---EMA:Print("canLoot", "slot", slot, "name", name )
				LootSlot(slot)
				numloot = GetNumLootItems()
			end
		end
		tries = tries + 1
		if tries < 8 then
			EMA:doLootLoop( tries )
		else
			CloseLoot()
		end
	else
		CloseLoot()
	end
end

function EMA:doLootLoop( tries )
	--EMA:Print("loop", tries)
	EMA:ScheduleTimer("doLoot", 0.6, tries )
end

function EMA:EnableAutoLoot()
	if EMA.db.autoLoot == true then
		if GetCVar("autoLootDefault") == "0" then
			--EMA:Print("testSetOFF")
			SetCVar( "autoLootDefault", 1 )
		end
	end
end

function EMA:TellTeamEpicBoE( name )
	--EMA:Print("loottest", name )
		for bagID = 0, NUM_BAG_SLOTS do
			for slotID = 1,GetContainerNumSlots( bagID ),1 do
				--EMA:Print( "Bags OK. checking", itemLink )
				local rarity = nil
				local item = Item:CreateFromBagAndSlot(bagID, slotID)
				if ( item ) then
					local bagItemName = item:GetItemName()
					if ( bagItemName ) then
						if bagItemName == name then
							--EMA:Print("test", bagItemName)
							local location = item:GetItemLocation()
							local itemLink = item:GetItemLink()
							local itemType = C_Item.GetItemInventoryType( location )
							local isBop = C_Item.IsBound( location )
							local itemRarity =  C_Item.GetItemQuality( location )
							if itemType ~= 0 then
								--EMA:Print("loottest", itemLink, itemRarity , itemType )
								if isBop == false then
								--EMA:Print("test", isBop )
									if itemRarity == 4 then
										rarity = L["EPIC"]
									else
										rarity = L["RARE"]
									end
								end
								if rarity ~= nil then
									EMA:EMASendMessageToTeam( EMA.db.messageArea, L["I_HAVE_LOOTED_X_Y_ITEM"]( rarity, itemLink ), false )
								end
							else
								if EMA.db.tellBoEMount == true and EMAPrivate.Core.isEmaClassicBccBuild() == false then
									if isBop == false then
										local mountIDs = C_MountJournal.GetMountIDs()
										for i = 1, #mountIDs do
											local creatureName, mountSpellID,_,_,_,_,_,_,_,_, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountIDs[i])
											--EMA:Print("test2", itemLink)
											if name == creatureName then
												--EMA:Print("FoundAMount", bagItemName)
												rarity = L["MOUNT"]
											end
										end
									end
								end
							--EMA:Print("I have looted a Epic BOE Item: ", rarity, itemLink )
							if rarity ~= nil then
								EMA:EMASendMessageToTeam( EMA.db.messageArea, L["I_HAVE_LOOTED_X_Y_ITEM"]( rarity, itemLink ), false )
							end
						end
					end
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------
-- EMA Commands functionality.
-------------------------------------------------------------------------------------------------------------


-- A EMA command has been received.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if characterName ~= self.characterName then
		-- If the command was to take a taxi...
		if commandName == EMA.COMMAND_TAKE_TAXI then
			-- If not already on a taxi...
			if not UnitOnTaxi( "player" ) then
				-- And if the taxi frame is open...
				local TaxiFrame = EMA.TaxiFrameName
				if TaxiFrame:IsVisible() then
					TakeTaxi( characterName, ... )
				end
			end
		end
		if commandName == EMA.COMMAND_EXIT_TAXI then
			if UnitOnTaxi ( "player") then
				LeaveTaxi ( characterName, ... )
			end
		end
		if commandName == EMA.COMMAND_CLOSE_TAXI then
			CloseTaxiMapFrame()
		end

		if commandName == EMA.COMMAND_MOUNT_ME then
			--EMA:Print("command")
			EMA:TeamMount( characterName, ... )
		end
		-- Dismount if mounted!
		if commandName == EMA.COMMAND_MOUNT_DISMOUNT then
			--EMA:Print("time to Dismount")
			if IsMounted() then
				Dismount()
			end
		end
	end
	if commandName == EMA.COMMAND_MOUNT_COMMAND then
		EMA:ReceiveRandomMountWithTeam( characterName, ... )
	end
end

function EMA:UPDATE_BINDINGS()
	if InCombatLockdown() then
		return
	end
	ClearOverrideBindings( EMA.keyBindingFrame )
	local key1, key2 = GetBindingKey( "TEAMMOUNT" )
	if key1 then
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key1, "EMATeamSecureButtonMount" )
	end
	if key2 then
		SetOverrideBindingClick( EMA.keyBindingFrame, false, key2, "EMATeamSecureButtonMount" )
	end
end


EMAApi.Taxi = {}
EMAApi.Taxi.MESSAGE_TAXI_TAKEN = EMA.MESSAGE_TAXI_TAKEN
