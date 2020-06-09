//
//  ToolTip v 2.0 - toolTip package
//  Russell Lowke, October 4th 2011
// 
//  Copyright (c) 2010-2011 Lowke Media
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

//
//  Usage:
//
//  A nice example of skinning the ToolTip is,
//
//  Tooltip.font = "Verdana";
//  Tooltip.fontSize = 14;
//  Tooltip.fontColor = 0xFFFFFF;
//  Tooltip.bold = true;
//  Tooltip.bgColor = 0x202020;
//  Tooltip.bgAlpha = 0.85;
//  Tooltip.dropShadow = 0;
//  Tooltip.lineColor = 0x000000;
//  Tooltip.lineThinkness = 1;
//  Tooltip.ellipseWidth = 24;
//  Tooltip.padding = 6;
//  Tooltip.minWidth = 70;
//  Tooltip.maxWidth = 180;
//  Tooltip.leading = 1;
//
//
//  To apply the tooltip to a display object simply,
//
//  ToolTip.addToolTip(displayObject, "toolTipText");



package com.lowke.tooltip
{
    import com.lowke.animator.Animator;
    import com.lowke.animator.effect.DelayFX;
    import com.lowke.animator.effect.tween.TweenFX;
    import com.lowke.animator.effect.tween.easing.adobe.Sine;
    import com.lowke.logger.Logger;
    
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.geom.Rectangle;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.Dictionary;
    
    public class Tooltip extends Sprite 
    {
        //
        // error, warning and ifo IDs
        public static const LOG_PREFIX:String = "TTP";
        public static const WARNING_SKIN_NOT_SET:String = "TTP00";
        public static const DEBUG_REMOVED_FROM_STAGE:String = "TTP01";
        
        public static const USE_DEFAULT:int = -1;                       // -1 indicates to use _defaultDuration delay duration
        
        private static const FADEIN_DURATION:uint = 200;                // duration of ttip fadein in milliseconds
        private static const FADEOUT_DURATION:uint = 300;               // duration of ttip fadeout in milliseconds
        
        // defaults
        private static var _bgColor:uint            = 0xFFFFBB;         // yellow color used
        private static var _bgAlpha:Number          = 1;                // alpha for the bg box
        private static var _dropShadow:uint         = 2;                // drop shadow distance
        private static var _lineColor:uint          = 0x000000;         // line color used
        private static var _lineThinkness:uint      = 1;                // line thickness used
        private static var _ellipseWidth:Number     = 0;                // ellipseWidth of box corners. 0 = none.
        private static var _font:String             = "_sans";          // generic sans serif font default
        private static var _fontSize:int            = 14;               // pt size of font used
        private static var _fontColor:uint          = 0x000000;         // color of font
        private static var _bold:Boolean            = false;            // bold font
        private static var _italic:Boolean          = false;            // italic font
        private static var _kerning:Boolean         = true;             // if true kerning used when formatting text
        private static var _leading:int             = 0;                // leading used when formatting text
        private static var _letterSpacing:Number    = 0;                // letterSpacing used when formatting text
        private static var _padding:uint            = 2;                // padding used around elements
        private static var _displacement:uint       = 8;                // x and y displacement of tooltip from mouse location
        private static var _minWidth:Number         = NaN;              // minimum width
        private static var _maxWidth:Number         = NaN;              // maximum width
        private static var _defaultDuration:uint    = 1500;             // default duration for tip to appear, in milliseconds
        
        private static var _toolTips:Dictionary = new Dictionary();     // hash of all toolTips
        private static var _fadeEffect:TweenFX;                         // effect used to fade out tool tip
        private static var _displayedToolTip:Tooltip;                   // currently displayed tooltip, will be null if no tooltip shown
        private var _ani:Animator;                                      // Animator
        protected var _displayObject:DisplayObject;                     // parent of ToolTip
        protected var _box:Shape;                                       // box shape used for background of tool tip
        protected var _textField:TextField;                             // text field used for tooltip
        private var _enabled:Boolean = true;                            // tooltip only appears if enabled
        private var _duration:uint;                                     // duration in milliseconds for tip to appear
        private var _displaceX:uint;                                    // x displacement used by tooltip
        private var _displaceY:uint;                                    // y displacement used by tooltip,
        protected var _useMousePosition:Boolean;                            // by default tooltips use mouse position
        private var _persist:Boolean = false;                           // if persist true then tooltip not auto removed when removed from stage
        protected var _message:String;                                  // text messgae displayed
        
        
        //
        // Static helper functions for dealing with Tooltips
        //
        
        public static function addToolTip(displayObject:DisplayObject,
                                          message:String,
                                          useMousePosition:Boolean = false, 
                                          duration:int = USE_DEFAULT):Tooltip 
        {   
            return new Tooltip(displayObject, message, useMousePosition, duration);
        }
        
        public static function removeToolTip(displayObject:DisplayObject):void 
        {
            var toolTip:Tooltip = _toolTips[displayObject];
            if (toolTip) 
            {
                toolTip.close();
            }
        }
        
        public static function getToolTip(displayObject:DisplayObject):Tooltip {
            return _toolTips[displayObject] as Tooltip;
        }
        
        public function Tooltip(displayObject:DisplayObject,
                                message:String,
                                useMousePosition:Boolean = false,
                                duration:int = USE_DEFAULT) 
        {
            super();
            
            if (duration < 0 || duration == USE_DEFAULT) 
            {
                _duration = _defaultDuration;
            } 
            else if (duration == 0) 
            {
                // duration should never be 0
                _duration = 1;
            } 
            else 
            {
                _duration = duration;
            }
            
            _ani = Animator.instance;
            _displayObject = displayObject;
            _message = message;
            _useMousePosition = useMousePosition;
            _displaceX = _displacement;
            _displaceY = _displacement;
            
            // remove any ToolTip already on the DisplayObject
            removeToolTip(_displayObject);
            
            // build textField to find height of message
            _textField = new TextField();
            _textField.selectable = false;
            _textField.multiline = true;
            _textField.text = _message;
            _textField.wordWrap = false;
            _textField.autoSize = TextFieldAutoSize.CENTER;
            _textField.mouseEnabled = false;
            
            var textFormat:TextFormat;
            textFormat = _textField.getTextFormat();
            textFormat.font = _font;
            textFormat.size = _fontSize;
            textFormat.color = _fontColor;
            textFormat.bold = _bold;
            textFormat.italic = _italic;
            textFormat.align = TextFormatAlign.CENTER;
            textFormat.kerning = _kerning;
            textFormat.leading = _leading;
            textFormat.letterSpacing = _letterSpacing;
            var font:Font = getFont(_font);
            _textField.embedFonts = (font) ? true : false;
            _textField.setTextFormat(textFormat);
            
            // check for minimum and maximum width
            if (_minWidth && _textField.width + _padding*2 < _minWidth) 
            {
                _textField.autoSize = TextFieldAutoSize.NONE;
                _textField.width = _minWidth - _padding*2;
            } 
            else if (_maxWidth && _textField.width + _padding*2 > _maxWidth) 
            {
                _textField.wordWrap = true;
                _textField.width = _maxWidth - _padding*2;
            }
            
            // add background box
            var boxHeight:Number = _textField.height + _padding*2;
            var boxWidth:Number = _textField.width + _padding*2;
            _box = new Shape();
            _box.graphics.beginFill(_bgColor, _bgAlpha);
            _box.graphics.lineStyle(_lineThinkness, _lineColor);
            _box.graphics.drawRoundRect(x, y, boxWidth, boxHeight, _ellipseWidth);
            addChild(_box);
            
            // add message text
            _textField.y = y + _padding;
            _textField.x = x + _padding;
            this.mouseEnabled = false;
            addChild(_textField);
            
            // add dropshadow
            if (_dropShadow) 
            {
                this.filters = [ new DropShadowFilter(_dropShadow) ];
            }
            
            // add listeners
            _displayObject.addEventListener(MouseEvent.ROLL_OVER, mouseOver);
            _displayObject.addEventListener(MouseEvent.ROLL_OUT, mouseOut);
            _displayObject.addEventListener(Event.MOUSE_LEAVE, mouseOut);
            _displayObject.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            
            // keep reference
            _toolTips[_displayObject] = this;
        }
        
        public function close():void 
        {
            hideToolTip();
            
            _displayObject.removeEventListener(MouseEvent.ROLL_OVER, mouseOver);
            _displayObject.removeEventListener(MouseEvent.ROLL_OVER, mouseOut);
            _displayObject.removeEventListener(Event.MOUSE_LEAVE, mouseOut);
            _displayObject.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            
            _toolTips[_displayObject] = null;
            delete _toolTips[_displayObject];
        }
        
        public function hideToolTip():void 
        {
            if (_fadeEffect && _fadeEffect.target == this) 
            {
                _fadeEffect = null;
            }
            _ani.anime(this).removeEffects();
            
            if (_displayObject.stage && _displayObject.stage.contains(this)) 
            {
                parent.removeChild(this);
            }
            
            if (_displayedToolTip == this) 
            {
                _displayedToolTip = null;
            }
        }
        
        public static function hideToolTip():void
        {
            if (_displayedToolTip) 
            {
                _displayedToolTip.hideToolTip();
            }
        }
        
        private function removedFromStage(event:Event):void 
        {
            if (_persist) 
            {
                hideToolTip();
            } 
            else 
            {
                close();
                Logger.debug("ToolTip for displayObject \"" +  _displayObject.name + "\" auto-removed because it was removed from the stage.\n" +
                    "Set persist to true to prevent this from happening.\n" +
                    "ToolTips set to persist should be disposed of using close() when no longer needed.", DEBUG_REMOVED_FROM_STAGE);
            }
        }
        
        public function mouseOver(event:MouseEvent = null):void 
        {
            if (_enabled) 
            {
                if (_fadeEffect) 
                {
                    // if fade effect in progress
                    //  immediately show tool tip
                    showToolTip();
                } 
                else 
                {
                    // otherwise delay before showing tool tip
                    _ani.anime(this).addEffect(new DelayFX(_duration)).whenDone(showToolTip);
                }
            }
        }
        
        public function showToolTip():void 
        {   
            _ani.anime(this).removeEffectNamed("DelayFX", false, false);
            
            // cut short any fade effect in progress
            if (_fadeEffect) 
            {
                var toolTip:Tooltip = _fadeEffect.target as Tooltip;
                toolTip.hideToolTip();
            }
            
            positioning();
            
            _ani.anime(this).addEffect(new TweenFX("alpha", 0, 1, FADEIN_DURATION, Sine.easeOut));
            _displayObject.stage.addChild(this);
            _displayedToolTip = this;
        }
        
        protected function positioning():void
        {
            var mStage:Stage = _displayObject.stage;
            var rect:Rectangle = _displayObject.getRect(mStage);
            
            // start with tooltip in center of sprite
            var nX:Number = rect.x + rect.width/2;      
            var nY:Number = rect.y + rect.height/3;
            
            if (_useMousePosition) 
            {
                // start tooltip at mouse position
                nX = mStage.mouseX;
                nY = mStage.mouseY;
            }
            
            if ((nX + width + _displaceX) < mStage.stageWidth) 
            {
                // draw on right
                nX += _displaceX;
            } 
            else 
            {
                // draw on left
                nX -= (width + _displaceX);
            }
            
            if ((nY - (height + _displaceY)) > 0) 
            {
                // draw above
                nY -= (height + _displaceY);
            } 
            else 
            {
                // draw below
                nY += _displaceY;
            }
            
            x = nX;
            y = nY;
        }
        
        public function mouseOut(event:MouseEvent = null):void
        {
            _ani.anime(this).removeEffectNamed("DelayFX", false, false);
            
            if (_displayObject.stage && _displayObject.stage.contains(this)) 
            {
                // fade out the tool tip
                _fadeEffect = new TweenFX("alpha", NaN, 0, FADEOUT_DURATION, Sine.easeOut);
                _ani.anime(this).addEffect(_fadeEffect).whenDone(hideToolTip);
            }
        }
        
        
        //
        // return true if the mouse over DisplayObject
        private static function isMouseOver(displayObject:DisplayObject,
                                            shapeFlag:Boolean = true):Boolean 
        {
            return (displayObject.stage && displayObject.hitTestPoint(displayObject.stage.mouseX, displayObject.stage.mouseY, shapeFlag));
        }
        
        
        //
        // accessors and mutators
        //
        
        public function get enabled():Boolean                           { return _enabled; }
        public function get persist():Boolean                           { return _persist; }
        public function get displaceX():uint                            { return _displaceX; }
        public function get displaceY():uint                            { return _displaceY; }
        public function get message():String                            { return _message; }
        public function get useMousePosition():Boolean                  { return _useMousePosition; }
        
        public static function get displayedToolTip():Tooltip           { return _displayedToolTip; }
        public static function get bgColor():uint                       { return _bgColor; }
        public static function get bgAlpha():Number                     { return _bgAlpha; }
        public static function get dropShadow():uint                    { return _dropShadow; }
        public static function get lineColor():uint                     { return _lineColor; }
        public static function get lineThinkness():uint                 { return _lineThinkness; }
        public static function get ellipseWidth():Number                { return _ellipseWidth; }
        public static function get font():String                        { return _font; }
        public static function get fontSize():int                       { return _fontSize; }
        public static function get fontColor():uint                     { return _fontColor; }
        public static function get bold():Boolean                       { return _bold; }
        public static function get italic():Boolean                     { return _italic; }
        public static function get padding():uint                       { return _padding; }
        public static function get kerning():Boolean                    { return _kerning; }
        public static function get leading():int                        { return _leading; }
        public static function get letterSpacing():Number               { return _letterSpacing; }
        public static function get displacement():uint                  { return _displacement; }
        public static function get defaultDuration():uint               { return _defaultDuration; }
        public static function get minWidth():Number                    { return _minWidth; }
        public static function get maxWidth():Number                    { return _maxWidth; }
        
        
        
        public function set enabled(value:Boolean):void 
        {
            _enabled = value; 
            if (! _enabled) 
            {
                mouseOut();
            } 
            else if (isMouseOver(_displayObject)) 
            {
                mouseOver();
            }
        }
        
        public function set persist(value:Boolean):void                 { _persist          = value; }
        public function set displaceX(value:uint):void                  { _displaceX        = value; }
        public function set displaceY(value:uint):void                  { _displaceY        = value; }
        public function set useMousePosition(value:Boolean):void        { _useMousePosition = value; }
        public static function set bgColor(value:uint):void             { _bgColor          = value; }
        public static function set bgAlpha(value:Number):void           { _bgAlpha          = value; }
        public static function set dropShadow(value:uint):void          { _dropShadow       = value; }
        public static function set lineColor(value:uint):void           { _lineColor        = value; }
        public static function set lineThinkness(value:uint):void       { _lineThinkness    = value; }
        public static function set ellipseWidth(value:Number):void      { _ellipseWidth     = value; }
        public static function set font(value:String):void              { _font             = value; }
        public static function set fontSize(value:int):void             { _fontSize         = value; }
        public static function set fontColor(value:uint):void           { _fontColor        = value; }
        public static function set bold(value:Boolean):void             { _bold             = value; }
        public static function set italic(value:Boolean):void           { _italic           = value; }
        public static function set kerning(value:Boolean):void          { _kerning          = value; }
        public static function set leading(value:int):void              { _leading          = value; }
        public static function set letterSpacing(value:Number):void     { _letterSpacing    = value; }
        public static function set padding(value:uint):void             { _padding          = value; }
        public static function set displacement(value:uint):void        { _displacement     = value; }
        public static function set defaultDuration(value:uint):void     { _defaultDuration  = value; }
        public static function set minWidth(value:Number):void          { _minWidth         = Math.abs(value); }
        public static function set maxWidth(value:Number):void          { _maxWidth         = Math.abs(value); }
        
        
        
        /**
         * Searches for a registered font by font name and returns that font
         * 
         * @param fontName Name of the font being searched for
         * @param includeDeviceFonts If true then device fonts are included in the search
         * 
         * @returns Returns a reference to the registered font
         *          If the font is not registered <code>null</code> is returned.
         */
        public static function getFont(fontName:String, 
                                       includeDeviceFonts:Boolean = false):Font
        {
            for each (var font:Font in Font.enumerateFonts(includeDeviceFonts)) 
            {
                if (fontName == font.fontName) 
                {
                    return font;    
                }
            }
            return null;
        }
    }
}