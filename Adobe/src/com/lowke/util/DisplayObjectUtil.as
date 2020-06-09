package com.lowke.util
{
    import flash.display.DisplayObject;
    import flash.display.LoaderInfo;

    public class DisplayObjectUtil
    {
        /**
         * Trace all of a DisplayObject's parents
         *
         * @param displayObject DisplayObject being traced.
         */
        public static function traceParents(displayObject:DisplayObject, string:String = ""):void
        {
            if (displayObject.parent)
            {
                if (string == "")
                {
                    string = displayObject.toString();
                }
                else
                {
                    string = displayObject + " <-- " + string;
                }
                traceParents(displayObject.parent, string);
            }
            else
            {
                trace("[end] <-- " + string);
            }
        }


        public static function getDisplayPath(displayObject:DisplayObject):String
        {
            var string:String = "";
            var loaderInfo:LoaderInfo;
            while (displayObject.parent)
            {
                if (string != "")
                {
                    string = string + " < ";
                }
                string += displayObject.name + " " + displayObject;
                if (! loaderInfo && displayObject.loaderInfo)
                {
                    // save the loaderInfo asap if available
                    loaderInfo = displayObject.loaderInfo;
                }
                displayObject = displayObject.parent;
            }

            string += ".";

            if (loaderInfo)
            {
                string += "\n\nurl:" + loaderInfo.url + "\n";
            }

            return string;
        }
    }
}
