-- ================================================================================ --
--				EMA - ( Ebony's MultiBoxing Assistant )    							--
--				Current Author: Jennifer Calladine (Ebony)								--
--																					--
--				License: All Rights Reserved 2018-2020 Jennifer Calladine					--
--																					--
--				Some Code Used from "Jamba" that is 								--
--				Released under the MIT License 										--
--				"Jamba" Copyright 2008-2015  Michael "Jafula" Miller				--
--																					--
-- ================================================================================ --

-- Only Load for Classic/TBC
if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE then
	return
end

-- Create the addon using AceAddon-3.0 and embed some libraries.
local EMA = LibStub( "AceAddon-3.0" ):NewAddon( 
	"Information", 
	"Module-1.0", 
	"AceConsole-3.0", 
	"AceEvent-3.0",
	"AceTimer-3.0"
)

-- Get the EMA Utilities Library.
local EMAUtilities = LibStub:GetLibrary( "EbonyUtilities-1.0" )
local EMAHelperSettings = LibStub:GetLibrary( "EMAHelperSettings-1.0" )
local LibBagUtils = LibStub:GetLibrary( "LibBagUtils-1.0" )
EMA.SharedMedia = LibStub( "LibSharedMedia-3.0" )

--  Constants and Locale for this module.
EMA.moduleName = "Information"
EMA.settingsDatabaseName = "InformationClassicProfileDB"
EMA.chatCommand = "ema-information"
local L = LibStub( "AceLocale-3.0" ):GetLocale( "Core" )
EMA.parentDisplayName = L["DISPLAY"]
EMA.moduleDisplayName = L["CURRENCY"]
-- Icon 
EMA.moduleIcon = "Interface\\Addons\\EMA\\Media\\SellIcon.tga"
-- order
EMA.moduleOrder = 3

EMA.globalCurrencyFramePrefix = "EMAToonCurrencyListFrame"
EMA.currTypes = {}
EMA.simpleCurrList = {}

-------------------------------------- End of edit --------------------------------------------------------------

	
	
-- Settings - the values to store and their defaults for the settings database.
EMA.settings = {
	profile = {
		currGold = true,
		bagSpace = true,
		charDurr = true,	
		
		currencyFrameAlpha = 1.0,
		currencyFramePoint = "CENTER",
		currencyFrameRelativePoint = "CENTER",
		currencyFrameXOffset = 0,
		currencyFrameYOffset = 0,
		currencyFrameBackgroundColourR = 1.0,
		currencyFrameBackgroundColourG = 1.0,
		currencyFrameBackgroundColourB = 1.0,
		currencyFrameBackgroundColourA = 1.0,
		currencyFrameBorderColourR = 1.0,
		currencyFrameBorderColourG = 1.0,
		currencyFrameBorderColourB = 1.0,
		currencyFrameBorderColourA = 1.0,		
		currencyBorderStyle = L["BLIZZARD_TOOLTIP"],
		currencyBackgroundStyle = L["BLIZZARD_DIALOG_BACKGROUND"],
		currencyFontStyle = L["ARIAL_NARROW"],
		currencyFontSize = 12,		
		currencyScale = 1,
		currencyNameWidth = 60,
		currencyPointsWidth = 50,
		currencyGoldWidth = 140,
		currencySpacingWidth = 3,
		currencyLockWindow = false,
		currOpenStartUpMaster = false,
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
				usage = "/ema-information config",
				get = false,
				set = "",				
			},
			show = {
				type = "input",
				name = L["SHOW_CURRENCY"],
				desc = L["SHOW_CURRENCY_HELP"],
				usage = "ema-information show",
				get = false,
				set = "EMAToonRequestCurrency",
			},
			hide = {
				type = "input",
				name = L["HIDE_CURRENCY"],
				desc = L["HIDE_CURRENCY_HELP"],
				usage = "ema-information hide",
				get = false,
				set = "EMAToonHideCurrency",
			},			
			push = {
				type = "input",
				name = L["PUSH_ALL_SETTINGS"],
				desc = L["PUSH_SETTINGS_INFO"],
				usage = "ema-information push",
				get = false,
				set = "EMASendSettings",
			},											
		},
	}
	return configuration
end

local function DebugMessage( ... )
	--EMA:Print( ... )
end

-------------------------------------------------------------------------------------------------------------
-- Command this module sends.
-------------------------------------------------------------------------------------------------------------

EMA.COMMAND_REQUEST_CURRENCY = "SendCurrency"
EMA.COMMAND_HERE_IS_CURRENCY = "HereIsCurrency"

-------------------------------------------------------------------------------------------------------------
-- Messages module sends.
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-- Variables used by module.
-------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
-- Settings Dialogs.
-------------------------------------------------------------------------------------------------------------

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
	local bottomOfInfo = EMA:SettingsCreateCurrency( EMAHelperSettings:TopOfSettings() )
	EMA.settingsControl.widgetSettings.content:SetHeight( -bottomOfInfo )	
	-- Help
	local helpTable = {}
	EMAHelperSettings:CreateHelp( EMA.settingsControl, helpTable, EMA:GetConfiguration() )		
end




function EMA:SettingsCreateCurrency( top )
	-- Get positions.
	local checkBoxHeight = EMAHelperSettings:GetCheckBoxHeight()
	local sliderHeight = EMAHelperSettings:GetSliderHeight()
	local mediaHeight = EMAHelperSettings:GetMediaHeight()	
	local editBoxHeight = EMAHelperSettings:GetEditBoxHeight()
	local buttonHeight = EMAHelperSettings:GetButtonHeight()
	local dropdownHeight = EMAHelperSettings:GetDropdownHeight() + 10
	local labelHeight = EMAHelperSettings:GetLabelHeight()
	local continueLabelHeight = 18
	local left = EMAHelperSettings:LeftOfSettings()
	local headingHeight = EMAHelperSettings:HeadingHeight()
	local headingWidth = EMAHelperSettings:HeadingWidth( true )
	local horizontalSpacing = EMAHelperSettings:GetHorizontalSpacing()
	local indent = horizontalSpacing * 12
	local verticalSpacing = EMAHelperSettings:GetVerticalSpacing()
	local halfWidth = (headingWidth - horizontalSpacing) / 2
	local thirdWidth = (headingWidth - (horizontalSpacing * 5)) / 5
	local halfWidthSlider = (headingWidth - horizontalSpacing) / 2
	local column2left = left + halfWidthSlider
	local left2 = left + thirdWidth
	local left3 = left + (thirdWidth * 1)
	local right = left + halfWidth + horizontalSpacing
	local movingTop = top
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["CURRENCY_HEADER"], movingTop, false )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxCurrencyGold = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["GOLD"],
		EMA.SettingsToggleCurrencyGold,
		L["GOLD_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
		EMA.settingsControl.checkBoxCurrencyBagSpace = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["BAG_SPACE"],
		EMA.SettingsToggleCurrencyBagSpace,
		L["BAG_SPACE_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
		EMA.settingsControl.checkBoxCurrencyCharDurr = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["DURR"],
		EMA.SettingsToggleCurrencyCharDurr,
		L["DURR_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight	

	-- Other Stuff	
	EMA.settingsControl.currencyButtonShowList = EMAHelperSettings:CreateButton( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SHOW_CURRENCY"], 
		EMA.EMAToonRequestCurrency,
		L["SHOW_CURRENCY_HELP"]
	)
	movingTop = movingTop - buttonHeight
	EMA.settingsControl.checkBoxCurrencyOpenStartUpMaster = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["CURR_STARTUP"],
		EMA.SettingsToggleCurrencyOpenStartUpMaster,
		L["CURR_STARTUP_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight
	-- Create appearance & layout.
	EMAHelperSettings:CreateHeading( EMA.settingsControl, L["APPEARANCE_LAYOUT_HEALDER"], movingTop, true )
	movingTop = movingTop - headingHeight
	EMA.settingsControl.checkBoxCurrencyLockWindow = EMAHelperSettings:CreateCheckBox( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["LOCK_CURR_LIST"],
		EMA.SettingsToggleCurrencyLockWindow,
		L["LOCK_CURR_LIST_HELP"]
	)	
	movingTop = movingTop - checkBoxHeight		
	EMA.settingsControl.currencyScaleSlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SCALE"]
	)
	EMA.settingsControl.currencyScaleSlider:SetSliderValues( 0.5, 2, 0.01 )
	EMA.settingsControl.currencyScaleSlider:SetCallback( "OnValueChanged", EMA.SettingsChangeScale )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.currencyTransparencySlider = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["TRANSPARENCY"]
	)
	EMA.settingsControl.currencyTransparencySlider:SetSliderValues( 0, 1, 0.01 )
	EMA.settingsControl.currencyTransparencySlider:SetCallback( "OnValueChanged", EMA.SettingsChangeTransparency )
	movingTop = movingTop - sliderHeight - verticalSpacing	
	EMA.settingsControl.currencyMediaBorder = EMAHelperSettings:CreateMediaBorder( 
		EMA.settingsControl, 
		halfWidthSlider, 
		left, 
		movingTop,
		L["BORDER_STYLE"]
	)
	EMA.settingsControl.currencyMediaBorder:SetCallback( "OnValueChanged", EMA.SettingsChangeBorderStyle )

	EMA.settingsControl.currencyBorderColourPicker = EMAHelperSettings:CreateColourPicker(
		EMA.settingsControl,
		halfWidthSlider,
		column2left + 15,
		movingTop - 15,
		L["BORDER COLOUR"]
	)
	EMA.settingsControl.currencyBorderColourPicker:SetHasAlpha( true )
	EMA.settingsControl.currencyBorderColourPicker:SetCallback( "OnValueConfirmed", EMA.SettingsBorderColourPickerChanged )	
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMA.settingsControl.currencyMediaBackground = EMAHelperSettings:CreateMediaBackground( 
		EMA.settingsControl, 
		halfWidthSlider, 
		left, 
		movingTop,
		L["BACKGROUND"]
	)
	EMA.settingsControl.currencyMediaBackground:SetCallback( "OnValueChanged", EMA.SettingsChangeBackgroundStyle )
	EMA.settingsControl.currencyBackgroundColourPicker = EMAHelperSettings:CreateColourPicker(
		EMA.settingsControl,
		halfWidthSlider,
		column2left + 15,
		movingTop - 15,
		L["BG_COLOUR"]
	)
	EMA.settingsControl.currencyBackgroundColourPicker:SetHasAlpha( true )
	EMA.settingsControl.currencyBackgroundColourPicker:SetCallback( "OnValueConfirmed", EMA.SettingsBackgroundColourPickerChanged )
	movingTop = movingTop - mediaHeight - verticalSpacing
	--Font
	EMA.settingsControl.currencyMediaFont = EMAHelperSettings:CreateMediaFont( 
		EMA.settingsControl, 
		halfWidthSlider, 
		left, 
		movingTop,
		L["FONT"]
	)
	EMA.settingsControl.currencyMediaFont:SetCallback( "OnValueChanged", EMA.SettingsChangeFontStyle )
	EMA.settingsControl.currencyFontSize = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		halfWidthSlider, 
		column2left, 
		movingTop, 
		L["FONT_SIZE"]
	)	
	EMA.settingsControl.currencyFontSize:SetSliderValues( 8, 20 , 1 )
	EMA.settingsControl.currencyFontSize:SetCallback( "OnValueChanged", EMA.SettingsChangeFontSize )
	movingTop = movingTop - mediaHeight - verticalSpacing
	EMA.settingsControl.currencySliderSpaceForName = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_FOR_NAME"]
	)
	EMA.settingsControl.currencySliderSpaceForName:SetSliderValues( 20, 200, 1 )
	EMA.settingsControl.currencySliderSpaceForName:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceForName )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.currencySliderSpaceForGold = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_FOR_GOLD"]
	)
	EMA.settingsControl.currencySliderSpaceForGold:SetSliderValues( 20, 200, 1 )
	EMA.settingsControl.currencySliderSpaceForGold:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceForGold )
	movingTop = movingTop - sliderHeight - verticalSpacing
	EMA.settingsControl.currencySliderSpaceForPoints = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_FOR_POINTS"]
	)
	EMA.settingsControl.currencySliderSpaceForPoints:SetSliderValues( 20, 200, 1 )
	EMA.settingsControl.currencySliderSpaceForPoints:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceForPoints )
	movingTop = movingTop - sliderHeight - verticalSpacing	
	EMA.settingsControl.currencySliderSpaceBetweenValues = EMAHelperSettings:CreateSlider( 
		EMA.settingsControl, 
		headingWidth, 
		left, 
		movingTop, 
		L["SPACE_BETWEEN_VALUES"]
	)
	EMA.settingsControl.currencySliderSpaceBetweenValues:SetSliderValues( 0, 20, 1 )
	EMA.settingsControl.currencySliderSpaceBetweenValues:SetCallback( "OnValueChanged", EMA.SettingsChangeSliderSpaceBetweenValues )
	movingTop = movingTop - sliderHeight - verticalSpacing	
	return movingTop	
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
	EMA.settingsControl.checkBoxCurrencyGold:SetValue( EMA.db.currGold )
	EMA.settingsControl.checkBoxCurrencyBagSpace:SetValue ( EMA.db.bagSpace )
	EMA.settingsControl.checkBoxCurrencyCharDurr:SetValue ( EMA.db.charDurr )
	
	--state
	EMA.settingsControl.checkBoxCurrencyOpenStartUpMaster:SetValue( EMA.db.currOpenStartUpMaster )
	EMA.settingsControl.currencyTransparencySlider:SetValue( EMA.db.currencyFrameAlpha )
	EMA.settingsControl.currencyScaleSlider:SetValue( EMA.db.currencyScale )
	EMA.settingsControl.currencyMediaBorder:SetValue( EMA.db.currencyBorderStyle )
	EMA.settingsControl.currencyMediaBackground:SetValue( EMA.db.currencyBackgroundStyle )
	EMA.settingsControl.currencyBackgroundColourPicker:SetColor( EMA.db.currencyFrameBackgroundColourR, EMA.db.currencyFrameBackgroundColourG, EMA.db.currencyFrameBackgroundColourB, EMA.db.currencyFrameBackgroundColourA )
	EMA.settingsControl.currencyBorderColourPicker:SetColor( EMA.db.currencyFrameBorderColourR, EMA.db.currencyFrameBorderColourG, EMA.db.currencyFrameBorderColourB, EMA.db.currencyFrameBorderColourA )
	EMA.settingsControl.currencyMediaFont:SetValue( EMA.db.currencyFontStyle )
	EMA.settingsControl.currencyFontSize:SetValue( EMA.db.currencyFontSize )
	EMA.settingsControl.currencySliderSpaceForName:SetValue( EMA.db.currencyNameWidth )
	EMA.settingsControl.currencySliderSpaceForGold:SetValue( EMA.db.currencyGoldWidth )
	EMA.settingsControl.currencySliderSpaceForPoints:SetValue( EMA.db.currencyPointsWidth )
	EMA.settingsControl.currencySliderSpaceBetweenValues:SetValue( EMA.db.currencySpacingWidth )
	EMA.settingsControl.checkBoxCurrencyLockWindow:SetValue( EMA.db.currencyLockWindow )
	if EMA.currencyListFrameCreated == true then
		EMA:CurrencyListSetColumnWidth()
		EMA:SettingsUpdateBorderStyle()
		EMA:SettingsUpdateFontStyle()
		EMA:CurrencyUpdateWindowLock()
		EMAToonCurrencyListFrame:SetScale( EMA.db.currencyScale )
---????		EMA:UpdateHendingText()
		EMA:CurrencyListSetHeight()
	end
end

function EMA:SettingsPushSettingsClick( event )
	EMA:EMASendSettings()
end

function EMA:SettingsToggleCurrencyGold( event, checked )
	EMA.db.currGold = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsToggleCurrencyBagSpace( event, checked )
	EMA.db.bagSpace = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleCurrencyCharDurr( event, checked )
	EMA.db.charDurr = checked
	EMA:SettingsRefresh()
end	

function EMA:SettingsToggleCurrencyOpenStartUpMaster( event, checked )
	EMA.db.currOpenStartUpMaster = checked
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeScale( event, value )
	EMA.db.currencyScale = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeTransparency( event, value )
	EMA.db.currencyFrameAlpha = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeBorderStyle( event, value )
	EMA.db.currencyBorderStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeBackgroundStyle( event, value )
	EMA.db.currencyBackgroundStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsBackgroundColourPickerChanged( event, r, g, b, a )
	EMA.db.currencyFrameBackgroundColourR = r
	EMA.db.currencyFrameBackgroundColourG = g
	EMA.db.currencyFrameBackgroundColourB = b
	EMA.db.currencyFrameBackgroundColourA = a
	EMA:SettingsRefresh()
end

function EMA:SettingsBorderColourPickerChanged( event, r, g, b, a )
	EMA.db.currencyFrameBorderColourR = r
	EMA.db.currencyFrameBorderColourG = g
	EMA.db.currencyFrameBorderColourB = b
	EMA.db.currencyFrameBorderColourA = a
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeFontStyle( event, value )
	EMA.db.currencyFontStyle = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeFontSize( event, value )
	EMA.db.currencyFontSize = value
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceForName( event, value )
	EMA.db.currencyNameWidth = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceForGold( event, value )
	EMA.db.currencyGoldWidth = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceForPoints( event, value )
	EMA.db.currencyPointsWidth = tonumber( value )
	EMA:SettingsRefresh()
end

function EMA:SettingsChangeSliderSpaceBetweenValues( event, value )
	EMA.db.currencySpacingWidth = tonumber( value )
	EMA:SettingsRefresh()
end
		
function EMA:SettingsToggleCurrencyLockWindow( event, checked )
	EMA.db.currencyLockWindow = checked
	EMA:CurrencyUpdateWindowLock()
	EMA:SettingsRefresh()
end

-------------------------------------------------------------------------------------------------------------
-- Addon initialization, enabling and disabling.
-------------------------------------------------------------------------------------------------------------

-- Initialise the module.
function EMA:OnInitialize()
	EMA.currencyTotalGold = 0
	EMA.currencyListFrameCreated = false
	EMA.currencyFrameCharacterInfo = {}
	EMA.currentCurrencyValues = {}
	-- Create the settings control.
	SettingsCreate()
	-- Initialise the EMAModule part of this module.
	EMA:EMAModuleInitialize( EMA.settingsControl.widgetSettings.frame )
	-- Populate the settings.
	EMA:SettingsRefresh()
	-- Create the currency list frame.
	EMA:CreateEMAToonCurrencyListFrame()
end

-- Called when the addon is enabled.
function EMA:OnEnable()
	-- WoW events.
	--EMA:RegisterMessage( EMAApi.MESSAGE_MESSAGE_AREAS_CHANGED, "OnMessageAreasChanged" )
	if EMA.db.currOpenStartUpMaster == true then
		if EMAApi.IsCharacterTheMaster( self.characterName ) == true then
			EMA:ScheduleTimer( "EMAToonRequestCurrency", 5 )
		end
	end
end

-- Called when the addon is disabled.
function EMA:OnDisable()
end

-- Settings received.
function EMA:EMAOnSettingsReceived( characterName, settings )	
	if characterName ~= EMA.characterName then
		-- Update the settings.
		EMA.db.currGold = settings.currGold
		EMA.db.bagSpace = settings.bagSpace
		EMA.db.charDurr = settings.charDurr
	
		EMA.db.currOpenStartUpMaster = settings.currOpenStartUpMaster
		EMA.db.currencyScale = settings.currencyScale
		EMA.db.currencyFrameAlpha = settings.currencyFrameAlpha
		EMA.db.currencyFramePoint = settings.currencyFramePoint
		EMA.db.currencyFrameRelativePoint = settings.currencyFrameRelativePoint
		EMA.db.currencyFrameXOffset = settings.currencyFrameXOffset
		EMA.db.currencyFrameYOffset = settings.currencyFrameYOffset
		EMA.db.currencyFrameBackgroundColourR = settings.currencyFrameBackgroundColourR
		EMA.db.currencyFrameBackgroundColourG = settings.currencyFrameBackgroundColourG
		EMA.db.currencyFrameBackgroundColourB = settings.currencyFrameBackgroundColourB
		EMA.db.currencyFrameBackgroundColourA = settings.currencyFrameBackgroundColourA
		EMA.db.currencyFrameBorderColourR = settings.currencyFrameBorderColourR
		EMA.db.currencyFrameBorderColourG = settings.currencyFrameBorderColourG
		EMA.db.currencyFrameBorderColourB = settings.currencyFrameBorderColourB
		EMA.db.currencyFrameBorderColourA = settings.currencyFrameBorderColourA	
		EMA.db.currencyBorderStyle = settings.currencyBorderStyle
		EMA.db.currencyBackgroundStyle = settings.currencyBackgroundStyle
		EMA.db.currencyFontSize = settings.currencyFontSize
		EMA.db.currencyFontStyle = settings.currencyFontStyle
		EMA.db.currencyNameWidth = settings.currencyNameWidth
		EMA.db.currencyPointsWidth = settings.currencyPointsWidth
		EMA.db.currencyGoldWidth = settings.currencyGoldWidth
		EMA.db.currencySpacingWidth = settings.currencySpacingWidth
		EMA.db.currencyLockWindow = settings.currencyLockWindow
		-- Refresh the settings.
		EMA:SettingsRefresh()
		-- Tell the player.
		EMA:Print( L["SETTINGS_RECEIVED_FROM_A"]( characterName ) )
	end
end

function EMA:CreateEMAToonCurrencyListFrame()
	-- The frame.
	local frame = CreateFrame( "Frame", "EMAToonCurrencyListWindowFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil )
	frame.obj = EMA
	frame:SetFrameStrata( "LOW" )
	frame:SetToplevel( false )
	frame:SetClampedToScreen( true )
	frame:EnableMouse( true )
	frame:SetMovable( true )	
	frame:RegisterForDrag( "LeftButton" )
	frame:SetScript( "OnDragStart", 
		function( this ) 
			if IsAltKeyDown() then
				this:StartMoving() 
			end
		end )
	frame:SetScript( "OnDragStop", 
		function( this ) 
			this:StopMovingOrSizing() 
			local point, relativeTo, relativePoint, xOffset, yOffset = this:GetPoint()
			EMA.db.currencyFramePoint = point
			EMA.db.currencyFrameRelativePoint = relativePoint
			EMA.db.currencyFrameXOffset = xOffset
			EMA.db.currencyFrameYOffset = yOffset
		end	)
	frame:SetWidth( 500 )
	frame:SetHeight( 200 )
	frame:ClearAllPoints()
	frame:SetPoint( EMA.db.currencyFramePoint, UIParent, EMA.db.currencyFrameRelativePoint, EMA.db.currencyFrameXOffset, EMA.db.currencyFrameYOffset )
	frame:SetBackdrop( {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
		tile = true, tileSize = 10, edgeSize = 10, 
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	} )

	-- Create the title for the frame.
	local titleName = frame:CreateFontString( "EMAToonCurrencyListWindowFrameTitleText", "OVERLAY", "GameFontNormal" )
	titleName:SetPoint( "TOPLEFT", frame, "TOPLEFT", 3, -8 )
	titleName:SetTextColor( NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1.0 )
	titleName:SetText( L["CURRENCY"] )
	titleName:SetWidth( 200 )
	titleName:SetJustifyH( "LEFT" )
	titleName:SetWordWrap( false )
	frame.titleName = titleName
	
	-- Create the headings.
	local left = 10
	local spacing = 50
	local width = 50
	local top = -30
	local parentFrame = frame
	local r = 1.0
	local g = 0.96
	local b = 0.41
	local a = 1.0
	-- Set the characters name font string.
	local frameCharacterName = EMA.globalCurrencyFramePrefix.."TitleCharacterName"
	local frameCharacterNameText = parentFrame:CreateFontString( frameCharacterName.."Text", "OVERLAY", "GameFontNormal" )
	frameCharacterNameText:SetText( L["NAME"] )
	frameCharacterNameText:SetTextColor( r, g, b, a )
	frameCharacterNameText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameCharacterNameText:SetWidth( width * 2.5 )
	frameCharacterNameText:SetJustifyH( "LEFT" )
	frame.characterNameText = frameCharacterNameText
	left = left + (spacing * 2)
	-- Set the Gold font string.
	local frameGold = EMA.globalCurrencyFramePrefix.."TitleGold"
	local frameGoldText = parentFrame:CreateFontString( frameGold.."Text", "OVERLAY", "GameFontNormal" )
	frameGoldText:SetText( L["GOLD"] )
	frameGoldText:SetTextColor( r, g, b, a )
	frameGoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameGoldText:SetWidth( width )
	frameGoldText:SetJustifyH( "CENTER" )
	frame.GoldText = frameGoldText
	left = left + spacing	
	-- Set the BagSpace font string.
	local frameBagSpace = EMA.globalCurrencyFramePrefix.."TitleBagSpace"
	local frameBagSpaceText = parentFrame:CreateFontString( frameBagSpace.."Text", "OVERLAY", "GameFontNormal" )
	frameBagSpaceText:SetText( L["BAG_SPACE"] )
	frameBagSpaceText:SetTextColor( r, g, b, a )
	frameBagSpaceText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameBagSpaceText:SetWidth( width )
	frameBagSpaceText:SetJustifyH( "CENTER" )
	frame.BagSpaceText = frameBagSpaceText
	left = left + spacing
	-- Set the CharDurr font string.
	local frameCharDurr = EMA.globalCurrencyFramePrefix.."TitleBagSpace"
	local frameCharDurrText = parentFrame:CreateFontString( frameCharDurr.."Text", "OVERLAY", "GameFontNormal" )
	frameCharDurrText:SetText( L["DURR"] )
	frameCharDurrText:SetTextColor( r, g, b, a )
	frameCharDurrText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameCharDurrText:SetWidth( width )
	frameCharDurrText:SetJustifyH( "CENTER" )
	frame.CharDurrText = frameCharDurrText
	left = left + spacing
	
	-- Set the Total Gold font string.
	left = 10
	top = -50
	local frameTotalGoldTitle = EMA.globalCurrencyFramePrefix.."TitleTotalGold"
	local frameTotalGoldTitleText = parentFrame:CreateFontString( frameTotalGoldTitle.."Text", "OVERLAY", "GameFontNormal" )
	frameTotalGoldTitleText:SetText( L["TOTAL"] )
	frameTotalGoldTitleText:SetTextColor( r, g, b, a )
	frameTotalGoldTitleText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTotalGoldTitleText:SetWidth( width )
	frameTotalGoldTitleText:SetJustifyH( "LEFT" )
	frame.TotalGoldTitleText = frameTotalGoldTitleText

	local frameTotalGold = EMA.globalCurrencyFramePrefix.."TotalGold"
	local frameTotalGoldText = parentFrame:CreateFontString( frameTotalGold.."Text", "OVERLAY", "GameFontNormal" )
	frameTotalGoldText:SetText( "0" )
	frameTotalGoldText:SetTextColor( r, g, b, a )
	frameTotalGoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameTotalGoldText:SetWidth( width )
	frameTotalGoldText:SetJustifyH( "RIGHT" )
	frame.TotalGoldText = frameTotalGoldText
	
	-- Set frame width.
	frame:SetWidth( left + 10 )
	
	-- Set transparency of the the frame (and all its children).
	frame:SetAlpha( EMA.db.currencyFrameAlpha )
	
	-- Set scale.
	frame:SetScale( EMA.db.currencyScale )
	
	-- Set the global frame reference for this frame.
	EMAToonCurrencyListFrame = frame
	
	-- Close.
	local closeButton = CreateFrame( "Button", EMA.globalCurrencyFramePrefix.."ButtonClose", frame, "UIPanelCloseButton" )
	closeButton:SetScript( "OnClick", function() EMAToonCurrencyListFrame:Hide() end )
	closeButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", 0, 0 )	
	frame.closeButton = closeButton
	
	-- Update.
	local updateButton = CreateFrame( "Button", EMA.globalCurrencyFramePrefix.."ButtonUpdate", frame, "UIPanelButtonTemplate" )
	updateButton:SetScript( "OnClick", function() EMA:EMAToonRequestCurrency() end )
	updateButton:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", -30, -4 )
	updateButton:SetHeight( 22 )
	updateButton:SetWidth( 55 )
	updateButton:SetText( L["UPDATE"] )		
	
	frame.updateButton = updateButton
	
	EMA:SettingsUpdateBorderStyle()
	EMA:CurrencyUpdateWindowLock()
	EMA:SettingsUpdateFontStyle()
	EMAToonCurrencyListFrame:Hide()
	EMA.currencyListFrameCreated = true

	EMA:CurrencyListSetHeight()
end

function EMA:CurrencyUpdateWindowLock()
	if EMA.db.currencyLockWindow == false then
		EMAToonCurrencyListFrame:EnableMouse( true )
	else
		EMAToonCurrencyListFrame:EnableMouse( false )
	end
end

function EMA:SettingsUpdateBorderStyle()
	local borderStyle = EMA.SharedMedia:Fetch( "border", EMA.db.currencyBorderStyle )
	local backgroundStyle = EMA.SharedMedia:Fetch( "background", EMA.db.currencyBackgroundStyle )
	local frame = EMAToonCurrencyListFrame
	frame:SetBackdrop( {
		bgFile = backgroundStyle, 
		edgeFile = borderStyle, 
		tile = true, tileSize = frame:GetWidth(), edgeSize = 10, 
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	} )
	frame:SetBackdropColor( EMA.db.currencyFrameBackgroundColourR, EMA.db.currencyFrameBackgroundColourG, EMA.db.currencyFrameBackgroundColourB, EMA.db.currencyFrameBackgroundColourA )
	frame:SetBackdropBorderColor( EMA.db.currencyFrameBorderColourR, EMA.db.currencyFrameBorderColourG, EMA.db.currencyFrameBorderColourB, EMA.db.currencyFrameBorderColourA )
	frame:ClearAllPoints()
	frame:SetAlpha( EMA.db.currencyFrameAlpha )
	frame:SetPoint( EMA.db.currencyFramePoint, UIParent, EMA.db.currencyFrameRelativePoint, EMA.db.currencyFrameXOffset, EMA.db.currencyFrameYOffset )
end

function EMA:SettingsUpdateFontStyle()
	local textFont = EMA.SharedMedia:Fetch( "font", EMA.db.currencyFontStyle )
	local textSize = EMA.db.currencyFontSize
	local frame = EMAToonCurrencyListFrame
	frame.titleName:SetFont( textFont , textSize , "OUTLINE")
	frame.characterNameText:SetFont( textFont , textSize , "OUTLINE")
	frame.GoldText:SetFont( textFont , textSize , "OUTLINE")
	frame.BagSpaceText:SetFont( textFont , textSize , "OUTLINE")
	frame.CharDurrText:SetFont( textFont , textSize , "OUTLINE")
	for characterName, currencyFrameCharacterInfo in pairs( EMA.currencyFrameCharacterInfo ) do
		--EMA:Print("test", characterName)
		currencyFrameCharacterInfo.characterNameText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.GoldText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.BagSpaceText:SetFont( textFont , textSize , "OUTLINE")
		currencyFrameCharacterInfo.CharDurrText:SetFont( textFont , textSize , "OUTLINE")
	end
end


function EMA:CurrencyListSetHeight()
	local additionalLines = 0
	local addHeight = 0
	if EMA.db.currGold == true then
		additionalLines = 1
		addHeight = 5
	end
	EMAToonCurrencyListFrame:SetHeight( 56 + (( EMAApi.GetTeamListMaximumOrderOnline() + additionalLines) * 15) + addHeight )
end

function EMA:CurrencyListSetColumnWidth()
	local nameWidth = EMA.db.currencyNameWidth
	local pointsWidth = EMA.db.currencyPointsWidth
	local goldWidth = EMA.db.currencyGoldWidth
	local spacingWidth = EMA.db.currencySpacingWidth
	local frameHorizontalSpacing = 10
	local numberOfPointsColumns = 0
	local parentFrame = EMAToonCurrencyListFrame
	local headingRowTopPoint = -30
	local left = frameHorizontalSpacing
	local haveGold = 0
	-- Heading rows.
	parentFrame.characterNameText:SetWidth( nameWidth )
	parentFrame.characterNameText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
	left = left + nameWidth + spacingWidth
 	if EMA.db.currGold == true then
		parentFrame.GoldText:SetWidth( goldWidth )
		parentFrame.GoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + goldWidth + (spacingWidth * 3)
		parentFrame.GoldText:Show()
		haveGold = 1
	else
		parentFrame.GoldText:Hide()
		haveGold = 0
	end
 	if EMA.db.bagSpace == true then
		parentFrame.BagSpaceText:SetWidth( pointsWidth )
		parentFrame.BagSpaceText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + pointsWidth + spacingWidth
		numberOfPointsColumns = numberOfPointsColumns + 1
		parentFrame.BagSpaceText:Show()
	else
		parentFrame.BagSpaceText:Hide()
	end	
 	if EMA.db.charDurr == true then
		parentFrame.CharDurrText:SetWidth( pointsWidth )
		parentFrame.CharDurrText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, headingRowTopPoint )
		left = left + pointsWidth + spacingWidth
		numberOfPointsColumns = numberOfPointsColumns + 1
		parentFrame.CharDurrText:Show()
	else
		parentFrame.CharDurrText:Hide()
	end	
	-- Character rows.
	for characterName, currencyFrameCharacterInfo in pairs( EMA.currencyFrameCharacterInfo ) do
		if EMAPrivate.Team.GetCharacterOnlineStatus (characterName) == true then
			local left = frameHorizontalSpacing
			local characterRowTopPoint = currencyFrameCharacterInfo.characterRowTopPoint
				currencyFrameCharacterInfo.characterNameText:SetWidth( nameWidth )
				currencyFrameCharacterInfo.characterNameText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + nameWidth + spacingWidth
			if EMA.db.currGold == true then
				currencyFrameCharacterInfo.GoldText:SetWidth( goldWidth )
				currencyFrameCharacterInfo.GoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + goldWidth + (spacingWidth * 3)
				currencyFrameCharacterInfo.GoldText:Show()
			else
				currencyFrameCharacterInfo.GoldText:Hide()
			end
			if EMA.db.bagSpace == true then
				currencyFrameCharacterInfo.BagSpaceText:SetWidth( pointsWidth )
				currencyFrameCharacterInfo.BagSpaceText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + pointsWidth + spacingWidth
				currencyFrameCharacterInfo.BagSpaceText:Show()
			else	
				currencyFrameCharacterInfo.BagSpaceText:Hide()
			end
			if EMA.db.charDurr == true then
				currencyFrameCharacterInfo.CharDurrText:SetWidth( pointsWidth )
				currencyFrameCharacterInfo.CharDurrText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, characterRowTopPoint )
				left = left + pointsWidth + spacingWidth
				currencyFrameCharacterInfo.CharDurrText:Show()
			else	
				currencyFrameCharacterInfo.CharDurrText:Hide()
			end
		end
	end	
	-- Parent frame width and title.
	local finalParentWidth = frameHorizontalSpacing + nameWidth + spacingWidth + (haveGold * (goldWidth + (spacingWidth * 3))) + (numberOfPointsColumns * (pointsWidth + spacingWidth)) + frameHorizontalSpacing
	if finalParentWidth < 95 then
		finalParentWidth = 95
	end
	local widthOfCloseAndUpdateButtons = 70
	parentFrame.titleName:SetWidth( finalParentWidth - widthOfCloseAndUpdateButtons - frameHorizontalSpacing - frameHorizontalSpacing )
	parentFrame.titleName:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", frameHorizontalSpacing, -9 )
	if EMA.db.currGold == true then
		if numberOfPointsColumns > 1 then
			parentFrame.titleName:SetText( L["EMA_CURRENCY"] )
		else
			parentFrame.titleName:SetText( L["CURRENCY"] )
		end
	else
		if numberOfPointsColumns < 2 then
			parentFrame.titleName:SetText( "" )
		end
		if numberOfPointsColumns == 2 then
			parentFrame.titleName:SetText( L["CURR"] )
		end
		if (numberOfPointsColumns >= 3) and (numberOfPointsColumns <= 4) then
			parentFrame.titleName:SetText( L["CURRENCY"] )
		end
		if numberOfPointsColumns > 4 then
			parentFrame.titleName:SetText( L["EMA_CURRENCY"] )
		end
	end
	parentFrame:SetWidth( finalParentWidth )
	-- Total Gold.
	local nameLeft = frameHorizontalSpacing
	local goldLeft = frameHorizontalSpacing + nameWidth + spacingWidth
	local guildTop = -35 - ((EMAApi.GetTeamListMaximumOrderOnline() + 1) * 15) - 5
	local goldTop = -35 - ((EMAApi.GetTeamListMaximumOrderOnline() + 1) * 15) - 7	
	if EMA.db.currGold == true then
		parentFrame.TotalGoldTitleText:SetWidth( nameWidth )
		parentFrame.TotalGoldTitleText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", nameLeft, goldTop )
		parentFrame.TotalGoldTitleText:Show()
		parentFrame.TotalGoldText:SetWidth( goldWidth )
		parentFrame.TotalGoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", goldLeft, goldTop )
		parentFrame.TotalGoldText:Show()
	else
		parentFrame.TotalGoldTitleText:Hide()
		parentFrame.TotalGoldText:Hide()
	end
end

	


function EMA:CreateEMACurrencyFrameInfo( characterName, parentFrame )
	--EMA.Print("makelist", characterName)
	--if EMAPrivate.Team.GetCharacterOnlineStatus (characterName) == true then
	local left = 10
	local spacing = 50
	local width = 50
	local top = 0
	--local top = -35 + (-15 * EMAApi.GetPositionForCharacterName( characterName ))
	-- WHAT THE HELL IS GOING ON HERE! Ebony!
		local height1 = -35 + ( -15 * EMAApi.GetPositionForCharacterName( characterName) )
		local height2 = -35 + ( -15 * EMAApi.GetPositionForCharacterNameOnline( characterName) )
		if height1 < height2 then
			--EMA:Print("greater than ", characterName )
			top = height2
		elseif height1 > height2 then
			top = height2
		else
			top = height2
		end	
	--EMA:Print("Top", top)
	-- Create the table to hold the status bars for this character.	
	EMA.currencyFrameCharacterInfo[characterName] = {}
	-- Get the character info table.
	local currencyFrameCharacterInfo = EMA.currencyFrameCharacterInfo[characterName]
	currencyFrameCharacterInfo.characterRowTopPoint = top
	-- Set the characters name font string.
	local frameCharacterName = EMA.globalCurrencyFramePrefix.."CharacterName"
	local frameCharacterNameText = parentFrame:CreateFontString( frameCharacterName.."Text", "OVERLAY", "GameFontNormal" )
	frameCharacterNameText:SetText( Ambiguate( characterName , "none" ) )
	frameCharacterNameText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameCharacterNameText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameCharacterNameText:SetWidth( width * 2.5 )
	frameCharacterNameText:SetJustifyH( "LEFT" )
	currencyFrameCharacterInfo.characterNameText = frameCharacterNameText
	left = left + (spacing * 2)
	-- Set the Gold font string.
	local frameGold = EMA.globalCurrencyFramePrefix.."Gold"
	local frameGoldText = parentFrame:CreateFontString( frameGold.."Text", "OVERLAY", "GameFontNormal" )
	frameGoldText:SetText( "0" )
	frameGoldText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameGoldText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameGoldText:SetWidth( width )
	frameGoldText:SetJustifyH( "RIGHT" )
	currencyFrameCharacterInfo.GoldText = frameGoldText
	left = left + spacing
	-- Set the BagSpace font string.
	local frameBagSpace = EMA.globalCurrencyFramePrefix.."BagSpace"
	local frameBagSpaceText = parentFrame:CreateFontString( frameBagSpace.."Text", "OVERLAY", "GameFontNormal" )
	frameBagSpaceText:SetText( "0/0" )
	frameBagSpaceText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameBagSpaceText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameBagSpaceText:SetWidth( width )
	frameBagSpaceText:SetJustifyH( "RIGHT" )
	currencyFrameCharacterInfo.BagSpaceText = frameBagSpaceText
	left = left + spacing
	-- Set the Durability font string.
	local frameCharDurr = EMA.globalCurrencyFramePrefix.."CharDurr"
	local frameCharDurrText = parentFrame:CreateFontString( frameCharDurr.."Text", "OVERLAY", "GameFontNormal" )
	frameCharDurrText:SetText( "0"..L["%"] )
	frameCharDurrText:SetTextColor( 1.00, 1.00, 1.00, 1.00 )
	frameCharDurrText:SetPoint( "TOPLEFT", parentFrame, "TOPLEFT", left, top )
	frameCharDurrText:SetWidth( width )
	frameCharDurrText:SetJustifyH( "RIGHT" )
	currencyFrameCharacterInfo.CharDurrText = frameCharDurrText
	left = left + spacing	
	
	EMA:SettingsUpdateFontStyle()
end

function EMA:EMAToonHideCurrency()
	EMAToonCurrencyListFrame:Hide()
end

function EMA:EMAToonRequestCurrency()
	-- Colour Light Red.
	local r = 1.0
	local g = 0.42
	local b = 0.42
	local a = 0.6
	for characterName, currencyFrameCharacterInfo in pairs( EMA.currencyFrameCharacterInfo ) do
		--EMA.Print("DoRequestCurrency", characterName)
		-- Change Hight if a new member joins the team or leaves the team.
		local height1 = currencyFrameCharacterInfo.characterRowTopPoint
		local height2 = -35 + ( -15 * EMAApi.GetPositionForCharacterNameOnline( characterName) )
			if height1 < height2 then
				currencyFrameCharacterInfo.characterRowTopPoint = height2
			elseif height1 > height2 then
				currencyFrameCharacterInfo.characterRowTopPoint = height2
			end	
		if EMAApi.GetCharacterOnlineStatus ( characterName ) == false then
			-- Hides currency for offline members.
			--EMA.Print("offlineRemove", characterName )
			currencyFrameCharacterInfo.characterNameText:Hide()
			currencyFrameCharacterInfo.GoldText:Hide()
			currencyFrameCharacterInfo.BagSpaceText:Hide()
			currencyFrameCharacterInfo.CharDurrText:Hide()
		else
			currencyFrameCharacterInfo.characterNameText:Show()
			currencyFrameCharacterInfo.characterNameText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.GoldText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.BagSpaceText:SetTextColor( r, g, b, a )
			currencyFrameCharacterInfo.CharDurrText:SetTextColor( r, g, b, a )
		end
	end
	EMA.currencyTotalGold = 0
	EMA:EMASendCommandToTeam( EMA.COMMAND_REQUEST_CURRENCY, "" )
	EMA.SettingsRefresh()
	
end

function EMA:DoSendCurrency( characterName, dummyValue )
	--EMA:Print("Test2")
	if EMAApi.GetCharacterOnlineStatus ( characterName ) == true then
	table.wipe( EMA.currentCurrencyValues )
	EMA.currentCurrencyValues.currGold = GetMoney()
	-- BagSpace Maths
	local numFreeSlots, numTotalSlots = LibBagUtils:CountSlots("BAGS", 0)
	EMA.currentCurrencyValues.bagSpace = numFreeSlots
	EMA.currentCurrencyValues.bagSpaceMax = numTotalSlots
	-- Durability Maths
	local curTotal, maxTotal, broken = 0, 0, 0
	for i = 1, 18 do
		local curItemDurability, maxItemDurability = GetInventoryItemDurability(i)
		if curItemDurability and maxItemDurability then
			curTotal = curTotal + curItemDurability
			maxTotal = maxTotal + maxItemDurability
			if maxItemDurability > 0 and curItemDurability == 0 then
				broken = broken + 1
			end
		end
	end
	local durability = (curTotal / maxTotal) * 100
	local durabilityText = tostring(gsub( durability, "%.[^|]+", "") )	
	EMA.currentCurrencyValues.durability = durabilityText

	EMA:EMASendCommandToToon( characterName, EMA.COMMAND_HERE_IS_CURRENCY, EMA.currentCurrencyValues )
	else
		return
	end
end

function EMA:DoShowToonsCurrency( characterName, currencyValues )
	--EMA.Print("DoShowCurrency", characterName, EMA.currentCurrencyValues.currGold )
	local parentFrame = EMAToonCurrencyListFrame
	-- Get (or create and get) the character information.
	local currencyFrameCharacterInfo = EMA.currencyFrameCharacterInfo[characterName]
		--EMA.Print("Frame", characterName)
	if currencyFrameCharacterInfo == nil then
		EMA:CreateEMACurrencyFrameInfo( characterName, parentFrame )
		currencyFrameCharacterInfo = EMA.currencyFrameCharacterInfo[characterName]
	end
	-- Colour white.
	local r = 1.0
	local g = 1.0
	local b = 1.0
	local a = 1.0
	local v = 0
	
	currencyFrameCharacterInfo.GoldText:SetTextColor( r, g, b, a )
	currencyFrameCharacterInfo.characterNameText:SetTextColor( r, g, b, a )
	currencyFrameCharacterInfo.GoldText:SetTextColor( r, g, b, a )
	
	if currencyValues.bagSpace == 0 then 
		--EMA:Print("SetRed")
		currencyFrameCharacterInfo.BagSpaceText:SetTextColor( r, v, v, a )
	else
		--EMA:Print("SetWhite")
		currencyFrameCharacterInfo.BagSpaceText:SetTextColor( r, g, b, a )
	end	
	if currencyValues.durability == "0" then
		currencyFrameCharacterInfo.CharDurrText:SetTextColor( r, v, v, a )
	else
		--EMA:Print("SetWhite")
		currencyFrameCharacterInfo.CharDurrText:SetTextColor( r, g, b, a )
	end	
	
	currencyFrameCharacterInfo.GoldText:SetText( EMAUtilities:FormatMoneyString( currencyValues.currGold ) )
	currencyFrameCharacterInfo.BagSpaceText:SetText( currencyValues.bagSpace..L["/"]..currencyValues.bagSpaceMax )
	currencyFrameCharacterInfo.CharDurrText:SetText ( currencyValues.durability..L["%"] )
	
	-- Total gold.
	EMA.currencyTotalGold = EMA.currencyTotalGold + currencyValues.currGold
	parentFrame.TotalGoldText:SetText( EMAUtilities:FormatMoneyString( EMA.currencyTotalGold ) )
	-- Update width of currency list.
	EMA:CurrencyListSetColumnWidth()
	EMAToonCurrencyListFrame:Show()
end

-- A EMA command has been received.
function EMA:EMAOnCommandReceived( characterName, commandName, ... )
	if commandName == EMA.COMMAND_REQUEST_CURRENCY then
		EMA:DoSendCurrency( characterName, ... )
	end
	if commandName == EMA.COMMAND_HERE_IS_CURRENCY then
		EMA:DoShowToonsCurrency( characterName, ... )
	end
end
