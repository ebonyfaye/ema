-- ================================================================================ --
--                EMA - ( Ebony's MultiBoxing Assistant )                           --
--                Current Author: Jennifer Calladine (Ebony)                        --
--                                                                                  --
--                License: All Rights Reserved 2018-2025 Jennifer Cally             --
--                                                                                  --
--                Some Code Used from "Jamba" that is                               --
--                Released under the MIT License                                    --
--                "Jamba" Copyright 2008-2015  Michael "Jafula" Miller              --
--                                                                                  --
-- ================================================================================ --

local EMA = LibStub("AceAddon-3.0"):NewAddon(
	"Interaction",
	"Module-1.0",
	"AceConsole-3.0",
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

local EMAHelperSettings = LibStub:GetLibrary("EMAHelperSettings-1.0")
local LibAuras = LibStub:GetLibrary("LibAuras")
local LibBagUtils = LibStub:GetLibrary("LibBagUtils-1.0")

EMA.moduleName = "Interaction"
EMA.settingsDatabaseName = "InteractionProfileDB"
EMA.chatCommand = "ema-Interaction"

local L = LibStub("AceLocale-3.0"):GetLocale("Core")

EMA.parentDisplayName = L["INTERACTION"]
EMA.moduleDisplayName = L["INTERACTION"]
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\InteractionIcon.tga"
EMA.moduleOrder = 60

BINDING_HEADER_MOUNT = L["MOUNT"]
BINDING_NAME_TEAMMOUNT = L["MOUNT_WITH_TEAM"]

EMA.settings = {
	global = {
		takeMastersTaxi = true,
		requestTaxiStop = true,
		changeTaxiTime = 2,

		-- Mount
		mountWithTeam = false,
		dismountWithTeam = false,
		dismountWithMaster = false,
		mountInRange = false,

		-- Loot
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
		changeTaxiTime = 2,

		-- Mount
		mountWithTeam = false,
		dismountWithTeam = false,
		dismountWithMaster = false,
		mountInRange = false,

		-- Loot
		autoLoot = false,
		tellBoERare = false,
		tellBoEEpic = false,
		tellBoEMount = false,
		messageArea = EMAApi.DefaultMessageArea(),
		warningArea = EMAApi.DefaultWarningArea()
	},
}

function EMA:GetConfiguration()
	local configuration = {
		name = EMA.moduleDisplayName,
		handler = EMA,
		type = "group",
		childGroups = "tab",
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
-- Commands this module sends.
-------------------------------------------------------------------------------------------------------------

EMA.COMMAND_TAKE_TAXI = "EMATaxiTakeTaxi"
EMA.COMMAND_EXIT_TAXI = "EMATaxiExitTaxi"
EMA.COMMAND_CLOSE_TAXI = "EMACloseTaxi"
EMA.COMMAND_MOUNT_ME = "EMAMountMe"
EMA.COMMAND_MOUNT_COMMAND = "EMAMountCommand"
EMA.COMMAND_MOUNT_DISMOUNT = "EMAMountDisMount"

-------------------------------------------------------------------------------------------------------------
-- Messages this module sends.
-------------------------------------------------------------------------------------------------------------

EMA.MESSAGE_TAXI_TAKEN = "EMATaxiTaxiTaken"

-------------------------------------------------------------------------------------------------------------
-- Compatibility helpers.
-------------------------------------------------------------------------------------------------------------

local Compat = {}

function Compat:IsClassic()
	return EMAPrivate.Core.isEmaClassicBccBuild() == true
end

function Compat:IsRetail()
	return not self:IsClassic()
end

function Compat:IsTaxiMapSystem(uiMapSystem)
	return Enum and Enum.UIMapSystem and uiMapSystem == Enum.UIMapSystem.Taxi
end

function Compat:HasMountJournal()
	return self:IsRetail()
		and C_MountJournal ~= nil
		and type(C_MountJournal.GetMountIDs) == "function"
		and type(C_MountJournal.GetMountInfoByID) == "function"
		and type(C_MountJournal.GetMountInfoExtraByID) == "function"
		and type(C_MountJournal.SummonByID) == "function"
		and type(C_MountJournal.GetNumMounts) == "function"
end

function Compat:GetTaxiFrame(uiMapSystem)
	if self:IsTaxiMapSystem(uiMapSystem) then
		return TaxiFrame
	end

	if FlightMapFrame then
		return FlightMapFrame
	end

	return TaxiFrame
end

function Compat:IsFrameVisible(frame)
	if frame == nil then
		return false
	end

	if type(frame.IsShown) == "function" and frame:IsShown() then
		return true
	end

	if type(frame.IsVisible) == "function" and frame:IsVisible() then
		return true
	end

	return false
end

function Compat:CanUseTaxiNodes()
	return type(NumTaxiNodes) == "function" and type(TaxiNodeName) == "function"
end

function Compat:CloseTaxiMap()
	if type(CloseTaxiMap) == "function" then
		return pcall(CloseTaxiMap)
	end
	return false
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization.
-------------------------------------------------------------------------------------------------------------

function EMA:MigrateSettings()
	if EMA.db.changeTaxiTime == nil and EMA.db.changeTexiTime ~= nil then
		EMA.db.changeTaxiTime = EMA.db.changeTexiTime
	end
end

function EMA:OnInitialize()
	EMA.TakesTaxi = false
	EMA.LeavesTaxi = false
	EMA.TaxiFrameName = TaxiFrame

	EMA.taxiState = {
		frame = TaxiFrame,
		uiMapSystem = nil,
		pendingTake = false,
		pendingSender = nil,
		pendingNodeName = nil,
		pendingNodeIndex = nil,
		pendingCreatedAt = 0,
		suppressCloseBroadcast = false,
		lastTakeAt = 0,
	}

	EMA.castingMount = nil
	EMA.castingMountName = nil
	EMA.isMounted = nil
	EMA.responding = false

	EMA:SettingsCreate()
	EMA:EMAModuleInitialize(EMA.settingsControl.widgetSettings.frame)
	EMA:MigrateSettings()
	EMA:SettingsRefresh()

	if InCombatLockdown() == false then
		EMATeamSecureButtonMount = CreateFrame("CheckButton", "EMATeamSecureButtonMount", nil, "SecureActionButtonTemplate")
		EMATeamSecureButtonMount:SetAttribute("type", "macro")
		EMATeamSecureButtonMount:SetAttribute("macrotext", "/ema-interaction mount all")
		EMATeamSecureButtonMount:Hide()
	end
end

function EMA:OnEnable()
	EMA:SecureHook("TakeTaxiNode")
	EMA:SecureHook("TaxiRequestEarlyLanding")

	EMA:RegisterEvent("PLAYER_ENTERING_WORLD")
	EMA:RegisterEvent("PLAYER_CONTROL_GAINED")

	if Compat:IsRetail() then
		EMA:RegisterEvent("UNIT_SPELLCAST_START")
		EMA:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end

	EMA:RegisterEvent("LOOT_READY")
	EMA:RegisterEvent("TAXIMAP_OPENED")
	EMA:RegisterEvent("TAXIMAP_CLOSED")

	EMA.keyBindingFrame = CreateFrame("Frame", nil, UIParent)
	EMA:RegisterEvent("UPDATE_BINDINGS")
	EMA:UPDATE_BINDINGS()

	EMA:RegisterMessage(EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged")
end

function EMA:OnDisable()
end

-------------------------------------------------------------------------------------------------------------
-- Settings UI.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsCreate()
	EMA.settingsControl = {}

	EMAHelperSettings:CreateSettings(
		EMA.settingsControl,
		EMA.moduleDisplayName,
		EMA.parentDisplayName,
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder
	)

	local bottomOfInfo = EMA:SettingsCreateTaxi(EMAHelperSettings:TopOfSettings())
	EMA.settingsControl.widgetSettings.content:SetHeight(-bottomOfInfo)

	local helpTable = {}
	EMAHelperSettings:CreateHelp(EMA.settingsControl, helpTable, EMA:GetConfiguration())
end

function EMA:SettingsPushSettingsClick(event)
	EMA:EMASendSettings()
end

function EMA:SettingsCreateTaxi(top)
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local sliderHeight = EMAHelperSettings:GetSliderHeight()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local headingWidth = EMAHelperSettings:HeadingWidth(false)
	local halfWidthSlider = (headingWidth - horizontalSpacing) / 2
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local movingTop = top

	EMAHelperSettings:CreateHeading(EMA.settingsControl, L[""], movingTop, false)
	movingTop = movingTop - headingHeight

	EMAHelperSettings:CreateHeading(EMA.settingsControl, L["TAXI_OPTIONS"], movingTop, false)
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

	EMA.settingsControl.checkBoxRequestStop = EMAHelperSettings:CreateCheckBox(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["REQUEST_TAXI_STOP"],
		EMA.SettingsToggleRequestStop,
		L["REQUEST_TAXI_STOP_HELP"]
	)
	movingTop = movingTop - checkBoxHeight

	EMA.settingsControl.sliderTaxiDelay = EMAHelperSettings:CreateSlider(
		EMA.settingsControl,
		halfWidthSlider,
		left,
		movingTop,
		L["CLONES_TO_TAKE_TAXI_AFTER"]
	)
	EMA.settingsControl.sliderTaxiDelay:SetSliderValues(0, 5, 0.5)
	EMA.settingsControl.sliderTaxiDelay:SetCallback("OnValueChanged", EMA.SettingsChangeTaxiTimer)
	movingTop = movingTop - sliderHeight

	if Compat:IsRetail() then
		EMAHelperSettings:CreateHeading(EMA.settingsControl, L["MOUNT_OPTIONS"], movingTop, false)
		movingTop = movingTop - headingHeight

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
	end

	movingTop = movingTop - headingHeight

	EMAHelperSettings:CreateHeading(EMA.settingsControl, L["LOOT_OPTIONS"], movingTop, false)
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

	movingTop = movingTop - sliderHeight - verticalSpacing

	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["MESSAGE_AREA"]
	)
	EMA.settingsControl.dropdownMessageArea:SetList(EMAApi.MessageAreaList())
	EMA.settingsControl.dropdownMessageArea:SetCallback("OnValueChanged", EMA.SettingsSetMessageArea)
	movingTop = movingTop - dropdownHeight - verticalSpacing

	EMA.settingsControl.dropdownWarningArea = EMAHelperSettings:CreateDropdown(
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["SEND_WARNING_AREA"]
	)
	EMA.settingsControl.dropdownWarningArea:SetList(EMAApi.MessageAreaList())
	EMA.settingsControl.dropdownWarningArea:SetCallback("OnValueChanged", EMA.SettingsSetWarningArea)
	movingTop = movingTop - dropdownHeight - verticalSpacing

	return movingTop
end

function EMA:OnMessageAreasChanged(message)
	if not EMA.settingsControl then
		return
	end

	if EMA.settingsControl.dropdownMessageArea then
		EMA.settingsControl.dropdownMessageArea:SetList(EMAApi.MessageAreaList())
	end

	if EMA.settingsControl.dropdownWarningArea then
		EMA.settingsControl.dropdownWarningArea:SetList(EMAApi.MessageAreaList())
	end
end

function EMA:SettingsSetMessageArea(event, value)
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsSetWarningArea(event, value)
	EMA.db.warningArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleTakeTaxi(event, checked)
	EMA.db.takeMastersTaxi = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleRequestStop(event, checked)
	EMA.db.requestTaxiStop = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeTaxiTimer(event, value)
	EMA.db.changeTaxiTime = tonumber(value)
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleMountWithTeam(event, checked)
	EMA.db.mountWithTeam = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDisMountWithTeam(event, checked)
	EMA.db.dismountWithTeam = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDisMountWithMaster(event, checked)
	EMA.db.dismountWithMaster = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleMountInRange(event, checked)
	EMA.db.mountInRange = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleAutoLoot(event, checked)
	EMA.db.autoLoot = checked
	EMA:SettingsRefresh()
end

function EMA:EMAOnSettingsReceived(characterName, settings)
	if characterName ~= EMA.characterName then
		EMA.db.takeMastersTaxi = settings.takeMastersTaxi
		EMA.db.requestTaxiStop = settings.requestTaxiStop
		EMA.db.changeTaxiTime = settings.changeTaxiTime or settings.changeTexiTime

		EMA.db.mountWithTeam = settings.mountWithTeam
		EMA.db.dismountWithTeam = settings.dismountWithTeam
		EMA.db.dismountWithMaster = settings.dismountWithMaster

		EMA.db.autoLoot = settings.autoLoot
		EMA.db.messageArea = settings.messageArea
		EMA.db.warningArea = settings.warningArea

		EMA:SettingsRefresh()
		EMA:Print(L["SETTINGS_RECEIVED_FROM_A"](characterName))
	end
end

function EMA:BeforeEMAProfileChanged()
end

function EMA:OnEMAProfileChanged()
	EMA:MigrateSettings()
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	if not EMA.settingsControl or not EMA.settingsControl.checkBoxTakeMastersTaxi then
		return
	end

	EMA.settingsControl.checkBoxTakeMastersTaxi:SetValue(EMA.db.takeMastersTaxi)
	EMA.settingsControl.checkBoxRequestStop:SetValue(EMA.db.requestTaxiStop)
	EMA.settingsControl.sliderTaxiDelay:SetValue(EMA.db.changeTaxiTime)

	if Compat:IsRetail() then
		if EMA.settingsControl.checkBoxMountWithTeam then
			EMA.settingsControl.checkBoxMountWithTeam:SetValue(EMA.db.mountWithTeam)
		end
		if EMA.settingsControl.checkBoxDismountWithTeam then
			EMA.settingsControl.checkBoxDismountWithTeam:SetValue(EMA.db.dismountWithTeam)
		end
		if EMA.settingsControl.checkBoxDismountWithMaster then
			EMA.settingsControl.checkBoxDismountWithMaster:SetValue(EMA.db.dismountWithMaster)
		end
	end

	if EMA.settingsControl.dropdownMessageArea then
		EMA.settingsControl.dropdownMessageArea:SetValue(EMA.db.messageArea)
	end
	if EMA.settingsControl.dropdownWarningArea then
		EMA.settingsControl.dropdownWarningArea:SetValue(EMA.db.warningArea)
	end
	if EMA.settingsControl.checkBoxAutoLoot then
		EMA.settingsControl.checkBoxAutoLoot:SetValue(EMA.db.autoLoot)
	end
end

-------------------------------------------------------------------------------------------------------------
-- Private sections.
-------------------------------------------------------------------------------------------------------------

local TaxiPrivate = {}
local MountPrivate = {}
local LootPrivate = {}

-------------------------------------------------------------------------------------------------------------
-- Taxi private helpers.
-------------------------------------------------------------------------------------------------------------

function TaxiPrivate:GetNow()
	if type(GetTime) == "function" then
		return GetTime()
	end
	return 0
end

function TaxiPrivate:GetFrame()
	if EMA.taxiState and EMA.taxiState.frame then
		return EMA.taxiState.frame
	end

	return Compat:GetTaxiFrame(EMA.taxiState and EMA.taxiState.uiMapSystem)
end

function TaxiPrivate:IsFrameVisible()
	local frame = self:GetFrame()
	return Compat:IsFrameVisible(frame)
end

function TaxiPrivate:SetFrame(uiMapSystem)
	EMA.taxiState.uiMapSystem = uiMapSystem
	EMA.taxiState.frame = Compat:GetTaxiFrame(uiMapSystem)
	EMA.TaxiFrameName = EMA.taxiState.frame
end

function TaxiPrivate:ClearPending()
	EMA.taxiState.pendingTake = false
	EMA.taxiState.pendingSender = nil
	EMA.taxiState.pendingNodeName = nil
	EMA.taxiState.pendingNodeIndex = nil
	EMA.taxiState.pendingCreatedAt = 0
end

function TaxiPrivate:ResetState()
	self:ClearPending()
	EMA.TakesTaxi = false
	EMA.LeavesTaxi = false
	EMA.taxiState.suppressCloseBroadcast = false
end

function TaxiPrivate:SetPending(sender, nodeName, taxiNodeIndex)
	EMA.taxiState.pendingTake = true
	EMA.taxiState.pendingSender = sender
	EMA.taxiState.pendingNodeName = nodeName
	EMA.taxiState.pendingNodeIndex = taxiNodeIndex
	EMA.taxiState.pendingCreatedAt = self:GetNow()
end

function TaxiPrivate:IsPendingFresh()
	if EMA.taxiState.pendingTake ~= true then
		return false
	end

	local createdAt = EMA.taxiState.pendingCreatedAt or 0
	if createdAt <= 0 then
		return false
	end

	return (self:GetNow() - createdAt) <= 2.0
end

function TaxiPrivate:GetNodeName(nodeIndex)
	if type(nodeIndex) ~= "number" then
		return nil
	end

	if not Compat:CanUseTaxiNodes() then
		return nil
	end

	local numNodes = NumTaxiNodes()
	if type(numNodes) ~= "number" or nodeIndex < 1 or nodeIndex > numNodes then
		return nil
	end

	return TaxiNodeName(nodeIndex)
end

function TaxiPrivate:FindNodeIndex(nodeName, taxiNodeIndex)
	if not Compat:CanUseTaxiNodes() then
		return nil
	end

	local numNodes = NumTaxiNodes()
	if type(numNodes) ~= "number" or numNodes <= 0 then
		return nil
	end

	if type(taxiNodeIndex) == "number" and taxiNodeIndex >= 1 and taxiNodeIndex <= numNodes then
		local indexedName = TaxiNodeName(taxiNodeIndex)
		if nodeName == nil or indexedName == nodeName then
			return taxiNodeIndex
		end
	end

	if type(nodeName) == "string" and nodeName ~= "" then
		for i = 1, numNodes do
			local currentName = TaxiNodeName(i)
			if currentName == nodeName then
				return i
			end
		end
	end

	return nil
end

function TaxiPrivate:CanTakeNow()
	if UnitOnTaxi("player") then
		return false
	end

	if not self:IsFrameVisible() then
		return false
	end

	if not Compat:CanUseTaxiNodes() then
		return false
	end

	local numNodes = NumTaxiNodes()
	if type(numNodes) ~= "number" or numNodes <= 0 then
		return false
	end

	return true
end

function TaxiPrivate:AttemptTake(nodeIndex)
	if type(nodeIndex) ~= "number" then
		return false
	end

	if not self:CanTakeNow() then
		return false
	end

	local ok = pcall(TakeTaxiNode, nodeIndex)
	if ok and UnitOnTaxi("player") then
		EMA.TakesTaxi = true
		EMA.taxiState.lastTakeAt = self:GetNow()
		EMA.taxiState.suppressCloseBroadcast = true
		return true
	end

	return false
end

function TaxiPrivate:ProcessPending()
	if not EMA.db.takeMastersTaxi then
		self:ClearPending()
		return
	end

	if EMA.taxiState.pendingTake ~= true then
		return
	end

	if not self:IsPendingFresh() then
		self:ClearPending()
		return
	end

	if not self:CanTakeNow() then
		return
	end

	local nodeName = EMA.taxiState.pendingNodeName
	local taxiNodeIndex = EMA.taxiState.pendingNodeIndex
	local nodeIndex = self:FindNodeIndex(nodeName, taxiNodeIndex)

	if nodeIndex == nil then
		EMA:EMASendMessageToTeam(
			EMA.db.messageArea,
			L["I_AM_UNABLE_TO_FLY_TO_A"](nodeName or UNKNOWN),
			false
		)
		self:ClearPending()
		return
	end

	if self:AttemptTake(nodeIndex) then
		self:ClearPending()
	end
end

function TaxiPrivate:TakeFromTeam(sender, nodeName, taxiNodeIndex)
	if not EMA.db.takeMastersTaxi then
		return
	end

	if sender == EMA.characterName then
		return
	end

	if not EMAApi.IsCharacterTheMaster(sender) then
		return
	end

	self:SetPending(sender, nodeName, taxiNodeIndex)
	EMA:SendMessage(EMA.MESSAGE_TAXI_TAKEN)
	self:ProcessPending()
end

function TaxiPrivate:LeaveFromTeam(sender)
	if not EMA.db.requestTaxiStop then
		return
	end

	if sender == EMA.characterName then
		return
	end

	if UnitOnTaxi("player") ~= true then
		return
	end

	EMA.LeavesTaxi = true
	pcall(TaxiRequestEarlyLanding)
	EMA.LeavesTaxi = false

	EMA:EMASendMessageToTeam(
		EMA.db.messageArea,
		L["REQUESTED_STOP_X"](sender),
		false
	)
end

function TaxiPrivate:ShouldSuppressClose()
	local recentTake = (self:GetNow() - (EMA.taxiState.lastTakeAt or 0)) < 1.5

	if EMA.taxiState.suppressCloseBroadcast == true then
		return true
	end

	if EMA.taxiState.pendingTake == true then
		return true
	end

	if recentTake then
		return true
	end

	return false
end

function TaxiPrivate:CloseFrame()
	if EMA.taxiState.pendingTake == true then
		return
	end

	if EMA.TakesTaxi == true then
		return
	end

	if UnitOnTaxi("player") == true then
		return
	end

	Compat:CloseTaxiMap()
end

-------------------------------------------------------------------------------------------------------------
-- Mount private helpers.
-------------------------------------------------------------------------------------------------------------

function MountPrivate:IsClassic()
	return Compat:IsClassic()
end

function MountPrivate:ClearCastingMount()
	EMA.castingMount = nil
	EMA.castingMountName = nil
end

function MountPrivate:ResetResponding()
	EMA.responding = false
end

function MountPrivate:CaptureCurrentMountFromJournal()
	if self:IsClassic() or not Compat:HasMountJournal() then
		return
	end

	self:ClearCastingMount()

	if not IsMounted() then
		return
	end

	local mountIDs = C_MountJournal.GetMountIDs()
	for i = 1, #mountIDs do
		local _, spellID, _, active = C_MountJournal.GetMountInfoByID(mountIDs[i])
		if active then
			EMA.isMounted = spellID
			EMA:RegisterEvent("UNIT_AURA")
			break
		end
	end
end

function MountPrivate:HandleSpellcastStart(unitID, spellID)
	if self:IsClassic() or not Compat:HasMountJournal() then
		return
	end

	if unitID ~= "player" then
		return
	end

	local mountIDs = C_MountJournal.GetMountIDs()
	for i = 1, #mountIDs do
		local creatureName, mountSpellID, _, _, _, _, _, _, _, _, _, mountID = C_MountJournal.GetMountInfoByID(mountIDs[i])
		if spellID == mountSpellID then
			if IsShiftKeyDown() == false and EMA.responding == false then
				EMA:EMASendCommandToTeam(EMA.COMMAND_MOUNT_ME, creatureName, mountID)
				EMA.castingMount = spellID
				EMA.castingMountName = creatureName
				break
			end
		end
	end
end

function MountPrivate:HandleSpellcastSucceeded(unitID, spellID)
	if self:IsClassic() or not Compat:HasMountJournal() then
		return
	end

	if not EMA.db.mountWithTeam then
		return
	end

	if EMA.castingMount == nil then
		return
	end

	if unitID ~= "player" then
		return
	end

	if EMA.CommandLineMount == true then
		return
	end

	if spellID == EMA.castingMount then
		EMA.isMounted = spellID
		EMA.mountName = EMA.castingMountName
		EMA:RegisterEvent("UNIT_AURA")
		self:ClearCastingMount()
	end
end

function MountPrivate:HandleUnitAura(unitID)
	if self:IsClassic() then
		return
	end

	if unitID ~= "player" or EMA.isMounted == nil then
		return
	end

	if not LibAuras or type(LibAuras.UnitAura) ~= "function" then
		return
	end

	if LibAuras:UnitAura(unitID, EMA.isMounted) then
		return
	end

	self:ClearCastingMount()

	if EMA.db.dismountWithMaster == true then
		if EMAApi.IsCharacterTheMaster(EMA.characterName) == true and IsShiftKeyDown() == false then
			EMA:EMASendCommandToTeam(EMA.COMMAND_MOUNT_DISMOUNT)
			EMA:UnregisterEvent("UNIT_AURA")
		end
		return
	end

	if EMA.db.dismountWithTeam == true and IsShiftKeyDown() == false then
		EMA:EMASendCommandToTeam(EMA.COMMAND_MOUNT_DISMOUNT)
		EMA:UnregisterEvent("UNIT_AURA")
	end
end

function MountPrivate:FindUsableMountForType(sourceMountID)
	if not Compat:HasMountJournal() then
		return false, nil
	end

	local _, _, _, _, isUsable, _, _, _, _, _, _, resolvedMountID =
		C_MountJournal.GetMountInfoByID(sourceMountID)

	local _, _, _, _, sourceMountTypeID =
		C_MountJournal.GetMountInfoExtraByID(sourceMountID)

	if isUsable == true then
		return true, resolvedMountID
	end

	for i = 1, C_MountJournal.GetNumMounts() do
		local _, _, _, _, altIsUsable, _, _, _, _, _, _, altMountID =
			C_MountJournal.GetMountInfoByID(i)

		if altIsUsable == true then
			local _, _, _, _, mountTypeID =
				C_MountJournal.GetMountInfoExtraByID(altMountID)

			if sourceMountTypeID == mountTypeID then
				return true, altMountID
			end
		end
	end

	return false, nil
end

function MountPrivate:TeamMount(characterName, name, mountID)
	if self:IsClassic() or not Compat:HasMountJournal() then
		return
	end

	EMA.responding = true

	if not EMA.db.mountWithTeam then
		self:ResetResponding()
		return
	end

	if IsMounted() then
		self:ResetResponding()
		return
	end

	if EMA.db.mountInRange == true and UnitIsVisible(Ambiguate(characterName, "none")) == false then
		self:ResetResponding()
		return
	end

	local hasMount, usableMountID = self:FindUsableMountForType(mountID)
	if hasMount ~= true then
		self:ResetResponding()
		return
	end

	if name == "Random" then
		C_MountJournal.SummonByID(0)
	else
		C_MountJournal.SummonByID(usableMountID)
	end

	self:ResetResponding()

	if IsMounted() == false then
		EMA:ScheduleTimer("AmNotMounted", 2)
	end
end

function MountPrivate:ReceiveRandomMountWithTeam(characterName, tag)
	if not Compat:HasMountJournal() then
		return
	end

	if EMAApi.IsCharacterInGroup(EMA.characterName, tag) ~= true then
		return
	end

	if IsMounted() == false then
		C_MountJournal.SummonByID(0)
		return
	end

	if EMA.db.dismountWithTeam == true then
		Dismount()
	end
end

-------------------------------------------------------------------------------------------------------------
-- Loot private helpers.
-------------------------------------------------------------------------------------------------------------

function LootPrivate:HandleLootReady()
	if EMA.db.autoLoot == true then
		self:DoLoot()
	end
end

function LootPrivate:DoLoot(tries)
	if tries == nil then
		tries = 0
	end

	local numberFreeSlots = LibBagUtils:CountSlots("BAGS", 0)
	if numberFreeSlots <= 0 then
		return
	end

	local numloot = GetNumLootItems()
	if numloot ~= 0 then
		for slot = 1, numloot do
			local locked = select(6, GetLootSlotInfo(slot))
			if locked ~= nil and not locked then
				LootSlot(slot)
				numloot = GetNumLootItems()
			end
		end

		tries = tries + 1
		if tries < 8 then
			EMA:ScheduleTimer("doLoot", 0.6, tries)
		else
			CloseLoot()
		end
	else
		CloseLoot()
	end
end

function LootPrivate:EnableAutoLoot()
	if EMA.db.autoLoot == true and GetCVar("autoLootDefault") == "0" then
		SetCVar("autoLootDefault", 1)
	end
end

-------------------------------------------------------------------------------------------------------------
-- Taxi functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:TAXIMAP_OPENED(event, ...)
	local uiMapSystem = ...
	TaxiPrivate:SetFrame(uiMapSystem)
	EMA.taxiState.suppressCloseBroadcast = false

	if TaxiPrivate:IsPendingFresh() then
		TaxiPrivate:ProcessPending()
	else
		TaxiPrivate:ClearPending()
	end
end

function EMA:TakeTaxiNode(taxiNodeIndex)
	if not EMA.db.takeMastersTaxi then
		return
	end

	local nodeName = TaxiPrivate:GetNodeName(taxiNodeIndex)

	if EMA.TakesTaxi == true then
		EMA.TakesTaxi = false
		EMA.taxiState.lastTakeAt = TaxiPrivate:GetNow()
		return
	end

	EMA.taxiState.lastTakeAt = TaxiPrivate:GetNow()
	EMA:EMASendCommandToTeam(EMA.COMMAND_TAKE_TAXI, nodeName, taxiNodeIndex)
end

function EMA:TaxiRequestEarlyLanding(sender)
	if not EMA.db.requestTaxiStop then
		return
	end

	if UnitOnTaxi("player") == true and EMA.LeavesTaxi == false then
		EMA:EMASendCommandToTeam(EMA.COMMAND_EXIT_TAXI)
	end

	EMA.LeavesTaxi = false
end

function EMA:TAXIMAP_CLOSED(event, ...)
	if TaxiPrivate:ShouldSuppressClose() then
		EMA.taxiState.suppressCloseBroadcast = false
		return
	end

	TaxiPrivate:ClearPending()

	local taxiFrame = TaxiPrivate:GetFrame()
	if taxiFrame and type(taxiFrame.IsVisible) == "function" and not taxiFrame:IsVisible() then
		EMA:EMASendCommandToTeam(EMA.COMMAND_CLOSE_TAXI)
	end
end

-------------------------------------------------------------------------------------------------------------
-- Mount functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:PLAYER_ENTERING_WORLD(event, ...)
	TaxiPrivate:ResetState()

	LootPrivate:EnableAutoLoot()
	MountPrivate:CaptureCurrentMountFromJournal()
end

function EMA:PLAYER_CONTROL_GAINED(event, ...)
	if not UnitOnTaxi("player") then
		TaxiPrivate:ResetState()
	end
end

function EMA:UNIT_SPELLCAST_START(event, unitID, lineID, spellID, ...)
	MountPrivate:HandleSpellcastStart(unitID, spellID)
end

function EMA:UNIT_SPELLCAST_SUCCEEDED(event, unitID, lineID, spellID, ...)
	MountPrivate:HandleSpellcastSucceeded(unitID, spellID)
end

function EMA:UNIT_AURA(event, unitID, ...)
	MountPrivate:HandleUnitAura(unitID)
end

function EMA:TeamMount(characterName, name, mountID)
	MountPrivate:TeamMount(characterName, name, mountID)
end

function EMA:AmNotMounted()
	if IsMounted() == false then
		EMA:EMASendMessageToTeam(EMA.db.warningArea, L["I_AM_UNABLE_TO_MOUNT"], false)
	end
end

function EMA:RandomMountWithTeam(info, parameters)
	local tag = parameters
	EMA:EMASendCommandToTeam(EMA.COMMAND_MOUNT_COMMAND, tag)
end

function EMA:ReceiveRandomMountWithTeam(characterName, tag)
	MountPrivate:ReceiveRandomMountWithTeam(characterName, tag)
end

-------------------------------------------------------------------------------------------------------------
-- Loot functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:LOOT_READY(event, ...)
	LootPrivate:HandleLootReady()
end

function EMA:doLoot(tries)
	LootPrivate:DoLoot(tries)
end

function EMA:doLootLoop(tries)
	EMA:ScheduleTimer("doLoot", 0.6, tries)
end

function EMA:EnableAutoLoot()
	LootPrivate:EnableAutoLoot()
end

-------------------------------------------------------------------------------------------------------------
-- EMA command handling.
-------------------------------------------------------------------------------------------------------------

function EMA:EMAOnCommandReceived(characterName, commandName, ...)
	if characterName ~= self.characterName then
		if commandName == EMA.COMMAND_TAKE_TAXI then
			if not UnitOnTaxi("player") then
				TaxiPrivate:TakeFromTeam(characterName, ...)
			end
			return
		end

		if commandName == EMA.COMMAND_EXIT_TAXI then
			if UnitOnTaxi("player") then
				TaxiPrivate:LeaveFromTeam(characterName)
			end
			return
		end

		if commandName == EMA.COMMAND_CLOSE_TAXI then
			TaxiPrivate:CloseFrame()
			return
		end

		if commandName == EMA.COMMAND_MOUNT_ME then
			MountPrivate:TeamMount(characterName, ...)
			return
		end

		if commandName == EMA.COMMAND_MOUNT_DISMOUNT then
			if IsMounted() then
				Dismount()
			end
			return
		end
	end

	if commandName == EMA.COMMAND_MOUNT_COMMAND then
		MountPrivate:ReceiveRandomMountWithTeam(characterName, ...)
	end
end

function EMA:UPDATE_BINDINGS()
	if InCombatLockdown() then
		return
	end

	if not EMA.keyBindingFrame then
		return
	end

	ClearOverrideBindings(EMA.keyBindingFrame)

	local key1, key2 = GetBindingKey("TEAMMOUNT")
	if key1 then
		SetOverrideBindingClick(EMA.keyBindingFrame, false, key1, "EMATeamSecureButtonMount")
	end
	if key2 then
		SetOverrideBindingClick(EMA.keyBindingFrame, false, key2, "EMATeamSecureButtonMount")
	end
end

EMAApi.Taxi = {}
EMAApi.Taxi.MESSAGE_TAXI_TAKEN = EMA.MESSAGE_TAXI_TAKEN
