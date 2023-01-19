-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2023 Jennifer Cally					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Communications", 
	"AceComm-3.0", 
	"AceEvent-3.0",
	"AceConsole-3.0",
	"AceTimer-3.0",
	"AceHook-3.0"
)

-- Get the locale for EMACommunications.
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )

-- Get libraries.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local AceSerializer = LibStub:GetLibrary( "AceSerializer-3.0" )

local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )

-- EMACommunications is not a module, but the same naming convention for these values is convenient.
EMA.moduleName = "Communications"
EMA.moduleDisplayName = L["COMMUNICATIONS"]
EMA.settingsDatabaseName = "CommunicationsProfileDB"
EMA.parentDisplayName = L["OPTIONS"]
EMA.chatCommand = "ema-comm"
EMA.teamModuleName = "Team"
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\CommsLogo.tga"
-- order
EMA.moduleOrder = 20

-------------------------------------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------------------------------------

-- Communication methods.
EMA.COMMUNICATION_WHISPER = "WHISPER"
EMA.COMMUNICATION_GROUP = "RAID"
EMA.COMMUNICATION_GUILD = "GUILD"

-- Communication message prefix.
EMA.MESSAGE_PREFIX = "EmaMainComms"

-- Communication priorities.
EMA.COMMUNICATION_PRIORITY_BULK = "BULK"
EMA.COMMUNICATION_PRIORITY_NORMAL = "NORMAL"
EMA.COMMUNICATION_PRIORITY_ALERT = "ALERT"

-- Communication command.
EMA.COMMAND_PREFIX = "EmaCmdComms"
EMA.COMMAND_SEPERATOR = "\004"
EMA.COMMAND_ARGUMENT_SEPERATOR = "\005"

-- Internal commands sent by EMA Communications.
EMA.COMMAND_INTERNAL_SEND_SETTINGS = "EmaSetComms"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------


-- Get a settings value.
function EMA:ConfigurationGetSetting( key )
	return EMA.db[key[#key]]
end

-- Set a settings value.
function EMA:ConfigurationSetSetting( key, value )
	EMA.db[key[#key]] = value
end

-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		autoSetTeamOnlineorOffline = true,
		boostCommunication = true,
		useGuildComms = false
	},
}

-- Configuration.
local function GetConfiguration()
	local configuration = {
		name = EMA.moduleDisplayName,
		handler = EMA,
		type = 'group',
		get = "ConfigurationGetSetting",
		set = "ConfigurationSetSetting",
		args = {			 				
			type = "input",
				name = L["OPEN_CONFIG"],
				desc = L["OPEN_CONFIG_HELP"],
				usage = "/ema-comm config",
				get = false,
				set = "",
				guiHidden = true,
			push = {
				type = "input",
				name = L["PUSH_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "/ema-comm push",
				get = false,
				set = "EMASendSettings",
			},			
		},
	}
	return configuration
end


-- Debug message.
function EMA:DebugMessage( ... )
    --EMA:Print( ... )
end

-------------------------------------------------------------------------------------------------------------
-- Character online management.
-------------------------------------------------------------------------------------------------------------
local function IsCharacterOnline( characterName )
	return EMAPrivate.Team.GetCharacterOnlineStatus( characterName )
end

local function AssumeTeamAlwaysOnline()
	return "false"
end


-------------------------------------------------------------------------------------------------------------
-- Command management.
-------------------------------------------------------------------------------------------------------------

-- Creates a command to send.
local function CreateCommandToSend( moduleName, commandName, ... )
	--EMA:Print("Create", moduleName, commandName)
	-- Start the message with the module name and a seperator.
	local message = moduleName..EMA.COMMAND_SEPERATOR
	-- Add the command  name and a seperator.
	message = message..commandName..EMA.COMMAND_SEPERATOR
	-- Add any arguments to the message (serialized and seperated).
	local numberArguments = select( "#", ... )
	--EMA:Print("makecommand", numberArguments, "command",... )
	for iterateArguments = 1, numberArguments do
		local argument = select( iterateArguments, ... )
		message = message..AceSerializer:Serialize( argument )
		if iterateArguments < numberArguments then
			message = message..EMA.COMMAND_ARGUMENT_SEPERATOR
		end
	end
	return message	
end
	
local function CommandGuild(  message, ... )
	if EMA.db.useGuildComms == true then
			EMA:SendCommMessage(
			EMA.COMMAND_PREFIX,
			message,
			EMA.COMMUNICATION_GUILD,
			nil,
			EMA.COMMUNICATION_PRIORITY_ALERT	
			)
	end
end	
	
local function DefaultCommand( message )
	local channel = nil
	-- toon has to be in a group	
	if UnitInBattleground( "player" ) then
		channel = "INSTANCE_CHAT"
	elseif IsInGroup() then
		EMA:DebugMessage( "Group")
		local isInstance, instanceType = IsInInstance()
		local name, Type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance = GetInstanceInfo()
		if isInstance or instanceType == "raid" or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
				channel = "INSTANCE_CHAT"
			else
				if IsInRaid() then	
					channel = "RAID"
				else
					channel = "PARTY"
				end				
			end	
		else
			if IsInRaid() then	
				channel = "RAID"
			else
				channel = "PARTY"
			end
		end	
	end	
		--EMA:Print( "CHANNEL", channel)
	if channel then
	EMA:DebugMessage("Sending command to group.", message, "channel", channel, nil)
		--EMA:Print("Sending command to group.", message, "channel", channel, nil)
			--EMA.COMMUNICATION_GROUP,
			EMA:SendCommMessage(
			EMA.COMMAND_PREFIX,
			message,
			channel,
			nil,
			EMA.COMMUNICATION_PRIORITY_ALERT
			)
			--EMA:Print("testChennel", EMA.COMMAND_PREFIX, channel, EMA.COMMUNICATION_PRIORITY_ALERT)
	end
	--if the unit is not in the party then it unlikely did not get the party message,
	for characterName, characterOrder in EMAPrivate.Team.TeamList() do		
		if UnitInParty( Ambiguate( characterName, "none" ) ) == false then				
			EMA:DebugMessage( "Toon not in party:", characterName)
			if IsCharacterOnline( characterName ) == true then
				EMA:DebugMessage("Sending command to others not in party/raid.", message, "WHISPER", characterName)	
				EMA:SendCommMessage(
				EMA.COMMAND_PREFIX,
				message,
				EMA.COMMUNICATION_WHISPER,
				characterName,
				EMA.COMMUNICATION_PRIORITY_ALERT
				)
				--EMA:Print("testWis", EMA.COMMAND_PREFIX, EMA.COMMUNICATION_WHISPER, characterName , EMA.COMMUNICATION_PRIORITY_ALERT)	
			end	
		end
	end	
end

local function CommandAll( moduleName, commandName, ... )
   -- EMA:DebugMessage( "Command All: ", moduleName, commandName, ... )
	--EMA:Print( "Command All: ", moduleName, commandName, ... )
	-- Get the message to send.
	local message = CreateCommandToSend( moduleName, commandName, ... )
	if EMA.db.useGuildComms == true then 
		CommandGuild(  message )
	else
		DefaultCommand ( message )
	end
end	

-- Classic/tbc Due to a Slow/nonsending Comms in party/raid when Sending settings Tables we need fall over Whisper/Guild
local function CommandSettings( moduleName, commandName, ... )
--[[	
	if EMAPrivate.Core.isEmaClassicBuild() == false then
		CommandAll( moduleName, commandName, ... )
	else
]]	
		local message = CreateCommandToSend( moduleName, commandName, ... )
		if EMA.db.useGuildComms == true then 
			CommandGuild(  message )
		else
			for characterName, characterOrder in EMAPrivate.Team.TeamList() do					
				EMA:DebugMessage( "Toon not in party:", characterName)
				if IsCharacterOnline( characterName ) == true then
					EMA:DebugMessage("Sending command to others not in party/raid.", message, "WHISPER", characterName)	
					EMA:SendCommMessage(
					EMA.COMMAND_PREFIX,
					message,
					EMA.COMMUNICATION_WHISPER,
					characterName,
					EMA.COMMUNICATION_PRIORITY_BULK
					)
					--EMA:Print("testWis", EMA.COMMAND_PREFIX, EMA.COMMUNICATION_WHISPER, characterName , EMA.COMMUNICATION_PRIORITY_ALERT)	
				end	
			end
		end	
--	end	
end

-- Is This is use?
-- Send a command to the master.
local function CommandMaster( moduleName, commandName, ... )
    EMA:DebugMessage( "Command Master: ", moduleName, commandName, ... )
	-- Get the message to send.
	local message = CreateCommandToSend( moduleName, commandName, ... )
	-- Send the message to the master.
	local characterName = EMAPrivate.Team.GetMasterName()
		if IsCharacterOnline( characterName ) == true then
			EMA:DebugMessage("Sending command to others not in party/raid.", message, "WHISPER", characterName)	
				EMA:SendCommMessage( 
				EMA.COMMAND_PREFIX,
				message,
				EMA.COMMUNICATION_WHISPER,
				characterName,
				EMA.COMMUNICATION_PRIORITY_ALERT
				)
		end	
end

-- Is This is use?
-- Send a command to the Toon.
local function CommandToon( moduleName, characterName, commandName, ... )
	-- Get the message to send.
	local message = CreateCommandToSend( moduleName, commandName, ... )
		if IsCharacterOnline( characterName ) == true then
			EMA:DebugMessage("Sending command to others not in party/raid.", message, "WHISPER", characterName)	
				EMA:SendCommMessage( 
				EMA.COMMAND_PREFIX,
				message,
				EMA.COMMUNICATION_WHISPER,
				characterName,
				EMA.COMMUNICATION_PRIORITY_ALERT
				)
		end	
end		

-- Hide Player "Offline" Using to set the team memberm online.
local function SystemSpamFilter(frame, event, message)
	if( event == "CHAT_MSG_SYSTEM") then	
		if message:match(string.format(ERR_CHAT_PLAYER_NOT_FOUND_S, "(.+)")) then
			local SearchPlayerNotFound = gsub(ERR_CHAT_PLAYER_NOT_FOUND_S, "%%s", "(.+)")  -- Get from "No player named '%s' is currently playing."
			local _, _, characterName = strfind(message, SearchPlayerNotFound)
			if EMAApi.IsCharacterInTeam(characterName) == true then	
				--EMA:Print("player offline in team", characterName )
				if EMA.db.autoSetTeamOnlineorOffline == true then
					if IsCharacterOnline( characterName ) == true then
						EMAApi.setOffline( characterName, false )
						--EMA:Print("player offline in team", characterName )
					end
				end
				return true
			else
				--EMA:Print("player offline Not in team")
				return
			end
		end	
		if message:match(string.format(ERR_NOT_IN_RAID, "(.+)")) then
			return true
		end
	end		
    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemSpamFilter)



-- Receive a command from another character.
function EMA:CommandReceived( prefix, message, distribution, sender )
    local characterName = EMAUtilities:AddRealmToNameIfMissing( sender )
	EMA:DebugMessage( "Command received: ", prefix, message, distribution, sender )
	--EMA:Print( "Command received: ", prefix, message, distribution, sender )
	-- Check if the command is for EMA Communications.
	if prefix == EMA.COMMAND_PREFIX then
		--checks the char is in the team if not everyone can change settings and we do not want that
		if EMAPrivate.Team.IsCharacterInTeam( sender ) == true then
		    EMA:DebugMessage( "Sender is in team list." )
		   --automaic setting team members online.
			--EMA:Print("toonnonline", sender )
				if EMAPrivate.Team.GetCharacterOnlineStatus( characterName ) == false then
					--EMA:Print("Setting Toon online", distribution, sender, characterName )
					EMAApi.setOnline( characterName, true)
				end
			-- Split the command into its components.
			local moduleName, commandName, argumentsStringSerialized = strsplit( EMA.COMMAND_SEPERATOR, message )
			local argumentsTable  = {}
			-- Are there any arguments?
			if (argumentsStringSerialized ~= nil) and (argumentsStringSerialized:trim() == "") then 
				-- No.
				else
					-- Deserialize the arguments.
					local argumentsTableSerialized = { strsplit( EMA.COMMAND_ARGUMENT_SEPERATOR, argumentsStringSerialized ) }
					for index, argumentSerialized in ipairs( argumentsTableSerialized ) do
						local success, argument = AceSerializer:Deserialize( argumentSerialized )
						--EMA:Print("testSerialized", success, argument )
						if success == true then
							table.insert( argumentsTable, argument )
						else
							error( L["A: Failed to deserialize command arguments for B from C."]( "EMA", moduleName, sender ) )
						end
					end			
				end
				-- Look for internal EMA Communication commands.
				if commandName == EMA.COMMAND_INTERNAL_SEND_SETTINGS then				
					-- Tell EMACore to handle the settings received.
					EMAPrivate.Core.OnSettingsReceived( sender, moduleName, unpack( argumentsTable ) )
				else
					-- Any other command can go directly to the module that sent it.
					EMA:DebugMessage( "Sending command on to module: ", sender, moduleName, commandName, unpack( argumentsTable ) )
					EMAPrivate.Core.OnCommandReceived( sender, moduleName, commandName, unpack( argumentsTable ) )
				end
		else
			EMA:DebugMessage( "Sender is NOT in team list." )
		end
	end
end

-------------------------------------------------------------------------------------------------------------
-- EMA Communications API.  These methods should only be called by EMA Core.
-------------------------------------------------------------------------------------------------------------

-- Send settings to all members of the current team.
local function SendSettings( moduleName, settings )
	-- Send a push settings command to all.
	--EMA:Print("test", moduleName, EMA.COMMAND_INTERNAL_SEND_SETTINGS, settings )
	CommandSettings( moduleName, EMA.COMMAND_INTERNAL_SEND_SETTINGS, settings )
end

-- Command all members of the current team.
local function SendCommandAll( moduleName, commandName, ... )
	-- Send the command to all.
	CommandAll( moduleName, commandName, ... )
end

-- TODO: needs to be cleaned up at some point with other communication stuff

-- Command the master.
local function SendCommandMaster( moduleName, commandName, ... )
	-- Send the command to the master character.
	CommandMaster( moduleName, commandName, ... )
end

-- Command the master.
local function SendCommandToon( moduleName, characterName, commandName, ... )
	-- Send the command to the master character.
	CommandToon( moduleName, characterName, commandName, ... )
end

-------------------------------------------------------------------------------------------------------------
-- EMA Communications Initialization.
-------------------------------------------------------------------------------------------------------------

-- Initialize the addon.
function EMA:OnInitialize()
	--EMA.lastChannel = nil
	-- Register commands with AceComms - tell AceComms to call the CommandReceived function when a command is received.
	EMA:RegisterComm( EMA.COMMAND_PREFIX, "CommandReceived" )
	-- Create the settings database supplying the settings values along with defaults.
    EMA.completeDatabase = LibStub( "AceDB-3.0" ):New( EMA.settingsDatabaseName, EMA.settings )
	EMA.db = EMA.completeDatabase.profile
	-- Create the settings.
	LibStub( "AceConfig-3.0" ):RegisterOptionsTable( 
		EMA.moduleName, 
		GetConfiguration() 
	)	
	EMA:SettingsCreate()
	EMA.settingsFrame = EMA.settingsControl.widgetSettings.frame
	EMA:SettingsRefresh()	
	--TODO: Is this needed? as its already in a module??
	local k = GetRealmName()
	local realm = k:gsub( "%s+", "" )
	self.characterRealm = realm
	self.characterNameLessRealm = UnitName( "player" )
	self.characterName = self.characterNameLessRealm.."-"..self.characterRealm
	EMA.characterGUID = UnitGUID( "player" )
	-- End of needed:
	-- Register communications as a module.
	EMAPrivate.Core.RegisterModule( EMA, EMA.moduleName )
end
	
function EMA:OnEnable()
	EMA:RegisterEvent("GUILD_ROSTER_UPDATE")
	if EMA.db.boostCommunication == true then
		EMA:BoostCommunication()
		-- Repeat every 5 minutes.
		EMA:ScheduleRepeatingTimer( "BoostCommunication", 300 )
	end
end

function EMA:BoostCommunication()
	if EMA.db.boostCommunication == true then
		-- 2000 seems to be safe if NOTHING ELSE is happening. let's call it 800.
		ChatThrottleLib.MAX_CPS = 1200 --800
		-- Guesstimate overhead for sending a message; source+dest+chattype+protocolstuff
		ChatThrottleLib.MSG_OVERHEAD = 40
		-- WoW's server buffer seems to be about 32KB. 8KB should be safe, but seen disconnects on _some_ servers. Using 4KB now.
		ChatThrottleLib.BURST = 6000 --4000
		-- Reduce output CPS to half (and don't burst) if FPS drops below this value
		ChatThrottleLib.MIN_FPS = 10 --20
	end
end


-- Handle the chat command.
function EMA:EMAChatCommand( input )
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory( EMA.moduleDisplayName )
    else
        LibStub( "AceConfigCmd-3.0" ):HandleCommand( EMA.chatCommand, EMA.moduleName, input )
    end    
end

function EMA:OnDisable()
end

local function isPlayerInMyGuild( playerName) 
	local numGuildMembers, numOnline, numOnlineAndMobile = GetNumGuildMembers()
	for index = 1, numGuildMembers do
		local characterName,_,_,_,class,_,_,_,online,status,classFileName,_, _,isMobile = GetGuildRosterInfo(index)
		--EMA:Print("taaa", characterName, playerName)
		if characterName == playerName then
			--EMA:Print("player in my guild 102", characterName)
			return true
		end
	end
	return false
end


function EMA:GUILD_ROSTER_UPDATE(event, ... )
	if EMA.db.useGuildComms == false then
		return
	end
	EMA:SetNonGuildMembersOflline()
	local numGuildMembers, numOnline, numOnlineAndMobile = GetNumGuildMembers()
	for index = 1, numGuildMembers do
		characterName,_,_,_,class,_,_,_,online,status,classFileName,_, _,isMobile = GetGuildRosterInfo(index)
		--EMA:Print("Name", fullName, "online", online )
		if online == false then 
			if EMA.db.autoSetTeamOnlineorOffline == true then
				if EMAApi.IsCharacterInTeam(characterName) == true and IsCharacterOnline( characterName ) == true then 	
					EMAApi.setOffline( characterName, false )
					--EMA:Print("player offline in team", characterName )
				end
			end	
		end
	end
end


function EMA:SetNonGuildMembersOflline()
-- If Character is not in guild then auto set it offline as there is no communication for them cross guild!
	for characterName, position in EMAApi.TeamList() do
		local isNotInGuild = isPlayerInMyGuild( characterName )
		--EMA:Print("test", characterName, "is", isNotInGuild )
		
		if isNotInGuild == false then
			if EMA.db.autoSetTeamOnlineorOffline == true then
				if EMAApi.IsCharacterInTeam(characterName) == true and IsCharacterOnline( characterName ) == true then 	
					EMAApi.setOffline( characterName, false )
					--EMA:Print("player is not in my guild 101", characterName )
				end
			end	
		end	
	end
end	


-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

function EMA:SettingsCreate()
	EMA.settingsControl = {}
	EMAHelperSettings:CreateSettings( 
		EMA.settingsControl, 
		EMA.moduleDisplayName, 
		EMA.parentDisplayName, 
		EMA.EMASendSettings,
		EMA.moduleIcon,
		EMA.moduleOrder
		
	)
	local bottomOfOptions = EMA:SettingsCreateOptions( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfOptions )
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, GetConfiguration() )	
end

function EMA:SettingsCreateOptions( top )
	-- Get positions and dimensions.
	local buttonControlWidth = 105
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local labelContinueHeight = EMAHelperSettings:GetContinueLabelHeight()
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( false )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local column1Left = left
	local column2Left = left + 10
	local movingTop = top
	-- A blank to get layout to show right?
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L[""], movingTop, false )
	movingTop = movingTop - headingHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["COMMUNICATIONS"]..L[" "]..L["OPTIONS"] , movingTop, false )--
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.checkBoxAutoSetTeamOnlineorOffline = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop, 
		L["AUTO_SET_TEAM"],
		EMA.CheckBoxAutoSetTeamOnlineorOffline
	)
	--[[
	movingTop = movingTop - checkBoxHeight
	EMA.settingsControl.checkBoxBoostCommunication = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop, 
		L["BOOST_COMMUNICATIONS"],
		EMA.CheckBoxBoostCommunication,
		L["BOOST_COMMUNICATIONS_HELP"]
	)
	]]
	movingTop = movingTop - checkBoxHeight			
	movingTop = movingTop - checkBoxHeight
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["COMMUNICATIONS_AVD"]..L[" "]..L["OPTIONS"] , movingTop, false )--
	movingTop = movingTop - headingHeight	
	EMA.settingsControl.labelCommsInformation1 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["AVD_INFORMATION_ONE"] 
	)	
	movingTop = movingTop - labelContinueHeight	
	EMA.settingsControl.labelCommsInformation1 = EMAHelperSettings:CreateContinueLabel( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop,
		L["AVD_INFORMATION_TWO"] 
	)	
	movingTop = movingTop - labelContinueHeight	
	EMA.settingsControl.checkBoxUseGuildComms = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		column1Left, 
		movingTop, 
		L["USE_GUILD_COMMS"],
		EMA.CheckBoxUseGuildComms,
		L["USE_GUILD_COMMS_INFO"]
	)
	movingTop = movingTop - checkBoxHeight	
	return movingTop	
end

function EMA:CheckBoxBoostCommunication( event, value )
	EMA.db.boostCommunication = value
	EMA:SettingsRefresh()
end

function EMA:CheckBoxAssumeAlwaysOnline( event, value )
	EMA.db.assumeTeamAlwaysOnline = value
	EMA:SettingsRefresh()	
end

function EMA:CheckBoxAutoSetTeamOnlineorOffline( event, value )
	EMA.db.autoSetTeamOnlineorOffline = value
	EMA:SettingsRefresh()	
end


function EMA:CheckBoxUseGuildComms( event, value )
	EMA.db.useGuildComms = value
	EMA:SettingsRefresh()
end


function EMA:BeforeEMAProfileChanged()	
end

function EMA:OnEMAProfileChanged()
	EMA:SettingsRefresh()
end

function EMA:SettingsRefresh()	
	EMA.settingsControl.checkBoxAutoSetTeamOnlineorOffline:SetValue( EMA.db.autoSetTeamOnlineorOffline )
	--EMA.settingsControl.checkBoxBoostCommunication:SetValue( EMA.db.boostCommunication )
	EMA.settingsControl.checkBoxUseGuildComms:SetValue( EMA.db.useGuildComms )

end

-- Settings received.
function EMA:EMASendSettings()
	SendSettings( EMA.moduleName, EMA.db )
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.autoSetTeamOnlineorOffline = settings.autoSetTeamOnlineorOffline
	--	EMA.db.boostCommunication = settings.boostCommunication
		EMA.db.useGuildComms = settings.useGuildComms
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

-- text = message to send -- This is mosty used for sending over EMA Own Comms mosty of Whispers
-- chatDestination = "PARTY, WHISPER, RAID, CHANNEL, etc"
-- characterOrChannelName = character name if WHISPER or channel name if CHANNEL or nil otherwise
-- If we clean up EMA-msg then we can remove this maybe again Eboyn TODO::::
-- priority = one of 
--   EMA.COMMUNICATION_PRIORITY_BULK,
--   EMA.COMMUNICATION_PRIORITY_NORMAL
--   EMA.COMMUNICATION_PRIORITY_ALERT

local function SendChatMessage( text, chatDestination, characterOrChannelName, priority )
	-- Message small enough to send?
	--EMA:Print("test", text, chatDestination, characterOrChannelName, priority)
	if text:len() <= 255 then
		--EMA:Print("test TURE!!!!! TOBIG" )
		ChatThrottleLib:SendChatMessage( priority, EMA.MESSAGE_PREFIX, text, chatDestination, nil, characterOrChannelName, nil )
	else
		-- No, message is too big, split into smaller messages, taking UTF8 characters into account.	
		local bytesAvailable = string.utf8len(text1)
		local currentPosition = 1
		local countBytes = 1
		local startPosition = currentPosition
		local splitText = ""
		-- Iterate all the utf8 characters, character by character until we reach 255 characters, then send
		-- those off and start counting over.
		while currentPosition <= bytesAvailable do
			-- Count the number of bytes the character at this position takes up.
			countBytes = countBytes + EMAutf8charbytes( text, currentPosition )
			-- More than 255 bytes yet?
			if countBytes <= 255 then
				-- No, increment the position and keep counting.
				currentPosition = currentPosition + EMAutf8charbytes( text, currentPosition )
			else
				-- Yes, more than 255.  Send this amount off.
				splitText = text:sub( startPosition, currentPosition )
				ChatThrottleLib:SendChatMessage( priority, EMA.MESSAGE_PREFIX, splitText, chatDestination, nil, characterOrChannelName, nil )
				-- New start position and count.
				startPosition = currentPosition + 1
				countBytes = 1
			end
		end
		-- Any more bytes left to send?
		if startPosition < currentPosition then
			-- Yes, send them.
			splitText = text:sub( startPosition, currentPosition )
			ChatThrottleLib:SendChatMessage( priority, EMA.MESSAGE_PREFIX, splitText, chatDestination, nil, characterOrChannelName, nil )
		end
	end
end

EMAPrivate.Communications.COMMUNICATION_PRIORITY_BULK = EMA.COMMUNICATION_PRIORITY_BULK
EMAPrivate.Communications.COMMUNICATION_PRIORITY_NORMAL = EMA.COMMUNICATION_PRIORITY_NORMAL
EMAPrivate.Communications.COMMUNICATION_PRIORITY_ALERT = EMA.COMMUNICATION_PRIORITY_ALERT
EMAPrivate.Communications.SendChatMessage = SendChatMessage
EMAPrivate.Communications.SendSettings = SendSettings
EMAPrivate.Communications.SendCommandAll = SendCommandAll
EMAPrivate.Communications.SendCommandMaster = SendCommandMaster
EMAPrivate.Communications.SendCommandToon = SendCommandToon
EMAPrivate.Communications.SendCommandMaster = SendCommandMaster
EMAPrivate.Communications.SendCommandToon = SendCommandToon
EMAPrivate.Communications.AssumeTeamAlwaysOnline = AssumeTeamAlwaysOnline
