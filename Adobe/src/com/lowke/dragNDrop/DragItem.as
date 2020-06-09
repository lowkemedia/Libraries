//
//  DragItem v 1.0 - dragNDrop package
//  Russell Lowke, April 15th 2010
//
//  Copyright (c) 2010 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke/ for code repository
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

package com.lowke.dragNDrop
{   
    import com.lowke.animator.Animator;
    import com.lowke.animator.effect.tween.TweenFX;
    
    import flash.display.DisplayObject;
    import flash.display.FrameLabel;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BitmapFilter;
    import flash.filters.DropShadowFilter;
    import flash.media.Sound;
    
    public class DragItem extends MovieClip 
    {   
        // states
        public static var UP:String = "normal_up_state";
        public static var OVER:String = "roll_over_state";
        public static var DRAG:String = "drag_state";
        public static var RIGHT:String = "right_state";
        public static var WRONG:String = "wrong_state";
        
        // dispatched events
        public static var STARTED_DRAGGING:String = "drag_item_started_dragging";
        public static var FINISHED_MOVING:String = "drag_item_finished_moving";
        
        private static var _ani:Animator = Animator.instance;   // general animator
        private static var _defaultMoveSpeed:uint = 300;        // default move speed
        
        private var _view:MovieClip;                            // MovieClip view for the button
        private var _state:String;                              // current state, UP, DRAG, RIGHT or WRONG
        private var _upFrame:int = 1;                           // frame used in normal resting state
        private var _overFrame:int = 1;                         // frame used for rollovers
        private var _rightFrame:int = 2;                        // frame used for "right" feedback
        private var _wrongFrame:int = 3;                        // frame used for "wrong" feedback
        private var _dragFrame:int;                             // frame used while dragging
        private var _dragFilter:BitmapFilter;                   // filter used for dragging if no dragFrame supplied
        private var _seated:DropTarget;                         // DropTarget seated with this DragItem
        private var _rolledTarget:DropTarget;                   // currently rolled DropTarget
        private var _startX:Number;                             // start x location
        private var _startY:Number;                             // start y location
        private var _moveDuration:uint;                         // milliseconds taken to snap to destination
        private var _rollOverSound:Sound;                       // sound triggered on rollOver
        private var _dragSound:Sound;                           // sound triggered when item dragged clicked
        private var _dropSound:Sound;                           // sound triggered when item dropped
        private var _rightSound:Sound;                          // sound triggered when item graded as right
        private var _wrongSound:Sound;                          // sound triggered when item graded as wrong
        private var _returnToSeat:Boolean = false;              // if true will bounceBack to its last seated target
        
        
        public function DragItem(view:MovieClip = null) 
        {
            super();
            
            if (! view) 
            {
                _view = this;
            } 
            else 
            {
                _view = view;
                x += _view.x;
                y += _view.y;
                _view.x = 0;
                _view.y = 0;
                addChild(_view);
            }           
            
            _startX = x;
            _startY = y;
            _moveDuration = _defaultMoveSpeed;
            
            // find normal, over, drag, right, and wrong frames
            var upFrame:int = getFrameNumber(_view, "up");
            if (upFrame) 
            {
                _upFrame = upFrame;
            }
            
            var overFrame:int = getFrameNumber(_view, "over");
            if (overFrame) 
            {
                _overFrame = overFrame;
            }
            
            var rightFrame:int = getFrameNumber(_view, "right");
            if (rightFrame) 
            {
                _rightFrame = rightFrame;
            }
            
            var wrongFrame:int = getFrameNumber(_view, "wrong");
            if (wrongFrame) 
            {
                _wrongFrame = wrongFrame;
            }
            
            var dragFrame:int = getFrameNumber(_view, "drag");
            if (dragFrame) 
            {
                _dragFrame = dragFrame;
            } 
            else 
            {
                _dragFilter = new DropShadowFilter();
            }
            
            buttonMode = true;
            addEventListener(MouseEvent.ROLL_OVER, rollOver, false, 0, true);
            addEventListener(MouseEvent.ROLL_OUT, rollOut, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
            
            state = UP;
        }
        
        private function rollOver(evt:MouseEvent):void 
        {
            if (! enabled) 
            {
                return;
            }
            
            if (state == UP) 
            {
                state = OVER;
            }
        }
        
        private function rollOut(evt:MouseEvent):void 
        {   
            if (! enabled) 
            {
                return;
            }
            
            if (state == OVER) 
            {
                state = UP;
            }
        }
        
        private function mouseDown(evt:MouseEvent):void 
        {   
            if (! enabled) 
            {
                return;
            }
            
            dispatchEvent(new Event(STARTED_DRAGGING));
            DragItem.bringToTop(this);
            startDrag();
            addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
            
            state = DRAG;
        }
        
        private function enterFrame(evt:Event):void 
        {
            var target:DisplayObject = dropTarget;
            if (target && ! mouseOverSprite(target.parent as Sprite)) 
            {
                // verify target under mouse
                target = null;
            }
            rollTarget(target);
        }
        
        
        private function rollTarget(dObj:DisplayObject):void 
        {
            var target:DropTarget;
            if (dObj) 
            {
                if (findDropTargetWrapper(dObj)) 
                {
                    // found a DropTarget
                    target = findDropTargetWrapper(dObj);
                } 
                else if (findDragItemWrapper(dObj)) 
                {
                    // found a DragItem, target its seat
                    target = findDragItemWrapper(dObj).seated;
                }
            }
            
            // if target has changed
            if (_rolledTarget != target) 
            {
                if (_rolledTarget) 
                {
                    // remove highlight from previous target
                    _rolledTarget.state = DropTarget.NORMAL;
                }
                
                if (target) 
                {
                    // highlight new target
                    target.state = DropTarget.HIGHLIGHT;
                }
                
                _rolledTarget = target;
            }
        }
        
        private function mouseUp(evt:MouseEvent):void 
        {   
            if (! enabled) 
            {
                return;
            }
            
            stopDrag();
            removeEventListener(Event.ENTER_FRAME, enterFrame);
            
            if (_rolledTarget) 
            {
                if (_rolledTarget.seated) 
                {
                    swapWith(_rolledTarget.seated);
                } 
                else 
                {
                    seatOn(_rolledTarget);
                }
            } 
            else 
            {
                bounceBack();
            }
            
            rollTarget(null);
        }
        
        // much the same as seatOn, only sets _returnToSeat for you,
        //  which is desirable if it started on a target
        public function startOn(dropTarget:DropTarget):void 
        {
            _returnToSeat = true;
            var temp:uint = _moveDuration;
            _moveDuration = 0;  // snap to start location
            seatOn(dropTarget);
            _moveDuration = temp;
        }
        
        // seats a DragItem on a DropTarget, returning true if successful, false if not
        public function seatOn(dropTarget:DropTarget):Boolean 
        {
            if (dropTarget) 
            {
                return dropTarget.seat(this);
            } 
            else 
            {
                bounceBack();
                return false;
            }
        }
        
        private function swapWith(dragItem:DragItem):void 
        {   
            // remember the targets
            var myTarget:DropTarget = dragItem.seated;
            var otherTarget:DropTarget = _seated;
            
            // unseat the dragItems
            unseat();
            dragItem.unseat();
            
            // reseat dragItems
            dragItem.seatOn(otherTarget);
            seatOn(myTarget);
        }
        
        // unseat this DragItem from any DropTarget it is seated on
        public function unseat():void 
        {
            var temp:DropTarget = _seated;
            _seated = null;
            if (temp) 
            {
                temp.unseat();
            }
        }
        
        // bounce DragItem back to its last position
        public function bounceBack():void 
        {
            if (_returnToSeat && _seated && _seated.seat(this)) 
            {
                // if seated is returned to seated location
            } 
            else 
            {
                // otherwise reset back to start location
                reset();
            }
        }
        
        // reset DragItem back to start position
        public function reset(funct:Function = null):void
        {   
            // otherwise bounce back to start location
            unseat();
            Callback.oneArgs(this, FINISHED_MOVING, funct);
            animateToLoc(_startX, _startY);
        }
        
        public function animateToLoc(x:Number, 
                                     y:Number):void 
        {
            state = DRAG;
            DragItem.bringToTop(this);
            _ani.anime(this).addEffect(TweenFX.xyTo(x, y, _moveDuration)).whenDone(finishAnimate);
        }
        
        private function finishAnimate():void 
        {
            state = UP;
            dispatchEvent(new Event(FINISHED_MOVING));
        }
        
        // grade any DragItem as right or wrong
        public function grade():Boolean 
        {
            if (_seated) 
            {
                return _seated.grade();
            }
            
            state = DragItem.WRONG;
            return false;
        }
        
        public function setState(val:String):void 
        {   
            switch (val) 
            { 
                case RIGHT:
                    rightState();
                    break;
                
                case WRONG:
                    wrongState();
                    break;
                
                case OVER:
                    overState();
                    break;
                
                case DRAG:
                    dragState();
                    break;
                
                default:
                case UP:
                    upState();
                    break;
            }
        }
        
        public function upState():void 
        {
            _view.gotoAndStop(_upFrame);
            if (_dragFilter) 
            {
                filters = [];
            }
            
            if (_state == DRAG && _dropSound) 
            {
                _dropSound.play();
            }
            _state = UP;
        }
        
        public function overState():void 
        {
            _view.gotoAndStop(_overFrame);
            if (_dragFilter) 
            {
                filters = [];
            }
            
            if (_rollOverSound) 
            {
                _rollOverSound.play();
            }
            
            _state = OVER;
        }
        
        
        public function rightState():void 
        {
            _view.gotoAndStop(_rightFrame);
            if (_dragFilter) 
            {
                filters = [];
            }
            
            if (_rightSound && _state != RIGHT) 
            {
                _rightSound.play();
            }
            _state = RIGHT;
        }
        
        public function wrongState():void 
        {
            _view.gotoAndStop(_wrongFrame);
            if (_dragFilter) 
            {
                filters = [];
            }
            
            if (_wrongSound && _state != WRONG) 
            {
                _wrongSound.play();
            }
            _state = WRONG;
        }
        
        public function dragState():void 
        {   
            if (_dragFilter) 
            {
                _view.gotoAndStop(_overFrame);
                filters = [_dragFilter];
            } 
            else 
            {
                _view.gotoAndStop(_dragFrame);
            }
            
            if (_dragSound) 
            {
                _dragSound.play();
            }
            _state = DRAG;
        }
        
        
        
        //
        //  static helper methods
        
        //
        // looks through parent objects for DropTarget wrapper
        private static function findDropTargetWrapper(dObj:DisplayObject):DropTarget 
        {
            if (dObj is DropTarget) 
            {
                return dObj as DropTarget;
            } 
            else if (dObj.parent) 
            {
                return findDropTargetWrapper(dObj.parent);
            } 
            else 
            {
                return null;
            }
        }
        
        //
        // looks through parent objects for DragItem wrapper
        private static function findDragItemWrapper(dObj:DisplayObject):DragItem 
        {
            if (dObj is DragItem)
            {
                return dObj as DragItem;
            } 
            else if (dObj.parent) 
            {
                return findDragItemWrapper(dObj.parent);
            } 
            else 
            {
                return null;
            }
        }
        
        
        //
        // accessors and mutators
        public static function get defaultMoveSpeed():uint                  { return _defaultMoveSpeed; }
        public function get state():String                                  { return _state; }
        public function get seated():DropTarget                             { return _seated; }
        public function get moveDuration():uint                             { return _moveDuration; }
        public function get dragFilter():BitmapFilter                       { return _dragFilter; }
        public function get startX():Number                                 { return _startX; }
        public function get startY():Number                                 { return _startY; }
        public function get rollOverSound():Sound                           { return _rollOverSound; }
        public function get dragSound():Sound                               { return _dragSound; }
        public function get dropSound():Sound                               { return _dropSound; }
        public function get rightSound():Sound                              { return _rightSound; }
        public function get wrongSound():Sound                              { return _wrongSound; }
        public function get returnToSeat():Boolean                          { return _returnToSeat; }
        public function get view():MovieClip                                { return _view; }
        
        
        public static function set defaultMoveSpeed(val:uint):void          { _defaultMoveSpeed = val; }
        public function set state(val:String):void                          { setState(val); }
        public function set seated(val:DropTarget):void                     { _seated = val; }
        public function set dragFilter(val:BitmapFilter):void               { _dragFilter = val; }
        public function set moveDuration(val:uint):void                     { _moveDuration = val; }
        public function set startX(val:Number):void                         { _startX = val; }
        public function set startY(val:Number):void                         { _startY = val; }
        public function set rollOverSound(val:Sound):void                   { _rollOverSound = val; }
        public function set dragSound(val:Sound):void                       { _dragSound = val; }
        public function set dropSound(val:Sound):void                       { _dropSound = val; }
        public function set rightSound(val:Sound):void                      { _rightSound = val; }
        public function set wrongSound(val:Sound):void                      { _wrongSound = val; }
        public function set returnToSeat(val:Boolean):void                  { _returnToSeat = val; }
        
        
        
        //
        // return true if the mouse over sprite
        public static function mouseOverSprite(sprite:Sprite, 
                                               shapeFlag:Boolean = true):Boolean 
        {
            return (sprite && sprite.stage && sprite.hitTestPoint(sprite.stage.mouseX, sprite.stage.mouseY, shapeFlag));
        }
        
        //
        // bring a sprite to the top of its display list
        public static function bringToTop(sprite:Sprite):void 
        {
            sprite.parent.setChildIndex(sprite, sprite.parent.numChildren - 1);
        }
        
        //
        // returns the frame number of a specifc label on a MovieClip
        public static const NO_FRAME:int = 0;   
        public static function getFrameNumber(movieClip:MovieClip, label:String):uint 
        {
            var frameLabels:Array = movieClip.currentLabels;
            var nLabels:uint = frameLabels.length;
            for (var i:uint = 0; i < nLabels; ++i) 
            {
                var frameLabel:FrameLabel = frameLabels[i];
                if (frameLabel.name == label) 
                {
                    return frameLabel.frame;
                }
            }
            return NO_FRAME;
        }
    }
}