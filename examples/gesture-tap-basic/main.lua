--====================================================================--
-- Gesture Tap Basic
--
-- Shows simple use of
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2012-2015 David McCuskey. All Rights Reserved.
--====================================================================--



print( '\n\n##############################################\n\n' )



--====================================================================--
--== Imports


local Gesture = require 'dmc_corona.dmc_gesture'

local TouchMgr = require 'dmc_corona.dmc_touchmanager'


--====================================================================--
--== Setup, Constants


local W, H = display.contentWidth, display.contentHeight
local H_CENTER, V_CENTER = W*0.5, H*0.5


local txt_display, txt_display_t
local timer_t



--====================================================================--
--== Support Functions


local function doDisplayEffect()
	if timer_t ~= nil then timer.cancel( timer_t ) end
	if txt_display_t ~= nil then transition.cancel( txt_display_t ) end

	timer_t = timer.performWithDelay( 250, function()
		timer_t = nil
		txt_display_t = transition.to( txt_display, {
			time=1000, alpha=0,
			onComplete=function() txt_display_t = nil end
		})
	end)
end

local function displayFeedback( str )
	txt_display.alpha=1
	txt_display.alpha=1
	txt_display:setTextColor( 0.8,0,0 )
	txt_display.text = str
	doDisplayEffect()
end

local function setupUI()
	local o = display.newText( "", 0, 0, native.systemFont, 30 )
	o.anchorX, o.anchorY = 0.5, 0
	o.x, o.y = H_CENTER, 50
	txt_display = o
end



local function gestureEvent_handler( event )
	-- print( "gestureEvent_handler" )
	if event.type == event.target.GESTURE then
		displayFeedback( "Gesture: "..tostring(event.gesture) )
	end
end


local function viewTouchEvent_handler( event )
	print("viewTouchEvent_handler", event, event.phase, event.isFocused )
end


--====================================================================--
--== Main
--====================================================================--


local function main()

	local view, tap

	setupUI()

	-- create touch area for gestures

	view = display.newRect( H_CENTER, V_CENTER+40, V_CENTER, V_CENTER )
	view:setFillColor( 0.3,0.3,0.3 )
	-- TouchMgr.register( view, viewTouchEvent_handler )

	-- create a gesture, link to touch area

	-- tap = Gesture.newTapGesture( view, {taps=2,touches=1} )
	tap = Gesture.newTapGesture( view )
	tap:addEventListener( tap.EVENT, gestureEvent_handler )


	-- tap = Gesture.removeGestures( view )

end


-- start the action !

main()
