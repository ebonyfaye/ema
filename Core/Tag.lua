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
	"Tag",
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0"
)

-- Load libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local AceGUI = LibStub( "AceGUI-3.0" )

-- Constants required by EMAModule and Locale for this module.
EMA.moduleName = "Tag"
EMA.settingsDatabaseName = "TagProfileDB"
EMA.chatCommand = "ema-group"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["TEAM"]
EMA.moduleDisplayName = L["GROUP_LIST"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\GroupIcon.tga"
-- order
EMA.moduleOrder = 10

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
        tagList = {},
		groupList = {}
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
				usage = "/ema-group confg",
				get = false,
				set = "",				
			},
			add = {
				type = "input",
				name = L["ADD"],
				desc = L["ADD_TAG_HELP"],
				usage = "/ema-group add <NewGroupName>",
				get = false,
				set = "AddTagCommand",
			},					
			remove = {
				type = "input",
				name = L["REMOVE"],
				desc = L["REMMOVE_TAG_HELP"],
				usage = "/ema-group remove <NewGroupName>",
				get = false,
				set = "RemoveTagCommand",
			},						
			addtogroup = {
				type = "input",
				name = L["ADD_TO_GROUP"],
				desc = L["ADD_TO_GROUP_HELP"],
				usage = "/ema-group addtogroup <characterName> <GroupName>",
				get = false,
				set = "AddToGroupCommand",
			},					
			removefromgroup = {
				type = "input",
				name = L["REMOVE_FROM_GROUP"],
				desc = L["REMOVE_FROM_GROUP_HELP"],
				usage = "/ema-group removefromgroup <characterName> <NewGroupName>",
				get = false,
				set = "RemovefromGroupCommand",
			},				
			push = {
				type = "input",
				name = L["PUSH_ALL_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-group push",
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

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------
EMA.GROUP_LIST_CHANGED = "EMAMessageGroupListChanged"
-------------------------------------------------------------------------------------------------------------
-- Constants used by module.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreateGroupList()
	-- Position and size constants.
	local top = EMAHelperSettings:TopOfSettings()
	local left = EMAHelperSettings:LeftOfSettings()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local iconSize = 30
	local iconHight = iconSize + 10
	local lefticon =  left + iconSize
	local teamListWidth = headingWidth - 90
	local topOfList = top - headingHeight
	-- Team list internal variables (do not change).
	EMA.settingsControl.teamListHighlightRow = 1
	EMA.settingsControl.teamListOffset = 1
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	topOfList = topOfList - headingHeight
	--Main Heading	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["GROUP_LIST"], top, false )
	-- Create a team list frame.
	
	local list = {}
	list.listFrameName = "EMATagSettingsGroupListFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = topOfList
	list.listLeft = lefticon
	list.listWidth = teamListWidth
	list.rowHeight = 20
	list.rowsToDisplay = 15
	list.columnsToDisplay = 1
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 100
	list.columnInformation[1].alignment = "LEFT"
	list.scrollRefreshCallback = EMA.SettingsGroupListScrollRefresh
	list.rowClickCallback = EMA.SettingsGroupListRowClick
	EMA.settingsControl.groupList = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.groupList )
	-- Position and size constants (once list height is known).
	local bottomOfList = topOfList - list.listHeight - verticalSpacing

	EMA.settingsControl.tagListButtonAdd = EMAHelperSettings:Icon( 
		EMA.settingsControl, 
		iconSize,
		iconSize,
		"Interface\\Addons\\EMA\\Media\\CharAddParty.tga", --icon Image
		left - iconSize - 11, 
		topOfList - verticalSpacing ,
		L[""], 
		EMA.SettingsAddClick,
		L["BUTTON_TAG_ADD_HELP"]
	)		
	EMA.settingsControl.groupListButtonRemove = EMAHelperSettings:Icon( 
		EMA.settingsControl, 
		iconSize,
		iconSize,
		"Interface\\Addons\\EMA\\Media\\CharRemoveParty.tga", --icon Image
		left - iconSize - 11, 
		topOfList - verticalSpacing - iconHight,
		L[""], 
		EMA.SettingsRemoveClick,
		L["BUTTON_TAG_REMOVE_HELP"]
	)
	local bottomOfSection = bottomOfList -  buttonHeight - verticalSpacing

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
	-- Create the team list controls.
	local bottomOfGroupList = SettingsCreateGroupList()
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
	-- Update the settings team list.
	EMA:SettingsGroupListScrollRefresh()
	--EMA:SettingsTagListScrollRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	characterName = EMAUtilities:AddRealmToNameIfMissing( characterName )
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.tagList = EMAUtilities:CopyTable( settings.tagList )
		EMA.db.groupList = EMAUtilities:CopyTable( settings.groupList )
		EMA:InitializeAllTagsList()
		-- New team and tag lists coming up, highlight first item in each list.
		EMA.settingsControl.groupListHighlightRow = 1
		-- Refresh the settings.
		EMA:SettingsRefresh()
		EMA:SettingsGroupListRowClick( 1, 1 )
		EMA:SendMessage( EMA.GROUP_LIST_CHANGED )
		EMAApi.refreshDropDownList()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

-------------------------------------------------------------------------------------------------------------
-- Popup Dialogs.
-------------------------------------------------------------------------------------------------------------

-- Initialize Popup Dialogs.
local function InitializePopupDialogs()
   -- Ask the name of the tag to add as to the character.
   StaticPopupDialogs["EMATAG_ASK_TAG_NAME"] = {
        text = L["NEW_GROUP_NAME"],
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
			EMA:AddTagGUI( self.editBox:GetText() )
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
				EMA:AddTagGUI( self:GetText() )
            end
            self:GetParent():Hide()
        end,				
    }
   -- Confirm removing characters from member list.
   StaticPopupDialogs["EMATAG_CONFIRM_REMOVE_TAG"] = {
        text = L["REMOVE_FROM_TAG_LIST"],
		button1 = ACCEPT,
        button2 = CANCEL,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function( self )
			EMA:RemoveTagGUI()
		end,
    }        
end

-------------------------------------------------------------------------------------------------------------
-- Group Management.
-------------------------------------------------------------------------------------------------------------

local function AllTag()
	return L["ALL_LOWER"]
end

local function MasterTag()
	return L["MASTER_LOWER"]
end

local function MinionTag()
	return L["MINION_LOWER"]
end

local function GroupList()
	return EMA.db.groupList
end	

-- Does the Group list have this tag?
local function DoesGroupExist( group )
	local tag = EMAUtilities:Lowercase(group)
	local haveTag = false
	for index, findTag in ipairs( EMA.db.groupList ) do
		--EMA:Print("find", findTag, index )
		if findTag == tag then
			haveTag = true
			break
		end
	end
	return haveTag
end

local function AddGroup( group )
	if group ~= nil then
		if DoesGroupExist( group ) == false then
			table.insert( EMA.db.groupList, group )
			table.sort( EMA.db.groupList )
			EMAApi.refreshDropDownList()
			EMA:SendMessage( EMA.GROUP_LIST_CHANGED )
		end
	end	
end

-- If Calling to Remove a group we should Use EMAApi.RemoveGroup( Groupname ) or RemoveGroup then using This
local function RemoveFromGroupList( tag )
	if DoesGroupExist( tag ) == true then
		for index, group in pairs( EMA.db.groupList ) do
			if group == tag then
			table.remove( EMA.db.groupList, index )
			table.sort( EMA.db.groupList )
			end	
		end
	EMA:SettingsGroupListScrollRefresh()
	EMAApi.refreshDropDownList()
	EMA:SendMessage( EMA.GROUP_LIST_CHANGED )
	end	
end

local function RemoveGroup( tag )
	--  We don't Want to Tag to be part of the character Groups as it has been removed!
	for characterName, tagList in pairs( EMA.db.tagList ) do
		for index, tagIterated in ipairs( tagList ) do
			if tagIterated == tag then
				--EMA:Print("Remove tag:", tag, "from character:", characterName )
				EMAApi.RemoveGroupFromCharacter( characterName, tag )	
			end
		end
	end	
	RemoveFromGroupList( tag )
	EMA:SettingsGroupListScrollRefresh()
	EMAPrivate.Team.RefreshGroupList()
	EMA:SettingsGroupListRowClick( EMA.settingsControl.groupListHighlightRow - 1, 1 )
	EMA:SendMessage( EMA.GROUP_LIST_CHANGED )
end

-- We Do Not Want To Remove "System" Groups!
local function IsASystemGroup( tag )
	if tag == MasterTag() or tag == MinionTag() or tag == AllTag() then
		return true
	end
	--[[
	for id, apiClass in pairs( CLASS_SORT_ORDER ) do
		if tag == EMAUtilities:Lowercase(apiClass) then
			return true
		end	
	end
	]]
	return false
end

local function GetGroupListMaximumOrder()
	local largestPosition = 0 
	for groupId, tag in pairs( EMA.db.groupList ) do
		if groupId > largestPosition then
			largestPosition = groupId
		end	
	end
	return largestPosition
end 

local function GetGroupAtPosition( position )
	--EMA:Print("test", position )
	groupAtPosition = nil
		for groupId, groupName in pairs( EMA.db.groupList ) do
			if groupId == position then
				--EMA:Print("cptest",characterName, groupId, groupName)
				groupAtPosition = groupName
			end
		end
	return groupAtPosition	
end	

-------------------------------------------------------------------------------------------------------------
-- Team Group Management.
-------------------------------------------------------------------------------------------------------------

local function TeamGroupList()
	return EMA.db.groupList
end

local function IsCharacterInGroup( characterName, group )
	local tag = EMAUtilities:Lowercase(group)
	local DoesCharacterHaveTag = false
	for name, tagList in pairs( EMA.db.tagList ) do
		if characterName == name then
			for index, tagIterated in pairs( tagList ) do
				if tag == tagIterated then
					DoesCharacterHaveTag = true
				end
			end
		end	
	end	
	return DoesCharacterHaveTag
end

local function GetGroupListForCharacter( characterName )
	--EMA:Print("getList", characterName)
	characterName = EMAUtilities:AddRealmToNameIfMissing( characterName )
	if EMA.db.tagList[characterName] ~= nil then
		return EMA.db.tagList[characterName]
	end	
end

local function CharacterMaxGroups()
	--return EMA.characterTagList
	local maxOrder = 0
	for characterName, tagList in pairs( EMA.db.tagList ) do
		for index, tag in pairs( tagList ) do
			if index >= maxOrder then
				maxOrder = index
			end
		end	
	end
	return maxOrder
end	

local function DisplayGroupsForCharacter( characterName )
	EMA.characterTagList = GetGroupListForCharacter( characterName )
	table.sort( EMA.characterTagList )
	EMA:SettingsGroupListScrollRefresh()
end

local function CharacterAlreadyInGroup( characterName, tag )
	local canAdd = false
	return canAdd
end	

local function AddCharacterToGroup( characterName, tag )
	if characterName == nil or tag == nil then
		return
	end	
	-- We Add The GroupName To The characterName in the list!
	for name, tagList in pairs( EMA.db.tagList ) do
		if characterName == name then
			local allReadyInGroup = IsCharacterInGroup( characterName, tag )
			--EMA:Print("hereWeAddTOTagList", characterName, tag, allReadyInGroup)
			if allReadyInGroup == false then
				table.insert(  tagList, tag )
				table.sort ( tagList )
				EMAPrivate.Team.RefreshGroupList()
			end	
		end
	end
end	

local function RemoveGroupFromCharacter( characterName, tag )
	if characterName == nil or tag == nil then
		return
	end	
	-- We Remove a GroupName From the characterName in the list!
	for name, tagList in pairs( EMA.db.tagList ) do
		if characterName == name then
			for index, tagIterated in pairs( tagList ) do
				if tag == tagIterated then
					--EMA:Print("timetoRemovetag")
					table.remove( tagList, index )
					table.sort( tagList )
				end	
			end
		end
	end
end	

-- This should abeble to be removed now.
-- this can be used to add a character that you already know the name of the table. [characterTable] [GroupName/Tag]
local function AddTag( tagList, tag )
	table.insert( tagList, tag )	
	AddGroup( tag )
	EMA:SettingsGroupListScrollRefresh()
	EMAPrivate.Team.RefreshGroupList()
end

--TODO ADD CLASS TO LIST
local function CheckSystemTagsAreCorrect()
	for characterName, characterPosition in EMAPrivate.Team.TeamList() do
		--EMA:Print("CHeckTags", characterName)
		local characterTagList = GetGroupListForCharacter( characterName )
		-- Do we have a tagList for this character? if not make one!
		if characterTagList == nil then
			EMA.db.tagList[characterName] = {}
		end	
		-- Make sure all characters have the "all" tag.
		if IsCharacterInGroup ( characterName, AllTag() ) == false then
			AddCharacterToGroup( characterName, AllTag() )
		end
		-- Find Class and add If Known.
		-- TODO ADD HERE
		
		
		-- Master or minion?
		if EMAPrivate.Team.IsCharacterTheMaster( characterName ) == true then
			--EMA:Print("Master", characterName, characterTagList)
			if IsCharacterInGroup ( characterName, MasterTag() ) == false then	
				AddCharacterToGroup( characterName, MasterTag() )
			end
			if IsCharacterInGroup ( characterName, MinionTag() ) == true then	
				RemoveGroupFromCharacter( characterName, MinionTag() )
			end
		else
			-- Make sure minions have the minion tag and not the master tag.
			if IsCharacterInGroup ( characterName, MasterTag() ) == true then	
				RemoveGroupFromCharacter( characterName, MasterTag() )
			end
			if IsCharacterInGroup ( characterName, MinionTag() ) == false then
				AddCharacterToGroup( characterName, MinionTag() )
			end
		end
	end
end

-- Initialise the The Group list.
function EMA:InitializeAllTagsList()
	-- Add system tags to the list.
	AddGroup( AllTag() )
	AddGroup( MasterTag() )
	AddGroup( MinionTag() )
	for id, class in pairs( CLASS_SORT_ORDER ) do
		AddGroup( EMAUtilities:Lowercase(class) )
	end
end

-------------------------------------------------------------------------------------------------------------
-- GUI & Command Lines & Other Addons Acess.
-------------------------------------------------------------------------------------------------------------

function EMA:AddTagGUI( group )
	local tag = EMAUtilities:Lowercase( group )
	-- Cannot add a system tag.
	if IsASystemGroup( tag ) == false then
		-- Cannot add a tag that already exists.
		if DoesGroupExist( tag ) == false then
			-- Add tag, resort and display.
			AddGroup( tag ) 
			EMA:SettingsGroupListScrollRefresh()	
		end
	end
end

function EMA:RemoveTagGUI()
	local tag = GetGroupAtPosition( EMA.settingsControl.groupListHighlightRow )
	-- Cannot remove a system tag.
	if IsASystemGroup( tag ) == false then
		RemoveGroup( tag )	
	end
end

-- Add Group to group list from the command line.
function EMA:AddTagCommand( info, parameters )
	local tag = EMAUtilities:Lowercase( parameters )
	--local characterName, tag = strsplit( " ", inputText )
	if IsASystemGroup( tag ) == false then
		-- Cannot add a tag that already exists.
		if DoesGroupExist( tag ) == false then
			AddGroup( tag ) 
			EMA:SettingsGroupListScrollRefresh()	
		end
	end
end

-- Add Group to group list from the command line.
function EMA:AddToGroupCommand( info, parameters )
	--local inputText = EMAUtilities:Lowercase( parameters )
	local characterName, tag = strsplit( " ", parameters )
	if characterName ~= nil or tag ~= nil then
		local group = EMAUtilities:Lowercase( tag )
		if DoesGroupExist( group ) == true then
			local isInTeam, fullCharacterName = EMAPrivate.Team.IsCharacterInTeam( characterName )
			--EMA:Print("isInTeam", isInTeam, fullCharacterName, group )
			AddCharacterToGroup( fullCharacterName, group )
		end	
	else
	EMA:Print("[PH]"..L["WRONG_TEXT_INPUT_GROUP"] )
	end
end


-- Remove tag from character from the command line.
function EMA:RemoveTagCommand( info, parameters )
	local inputText = EMAUtilities:Lowercase( parameters )
	local characterName, tag = strsplit( " ", inputText )
		

end

function EMA:OnMasterChanged( message, characterName )
	CheckSystemTagsAreCorrect()
	EMA:SettingsRefresh()
end

function EMA:OnCharacterAdded( message, characterName )
	CheckSystemTagsAreCorrect()
	EMA:SettingsRefresh()
end

function EMA:OnCharacterRemoved( message, characterName )
	EMA.db.tagList[characterName] = nil
	EMA:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- Settings Callbacks.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsGroupListScrollRefresh()
	FauxScrollFrame_Update(
		EMA.settingsControl.groupList.listScrollFrame, 
		GetGroupListMaximumOrder(),
		EMA.settingsControl.groupList.rowsToDisplay, 
		EMA.settingsControl.groupList.rowHeight
	)
	EMA.settingsControl.groupListOffset = FauxScrollFrame_GetOffset( EMA.settingsControl.groupList.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.groupList.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.groupList.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.groupList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.groupList.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.groupListOffset
		if dataRowNumber <= GetGroupListMaximumOrder() then
			-- Put character name into columns.
			local group = GetGroupAtPosition( dataRowNumber )
			local groupName = EMAUtilities:Capitalise( group )
			EMA.settingsControl.groupList.rows[iterateDisplayRows].columns[1].textString:SetText( groupName )
			-- System tags are Yellow.
			if IsASystemGroup( group ) == true then
				EMA.settingsControl.groupList.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 0.96, 0.41, 1.0 )
			end
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.groupListHighlightRow then
				EMA.settingsControl.groupList.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingsGroupListRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.groupListOffset + rowNumber <= GetGroupListMaximumOrder() then
		EMA.settingsControl.groupListHighlightRow = EMA.settingsControl.groupListOffset + rowNumber
		EMA:SettingsGroupListScrollRefresh()
	end
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsAddClick( event )
	StaticPopup_Show( "EMATAG_ASK_TAG_NAME" )
end

function EMA:SettingsRemoveClick( event )
	local group = GetGroupAtPosition( EMA.settingsControl.groupListHighlightRow )
	StaticPopup_Show( "EMATAG_CONFIRM_REMOVE_TAG", group )
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	-- Current character tag list. 
	EMA.characterTagList = {}
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()	
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	-- Initialise the all tags list.
	EMA:InitializeAllTagsList()
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	-- Make sure all the system tags are correct.
	CheckSystemTagsAreCorrect()
	EMA:RegisterMessage( EMAPrivate.Team.MESSAGE_TEAM_MASTER_CHANGED, "OnMasterChanged" )
	EMA:RegisterMessage( EMAPrivate.Team.MESSAGE_TEAM_CHARACTER_ADDED, "OnCharacterAdded" )
	EMA:RegisterMessage( EMAPrivate.Team.MESSAGE_TEAM_CHARACTER_REMOVED, "OnCharacterRemoved" )
	-- Kickstart the settings team and tag list scroll frame.
	EMA:SettingsGroupListScrollRefresh()
	-- Click the first row in the team list table to populate the tag list table.
	EMA:SettingsGroupListRowClick( 1, 1 )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end
	
-------------------------------------------------------------------------------------------------------------
-- Commands.
-------------------------------------------------------------------------------------------------------------

function EMA:EMAOnCommandReceived( sender, commandName, ... )
end

-- Functions available for other addons EMA-EE > v8 
-- Group List API
EMAApi.GroupList = GroupList
EMAApi.GROUP_LIST_CHANGED = EMA.GROUP_LIST_CHANGED
EMAApi.DoesGroupExist = DoesGroupExist
EMAApi.IsASystemGroup = IsASystemGroup
EMAApi.GetGroupListMaximumOrder = GetGroupListMaximumOrder
EMAApi.GetGroupAtPosition = GetGroupAtPosition
EMAApi.AddGroup = AddGroup
EMAApi.RemoveGroup = RemoveGroup

--Character Group API
EMAApi.TeamGroupList = TeamGroupList
EMAApi.IsCharacterInGroup = IsCharacterInGroup
EMAApi.GetGroupListForCharacter = GetGroupListForCharacter
EMAApi.CharacterMaxGroups = CharacterMaxGroups
EMAApi.AddCharacterToGroup = AddCharacterToGroup
EMAApi.RemoveGroupFromCharacter = RemoveGroupFromCharacter
--EMAApi.CharacterAlreadyInGroup = CharacterAlreadyInGroup
EMAApi.PushGroupSettings = EMA.SettingsPushSettingsClick

-- SystemTags API
EMAApi.AllGroup = AllTag
EMAApi.MasterGroup = MasterTag 
EMAApi.MinionGroup = MinionTag

-- Old Way, most modules need to be rewiren/udated to support the new API 
-- but for now we should keep this here incase we Mass Up Somewhere -- Ebony
EMAPrivate.Tag.MasterTag = MasterTag
EMAPrivate.Tag.MinionTag = MinionTag
EMAPrivate.Tag.AllTag = AllTag
EMAPrivate.Tag.DoesCharacterHaveTag = IsCharacterInGroup
EMAApi.DoesCharacterHaveTag = IsCharacterInGroup
EMAApi.AllTag = AllTag
