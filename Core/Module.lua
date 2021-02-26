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

local MAJOR, MINOR = "Module-1.0", 2
local EMAModule, oldMinor = LibStub:NewLibrary( MAJOR, MINOR )

if not EMAModule then 
	return 
end

-- Load libraries.
LibStub( "AceConsole-3.0" ):Embed( EMAModule )
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )

-------------------------------------------------------------------------------------------------------------
-- EMA Module Mixin Management.
-------------------------------------------------------------------------------------------------------------

-- A list of modules that embed this module.
EMAModule.embeddedModules = EMAModule.embeddedModules or {}

-- These methods are the embbedable methods.

local mixinMethods = {
	"EMARegisterModule", "EMAModuleInitialize",
	"EMASendCommandToTeam", "EMASendCommandToMaster",
	"EMASendMessageToTeam", "EMASendCommandToToon",
	"EMASendSettings", "EMAOnSettingsReceived",
	"EMAChatCommand", 
	"EMAConfigurationGetSetting", "EMAConfigurationSetSetting",
} 

-- Embed all the embeddable methods into the target module.
function EMAModule:Embed( targetModule )
	for key, value in pairs( mixinMethods ) do
		targetModule[value] = self[value]
	end
	LibStub( "AceConsole-3.0" ):Embed( targetModule )
	self.embeddedModules[targetModule] = true
	return targetModule
end

-------------------------------------------------------------------------------------------------------------
-- EMA Module Registration.
-------------------------------------------------------------------------------------------------------------

-- Register a module with EMA.  EMA needs modules to be registered in order to faciliate communications.
function EMAModule:EMARegisterModule( moduleName )
	EMAPrivate.Core.RegisterModule( self, moduleName )
end

-------------------------------------------------------------------------------------------------------------
-- EMA Communications.
-------------------------------------------------------------------------------------------------------------

-- Send settings to all available EMA Team characters.
function EMAModule:EMASendSettings()
	EMAPrivate.Core.SendSettings( self, self.db )
end

-- Send a command to all available EMA Team characters.
function EMAModule:EMASendCommandToTeam( commandName, ... )
	EMAPrivate.Core.SendCommandToTeam( self, commandName, ... )
end

-- Send a command to just the master character.
function EMAModule:EMASendCommandToMaster( commandName, ... )
	EMAPrivate.Core.SendCommandToMaster( self, commandName, ... )
end

function EMAModule:EMASendCommandToToon( characterName, commandName, ... )
	EMAPrivate.Core.SendCommandToToon( self, characterName, commandName, ... )
end

-- Send a message to the team.
function EMAModule:EMASendMessageToTeam( areaName, message, suppressSender, ... )
	EMAPrivate.Message.SendMessage( areaName, message, suppressSender, ... )
end

-------------------------------------------------------------------------------------------------------------
-- EMA Chat Commands.
-------------------------------------------------------------------------------------------------------------
-- Does the Chat Command Exist
local function DoesTheChatCommandExist( configuration, command )
	local exist = false
	for key, info in pairs( configuration ) do
		stringName = string.lower( key )
		--print("aa", stringName, "vs", command )
		if info.type == "input" then
			if stringName == command then	
				exist = true
				break
			end
		end
	end
	return exist	
end				

-- Handle the chat command v2 EMA.
function EMAModule:EMAChatCommand( inputBefore )
	input = string.lower( inputBefore )
	--print("test2", "input", input, "command", self.chatCommand, "module", self.moduleName )
	local inputString, tag = strsplit( " ", inputBefore )
	local CommandExist = DoesTheChatCommandExist( self:GetConfiguration().args, inputString ) 
	if input == "config" then
		if InCombatLockdown() then
			print( L["CANNOT_OPEN_IN_COMBAT"] )
		return
	end
		-- Show Config
		EMAPrivate.SettingsFrame.Widget:Show()
		EMAPrivate.SettingsFrame.TreeGroupStatus.groups[self.parentDisplayName] = true
		EMAPrivate.SettingsFrame.WidgetTree:SelectByPath( self.parentDisplayName, self.moduleDisplayName )
		EMAPrivate.SettingsFrame.Tree.ButtonClick( nil, nil, self.moduleDisplayName, false)
	elseif CommandExist then			
		--Command Found now Handle IT!
		--print("Command Found", input )
		LibStub( "AceConfigCmd-3.0" ):HandleCommand( self.chatCommand, self.moduleName, input )
	else	
		-- hell knows what to do so HELP!!!
		--print("No found Command Found HELP", input )
		for key, info in pairs( self:GetConfiguration().args ) do
			if info.type == "input" then
				print("|cFFFFFF00"..info.usage, "|cFFFFFFFF".." [ "..info.desc.." ]" )
			end
		end	
	end    
end

-------------------------------------------------------------------------------------------------------------
-- Module initialization and settings management.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMAModule:EMAModuleInitialize( settingsFrame )
    -- Create the settings database supplying the settings values along with defaults.
	self.completeDatabase = LibStub( "AceDB-3.0" ):New( self.settingsDatabaseName, self.settings )
	self.db = self.completeDatabase.profile
	self.db.global = self.completeDatabase.global
	-- Create the settings.
	LibStub( "AceConfig-3.0" ):RegisterOptionsTable( self.moduleName, self:GetConfiguration() )
	self.settingsFrame = settingsFrame
	-- Register the chat command for this module.
	--print("EMAChatCommand", self.chatCommand, self.chatCommandTwo, self.chatCommandThree )
	if self.chatCommand then
		self:RegisterChatCommand( self.chatCommand, "EMAChatCommand" )
	end
	-- Remember the characters name.
	-- If server has a space in realm name GetRealmName() will show space this will not work with blizzard API so we need to hack this to work --ebony
	--local _, k = UnitFullName("player")
	local k = GetRealmName()
	local realm = k:gsub( "%s+", "")
	self.characterRealm = realm
	self.characterNameLessRealm = UnitName( "player" ) 
	--self.characterName = UnitFullName( "player" )
	self.characterName = self.characterNameLessRealm.."-"..self.characterRealm
	--self.characterName = UnitFullName("player")
	self.characterGUID = UnitGUID( "player" )
	-- Register this module with EMA.
	self:EMARegisterModule( self.moduleName )
end

-- Get a settings value.
function EMAModule:EMAConfigurationGetSetting( key )
	return self.db[key[#key]]
end

-- Set a settings value.
function EMAModule:EMAConfigurationSetSetting( key, value )
	self.db[key[#key]] = value
end

-------------------------------------------------------------------------------------------------------------
-- Upgrade Library.
-------------------------------------------------------------------------------------------------------------

-- Upgrade all modules that are already using this library to use the newer version.
for targetModule, value in pairs( EMAModule.embeddedModules ) do
	EMAModule:Embed( targetModule )
end
