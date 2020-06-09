//
//  Alert v 1.0.2 - alert package
//  Russell Lowke, November 14th 2011
// 
//  Copyright (c) 2008-2011 Lowke Media
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
//  Alert package
//
//  Alert is a quick and easy way to overlay an alert message on screen, 
//  accompanied by a traditional style INFO_ICON, QUESTION_ICON, WARNING_ICON, or ERROR_ICON icon.
//
//  Simply click on the alert to dismiss it. Multiple alerts displayed in the 
//  same parent will stack, each staggering down and to the right with each
//  subsequent alert. Alert height is sized according to the size of the 
//  message being displayed, width is a default value that may be set.
//
//
//  Usage:
//
//  Before Alert can be used, a display object in which alerts will display into
//  must be declared.  This is done by setting the static defaultParent
//  parameter. Usually the defaultParent display object is the project's stage.
//
//      Alert.defaultParent = this.stage;
//
//  Once the defaultParent has been set, displaying an Alert is easy,
//
//      Alert.show("Your alert message here", Alert.NO_ICON);
//
//  The optional 2nd parameter declares the icon type used in the Alert, such 
//  as, Alert.NO_ICON, Alert.INFO_ICON (default), Alert.QUESTION_ICON, Alert.WARNING_ICON, and 
//  Alert.ERROR_ICON. The optional 3rd parameter overrides the defaultParent, 
//  declaring a different parent display object in which to display the alert.
//
//  There are also shorthand static helper methods, Alert.info(), 
//  Alert.question(), Alert.warning(), and Alert.error(), e.g.
//
//      Alert.info("Your info message");
//      Alert.question("Your question message");
//      Alert.warning("Your warning message");
//      Alert.error("Your error message");
//

package com.lowke.alert
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.Dictionary;
    
    public class Alert extends Sprite 
    {   
        public static const SYSTEM_FONT_TYPEWRITER:String       = "_typewriter";
        public static const SYSTEM_FONT_SERIF:String            = "_serif";
        public static const SYSTEM_FONT_SANS_SERIF:String       = "_sans";
        
        public static const NO_ICON:String           = '';
        public static const INFO_ICON:String         = 'i';
        public static const QUESTION_ICON:String     = '?';
        public static const WARNING_ICON:String      = '!';
        public static const ERROR_ICON:String        = 'X';
        
        // defaults
        private static var _font:String             = SYSTEM_FONT_SANS_SERIF;   // generic sans serif font default
        private static var _fontPtSize:int          = 14;                       // pt size of font used
        private static var _width:uint              = 400;                      // default width of alerts
        private static var _iconPtSize:int          = 34;                       // pt size used for icon character
        private static var _iconSize:int            = 48;                       // icon height and width, in pixels
        private static var _whiteSpace:uint         = 18;                       // whitespace used around alert elements
        private static var _alertSpacing:uint       = 6;                        // spacing between each alert box
        
        private static var _defaultParent:DisplayObjectContainer;               // default parent to display Alert into
        private static var _alerts:Dictionary = new Dictionary(true);           // keeps track of # of alerts in each parent
        
        
        
        public function Alert(message:String, 
                              icon:String = INFO_ICON,
                              txtSelectable:Boolean = false,
                              parent:DisplayObjectContainer = null,
                              width:Number = NaN,
                              x:Number = NaN,
                              y:Number = NaN) 
        {
            super();
            
            if (! parent) 
			{
                if (! _defaultParent)
                {
                    throw new Error("No defaultParent has been declared. A defaultParent must be declared or a parent parameter passed when you use Alert. Typically the defaultParent is set to the application's stage.");
                }
                parent = _defaultParent;
            }
            
            if (isNaN(width)) 
            {
                width = _width;
            }
            
            // set alert count for parent container
            if (! _alerts[parent]) 
            {
                _alerts[parent] = 0;
            }
            
            // height and width of parent
            var parentHeight:Number = (parent is Stage) ? (parent as Stage).stageHeight : parent.height;
            var parentWidth:Number  = (parent is Stage) ? (parent as Stage).stageWidth  : parent.width;
            
            // center alert 1/2 way across
            if (isNaN(x)) 
            {
                x = parentWidth/2 - width/2;
                if (x < _whiteSpace) 
                {
                    x = _whiteSpace;
                }
            }
            
            // limit right edge
            x += _alerts[parent]*_alertSpacing;
            if (x > parentWidth - width - _alertSpacing) 
            {
                x = parentWidth - width - _alertSpacing;
            }
            
            // build textField to find height of message
            var textField:TextField = new TextField();
            textField.selectable = txtSelectable;
            textField.multiline = true;
            textField.wordWrap = true;
            textField.autoSize = TextFieldAutoSize.LEFT;
            if (icon == NO_ICON) 
            {
                textField.x = x + _whiteSpace;
                textField.width = width - _whiteSpace*2;
            } 
            else 
            {
                // make room for icon
                textField.x = x + _iconSize + _whiteSpace*2;
                textField.width = width - (_iconSize + _whiteSpace*3);
            }

            textField.text = message;
            var textFormat:TextFormat;
            textFormat = textField.getTextFormat();
            textFormat.font = _font;
            textFormat.size = _fontPtSize;
            var font:Font = getFont(_font);
            textField.embedFonts = (font) ? true : false;
            textField.setTextFormat(textFormat);
            
            // determine height, limit to a minimum and maximum
            var height:Number = textField.height + _whiteSpace*2 + 4;
            if (height < _iconSize + _whiteSpace*2 + 2) 
            {
                height = _iconSize + _whiteSpace*2 + 2;
            } 
            else if (height > parentHeight) 
            {
                height = parentHeight - _whiteSpace*2;
                textField.autoSize = TextFieldAutoSize.NONE;
                textField.height = height - (_whiteSpace*2 + 4);
                // make selectable, allowing user to access all content
                textField.selectable = true;
            }
            
            // center 1/3 down in y
            if (isNaN(y)) 
            {
                y = parentHeight/3 - height/2;
                if (y < _whiteSpace) 
                {
                    y = _whiteSpace;
                }
            }
            
            // limit bottom edge
            y += _alerts[parent]*_alertSpacing;
            if (y > parentHeight - height - _alertSpacing) 
            {
                y = parentHeight - height - _alertSpacing;
            }
            
            // add background box
            var color:uint = 0xCCCCCC;
            var box:Shape = new Shape();
            box.graphics.beginFill(color);
            box.graphics.lineStyle(2, 0x000000);
            box.graphics.drawRect(x, y, width, height);
            addChild(box);
            
            // add message text
            textField.y = y + _whiteSpace;
            addChild(textField);
            
            if (icon != NO_ICON) 
            {
                // add icon box
                var iconBox:Shape = new Shape();
                var iconColor:uint;
                switch (icon) 
                {
                    case WARNING_ICON:      iconColor = 0xFFFF99;       break;  // yellow
                    case ERROR_ICON:        iconColor = 0xCC6666;       break;  // red
                    case QUESTION_ICON:
                    case INFO_ICON:         iconColor = 0x6598FF;       break;  // blue
                    default:                iconColor = 0xEEEEEE;       break;  // lt. grey
                }
                
                iconBox.graphics.beginFill(iconColor);
                // iconBox.graphics.lineStyle(1, 0x000000);
                if (icon == INFO_ICON || icon == QUESTION_ICON) 
                {
                    iconBox.graphics.drawCircle(x + _whiteSpace + _iconSize/2, y + _whiteSpace + _iconSize/2, _iconSize/2);
                } 
                else 
                {
                    iconBox.graphics.drawRect(x + _whiteSpace, y + _whiteSpace, _iconSize, _iconSize);
                }
                
                addChild(iconBox);
                
                // add icon
                var iconField:TextField = new TextField();
                iconField.text = icon;
                iconField.selectable = false;
                iconField.x = x + _whiteSpace + 1;
                iconField.width = _iconSize - 1;
                var iconFormat:TextFormat;
                iconFormat = textField.getTextFormat();
                iconFormat.font = _font;
                iconFormat.size = _iconPtSize;
                iconFormat.bold = true;
                iconFormat.align = TextFormatAlign.CENTER;
                if (icon == INFO_ICON || icon == QUESTION_ICON) 
                {
                    iconFormat.color = 0xFFFFFF;
                }
                iconField.setTextFormat(iconFormat);
                iconField.y = y + _whiteSpace + (_iconSize - iconField.textHeight)/2 - 2;
                addChild(iconField);
            }
            
            
            // add dropshadow
            filters = [ new DropShadowFilter(2) ];
            
            // clicking on Alert will close the alert
            addEventListener(MouseEvent.CLICK, closeEvent, false, 0, true);
            
            // add alert to parent
            parent.addChildAt(this, parent.numChildren - _alerts[parent]);
            _alerts[parent] = _alerts[parent] + 1;
        }
        
        private function closeEvent(event:MouseEvent):void 
        {
            close();
        }
        
        public function close():void 
        {
            if (parent) 
            {
                removeEventListener(MouseEvent.CLICK, closeEvent);
                
                // decrement alerts counter for the parent
                _alerts[parent] = _alerts[parent] - 1;
                
                // if last Alert then clear refereneces from Dictonary
                if (_alerts[parent] == 0) 
                {
                    _alerts[parent] = null;
                    delete _alerts[parent];
                }
                
                // removing from the parent will cause Alert to clear from memory
                parent.removeChild(this);
            }
        }
        
        public static function show(message:String,
                                    icon:String = 'i' /* INFO_ICON */,
                                    txtSelectable:Boolean = false,
                                    width:Number = NaN,
                                    parent:DisplayObjectContainer = null,
                                    x:Number = NaN,
                                    y:Number = NaN):Alert 
        {                                   
            return new Alert(message, icon, txtSelectable, parent, width, x, y);
        }
        
        public static function info(message:String, txtSelectable:Boolean = false, width:Number = NaN):Alert 
        {              
            return show(message, INFO_ICON, txtSelectable, width);
        }
        
        public static function question(message:String, txtSelectable:Boolean = false, width:Number = NaN):Alert 
        {              
            return show(message, QUESTION_ICON, txtSelectable, width);
        }
        
        public static function warning(message:String, txtSelectable:Boolean = false, width:Number = NaN):Alert 
        {               
            return show(message, WARNING_ICON, txtSelectable, width);
        }
        
        public static function error(message:String, txtSelectable:Boolean = false, width:Number = NaN):Alert 
        {             
            return show(message, ERROR_ICON, txtSelectable, width);
        }
        
        
        
        //
        // accessors and mutators
        //
        
        public static function get font():String                                    { return _font; }
        public static function get width():uint                                     { return _width; }
        public static function get fontPtSize():int                                 { return _fontPtSize; }
        public static function get iconPtSize():int                                 { return _iconPtSize; }
        public static function get iconSize():int                                   { return _iconSize; }
        public static function get whiteSpace():uint                                { return _whiteSpace; }
        public static function get altertSpacing():uint                             { return _alertSpacing; }
        public static function get defaultParent():DisplayObjectContainer           { return _defaultParent; }
        
        public static function set font(value:String):void                          { _font          = value; }
        public static function set width(value:uint):void                           { _width         = value; }
        public static function set fontPtSize(value:int):void                       { _fontPtSize    = value; }
        public static function set iconPtSize(value:int):void                       { _iconPtSize    = value; }
        public static function set iconSize(value:int):void                         { _iconSize      = value; }
        public static function set whiteSpace(value:uint):void                      { _whiteSpace    = value; }
        public static function set altertSpacing(value:uint):void                   { _alertSpacing  = value; }
        public static function set defaultParent(value:DisplayObjectContainer):void {
            if (value) 
            {
                _defaultParent = value; 
            }
        }
        
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