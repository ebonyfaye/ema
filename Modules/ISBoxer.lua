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
	"ISBoxer", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceTimer-3.0"
)

-- Get the EMA Utilities Library.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local ISBoxerAddon = IsAddOnLoaded("Isboxer" )
local AceGUI = LibStub( "AceGUI-3.0" )

--  Constants and Locale for this module.
EMA.moduleName = "ISBoxer"
EMA.settingsDatabaseName = "ISBoxerProfileDB"
EMA.chatCommand = "ema-isboxer"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["TEAM"]
EMA.moduleDisplayName = L["ISBOXER"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\ISBoxerIcon.tga"
-- order
EMA.moduleOrder = 30


-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		messageArea = EMAApi.DefaultMessageArea(),
		isboxerTeamList = {},
		isboxerTeamName = L["N/A"],
		isboxerSync = false,
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
				usage = "/ema-isboxer config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_ALL_SETTINGS"],
				usage = "/ema-isboxer push",
				get = false,
				set = "EMASendSettings",
				guiHidden = true,
			},
			iammaster = {
				type = "input",
				name = L["ISBOXER_SET_MASTER"],
				desc = L["ISBOXER_COMMAND_LINE_HELP"],
				usage = "/ema-isboxer iammaster <group>",
				get = false,
				set = "CommandIAmMasterIsboxer",
				guiHidden = true,
			},
			strobeOnMe = {
				type = "input",
				name = L["ISBOXER_SET_STROBEONME"],
				desc = L["ISBOXER_COMMAND_LINE_HELP"],
				usage = "/ema-isboxer strobeOnMe <group>",
				get = false,
				set = "FollowStrobeOnMeCommandIsboxer",
				guiHidden = true,
			},
			strobeoff = {
				type = "input",
				name = L["ISBOXER_SET_STROBEOFF"],
				desc = L["ISBOXER_COMMAND_LINE_HELP"],
				usage = "/ema-isboxer strobeoff <group>",
				get = false,
				set = "FollowStrobeOffCommandIsboxer",
				guiHidden = true,
			},
			snw = {
				type = "input",
				name = L["ISBOXER_SET_SNW"],
				desc = L["ISBOXER_COMMAND_LINE_HELP"],
				usage = "/ema-isboxer snw",
				get = false,
				set = "FollowStrobeOffCommandSnw",
				guiHidden = true,
			},
		},
	}
	return configuration
end

-------------------------------------------------------------------------------------------------------------
-- CommandLines for this module sends. (cross "Jamba" Support) for isboxer
-------------------------------------------------------------------------------------------------------------

function EMA:ChatCommandTeam(input)
	if not input or input:trim() == "" then
		return
	else
	LibStub( "AceConfigCmd-3.0" ):HandleCommand( EMA.chatCommand, EMA.moduleName, input )
	end
end

function EMA:ChatCommandFollow(input)
  --EMA:Print("test", input )
	if not input or input:trim() == "" then
		return
	else
	LibStub( "AceConfigCmd-3.0" ):HandleCommand( EMA.chatCommand, EMA.moduleName, input )
	end
end

function EMA:CommandIAmMasterIsboxer( info, parameters )
	EMAApi.CommandIAmMaster( parameters )
end
	
function EMA:FollowStrobeOnMeCommandIsboxer( info, parameters )
	EMAApi.Follow.StrobeOnMeCommand( parameters )
end

function EMA:FollowStrobeOffCommandIsboxer( info, parameters )
	EMAApi.Follow.StrobeOffCommand( parameters )
end

function EMA:FollowStrobeOffCommandSnw( info, parameters )
	
end

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
-- Popup Dialogs.
-------------------------------------------------------------------------------------------------------------

local function InitializePopupDialogs()
	StaticPopupDialogs["EMAISBoxer_CONFIRM_REMOVE_ISBoxer_ITEMS"] = {
        text = L["REMOVE_ISBOXER_LIST"],
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

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	--EMA.autoISBoxerItemLink = L["N/A"]
	EMA.isboxerTeamName = L["N/A"]
	-- CommandLines for this module sends. (cross "Jamba" Support) for isboxer
	EMA:RegisterChatCommand("jamba-team", "ChatCommandTeam")
	EMA:RegisterChatCommand("jamba-follow", "ChatCommandFollow")
	EMA.autoISBoxerItemTag = EMAApi.AllTag()
	-- Create the settings control.
	EMA:SettingsCreate()
	-- Initialse the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "PLAYER_ENTERING_WORLD" )
	--EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	--EMA:RegisterMessage( EMAApi.GROUP_LIST_CHANGED , "OnGroupAreasChanged" )
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
	local bottomOfInfo = EMA:SettingsCreateISBoxer( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsCreateISBoxer( top )
	local buttonControlWidth = 85
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local labelContinueHeight = EMAHelperSettings:GetContinueLabelHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local ISBoxerWidth = headingWidth
	local dropBoxWidth = (headingWidth - horizontalSpacing) / 4
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ISBOXER_LIST_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.ISBoxerItemsHighlightRow = 1
	EMA.settingsControl.ISBoxerItemsOffset = 1
	local list = {}
	list.listFrameName = "EMAISBoxerIteamsSettingsFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = ISBoxerWidth
	list.rowHeight = 20
	list.rowsToDisplay = 10
	list.columnsToDisplay = 3
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 10
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 70
	list.columnInformation[2].alignment = "LEFT"
	list.columnInformation[3] = {}
	list.columnInformation[3].width = 20
	list.columnInformation[3].alignment = "LEFT"	
	list.scrollRefreshCallback = EMA.SettingsScrollRefresh
	list.rowClickCallback = EMA.SettingsISBoxerItemsRowClick
	EMA.settingsControl.ISBoxerItems = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.ISBoxerItems )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["ISBOXER_SYNC_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	-- Information line 1.
	EMA.settingsControl.labelSyncInformation1 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["SYNCINFORMATIONONE"] 
	)	
	movingTop = movingTop - labelContinueHeight		
	-- Information line 2.
	EMA.settingsControl.labelSyncInformation2 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["SYNCINFORMATIONTWO"] 
	)	
	movingTop = movingTop - labelContinueHeight		
	-- Information line 3.
	EMA.settingsControl.labelSyncInformation3 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop,
		L["SYNCINFORMATIONTHREE"] 
	)	
	movingTop = movingTop - labelHeight

	EMA.settingsControl.checkBoxISBoxerSnyc = EMAHelperSettings:CreateCheckBox( 
	EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["CHECKBOX_ISBOXER_SYNC"],
		EMA.SettingsToggleIsboxerSync,
		L["CHECKBOX_ISBOXER_SYNC_HELP"]
	)
	--[[
	movingTop = movingTop - checkBoxHeight	
	EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["MESSAGE_AREA"] 
	)
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
	EMA.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", EMA.SettingsSetMessageArea )
	]]
	movingTop = movingTop - dropdownHeight - verticalSpacing
	return movingTop	
end


-------------------------------------------------------------------------------------------------------------
-- Settings Callbacks.
-------------------------------------------------------------------------------------------------------------

local function GetISBoxerTeamMaxPosition()
	return #EMA.db.isboxerTeamList
end

function EMA:GetISBoxerTeamAtPosition( position )
	return EMA.db.isboxerTeamList[position]
end

local function GetCharacterNameAtOrderPosition( position )
	local characterNameAtPosition = ""
	for characterPosition, characterName in pairs(EMA.db.isboxerTeamList) do
		if characterPosition == position then
			characterNameAtPosition = characterName
			break
		end
	end
	return characterNameAtPosition
end

function EMA:SettingsScrollRefresh()
	FauxScrollFrame_Update(
		EMA.settingsControl.ISBoxerItems.listScrollFrame, 
		GetISBoxerTeamMaxPosition(),
		EMA.settingsControl.ISBoxerItems.rowsToDisplay, 
		EMA.settingsControl.ISBoxerItems.rowHeight
	)
	EMA.settingsControl.ISBoxerItemsOffset = FauxScrollFrame_GetOffset( EMA.settingsControl.ISBoxerItems.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.ISBoxerItems.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[3].textString:SetText( "" )
		EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[3].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )		
		EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.ISBoxerItemsOffset
		if dataRowNumber <= GetISBoxerTeamMaxPosition() then
			-- Put data information into columns.
			local characterName = GetCharacterNameAtOrderPosition( dataRowNumber )
			local teamName = EMA.db.isboxerTeamName
			EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[1].textString:SetText( dataRowNumber )
			EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[2].textString:SetText( characterName )
			EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].columns[3].textString:SetText( teamName )
			-- Highlight the selected row.
			--if dataRowNumber == EMA.settingsControl.ISBoxerItemsHighlightRow then
			--	EMA.settingsControl.ISBoxerItems.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			--end
		end
	end
end

function EMA:SettingsISBoxerItemsRowClick( rowNumber, columnNumber )		
	--[[
	if EMA.settingsControl.ISBoxerItemsOffset + rowNumber <= EMA:GetISBoxerItemsMaxPosition() then
		EMA.settingsControl.ISBoxerItemsHighlightRow = EMA.settingsControl.ISBoxerItemsOffset + rowNumber
		EMA:SettingsScrollRefresh()
	end
	]]
end

--[[
function EMA:OnMessageAreasChanged( message )
	EMA.settingsControl.dropdownMessageArea:SetList( EMAApi.MessageAreaList() )
end

function EMA:OnGroupAreasChanged( message )
	EMA.settingsControl.ISBoxerItemsEditBoxToonTag:SetList( EMAApi.GroupList() )
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.messageArea = value
	EMA:SettingsRefresh()
end
]]

function EMA:SettingsToggleIsboxerSync( event, checked )
	EMA.db.isboxerSync = checked
	EMA:SettingsRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.isboxerSync = settings.isboxerSync
		--EMA.db.messageArea = settings.messageArea
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
	EMA.settingsControl.checkBoxISBoxerSnyc:SetValue ( EMA.db.isboxerSync )
	
	--EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.messageArea )
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
-- ISBoxer functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:PLAYER_ENTERING_WORLD(event, ... )
	EMA:ScheduleTimer( "IsboxerSyncTeamList", 0.5 )
	EMA:AddIsboxerMembers()
end

function EMA:AddIsboxerMembers()
	--table.wipe( EMA.db.isboxerTeamList )
	if IsAddOnLoaded("Isboxer" ) == true then 
		--EMA:Print("test")
		--local _, teamName, members = isboxer.CharacterSet
		for value, data in pairs( isboxer.CharacterSet ) do
			--EMA:Print("test",value, "data", data )
			if value == "Members" then 
			--EMA:Print("testMembersList")
				for isbSlot, characterName in pairs( data ) do 
					if EMA.db.isboxerTeamList[isbSlot] == nil then
						EMA.db.isboxerTeamList[isbSlot] = characterName
					end					
				end
			else
				--EMA:Print("testTeamListName", data )
				EMA.db.isboxerTeamName = data
			end	
		end
	end	
end

local function IsboxerTeamList()
	return pairs( EMA.db.isboxerTeamList )
end	

local function IsStillInTeam( characterName )
	local stillInTeam = false
	for value, data in pairs( isboxer.CharacterSet ) do
		--EMA:Print("test",value, "data", data )
		if value == "Members" then 
		--EMA:Print("testMembersList")
			for b, isboxerCharacterName in pairs( data ) do 
				--EMA:Print("test", characterName, "vs", isboxerCharacterName )
				if isboxerCharacterName == characterName then
				stillInTeam = true
				break
				end
			end	
		end			
	end
	return stillInTeam
end

function EMA:IsboxerSyncTeamList()
	if EMA.db.isboxerSync == true and IsAddOnLoaded("Isboxer" ) == true then
		for isbSlot, isboxerCharacterName in pairs( EMA.db.isboxerTeamList ) do
			--EMA:Print("test", isboxerCharacterName)
			local characterName = EMAUtilities:AddRealmToNameIfMissing( isboxerCharacterName )
			if EMAApi.IsCharacterInTeam ( isboxerCharacterName ) == false and (characterName ~= EMA.characterName ) then
				--EMA:Print("NOT IN TEAM", isboxerCharacterName)
				EMAApi.AddMember( characterName )
			elseif IsStillInTeam( characterName ) == false and (characterName ~= EMA.characterName ) then
				if EMAApi.IsCharacterInTeam ( characterName ) == true then
					--EMA:Print("NoLongerInTeam", characterName, isbSlot )
					EMA.db.isboxerTeamList[isbSlot] = nil	
					EMAApi.RemoveMember( characterName ) 
				end
			end
		end
	end
	EMA:SettingsScrollRefresh()
end

EMAApi.IsboxerTeamList = IsboxerTeamList
EMAApi.addisboxermembers = EMA.AddIsboxerMembers