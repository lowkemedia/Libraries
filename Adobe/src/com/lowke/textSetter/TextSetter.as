//
//  TextSetter v 1.0
//  Russell Lowke, May 22nd 2013
//
//  Copyright (c) 2013 Lowke Media
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

package com.lowke.textSetter
{
    import com.lowke.util.DisplayObjectUtil;
    import com.lowke.util.StringUtil;
    import com.lowke.textSetter.valueObject.FieldVO;
    import com.lowke.textSetter.valueObject.SpriteVO;
    import com.lowke.font.FontLoader;
    import com.lowke.font.valueObject.FontMapVO;
    import com.lowke.font.event.FontsReadyEvent;
    import com.lowke.logger.Logger;
    
    import flash.display.Sprite;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    public class TextSetter
    {
        //
        // error, warning and ifo IDs
        public static const LOG_PREFIX:String = "FLD";
        public static const WARNING_NULL_FIELD:String = "FLD00";
        public static const WARNING_NULL_SPRITE:String = "FLD01";
        public static const WARNING_CANT_FIND_FONT_MAP:String = "FLD02";
        public static const WARNING_FONT_NAME_MUST_START_WITH_UNDERSCORE:String = "FLD03";
        public static const WARNING_CANT_FIND_FONT:String = "FLD04";
        public static const WARNING_DO_NOT_USE_BITMAP_ANTI_ALIAS:String = "FLD05";
        public static const WARNING_NEED_GLYPHS:String = "FLD06";
        
        private static const UNDERSCORE:String = '_';
        private static const BITMAP_ANTI_ALIAS_INDICATOR:String = "_st";
        
        
        // indicates a field should use word wrap
        public static const WORD_WRAP_INDICATOR:String = "wrap";
        
        private static var _fontLoader:FontLoader = FontLoader.instance;
        

        // reflow text field with string
        public static function setField(field:TextField,
                                        string:String,
                                        wordWrap:Boolean = false):void 
        {
            // search for "wrap" in instance name indicating wordWrap flag is true
            var textFieldName:String = field.name.toLocaleLowerCase();
            if (textFieldName.indexOf(WORD_WRAP_INDICATOR) != -1) 
            {
                wordWrap = true;
            }
            
            if (! field) 
            {
                Logger.warning("setField() received a null field for localization.", WARNING_NULL_FIELD, true);
                return;
            }
            
            if (_fontLoader.loading) 
            {
                // wait for fonts to finish loading
                retryAfterLoad(null, field, string, wordWrap);
                return;
            }
            
            // ensure the field is visible
            field.visible = true;
            
            // get original field data
            var fieldDetails:FieldVO = FieldVO.fieldDetails(field);
            field.scaleX = fieldDetails.scaleX;
            field.scaleY = fieldDetails.scaleY;
            field.width = fieldDetails.width/fieldDetails.scaleX;
            field.height = fieldDetails.height/fieldDetails.scaleY;
            field.x = fieldDetails.x;
            field.y = fieldDetails.y;
            
            // these values to be used in TextFormat
            var fontName:String = fieldDetails.fontName;
            var fontSize:Number = fieldDetails.fontSize;
            var bold:Boolean = fieldDetails.bold;
            var italic:Boolean = fieldDetails.italic;
            var fontColor:uint = fieldDetails.fontColor;
            if (field.textColor) 
            {
                fontColor = field.textColor;
            }
            
            // get font mapping data
            var fontMapData:FontMapVO = _fontLoader.getFontMap(fontName, fontSize);
            
            if (fontMapData) 
            {
                if (fontMapData.fontTo) 
                { 
                    fontName = fontMapData.fontTo;
                }
                
                if (fontMapData.sizeTo) 
                {
                    fontSize = fontMapData.sizeTo;
                }
                
                if (fontMapData.bold) 
                {
                    bold = true;
                }
                
                if (fontMapData.italic) 
                {
                    italic = true;
                }
                
            } 
            else 
            {
                if (fontName) 
                {
                    // auto create a map for missing font
                    var fontTo:String = "_" + stringReplace(fontName, " ", "");
                    _fontLoader.createFontMap(fontName, 0, fontTo, 0, false, false);
                    fontName = fontTo;
                } 
                else 
                {
                    if (fontName) 
                    {
                        Logger.warning("Could not find font map for font \"" + fontName + "\" used in field " + DisplayObjectUtil.getDisplayPath(field) + "\n" +
                            "Using default font " + _fontLoader.defaultFontName + " instead.", WARNING_CANT_FIND_FONT_MAP + "[" + fontName + "]", false, true);
                    }
                    
                    // if there is no font map then use the default font
                    fontName = _fontLoader.defaultFontName;
                }
            }
            
            if (! StringUtil.stringHasValue(fontName))
            {
                fontName = _fontLoader.defaultFontName;
            }
            
            fontName = FontLoader.stripFontName(fontName);
            
            var embeddedFont:Font;
            if (! FontLoader.isSystemFont(fontName)) 
            {
                // find font
                embeddedFont = FontLoader.getFont(fontName);
                
                if (! embeddedFont) 
                {
                    if (! _fontLoader.fontFaild(fontName)) 
                    {
                        if (fontName.charAt() != UNDERSCORE) 
                        {
                            Logger.warning("Font \"" + fontName + "\" must start with an \'" + UNDERSCORE + "\' as all fonts must have the underscore prefix.",
                                WARNING_FONT_NAME_MUST_START_WITH_UNDERSCORE, false, true);
                            fontName = "_" + fontName;
                        }
                        
                        // load the font
                        _fontLoader.loadFont(fontName);
                        
                        // call localizeField again after load
                        retryAfterLoad(null, field, string, wordWrap);
                        return;
                    }
                    
                    // can't get mapping font
                    var originalFontName:String = fontName;
                    fontName = _fontLoader.defaultFontName;
                    embeddedFont = FontLoader.getFont(fontName);
                    
                    var extraWarningString:String = "";
                    if (! embeddedFont) 
                    {    
                        // still can't get mapping font
                        if (fontName != _fontLoader.defaultFontName) 
                        {
                            extraWarningString = "Could not find default font \"" + fontName + "\" either.";
                        }
                        fontName = _fontLoader.defaultFontName;
                    }
                    
                    Logger.warning("Could not find font \"" + originalFontName + "\"." + extraWarningString + " Using font \"" + fontName + "\" instead.",
                        WARNING_CANT_FIND_FONT + "[" + originalFontName +"]", false, true);
                    
                    if (fontName.indexOf(BITMAP_ANTI_ALIAS_INDICATOR) != -1) 
                    {
                        Logger.warning("Do not use a field Anti-alias setting of  \'Bitmap text [no anti-alias]\' on field " + field.name, WARNING_DO_NOT_USE_BITMAP_ANTI_ALIAS);
                    }
                }
            }
            
            if (embeddedFont) 
            {
                // check glyphs
                fontName = embeddedFont.fontName;
                var missing:String = missingGlyphs(embeddedFont, string);
                if (missing)
                {
                    Logger.warning("Font \"" + fontName + "\" doesn't have all the glyphs needed to display string:\"" + string + "\"\n" +
                        "Glyphs that are missing are: " + missing, WARNING_NEED_GLYPHS);
                }
                field.embedFonts = true;
            } 
            else 
            {
                field.embedFonts = false;
            }
            
            // create new TextFormat with the mapped font
            var newTextFormat:TextFormat = new TextFormat();
            newTextFormat.font = fontName;
            newTextFormat.size = fontSize;
            newTextFormat.color = fontColor;
            
            // set bold and italic flags if required
            //  Note: setting these flags overrides .html text formatting
            if (bold)
            { 
                newTextFormat.bold = true; 
            }
            
            if (italic)
            { 
                newTextFormat.italic = true; 
            }
            
            // Hack to stop cropping on bold and/or italic text.
            // 	Flash will often crop the top right corner of a field when the field
            //	is reflowed using field.autoSize and the font is italic or bold or
            //	(in particular) italic and bold. Assigning the field a margin  
            //	prevents this cropping.
            if (! newTextFormat.rightMargin) 
            {
                newTextFormat.rightMargin = 1;
            }
            
            if (! newTextFormat.leftMargin) 
            {
                newTextFormat.leftMargin = 1;
            }
            
            field.htmlText = string;
            // field.htmlText = "<font face=\""+fontName+"\">TEST, <b>BOLD</b></font> <font face=\"_CCComicrazy\">hello</font>";
            
            field.setTextFormat(newTextFormat);
            field.defaultTextFormat = newTextFormat;
            field.wordWrap = wordWrap;
            
            if (fieldDetails.align && field.type != TextFieldType.INPUT) 
            {
                if (fieldDetails.align == TextFormatAlign.LEFT || 
                    fieldDetails.align == TextFormatAlign.CENTER ||
                    fieldDetails.align == TextFormatAlign.RIGHT) 
                {
                    field.autoSize = fieldDetails.align;
                } 
                else 
                {
                    field.autoSize = TextFormatAlign.LEFT;
                }
            }
            
            // if the field width becomes smaller, adjust horizontal position according to alignment
            switch (fieldDetails.align) 
            {
                case TextFieldAutoSize.CENTER:
                    field.x = fieldDetails.x + (fieldDetails.width - field.width)/2;
                    break;
                case TextFieldAutoSize.RIGHT:
                    field.x = fieldDetails.x + (fieldDetails.width - field.width);
                    break;
                case TextFieldAutoSize.LEFT:
                case TextFieldAutoSize.NONE:
                default:
            }
        }
        
        // adjusts a sprite to match a reflowed textfield
        public static function setSpriteField(sprite:Sprite,
                                              field:TextField,
                                              string:String,
                                              wordWrap:Boolean = false):void
        {
            if (! sprite) 
            {
                Logger.warning("setSprite() received a null sprite for string \"" + string + "\".", WARNING_NULL_SPRITE);
                return;
            }
            
            if (! field) 
            {
                Logger.warning("setSprite() received a null field for string \"" + string + "\".", WARNING_NULL_FIELD);
                return;
            }
            
            if (_fontLoader.loading) 
            {
                // wait for fonts to finish loading
                retryAfterLoad(sprite, field, string, wordWrap);
                return;
            }
            
            // ensure the sprite and field are visible
            sprite.visible = true;
            field.visible = true;
            
            // reset sprite and field to original settings
            var fieldDetails:FieldVO = FieldVO.fieldDetails(field);	
            var spriteDetails:SpriteVO = SpriteVO.spriteDetails(sprite);
            spriteDetails.spritePadding = sprite.height - field.height;
            field.x = fieldDetails.x;
            field.y = fieldDetails.y;
            field.scaleX = fieldDetails.scaleX;
            field.scaleY = fieldDetails.scaleY;
            sprite.x = spriteDetails.x;
            sprite.y = spriteDetails.y;
            sprite.scaleX = spriteDetails.scaleX;
            sprite.scaleY = spriteDetails.scaleY;
            
            setField(field, string, wordWrap);

            // find height and width changes
            var fieldWidth:Number = field.width;
            var fieldHeight:Number = field.height;
            var widthChange:Number = fieldWidth/fieldDetails.width;
            var heightChange:Number = fieldHeight/fieldDetails.height;
            
            if (widthChange > 1) 
            {
                // change the sprite width according to change
                sprite.scaleX = widthChange*spriteDetails.scaleX;
                
                if (sprite.contains(field)) 
                {
                    // correct for distortion of text inside the sprite
                    field.scaleX = 1/widthChange*fieldDetails.scaleX;
                }
                
                // fix x position as setting scaleX can cause shift.
                field.x = fieldDetails.x;
            } 
            else if (widthChange < 1)
            {    
                // if the field width becomes smaller, adjust horizontal position according to alignment
                switch (fieldDetails.align) 
                {
                    case TextFieldAutoSize.CENTER:
                        field.x = fieldDetails.x + (fieldDetails.width - field.width)/2;
                        break;
                    case TextFieldAutoSize.RIGHT:
                        field.x = fieldDetails.x + (fieldDetails.width - field.width);
                        break;
                    case TextFieldAutoSize.LEFT:
                    case TextFieldAutoSize.NONE:
                    default:
                }
            }
            
            if (heightChange > 1)
            {    
                // change the sprite height according to change
                sprite.scaleY = heightChange*spriteDetails.scaleY;
                
                if (sprite.contains(field)) 
                {
                    // correct for distortion of text if inside the sprite
                    field.scaleY = 1/heightChange*fieldDetails.scaleY;
                }
                
                // fix y position as setting scaleY can cause shift.
                field.y = fieldDetails.y;
            }
        }
        
        // retry once fonts have finished loading
        private static function retryAfterLoad(sprite:Sprite,
                                               field:TextField,
                                               string:String,
                                               wordWrap:Boolean):void 
        {
            
            // wait for any fonts to finish loading
            var listener:Function = function ():void 
            {
                _fontLoader.removeEventListener(FontsReadyEvent.FONTS_READY_EVENT, listener);
                if (sprite)
                {
                    setSpriteField(sprite, field, string, wordWrap);
                }
                else
                {
                    setField(field, string, wordWrap);
                }
            };
            _fontLoader.addEventListener(FontsReadyEvent.FONTS_READY_EVENT, listener);
            
            // hide the field and sprite in the interim
            field.visible = false;
            if (sprite)
            {
                sprite.visible = false;
            }
        }
        
        public static function missingGlyphs(font:Font, 
                                             string:String):String
        {
            // strip out line breaks etc, which can be problematic with font.hasGlyphs()
            string = stringReplace(string, ' ', '');	// strip out spaces		
            string = stringReplace(string, '\n', '');	// remove new line
            string = stringReplace(string, '\r', '');	// remove return
            string = stringReplace(string, '\t', '');	// remove tabs
            
            var missing:String;
            if (! font.hasGlyphs(string)) 
            {
                var missingGlyphs:Object = new Object();
                missing = "";
                for (var i:uint = 0; i < string.length; ++i) 
                {
                    var char:String = string.charAt(i);
                    var charCode:int = char.charCodeAt();
                    if (! font.hasGlyphs(char) && ! missingGlyphs[char]) 
                    {
                        missingGlyphs[char] = char;
                        missing += ((missing == "") ? "" : ", ") + "\"" + char + "\" [" + charCode + "]";
                    }
                }
            }
            
            return missing;
        }
        
        /**
         * Replaces all instances of the replace string in the input string
         * with the replaceWith string.
         * 
         * @param input Original string
         * @param replace The string that will be replaced
         * @param replaceWith The string that will replace instances of replace
         * @returns A new String with the replace string replaced with replaceWith
         */
        public static function stringReplace(input:String, 
                                             replace:String, 
                                             replaceWith:String):String
        {
            return input.split(replace).join(replaceWith);
        }
    }
}