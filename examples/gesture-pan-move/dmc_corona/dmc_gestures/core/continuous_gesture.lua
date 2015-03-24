--====================================================================--
-- dmc_corona/dmc_gesture/core/continous_gesture.lua
--
-- Documentation:
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2015 David McCuskey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]



--====================================================================--
--== DMC Corona Library : Continuous Continuous Base
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Continuous Continuous
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

local Gesture = require 'dmc_gestures.core.gesture'


--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass



--====================================================================--
--== Continuous Base Class
--====================================================================--


local Continuous = newClass( Gesture, { name="Continuous" } )

--== Class Constants

Continuous.TYPE = nil -- override this

--== State Constants

Continuous.STATE_BEGAN = 'state_began'
Continuous.STATE_CHANGED = 'state_changed'
Continuous.STATE_CANCELED = 'state_cancelled'

--== Event Constants

Continuous.BEGAN = 'began'
Continuous.CHANGED = 'changed'
Continuous.ENDED = 'ended'
Continuous.RECOGNIZED = Continuous.ENDED

--======================================================--
-- Start: Setup DMC Objects

--[[
function Continuous:__init__( params )
	-- print( "Continuous:__init__", params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--
	--== Create Properties ==--
end
--]]
--[[
function Continuous:__undoInit__()
	-- print( "Continuous:__undoInit__" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]

--[[
function Continuous:__initComplete__()
	-- print( "Continuous:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
end
--]]

--[[
function Continuous:__undoInitComplete__()
	-- print( "Continuous:__undoInitComplete__" )
	--==--
	self:superCall( ObjectBase, '__undoInitComplete__' )
end
--]]

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods




--====================================================================--
--== Private Methods


--- calculate the "middle" of touch points in this gesture
-- @param table of touches
-- @return Coordinate table of coordinates
--
function Continuous:_calculateCentroid( touches )
	-- print("Continuous:_calculateCentroid" )
	local cnt=0
	local x,y = 0,0
	for _, te in pairs( touches ) do
		x=x+te.x ; y=y+te.y
		cnt=cnt+1
	end
	return {x=x/cnt,y=y/cnt}
end


-- this one goes to the Gesture consumer (who created gesture)
function Continuous:_startMultitouchEvent()
	-- print("Continuous:_startMultitouchEvent" )
	local pos = self:_calculateCentroid( self._touches )
	local me = {
		id=self._id,
		gesture=self.TYPE,
		phase=Continuous.BEGAN,
		xStart=pos.x,
		yStart=pos.y,
		x=pos.x,
		y=pos.y,
		count=self._touch_count,
		touches=self._touches
	}
	self._multitouch_evt = me
	return me
end

function Continuous:_updateMultitouchEvent()
	-- print("Continuous:_updateMultitouchEvent" )
	local pos = self:_calculateCentroid( self._touches )
	local me = self._multitouch_evt

	me.phase = Continuous.CHANGED
	me.x, me.y = pos.x, pos.y
	me.count=self._touch_count

	return me
end

function Continuous:_endMultitouchEvent()
	-- print("Continuous:_endMultitouchEvent" )
	local pos = self:_calculateCentroid( self._touches )
	local me = self._multitouch_evt

	me.phase = Continuous.ENDED
	me.x, me.y = pos.x, pos.y
	me.count=self._touch_count

	self._multitouch_evt = nil
	return me
end


-- this one goes to the Gesture consumer (who created gesture)
function Continuous:_dispatchBeganEvent()
	-- print("Continuous:_dispatchBeganEvent" )
	local me = self:_startMultitouchEvent()
	self:dispatchEvent( self.GESTURE, me, {merge=true} )
end

-- this one goes to the Gesture consumer (who created gesture)
function Continuous:_dispatchChangedEvent()
	-- print("Continuous:_dispatchChangedEvent" )
	local me = self:_updateMultitouchEvent()
	self:dispatchEvent( self.GESTURE, me, {merge=true} )
end

-- this one goes to the Gesture consumer (who created gesture)
function Continuous:_dispatchRecognizedEvent()
	-- print("Continuous:_dispatchRecognizedEvent" )
	local me = self:_endMultitouchEvent()
	self:dispatchEvent( self.GESTURE, me, {merge=true} )
end




--====================================================================--
--== Event Handlers


Continuous.touch = Gesture.touch



--====================================================================--
--== State Machine


function Continuous:state_possible( next_state, params )
	-- print( "Continuous:state_possible: >> ", next_state )

	--== Check Delegate to see if this transition is OK

	local del = self._delegate
	local f = del and del.gestureShouldBegin
	local shouldBegin = true
	if f then shouldBegin = f( self ) end
	if not shouldBegin then next_state=Continuous.STATE_FAILED end

	--== Go to next State

	if next_state == Continuous.STATE_FAILED then
		self:do_state_failed( params )

	elseif next_state == Continuous.STATE_BEGAN then
		self:do_state_began( params )

	elseif next_state == Continuous.STATE_POSSIBLE then
		self:do_state_possible( params )

	else
		print( "WARNING :: Continuous:state_possible " .. tostring( next_state ) )
	end
end


--== State Began ==--

function Continuous:do_state_began( params )
	-- print( "Continuous:do_state_began", params )
	params = params or {}
	if params.notify==nil then params.notify=true end
	--==--
	self:setState( Continuous.STATE_BEGAN )
	self:_dispatchGestureNotification( params.notify )
	self:_dispatchStateNotification( params.notify )
	self:_dispatchBeganEvent()
end

function Continuous:state_began( next_state, params )
	-- print( "Continuous:state_began: >> ", next_state, params )

	if next_state == Continuous.STATE_CHANGED then
		self:do_state_changed( params )
	else
		print( "WARNING :: Continuous:state_began " .. tostring( next_state ) )
	end
end


--== State Changed ==--

function Continuous:do_state_changed( params )
	-- print( "Continuous:do_state_changed" )
	params = params or {}
	if params.notify==nil then params.notify=true end
	--==--
	self:setState( Continuous.STATE_CHANGED )
	self:_updateMultitouchEvent()
	self:_dispatchStateNotification( params.notify )
	self:_dispatchChangedEvent()
end

function Continuous:state_changed( next_state, params )
	-- print( "Continuous:state_changed: >> ", next_state )

	if next_state == Continuous.STATE_CHANGED then
		self:do_state_changed( params )

	elseif next_state == Continuous.STATE_CANCELED then
		self:do_state_cancelled( params )

	elseif next_state == Continuous.STATE_RECOGNIZED then
		self:do_state_recognized( params )

	else
		print( "WARNING :: Continuous:state_changed " .. tostring( next_state ) )
	end
end


--== State Recognized ==--

function Continuous:do_state_recognized( params )
	-- print( "Continuous:do_state_recognized", self._id )
	params = params or {}
	if params.notify==nil then params.notify=true end
	--==--
	self:setState( Continuous.STATE_RECOGNIZED )
	self:_dispatchStateNotification( params.notify )
	self:_dispatchRecognizedEvent()
end


--== State Canceled ==--

function Continuous:do_state_cancelled( params )
	-- print( "Continuous:do_state_cancelled" )
	params = params or {}
	if params.notify==nil then params.notify=true end
	--==--
	self:setState( Continuous.STATE_CANCELED )
	self:_endMultitouchEvent()
	self:_dispatchStateNotification( params.notify )
end

function Continuous:state_cancelled( next_state, params )
	-- print( "Continuous:state_cancelled: >> ", next_state )

	if next_state == Continuous.STATE_POSSIBLE then
		self:do_state_possible( params )

	else
		print( "WARNING :: Continuous:state_cancelled " .. tostring( next_state ) )
	end
end



return Continuous
