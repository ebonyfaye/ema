-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Cally (Ebony)								--
--																					--
--				License: All Rights Reserved 2018 Jennifer Cally					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

local MAJOR, MINOR = "Module-1.0", 1
local EMAModule, oldMinor = LibStub:NewLibrary( MAJOR, MINOR )

if not EMAModule then 
	return 
end

-- Load libraries.
LibStub( "AceConsole-3.0" ):Embed( EMAModule )

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

-- Handle the chat command.
function EMAModule:EMAChatCommand( input )
   --print("test", input, self.chatCommand, self.moduleName )
	if not input or input:trim() == "" then
		EMAPrivate.SettingsFrame.Widget:Show()
		EMAPrivate.SettingsFrame.TreeGroupStatus.groups[self.parentDisplayName] = true
		EMAPrivate.SettingsFrame.WidgetTree:SelectByPath( self.parentDisplayName, self.moduleDisplayName )
		EMAPrivate.SettingsFrame.Tree.ButtonClick( nil, nil, self.moduleDisplayName, false)
    else
        LibStub( "AceConfigCmd-3.0" ):HandleCommand( self.chatCommand, self.moduleName, input )
		--LibStub( "AceConfigCmd-3.0" ):HandleCommand( self.chatCommandTwo, self.moduleName, input )
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
	-- Create the settings.
	LibStub( "AceConfig-3.0" ):RegisterOptionsTable( self.moduleName, self:GetConfiguration() )
	self.settingsFrame = settingsFrame
	-- Register the chat command for this module.
	--print("EMAChatCommand", self.chatCommand, self.chatCommandTwo, self.chatCommandThree )
	if self.chatCommand then
		self:RegisterChatCommand( self.chatCommand, "EMAChatCommand" )
	end
	--[[
	if self.chatCommandTwo then
		self:RegisterChatCommand( self.chatCommandTwo, "EMAChatCommand" )
	end
	if self.chatCommandThree then
		--self:RegisterChatCommand( self.chatCommandThree, "EMAChatCommandThree" )
	end
	]]
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
