//
//	ActionPlayFrames v 1.0 - effectQueue package
//	Russell Lowke, Wednesdaym April 11th 2012
//
//	Copyright (c) 2012 Lowke Media
//	see http://www.lowkemedia.com for more information
//	see http://code.google.com/p/lowke/ for code repository
//
//	Permission is hereby granted, free of charge, to any person obtaining a 
//	copy of this software and associated documentation files (the "Software"), 
//	to deal in the Software without restriction, including without limitation 
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//	and/or sell copies of the Software, and to permit persons to whom the 
//	Software is furnished to do so, subject to the following conditions:
// 
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
// 
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER	 
//	DEALINGS IN THE SOFTWARE. 
//
//

package com.lowke.actionQueue
{
    import com.lowke.playFrames.PlayFrames;
    
    import flash.display.MovieClip;
    
    public class ActionPlayFrames extends Action implements IAction
    {
        public static const PLAY_FRAMES_ACTION:String = "playFramesAction";
        
        private var _clip:MovieClip;
        private var _startLabel:String;
        private var _endLabel:String;
        private var _frameRate:Number;
        private var _duration:uint;
        private var _playEveryFrame:Boolean;
		private var _stopChildren:Boolean;
        private var _type:uint;
        private var _markAsFinishedWhenActionStarts:Boolean;
        
        public function ActionPlayFrames(clip:MovieClip,
                                         startLabel:String = null,
                                         endLabel:String = null,
                                         frameRate:Number = NaN,
                                         duration:uint = 0,
                                         playEveryFrame:Boolean = false,
										 stopChildren:Boolean = false,
                                         type:uint = 1 /* PlayFrames.TYPE_END */,
                                         markAsFinishedWhenActionStarts:Boolean = false) 
        {
            super(PLAY_FRAMES_ACTION);
            
            _clip = clip;
            _startLabel = startLabel;
            _endLabel = endLabel;
            _frameRate = frameRate;
            _duration = duration;
            _playEveryFrame = playEveryFrame;
			_stopChildren = stopChildren;
            _type = type;
            _markAsFinishedWhenActionStarts = markAsFinishedWhenActionStarts;
        }
        
        public override function playAction():void
        {
            var playFrames:PlayFrames = PlayFrames.play(_clip, _startLabel, _endLabel, _frameRate, _duration, _playEveryFrame, _stopChildren, _type);
            if (_markAsFinishedWhenActionStarts) 
            {
                finishAction();
            } 
            else 
            {
                playFrames.whenDone(finishAction);
            }
        }
    }
}