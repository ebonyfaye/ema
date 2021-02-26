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
	"Talk", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceHook-3.0"
)

-- Load libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Talk"
EMA.settingsDatabaseName = "TalkProfileDB"
EMA.chatCommand = "ema-talk"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["TOON"]
EMA.moduleDisplayName = L["TALK"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\ChatIcon.tga"
-- order
EMA.moduleOrder = 40


-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		forwardWhispers = true,
		doNotForwardRealIdWhispers = true,
--		forwardViaWhisper = false,
		fakeWhisper = true,
		fakeInjectSenderToReplyQueue = true,
		fakeInjectOriginatorToReplyQueue = false,
--		fakeWhisperCompact = false,
		whisperMessageArea = "ChatFrame1",
--		enableChatSnippets = false,
--		chatSnippets = {},
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
				usage = "/ema-talk config",
				get = false,
				set = "",				
			},
			push = {
				type = "input",
				name = L["PUSH_ALL_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-talk push",
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

EMA.COMMAND_MESSAGE = "EMATalkMessage"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Talk Management.
-------------------------------------------------------------------------------------------------------------

function EMA:UpdateChatFrameList()
	EMAUtilities:ClearTable( EMA.chatFrameList )
	for index = 1, NUM_CHAT_WINDOWS do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo( index )
		if (shown == 1) or (docked ~= nil) then
			EMA.chatFrameList["ChatFrame"..index] = name
		end
	end
	table.sort( EMA.chatFrameList )
end

function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()	
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()
	-- Set values.
	EMA.settingsControl.checkBoxForwardWhispers:SetValue( EMA.db.forwardWhispers )
	EMA.settingsControl.checkBoxDoNotForwardRealIdWhispers:SetValue( EMA.db.doNotForwardRealIdWhispers )
--	EMA.settingsControl.checkBoxForwardViaWhisper:SetValue( EMA.db.forwardViaWhisper )
	EMA.settingsControl.checkBoxFakeWhispers:SetValue( EMA.db.fakeWhisper )
	EMA.settingsControl.checkBoxFakeInjectSenderToReplyQueue:SetValue( EMA.db.fakeInjectSenderToReplyQueue )
	EMA.settingsControl.checkBoxFakeInjectOriginatorToReplyQueue:SetValue( EMA.db.fakeInjectOriginatorToReplyQueue )
--	EMA.settingsControl.checkBoxFakeWhisperCompact:SetValue( EMA.db.fakeWhisperCompact )
--	EMA.settingsControl.checkBoxEnableChatSnippets:SetValue( EMA.db.enableChatSnippets )
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.whisperMessageArea )
	-- Set state.
	EMA.settingsControl.checkBoxFakeInjectSenderToReplyQueue:SetDisabled( not EMA.db.fakeWhisper )
	EMA.settingsControl.checkBoxFakeInjectOriginatorToReplyQueue:SetDisabled( not EMA.db.fakeWhisper )
--	EMA.settingsControl.checkBoxFakeWhisperCompact:SetDisabled( not EMA.db.fakeWhisper )
	EMA.settingsControl.dropdownMessageArea:SetDisabled( not EMA.db.fakeWhisper )
	EMA.settingsControl.buttonRefreshChatList:SetDisabled( not EMA.db.fakeWhisper )
--	EMA.settingsControl.buttonRemove:SetDisabled( not EMA.db.enableChatSnippets )
--	EMA.settingsControl.buttonAdd:SetDisabled( not EMA.db.enableChatSnippets )
--	EMA.settingsControl.multiEditBoxSnippet:SetDisabled( not EMA.db.enableChatSnippets )
--	EMA:SettingsScrollRefresh()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.forwardWhispers = settings.forwardWhispers
		EMA.db.doNotForwardRealIdWhispers = settings.doNotForwardRealIdWhispers
		EMA.db.fakeWhisper = settings.fakeWhisper
--		EMA.db.enableChatSnippets = settings.enableChatSnippets
		EMA.db.whisperMessageArea = settings.whisperMessageArea
--		EMA.db.forwardViaWhisper = settings.forwardViaWhisper
--		EMA.db.fakeWhisperCompact = settings.fakeWhisperCompact
		EMA.db.fakeInjectSenderToReplyQueue = settings.fakeInjectSenderToReplyQueue
		EMA.db.fakeInjectOriginatorToReplyQueue = settings.fakeInjectOriginatorToReplyQueue
		EMA.db.chatSnippets = EMAUtilities:CopyTable( settings.chatSnippets )
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
		end
end

-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

local function SettingsCreateOptions( top )
	-- Position and size constants.
	local buttonControlWidth = 105
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local left2 = left + halfWidth + horizontalSpacing
	local indent = horizontalSpacing * 10
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, "", movingTop, false )
	movingTop = movingTop - headingHeight	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["TALK_OPTIONS"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxForwardWhispers = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["FORWARD_WHISPERS_MASTER_RELAY"],
		EMA.SettingsToggleForwardWhispers,
		L["FORWARD_WHISPERS_MASTER_RELAY_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight	
	EMA.settingsControl.checkBoxDoNotForwardRealIdWhispers = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["DO_NOT_BATTENET_WHISPERS"],
		EMA.SettingsToggleDoNotForwardRealIdWhispers,
		L["DO_NOT_BATTENET_WHISPERS_HELP"]
	)	
--[[
	movingTop = movingTop - checkBoxHeight	
	EMA.settingsControl.checkBoxForwardViaWhisper = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["FORWARD_USING_NORMAL_WHISPERS"],
		EMA.SettingsToggleForwardViaWhisper,
		L["FORWARD_USING_NORMAL_WHISPERS_HRLP"]
	)
]]	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxFakeWhispers = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["FORWARD_FAKE_WHISPERS"],
		EMA.SettingsToggleFakeWhispers,
		L["FORWARD_FAKE_WHISPERS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
		EMA.settingsControl.dropdownMessageArea = EMAHelperSettings:CreateDropdown( 
		EMA.settingsControl,
		(headingWidth - indent) / 2, 
		left + indent, 
		movingTop, 
		L["FAKE_WHISPERS_CHANNEL"] 
	)
	EMA.settingsControl.dropdownMessageArea:SetList( EMA.chatFrameList )
	EMA.settingsControl.dropdownMessageArea:SetCallback( "OnValueChanged", EMA.SettingsSetMessageArea )
	EMA.settingsControl.buttonRefreshChatList = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left + indent + (headingWidth - indent) / 2 + horizontalSpacing, 
		movingTop - buttonHeight + 4,
		L["UPDATE"],
		EMA.SettingsRefreshChatListClick
	)
	movingTop = movingTop - dropdownHeight - verticalSpacing
	EMA.settingsControl.checkBoxFakeInjectSenderToReplyQueue = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth - indent, 
		left + indent, 
		movingTop, 
		L["FORWARDER_REPLY_QUEUE"],
		EMA.SettingsToggleFakeInjectSenderToReplyQueue,
		L["FORWARDER_REPLY_QUEUE_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxFakeInjectOriginatorToReplyQueue = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth - indent, 
		left + indent, 
		movingTop, 
		L["ORIGINATOR_REPLY_QUEUE"],
		EMA.SettingsToggleFakeInjectOriginatorToReplyQueue,
		L["ORIGINATOR_REPLY_QUEUE_HELP"]
		)	
--[[
		movingTop = movingTop - checkBoxHeight	
	EMA.settingsControl.checkBoxFakeWhisperCompact = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth - indent, 
		left + indent, 
		movingTop, 
		L["MESSAGES_WITH_LINKS"],
		EMA.SettingsToggleFakeWhisperCompact,
		L["MESSAGES_WITH_LINKS_HELP"]
	)	
]]	
--[[
	movingTop = movingTop - checkBoxHeight	
	
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["CHAT_SNIPPETS"], movingTop, false )
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.checkBoxEnableChatSnippets = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["ENABLE_CHAT_SNIPPETS"],
		EMA.SettingsToggleChatSnippets,
		L["ENABLE_CHAT_SNIPPETS_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight		
	EMA.settingsControl.highlightRow = 1
	EMA.settingsControl.offset = 1
	local list = {}
	list.listFrameName = "EMATalkChatSnippetsSettingsFrame"
	list.parentFrame = EMA.settingsControl.widgetSettings.content
	list.listTop = movingTop
	list.listLeft = left
	list.listWidth = headingWidth
	list.rowHeight = 20
	list.rowsToDisplay = 5
	list.columnsToDisplay = 2
	list.columnInformation = {}
	list.columnInformation[1] = {}
	list.columnInformation[1].width = 25
	list.columnInformation[1].alignment = "LEFT"
	list.columnInformation[2] = {}
	list.columnInformation[2].width = 75
	list.columnInformation[2].alignment = "LEFT"	
	list.scrollRefreshCallback = EMA.SettingsScrollRefresh
	list.rowClickCallback = EMA.SettingsRowClick
	EMA.settingsControl.list = list
	EMAHelperSettings:CreateScrollList( EMA.settingsControl.list )
	movingTop = movingTop - list.listHeight - verticalSpacing
	EMA.settingsControl.buttonAdd = EMAHelperSettings:CreateButton(	
		EMA.settingsControl, 
		buttonControlWidth, 
		left, 
		movingTop, 
		L["ADD"],
		EMA.SettingsAddClick
	)
	EMA.settingsControl.buttonRemove = EMAHelperSettings:CreateButton(
		EMA.settingsControl, 
		buttonControlWidth, 
		left + buttonControlWidth + horizontalSpacing, 
		movingTop,
		L["REMOVE"],
		EMA.SettingsRemoveClick
	)
	movingTop = movingTop -	buttonHeight - verticalSpacing
	EMA.settingsControl.multiEditBoxSnippet = EMAHelperSettings:CreateMultiEditBox( 
		EMA.settingsControl,
		headingWidth,
		left,
		movingTop,
		L["SNIPPET_TEXT"],
		5
	)
	EMA.settingsControl.multiEditBoxSnippet:SetCallback( "OnEnterPressed", EMA.SettingsMultiEditBoxChangedSnippet )
	local multiEditBoxHeightSnippet = 110
	
	movingTop = movingTop - multiEditBoxHeightSnippet								
]]	
	return movingTop
end

local function SettingsCreate()
	EMA.settingsControl = {}
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.SettingsPushSettingsClick,
		EMA.moduleIcon,
		EMA.moduleOrder		
	)
	local bottomOfSettings = SettingsCreateOptions( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfSettings )	
end

-------------------------------------------------------------------------------------------------------------
-- Settings Callbacks.
-------------------------------------------------------------------------------------------------------------

--[[
function EMA:SettingsScrollRefresh()
	FauxScrollFrame_Update(
		EMA.settingsControl.list.listScrollFrame, 
		EMA:GetItemsMaxPosition(),
		EMA.settingsControl.list.rowsToDisplay, 
		EMA.settingsControl.list.rowHeight
	)
	EMA.settingsControl.offset = FauxScrollFrame_GetOffset( EMA.settingsControl.list.listScrollFrame )
	for iterateDisplayRows = 1, EMA.settingsControl.list.rowsToDisplay do
		-- Reset.
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetText( "" )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetText( "" )
		EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetTextColor( 1.0, 1.0, 1.0, 1.0 )				
		EMA.settingsControl.list.rows[iterateDisplayRows].highlight:SetColorTexture( 0.0, 0.0, 0.0, 0.0 )
		-- Get data.
		local dataRowNumber = iterateDisplayRows + EMA.settingsControl.offset
		if dataRowNumber <= EMA:GetItemsMaxPosition() then
			-- Put data information into columns.
			local itemInformation = EMA:GetItemAtPosition( dataRowNumber )
			EMA.settingsControl.list.rows[iterateDisplayRows].columns[1].textString:SetText( itemInformation.name )
			EMA.settingsControl.list.rows[iterateDisplayRows].columns[2].textString:SetText( itemInformation.snippet )
			-- Highlight the selected row.
			if dataRowNumber == EMA.settingsControl.highlightRow then
				EMA.settingsControl.list.rows[iterateDisplayRows].highlight:SetColorTexture( 1.0, 1.0, 0.0, 0.5 )
			end
		end
	end
end

function EMA:SettingsRowClick( rowNumber, columnNumber )		
	if EMA.settingsControl.offset + rowNumber <= EMA:GetItemsMaxPosition() then
		EMA.settingsControl.highlightRow = EMA.settingsControl.offset + rowNumber
		local itemInformation = EMA:GetItemAtPosition( EMA.settingsControl.highlightRow )
		if itemInformation ~= nil then
			EMA.settingsControl.multiEditBoxSnippet:SetText( itemInformation.snippet )
		end
		EMA:SettingsScrollRefresh()
	end
end
]]

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsSetMessageArea( event, value )
	EMA.db.whisperMessageArea = value
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleForwardWhispers( event, checked )
	EMA.db.forwardWhispers = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleDoNotForwardRealIdWhispers( event, checked )
	EMA.db.doNotForwardRealIdWhispers = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleFakeWhispers( event, checked )
	EMA.db.fakeWhisper = checked
	EMA:SettingsRefresh()
end

--[[
function EMA:SettingsToggleForwardViaWhisper( event, checked )
	EMA.db.forwardViaWhisper = checked
	EMA:SettingsRefresh()
end
]]

function EMA:SettingsToggleFakeInjectSenderToReplyQueue( event, checked )
	EMA.db.fakeInjectSenderToReplyQueue = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleFakeInjectOriginatorToReplyQueue( event, checked )
	EMA.db.fakeInjectOriginatorToReplyQueue = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsRefreshChatListClick( event )
	EMA:UPDATE_CHAT_WINDOWS()
end

--[[
function EMA:SettingsToggleFakeWhisperCompact( event, checked )
	EMA.db.fakeWhisperCompact = checked
	EMA:SettingsRefresh()
end
]]

--[[
function EMA:SettingsToggleChatSnippets( event, checked )
	EMA.db.enableChatSnippets = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsMultiEditBoxChangedSnippet( event, text )
	local itemInformation = EMA:GetItemAtPosition( EMA.settingsControl.highlightRow )
	if itemInformation ~= nil then
		itemInformation.snippet = text
	end
	EMA:SettingsRefresh()
end
]]


--[[
function EMA:SettingsAddClick( event )
	StaticPopup_Show( "EMATALK_ASK_SNIPPET" )
end

function EMA:SettingsRemoveClick( event )
	StaticPopup_Show( "EMATALK_CONFIRM_REMOVE_CHAT_SNIPPET" )
end
]]
-------------------------------------------------------------------------------------------------------------
-- Popup Dialogs.
-------------------------------------------------------------------------------------------------------------

-- Initialize Popup Dialogs.
local function InitializePopupDialogs()
	--[[
	StaticPopupDialogs["EMATALK_ASK_SNIPPET"] = {
        text = L["CHAT_SNIPPET_POPUP"],
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
			EMA:AddItem( self.editBox:GetText() )
		end,
		EditBoxOnTextChanged = function( self )
            if not self:GetText() or self:GetText():trim() == "" or self:GetText():find( "%W" ) ~= nil then
				self:GetParent().button1:Disable()
            else
                self:GetParent().button1:Enable()
            end
        end,
		EditBoxOnEnterPressed = function( self )
            if self:GetParent().button1:IsEnabled() then
				EMA:AddItem( self:GetText() )
            end
            self:GetParent():Hide()
        end,				
    }
	StaticPopupDialogs["EMATALK_CONFIRM_REMOVE_CHAT_SNIPPET"] = {
        text = L["REMOVE_CHAT_SNIPPET"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
        OnAccept = function( self )
			EMA:RemoveItem()
		end,
    } 
	]]
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	EMA.chatFrameList = {}
	EMA:UpdateChatFrameList()
	-- Remember the last sender to whisper this character.
	EMA.lastSender = nil
	EMA.lastSenderIsReal = false
	EMA.lastSenderRealID = nil
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Hook the SendChatMessage to translate any chat snippets.
	--EMA:RawHook( "SendChatMessage", true )	
	-- Initialise the popup dialogs.
	InitializePopupDialogs()
	-- Populate the settings.
	EMA:SettingsRefresh()	
--	EMA:SettingsRowClick( 1, 1 )
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	EMA:RegisterEvent( "CHAT_MSG_WHISPER" )
	EMA:RegisterEvent( "CHAT_MSG_BN_WHISPER" )
	EMA:RegisterEvent( "UPDATE_CHAT_WINDOWS" )
	EMA:RegisterEvent( "UPDATE_FLOATING_CHAT_WINDOWS", "UPDATE_CHAT_WINDOWS" )
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-------------------------------------------------------------------------------------------------------------
-- EMATalk functionality.
-------------------------------------------------------------------------------------------------------------

function EMA:UPDATE_CHAT_WINDOWS()
	EMA:UpdateChatFrameList()
	EMA.settingsControl.dropdownMessageArea:SetList( EMA.chatFrameList )
	if EMA.chatFrameList[EMA.db.whisperMessageArea] == nil then
		EMA.db.whisperMessageArea = "ChatFrame1"
	end
	EMA.settingsControl.dropdownMessageArea:SetValue( EMA.db.whisperMessageArea )	
end

function EMA:GetItemsMaxPosition()
	return #EMA.db.chatSnippets
end

function EMA:GetItemAtPosition( position )
	return EMA.db.chatSnippets[position]
end

function EMA:AddItem( name )
	local itemInformation = {}
	itemInformation.name = name
	itemInformation.snippet = ""
	table.insert( EMA.db.chatSnippets, itemInformation )
	EMA:SettingsRefresh()			
	EMA:SettingsRowClick( 1, 1 )
end

function EMA:RemoveItem()
	table.remove( EMA.db.chatSnippets, EMA.settingsControl.highlightRow )
	EMA:SettingsRefresh()
	EMA:SettingsRowClick( 1, 1 )		
end

--[[
-- The SendChatMessage hook.
function EMA:SendChatMessage( ... )
	local message, chatType, language, target = ...
	EMA:Print("test")
	if chatType == "WHISPER" then
		-- Does this character have chat snippets enabled?
		if EMA.db.enableChatSnippets == true then
			local snippetName = select( 3, message:find( "^!(%w+)$" ) )
			-- If a snippet name was found...
			if snippetName then
				-- Then look up the associated text.
				local messageToSend = EMA:GetTextForSnippet( snippetName )
				EMA:Print("test")
				--EMAPrivate.Communications.SendChatMessage( messageToSend, "WHISPER", target, EMAPrivate.Communications )
				
				-- Finish with the chat message, i.e. do not let the original handler run.
				return true
			end
		end
	end
	
	-- Call the orginal function.
	return EMA.hooks["SendChatMessage"]( ... )
end
]]

function EMA:CHAT_MSG_WHISPER( chatType, message, sender, language, channelName, target, flag, ... )
	-- Does this character forward whispers?
	--EMA:Print("Test", message, sender)
	if EMA.db.forwardWhispers == true then
		-- Set a GM flag if this whisper was from a GM.
		local isGM = false
		if flag == L["GM"] then
			isGM = true
		end
		-- Was the sender the master?
		if EMAApi.IsCharacterTheMaster( sender ) == true then
			-- Yes, relay the masters message to others.
			EMA:ForwardWhisperFromMaster( message )
		else		
			-- Not the master, forward the whisper to the master.
			EMA:ForwardWhisperToMaster( message, sender, isGM, false, nil )
		end
	end
end

function EMA:CHAT_MSG_BN_WHISPER( event, message, sender, a, b, c, d, e, f, g, h, i, j, realFriendID, ... )
	-- Does this character forward whispers?
	if EMA.db.forwardWhispers == true and EMA.db.doNotForwardRealIdWhispers == false then
		-- Is this character NOT the master?
		if EMAApi.IsCharacterTheMaster( self.characterName ) == false then
			-- Yes, not the master, relay the message to the master.
			EMA:ForwardWhisperToMaster( message, sender, false, true, realFriendID )
		end
	end
end

local function ColourCodeLinks( message )
	local realMessage = message
	for link in message:gmatch( "|H.*|h" ) do
		local realLink = ""
		local startFind, endFind = message:find( "|Hitem", 1, true )
		-- Is it an item link?
		if startFind ~= nil then
			-- Yes, is an item link.
			local itemQuality = select( 3, GetItemInfo( link ) )
			-- If the item is not in our cache, we cannot get the correct item quality / colour and the link will not work.
			if itemQuality ~= nil then
				realLink = select( 4, GetItemQualityColor( itemQuality ) )..link..FONT_COLOR_CODE_CLOSE
			else
				realLink = NORMAL_FONT_COLOR_CODE..link..FONT_COLOR_CODE_CLOSE
			end
		else
			-- Not an item link.
			-- GetFixedLink is in Blizzard's FrameXML/ItemRef.lua
			-- It fixes, quest, achievement, talent, trade, enchant and instancelock links.						
			realLink = GetFixedLink( link )
		end
		realMessage = realMessage:replace( link, realLink )
	end
	return realMessage
end

local function DoesMessageHaveLink( message )
	local startFind, endFind = message:find( "|H", 1, true )
	return startFind ~= nil 
end

local function BuildWhisperCharacterString( originalSender, viaCharacter )
	local info = ChatTypeInfo["WHISPER"]
	local colorString = format( "|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255 )
	return format( "%s|Hplayer:%2$s|h[%2$s]|h%4$s|Hplayer:%3$s|h[%3$s]|h%5$s|r", colorString, originalSender, viaCharacter, L["TALK_VIA"], L[")"] )
end

function EMA:ForwardWhisperToMaster( message, sender, isGM, isReal, realFriendID )
	-- Don't relay messages to the master or self (causes infinite loop, which causes disconnect).
	if (EMAApi.IsCharacterTheMaster( EMA.characterName )) or (EMA.characterName == sender) then
		return
	end
	-- Don't relay messages from the master either (not that this situation should happen).
	if EMAApi.IsCharacterTheMaster( sender ) == true then
		return
	end
	-- Build from whisper string, this cannot be a link as player links are not sent by whispers.
	local fromCharacterWhisper = sender	
	if isReal == true then
		-- Get the toon name of the character the RealID person is playing, Blizzard will not reveal player real names, so cannot send those.
		fromCharacterWhisper = select( 5, BNGetFriendInfoByID( realFriendID ) )..L["BATTLE_NET"]
		--local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText = BNGetFriendInfoByID( realFriendID )
	end
	if isGM == true then
		fromCharacterWhisper = fromCharacterWhisper..L["<GM>"]
	end
	-- Whisper the master.
	if EMA.db.fakeWhisper == true then
		local completeMessage = L["WHISPERS"]..message
	--[[	
		-- Send in compact format?
		if EMA.db.fakeWhisperCompact == true then
			-- Does the message contain a link?
			if DoesMessageHaveLink( message ) == false then
				-- No, don't display the message.
				local info = ChatTypeInfo["WHISPER"]
				local colorString = format( "|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255 )
				completeMessage = L[" "]..colorString..L["WHISPERED_YOU"].."|r"
			end
		end
	]]	
		if isGM == true then
			completeMessage = L[" "]..L["<GM>"]..L[" "]..completeMessage
		end
		local inject1 = nil
		if EMA.db.fakeInjectSenderToReplyQueue == true then
			inject1 = EMA.characterName
		end
		local inject2 = nil
		if EMA.db.fakeInjectOriginatorToReplyQueue == true then
			inject2 = sender
		end
		EMA:EMASendCommandToMaster( EMA.COMMAND_MESSAGE, EMA.db.whisperMessageArea, sender, EMA.characterName, completeMessage, inject1, inject2 )
	end
	--[[
	if EMA.db.forwardViaWhisper == true then
		-- RealID messages do not wrap links in colour codes (text is always all blue), so wrap link in colour code
		-- so normal whisper forwarding with link works.
		if (isReal == true) and (DoesMessageHaveLink( message ) == true) then
			message = ColourCodeLinks( message )
		end
		EMAPrivate.Communications.SendCommandMaster( fromCharacterWhisper..": "..message, "WHISPER", EMAApi.GetMasterName(), EMAPrivate.Communications.COMMUNICATION_PRIORITY_BULK )
	end
	]]
	-- Remember this sender as the most recent sender.
	EMA.lastSender = sender
	EMA.lastSenderIsReal = isReal
	EMA.lastSenderRealID = realFriendID
end

function EMA:ForwardWhisperFromMaster( messageFromMaster )
	-- Who to send to and what to send?
	-- Check the message to see if there is a character to whisper to; character name is preceeded by @.
	-- No match will return nil for the parameters.
	local sendTo, messageToInspect = select( 3, messageFromMaster:find( "^@(%w+)%s*(.*)$" ) )
	-- If no sender found in message...
	if not sendTo then
		-- Then send to last sender.
		sendTo = EMA.lastSender
		-- Send the full message.
		messageToInspect = messageFromMaster
	end
	-- Check to see if there is a snippet name in the message (text with a leading !).
	local messageToSend = messageToInspect
--[[	
	if EMA.db.enableChatSnippets == true then
		local snippetName = select( 3, messageToInspect:find( "^!(%w+)$" ) )
		-- If a snippet name was found...
		if snippetName then
			-- Then look up the associated text.
			messageToSend = EMA:GetTextForSnippet( snippetName )
		end
	end
]]	
	-- If there is a valid character to send to...
	if sendTo then
		if messageToSend:trim() ~= "" then
			-- Send the message.
			if EMA.lastSenderIsReal == true and EMA.lastSenderRealID ~= nil then
				BNSendWhisper( EMA.lastSenderRealID, messageToSend )
			else
				--EMA:Print("chatSend", messageToSend, sendTo ) 
				SendChatMessage( messageToSend, "WHISPER", nil, sendTo )
			end
		end
		-- Remember this sender as the most recent sender.
		EMA.lastSender = sendTo
	end
end

function EMA:GetTextForSnippet( snippetName )
	local snippet = ""
	for position, itemInformation in pairs( EMA.db.chatSnippets ) do
		if itemInformation.name == snippetName then
			snippet = itemInformation.snippet
			break
		end
	end
	return snippet
end

function EMA:ProcessReceivedMessage( sender, whisperMessageArea, orginator, forwarder, message, inject1, inject2 )
	local chatTimestamp = ""
	local info = ChatTypeInfo["WHISPER"]
	local colorString = format( "|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255 )	
	if (CHAT_TIMESTAMP_FORMAT) then
		chatTimestamp = colorString..BetterDate( CHAT_TIMESTAMP_FORMAT, time() ).."|r"
	end
	local fixedMessage = message
	for embeddedColourString in message:gmatch( "|c.*|r" ) do
		fixedMessage = fixedMessage:replace( embeddedColourString, "|r"..embeddedColourString..colorString )
	end
	fixedMessage = colorString..fixedMessage.."|r"
	if string.sub( whisperMessageArea, 1, 9 ) ~= "ChatFrame" then
		whisperMessageArea = "ChatFrame1"
	end
	_G[whisperMessageArea]:AddMessage( chatTimestamp..BuildWhisperCharacterString( orginator, forwarder )..fixedMessage )
	if inject1 ~= nil then
		ChatEdit_SetLastTellTarget( inject1, "WHISPER" )
	end
	if inject2 ~= nil then
		ChatEdit_SetLastTellTarget( inject2, "WHISPER" )
	end	
end

-- A EMA command has been recieved.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if commandName == EMA.COMMAND_MESSAGE then		
		EMA:ProcessReceivedMessage( characterName, ... )
	end
end