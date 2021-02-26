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

-- THIS FILE NEED A GOOD REWIRE ONEDAY, AND A PAIN IN THE NECK TO USE.........


-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Message",
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0"
)

-- Load libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local Media = LibStub("LibSharedMedia-3.0")

-- Built in Sounds
Media:Register("sound", "EMA: RaidWarning", "Interface\\Addons\\EMA\\Media\\Sounds\\raidwarning.ogg" )
Media:Register("sound", "EMA: Warning", "Interface\\Addons\\EMA\\Media\\Sounds\\Warning.ogg")
 
-- Constants and Locale for this module.
EMA.moduleName = "Message"
EMA.settingsDatabaseName = "MessageProfileDB"
EMA.chatCommand = "ema-message"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["OPTIONS"]
EMA.moduleDisplayName = L["MESSAGE_DISPLAY"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\ChatIcon.tga"
-- order
EMA.moduleOrder = 80



-------------------------------------------------------------------------------------------------------------
-- Message area management.
-------------------------------------------------------------------------------------------------------------

-- areas = {}
-- areas["areaname"].type
-- areas["areaname"].tag
-- areas["areaname"].channelName
-- areas["areaname"].channelPassword
-- areas["areaname"].chatWindowName 
-- areas["areaname"].areaOnScreenName
-- areas["areaname"].soundToPlay

-- Message area types.
EMA.AREA_TYPE_DEFAULT_CHAT = 1
--EMA.AREA_TYPE_SPECIFIC_CHAT = 2
EMA.AREA_TYPE_WHISPER = 3
EMA.AREA_TYPE_PARTY = 4
EMA.AREA_TYPE_GUILD = 5
EMA.AREA_TYPE_GUILD_OFFICER = 6
EMA.AREA_TYPE_RAID = 7
EMA.AREA_TYPE_RAID_WARNING = 8
--EMA.AREA_TYPE_CHANNEL = 9
--EMA.AREA_TYPE_PARROT = 10
--EMA.AREA_TYPE_MSBT = 11
EMA.AREA_TYPE_MUTE = 12

-- Message area types names and uses information.
EMA.areaTypes = {}
-- Default chat window.
EMA.areaTypes[EMA.AREA_TYPE_DEFAULT_CHAT] = {}
EMA.areaTypes[EMA.AREA_TYPE_DEFAULT_CHAT].name = L["DEFAULT_CHAT_WINDOW"]
EMA.areaTypes[EMA.AREA_TYPE_DEFAULT_CHAT].usesTag = true
EMA.areaTypes[EMA.AREA_TYPE_DEFAULT_CHAT].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_DEFAULT_CHAT].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_DEFAULT_CHAT].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_DEFAULT_CHAT].mustBeWired = true
EMA.areaTypes[EMA.AREA_TYPE_DEFAULT_CHAT].usesSound = true
-- Specific chat window.
--[[
EMA.areaTypes[EMA.AREA_TYPE_SPECIFIC_CHAT] = {}
EMA.areaTypes[EMA.AREA_TYPE_SPECIFIC_CHAT].name = L["Specific Chat Window"]
EMA.areaTypes[EMA.AREA_TYPE_SPECIFIC_CHAT].usesTag = true
EMA.areaTypes[EMA.AREA_TYPE_SPECIFIC_CHAT].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_SPECIFIC_CHAT].usesChatWindowName = true
EMA.areaTypes[EMA.AREA_TYPE_SPECIFIC_CHAT].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_SPECIFIC_CHAT].mustBeWired = true
EMA.areaTypes[EMA.AREA_TYPE_SPECIFIC_CHAT].usesSound = true
]]--
-- Whisper.
EMA.areaTypes[EMA.AREA_TYPE_WHISPER] = {}
EMA.areaTypes[EMA.AREA_TYPE_WHISPER].name = L["WHISPER"]
EMA.areaTypes[EMA.AREA_TYPE_WHISPER].usesTag = true
EMA.areaTypes[EMA.AREA_TYPE_WHISPER].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_WHISPER].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_WHISPER].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_WHISPER].mustBeWired = true
EMA.areaTypes[EMA.AREA_TYPE_WHISPER].usesSound = true
-- Party.
EMA.areaTypes[EMA.AREA_TYPE_PARTY] = {}
EMA.areaTypes[EMA.AREA_TYPE_PARTY].name = L["PARTY"]
EMA.areaTypes[EMA.AREA_TYPE_PARTY].usesTag = false
EMA.areaTypes[EMA.AREA_TYPE_PARTY].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_PARTY].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_PARTY].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_PARTY].mustBeWired = false
EMA.areaTypes[EMA.AREA_TYPE_PARTY].usesSound = true
-- Guild.
EMA.areaTypes[EMA.AREA_TYPE_GUILD] = {}
EMA.areaTypes[EMA.AREA_TYPE_GUILD].name = L["GUILD"]
EMA.areaTypes[EMA.AREA_TYPE_GUILD].usesTag = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD].mustBeWired = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD].usesSound = true
-- Guild Officer.
EMA.areaTypes[EMA.AREA_TYPE_GUILD_OFFICER] = {}
EMA.areaTypes[EMA.AREA_TYPE_GUILD_OFFICER].name = L["GUILD_OFFICER"]
EMA.areaTypes[EMA.AREA_TYPE_GUILD_OFFICER].usesTag = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD_OFFICER].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD_OFFICER].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD_OFFICER].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD_OFFICER].mustBeWired = false
EMA.areaTypes[EMA.AREA_TYPE_GUILD_OFFICER].usesSound = true
-- Raid.
EMA.areaTypes[EMA.AREA_TYPE_RAID] = {}
EMA.areaTypes[EMA.AREA_TYPE_RAID].name = L["RAID"]
EMA.areaTypes[EMA.AREA_TYPE_RAID].usesTag = false
EMA.areaTypes[EMA.AREA_TYPE_RAID].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_RAID].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_RAID].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_RAID].mustBeWired = false
EMA.areaTypes[EMA.AREA_TYPE_RAID].usesSound = true
-- Raid Warning.
EMA.areaTypes[EMA.AREA_TYPE_RAID_WARNING] = {}
EMA.areaTypes[EMA.AREA_TYPE_RAID_WARNING].name = L["RAID_WARNING"]
EMA.areaTypes[EMA.AREA_TYPE_RAID_WARNING].usesTag = true
EMA.areaTypes[EMA.AREA_TYPE_RAID_WARNING].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_RAID_WARNING].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_RAID_WARNING].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_RAID_WARNING].mustBeWired = true
EMA.areaTypes[EMA.AREA_TYPE_RAID_WARNING].usesSound = true
-- Private Channel.
--[[
EMA.areaTypes[EMA.AREA_TYPE_CHANNEL] = {}
EMA.areaTypes[EMA.AREA_TYPE_CHANNEL].name = L["Channel"]
EMA.areaTypes[EMA.AREA_TYPE_CHANNEL].usesTag = false
EMA.areaTypes[EMA.AREA_TYPE_CHANNEL].usesChannel = true
EMA.areaTypes[EMA.AREA_TYPE_CHANNEL].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_CHANNEL].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_CHANNEL].mustBeWired = false
EMA.areaTypes[EMA.AREA_TYPE_CHANNEL].usesSound = true
--]]
-- Mute.
EMA.areaTypes[EMA.AREA_TYPE_MUTE] = {}
EMA.areaTypes[EMA.AREA_TYPE_MUTE].name = L["MUTE"]
EMA.areaTypes[EMA.AREA_TYPE_MUTE].usesTag = false
EMA.areaTypes[EMA.AREA_TYPE_MUTE].usesChannel = false
EMA.areaTypes[EMA.AREA_TYPE_MUTE].usesChatWindowName = false
EMA.areaTypes[EMA.AREA_TYPE_MUTE].usesScreen = false
EMA.areaTypes[EMA.AREA_TYPE_MUTE].mustBeWired = false
EMA.areaTypes[EMA.AREA_TYPE_MUTE].usesSound = false

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		["areas"] = {
			{
				["type"] = 1,
				["name"] = L["DEFAULT_MESSAGE"],
				["tag"] = EMAPrivate.Tag.MasterTag(),
			},
			{
				["type"] = 8,
				["name"] = L["DEFAULT_WARNING"],
				["tag"] = EMAPrivate.Tag.MasterTag(),
				["soundToPlay"] = "EMA: RaidWarning",
			},
			{
				["type"] = 12,
				["name"] = L["MUTE_POFILE"],
			},			
		},
	},
}

 EMA.simpleAreaList = {}
 
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
				usage = "/ema-message config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-message push",
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

EMA.COMMAND_MESSAGE = "EMAMessageMessage"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-- Master changed, parameter: new master name.
EMA.MESSAGE_MESSAGE_AREAS_CHANGED = "EMAMessageMessageAreasChanged"

-------------------------------------------------------------------------------------------------------------
-- Constants used by module.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Settings Populate.
-------------------------------------------------------------------------------------------------------------

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	-- Update the settings area list.
	EMA:SettingsAreaListScrollRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.areas = EMAUtilities:CopyTable( settings.areas )
		-- Refresh the settings.
		EMA:SettingsRefresh()
		EMA:SendMessage( EMA.MESSAGE_MESSAGE_AREAS_CHANGED )
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

-------------------------------------------------------------------------------------------------------------
-- Area management.
-------------------------------------------------------------------------------------------------------------

local function MessageAreaList()
	EMAUtilities:ClearTable( EMA.simpleAreaList )
	for index, area in ipairs( EMA.db.areas ) do
		EMA.simpleAreaList[area.name] = area.name
	end
	table.sort( EMA.simpleAreaList )
	return EMA.simpleAreaList
end

local function GetAreaByName( areaName )	
	for index, area in ipairs( EMA.db.areas ) do
		if area.name == areaName then
			return area
		end
	end
	return nil
end

local function GetAreaAtPosition( position )
	return EMA.db.areas[position]
end

local function SetAreaAtPosition( position, areaInformation )
	EMA.db.areas[position] = areaInformation
end
	
local function GetAreaListMaxPosition()
	return #EMA.db.areas
end

local function DoesAreaListContainArea( name )
	local containsArea = false
	for index, area in ipairs( EMA.db.areas ) do
		if area.name == name then
			containsArea = true
			break
		end
	end
	return containsArea
end

local function AddArea( name )
	if DoesAreaListContainArea( name ) == false then
		-- Add a new area.
		local newArea = {}
		newArea.name = name
		newArea.type = EMA.AREA_TYPE_DEFAULT_CHAT
		table.insert( EMA.db.areas, newArea )
		-- Refresh the settings.
		EMA:SettingsRefresh()
		EMA:SendMessage( EMA.MESSAGE_MESSAGE_AREAS_CHANGED )
	end
end
		
local function RemoveArea( name )
	if DoesAreaListContainArea( name ) == true then
		local areaIndex = 0
		for index, area in ipairs( EMA.db.areas ) do
			if area.name == name then
				areaIndex = index
				break
			end
		end
		if areaIndex ~= 0 then
			table.remove( EMA.db.areas, areaIndex )
			-- Send a message to any listeners that the message areas have changed.
			EMA:SendMessage( EMA.MESSAGE_MESSAGE_AREAS_CHANGED )
		end
	end
end

function EMA:AddAreaGUI( name )
	AddArea( name )
	EMA:SettingsAreaListScrollRefresh()
end

function EMA:RemoveAreaGUI()
	local area = GetAreaAtPosition( EMA.settingsControl.areaListHighlightRow )	
	RemoveArea( area.name )
	EMA.settingsControl.areaListHighlightRow = 1	
	EMA:SettingsAreaListScrollRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreateAreaList()
	-- Position and size constants.
	local areaListButtonControlWidth = 125
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local top = EMAHelperSettings:TopOfSettings()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local areaListWidth = headingWidth
	-- Team list internal variables (do not change).
	EMA.settingsControl.areaListHighlightRow = 1
	EMA.settingsControl.areaListOffset = 1
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	top = top - headingHeight
	-- Create a heading.
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["MESSAGE_AREA_LIST"], top, false )
	-- Create an area list frame.

	local list = {}
	list.listFrameName = "EMAMessageSettingsAreaListFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = top - headingHeight
	list.listLeft = left
	list.listWidth = areaListWidth
	list.rowHeight = 20
	list.rowsToDisplay = 8
	list.columnsToDisplay = 2
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 60
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 40
	list.columnInformation[2].alignment = "LEFT"
	list.scrollRefreshCallback = EMA.SettingsAreaListScrollRefresh
	list.rowClickCallback = EMA.SettingsAreaListRowClick
	EMA.settingsControl.areaList = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.areaList )
	-- Position and size constants (once list height is known).
	local bottomOfList = top - headingHeight - list.listHeight - verticalSpacing	
	local bottomOfSection = bottomOfList - verticalSpacing - buttonHeight - verticalSpacing 
	-- Create buttons.
	EMA.settingsControl.areaListButtonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		areaListButtonControlWidth, 
		left, 
		bottomOfList, 
		L["ADD"],
		EMA.SettingsAddClick,
		L["ADD_MSG_HELP"]
	)
	EMA.settingsControl.areaListButtonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		areaListButtonControlWidth, 
		left + horizontalSpacing + areaListButtonControlWidth, 
		bottomOfList, 
		L["REMOVE"],
		EMA.SettingsRemoveClick,
		L["REMOVE_MSG_HELP"]
	)	
	
	return bottomOfSection
end

local function SettingsCreateAreaTypes( top )
	local areaListButtonControlWidth = 125
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - (horizontalSpacing  * 3)) / 2
	local column1Left = left
	local column2Left = left + halfWidth + (horizontalSpacing * 3)
	local areaConfigurationTop = top - headingHeight
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	top = top - headingHeight
	--Main Heading
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["MESSAGE_AREA_CONFIGURATION"], top, false )
	EMA.settingsControl.areaTypeDropdown = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		areaConfigurationTop, 
		L["MESSAGE_AREA"]
	)
	areaConfigurationTop = areaConfigurationTop - dropdownHeight
	local areaList = {}
	for areaType, areaTypeInformation in pairs( EMA.areaTypes ) do
		areaList[areaType] = areaTypeInformation.name
	end
	EMA.settingsControl.areaTypeDropdown:SetList( areaList )
	EMA.settingsControl.areaTypeDropdown:SetCallback( "OnValueChanged", EMA.UpdateAreaTypeControls )
	EMA.settingsControl.areaEditBoxTag = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		headingWidth,
		column1Left,
		areaConfigurationTop,
		L["GROUP"]
	)
	EMA.settingsControl.areaEditBoxTag:SetCallback( "OnEnterPressed", EMA.EditBoxTagChanged )
	areaConfigurationTop = areaConfigurationTop - dropdownHeight	
	EMA.settingsControl.areaEditBoxName = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		headingWidth,
		column1Left,
		areaConfigurationTop,
		L["NAME"]
	)
	EMA.settingsControl.areaEditBoxName:SetCallback( "OnEnterPressed", EMA.EditBoxNameChanged )
	areaConfigurationTop = areaConfigurationTop - dropdownHeight	
	EMA.settingsControl.areaEditBoxPassword = EMAHelperSettings:CreateEditBox( EMA.settingsControl,
		headingWidth,
		column1Left,
		areaConfigurationTop,
		L["PASSWORD"]
	)	
	EMA.settingsControl.areaEditBoxPassword:SetCallback( "OnEnterPressed", EMA.EditBoxPasswordChanged )
	areaConfigurationTop = areaConfigurationTop - dropdownHeight	
	EMA.settingsControl.areaOnScreenDropdown = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		areaConfigurationTop, 
		L["AREA"]
	)
	EMA.settingsControl.areaOnScreenDropdown:SetCallback( "OnValueChanged", EMA.UpdateAreaOnScreenControls )
	areaConfigurationTop = areaConfigurationTop - dropdownHeight
	areaConfigurationTop = areaConfigurationTop - verticalSpacing - verticalSpacing
	EMA.settingsControl.areaSoundDropdown = EMAHelperSettings:CreateMediaSound( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		areaConfigurationTop,
		L["SOUND_TO_PLAY"]
	)
	EMA.settingsControl.areaSoundDropdown:SetCallback( "OnValueChanged", EMA.UpdateSoundControls )

	areaConfigurationTop = areaConfigurationTop - dropdownHeight
	areaConfigurationTop = areaConfigurationTop - verticalSpacing - verticalSpacing
	EMA.settingsControl.areaListButtonUpdate = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		areaListButtonControlWidth, 
		column1Left, 
		areaConfigurationTop, 
		L["SAVE"],
		EMA.SettingsUpdateClick
	)		
	areaConfigurationTop = areaConfigurationTop - buttonHeight	
	EMA.settingsControl.areaEditBoxTag:SetDisabled( true )
	EMA.settingsControl.areaEditBoxTag:SetText( "" )
	EMA.settingsControl.areaEditBoxName:SetDisabled( true )
	EMA.settingsControl.areaEditBoxName:SetText( "" )
	EMA.settingsControl.areaEditBoxPassword:SetDisabled( true )
	EMA.settingsControl.areaEditBoxPassword:SetText( "" )	
	EMA.settingsControl.areaOnScreenDropdown:SetDisabled( true )
	EMA.settingsControl.areaOnScreenDropdown:SetText( "" )
	EMA.settingsControl.areaSoundDropdown:SetDisabled( true )
	EMA.settingsControl.areaSoundDropdown:SetText( "" )	
	local bottomOfSection = areaConfigurationTop
	return bottomOfSection	
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
	-- Create the area list controls.
	local bottomOfAreaList = SettingsCreateAreaList()
	-- Create the area type configuration controls.
	local bottomOfAreaTypes = SettingsCreateAreaTypes( bottomOfAreaList )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfAreaTypes )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )	
end

-------------------------------------------------------------------------------------------------------------
-- Settings Callbacks.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsAreaListScrollRefresh()
	FauxScrollFrame_Update(
		EMA.settingsControl.areaList.listScrollFrame, 
		GetAreaListMaxPosition(),
		EMA.settingsControl.areaList.rowsToDisplay, 
		EMA.settingsControl.areaList.rowHeight
	)
	
	EMA.settingsControl.areaListOffset = FauxScrollFrame_GetOffset( EMA.settingsControl.areaList.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.areaList.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.areaList.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.areaList.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.areaList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.areaList.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.areaList.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.areaListOffset
		if dataRowNumber <= GetAreaListMaxPosition() then
			-- Put area name and type into columns.
			local areaInformation = GetAreaAtPosition( dataRowNumber )
			local areaName = areaInformation.name
			local areaType = EMA.areaTypes[areaInformation.type].name
			EMA.settingsControl.areaList.rows[iterateDisplayRows].columns[1].textString:SetText( areaName )
			EMA.settingsControl.areaList.rows[iterateDisplayRows].columns[2].textString:SetText( areaType )
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.areaListHighlightRow then
				EMA.settingsControl.areaList.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:UpdateAreaTypeControls( event, areaTypeIdentifier )		
	EMA.currentlySelectedAreaTypeIdentifier = areaTypeIdentifier
	local areaType = EMA.areaTypes[areaTypeIdentifier]
	-- Disable all controls.
	EMA.settingsControl.areaEditBoxTag:SetDisabled( true )
	EMA.settingsControl.areaEditBoxName:SetDisabled( true )
	EMA.settingsControl.areaEditBoxPassword:SetDisabled( true )
	EMA.settingsControl.areaOnScreenDropdown:SetDisabled( true )
	EMA.settingsControl.areaSoundDropdown:SetDisabled( true )
	-- Enable controls if they are used.
	if areaType.usesTag == true then
		EMA.settingsControl.areaEditBoxTag:SetDisabled( false )
	end
	if areaType.usesChannel == true then
		EMA.settingsControl.areaEditBoxName:SetDisabled( false )
		EMA.settingsControl.areaEditBoxPassword:SetDisabled( false )
	end
	if areaType.usesChatWindowName == true then
		EMA.settingsControl.areaEditBoxName:SetDisabled( false )
	end
	if areaType.usesScreen == true then
		-- Nothing here anymore!
		
	end
	if areaType.usesSound == true then
		EMA.settingsControl.areaSoundDropdown:SetDisabled( false )
	end
end

local function UpdateAreaTypeInformation()		
	-- Update the area type controls to reflect the information for this selection.
	local areaInformation = GetAreaAtPosition( EMA.settingsControl.areaListHighlightRow )
	local areaType = EMA.areaTypes[areaInformation.type]
	-- Set the area type control.
	EMA.settingsControl.areaTypeDropdown:SetValue( areaInformation.type )
	EMA:UpdateAreaTypeControls( "OnValueChanged", areaInformation.type )
	-- Clear controls.
	EMA.settingsControl.areaEditBoxTag:SetText( "" )
	EMA.settingsControl.areaEditBoxName:SetText( "" )
	EMA.settingsControl.areaEditBoxPassword:SetText( "" )
	EMA.settingsControl.areaOnScreenDropdown:SetText( "" )
	-- Populate controls if they are used.
	if areaType.usesTag == true then
		EMA.settingsControl.areaEditBoxTag:SetText( areaInformation.tag )
		EMA.currentEditBoxTagText = areaInformation.tag
	end
	if areaType.usesChannel == true then
		EMA.settingsControl.areaEditBoxName:SetText( areaInformation.channelName )
		EMA.currentEditBoxNameText = areaInformation.channelName
		EMA.settingsControl.areaEditBoxPassword:SetText( areaInformation.channelPassword )
		EMA.currentEditBoxPasswordText = areaInformation.channelPassword
	end
	if areaType.usesChatWindowName == true then
		EMA.settingsControl.areaEditBoxName:SetText( areaInformation.chatWindowName )
		EMA.currentEditBoxNameText = areaInformation.chatWindowName
	end
	if areaType.usesScreen == true then
		EMA.settingsControl.areaOnScreenDropdown:SetValue( areaInformation.areaOnScreenName )
		EMA:UpdateAreaOnScreenControls( "OnValueChanged", areaInformation.areaOnScreenName )
	end
	if areaType.usesSound == true then
		EMA.settingsControl.areaSoundDropdown:SetValue( areaInformation.soundToPlay )
	end
end

function EMA:SettingsAreaListRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.areaListOffset + rowNumber <= GetAreaListMaxPosition() then
		EMA.settingsControl.areaListHighlightRow = EMA.settingsControl.areaListOffset + rowNumber
		UpdateAreaTypeInformation()
		EMA:SettingsAreaListScrollRefresh()
	end
end

function EMA:EditBoxTagChanged( event, text )
	EMA.currentEditBoxTagText = text
end

function EMA:EditBoxNameChanged( event, text )
	EMA.currentEditBoxNameText = text
end

function EMA:EditBoxPasswordChanged( event, text )
	EMA.currentEditBoxPasswordText = text
end

local function SetAreaConfigurationIntoCurrentArea()
	-- Get information from table at position.
	local areaInformation = GetAreaAtPosition( EMA.settingsControl.areaListHighlightRow )
	-- Update the area type for this area.
	areaInformation.type = EMA.currentlySelectedAreaTypeIdentifier
	-- Get the area information.
	local areaType = EMA.areaTypes[areaInformation.type]
	-- Update the area information according to the area type.
	if areaType.usesTag == true then
		areaInformation.tag = EMA.currentEditBoxTagText
	end
	if areaType.usesChannel == true then
		areaInformation.channelName = EMA.currentEditBoxNameText
		areaInformation.channelPassword = EMA.currentEditBoxPasswordText
	end
	if areaType.usesChatWindowName == true then
		areaInformation.chatWindowName = EMA.currentEditBoxNameText
	end
	if areaType.usesScreen == true then
		areaInformation.areaOnScreenName = EMA.currentlySelectedAreaOnScreenName
	end
	if areaType.usesSound == true then
		areaInformation.soundToPlay = EMA.currentlySelectedAreaSoundToPlay
	end
	-- Put information back into table at position.
	SetAreaAtPosition( EMA.settingsControl.areaListHighlightRow, areaInformation )
	-- Refresh the settings.
	EMA:SettingsRefresh()
end

function EMA:UpdateAreaOnScreenControls( event, areaOnScreenName )		
	EMA.currentlySelectedAreaOnScreenName = areaOnScreenName
end

function EMA:UpdateSoundControls( event, value )
	EMA.settingsControl.areaSoundDropdown:SetValue( value )
	EMA.currentlySelectedAreaSoundToPlay = value
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
	--EMA:SendMessage( EMA.MESSAGE_MESSAGE_AREAS_CHANGED )
end

function EMA:SettingsUpdateClick( event )
	SetAreaConfigurationIntoCurrentArea()
end

function EMA:SettingsAddClick( event )
	StaticPopup_Show( "EMAMESSAGE_ASK_AREA_NAME" )
end

function EMA:SettingsRemoveClick( event )
	local area = GetAreaAtPosition( EMA.settingsControl.areaListHighlightRow )
	StaticPopup_Show( "EMAMESSAGE_CONFIRM_REMOVE_AREA", area.name )
end

-------------------------------------------------------------------------------------------------------------
-- Popup Dialogs.
-------------------------------------------------------------------------------------------------------------

-- Initialize Popup Dialogs.
local function InitializePopupDialogs()
   StaticPopupDialogs["EMAMESSAGE_ASK_AREA_NAME"] = {
        text = L["STATICPOPUP_ADD_MSG"],
        button1 = ACCEPT,
        button2 = CANCEL,
        hasEditBox = 1,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
		OnShow = function( self )
			self.editBox:SetText("")
            self.button1:Disable()
            self.editBox:SetFocus()
        end,		
        OnAccept = function( self )
			EMA:AddAreaGUI( self.editBox:GetText() )
		end,
        EditBoxOnTextChanged = function( self )
            if not self:GetText() or self:GetText():trim() == "" then
				self:GetParent().button1:Disable()
            else
                self:GetParent().button1:Enable()
            end
        end,		
		EditBoxOnEnterPressed = function( self )
            if self:GetParent().button1:IsEnabled() then
				EMA:AddAreaGUI( self:GetText() )
            end
            self:GetParent():Hide()
        end,		
    }
   StaticPopupDialogs["EMAMESSAGE_CONFIRM_REMOVE_AREA"] = {
        text = L["REMOVE_MESSAGE_AREA"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function( self )
			EMA:RemoveAreaGUI()
		end,
    }        
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	EMA.currentlySelectedAreaTypeIdentifier = EMA.AREA_TYPE_DEFAULT_CHAT
	EMA.currentEditBoxTagText = ""
	EMA.currentEditBoxNameText = ""
	EMA.currentEditBoxPasswordText = ""	
	EMA.currentlySelectedAreaOnScreenName = ""
	EMA.currentlySelectedAreaSoundToPlay = ""
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	-- Click the area list first row, column to set the child controls.
	EMA:SettingsAreaListRowClick( 1, 1 )
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	-- Kickstart the settings team list scroll frame.
	EMA:SettingsAreaListScrollRefresh()
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-------------------------------------------------------------------------------------------------------------
-- Send messages.
-------------------------------------------------------------------------------------------------------------

local function DefaultMessageArea()
	return L["DEFAULT_MESSAGE"]
end

local function DefaultWarningArea()
	return L["DEFAULT_WARNING"]
end

local function DisplayMessageDefaultChat( sender, message, suppressSender )
	local senderName = Ambiguate(sender, "none")
	local chatTimestamp = ""
	if (CHAT_TIMESTAMP_FORMAT) then
		chatTimestamp = BetterDate( CHAT_TIMESTAMP_FORMAT, time() )
	end
	local completeMessage = chatTimestamp
	if suppressSender == false then
		completeMessage = completeMessage.."|Hplayer:"..sender.."|h["..senderName.."]|h"..L[": "]
	end
	completeMessage = completeMessage..message
	DEFAULT_CHAT_FRAME:AddMessage( completeMessage )
end

local function DisplayMessageChatWhisper( sender, message, suppressSender )
	-- The whisper comes across the wire and you whisper yourself...
	-- If we clean up EMA-msg then we can remove this maybe again Eboyn TODO::::
	EMAPrivate.Communications.SendChatMessage( message, "WHISPER", sender, EMAPrivate.Communications.COMMUNICATION_PRIORITY_ALERT )
end

local function DisplayMessageChat( sender, message, chatDestination, suppressSender )
	local canSend = false
	if (chatDestination == "GUILD" or chatDestination == "OFFICER") then
		if IsInGuild() then
			canSend = true
		else
			EMA:Print( L["ERROR: Not in a Guild"] )
		end
	end
	if chatDestination == "PARTY" then
		if GetNumSubgroupMembers() > 0 then	
			canSend = true
		else
			EMA:Print( L["ERROR: Not in a Party"] )
		end
	end
	if chatDestination == "RAID" then
		if GetNumGroupMembers() > 0 and IsInRaid() then	
			canSend = true
		else
			EMA:Print( L["ERROR: Not in a Raid"] )
		end
	end
	if canSend == true then
		-- If we clean up EMA-msg then we can remove this maybe again Eboyn TODO::::
		EMAPrivate.Communications.SendChatMessage( message, chatDestination, nil, EMAPrivate.Communications.COMMUNICATION_PRIORITY_ALERT )
	else
		EMA:Print( message )	
	end	
end

local function DisplayMessageRaidWarning( sender, message, suppressSender )
	local completeMessage = ""
	local senderName = Ambiguate(sender, "none")
	if suppressSender == false then
		completeMessage = completeMessage..senderName..L[": "]
	end
	completeMessage = completeMessage..message
	RaidNotice_AddMessage( RaidWarningFrame, completeMessage, ChatTypeInfo["RAID_WARNING"] )
end
		

local function PlayMessageSound( soundToPlay )	
	--EMA:Print("test", Media:Fetch( 'sound', soundToPlay  ) )
	PlaySoundFile( Media:Fetch( 'sound', soundToPlay ), "Ambience" )
end

local function ProcessReceivedMessage( sender, areaName, message, suppressSender, ... )
	-- Get the area requested.
	local area = GetAreaByName( areaName )
	if area == nil then
		EMA:Print( L["ERROR: Could not find area: A"]( areaName ) )
		EMA:Print( message )
		return
	end
	-- What sort of area is this?
	local areaType = EMA.areaTypes[area.type]
	-- Does this area type use tags?  If so, check the tag.
	if areaType.usesTag == true then
		if EMAPrivate.Tag.DoesCharacterHaveTag( EMA.characterName, area.tag ) == false then
			-- Tag not on this character, bail.
			return
		end
	end
	-- Display the message.
	if area.type == EMA.AREA_TYPE_DEFAULT_CHAT then
		DisplayMessageDefaultChat( sender, message, suppressSender )
	end
	if area.type == EMA.AREA_TYPE_SPECIFIC_CHAT then
		-- TODO
	end
	if area.type == EMA.AREA_TYPE_WHISPER then
		DisplayMessageChatWhisper( sender, message, suppressSender )
	end
	if area.type == EMA.AREA_TYPE_PARTY then
		DisplayMessageChat( sender, message, "PARTY", suppressSender )
	end
	if area.type == EMA.AREA_TYPE_GUILD then
		DisplayMessageChat( sender, message, "GUILD", suppressSender )
	end
	if area.type == EMA.AREA_TYPE_GUILD_OFFICER then
		DisplayMessageChat( sender, message, "OFFICER", suppressSender )
	end
	if area.type == EMA.AREA_TYPE_RAID then
		DisplayMessageChat( sender, message, "RAID", suppressSender )
	end
	if area.type == EMA.AREA_TYPE_RAID_WARNING then
		DisplayMessageRaidWarning( sender, message, suppressSender )
	end
	if area.type == EMA.AREA_TYPE_CHANNEL then
		-- TODO
	end
--[[
	if area.type == EMA.AREA_TYPE_PARROT then
		DisplayMessageParrot( sender, message, area.areaOnScreenName, suppressSender )
	end
	if area.type == EMA.AREA_TYPE_MSBT then
		DisplayMessageMikSBT( sender, message, area.areaOnScreenName, suppressSender )
	end
]]	
	if area.type == EMA.AREA_TYPE_MUTE then
		-- Do nothing! Mute means eat the message.
	end
	if areaType.usesSound == true and area.soundToPlay ~= "None" then
		--EMA:Print("test", area.soundToPlay )
		PlayMessageSound(area.soundToPlay )
	end	
end

local function SendMessage( areaName, message, suppressSender, ... )
	-- Get the area requested.
	local area = GetAreaByName( areaName )
	if area == nil then
		EMA:Print( L["ERR_COULD_NOT_FIND_AREA"]( areaName ) )
		
		EMA:Print( message )
		return
	end
	-- What sort of area is this?
	local areaType = EMA.areaTypes[area.type]
	-- Does this area type use tags?  If so, find out if the message needs to be sent over the wire.
	local sendToJustMe = false
	if areaType.usesTag == true then
		--if area.tag == EMAPrivate.Tag.JustMeTag() then
		--	sendToJustMe = true
		--end
		if area.tag == EMAPrivate.Tag.MasterTag() and EMAPrivate.Team.IsCharacterTheMaster( EMA.characterName ) == true then
			sendToJustMe = true
		end
	end
	-- Send over the wire or process locally?
	if sendToJustMe == true or areaType.mustBeWired == false then
		ProcessReceivedMessage( EMA.characterName, areaName, message, suppressSender, ... )
	else
		EMA:EMASendCommandToTeam( EMA.COMMAND_MESSAGE, areaName, message, suppressSender, ... )
	end
end

-------------------------------------------------------------------------------------------------------------
-- Commands.
-------------------------------------------------------------------------------------------------------------

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if commandName == EMA.COMMAND_MESSAGE then		
		ProcessReceivedMessage( characterName, ... )
	end
end

-- Functions available from EMA Message for other EMA internal objects.
EMAPrivate.Message.SendMessage = SendMessage

-- Functions available for other addons.
EMAApi.MessageAreaList = MessageAreaList
EMAApi.DefaultMessageArea = DefaultMessageArea
EMAApi.DefaultWarningArea = DefaultWarningArea
EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED = EMA.MESSAGE_MESSAGE_AREAS_CHANGED
