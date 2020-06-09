//
//  FrameController v 1.6 - buttonController package
//  Russell Lowke, June 30th 2013
//
//  Copyright (c) 2011-2013 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke-buttoncontroller/ for code repository
//  see http://code.google.com/p/lowke/ for entire lowke code repository
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER  
//  DEALINGS IN THE SOFTWARE. 
//
//

package com.lowke.buttonController.controller
{
    import com.lowke.buttonController.ButtonController;
    import com.lowke.logger.Logger;
    import com.lowke.playFrames.PlayFrames;
    import com.lowke.playFrames.event.FramesFinishedEvent;
    
    import flash.display.MovieClip;
    import flash.events.Event;

    public class FrameController
    {   
        /** frame constants */
        public static const UP:String               = "up";
        public static const OVER:String             = "over";
        public static const DOWN:String             = "down";
        public static const SELECTED:String         = "selected";
        public static const DISABLED:String         = "disabled";
        
        public static const HOT_SPOT:String         = "hotSpot";
        
        private var _view:MovieClip;                        // MovieClip view being controlled
        private var _buttonController:ButtonController;     // ButtonController that created this FrameController
        private var _playFrames:PlayFrames;                 // used for playing frames of _view backwards and forwards at fps
        private var _fps:Number = NaN;                      // fps used to animate button, defaults to frame rate of stage
        private var _frame:String;                          // (read only) frame is UP, OVER, DOWN, SELECTED or DISABLED
        private var _upFrameNumber:int = 1;                 // frame of _view used to display up frame, defaults to frame 1
        private var _overFrameNumber:int = 2;               // frame of _view used to display over frame, defaults to frame 2
        private var _downFrameNumber:int = 3;               // frame of _view used to display down frame, defaults to frame 3
        private var _selectedFrameNumber:int = 3;           // frame of _view used to display selected frame, defaults to frame 3 (same as down)
        private var _disabledFrameNumber:int;               // frame of _view used to display disabled frame
        
        
        public function FrameController(buttonController:ButtonController) 
        {
            _buttonController = buttonController;
        }
        
        public function initialize():void
        {
            _view = _buttonController.view as MovieClip;
            
            if (! _view) 
            {
                Logger.warning("FrameController must control a MovieClip.", ButtonController.WARNING_FRAME_CONTROLLER_NEEDS_MOVIECLIP);
            }
            
            setFrames("");
        }
        
        //
        // assign the up, over, down and disabled frames 
        // according to a state String keyword
        public function setFrames(state:String):void 
        {   
            //
            // find label frames on _view MovieClip and ensure no frames incorrectly labeled with "_" prefix,
            //  as "_up", "_over", or "_down" frame labels will cause a conflict when _view.buttonMode is true;
            var frameTypes:Array = [UP, OVER, DOWN];
            var div:String = (state == "") ? "" : "_";
            
            // reset snapTo flags
            _buttonController.snapFromUp        = false;
            _buttonController.snapOverToDown    = false;
            _buttonController.snapOverToUp      = false;
            _buttonController.snapFromDown      = false;
            
            for each (var frameType:String in frameTypes) 
            {
                var frame:int;
                
                // check for illegal '_' prefix
                frame = PlayFrames.getFrameNumber(_view, "_" + frameType);
                if (frame != PlayFrames.NO_FRAME) 
                {
                    Logger.warning(frameType + " frame on MovieClip instance \"" + _view.name + "\" is labeled \"_" + frameType +
                        "\" and should be labeld \"" + frameType + "\" (without \"_\").",
                        ButtonController.WARNING_DONT_USE_UNDERSCORE);
                    setFrameNumber(frameType, frame);
                    continue;
                }
                
                // check for '-' prefix
                frame = PlayFrames.getFrameNumber(_view, '-' + frameType + div + state);
                if (frame != PlayFrames.NO_FRAME) 
                {
                    setFrameNumber(frameType, frame);
                    
                    switch (frameType) 
                    {
                        case UP:
                            Logger.warning("On MovieClip instance " + _view.name +
                                " the dash indicator on label '-up' has no effect, label should be 'up' or 'up-'.", 
                                ButtonController.WARNING_DASH_INDICATOR_IGNORED);
                            break;
                        case OVER:
                            _buttonController.snapOverToUp = true;
                            break;
                        case DOWN:
                            _buttonController.snapFromDown = true;
                            break;
                    }
                    continue;
                }
                
                // check for suffix '-'
                frame = PlayFrames.getFrameNumber(_view, frameType + div + state + '-');
                if (frame != PlayFrames.NO_FRAME) 
                {
                    setFrameNumber(frameType, frame);
                    
                    switch (frameType) 
                    {
                        case UP:
                            _buttonController.snapFromUp = true;
                            break;
                        case OVER:
                            _buttonController.snapOverToDown = true;
                            break;
                        case DOWN:
                            Logger.warning("On MovieClip instance " + _view.name +
                                " the dash indicator on label 'down-' has no effect, label should be 'down' or '-down'.", 
                                ButtonController.WARNING_DASH_INDICATOR_IGNORED); 
                            break;
                    }
                    continue;
                }
                
                // check for special case OVER with both '-' prefix and suffix '-'
                if (frameType == OVER) 
                {
                    frame = PlayFrames.getFrameNumber(_view, '-' + frameType + div + state + '-');
                    if (frame != PlayFrames.NO_FRAME) 
                    {
                        setFrameNumber(frameType, frame);
                        _buttonController.snapOverToDown = true;
                        _buttonController.snapOverToUp = true;
                        continue;
                    }
                }
                
                // check for frame
                frame = PlayFrames.getFrameNumber(_view, frameType + div + state);
                if (frame) 
                {
                    setFrameNumber(frameType, frame);
                } 
                else 
                {
                    if (stringHasValue(state) && frameType == UP) 
                    {
                        Logger.warning("Could not find up frame for state \"" + state + "\" (should be labeled \"" + frameType + div + state + "\") on MovieClip instance " + _view.name + ".",
                            ButtonController.WARNING_CANT_FIND_UP_LABEL);
                    }
                }
                
                // check for hit area
                var hitClip:MovieClip = _view[HOT_SPOT];
                if (hitClip) 
                {
                    _view.hitArea = hitClip;
                }
            }
            
			// check for a selected frame
			_selectedFrameNumber = PlayFrames.getFrameNumber(_view, SELECTED + div + state);
			if (_selectedFrameNumber == PlayFrames.NO_FRAME) 
			{
				_selectedFrameNumber = _downFrameNumber;
			}
			
			// check for a disabled frame
			_disabledFrameNumber = PlayFrames.getFrameNumber(_view, DISABLED + div + state);
			if (_disabledFrameNumber == PlayFrames.NO_FRAME) 
			{
				_disabledFrameNumber = PlayFrames.getFrameNumber(_view, DISABLED);
			}
        }
        
        private function setFrameNumber(frameType:String, frame:uint):void
        {
            switch (frameType) 
            {
                case UP:        _upFrameNumber   = frame;       break;
                case OVER:      _overFrameNumber = frame;       break;
                case DOWN:      _downFrameNumber = frame;       break;
            }
        }
        
        public function gotoFrame(frame:String):void 
        {
            _frame = frame;
            removePlayFrames();
            var mFrameNumber:uint = frameNumber(frame);
            _view.gotoAndStop(mFrameNumber);
        }
        
        public function playFrames(startFrame:String, 
                                   endFrame:String, 
                                   type:int = 1,
                                   funct:Function = null):void
        {   
            var startFrameNumber:uint = frameNumber(startFrame);
            var endFrameNumber:uint = frameNumber(endFrame);
            
            //
            // If the start frame is the end frame 
            //  or we're animating over only one frame then snap to end frame
            if (startFrameNumber == endFrameNumber || 
                type == PlayFrames.TYPE_END &&
                (Math.abs(endFrameNumber - startFrameNumber) == 1)) 
            {
                // snap to frame 
                gotoFrame(endFrame);
                
                // call the function
                if (funct != null) 
                {
                    funct();
                }
            } 
            else 
            {
                _frame = endFrame;
                
                //
                // play (or looping) over a sequence of frames
                
                // if the current frame is within the range of the 
                //  the animation then start on the current frame
                var currentFrameNumber:uint = _view.currentFrame;
                if (type == PlayFrames.TYPE_END && 
                    withinRange(currentFrameNumber, startFrameNumber, endFrameNumber)) 
                {
                    startFrameNumber = currentFrameNumber;
                }
                
                // play sequence of frames
                _playFrames = PlayFrames.playFrames(_view, startFrameNumber, endFrameNumber, _fps);
                _playFrames.playEveryFrame = true;
                _playFrames.type = type;
                
                // and call the function once animation has finished
                if (funct != null) 
                {
                    // listen for batch complete
                    var listener:Function = function (event:Event):void 
                    {
                        _view.removeEventListener(FramesFinishedEvent.PLAY_FRAMES_FINISHED, listener);
                        funct();
                    };
                    _view.addEventListener(FramesFinishedEvent.PLAY_FRAMES_FINISHED, listener);
                }
            }
        }
        
        private function frameNumber(frame:String):int 
        {
            switch (frame) 
            {
                case UP:
                    return _upFrameNumber;
                case OVER:
                    return _overFrameNumber;
                case DOWN:
                    return _downFrameNumber;
                case SELECTED:
                    return _selectedFrameNumber;
                case DISABLED:
                    if (_disabledFrameNumber) 
                    {
                        return _disabledFrameNumber;
                    }
            }
            
            // otherwise give default
            if (_buttonController.selected) 
            {
                return _downFrameNumber;
            } 
            else 
            {
                return _upFrameNumber;
            }
        }
        
        // return true if there is no specific disabled frame
        public function noDisabledFrame():Boolean 
        {
            return (_disabledFrameNumber == PlayFrames.NO_FRAME);
        }
        
        // snap to end and stop any existing animation
        public function removePlayFrames():void 
        {
            if (_playFrames) 
            {
                _playFrames.end();
            }
            _playFrames = null;
        }
        
        public function get playing():Boolean
        { 
            return (_playFrames && _playFrames.playing); 
        }
        
        public function get fps():uint
        {
            return _fps; 
        }
        
        public function get frame():String
        { 
            return _frame; 
        }
        
        public function set fps(value:uint):void
        {
            _fps = value;
        }
        
        //
        // Static helper functions
        //
        
        /**
         * Specifies whether the specified string is either non-null, or contains
         * characters (i.e. length is greater that 0)
         * 
         * @param string The string which is being checked for a value
         * @return Returns true if the string has a value
         */
        public static function stringHasValue(string:String):Boolean
        {
            return (string != null && string.length > 0);           
        }
        
        /**
         * Returns true if value with range of other two values.
         * 
         * @param value Value being checked if within range of other tqo parameters.
         * @param valueA First value defining range limit.
         * @param valueB Second value defining range limit.
         */
        private static function withinRange(value:Number, 
                                            valueA:Number, 
                                            valueB:Number):Boolean 
        {   
            var low:Number;
            var high:Number;
            if (valueA < valueB) 
            {
                low = valueA;
                high = valueB;
            } 
            else 
            {
                low = valueB;
                high = valueA;
            }
            
            if (value < low) 
            {
                return false;
            } 
            else if (value > high)
            {
                return false;
            } 
            else 
            {
                return true;
            }
        }
    }
}