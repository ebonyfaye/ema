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

local L = LibStub("AceLocale-3.0"):NewLocale( "Core", "deDE")
if not L then 
	return 
end
-- NewLocales

--PreCoded ALL
L["JAMBA"] = "Jamba"
L["JAMBA EE"] = "Jamba EE"

L["EMA"] = "EMA"
L[""] = true
L[" "] = true
L[": "] = true
L["("] = true
L[")"] = true
L[" / "] = true
L["/"] = true
L["%"] = true
L["N/A"] = true
L["PUSH_SETTINGS"] = "Teile Einstellungen"
L["PUSH_ALL_SETTINGS"] = "Teile Alle Einstellungen"
L["PUSH_SETTINGS_INFO"] = "Teile Einstellungen mit Team Mitgliedern" 
L["MINION"] = "Minion"
L["NAME"] = "Name"
L["MASTER"] = "Master"
L["ALL"] = "All"
L["MESSAGES_HEADER"] = "Nachricht"
L["MESSAGE_AREA"]  = "Nachrichten Region"
L["SEND_WARNING_AREA"] = "Warnungs Region"
L["PH"] = "PH"
L["GUILD"] = "Gilde"
L["CTRL"] = "Strg"
L["SHIFT"] = "Shift"
L["ALT"] = "Alt"
L["UPDATE"] = "Update"


-- Display Options
L["APPEARANCE_LAYOUT_HEALDER"] = "Aussehen und Anordnung"
L["BLIZZARD"] = "Blizzard"
L["BLIZZARD_TOOLTIP"] = "Blizzard Tooltip"
L["BLIZZARD_DIALOG_BACKGROUND"] = "Blizzard Dialog Hintergrund"
L["ARIAL_NARROW"] = "Arial Narrow"
L["NUMBER_OF_ROWS"] = "Anzahl der Reihen"
L["SCALE"] = "Skalierung"
L["TRANSPARENCY"] = "Transparenz"
L["BORDER_STYLE"] = "Rahmen Style" 
L["BORDER COLOUR"] = "Rahmen Farbe"
L["BACKGROUND"] = "Hintergrund"
L["BG_COLOUR"] = "Hintergrundfarbe"
L["FONT"] = "Schriftart"
L["FONT_SIZE"] = "Schriftart Größe"
L["BAR_TEXTURES"] = "Statusbalken Textur"
L["WIDTH"] = "Breite"
L["HEIGHT"] = "Höhe"

-- Numbers
L["1"] = "Eins"
L["2"] = "Zwei"
L["3"] = "Drei"
L["4"] = "Vier"
L["5"] = "Fünf"
L["6"] = "Sechs"
L["7"] = "Sieben"
L["8"] = "Acht"
L["9"] = "Neun"
L["10"] = "Zehn"
L["11"] = "Elf"
L["12"] = "Zwölf"
L["13"] = "Dreizehn"
L["14"] = "Vierzehn"
L["15"] = "Fünfzehn"
L["16"] = "Sechzehn"
L["17"] = "Siebenzehn"
L["18"] = "Achtzehn"
L["19"] = "Neunzehn"
L["20"] = "Zwanzig"

--------------------------
-- Modules Locale
L["NEWS"] = "Neuigkeiten"
L["OPTIONS"] = "Optionen"
L["SETUP"] = "Aufbau" 
L["PROFILES"] = "Profiles"
L["TEAM"] = "Team"
L["COMMUNICATIONS"] = "Kommunikationen"
L["MESSAGE_DISPLAY"] = "Nachrichten Anzeige"
L["GROUP_LIST"] = "Kategorien Liste"
L["DISPLAY"] = "Anzeigen"
L["ITEM_USE"] = "Gegenstände"
L["VENDER_LIST_MODULE"] = "Verkaufen"
L["INTERACTION"] = "Interaktionen"
L["CURRENCY"] = "Währungen"
L["TOON"] = "Toon"
L["FOLLOW"] = "Folgen"
L["PURCHASE"] = "Kaufen"
-- FUCKED UP!
L["VENDER"] = "Händler"
L["VENDOR"] = "Verkaufen"
L["PURCHASE"] = "Kaufen"
L["WARNINGS"] = "Warnungen"
L["QUEST"] = "Quest"
L["TRADE"] = "Handeln"
L["REPAIR"] = "Reparieren"
L["TALK"] = "Unterhaltungen"
L["QUEST"] = "Quest" 
L["COMPLETION"] = "Abschluss"
L["TRACKER"] = "Anzeige"

--------------------------
-- Pecoded String Formats
L["SETTINGS_RECEIVED_FROM_A"] = function( characterName )
	return string.format("Einstellungen erhalten von %s", characterName )
end

L["A_IS_NOT_IN_TEAM"] = function( characterName )
	return string.format("%s ist nicht in der Team Liste. %s kann nicht zum Meister ernannt werden.", characterName )
end
--------------------------
-- Core Locale
L["STATUSTEXT"] = "The Awesome MultiBoxing Assistant Ebony's Edition"
L["RESET_SETTINGS_FRAME"] = "Setzt Einstellungs Fenster zurück"
L["MODULE_NOT_LOADED"] = "Modul nicht geladen oder nicht Aktuell"
L["RELEASE_NOTES"] = "Veröffentlichungsnotiz "
L["COPYING_PROFILE"] = "Copying profile: "
L["CHANGING_PROFILE"] = "Änderungsprofil: "
L["PROFILE_RESET"] = "Profile reset - iterating all modules."
L["RESETTING_PROFILE"] = "Resetting profile: "
L["PROFILE_DELETED"] = "Profile deleted - iterating all modules."
L["DELETING_PROFILE"] = "Deleting profile: "
L["Failed_LOAD_MODULE"] =  "Failed to load EMA Module: "
L["TEXT1"] = "EMA Ebony's Edition v8 für BFA" 
L["TEXT2"] = ""
L["TEXT3"] = "Dies ist eine Beta Version!"
L["TEXT4"] = ""
L["TEXT5"] = ""
L["TEXT6"] = "Für mehr Informationen lies Bitte den ChangeLog"
L["TEXT7"] = ""
L["TEXT8"] = ""
L["TEXT9"] = ""
L["TEXT10"] = ""
L["SPECIAL_THANKS"] = "Special Thanks:"
L["THANKS1"] = "Michael \"Jafula\" Miller For Making Jamba That Some Of This Code Is Based Of"
L["THANKS2"] = "tk911 für die Deutsche Übersetzung"
L["THANKS3"] = ""
L["WEBSITES"] = "Websites"
L["ME"] = "Current Project Manger Jennifer Calladine (Ebony)" 
L["ME_TWITTER"] = "https://twitter.com/Jenn_Ebony"
L["D-B"] = "http://Dual-boxing.com"
L["ISB"] = "http://IsBoxer.com"
L["TEMP_WEBSITE1"] = ""
L["TEMP_WEBSITE2"] = ""
L["TEMP_WEBSITE3"] = ""
L["COPYRIGHT"] = "Copyright (c) 2015-2021  Jennifer Calladine (Ebony)"
L["COPYRIGHTTWO"] = "Released Under License: The MIT License"
L["FRAME_RESET"] = "Frame Reset"
-- Msg 8000
L["ALL_SETTINGS_RESET"] = "Willkommen zu EMA \"Ebony's Edition\" für Patch 8.0.1 \nAlle EMA Einstellungen wurden Zurückgesetzt!"
--------------------------
-- Communications Locale

L["A: Failed to deserialize command arguments for B from C."] = function( libraryName, moduleName, sender )
	return libraryName..": Failed to deserialize command arguments for "..moduleName.." from "..sender.."."
end
L["AUTO_SET_TEAM"] = "Team Mitglieder automatisch On/Offline setzen"
L["BOOST_COMMUNICATIONS"] = "Erhöhe EMA zu EMA Kommunikationen"
L["BOOST_COMMUNICATIONS_HELP"] = "Erfordert Neustart, kann zu Verbindungsabbrüchen führen."
L["USE_GUILD_COMMS"] = "Verwende Gilden Kommunikationen"
L["USE_GUILD_COMMS_INFO"] = "Alle Teammitglieder müssen in der selben Gilde sein." 

----------------------------
-- Helper Locale
L["COMMANDS"] = "Kommandos"
L["SLASH_COMMANDS"] = "/Kommandos"

----------------------------
-- Team Locale
L["JAMBA-TEAM"] = "EMA-Team"
L["INVITE_GROUP"] = "Lade Team in Gruppe ein"
L["DISBAND_GROUP"] = "Löse Gruppe auf"
L["SET_MASTER"] = "Mache Aktuellen Charakter zum Meister"
L["ADD"] = "Hinzufügen"
L["ADD_HELP"] = "Füge ein Mitglied zur Teamliste hinzu."
L["REMOVE"] = "Entferne"
L["REMOVE_REMOVE"] = "Entferne ein Mitglied aus der Teamliste."
L["MASTER_HELP"] = "Ernenne einen Charakter zum Meister"
L["I_AM_MASTER"] = "Ich bin der Meister"
L["I_AM_MASTER_HELP"] = "Ernenne diesen Charakter zum Meister"
L["INVITE"] = "Einladen"
L["INVITE_HELP"] = "Ladet alle Teammitgieder in eine Gruppe ein."
L["DISBAND"] = "Auflösen"
L["DISBAND_HELP"] = "Alle Teammitgieder verlassen ihre Gruppe."
L["ADD_GROUPS_MEMBERS"] = "Füge ein Gruppenmitglied hinzu"
L["ADD_GROUPS_MEMBERS_HELP"] = "Füge ein Mitglied deiner Aktuellen Gruppe dem Team Hinzu."
L["REMOVE_ALL_MEMBERS"] = "Entferne alle Mitglieder"
L["REMOVE_ALL_MEMBERS_HELP"] = "Entfernt alle Mitglieder aus dem Team."
L["SET_TEAM_OFFLINE"] = "Markiere Team als Offline"
L["SET_TEAM_OFFLINE_HELP"] = "Markiert alle Teammitgieder als Offline"
L["SET_TEAM_ONLINE"] = "Markiere Team als Online"
L["SET_TEAM_ONLINE_HELP"] = "Markiert alle Teammitgieder als Online"
L["TEAM_HEADER"] = "Team"
L["GROUPS_HEADER"] = "Kategorie"
L["BUTTON_ADD_HELP"] = "Füge ein Mitglied zur Team Liste hinzu\nBenützt werden kann:\nCharakterName\nCharakterName-realm\nZiel\nMouseover"
L["BUTTON_ADDALL_HELP"] = "Fügt alle Gruppen/Schlachtzugsmitglieder der Team Liste hinzu"
L["BUTTON_UP_HELP"] = "Bewege einen Charakter in der Team Liste nach Oben"
L["BUTTON_ISBOXERADD_HELP"] = "Fügt dein IsBoxer Team deiner Teamliste hinzu."
L["BUTTON_DOWN_HELP"] = "Bewege einen Charakter in der Team Liste nach Unten"
L["BUTTON_REMOVE_HELP"] = "Entfernt das ausgewählte Mitglied aus der Teamliste"
L["BUTTON_MASTER_HELP"] = "Ernenne das ausgewählte Mitglied zum Meister seiner Gruppe"
L["BUTTON_GROUP_REMOVE_HELP"] = "Entfernt die Kategorie vom ausgewählten Charakter"
L["CHECKBOX_ISBOXER_SYNC"] = "Synchronisiere mit IsBoxer"
L["CHECKBOX_ISBOXER_SYNC_HELP"] = "Charakere basierent auf dem IsBoxer Team hinzufügen/entfernen."
L["MASTER_CONTROL"] = "Meister Kontrolle"
L["CHECKBOX_MASTER_LEADER"] = "Befördere Meister zum Gruppenanführer"
L["CHECKBOX_MASTER_LEADER_HELP"] = "Meister wird immer der Gruppenanführer sein."
L["CHECKBOX_CTM"] = "Setzte 'Mit Klicks Bewegen' bei Dienern"
L["CHECKBOX_CTM_HELP"] = "Automatischen Aktivieren von 'Mit Klicks Bewegen' bei Dienern und Deaktivieren beim Meister."
L["PARTY_CONTROLS"] = "Gruppen Einladungskontrolle"
L["CHECKBOX_CONVERT_RAID"] = "Automatischen ändern zum Schlachtzugs"
L["CHECKBOX_CONVERT_RAID_HELP"] = "Ändert Automatisch zum Schlachtzugs falls mehr als Fünf Charaktere eingeladen werden."
L["CHECKBOX_ASSISTANT"] = "Automatisch zum Assistenten befördern"
L["CHECKBOX_ASSISTANT_HELP"] = "Befördert Automatisch alle Schlachtzugsmitglieder zum Assistenten"
L["CHECKBOX_TEAM"] = "Von Team Mitgliedern annehmen"
L["CHECKBOX_TEAM_HELP"] = "Akzeptiert automatisch Einladungen von Team Mitgliedern."
L["CHECKBOX_ACCEPT_FROM_FRIENDS"] = "Von Freunden annehmen"
L["CHECKBOX_ACCEPT_FROM_FRIENDS_HELP"] = "Akzeptiert automatisch Einladungen von Freunden."
L["CHECKBOX_ACCEPT_FROM_GUILD"] = "Von Gilde annehmen"
L["CHECKBOX_ACCEPT_FROM_GUILD_HELP"] = "Akzeptiert automatisch Einladungen von Gilden Mitgliedern."
L["CHECKBOX_DECLINE_STRANGERS"] = "Von Fremden ablehnen"
L["CHECKBOX_DECLINE_STRANGERS_HELP"] = "Lehnt einladungen von allen anderen ab."
L["NOT_LINKED"] = "(Nicht Verknüpft)"
L["TEAM_NO_TARGET"] = "Kein Ziel oder Ziel ist kein Spieler"
L["UNKNOWN_GROUP"] = "Unbekannte Kategorie"
L["ONLINE"] = "Online"
L["OFFLINE"] = "Offline"
L["STATICPOPUP_ADD"] = "Trage Charakter-Server Namen ein um ihn der Team Liste hinzuzufügen:"
L["STATICPOPUP_REMOVE"] = "Bist du dir sicher das du %s aus der Team Liste entfernen willst?"

--------------------------
-- Message Locale
L["DEFAULT_CHAT_WINDOW"] = "Standard Chatfenster"
L["WHISPER"] = "Flüstern"
L["PARTY"] = "Gruppe" 
L["GUILD_OFFICER"] = "Gilden Offizier"
L["RAID"] = "Schlachtzug"
L["RAID_WARNING"] = "Schlachtzugs Warnung"
L["MUTE"] = "Stummschlaten"
L["DEFAULT_MESSAGE"] = "Standard Nachricht"
L["DEFAULT_WARNING"] = "Standard Warnung"
L["MUTE_POFILE"] = "Stummschalten (Standart)"
L["ADD_MSG_HELP"] = "Hinzufügen einer Neuen Nachrichten Region"
L["REMOVE_MSG_HELP"] = "Entferne eine Nachrichten Region"
L["NAME"] = "Name"
L["PASSWORD"] = "Passwort"
L["AREA"]  = "Region auf dem Bildschirm"
L["SOUND_TO_PLAY"] = "Geräusch"
L["SAVE"] = "Speichern"
L["STATICPOPUP_ADD_MSG"] = "Name der hinzuzufügenden Region?"
L["REMOVE_MESSAGE_AREA"] = "Willst du \"%s\" aus der Liste entfernen?"
L["MESSAGE_AREA_LIST"] = "Nachrichten Regions Liste"
L["MESSAGE_AREA_CONFIGURATION"] = "Nachrichten Regions Konfigurierung"
L["ERR_COULD_NOT_FIND_AREA"] = function( areaName )
	return string.format("ERROR: Could not find area: %s", areaName) 
end
--------------------------
-- Tag/Group Locale
L["ADD_TAG_HELP"]= "Add a Group To This Character."
L["REMMOVE_TAG_HELP"] = "Remove A Tag From This Character."
L["GROUP"] =  "Kategorie"
L["BUTTON_TAG_ADD_HELP"] = "Füge eine Kategorie der Liste hinzu"
L["BUTTON_TAG_REMOVE_HELP"] = "Entferne eine Kategorie aus der Liste"
L["ADD_TO_GROUP"] = "Add To Group"
L["ADD_TO_GROUP_HELP"] = "Add Character To Group"
L["REMOVE_FROM_GROUP"] = "Remove From Group"
L["REMOVE_FROM_GROUP_HELP"] = "Remove Character From Group"
L["WRONG_TEXT_INPUT_GROUP"] = "Needs To Be In <Character-realm> <Group> Format"
L["NEW_GROUP_NAME"] = "Füge eine Neue Kategorie hinzu:"
L["REMOVE_FROM_TAG_LIST"] = "Willst du \"%s\" aus der Liste entfernen?"
--Note This need to be lowercase! 
--If translated Make Sure you keep them as a the lowercase words or you Will breck Group/Tag
--It be a headache i don't need -- Ebony
L["ALL_LOWER"] = "all"
L["MASTER_LOWER"] = "master"
L["MINION_LOWER"] = "minion"

--------------------------
-- Item-Use Locale
L["ITEM-USE"] = "Gegenstände"
L["ITEM"] = "Gegenstand"
L["HIDE_ITEM_BAR"] = "Verstecke Gegenstands Anzeige"
L["HIDE_ITEM_BAR_HELP"] = "Verstecke die Gegenstands Anzeige."
L["SHOW_ITEM_BAR"] = "Zeige Gegenstands Anzeige an"
L["SHOW_ITEM_BAR_HELP"] = "Zeigt die Gegenstands Anzeige an."
L["CLEAR_ITEM_BAR"] = "Leere Gegenstands Anzeige"
L["CLEAR_ITEM_BAR_HELP"] = "Leere die Gegenstands Anzeige(Entfernt alle Gegenstände)"
L["CLEAR_BUTT"] = "Leeren"
L["SYNC_BUTT"] = "Sync"
L["TOOLTIP_SYNCHRONISE"] = "Synchronisiere die Gegenstands Anzeige"
L["TOOLTIP_NOLONGER_IN_BAGS"] = "Entfernt Gegenstände die sich nicht länger in deiner Tasche befinden aus der Gegenstands Anzeige."
L["NEW_QUEST_ITEM"] = "Neuer Gegenstand gefunden der eine Quest startet!"
L["ITEM_USE_OPTIONS"] = "Gegenstands Anzeigen Optionen"
L["SHOW_ITEM_BAR"] = "Zeige Gegenstands Anzeige"
L["SHOW_ITEM_BAR_HELP"] = "Zeigt die Gegenstands Anzeige"
L["ONLY_ON_MASTER"] = "Nur bei Meister"
L["ONLY_ON_MASTER_HELP"] = "Zeigt die Gegenstands Anzeige nur beim Meister an."
L["SHOW_ITEM_COUNT"] = "Zeige Gegenstandsanzahl an"
L["SHOW_ITEM_COUNT_HELP"] = "Zeigt Gegenstandanzahl und Gegenstandanzahl Tooltips an."
L["KEEP_BARS_SYNCHRONIZED"] = "Halte Gegenstands Anzeige bei Dienern Synchronisiert"
L["KEEP_BARS_SYNCHRONIZED_HELP"] = "Halte Gegenstands Anzeige bei Dienern Synchronisiert"
L["ADD_QUEST_ITEMS_TO_BAR"] = "Füge Questgegenstände automatisch der Anzeige hinzu"
L["ADD_QUEST_ITEMS_TO_BAR_HELP"] = "Fügt verwendbare Questgegenstände automatisch der Anzeige hinzu."
L["ADD_ARTIFACT_ITEMS"] = "Füge Artefaktmacht automatisch der Anzeige hinzu"
L["ADD_ARTIFACT_ITEMS_HELP"] = "Fügt verwendbare Artefaktmacht automatisch der Anzeige hinzu. (Legion)"
L["ADD_SATCHEL_ITEMS"] = "Füge Behälter automatisch der Anzeige hinzu"
L["ADD_SATCHEL_ITEMS_HELP"] = "Fügt Behälter(Kisten/Beutel) automatisch der Anzeige hinzu. "
L["HIDE_BUTTONS"] = "Verstecke Tasten"
L["HIDE_BUTTONS_HELP"] = "Versteckt Tasten(Sync/Leeren)"
L["HIDE_IN_COMBAT"] = "Im Kampf verstecken" 
L["HIDE_IN_COMBAT_HELP_IU"] = "Versteckt Anzeige im Kampf"
L["NUMBER_OF_ITEMS"] = "Anzahl der Gegenstände"
L["CLEAR_BUTT"] = "Leeren"
L["SYNC_BUTT"] = "Sync"
L["ITEM_BAR_CLEARED"] = "Gegenstands Anzeige geleert"
L["TEAM_BAGS"] = "Gegenstände des Teams"
L["BAG_BANK"] = "Taschen (Bank)"


--------------------------
-- EMA-Sell Locale
L["SELL"] = "Verkauf"
L["SELL_LIST"] = "Sell/Delete Item's List"
L["SELL_ALL"] = "Sell or Delete If Not Sell Price All Item's In This List"
L["ALT_SELL_ALL"] = "[Alt] um weitere Gegenstände zu verkaufen"
L["ALT_SELL_ALL_HELP"] = "Halte [Alt] um gleiche Gegenstände auf allen Charakteren zu verkaufen."
L["AUTO_SELL_ITEMS"] = "Gegenstände automatisch verkaufen"
L["AUTO_SELL_ITEMS_HELP"] = "Gegenstände unterhalb automatisch verkaufen."
L["ONLY_SB"] = "Nur Seelengebunden"
L["ONLY_SB_HELP"] = "Nur Seelengebundene Gegenstände verkaufen."
L["iLVL"] = "Gegenstandsstufe"
L["iLVL_HELP"] = "Verkaufe Gegenstände unterhalb der angegebenen Gegenstandsstufe. "
L["SELL_GRAY"] = "|cff9d9d9d Verkaufe Graue Gegenstände"
L["SELL_GRAY_HELP"] = "Verkauft alle Grauen Gegenstände"
L["SELL_GREEN"] = "|cff1eff00 Verkaufe Ungewöhnliche Gegenstände"
L["SELL_GREEN_HELP"] = "Verkauft alle Ungewöhnliche (Grün) Gegenstände"
L["SELL_RARE"] = "|cff0070dd Verkaufe Seltene Gegenstände"
L["SELL_RARE_HELP"] = "Verkauft alle Seltene (Blau) Gegenstände"
L["SELL_EPIC"] = "|cffa335ee Verkaufe Epische Gegenstände"
L["SELL_EPIC_HELP"]	= "Verkauft alle Epische (Lila) Gegenstände"
L["SELL_LIST_DROP_ITEM"] = "Verkaufe Andere Gegenstände(Ziehe Gegenstände in die Box)"
L["ITEM_TAG_ERR"] = "Item Tags Must Only Be Made Up Of Letters And Numbers."
L["POPUP_REMOVE_ITEM"] = "Bist du dir sicher das du den ausgewählten Gegenstand aus der Verkaufs Liste entfernen willst?"
L["ADD_TO_LIST"] = "Adds Item To List"
L["SELL_ITEMS"] = "Sell Items"
L["POPUP_DELETE_ITEM"] = "What You like to delete?"
L["I_HAVE_SOLD_X"] = function( temLink )
	return string.format("Ich habe %s verkauft.", temLink)
end
L["I_SOLD_ITEMS_PLUS_GOLD"] = function( count )
	return string.format( "Ich habe %s verkauft, für: ", count)
end	
L["DELETE_ITEM"] = function( bagItemLink )
	return string.format( "Ich habe %s GELÖSCHT!", bagItemLink)
end

--------------------------
-- Interaction Locale
L["TAXI"] = "Taxi"
L["TAXI_OPTIONS"] = "Taxi Optionen"
L["TAKE_TEAMS_TAXI"] = "Benutze Flugrouten mit Team"
L["TAKE_TEAMS_TAXI_HELP"] = "Benutze die selbe Flugroute mit allen Team Mitgliedern \n(Andere Team Mitglieder müssen die Flugkarte geöffnet haben)."
L["REQUEST_TAXI_STOP"] = "Beantrage Notlandung mit Team"
L["REQUEST_TAXI_STOP_HELP"] = "[PH] REQUEST_TAXI_STOP_HELP"
L["CLONES_TO_TAKE_TAXI_AFTER"] = "Diener Flug verzögerung (Sek)"
--Mount Locale
L["MOUNT"] = "Reittier"
L["MOUNT_OPTIONS"] = "Reittier Optionen"
L["MOUNT_WITH_TEAM"] = "Aufsteigen mit dem Team"
L["MOUNT_WITH_TEAM_HELP"] = "[PH] MOUNT_WITH_TEAM_HELP"
L["DISMOUNT_WITH_TEAM"] = "Absteigen mit dem Team"
L["DISMOUNT_WITH_TEAM_HELP"] = "Absteigen wenn das Team Absitzt"
L["ONLY_DISMOUNT_WITH_MASTER"] = "Nur mit Meister Absteigen"
L["ONLY_DISMOUNT_WITH_MASTER_HELP"] = "NUR Absteigen WENN DER MEISTER ABSITZT"
L["ONLY_MOUNT_WHEN_IN_RANGE"] = "Nur Absteigen wenn in Reichweite"
L["ONLY_MOUNT_WHEN_IN_RANGE_HELP"] = "Absteigen nur wenn das Team in Reichweite ist. \nFunktioniert nur in der Gruppe!"
L["I_AM_UNABLE_TO_MOUNT"] = "Ich kann nicht Aufsteigen!"
-- Loot Locale
L["LOOT_OPTIONS"] = "Beute Option Version 2.0"
L["DISMOUNT_WITH_CHARACTER"] = "Dismount With Character That Dismount"
L["ENABLE_AUTO_LOOT"] = "Verbesserte Beute aufteilung"
L["ENABLE_AUTO_LOOT_HELP"] = "Alte Beute aufteilung \naber Besser!"
L["TELL_TEAM_BOE_RARE"] = "Mitteilung bei Seltenen Gegenständen"
L["TELL_TEAM_BOE_RARE_HELP"] = "Macht sich bemerkbar wenn ein Seltener Gegenstand gefunden wurde der nicht beim Aufheben gebunden ist."
L["TELL_TEAM_BOE_EPIC"] = "Mitteilung bei Epischen Gegenständen"
L["TELL_TEAM_BOE_EPIC_HELP"] = "Macht sich bemerkbar wenn ein Epischer Gegenstand gefunden wurde der nicht beim Aufheben gebunden ist."
L["I_HAVE_LOOTED_X_Y_ITEM"] = function( rarity, itemName )
	return string.format( "Ich habe einen %q Gegenstand gefunden: %s", rarity, itemName )
end
L["EPIC"] = "Epischen"
L["RARE"] = "Selernen"
L["REQUESTED_STOP_X"] = function( sender )
	return string.format( "Ich habe eine anfrage für eine Notlandung von %s erhalten", sender )
end
L["SETTINGS_RECEIVED_FROM_A"] = function( characterName )
	return string.format( "Neue Einstellungen von %s erhalten.", characterName )
end
L["I_AM_UNABLE_TO_FLY_TO_A"] = function( nodename )
	return string.format( "Es ist mir nicht möglich nach %s zu fliegen.", nodename )
end
--------------------------
-- Currency Locale
L["EMA_CURRENCY"] = "EMA Währungen"
L["SHOW_CURRENCY"] = "Zeige Währungen an"
L["SHOW_CURRENCY_HELP"] = "Zeigt die Währungs Anzeige an."
L["HIDE_CURRENCY"] = "Verstecke Währungen"
L["HIDE_CURRENCY_HELP"] = "Versteckt die Währungs Anzeige für alle Team Mitglieder."
L["CURRENCY_HEADER"] = "Währungs Auswahl für die Anzeige"
L["GOLD"] = "Gold"
L["GOLD_HELP"] = "Zeige Gold der Diener"
L["GOLD_GB"] = "Zeige Gold in Gildenbank"
L["GOLD_GB_HELP"] = "Zeige Gold in der Gildenbank.\n(Wird nur beim besuch der Gildenbank Aktualisiert)"
L["CURR_STARTUP"] = "Zeige Währungs Anzeige beim Starten an"
L["CURR_STARTUP_HELP"] = "Zeigt die Währungs Anzeige beim starten an.\n(Nur beim Meister)"
L["LOCK_CURR_LIST"] = "Sperre die Währungs Anzeige"
L["LOCK_CURR_LIST_HELP"] = "Sperrt die Währungs Anzeige, hindurch Klicken möglich."
L["SPACE_FOR_NAME"] = "Platz für Namen"
L["SPACE_FOR_GOLD"] =  "Platz für Namen"
L["SPACE_FOR_POINTS"] = "Platz für Währungen"
L["SPACE_BETWEEN_VALUES"] = "Platz zwischen Werten"
L["TOTAL"] = "Gesamt"
L["CURR"] = "Curr"


--------------------------
-- Display Team Locale
L["EMA_TEAM"] = "EMA Team"
L["HIDE_TEAM_DISPLAY"] = "Verstecke Team"
L["HIDE_TEAM_DISPLAY_HELP"] = "Verstecke die Team Anzeige."
L["SHOW_TEAM_DISPLAY"] = "Zeige Team"
L["SHOW_TEAM_DISPLAY_HELP"] = "Zeige die Team Anzeige an."
L["DISPLAY_HEADER"] = "Team Anzeigeoptionen"
L["SHOW"] = "Anzeigen"
L["SHOW_TEAM_FRAME"] = "Zeige Team Anzeige"
L["SHOW_TEAM_FRAME_HELP"] = "Zeige EMA Team Anzeige"
L["HIDE_IN_COMBAT_HELP_DT"] = "Verstecke Team Anzeige im Kampf"
L["ENABLE_CLIQUE"] = "Aktiviere 'Clique' Unterstützung"
L["ENABLE_CLIQUE_HELP"] = "Aktiviere die 'Clique' Unterstützung\n(benötigt [/Reload Ui])"
L["SHOW_PARTY"] = "Zeige nur Gruppen Mitglieder"
L["SHOW_PARTY_HELP"] = "Zeige nur aktuelle Gruppenmitglieder an."
L["HEALTH_POWER_GROUP"] = "Gesundheit & Ressourcen außerhalb der Gruppe"
L["HEALTH_POWER_GROUP_HELP"] = "Aktualisiert Gesundheit und Ressourcen über die aktuelle Gruppe hinaus \nBenötigt Gilden Kommunikationen!"
L["SHOW_TITLE"] = "Zeige Titel"
L["SHOW_TITLE_HELP"] = "Zeige Titel der Team Anzeige an."
L["STACK_VERTICALLY"] = "Vertikale Team Anzeige"
L["STACK_VERTICALLY_HELP"] = "Ordnet die Team Anzeige Vertikal an."
L["CHARACTERS_PER_BAR"] = "Anzahl der Charaktere pro Reihe"
L["SHOW_CHARACTER_PORTRAIT"] = "Zeige Charakter Portrait"
L["SHOW_FOLLOW_BAR"] = "Zeige die 'Folgeanzeige' und den Charakter Namen" 
L["SHOW_NAME"] = "Zeige Charakter Namen"
L["SHOW_XP_BAR"] = "Zeige Erfahrung\n\nund Artefaktmacht\nund Ehre\nund Ruf"
L["VALUES"] = "Werte"
L["VALUES_HELP"] = "Zeige Werte"
L["PERCENTAGE"] = "Prozentual"
L["PERCENTAGE_HELP"] = "Zeigt Prozente an."
L["SHOW_XP"] = "Erfahrung"
L["SHOW_XP_HELP"] = "Zeigt Team Erfahrung an."
L["ARTIFACT_BAR"] = "Artefaktmacht"
L["ARTIFACT_BAR_HELP"] = "Zeigt Team Artefaktmacht an."
L["HONORXP"] = "Ehre"
L["HONORXP_HELP"] = "Zeigt Team Ehre an."
L["REPUTATION_BAR"] = "Ruf"
L["REPUTATION_BAR_HELP"] = "Zeigt Team Ruf an." 
L["SHOW_HEALTH"] = "Zeige Team Gesundheit"
L["SHOW_CLASS_COLORS"] = "Zeige Klassenfarbe"
L["SHOW_CLASS_COLORS_HELP"] = "Färbt Gesundheit in der Klassenfarbe es Charakters an."
L["POWER_HELP"] = "Zeit Team Ressourcen an\n\nMana, Wut, Etc..."
L["CLASS_POWER"] = "Zeigt Team Klassen Ressourcen an\n\nCombopunkte\nSeelensplitter\nHeilige Kraft\nRunen"
L["DEAD"] = "Tot"
L["PORTRAIT_HEADER"] = "Portrait"
L["FOLLOW_BAR_HEADER"] = "Folgen Anzeige"
L["EXPERIENCE_HEADER"] = "Erfahrungs Anzeige"
L["HEALTH_BAR_HEADER"] = "Gesundheits Anzeige"
L["POWER_BAR_HEADER"] = "Ressourcen Anzeige"
L["CLASS_BAR_HEADER"] = "Klassen Ressourcen Anzeige"

--------------------------
-- Follow Locale
L["FOLLOW_BINDING_HEADER"] = "Folgen Tastenbelegung"
L["FOLLOW_TRAIN"] = "Folgen im Zug"
L["FOLLOW_STROBE_ME"] = "Auto Folgen AN"
L["FOLLOW_STROBE_OFF"] = "Auto Folgen Aus"
L["FOLLOW_BROKEN_MSG"] = "Folgen Unterbrochen!"
L["FOLLOW_MASTER"] = "Folge dem Meister"
L["FOLLOW_MASTER_HELP"] = "Folge dem aktuellen Meister"
L["FOLLOW_TARGET"] = "Folge Ziel: <TargetName>"
L["FOLLOW_TARGET_HELP"] = "Folge einem Spezifischen Ziel"
L["FOLLOW_AFTER_COMBAT"] = "Automatisches Folgen nach dem Kampf"
L["FOLLOW_AFTER_COMBAT_HELP"] = "Automatisches Folgen nach dem Kampf"
L["DELAY_FOLLOW_AFTER_COMBAT"] = "Verzögerung in Sekunden"
L["DELAY_FOLLOW_AFTER_COMBAT_HELP"] = "Verzögerung des Automatischen Folgen nach dem Kampf in Sekunden"
L["FOLLOW_STROBING"] = "Beginnt wiederholtes Folgen <TargetName>"
L["FOLLOW_STROBING_HELP"] = "Beginnt eine Sequenze von Folgebefehlen (Einstellbaren) \nZiel Spezifischer Charakter."
L["FOLLOW_STROBING_ME"] = "Beginnt wiederholtes Folgen auf mir!"
L["FOLLOW_STROBING_ME_HELP"] = "Beginnt eine Sequenze von Folge Befehlen (Einstellbaren) \nAktueller Charakter."
L["FOLLOW_STROBING_END"] = "Beendet wiederholtes Folgen"
L["FOLLOW_STROBING_END_HELP"] = "Beendet wiederholtes Folgen auf allen Charakteren." 
L["FOLLOW_SET_MASTER"] = "Bestimmt Folge Ziel durch Namen"
L["FOLLOW_SET_MASTER_HELP"] = "Bestimmt Folge Ziel durch Namen"
L["TRAIN"] = "Folge Kette"
L["FOLLOW_ME"] = "Folge mir"
L["TRAIN_HELP"] = "Alle Charaktere bilden eine Folgen Kette."
L["FOLLOW_ME_HELP"] = "Folge Mor <EMA Kategorie>"
L["SNW"] = "Unw"
L["SNW_HELP"] = "Unterdrücke nächste Warnung"
L["TIME_DELAY_FOLLOWING"] = "Verzögerung für automatisches Folgen nach dem Kampf"
L["DIFFERENT_TOON_FOLLOW"] = "Benutze anderen Charakter als Folge Ziel"
L["DIFFERENT_TOON_FOLLOW_HELP"] = "Benutze anderen Charakter unterhalb als Folge Ziel"
L["NEW_FOLLOW_MASTER"] = "Neuer Folge Charakter"
L["FOLLOW_BROKEN_WARNING"] = "Warnung beim brechen von Folgen"
L["WARN_STOP_FOLLOWING"] = "Wenn ich aufhöre zu Folgen"
L["WARN_STOP_FOLLOWING_HELP"] = "Benachrichtigt den Meister wenn ein Charakter aufhört ihm zu folgen."
L["ONLY_IF_OUTSIDE_RANGE"] = "Nur warnen wenn außerhalb der Folge Reichweite"
L["ONLY_IF_OUTSIDE_RANGE_HELP"] = "Warnt nur wenn sich der Charakter außerhalb der Reichweite befindet die benöigt wird um erneut zu folgen."
L["FOLLOW_BROKEN_MESSAGE"] = "Benutzerdefinierte Nachricht wenn Charakter aufhört zufolgen"
L["DO_NOT_WARN"] = "Nicht warnen wenn ..."
L["IN_COMBAT"] = "Im Kampf"
L["ANY_MEMBER_IN_COMBAT"] = "Ein Teammitglied im Kampf ist"
L["FOLLOW_STROBING"] = "Wiederholtes Folgen aktiv"
L["FOLLOW_STROBING_AJM_FOLLOW_COMMANDS."] = "Wiederholtes Folgen wird durch /EMA-Follow Befehle kontrolliert."
L["USE_MASTER_STROBE_TARGET"] = "Meister ist IMMER Ziel Auto Folgen"
L["PAUSE_FOLLOW_STROBING"] = "Pausiere Wiederholtes Folgen wenn ...."
L["DRINKING_EATING"] = "Esse/Trinke"
L["IN_A_VEHICLE"] = "In einem Fahrzeug"
L["GROUP_FOLLOW_STROBE"] = "Kategorie für Auto Folgen"
L["FREQUENCY"] = "Frequenz in Sekunden"
L["FREQUENCY_COMABT"] = "Frequenz im Kampf in Sekunden"
L["ON"] = "An"
L["OFF"] = "Aus"
L["DRINK"] = "Trinken"
L["FOOD"] = "Essen"
L["REFRESHMENT"] = "Erfrischung"

--------------------------
-- Vender/Purchase Locale.
L["AUTO_BUY_ITEMS"] = "Gegenstände automatisch Kaufen"
L["OVERFLOW"] = "Überkaufen"
L["REMOVE_VENDER_LIST"] = "Entfernen von der Kaufliste"
L["ITEM_DROP"] = "Gegenstand (Ziehe Gegenstand aus deiner Tasche in die Box)"
L["PURCHASE_ITEMS"] = "Gegenstände automatisch Kaufen"
L["ADD_ITEM"] = "Gegenstand hinzufügen"
L["AMOUNT"] = "Anzahl"
L["PURCHASE_MSG"] = "Kauf Nachrichten"
L["ITEM_ERROR"] = "Item Tags Must Only Be Made Up Of Letters And Numbers."
L["NUM_ERROR"] = "Anzahl muss eine Nummer sein."
L["BUY_POPUP_ACCEPT"] = "Bist du sicher das du den ausgewählten Gegenstand aus der Liste entfernen willst?"
L["ERROR_BAGS_FULL"] =  "Ich habe nicht genug Platz in meiner Tasche um alles zu kaufen."
L["ERROR_GOLD"] = "Ich hab nicht genug Gold um alles zu kaufen." 
L["ERROR_CURR"] = "Ich habe nicht genug der benötigten Währung um alles zu kaufen."

--------------------------
-- Trade Locale
L["REMOVE_TRADE_LIST"] = "Bist du sicher das du den ausgewählten Gegenstand aus der Liste entfernen willst?"
L["TRADE_LIST_HEADER"] = "Handels Liste"
L["TRADE_LIST"] = "Handel die angegebenen Gegenständen"
L["TRADE_LIST_HELP"] = "Alle in dieser angegeben Gegenstände werden entsprechend der Kategorien gehaldelt."
L["TRADE_BOE_ITEMS"] = "Handel nicht gebundene Gegenstände"
L["TRADE_BOE_ITEMS_HELP"] = "Handel alle Gegenstände die nicht beim Aufheben gebunden werden mit dem aktuellen Meister."
L["TRADE_REAGENTS"] = "Handel alle Handwerksmaterialien"
L["TRADE_REAGENTS_HELP"] = "Handel Alle Handwerksmaterialien mit dem aktuellen Meister"
L["TRADE_OPTIONS"] = "Handel mit \"Meister\" Optionen"
L["TRADE_GOLD"] = "Handel überschüssiges Gold"
L["TRADE_GOLD_HELP"] = "Handel überschüssiges Gold von den Minions zum Meister \n\n ACHTUNG!\n Passe beim automatischen Handeln immer auf!"
L["GOLD_TO_KEEP"] = "Anzahl des Goldes das die Minions behalten sollen"
L["TRADE_TAG_ERR"] = "Gegenstands Bezeichnungen dürfen nur Buchstaben und Ziffern beinhalten"
L["ERR_WILL_NOT_TRADE"] = "Das Ziel ist kein Teammitglied, Handel nicht möglich."
L["ADD_ITEMS"] = "Füge Gegenstände hinzu"

--------------------------
-- Toon Locale
L["ATTACKED"] = "Ich werde ANGEGRIFFEN!"
L["TARGETING"] = "kein Ziel!"
L["FOCUS"] = "kein Focus!"
L["LOW_HEALTH"] = "wenig Gesundheit!"
L["LOW_MANA"] = "wenig Mana!"
L["BAGS_FULL"] = "volle Taschen!"
L["CCED"] = "Ich habe"
-- Vendor
L["AUTO_REPAIR"] = "Automatisches Reparieren"
L["AUTO_REPAIR_HELP"] = "Minions versuchen bei Händlern automatisch zu Reparieren."
L["REPAIR_GUILD_FUNDS"] = "Reparaturen von der Gildenbank zahlen"
L["REPAIR_GUILD_FUNDS_HELP"] = "Versucht mit Gold von der Gildenbank zu reparieren."
-- Requests
L["REQUESTS"] = "Anfragen"
L["DENY_DUELS"] = "Duell Einladungen ablehnen"
L["DENY_DUELS_HELP"] = "Lehnt Duell Anfragen automatisch ab."
L["DENY_GUILD_INVITES"] = "Gildeneinladungen ablehnen"
L["DENY_GUILD_INVITES_HELP"] = "Lehnt Gildeneinladungen automatisch ab."
L["ACCEPT_RESURRECT"] = "Wiederbelebungen annehmen"
L["ACCEPT_RESURRECT_AUTO"] = "Nimmt Wiederbelebungen automatisch an."
L["ACCEPT_RESURRECT_FROM_TEAM"] = "Nur von Teammitgliedern"
L["ACCEPT_RESURRECT_FROM_TEAM_HELP"] = "Automatische Annahme von Wiederbelebungsanfragen \nAuf ALLEN Teammitgiedern\nNur für Teammitgieder"

L["RELEASE_PROMPTS"] = "Team Anzeige zum Geist Freilassen anzeigen"
L["RELEASE_PROMPTS_HELP"] = "Sobald ein Teammitglied stirbt wird auf alles Charakteren eine Anzeige eingeblendet mit der alle Charaktere gleichzeitig den Geist Freilassen können. "
L["SUMMON_REQUEST"] = "Beschwörungen annehmen"
L["SUMMON_REQUEST_HELP"] = "Nimmt Beschwörungen automatisch an."
L["GROUPTOOLS_HEADING"] = "Dungeon Werkzeuge"
L["ROLE_CHECKS"] = "Gruppen Rollen akzeptieren" 
L["ROLE_CHECKS_HELP"] = "Wenn bereits eine Rolle ausgewählt ist wird diese automatisch angenommen"
L["READY_CHECKS"] = "Bereitschafts Abfrage als Team annehmen"
L["READY_CHECKS_HELP"] = "Bereitschafts Abfrage wird von allen Charakteren mit bestätigt."
L["LFG_Teleport"] = "Dungeon Teleportation mit Team"
L["LFG_Teleport_HELP"] = "Minions werden Teleportation in/aus einem Dungeon nachmachen."
L["ROLL_LOOT"] = "Mit Team auf Beute würfeln"
L["ROLL_LOOT_HELP"] = "Falls möglich würfeln alle Minions auf die gleichen Gegenstände wie der Master."
-- Warnings
L["COMBAT"] = "Kampf"
L["WARN_HIT"] = "Warnt falls ein Minion Schaden erleidet"
L["WARN_HIT_HELP"] = "Warnt bei dem ersten Schaden denn ein Minion im Kampf erleidet."
L["TARGET_NOT_MASTER"] = "Warnt wenn kein Ziel existiert"
L["TARGET_NOT_MASTER_HELP"] = "Warnt wenn im Kampf kein Ziel existiert (Minion)"
L["FOCUS_NOT_MASTER"] = "Warnt wenn kein Focus Ziel existiert"
L["FOCUS_NOT_MASTER_HELP"] = "Warnt wenn im Kampf kein Focus Ziel existiert (Minion)"
L["HEALTH_POWER"] = "Gesundheit / Mana"
L["HEALTH_DROPS_BELOW"] = "Warnt wenn Gesundheit unter den Wert fällt"
L["HEALTH_DROPS_BELOW_HELP"] = "Warnt wenn die Gesundheit eines Minions unter den Wert fällt"
L["HEALTH_PERCENTAGE"] = "Gesundheitswert - warnt bei weniger als ... Prozent"
L["MANA_DROPS_BELOW"] = "Warnt wenn Mana unter den Wert fällt"
L["MANA_DROPS_BELOW_HELP"] = "Warnt wenn das Mana eines Minions unter den Wert fäll"
L["MANA_PERCENTAGE"] = "Manawert - warnt bei weniger als ... Prozent"
L["DURABILITY_DROPS_BELOW"] = "Warnt wenn Haltbarkeit unter den Wert fällt"
L["DURABILITY_DROPS_BELOW_HELP"] = "Warnt wenn die Haltbarkeit eines Minions unter den Wert fällt."
L["DURABILITY_PERCENTAGE"] = "Haltbarkeit - warnt bei weniger als ... Prozent"
L["LOW_DURABILITY_TEXT"] = "Niedrige Haltbarkeit Text"
L["DURABILITY_LOW_MSG"] = "Meine Haltbarkeit fällt auf"
L["BAGS_FULL"] = "Taschen sind Voll"
L["BAGS_FULL_HELP"] = "Warnt wenn Taschen Voll sind"
L["BAG_SPACE"] = "Taschen Platz"
L["OTHER"] = "Andere"
L["WARN_IF_CC"] = "Warnt wenn ein Team Mitglied unter den Einfluss von Kontrollversucheffekten fällt"
L["WARN_IF_CC_HELP"] = "Warnt wenn ein Team Mitglied unter den Einfluss von Kontrollversucheffekten fällt"
L["RELEASE_TEAM_Q"] = "Mit Team Geist Freilassen?"
L["RELEASE_TEAM"] = "Team freilassen"
L["RECOVER_CORPSES"] = "Team wiederbeleben?"
L["ERR_GOLD_TO_REPAIR"] = "Ich habe nicht genug Gold um alle Gegenstände zu Reparieren."
L["RELEASE_CORPSE_FOR_X"] = function( delay )
	return string.format( "Ich kann meinen Geist für %s sekunden nicht freilassen", delay )
end
L["I_REFUSED_A_DUEL_FROM_X"] = function( challenger )
	return string.format( "Ich habe eine Duell Anfrage von %s abgelehnt.", challenger )
end
L["REFUSED_GUILD_INVITE"] = function( guild, inviter )
	return string.format( "Ich habe eine Gildeneinladung für %s von %s abgelehnt.", guild, inviter )
end
L["SUMMON_FROM_X_TO_Y"] = function( sender, location )
	return string.format( "Ich habe eine Beschwörung von: %s nach: %s angenommen.", sender, location )
end
L["REPAIRING_COST_ME_X"] = function( costString )
    return string.format( "Reparieren kostet mich: %s", costString )
end

--------------------------
-- Talk Locale

L["TALK_OPTIONS"] = "Unterhaltungs Optionen"
L["FORWARD_WHISPERS_MASTER_RELAY"] = "Leite Unterhaltungen zu und von dem Master weiter"
L["FORWARD_WHISPERS_MASTER_RELAY_HELP"] = "Leitet geflüstertes zum Master weiter und \nleitet antworten zu dem flüsterer zurück."
L["DO_NOT_BATTENET_WHISPERS"] = "Battle.net Nachrichten nicht weiterleiten"
L["DO_NOT_BATTENET_WHISPERS_HELP"] = "Leitet keine Nachrichten über das Battle.net System weiter."

L["FORWARD_FAKE_WHISPERS"] = "Weiterleitung per Falschem geflüster für Klickbare Spieler und Links"
L["FORWARD_FAKE_WHISPERS_HELP"] = "Weiterleitung per Falschem geflüster für Klickbare Spieler und Links"
L["FAKE_WHISPERS_CHANNEL"]  = "Sende Falsch geflüster an"
L["FORWARDER_REPLY_QUEUE"] = "Zeigt Weiterleitenden im geflüster an den Master an"
L["FORWARDER_REPLY_QUEUE_HELP"] = "Zeigt Weiterleitenden im geflüster an den Master an."
L["ORIGINATOR_REPLY_QUEUE"] = "Zeigt den Flüsternden im geflüster an den Meister an"
L["ORIGINATOR_REPLY_QUEUE_HELP"] = "Zeigt den Weiterleitenden Flüsterer im geflüster an den Meister an." 
L["MESSAGES_WITH_LINKS"] = "Zeige nur Nachrichten mit Links"
L["MESSAGES_WITH_LINKS_HELP"] = "Zeige nur Nachrichten mit Links"
-- TOBEREMOVED
L["CHAT_SNIPPETS"] = "Chat Snippets"
L["ENABLE_CHAT_SNIPPETS"] = "Enable Chat Snippets"
L["ENABLE_CHAT_SNIPPETS_HELP"] = "Chat Snippets Auto Send Messages To Players That Wispers Your Minions"
L["SNIPPET_TEXT"] = "Snippet Text"
L["CHAT_SNIPPET_POPUP"] = "Enter The Shortcut Text For This Chat Snippet:"
L["REMOVE_CHAT_SNIPPET"] = "Are You Sure You Wish To Remove The Selected Chat Snippet?"
--END
L["GM"] = "GM"
L["TALK_VIA"] = " (über "
L["BATTLE_NET"] = "<BatteTag>"
L["<GM>"] = "<GameMaster>"
L["WHISPERS"] = " flüstert: "
L["WHISPERED_YOU"] = "Flüstert dir."

------------------------
-- Quest Locale

L["ABANDON_QUESTS_TEAM"] = "Willst du \"%s\" auf all deinen Toons abbrechen?"
L["JUST_ME"] = "Nur bei Mir"
L["ALL_TEAM"] = "Gesamten Team"
L["TRACK_QUEST_ON_TEAM"] = "Willst du \"%s\" auf all deinen Toons verfolgen?"
L["UNTRACK_QUEST_ON_TEAM"] = "Willst du \"%s\" auf all deinen Toons NICHT mehr verfolgen?"
L["ABANDON_ALL_QUESTS"] = "Willst du \"ALLE\" deine Quests auf JEDEM Toon abbrechen? \nBist du Sicher?"
L["YES_IAM_SURE"] = "Ja, ich bin mir Sicher"
L["INFORMATION"] = "Informationen"
L["QUESTINFORMATIONONE"] = "EMA-Quest behandelt alle Teammitgieder als wären sie Master."
L["QUESTINFORMATIONTWO"] = "Quest Aktionen eines Charakters werden von allen anderen ebenfalls durchgeführt."
L["QUESTINFORMATIONTHREE"] = "Egal wer aktuell Master ist."
L["QUEST_HEADER"] = "Quest Annahme und Abgabe mit EMA"
L["MIRROR_QUEST"] = "Quest Auswahl und Annahme"
L["MIRROR_QUEST_HELP"] = "Spiegelt die Auswahl des Meisters auf das restliche Team."
L["AUTO_SELECT_QUESTS"] = "Automatische Annahme aller Quests"
L["AUTO_SELECT_QUESTS_HELP"] = "Automatische Questannahme \nSobald ein Questgeber angesprochen wurde."
L["ACCEPT_QUESTS"] = "Quest annahme"
L["ACCEPT_QUESTS_HELP"] = "Quest annahme"
L["ACCEPT_QUEST_WITH_TEAM"] = "Nimmt Quests mit Team an"
L["ACCEPT_QUEST_WITH_TEAM_HELP"] = "Nimmt Quests gleichzeitig mit dem Team an."
L["QUEST_INFORMATION_AUTO"] = "AUTOMATISCH: Nimmt jede Quest an unabhängig vom Team."
L["DONOT_AUTO_ACCEPT_QUESTS"] = "Nimmt Quests nicht automatisch an." 
L["DONOT_AUTO_ACCEPT_QUESTS_HELP"] = "Nimmt Quest niemals automatisch an."
L["AUTO_ACCEPT_QUESTS"] = "Nimmt jede geteilte Quest Automatisch an"
L["AUTO_ACCEPT_QUESTS_HELP"] = "Nimmt jede geteilte Quest Automatisch an unabhängig von Wem. "
L["AUTO_ACCEPT_QUESTS_LIST"] = "Nimmt geteilte Quest an:"
L["AUTO_ACCEPT_QUESTS_LIST_HELP"] = "Nimmt geteilte Quests von folgenden Quellen automatisch an."
L["TEAM_QUEST_HELP"] = "Von jedem Team Mitglied."
L["NPC"] = "Questgeber"
L["NPC_HELP"] = "Von jedem Nicht-Spieler-Charakter."
L["FRIENDS"] = "Freunden"
L["FRIENDS_HELP"] = "Von jedem in deiner Freundes/BattleTag Liste."
-- Quest
L["QUEST_GROUP_HELP"] = "Von jedem in deiner Gruppe."
L["GUILD_HELP"] = "Von jedem in deiner Gilde."
L["PH_RAID"] = "[PH] Raid" 
L["PH_RAID_HELP"] = "[PH] Raid" 
L["MASTER_SHARE_QUESTS"] = "Master teilt automatisch jede angenommene Quest"
L["MASTER_SHARE_QUESTS_HELP"] = "Master wird versuchen jede angenommene Quest auch zuteilen."
L["ACCEPT_ESCORT_QUEST"] = "Team akzeptiert jede Eskort Quest vom Team."
L["ACCEPT_ESCORT_QUEST_HELP"] = "Automatische annahme von Eskort Quests die jemand im Team startet."
L["HOLD_SHIFT_TO_OVERRIDE"] = "Halte [Shift] zum überschreiben der Automatischen Annahme/Abgabe von Quests"
L["HOLD_SHIFT_TO_OVERRIDE_HELP"] = "Halte [Shift] zum überschreiben der Automatischen Annahme/Abgabe von Quests."
L["SHOW_PANEL_UNDER_QUESTLOG"] = "Zeige Zusätzliche Tasten unter der Weltkarte"
L["SHOW_PANEL_UNDER_QUESTLOG_HELP"] = "Zeige Zusätzliche Tasten unter der Weltkarte"
-- Completion
L["QUEST_COMPLETION"] = "Quest Abschluss"
L["ENABLE_QUEST_COMPLETION"] = "Aktiviere automatische Questabgabe"
L["ENABLE_QUEST_COMPLETION_HELP"] = "Ermöglicht das automatische abgeben von Fertigen Quests."
L["NOREWARDS_OR_ONEREWARD"] = "Quest hat keine oder eine Belohnung:"
L["QUEST_DO_NOTHING"] = "Toon macht nichts"
L["QUEST_DO_NOTHING_HELP"] = "Toon gibt Quest nicht automatisch ab."
L["COMPLETE_QUEST_WITH_TEAM"] = "Toon gibt Quest mit Master ab"
L["COMPLETE_QUEST_WITH_TEAM_HELP"] = "Alle geben ihre Quest gleichzeitig mit dem Master ab."
L["AUTO_COMPLETE_QUEST"] = "Toon gibt Quest automatisch ab"
L["AUTO_COMPLETE_QUEST_HELP"] = "Gibt Quests automatisch ab."
L["MORE_THEN_ONE_REWARD"] = "Quest hat mehr als eine Belohnung:"
L["MUST_CHOOSE_OWN_REWARD"] = "Toon muss Belohnung auswählen"
L["MUST_CHOOSE_OWN_REWARD_HELP"] = "Toons müssen ihre Belohnung seperat auswählen"
L["CHOOSE_SAME_REWARD"] = "Toons wählen die selbe Belohnung"
L["CHOOSE_SAME_REWARD_HELP"] = "Toons wählen die selbe Belohnung wie der rest des Teams \n\nNur verwenden wenn alle Teammitglieder die selbe Klasse sind."
L["MODIFIER_CHOOSE_SAME_REWARD"] = "Wenn eine Modifier Taste gehalten wird, wählen die Toons die selbe Belohnung"
L["MODIFIER_CHOOSE_SAME_REWARD_HELP"] = "Wenn eine Modifier Taste gehalten wird, wählen die Toons die selbe Belohnung"
L["OVERRIDE_REWARD_SELECTED"] = "Überschreibung: Wenn ein Minion bereits eine Belohnung ausgewählt hat, wählt er diesen"
L["OVERRIDE_REWARD_SELECTED_HELP"] = "Überschreibung: Wenn ein Minion bereits eine Belohnung ausgewählt hat, wählt er diesen."
L["SHARING_QUEST_TO_ALLMINIONS"] = "Teile Quests mit allen Minions"
L["TRACKING_QUEST_TO_ALLMINIONS"] = "Verfolge Quests bei allen Minions"
L["UNTRACKING_QUESTS_ALLMINIONS"] = "Entfolge Quests bei allen Minions"
L["TOGGLE"] = "Wechseln"
L["ABANDON_ALL"] = "ALLE Quests abbrechen"
L["ABANDON_ALL_TOOLTIP"] = "Breche alle Quests auf Allen Minions ab"
L["SHARE_ALL"] = "Teile Alle"
L["SHARE_ALL_TOOLTIP"] = "Teile Alle Quests bei Allen Minions"
L["TRACK_ALL"] = "Verfolge Alle"
L["TRACK_ALL_TOOLTIP"] = "Verfolge Alle Quests bei Allen Minions"
L["UNTRACK_ALL"] = "Entfolge Alle"
L["UNTRACK_ALL_TOOLTIP"] = "Entfolge Alle Quests bei Allen Minions"
L["ABANDONING_ALLQUEST"] = "Breche Quest bei allem Minions ab"

-- Quest Strings
L["AUTOMATICALLY_ACCEPTED_ESCORT_QUEST"] = function( questName )
	return string.format( "Eine Eskort Quest wurde angenommen: %s", questName )
end
L["INVENTORY_IS_FULL_CAN_NOT_HAND_IN_QUEST"] = function( questName )
	return string.format( "Taschen sind voll, ich kann die Quest %s nicht abgeben.", questName )
end
L["ACCEPTED_QUEST_QN"] = function( questName )
	return string.format( "%s angenommen", questName )
end
L["AUTO_ACCEPTED_PICKUPQUEST_QN"] = function( questName )
	return string.format( "Eine Quest wurde automatisch angenommen: %s", questName )
end
L["AUTOMATICALLY_ACCEPTED_QUEST"] = function( questName )
	return string.format( "Eine Quest wurde automatisch angenommen: %s", questName )
end
L["QUESTLOG_DO_NOT_HAVE_QUEST"] = function( questName )
	return string.format( "Ich habe diese Quest nicht: %s", questName )
end
L["JAMBA_QUESTLOG_Have_Abandoned_Quest"] = function( questName )
	return string.format( "Ich habe diese Quest abgebrochen: %s", questName )
end

------------------------
-- QuestTracker Locale

L["SHOW_QUEST_WATCHER"] = "Zeige Quests an"
L["SHOW_QUEST_WATCHER_HELP"] = "Zeige die Questanzeige an."
L["HIDE_QUEST_WATCHER"] = "Verstecke Quests"
L["HIDE_QUEST_WATCHER_HELP"] = "Versteckt die Questanzeige."
L["QUEST_TRACKER_HEADER"] = "Quest Anzeige Einstellungen"
L["ENABLE_TRACKER"] = "Aktiviere Quest Anzeige"
L["ENABLE_TRACKER_HELP"] = "Aktivie die EMA Quest Anzeige"
L["UNLOCK_TRACKER"] = "Entriegel Quest Anzeige"
L["UNLOCK_TRACKER_HELP"] = "Entriegel die EMA Questanzeige. \n Halte[Alt] zum verschieben"
L["HIDE_BLIZZ_OBJ_TRACKER"] = "Verstecke Blizzards Quest Anzeige" 
L["HIDE_BLIZZ_OBJ_TRACKER_HELP"] = "Versteckt die Standard Blizzard Quest verfolgung."
L["SHOW_JOT_ON_MASTER"] = "Zeige Quest nur auf Master"
L["SHOW_JOT_ON_MASTER_HELP"] = "Zeigt die EMA Quest Anzeige nur auf dem Master an."
L["HIDE_JOT_IN_COMBAT"] = "Verstecke Quests im Kamp"
L["HIDE_JOT_IN_COMBAT_HELP"] = "Verstecke die EMA Quest Anzeige im Kampf"
L["SHOW_COMPLETED_OBJ_DONE"] = "Zeige Vollständige Quests an"
L["SHOW_COMPLETED_OBJ_DONE_HELP"] = "Zeigt vervollständigte Quests als 'Fertig' an."
L["HIDE_OBJ_COMPLETED"] = "Verstecke Vollständige Quests"
L["HIDE_OBJ_COMPLETED_HELP"] = "Verstecke Vollständige Quests"
L["SEND_PROGRESS_MESSAGES"] = "Teile Questfortschritte mit"
L["SEND_PROGRESS_MESSAGES_HELP"] = "Teile Questfortschritt in der Nachrichten Region's Box unterhalb"
L["QUESTWACHERINFORMATIONONE"] = "Um die Zeilen und Breite zu übernehmen wird ein [/reload] benötigt. "
L["LINES_TO_DISPLAY"] = "Zeilen mit Informationen anzeigen"
L["TRACKER_WIDTH"] = "Anzeige Breite"
L["DONE"] = "Fertig"
L["TRACKER_TITLE_NAME"] = "EMA Quest Anzeige"
L["REWARDS"] = "Belohnung"
L["REWARDS_TEXT"] = "Abschluss dieser Quest gewährt \nEuch:"
L["HEADER_MOUSE_OVER_QUESTWATCHER"] = "Halte \"ALT\" gedrückt um die Quest Anzeige zu verschieben"
L["UPDATE_MOUSE_OVER_QUESTWATCHER"] = "Zwingt die Quest Anzeige zu einer Aktualisierung"

------------------------
-- Guild Locale
L["GUILDTAB"] = ""
L["GUILD_LIST_HEADER"] = "Gildenbank Liste"
L["GUILD_LIST"] = "Verstaue aufgelistete Gegenstände in der Gildenbank"
L["GUILD_LIST_HELP"] = "Verstaue aufgelistete Gegenstände Automatisch in der Gildenbank"
L["GB_TAB_LIST"] = "Gildenbank Tab Number"
L["GUILD_BOE_ITEMS"] = "Verstaue alle Nicht gebundenen Ausrüstung in der Gildenbank" 
L["GUILD_BOE_ITEMS_HELP"] = "Verstaue alle nicht beim aufheben gebundene Ausrüstung in der Gildenbank"
L["GUILD_REAGENTS"] =  "Verstaue alle Handwerksmaterialien in der Gildenbank"
L["GUILD_REAGENTS_HELP"] = "Verstaue alle Handwerksmaterialien in der Gildenbank"
L["GB_OPTIONS"] = "Gildenbank Optionen"
L["GB_GOLD"] = "Adjustiere Charakter Gold bei Gildenbank besuch"
L["GB_GOLD_HELP"] = "Adjustiere Charakter Gold bei Gildenbank besuch"
L["REMOVE_GUILD_LIST"] = "Bist du dir sicher das du den ausgewählten Gegenstand aus der Liste entfernen willst?"

------------------------
-- X Locale
