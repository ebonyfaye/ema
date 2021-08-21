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

local L = LibStub("AceLocale-3.0"):NewLocale( "Core", "enUS", true )

-- NewLocales
  
--PreCoded ALL
L["JAMBA"] = "Jamba"
L["JAMBA EE"] = "Jamba EE"
L["EMA"] = "EMA"
L["DISABLED_IN_CLASSIC"] = "Not Supported In Classic or Classic-TBC"
L[""] = true
L[" "] = true
L[": "] = true
L["("] = true
L[")"] = true
L[" / "] = true
L["/"] = true
L["%"] = true
L["N/A"] = true
L["WIP"] = "wip"
L["OPEN_CONFIG"] = "Opens The Config"
L["OPEN_CONFIG_HELP"] = "Opens The Configuration GUI"
L["PUSH_SETTINGS"] = "Push Settings"
L["PUSH_ALL_SETTINGS"] = "Push All Settings"
L["PUSH_SETTINGS_INFO"] = "Push Settings To Team Members" 
L["MINION"] = "Minion"
L["NAME"] = "Name"
L["MASTER"] = "Master"
L["ALL"] = "All"
L["MESSAGES_HEADER"] = "Messages"
L["MESSAGE_AREA"]  = "Message Area"
L["SEND_WARNING_AREA"] = "Warning Area"
L["PH"] = "PH"
L["PH_HELP"] = "Place Holder"
L["CTRL"] = "Ctrl"
L["SHIFT"] = "Shift"
L["ALT"] = "Alt"
L["UPDATE"] = "Update"
L["ISBOXER_ADDON_NOT_LOADED"] = "ISBoxer Addon Not Installed Or Loaded"
L["GLOBAL_LIST"] = "Use Global List"
L["GLOBAL_SETTINGS_LIST_HELP"] = "Use A Global List \nThis Works Across All Characters"
L["COPY"] = "Copy"
L["COPY_HELP"] = "Copy From Local To Global List"
L["MODULE_LIST"] = "Module List"
L["CANNOT_OPEN_IN_COMBAT"] = "|cFFFF0000Cannot Open The GUI Config In Combat"

-- Display Options
L["APPEARANCE_LAYOUT_HEALDER"] = "Appearance & Layout"
L["BLIZZARD"] = "Blizzard"
L["BLIZZARD_TOOLTIP"] = "Blizzard Tooltip"
L["BLIZZARD_DIALOG_BACKGROUND"] = "Blizzard Dialog Background"
L["ARIAL_NARROW"] = "Arial Narrow"
L["NUMBER_OF_ROWS"] = "Number Of Rows"
L["SCALE"] = "Scale"
L["TRANSPARENCY"] = "Transparency"
L["BORDER_STYLE"] = "Border Style" 
L["BORDER COLOUR"] = "Border Colour"
L["BACKGROUND"] = "Background"
L["BG_COLOUR"] = "Background Colour"
L["FONT"] = "Font"
L["FONT_SIZE"] = "Font Size"
L["BAR_TEXTURES"] = "Status Bar Textures"
L["WIDTH"] = "Width"
L["HEIGHT"] = "Hight"

-- Numbers
L["1"] = "One"
L["2"] = "Two"
L["3"] = "Three"
L["4"] = "Four"
L["5"] = "Five"
L["6"] = "Six"
L["7"] = "Seven"
L["8"] = "Eight"
L["9"] = "Nine"
L["10"] = "Ten"
L["11"] = "Eleven"
L["12"] = "Twelve"
L["13"] = "Thirteen"
L["14"] = "Fourteen"
L["15"] = "Fifteen"
L["16"] = "Sixteen"
L["17"] = "Sventeen"
L["18"] = "Eighteen"
L["19"] = "Nineteen"
L["20"] = "Twenty"

--------------------------
-- Modules Locale
L["NEWS"] = "News"
L["OPTIONS"] = "Options"
L["SETUP"] = "Setup" 
L["PROFILES"] = "Profiles"
L["TEAM"] = "Team"
L["COMMUNICATIONS"] = "Communications"
L["MESSAGE_DISPLAY"] = "Message Display"
L["GROUP_LIST"] = "Group List"
L["DISPLAY"] = "Display"
L["ITEM_USE"] = "Item Use"
L["VENDOR_LIST_MODULE"] = "Sell List"
L["INTERACTION"] = "Interaction"
L["CURRENCY"] = "Currency"
L["INFORMATION"] = "Information"
L["TOON"] = "Toon"
L["FOLLOW"] = "Follow"
L["PURCHASE"] = "Purchase"
L["VENDOR"] = "Vendor"
L["PURCHASE"] = "Purchase"
L["WARNINGS"] = "Warnings"
L["QUEST"] = "Quest"
L["TRADE"] = "Trade"
L["GUILD"] = "Guild"
L["Mail"] = "Mail"
L["REPAIR"] = "Repair"
L["TALK"] = "Talk"
L["QUEST"] = "Quest" 
L["COMPLETION"] = "Completion"
L["TRACKER"] = "Tracker"
L["ISBOXER"] = "ISBoxer"
L["MACRO"] = "Macro"

--------------------------
-- Pecoded String Formats
L["SETTINGS_RECEIVED_FROM_A"] = function( characterName )
	return string.format("Settings Received From %s", characterName )
end

L["A_IS_NOT_IN_TEAM"] = function( characterName )
	return string.format("%s Is Not In My Team List. I Can Not Set Them To Be My Master.", characterName )
end
--------------------------
-- Core Locale
L["STATUSTEXT"] = "EMA: Ebony's MultiBoxing Assistant"
L["RESET_SETTINGS_FRAME"] = "Reset Settings Frame"
L["MODULE_NOT_LOADED"] = "Module Not Loaded Or Is Out Of Date"
L["RELEASE_NOTES"] = "Release Notes "
L["COPYING_PROFILE"] = "Copying profile: "
L["CHANGING_PROFILE"] = "Changing profile: "
L["PROFILE_RESET"] = "Profile reset - iterating all modules."
L["RESETTING_PROFILE"] = "Resetting profile: "
L["PROFILE_DELETED"] = "Profile deleted - iterating all modules."
L["DELETING_PROFILE"] = "Deleting profile: "
L["Failed_LOAD_MODULE"] =  "Failed to load EMA Module: "
L["KEY_BINDINGS"] = "Key Bindings"
L["VERSION"] = "Version"
L["SPECIAL_THANKS"] = "Special Thanks:"
L["THANKS1"] = "Michael \"Jafula\" Miller For Making Jamba That Some Of This Code Is Based On"
L["WEBSITES"] = "Websites"
L["ME"] = "Current Project Manger Jennifer Calladine (Ebony) " 
L["ME_TWITTER"] = "https://twitter.com/Jenn_Ebony"
L["COPYRIGHT"] = "Copyright (C) 2015-2021  Jennifer Calladine (Ebony)"
L["COPYRIGHTTWO"] = "Released Under License: All Rights Reserved unless otherwise explicitly stated"
L["FRAME_RESET"] = "Frame Reset"
-- Msg 8000
L["ALL_SETTINGS_RESET"] = "Thank You For Using EMA \nYour settings have been reset. \n\nPlease report any bugs to the source control issue tracker."
L["CAN_NOT_RUN_JAMBA_AND_EMA"] = "|cFFFF0000 You Can Not Run \"Jamba\" With EMA \nDisabling Jamba Addon \n\nThis Will Reload Your UI"
-- CHANGE ME!!!
L["v2_NEWS"] = "|cFFFFFF00Thank You For Upgrading EMA \nYou Are Now On Release v3.0 \n\n|cFFFFFFFFRead Changelog For More Information"

--------------------------
-- Communications Locale

L["A: Failed to deserialize command arguments for B from C."] = function( libraryName, moduleName, sender )
	return libraryName..": Failed to deserialize command arguments for "..moduleName.." from "..sender.."."
end
L["AUTO_SET_TEAM"] = "Auto Set Team Members On and Off Line"
L["BOOST_COMMUNICATIONS"] = "Boost EMA Communications"
L["BOOST_COMMUNICATIONS_HELP"] = "Reload UI To Take Effect, May Cause Disconnections"
L["USE_GUILD_COMMS"] = "Use Guild Communications"
L["USE_GUILD_COMMS_INFO"] = "Use Guild Communications \nAll Of Team Needs To Be In Same Guild" 
L["USE_CHANNEL_COMMS"] = "Use Channel Communications"
L["USE_CHANNEL_COMMS_INFO"] = "Use Chennel Communications \nAll Of Team Needs To Be On The Same Realm" 
L["AVD_INFORMATION_ONE"] = "All Characters Will Need To Be on the Same Realm Or A Connect Realms"
L["AVD_INFORMATION_TWO"] = "This Is The Recommended System To Use"
L["COMMUNICATIONS_AVD"] = "Advanced Communications"

----------------------------
-- Helper Locale
L["COMMANDS"] = "Commands"
L["SLASH_COMMANDS"] = "Slash Commands"

----------------------------
-- Team Locale
L["JAMBA-TEAM"] = "Team"
L["INVITE_GROUP"] = "Invite Team To Group"
L["DISBAND_GROUP"] = "Disband Group"
L["SET_MASTER"] = "Set Current Character The Master"
L["ADD"] = "Add"
L["ADD_HELP"] = "Add a member to the team list."
L["REMOVE"] = "Remove"
L["REMOVE_REMOVE"] = "Remove A Member From The Team List."
L["MASTER_HELP"] = "Set The Master Character."
L["I_AM_MASTER"] = "I'm The Master"
L["I_AM_MASTER_HELP"] = "Set This Character To Be The Master Character."
L["INVITE"] = "Invite"
L["INVITE_HELP"] = "Invite Team Members To A Party With Or Without A <Group>."
L["DISBAND"] = "Disband"
L["DISBAND_HELP"] = "Disband All Team Members From Their Parties."
L["ADD_GROUPS_MEMBERS"] = "Add Groups Members"
L["ADD_GROUPS_MEMBERS_HELP"] = "Add Members In The Current Group To The Team."
L["REMOVE_ALL_MEMBERS"] = "Remove All Members"
L["REMOVE_ALL_MEMBERS_HELP"] = "Remove all members from the team."
L["SET_TEAM_OFFLINE"] = "Set Team OffLine"
L["SET_TEAM_OFFLINE_HELP"] = "Set All Team Members OffLine"
L["SET_TEAM_ONLINE"] = "Set Team OnLine"
L["SET_TEAM_ONLINE_HELP"] = "Set All Team Members OnLine"
L["TEAM_HEADER"] = "Team"
L["GROUPS_HEADER"] = "Groups"
L["BUTTON_ADD_HELP"] = "Adds A Member To The Team List\nYou can Use:\nCharacterName\nCharacterName-realm\nTarget\nMouseover"
L["BUTTON_ADDALL_HELP"] = "Adds all Party/Raid members to the team list"
L["BUTTON_UP_HELP"] = "Move The Character Up A Place In The Team List"
L["BUTTON_ISBOXER_ADD_HELP"] = "Adds ISBoxer Team Members To The Team List"
L["BUTTON_DOWN_HELP"] = "Move The Character Down A Place In The Team List"
L["BUTTON_REMOVE_HELP"] = "Removes Selected Member From The Team List"
L["BUTTON_MASTER_HELP"] = "Set The Selected Member To Be The Master Of The Group"
L["BUTTON_GROUP_REMOVE_HELP"] = "Removes The Group From The Selected Character"
L["CHECKBOX_ISBOXER_ADD"] = "Auto Add ISBoxer Team List"
L["CHECKBOX_ISBOXER_ADD_HELP"] = "Automatically Adds ISBoxer Team List Members \nNOTE:\nDoes Not Remove Members No Longer In The Isboxer Team"
L["MASTER_CONTROL"] = "Master Control"
L["CHECKBOX_MASTER_LEADER"] = "Promote Master To Party Leader."
L["CHECKBOX_MASTER_LEADER_HELP"] = "Master Will Always Be The Party Leader."
L["CHECKBOX_CTM"] = "Sets Click-To-Move On Minions"
L["CHECKBOX_CTM_HELP"] = "Auto Activate Click-To-Move On Minions And Deactivate On Master."
L["PARTY_CONTROLS"] = "Party Invitations Control"
L["CHECKBOX_CONVERT_RAID"] = "Auto Convert To Raid"
L["CHECKBOX_CONVERT_RAID_HELP"] = "Auto Convert To Raid If Team Is Over Five Characters"
L["CHECKBOX_ASSISTANT"] = "Auto Set All Assistant"
L["CHECKBOX_ASSISTANT_HELP"] = "Auto Set all raid Member's to Assistant."
L["CHECKBOX_TEAM"] = "Accept From Team"
L["CHECKBOX_TEAM_HELP"] = "Auto Accept Invites From The Team."
L["CHECKBOX_ACCEPT_FROM_FRIENDS"] = "Accept From Friends"
L["CHECKBOX_ACCEPT_FROM_FRIENDS_HELP"] = "Auto Accept Invites From Your Friends List."
L["CHECKBOX_ACCEPT_FROM_GUILD"] = "Accept From Guild."
L["CHECKBOX_ACCEPT_FROM_GUILD_HELP"] = "Auto Accept Invites From Your Guild."
L["CHECKBOX_DECLINE_STRANGERS"] = "Decline from strangers."
L["CHECKBOX_DECLINE_STRANGERS_HELP"] = "Decline Invites From Anyone Else"
L["NOT_LINKED"] = "(Not Linked)"
L["TEAM_NO_TARGET"] = "No Target Or Target Is Not A Player"
L["UNKNOWN_GROUP"] = "Unknown Group"
L["ONLINE"] = "Online"
L["OFFLINE"] = "Offline"
L["STATICPOPUP_ADD"] = "Enter character to add in name-server format:"
L["STATICPOPUP_REMOVE"] = "Are you sure you wish to remove %s from the team list?"
L["SET_FOCUS_MASTER"] = "Sets Focus To Master* "
L["SET_MASTER_TARGET"] = "Sets Target To Master* "
L["SET_MASTER_ASSIST"] = "Sets Assist To Master* "
L["FAKE_KEY_BINDING"] = "* Needs to Press the key on all clones"
L["BINDING_CLICK_TO_MOVE"] = "Toggle Click To Move"
L["COMMANDLINE_CLICK_TO_MOVE"] = "Toggles Click To Move <Group> "
L["COMMANDLINE_CLICK_TO_MOVE_HELP"] = "Toggles Click To Move By <Group>"
L["SET_FOCUS_ONE"] = "Sets Focus To Order One"
L["SET_FOCUS_TWO"] = "Sets Focus To Order Two"
L["SET_FOCUS_THREE"] = "Sets Focus To Order Three"
L["SET_FOCUS_FOUR"] = "Sets Focus To Order Four"
L["SET_FOCUS_FIVE"] = "Sets Focus To Order Five"
L["SET_FOCUS_SIX"] = "Sets Focus To Order Six"
L["SET_FOCUS_SEVEN"] = "Sets Focus To Order Seven"
L["SET_FOCUS_EIGHT"] = "Sets Focus To Order Eight"
L["SET_FOCUS_NINE"] = "Sets Focus To Order Nine"
L["SET_FOCUS_TEN"] = "Sets Focus To Order Ten"

--------------------------
-- Message Locale
L["DEFAULT_CHAT_WINDOW"] = "Default Chat Window"
L["WHISPER"] = "Whisper"
L["PARTY"] = "Party" 
L["GUILD_OFFICER"] = "Guild Officer"
L["RAID"] = "Raid"
L["RAID_WARNING"] = "Raid Warning"
L["MUTE"] = "MUTE"
L["DEFAULT_MESSAGE"] = "Default Message"
L["DEFAULT_WARNING"] = "Default Warning"
L["MUTE_POFILE"] = "Mute (Default)"
L["ADD_MSG_HELP"] = "Adds New Message Area"
L["REMOVE_MSG_HELP"] = "Removes Message Area"
L["NAME"] = "Name"
L["PASSWORD"] = "Password"
L["AREA"]  = "Area On Screen"
L["SOUND_TO_PLAY"] = "Sound To Play"
L["SAVE"] = "Save"
L["STATICPOPUP_ADD_MSG"] = "Enter Name Of The Message Area To Add:"
L["REMOVE_MESSAGE_AREA"] = "Are You Sure You Wish To Remove \"%s\" From The Message Area List?"
L["MESSAGE_AREA_LIST"] = "Message Area List"
L["MESSAGE_AREA_CONFIGURATION"] = "Message Area Configuration"
L["ERR_COULD_NOT_FIND_AREA"] = function( areaName )
	return string.format("ERROR: Could not find area: %s", areaName) 
end
--------------------------
-- Tag/Group Locale
L["ADD_TAG_HELP"]= "Add a Group To This Character."
L["REMMOVE_TAG_HELP"] = "Remove A Tag From This Character."
L["GROUP"] =  "Group"
L["BUTTON_TAG_ADD_HELP"] = "Adds A New Group To The List"
L["BUTTON_TAG_REMOVE_HELP"] = "Removes A Group From The List"
L["ADD_TO_GROUP"] = "Add To Group"
L["ADD_TO_GROUP_HELP"] = "Add Character To Group"
L["REMOVE_FROM_GROUP"] = "Remove From Group"
L["REMOVE_FROM_GROUP_HELP"] = "Remove Character From Group"
L["WRONG_TEXT_INPUT_GROUP"] = "Needs To Be In <Character-realm> <Group> Format"
L["NEW_GROUP_NAME"] = "Adds A New Group:"
L["REMOVE_FROM_TAG_LIST"] = "Are You Sure You Wish To Remove %s From The Group List?"
--Note This needs to be lowercase! 
--If translated Make Sure you keep them as as the lowercase words or you Will break Group/Tag
--It be a headache i don't need -- Ebony
L["ALL_LOWER"] = "all"
L["MASTER_LOWER"] = "master"
L["MINION_LOWER"] = "minion"

--------------------------
-- Item-Use Locale
L["ITEM-USE"] = "Item-Use"
L["ITEM"] = "Item"
L["HIDE_ITEM_BAR"] = "Hide Item Bar"
L["HIDE_ITEM_BAR_HELP"] = "Hide The Item Bar Panel."
L["SHOW_ITEM_BAR"] = "Show Item Bar"
L["SHOW_ITEM_BAR_HELP"] = "Show The Item Bar Panel."
L["CLEAR_ITEM_BAR"] = "Clear Item Bar"
L["CLEAR_ITEM_BAR_HELP"] = "Clear The Item Bar (Remove All Items)."
L["CLEAR_BUTT"] = "Clear"
L["SYNC_BUTT"] = "Sync"
L["TOOLTIP_SYNCHRONISE"] = "Synchronise The Item-Use Bar \nAnd Updates Item Count"
L["TOOLTIP_NOLONGER_IN_BAGS"] = "Remove Items No Longer In Your Bags, From The Item Bar"
L["NEW_QUEST_ITEM"] = "New Item That Starts A Quest Found!"
L["ITEM_USE_OPTIONS"] = "Item Use Options"
L["SHOW_ITEM_BAR"] = "Shows The ItemBar"
L["SHOW_ITEM_BAR_HELP"] = "Shows The EMA Item Use Bar"
L["ONLY_ON_MASTER"] = "Only On Master"
L["ONLY_ON_MASTER_HELP"] = "Only Shows On The Master Character"
L["SHOW_ITEM_COUNT"] = "Show Item Count"
L["SHOW_ITEM_COUNT_HELP"] = "Show ItemCount and ItemCount Tooltips \nOn EMA Item Use Bar"
L["KEEP_BARS_SYNCHRONIZED"] = "Keep Item Bars On Minions Synchronized"
L["KEEP_BARS_SYNCHRONIZED_HELP"] = "Keep Item Bars On Minions Synchronized"
L["ADD_QUEST_ITEMS_TO_BAR"] = "Automatically Add Quest Items To Bar"
L["ADD_QUEST_ITEMS_TO_BAR_HELP"] = "Automatically Adds Usable Quest Items To Bar"
L["ADD_ARTIFACT_ITEMS"] = "Automatically Add ArtifactPower Tokens To Bar"
L["ADD_ARTIFACT_ITEMS_HELP"] = "Automatically Add ArtifactPower Tokens To Bar (Legion)"
L["ADD_SATCHEL_ITEMS"] = "Automatically Add Satchel Items To Bar"
L["ADD_SATCHEL_ITEMS_HELP"] = "Automatically Add Satchel Items To Bar ( Lootable Bags/Boxes )"
L["HIDE_BUTTONS"] = "Hide Buttons"
L["HIDE_BUTTONS_HELP"] = "Hides The Top Buttons (Clear)"
L["HIDE_IN_COMBAT"] = "Hide In Combat" 
L["HIDE_IN_COMBAT_HELP_IU"] = "Hide Item Bar In Combat"
L["NUMBER_OF_ITEMS"] = "Number Of Items"
L["ITEM_BAR_CLEARED"] = "Item Bar Cleared"
L["TEAM_BAGS"] = "Items In Team Bags"
L["BAG_BANK"] = "Bag (Banks)"
L["QUEST_ITEM"] = "Quest Item"

--------------------------
-- Sell Locale
L["SELL"] = "Sell"
L["SELL_LIST"] = "Sell/Destroy/BlackList List"
L["SELL_ALL"] = "Sell or Destroy The Item \nIf On BlackList Will Not Sell"
L["ALT_SELL_ALL"] = "Hold [Alt] While Selling An Item, To Sell On All Toons"
L["ALT_SELL_ALL_HELP"] = "Hold [Alt] Key While Selling An Item To The Vendor, To Sell That Item On All Toons"
L["AUTO_SELL_ITEMS"] = "Automatically Sell Items"
L["AUTO_SELL_ITEMS_HELP"] = "Automatically Sell Items Below"
L["GLOBAL_SELL_LIST"] = "Global Sell List"
L["BLACKLIST_ITEM"] = "Black List"
L["BLACKLIST_ITEM_HELP"] = "EMA Can Not Sell This Item \ne.g.: Philosopher's Stones"
L["ONLY_SB"] = "Only SoulBound"
L["ONLY_SB_HELP"] = "Only Sell SoulBound Items"
L["iLVL"] = "Item Level"
L["iLVL_HELP"] = "Sell Items Below The Item Level"
L["SELL_GRAY"] = "|cff9d9d9d Sell Gray Items"
L["SELL_GRAY_HELP"] = "Sell All Gray Items"
L["SELL_GREEN"] = "|cff1eff00 Sell Uncommon Items"
L["SELL_GREEN_HELP"] = "Sell All Uncommon(Green) Items"
L["SELL_RARE"] = "|cff0070dd Sell Rare Items"
L["SELL_RARE_HELP"] = "Sell All Rare(Blue) Items"
L["SELL_EPIC"] = "|cffa335ee Sell Epic Items"
L["SELL_EPIC_HELP"]	= "Sell All Epic(Purple) Items"
L["AUTO_SELL_TOYS"] = "|cff00ccff Sell Already Known Toys"
L["AUTO_SELL_TOYS_HELP"] = "Sell Or Destroy Already Known SoulBound Toys"
L["AUTO_SELL_MOUNTS"] = "|cff00ccff Already Known Mounts"
L["AUTO_SELL_MOUNTS_HELP"] = "Sell Or Destroy Already Known SoulBound Mounts"
L["SELL_LIST_DROP_ITEM"] = "Sell Other Item (Shift+Click Item In Bag)"
L["ITEM_TAG_ERR"] = "Item Tags Must Only Be Made Up Of Letters And Numbers."
L["POPUP_REMOVE_ITEM"] = "Are You Sure You Wish To Remove The Selected Item From The Auto Sell: Items List?"
L["ADD_TO_LIST"] = "Adds Item To List"
L["SELL_ITEMS"] = "Sell Items"
L["POPUP_DELETE_ITEM"] = "Would you like to delete?"
L["ITEM_ON_BLACKLIST"] = "On Black List"
L["Destroy Item"] = "Destroy Item"
L["I_HAVE_SOLD_X"] = function( temLink )
	return string.format("I Have Sold: %s", temLink )
end
L["I_SOLD_ITEMS_PLUS_GOLD"] = function( count )
	return string.format( "I have sold: %s Items And Made: ", count )
end	
L["DELETE_ITEM"] = function( bagItemLink )
	return string.format( "I Have DELETED: %s", bagItemLink )
end

--------------------------
-- Interaction Locale
L["TAXI"] = "Taxi"
L["TAXI_OPTIONS"] = "Taxi Options"
L["TAKE_TEAMS_TAXI"] = "Take Team's Taxi"
L["TAKE_TEAMS_TAXI_HELP"] = "Take The Same Flight As Another Team Member \n(Other Team Members Must Have NPC Flight Master Window Open)."
L["REQUEST_TAXI_STOP"] = "Request Taxi Stop With Team"
L["REQUEST_TAXI_STOP_HELP"] = "Request Taxi Stop With Team"
L["CLONES_TO_TAKE_TAXI_AFTER"] = "Clones To Take Taxi After Leader"
--Mount Locale
L["MOUNT"] = "Mount"
L["MOUNT_OPTIONS"] = "Mount Options"
L["MOUNT_WITH_TEAM"] = "Mount With Team"
L["MOUNT_WITH_TEAM_HELP"] = "If a team member mounts, so do you"
L["DISMOUNT_WITH_TEAM"] = "Dismount With Team"
L["DISMOUNT_WITH_TEAM_HELP"] = "Dismount When Any Team Dismounts"
L["ONLY_DISMOUNT_WITH_MASTER"] = "Only Dismount's With Master"
L["ONLY_DISMOUNT_WITH_MASTER_HELP"] = "Only Dismount's When Master Character Dismounts"
L["ONLY_MOUNT_WHEN_IN_RANGE"] = "Only Mount When In Range"
L["ONLY_MOUNT_WHEN_IN_RANGE_HELP"] = "Dismounts Only When The Team Is In Range /nOnly Works In A Party!"
L["I_AM_UNABLE_TO_MOUNT"] = "I Am Unable To Mount."
L["MOUNT_HELP"] = "Command Teams To Summon A Random Favorite Mount"

-- Loot Locale
L["LOOT_OPTIONS"] = "Loot v2 Options"
L["DISMOUNT_WITH_CHARACTER"] = "Dismount With Character That Dismount"
L["ENABLE_AUTO_LOOT"] = "Enable Auto Loot"
L["ENABLE_AUTO_LOOT_HELP"] = "Old Advanced Loot \nBut Better \nWorks Better WITH Blizzard Auto Loot"
L["TELL_TEAM_BOE_RARE"] = "Tell Team BoE Rare"
L["TELL_TEAM_BOE_RARE_HELP"] = "Tell The Team If I Loot A BoE Rare"
L["TELL_TEAM_BOE_EPIC"] = "Tell Team BoE Epic"
L["TELL_TEAM_BOE_EPIC_HELP"] = "Tell The Team If I Loot A BoE Epic"
L["TELL_TEAM_BOE_MOUNT"] = "Tell Team Mount"
L["TELL_TEAM_BOE_MOUNT_HELP"] = "Tell The Team If I Loot A BoE Mount"
L["I_HAVE_LOOTED_X_Y_ITEM"] = function( rarity, itemName )
	return string.format( "I Have Looted A %q BoE Item: %s", rarity, itemName )
end
L["EPIC"] = "Epic"
L["RARE"] = "Rare"
L["REQUESTED_STOP_X"] = function( sender )
	return string.format( "I Have Requested A Taxi Stop From %s", sender )
end
L["I_AM_UNABLE_TO_FLY_TO_A"] = function( nodename )
	return string.format( "I Am Unable To Fly To %s.", nodename )
end
--------------------------
-- infomation Locale
L["EMA_CURRENCY"] = "Currency"
L["SHOW_CURRENCY"] = "Show Currency"
L["SHOW_CURRENCY_HELP"] = "Toggle The Currency Window Frame."
L["HIDE_CURRENCY"] = "Hide Currency"
L["HIDE_CURRENCY_HELP"] = "Hide The Currency Values For All Members In The Team."
L["CURRENCY_HEADER"] = "Currency Selection To Show On Frame"
L["BAG_SPACE"] = "Bag Space"
L["GOLD"] = "Gold"
L["GOLD_HELP"] = "Shows The Minion's Gold"
L["GOLD_GB"] = "Include Gold In Guild Bank"
L["GOLD_GB_HELP"] = "Show Gold In Guild Bank\n(This Does Not Update Unless You Visit The Guildbank)"
L["SHOW_BAG_SPACE"] = "Bag Space"
L["SHOW_BAG_SPACE_HELP"] = "Shows The Minion's Bag Space"
L["CURRENCY_CLASSIC"] = "Classic"
L["CURRENCY_CLASSIC_HELP"] = "Shows Anything Before Warlords Of Draenor Currencies"
L["CURRENCY_WOD"] = "Warlords Of Draenor"
L["CURRENCY_WOD_HELP"] = "Shows Warlords Of Draenor Currencies"
L["CURRENCY_LEGION"] = "Legion"
L["CURRENCY_LEGION_HELP"] = "Shows Legion Currencies"
L["CURRENCY_BFA"] = "Battle for Azeroth"
L["CURRENCY_BFA_HELP"] = "Battle for Azeroth Currencies"
L["CURRENCY_SHADOWLANDS"] = "Shadowlands"
L["CURRENCY_SHADOWLANDS_HELP"] = "Shadowlands Currencies"
L["CURR_STARTUP"] = "Open Currency List On Startup"
L["CURR_STARTUP_HELP"] = "Open Currency List On Startup On Everyone."
L["CURR_STARTUP_MASTER"] = "Only On Master"
L["CURR_STARTUP_MASTER_HELP"] = "Open Currency List On The Master Only"
L["LOCK_CURR_LIST"] = "Lock The Currency List Frame"
L["LOCK_CURR_LIST_HELP"] = "Locks The Currency List Frame And Enables Mouse Click-Through"
L["SPACE_FOR_NAME"] = "Space For Name"
L["SPACE_FOR_GOLD"] =  "Space For Gold"
L["SPACE_FOR_OTHER"] = "Space For Other"
L["SPACE_FOR_POINTS"] = "Space For Points"
L["SPACE_BETWEEN_VALUES"] = "Space Between Values"
L["TOTAL"] = "Total"
L["CURR"] = "Curr"
L["BAG_SPACE_HELP"] = "Shows The Characters Current Bag Space"
L["DURR"] = "Durability"
L["DURR_HELP"] = "Shows The Character Durability "
-- chat Triggers
L["CHAT_TRIGGER"] = "Chat !Triggers"
L["CHAT_TRIGGERS"] = "Listen to Chat Triggers"
L["CHAT_TRIGGERS_HELP"] = "Listen to !Triggers in \nParty/raid/guild to tell your team about things\n!emahelp"
L["NO_KEYSTONE_FOUND"] = "I Do Not Currently Have a Keystone"
L["I_HAVE_X_GOLD"] = function( gold )
	return string.format( "%s ", gold)
end
L["MY_KEY_STONE_IS"] = function( key )
	return string.format( "%s", key )
end
L["MY_LATENCY_IS:X_MS_X_MS"] = function( home, world )
	return string.format( "%s ms (Home) %s ms (World)", home, world )
end
L["MY_CURRENT_DURABILITY_IS"] = function (durabilityText)
	return string.format( "Durability %s", durabilityText )
end
L["ITEMCOUNT:_x_BAGS_BANK"] = function (item, countBags, countTotal)
	return string.format( "%s %s (Bags) %s (Bank)", item, countBags, (countTotal - countBags) )
end	
L["BAG_FREE_SPACE"] = function (numFreeSlots, numTotalSlots)
	return string.format( "%s (Free) / %s (Total)", numFreeSlots, numTotalSlots )
end	

--------------------------
-- Display Team Locale
L["EMA_TEAM"] = "EMA Team"
L["HIDE_TEAM_DISPLAY"] = "Hide Team Display"
L["HIDE_TEAM_DISPLAY_HELP"] = "Hide The Display Team Panel."
L["SHOW_TEAM_DISPLAY"] = "Show Team Display"
L["SHOW_TEAM_DISPLAY_HELP"] = "Show The Display Team Panel."
L["DISPLAY_HEADER"] = "Display Team Options"
L["SHOW"] = "Show"
L["SHOW_TEAM_FRAME"] = "Show Team Frame"
L["SHOW_TEAM_FRAME_HELP"] = "Show EMA Team Frame List"
L["HIDE_IN_COMBAT_HELP_DT"] = "Hides The TeamFrame In Combat"
L["ENABLE_CLIQUE"] = "Enable Clique Support"
L["ENABLE_CLIQUE_HELP"] = "Enable Clique Support\n([/Reload Ui] To Take Effect)"
L["SHOW_PARTY"] = "Only Show Party Members"
L["SHOW_PARTY_HELP"] = "Only Show Party Team Members"
L["HEALTH_POWER_GROUP"] = "Health & Power Out of Group"
L["HEALTH_POWER_GROUP_HELP"] = "Update Health and Power Out Of Groups\nUse Guild Communications!"
L["SHOW_TITLE"] = "Show Title on Frame"
L["SHOW_TITLE_HELP"] = "Show Team List Title on Display Team Frame"
L["STACK_VERTICALLY"] = "Stack Bars Vertically"
L["STACK_VERTICALLY_HELP"] = "Stack Display Team Frame Bars Vertically"
L["CHARACTERS_PER_BAR"] = "Number of Characters Per Row"
L["SHOW_CHARACTER_PORTRAIT"] = "Shows Characters Portraits"
L["FREEZE_PORTRAIT"] = "Freeze Portrait"
L["FREEZE_PORTRAIT_HELP"] = "Freeze Characters Portrait"
L["SHOW_FOLLOW_BAR"] = "Shows the Follow Bar and Character Name"
L["SHOW_NAME"] = "Show Character Name"
L["SHOW_XP_BAR"] = "Show the Team Experience Bar\n\nAnd Artifact XP Bar\nAnd Honor XP Bar\nAnd Reputation Bar"
L["VALUES"] = "Values"
L["VALUES_HELP"] = "Show Values"
L["PERCENTAGE"] = "Percentage"
L["PERCENTAGE_HELP"] = "Show Percentage"
L["SHOW_LEVEL"] = "Show Level"
L["SHOW_LEVEL_HELP"] = "Show level on experience bar"
L["SHOW_XP"] = "Experience Bar"
L["SHOW_XP_HELP"] = "Show the Team Experience bar"
L["ARTIFACT_BAR"] = "Artifact Bar"
L["ARTIFACT_BAR_HELP"] = "Show the Team Artifact Experience bar"
L["HONORXP"] = "Show Honor Bar"
L["HONORXP_HELP"] = "Show the Team Honor Experience Bar"
L["REPUTATION_BAR"] = "Show Reputation Bar"
L["REPUTATION_BAR_HELP"] = "Show the Team Reputation Bar" 
L["SHOW_HEALTH"] = "Show the Team's Health Bars"
L["SHOW_CLASS_COLORS"] = "Show Class Colors"
L["SHOW_CLASS_COLORS_HELP"] = "Show Class Colors on Health Bars"
L["POWER_HELP"] = "Show the Team Power Bar\n\nMana, Rage, Etc..."
L["CLASS_POWER"] = "Show the Teams Class Power Bar\n\nComboPoints\nSoulShards\nHoly Power\nDK Runes"
L["GCD_FRAME_HEADER"] = "Trufigcd Support"
L["GCD_FRAME"] = "Show A Trufigcd Bar On The Ema Team List\nNote:You Will Need The Trufigcd Addon Installed"
L["DEAD"] = "Dead"
L["PORTRAIT_HEADER"] = "Portrait"
L["FOLLOW_BAR_HEADER"] = "Follow Status Bar"
L["EXPERIENCE_HEADER"] = "Experience Bars"
L["HEALTH_BAR_HEADER"] = "Health Bar"
L["POWER_BAR_HEADER"] = "Power Bar"
L["CLASS_BAR_HEADER"] = "Class Power Bar"
L["CAN_NOT_FIND_TRUFIGCD_ADDON"] = "TrufiGCD Missing" 
L["NOT_SUPPORTED"] = "UnSupported"


--------------------------
-- Follow Locale
L["FOLLOW_BINDING_HEADER"] = "Follow Key Bindings"
L["FOLLOW_TRAIN"] = "Follow As A Train"
L["FOLLOW_STROBE_ME"] = "Follow Strobe Me"
L["FOLLOW_STROBE_OFF"] = "Follow Strobe Off"
L["FOLLOW_BROKEN_MSG"] = "Follow Broken!"
L["FOLLOW_MASTER"] = "Follow The Master <Group>"
L["FOLLOW_MASTER_HELP"] = "Follow The Master Current Master (Group)"
L["FOLLOW_TARGET"] = "Follow A Target <TargetName>"
L["FOLLOW_TARGET_HELP"] = "Follow The Specified Target (Group)"
L["FOLLOW_AFTER_COMBAT"] = "Auto Folllow After Combat"
L["FOLLOW_AFTER_COMBAT_HELP"] = "Automatically Follow After Combat"
L["DELAY_FOLLOW_AFTER_COMBAT"] = "Delay Follow After Combat (s)"
L["DELAY_FOLLOW_AFTER_COMBAT_HELP"] = "Delay Follow After Combat In Seconds"
L["FOLLOW_STROBING"] = "Begin Follow Strobing <TargetName>"
L["FOLLOW_STROBING_HELP"] = "Begin A Sequence Of Follow Commands That Strobe Every Second (Configurable) A Specified Target."
L["FOLLOW_STROBING_ME"] = "Begin Follow Strobing Me"
L["FOLLOW_STROBING_ME_HELP"] = "Begin A Sequence Of Follow Commands That Strobe Every Second (Configurable) This Character"
L["FOLLOW_STROBING_END"] = "Ends Follow Strobing"
L["FOLLOW_STROBING_END_HELP"] = "Ends Follow Strobing On All Characters" 
L["FOLLOW_SET_MASTER"] = "Sets Follow By Name"
L["FOLLOW_SET_MASTER_HELP"] = "Sets Follow By Name"
L["TRAIN"] = "Makes All Characters Follow In A Train"
L["FOLLOW_ME"] = "Follow Me"
L["FOLLOW_STOP"] = "Follow Stop" 
L["FOLLOW_STOP_HELP"] = "Sends A Command To The Minions To Stop Follow There Target"
L["TRAIN_HELP"] = "Makes All Characters Follow In A Train Behind Each Other"
L["FOLLOW_ME_HELP"] = "Follow Me <EMA Group>"
L["SNW"] = "Snw"
L["SNW_HELP"] = "Suppress Next Warning"
L["TIME_DELAY_FOLLOWING"] = "Seconds To Delay Before Following After Combat"
L["DIFFERENT_TOON_FOLLOW"] = "Use Different Character For Follow"
L["DIFFERENT_TOON_FOLLOW_HELP"] = "Use Different Character Below For Follow"
L["NEW_FOLLOW_MASTER"] = "New Follow Character"
L["FOLLOW_BROKEN_WARNING"] = "Follow Broken Warning"
L["WARN_STOP_FOLLOWING"] = "Warn If I Stop Following"
L["WARN_STOP_FOLLOWING_HELP"] = "Tell The Master If A Character Stops Following"
L["ONLY_IF_OUTSIDE_RANGE"] = "Only Warn If Outside Follow Range"
L["ONLY_IF_OUTSIDE_RANGE_HELP"] = "Only Warn If Character Is Outside Follow Range"
L["WRAN_IN_PVP_COMBAT"] = "Warn If In PvP Combat"
L["WRAN_IN_PVP_COMBAT_HELP"] = "Warns If A Team Member Is In PvP Combat"
L["FOLLOW_BROKEN_MESSAGE"] = "Follow Broken Custom Message"
L["DO_NOT_WARN"] = "Do Not Warn If"
L["IN_COMBAT"] = "In Combat"
L["ANY_MEMBER_IN_COMBAT"] = "Any Member In Combat"
L["FOLLOW_STROBING"] = "Follow Strobing"
L["FOLLOW_STROBING_EMA_FOLLOW_COMMANDS."] = "Follow Strobing Is Controlled By \"/ema Commands\" Or KeyBindings"
L["USE_MASTER_STROBE_TARGET"] = "Always Use Master As The Strobe Target"
--
L["PAUSE_FOLLOW_STROBING"] = "Pause Follow Strobing If ...."
L["DRINKING_EATING"] = "Drinking/Eating"
L["IN_A_VEHICLE"] = "In A Vehicle"
L["PLAYER_DEAD"] = "Dead Or Ghost"
--
L["GROUP_FOLLOW_STROBE"] = "Group For Follow Strobe"
L["FREQUENCY"] = "Frequency (s)"
L["FREQUENCY_COMABT"] = "Frequency In Combat (s)"
L["ON"] = "On"
L["OFF"] = "Off"
L["DRINK"] = "Drink"
L["FOOD"] = "Food"
L["REFRESHMENT"] = "Refreshment"
L["PVP_FOLLOW_ERR"] = "Can Not Follow You, I Am Engaged In PvP Combat"

--------------------------
-- Vendor/Purchase Locale.
L["AUTO_BUY_ITEMS"] = "Auto Buy Items"
L["OVERFLOW"] = "Overflow"
L["REMOVE_VENDOR_LIST"] = "Remove From Vendor List"
L["ITEM_DROP"] = "Item (Shift+Click Item In Bag)"
L["PURCHASE_ITEMS"] = "Auto Purchase Items"
L["ADD_ITEM"] = "Add Item"
L["AMOUNT"] = "Amount"
L["PURCHASE_MSG"] = "Purchase Messages"
L["ITEM_ERROR"] = "Item Tags Must Only Be Made Up Of Letters And Numbers."
L["NUM_ERROR"] = "Amount To Buy Must Be A Number."
L["BUY_POPUP_ACCEPT"] = "Are You Sure You Wish To Remove The Selected Item From The Auto Buy Items List?"
L["ERROR_BAGS_FULL"] =  "I Do Not Have Enough Space In My Bags To Complete My Purchases."
L["ERROR_GOLD"] = "I Do Not Have Enough Money To Complete My Purchases." 
L["ERROR_CURR"] = "I Do Not Have Enough Other Currency To Complete My Purchases."

--------------------------
-- Trade Locale
L["REMOVE_TRADE_LIST"] = "Are You Sure You Wish To Remove The Selected Item From The Trade Items List?"
L["TRADE_LIST_HEADER"] = "Trade Item List"
L["TRADE_LIST"] = "Trade Items"
L["GLOBAL_TRADE_LIST"] = "Global Trade List"
L["TRADE_LIST_HELP"] = "Trade Items With The Selected EMA-Group Member"
L["TRADE_BOE_ITEMS"] = "Trades Binds When Equipped Items With:"
L["TRADE_BOE_ITEMS_HELP"] = "Trade All Binds When Equipped Items with EMA Groups"
L["TRADE_REAGENTS"] = "Trades Crafting Reagents Items With:"
L["TRADE_REAGENTS_HELP"] = "Trades All Crafting Reagent Items with EMA Groups"
L["TRADE_RECIPE_FORMULA"] = "Trades Recipe Items WIth:"
L["TRADE_RECIPE_FORMULA_HELP"] = "Trades All Recipe/Patterns/BulePrints Items with EMA Groups"
L["TRADE_OPTIONS"] = "Trade To Options"
L["TRADE_GOLD"] = "Trade Excess Gold To Master From Minion"
L["TRADE_GOLD_HELP"] = "Trade Excess Gold To Master From Minions \nAlways Be Careful When Auto Trading."
L["GOLD_TO_KEEP"] = "Amount of Gold To Keep:"
L["TRADE_TAG_ERR"] = "Item Tags Must Only Be Made Up Of Letters And Numbers."
L["ERR_WILL_NOT_TRADE"] = "Is Not A Member Of The Team, Will Not Trade Items."
L["ADD_ITEMS"] = "Add Items"

--------------------------
-- Toon Locale
L["ATTACKED"] = "I'm Attacked!"
L["TARGETING"] = "Not Targeting!"
L["FOCUS"] = "Not Focus!"
L["LOW_HEALTH"] = "Low Health!"
L["LOW_MANA"] = "Low Mana!"
L["BAGS_FULL"] = "Bags Full!"
L["CCED"] = "I've Been"
-- Vendor
L["AUTO_REPAIR"] = "Auto Repair"
L["AUTO_REPAIR_HELP"] = "Auto Repairs Toon's Items When You Visit a Repair Merchant"
L["REPAIR_GUILD_FUNDS"] = "Auto Repair With Guild Funds"
L["REPAIR_GUILD_FUNDS_HELP"] = "Tries To Auto Repair With Guild Bank Funds \nBefore Their Own Gold"
-- Requests
L["REQUESTS"] = "Requests"
L["DENY_DUELS"] = "Auto Deny Duels"
L["DENY_DUELS_HELP"] = "Automatically Deny Duels From Players \nOn All Team Members"
L["DENY_GUILD_INVITES"] = "Auto Deny Guild Invites"
L["DENY_GUILD_INVITES_HELP"] = "Automatically Deny All Guild Invites"
L["ACCEPT_RESURRECT"] = "Auto Accept Resurrect Request"
L["ACCEPT_RESURRECT_AUTO"] = "Automatically Accept Resurrect Request \nOn All Team Members"
L["ACCEPT_RESURRECT_FROM_TEAM"] = "Only From EMA Team Members"
L["ACCEPT_RESURRECT_FROM_TEAM_HELP"] = "Automatically Accept Resurrect Request \nOn All Team Members\nOnly From Team Members"
L["RELEASE_PROMPTS"] = "Display Team Release Prompts"
L["RELEASE_PROMPTS_HELP"] = "Display EMA Team Release Popup Displays when the Team Dies"
L["SUMMON_REQUEST"] = "Auto Accept Summon Request"
L["SUMMON_REQUEST_HELP"] = "Automatically Accept Summon Requests"
L["GROUPTOOLS_HEADING"] = "Instance Tools"
L["ROLE_CHECKS"] = "Auto Accept Role Checks" 
L["ROLE_CHECKS_HELP"] = "Automatically Accept Role Checks \n\nIf A Role Is Already Set.."
L["READY_CHECKS"] = "Accept Ready Checks With Team"
L["READY_CHECKS_HELP"] = "Accept Ready Checks With Team \n\nIf Team Member Is The One That Does The Ready Check It Is Auto."
L["LFG_Teleport"] = "Instance Teleport With Team"
L["LFG_Teleport_HELP"] = "Minions Will Copy The Teams Instance Telport"
L["ROLL_LOOT"] = "Roll Loot With Team"
L["ROLL_LOOT_HELP"] = "Roll Loot With the Team \nIf Any Instance Has A Roll On A Item"
L["WAR_MODE"] = "Toggle WarMode With Team"
L["WAR_MODE_HELP"] = "Toggle WarMode \"World PvP\" With The Team"
L["PARTY_SYNC"] = "Auto Accept Party Sync Requests"
L["PARTY_SYNC_HELP"] = "Team Members Auto Accept Party Sync Requests"
-- Warnings
L["COMBAT"] = "Combat"
L["WARN_HIT"] = "Warn If Minion Gets Hit"
L["WARN_HIT_HELP"] = "Warn If Hit First Time In Combat (Minion)"
L["TARGET_NOT_MASTER"] = "Warn If Target Not Master"
L["TARGET_NOT_MASTER_HELP"] = "Warn If Target Not Master On Combat (Minion)"
L["FOCUS_NOT_MASTER"] = "Warn If Focus Not Master"
L["FOCUS_NOT_MASTER_HELP"] = "Warn If Focus Not Master On Combat (Minion)"
L["HEALTH_POWER"] = "Health / Mana"
L["HEALTH_DROPS_BELOW"] = "Warn If My Health Drops Below"
L["HEALTH_DROPS_BELOW_HELP"] = "Warn Master If Health Drops Below A Certain Percent"
L["HEALTH_PERCENTAGE"] = "Health Amount - Percentage Allowed Before Warning"
L["MANA_DROPS_BELOW"] = "Warn If My Mana Drops Below"
L["MANA_DROPS_BELOW_HELP"] = "Warn Master If Mana Drops Below A Certain Percent"
L["MANA_PERCENTAGE"] = "Mana Amount - Percentage Allowed Before Warning"
L["DURABILITY_DROPS_BELOW"] = "Durability Drops Below"
L["DURABILITY_DROPS_BELOW_HELP"] = "Warn Master If My Durability Drops Below A Certain Percent"
L["DURABILITY_PERCENTAGE"] = "Warn If My Durability Drops Below"
L["LOW_DURABILITY_TEXT"] = "Low Durability Text"
L["DURABILITY_LOW_MSG"] = "I Have My Durability At"
L["BAG_SLOTS_HELP"] = "Empty Bags Slots Allowed Before Warning"
L["BAGS_ALMOST_FULL"] = "Bags Are Almost Full"
L["BAGS_FULL"] = "Warn If Bags Are Full"
L["BAGS_FULL_HELP"] = "Warn If All Regular Bags Are Full"
L["BAG_SPACE"] = "Bag Space"
L["OTHER"] = "Other"
L["WARN_IF_CC"] = "Warn If Toon Gets Crowd Controlled"
L["WARN_IF_CC_HELP"] = "Warn If Any Team Member Gets Crowd Controlled"
L["RELEASE_TEAM_Q"] = "Release All Team?"
L["RELEASE_TEAM"] = "Release Team"
L["RECOVER_CORPSES"] = "Recover All Team Corpses?"
L["ERR_GOLD_TO_REPAIR"] = "I Do Not Have Enough Money To Repair All My Items"
--Set View
L["SET_VIEW_HEADER"] = "Set View Settings" 
L["SET_VIEW"] = "Set View" 
L["SET_VIEW_HELP"] = "Set View Team View" 
L["SET_VIEW_WITHOUT_MASTER"] = "Set View Without Master"
L["SET_VIEW_WITHOUT_MASTER_HELP"] = "Set View Without The Master"


L["RELEASE_CORPSE_FOR_X"] = function( delay )
	return string.format( "I can not release to my Corpse for: %s seconds", delay )
end
L["I_REFUSED_A_DUEL_FROM_X"] = function( challenger )
	return string.format( "I Refused A Duel From: %s", challenger )
end
L["REFUSED_GUILD_INVITE"] = function( guild, inviter )
	return string.format( "I Refused A Guild Invite To: %s From: %s", guild, inviter )
end
L["SUMMON_FROM_X_TO_Y"] = function( sender, location )
	return string.format( "I Accepted Summon From: %s To: %s", sender, location )
end
L["REPAIRING_COST_ME_X"] = function( costString )
    return string.format( "Repairing Cost Me: %s", costString )
end
L["ERR_WARMODE"] = function( text )
    return string.format( "|cFFFF0000 WarMode: %s", text )
end

--------------------------
-- Talk Locale

L["TALK_OPTIONS"] = "Talk Options"
L["FORWARD_WHISPERS_MASTER_RELAY"] = "Forward Whispers To Master And Relay Back"
L["FORWARD_WHISPERS_MASTER_RELAY_HELP"] = "Forward Whispers To Master And \nRelay Back To The Character That Whispered You"
L["DO_NOT_BATTENET_WHISPERS"] = "Do Not Forward Battle.Net Whispers"
L["DO_NOT_BATTENET_WHISPERS_HELP"] = "Do Not Forward BatteTag Or RealID Whispers"
L["FORWARD_FAKE_WHISPERS"] = "Forward Via Fake Whispers For Clickable Links And Players"
L["FORWARD_FAKE_WHISPERS_HELP"] = "Forward Via Fake Whispers To Use As Clickable Links And Players"
L["FAKE_WHISPERS_CHANNEL"]  = "Send Fake Whispers To"
L["FORWARDER_REPLY_QUEUE"] = "Add Forwarder To Reply Queue On Master"
L["FORWARDER_REPLY_QUEUE_HELP"] = "Add Forwarder To Reply Queue On Master"
L["ORIGINATOR_REPLY_QUEUE"] = "Add Originator To Reply Queue On Master"
L["ORIGINATOR_REPLY_QUEUE_HELP"] = "Add Originator To Reply Queue On Master" 
L["MESSAGES_WITH_LINKS"] = "Only Show Messages With Links"
L["MESSAGES_WITH_LINKS_HELP"] = "Only Show Messages With Links"
-- TOBEREMOVED
L["CHAT_SNIPPETS"] = "Chat Snippets"
L["ENABLE_CHAT_SNIPPETS"] = "Enable Chat Snippets"
L["ENABLE_CHAT_SNIPPETS_HELP"] = "Chat Snippets Auto Send Messages To Players That Wispers Your Minions"
L["SNIPPET_TEXT"] = "Snippet Text"
L["CHAT_SNIPPET_POPUP"] = "Enter The Shortcut Text For This Chat Snippet:"
L["REMOVE_CHAT_SNIPPET"] = "Are You Sure You Wish To Remove The Selected Chat Snippet?"
--END
L["GM"] = "GM"
L["TALK_VIA"] = " (via "
L["BATTLE_NET"] = "<BatteTag>"
L["<GM>"] = "<GameMaster>"
L["WHISPERS"] = " Whispers: "
L["WHISPERED_YOU"] = "Whispered You."

------------------------
-- Quest Locale
L["ABANDON_QUESTS_TEAM"] = "Would you like to Abandon \"%s\" On All Toons?"
L["JUST_ME"] = "Just Me"
L["ALL_TEAM"] = "All Team"
L["TRACK_QUEST_ON_TEAM"] = "Would you like to Track \"%s\" On All Toons?"
L["UNTRACK_QUEST_ON_TEAM"] = "Would you like to Untrack \"%s\" On All Toons?"
L["ABANDON_ALL_QUESTS"] = "This Will Abandon \"ALL\" Quests On Every Toon! \nYes, This Means You Will End Up With ZERO Quests In Your Quest Log! \nAre You Sure?"
L["YES_IAM_SURE"] = "Yes I'm Sure"
L["INFORMATION"] = "Information"
L["QUESTINFORMATIONONE"] = "Quest Treats Any Team member as the Master."
L["QUESTINFORMATIONTWO"] = "Quest actions by one character will be actioned by the other"
L["QUESTINFORMATIONTHREE"] = "Characters Regardless Of Who The Master Is."
L["QUEST_HEADER"] = "Toon Select & Decline Quest With Team"
L["MIRROR_QUEST"] = "Quest Selection & Acceptance"
L["MIRROR_QUEST_HELP"] = "Mirror Quest Selection With All Team"
L["AUTO_SELECT_QUESTS"] = "All Auto Select Quests"
L["AUTO_SELECT_QUESTS_HELP"] = "Automatically Pick Up Quest \nWhen You Talk To A Quest Giving NPC"
L["ACCEPT_QUESTS"] = "Accept Quests"
L["ACCEPT_QUESTS_HELP"] = "Accept Quests"
L["ACCEPT_QUEST_WITH_TEAM"] = "Accept Quest With Team"
L["ACCEPT_QUEST_WITH_TEAM_HELP"] = "Accept Quest With Team Members"
L["QUEST_INFORMATION_AUTO"] = "Automatically: Accept Quests Regardless of the Team Selection"
L["DONOT_AUTO_ACCEPT_QUESTS"] = "Do Not Auto Accept Quests" 
L["DONOT_AUTO_ACCEPT_QUESTS_HELP"] = "Never Auto Accept Quests From Anyone"
L["AUTO_ACCEPT_QUESTS"] = "All Auto Accept ANY Quest"
L["AUTO_ACCEPT_QUESTS_HELP"] = "All Auto Accept ANY Quest From Anyone"
L["AUTO_ACCEPT_QUESTS_LIST"] = "Only Auto Accept Quests From:"
L["AUTO_ACCEPT_QUESTS_LIST_HELP"] = "Only Auto Accept Quests From The Following  List"
L["TEAM_QUEST_HELP"] = "Any EMA Team Member"
L["NPC"] = "NPC"
L["NPC_HELP"] = "Any Non-Player Character"
L["FRIENDS"] = "Friends"
L["FRIENDS_HELP"] = "Anyone On Your Friends List Or BattleTag Friends List"
-- Quest
L["QUEST_GROUP_HELP"] = "Anyone In Your Party Group"
L["GUILD_HELP"] = "Anyone In Your Guild"
L["PH_RAID"] = "[PH] Raid" 
L["PH_RAID_HELP"] = "[PH] Raid" 
L["MASTER_SHARE_QUESTS"] = "Master Auto Share Quests When Accepted"
L["MASTER_SHARE_QUESTS_HELP"] = "Master Will Try And Share Quests When Accepted"
L["ACCEPT_ESCORT_QUEST"] = "Toon Auto Accept Escort Quest From Team"
L["ACCEPT_ESCORT_QUEST_HELP"] = "Automatically Accept Escort Quests When A Team Picks One Up"
L["HOLD_SHIFT_TO_OVERRIDE"] = "Hold Shift To Override Auto Select/Auto Complete"
L["HOLD_SHIFT_TO_OVERRIDE_HELP"] = "Hold Shift Key To Override Auto Select/Auto Complete"
L["SHOW_PANEL_UNDER_QUESTLOG"] = "Show Extra Buttons Panel Under WorldMap Quest Log"
L["SHOW_PANEL_UNDER_QUESTLOG_HELP"] = "Show Extra Buttons Panel Under World Map Quest Log \ne.g.: TrackAll"
-- Completion
L["QUEST_COMPLETION"] = "Quest Completion"
L["ENABLE_QUEST_COMPLETION"] = "Enable Auto Quest Completion"
L["ENABLE_QUEST_COMPLETION_HELP"] = "Enable Automatically Handing In Quests"
L["NOREWARDS_OR_ONEREWARD"] = "Quest Has No Rewards Or One Reward:"
L["QUEST_DO_NOTHING"] = "Toon Do Nothing"
L["QUEST_DO_NOTHING_HELP"] = "Do Not Automatically Hand In Quest"
L["COMPLETE_QUEST_WITH_TEAM"] = "Toon Complete Quest With Team"
L["COMPLETE_QUEST_WITH_TEAM_HELP"] = "Complete Quest With Team EMA Members"
L["AUTO_COMPLETE_QUEST"] = "Automatically Complete Quest"
L["AUTO_COMPLETE_QUEST_HELP"] = "Automatically Complete/Turn In The Quest"
L["MORE_THEN_ONE_REWARD"] = "Quest Has More Than One Reward:"
L["MUST_CHOOSE_OWN_REWARD"] = "Toon Must Choose Own Reward"
L["MUST_CHOOSE_OWN_REWARD_HELP"] = "Toon Must Select Own Quest Reward"
L["CHOOSE_SAME_REWARD"] = "Toon Choose Same Reward As Team"
L["CHOOSE_SAME_REWARD_HELP"] = "Toon Will Choose Same Reward As EMA Team Members \n\nOnly Use If All Team Members Class"
L["CHOOSE_BEST_REWARD"] = "Choose Best Quest Reward"
L["CHOOSE_BEST_REWARD_HELP"] = "Try & Choose Best Quest Reward\nCan i use it < better in slot < If not best sell price!"
L["MODIFIER_CHOOSE_SAME_REWARD"] = "If Modifier Keys Pressed, Toon Choose Same Reward"
L["MODIFIER_CHOOSE_SAME_REWARD_HELP"] = "If Modifier Key Below Is Pressed, Minion Can Choose Same Reward"
L["OVERRIDE_REWARD_SELECTED"] = "Override: If Minion Already Has Reward Selected, Choose That Reward"
L["OVERRIDE_REWARD_SELECTED_HELP"] = "Override: If Minion Already Has Reward Selected, Choose That Reward \nAnd Not Use The Current Toon's Reward"
L["SHARING_QUEST_TO_ALLMINIONS"] = "Sharing Quests To All Minions"
L["TRACKING_QUEST_TO_ALLMINIONS"] = "Tracking Quests To All Minions"
L["UNTRACKING_QUESTS_ALLMINIONS"] = "Untracking Quests To All Minions"
L["TOGGLE"] = "Toggle"
L["TRACK_SINGLE_QUEST"] = "Track Selected"
L["TRACK_SINGLE_QUEST_TOOLTIP"] = "Track The Selected Quest"
L["UNTRACK_SINGLE_QUEST"] = "UnTrack Selected"
L["UNTRACK_SINGLE_QUEST_TOOLTIP"] = "UnTrack The Selected Quest"
L["ABANDON_ALL"] = "Abandon All Quests"
L["ABANDON_ALL_TOOLTIP"] = "Aabandon All Quests On All Minions"
L["SHARE_ALL"] = "Share All"
L["SHARE_ALL_TOOLTIP"] = "Share All Quests To All Minions"
L["TRACK_ALL"] = "Track All"
L["TRACK_ALL_TOOLTIP"] = "Track All Quests On All Minions"
L["UNTRACK_ALL"] = "Untrack All"
L["UNTRACK_ALL_TOOLTIP"] = "Untrack All Quests on all Minions"
L["ABANDONING_ALLQUEST"] = "Abandoning Quests To All Toons"
L["AM_I_TALKING_TO_A_NPC"] = "Am I Talking To A NPC"

-- Quest Strings
L["AUTOMATICALLY_ACCEPTED_ESCORT_QUEST"] = function( questName )
	return string.format( "Automatically Accepted Escort Quest: %s", questName )
end
L["INVENTORY_IS_FULL_CAN_NOT_HAND_IN_QUEST"] = function( questName )
	return string.format( "Inventory Is Full Can Not Hand In Quest: %s", questName )
end
L["ACCEPTED_QUEST_QN"] = function( questName )
	return string.format( "Accepted Quest: %s", questName )
end
L["AUTO_ACCEPTED_PICKUPQUEST_QN"] = function( questName )
	return string.format( "Automatically Accepted PickupQuest: %s", questName )
end
L["AUTOMATICALLY_ACCEPTED_QUEST"] = function( questName )
	return string.format( "Automatically Accepted Quest: %s", questName )
end
L["QUESTLOG_DO_NOT_HAVE_QUEST"] = function( questName )
	return string.format( "I Do Not Have The Quest: %s", questName )
end
L["QUESTLOG_HAVE_ABANDONED_QUEST"] = function( questName )
	return string.format( "I Have Abandoned The Quest: %s", questName )
end

------------------------
-- QuestTracker Locale
L["SHOW_QUEST_WATCHER"] = "Show Objective Tracker"
L["SHOW_QUEST_WATCHER_HELP"] = "Show The Objective/Quest EMA Tracker Window."
L["HIDE_QUEST_WATCHER"] = "Hide Objective Tracker"
L["HIDE_QUEST_WATCHER_HELP"] = "Hides The Objective/Quest EMA Tracker Window."
L["QUEST_TRACKER_HEADER"] = "Quest Tracker Settings"
L["ENABLE_TRACKER"] = "Enable Objective Tracker"
L["ENABLE_TRACKER_HELP"] = "Enables The EMA Objective/Quest Tracker"
L["UNLOCK_TRACKER"] = "Disable Click-Through"
L["UNLOCK_TRACKER_HELP"] = "Disable Click-Through on the The Objective/Quest Tracker"
L["HIDE_BLIZZ_OBJ_TRACKER"] = "Hide Blizzard's Objectives Tracker" 
L["HIDE_BLIZZ_OBJ_TRACKER_HELP"] = "Hides Default Blizzard Objective\Quest Tracker"
L["SHOW_JOT_ON_MASTER"] = "Show The EMA Objective Tracker On Master Toon"
L["SHOW_JOT_ON_MASTER_HELP"] = "Only show EMA Objective Tracker On Master Character Only"
L["HIDE_JOT_IN_COMBAT"] = "Hide EMA Objective/Quest Tracker In Combat"
L["HIDE_JOT_IN_COMBAT_HELP"] = "Hide EMA Objective/Quest Tracker in Combat"
L["SHOW_COMPLETED_OBJ_DONE"] = "Show Completed Objectives As 'DONE'"
L["SHOW_COMPLETED_OBJ_DONE_HELP"] = "Show Completed Objectives/Quests As 'DONE'"
L["HIDE_OBJ_COMPLETED"] = "Hide Objectives Completed"
L["HIDE_OBJ_COMPLETED_HELP"] = "Hide Objectives/Quests Completed By The Team"
L["SEND_PROGRESS_MESSAGES"] = "Send Progress Messages"
L["SEND_PROGRESS_MESSAGES_HELP"] = "Send Progress Messages To Message Area Box Below"
L["QUESTWACHERINFORMATIONONE"] = "You Will Need To Do UI [/reload] To Change Lines And Width"
L["LINES_TO_DISPLAY"] = "Lines Of Information To Display"
L["TRACKER_WIDTH"] = "Tracker Width"
L["DONE"] = "Done"
L["TRACKER_TITLE_NAME"] = "EMA Objectives Tracker"
L["REWARDS"] = "Rewards"
L["REWARDS_TEXT"] = "Completing This Quest Will \nReward You With:"
L["HEADER_MOUSE_OVER_QUESTWATCHER"] = "Hold Down \"ALT\" Key To Move EMA Objectives Tracker"
L["UPDATE_MOUSE_OVER_QUESTWATCHER"] = "Force A Update Of The EMA Objectives Tracker"

------------------------
-- Guild Locale
L["GUILDTAB"] = ""
L["GUILD_LIST_HEADER"] = "Guild Bank List"
L["GUILD_LIST"] = "Put The Items In The Guild Bank"
L["GUILD_LIST_HELP"] = "Automatically Put Listed Items Below In The Guild Bank"
L["GB_TAB_LIST"] = "Guild Bank Number Tab"
L["GUILD_BOE_ITEMS"] = "Places All BoE Items In:" 
L["GUILD_BOE_ITEMS_HELP"] = "Places All Binds When Equipped Items In The GuildBank"
L["GUILD_REAGENTS"] =  "Places All Reagents In:"
L["GUILD_REAGENTS_HELP"] = "Places All Crafting Reagents Items In The GuildBank"
L["GB_OPTIONS"] = "Guild Bank Options"
L["GB_GOLD"] = "Adjust Characters Money While Visiting A Guild Bank"
L["GB_GOLD_HELP"] = "Adjust Characters Money While Visiting A Guild Bank"
L["REMOVE_GUILD_LIST"] = "Are You Sure You Wish To Remove The Selected Item From The Guild Items List?"
L["I_HAVE_DEPOSITED_X_TO_GB"] = function( gold )
	return string.format("Deposited %s To The Guild Bank", gold )
end


-----------------------
-- Mail Locale
L["REMOVE_MAIL_LIST"] = "Are You Sure You Wish To Remove The Selected Item From The Mail Items List?"
L["MAIL_LIST_HEADER"] = "Mail Sending List"
L["MAIL_LIST"] = "Send Mail To The Selected Character"
L["MAIL_LIST_HELP"] = "Send Mail To The Selected Character"
L["MAILTOON"] = "Send Mail To:"
L["MAIL_BOE_ITEMS"] = "Mail All BoE Items To:"
L["MAIL_BOE_ITEMS_HELP"] = "Mail All BoE Items To The Selected Character"
L["MAIL_REAGENTS"] = "Mail All Reagents To:"
L["MAIL_REAGENTS_HELP"] = "Mails All Crafting Reagents Items To The Selected Character"
L["MAIL_RECIPES"] = "Mails Recipe Items To:"
L["MAIL_RECIPES_HELP"] = "Mails All Recipe/Patterns/BulePrints To The Selected Character"
L["MAIL_GOLD"] = "Adjust Characters Money While Visiting A Mail Box"
L["MAIL_GOLD_HELP"] = "Adjust Characters Money While Visiting A Mail Box"
L["SENT_AUTO_MAILER"] = "Sent By EMA Auto Mailer" 
L["Mail_OPTIONS"] = "Mail Options"
L["MAIL_GOLD_OPTIONS"]  = "Mail Gold Options"

L["SENT_AUTO_MAILER_GOLD"] = function( gold )
	return string.format("EMA Auto Gold Mailer: %s", gold )
end


-----------------------
-- Bank Locale
L["BANK"] = "Bank"
L["REMOVE_BANK_LIST"] = "Are You Sure You Wish To Remove The Selected Item From The Bank Items List?"
L["BANK_LIST_HEADER"] = "Bank Items List" 
L["BANK_LIST"] = "Put The Items In The Bank"
L["BANK_LIST_HELP"] = "Automatically Put Listed Items Below In The Bank"
L["BANK_BOE_ITEMS"] = "Places All BoE Items In The Bank" 
L["BANK_BOE_ITEMS_HELP"] = "Places All Binds When Equipped Items In The Bank"
L["BANK_REAGENTS"] = "Places All Reagents In Bank"
L["BANK_REAGENTS_HELP"] = "Places All Crafting Reagents Items In The Bank"
L["BANK_OPTIONS"] = "Extra Bank Options"

-----------------------
-- LDBBar Locale
L["LDBBAR_LEFT_CLICK"] = "Left Click"
L["LDBBAR_MIDDLE_CLICK"] = "Middle Click"
L["LDBBAR_RIGHT_CLICK"] = "Right Click"
L["LDBBAR_CONFIG"] = "To Open Main Config"
L["LDBBAR_CONFIG_TEAM"] = "To Open Team Settings"
L["LDBBAR_PUSH"] = "To Push All Settings"

-----------------------
-- Macro Local
local ema_macro_tail = "_EMA_AUTO"
L["MACRO_TAIL"] = ema_macro_tail -- Don't change this one, used to identify EMA macros

L["MACRO_TITLE"] = "Duplicate Macros"
L["SELECT_MACRO_TITLE"] = "Select macro to edit and clone" 
L["LOAD_MACRO_BUTTON"] = "Load macros"
L["LOAD_MACRO_BUTTON_HELP"] = "Get current character macros"
L["MACRO_NAME_AREA"] = "Macro name"
L["MACRO_BODY"] = "Macro content"
L["DELETE_MACROS"] = "Delete ALL EMA macros"
L["SEND_MACRO_ALL_CHARACTERS"] = "Send to all characters"
L["SEND_MACRO"] = "Send to character"
L["LOCAL_MACRO"] = "Local Macro ?"
L["LOCAL_MACRO_HELP"] = "If not local, it's global"
L["DELETE_MACROS_HELP"] = "It will delete all macros ending with " .. ema_macro_tail .. " on all your characters"

-----------------------
-- X Locale