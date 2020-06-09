package com.lowke.util
{
    import flash.text.Font;

    public class FontUtil
    {
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


        /**
         * Gives a dump of all registered fonts
         */
        public static function dumpRegisteredFonts():void
        {
            for each (var font:Font in Font.enumerateFonts(false))
            {
                trace("Registered font:" + font.fontName);
            }
            trace("___");
        }
    }
}
