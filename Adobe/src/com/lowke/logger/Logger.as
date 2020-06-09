//
//  Logger v 2.3.3 - logger package
//  Russell Lowke, August 28th 2016
// 
//  Copyright (c) 2009-2011 Lowke Media
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

package com.lowke.logger
{
    import com.lowke.alert.Alert;
    
    /**
     *  Logger package
     * 
     *  Logger is useful in production environments where problems need to be logged
     *  and dealt with rather than causing a crash. In particular, Logger allows
     *  issues to be classed as either LOG_LEVEL_SEVERE, LOG_LEVEL_WARNING, LOG_LEVEL_INFO, or LOG_LEVEL_DEBUG. 
     * 
     * 
     *  Usage:
     * 
     *  Logger can dispatch a classed log with an ID by using,
     * 
     *      Logger.log(Logger.LOG_LEVEL_SEVERE, "Your log message", 10000);
     * 
     *  Where the 1st parameter can be set to Logger.LOG_LEVEL_SEVERE, Logger.LOG_LEVEL_WARNING,
     *  Logger.LOG_LEVEL_INFO, Logger.LOG_LEVEL_TRCAE or Logger.LOG_LEVEL_DEBUG, and the 3rd parameter
     *  allows for anoptional id value which defaults to 0.
     * 
     *  There are also shorthand static helper methods, Logger.severe(),
     *  Logger.warning(), Logger.info(), and Logger.debug(), e.g.
     * 
     *      Logger.severe("Your error message");
     *      Logger.warning("Your warning message");
     *      Logger.info("Your info message");
     *      Logger.debug("Your debug message");
     *  
     * 
     *  You can set the logging level using Logger.logLevel,
     *  
     *      Logger.logLevel = Logger.LOG_LEVEL_PRINT;
     *  
     *  There are 6 logging levels, they are,
     * 
     *      Logger.logLevel = Logger.LOG_LEVEL_NONE           // don't log
     *      Logger.logLevel = Logger.LOG_LEVEL_SEVERE         // show only severe logs
     *      Logger.logLevel = Logger.LOG_LEVEL_WARNING        // show severe and warning logs
     *      Logger.logLevel = Logger.LOG_LEVEL_INFO           // show severe, warning, and info logs
     *      Logger.logLevel = Logger.LOG_LEVEL_PRINT          // show severe, warning, info, and print logs
     *      Logger.logLevel = Logger.LOG_LEVEL_DEBUG          // show all logs
     * 
     *  By default the logLevel is set to LOG_LEVEL_PRINT.
     * 
     *  Logger will automatically trace() logs. You can prevent Logger
     *  from doing this by setting the traceLogs parameter to false,
     * 
     *      Logger.traceLogs = false;
     *
     *
     *  Typically error identifiers are comprised of a three digit prefix
     *  followed by a two digit number code.  e.g. "LDR02"
     *
     */
    
    public class Logger
    {

        // log levels
        public static const LOG_LEVEL_NONE:uint    = 0;       // don't log
        public static const LOG_LEVEL_SEVERE:uint  = 1;
        public static const LOG_LEVEL_WARNING:uint = 2;
        public static const LOG_LEVEL_INFO:uint    = 3;
        public static const LOG_LEVEL_PRINT:uint   = 4;       // PRINT is a less spammy version of DEBUG for one-off testing
        public static const LOG_LEVEL_DEBUG:uint   = 5;

        private static const DIGITS_IN_PREFIX:uint = 3;
        private static const DIGITS_IN_NUMBER:uint = 2;


        private static var _traceLogs:Boolean = true;         // if true all logs are traced
        private static var _showAlert:Boolean = true;         // if true Alert box is shown
        private static var _logLevel:uint = LOG_LEVEL_PRINT;  // default logging level is LOG_LEVEL_PRINT

        // map of "once only" reports that have been logged so far
        private static var _onceOnlyErrors:Object = new Object();
        
        
        //
        // Methods for triggering Logger events
        //
        
        //
        // log() dispatches LogAsEvents, allowing an application
        // to deal with issues on its own terms, usually for logging purposes.
        public static function log(logLevel:uint,
                                   message:String,
                                   id:String = null,
                                   showStackTrace:Boolean = false,
                                   showOnlyOnce:Boolean = false):void
        {
            
            var stackTrace:String;
            if (showStackTrace) 
            {
                try 
                {
                    // intentionally throw error so we can get a stack trace
                    throw new Error(makeLoggingMessage(logLevel, message, id));
                } 
                catch (error:Error) 
                {
                    stackTrace = error.getStackTrace();
                }
            }
            
            // some errors are displayed only once, otherwise they get too spammy
            if (showOnlyOnce) 
            {
                if (_onceOnlyErrors[id])
                {
                    // this error has already been displayed
                    return;
                } 
                else 
                {
                    // tag this error as displayed
                    _onceOnlyErrors[id] = true;
                }
            }
            
            if (logLevel <= _logLevel) 
            {
                var logMessage:String = makeLoggingMessage(logLevel, message, id, stackTrace);
                
                // dispatch a LoggerEvent event for others to listen to
                handleLog(logLevel, logMessage, stackTrace);
            }
        }

        private static function handleLog(logLevel:int,
                                          logMessage:String,
                                          stackTrace:String = null):void
        {
            var width:Number = Alert.width;
            if (stackTrace)
            {
                // events with stackTrace need be shown in longer alert
                width *= 1.8;
            }

            if (_traceLogs ||
                logLevel == LOG_LEVEL_PRINT)
            {
                trace(logMessage);
            }

            if (_showAlert)
            {
                switch(logLevel)
                {
                    case LOG_LEVEL_SEVERE:
                        Alert.error(logMessage, true, width);
                        break;
                    case LOG_LEVEL_WARNING:
                        Alert.warning(logMessage, true, width);
                        break;
                    case LOG_LEVEL_INFO:
                        Alert.info(logMessage, true, width);
                        break;
                }
            }
        }

        // create string from general log parameters
        public static function makeLoggingMessage(level:uint,
                                                  message:String,
                                                  id:String = null,
                                                  stackTrace:String = null):String
        {

            if (stackTrace)
            {
                // stackTrace has the error's makeErrorMessage(level, message, id) inside it
                return stackTrace;
            }

            var str:String;
            switch (level)
            {
                case LOG_LEVEL_SEVERE:    str = "SEVERE";     break;
                case LOG_LEVEL_WARNING:   str = "WARNING";    break;
                case LOG_LEVEL_INFO:      str = "INFO";       break;
                case LOG_LEVEL_PRINT:     str = "PRINT";      break;
                case LOG_LEVEL_DEBUG:     str = "DEBUG";      break;
            }

            return str + (id ? " #" + id : "") + ": " + message;
        }

        //
        // static helper methods
        
        // by default severe logs show the stack trace
        public static function severe(message:String, 
                                      id:String = null, 
                                      stackTrace:Boolean = true,
                                      showOnlyOnce:Boolean = false):void
        {
            return log(LOG_LEVEL_SEVERE, message, id, stackTrace, showOnlyOnce);
        }
        
        public static function warning(message:String, 
                                       id:String = null, 
                                       stackTrace:Boolean = false,
                                       showOnlyOnce:Boolean = false):void
        {
            return log(LOG_LEVEL_WARNING, message, id, stackTrace, showOnlyOnce);
        }
        
        public static function info(message:String, 
                                    id:String = null, 
                                    stackTrace:Boolean = false,
                                    showOnlyOnce:Boolean = false):void
        {
            return log(LOG_LEVEL_INFO, message, id, stackTrace, showOnlyOnce);
        }
        
        public static function print(message:String, 
                                     id:String = null, 
                                     stackTrace:Boolean = false,
                                     showOnlyOnce:Boolean = false):void
        {
            return log(LOG_LEVEL_PRINT, message, id, stackTrace, showOnlyOnce);
        }
        
        public static function debug(message:String, 
                                     id:String = null, 
                                     stackTrace:Boolean = false,
                                     showOnlyOnce:Boolean = false):void
        {
            return log(LOG_LEVEL_DEBUG, message, id, stackTrace, showOnlyOnce);
        }


        //
        // log identifiers are comprised of a three digit prefix
        //  followed by a two or more digit number code
        //  e.g. "LDR02"
        public static function idPrefix(id:String):String
        {
            if (! id)
            {
                return "";
            }

            // remove the numbers
            var string:String = id.substring(0, DIGITS_IN_PREFIX);

            return string;
        }

        //
        // Strips out any extra characters added to log id.
        //  Some errors, such as font related errors,
        //  might add information such as the name of the font
        //  to the error id
        public static function idBasic(id:String):String
        {
            if (! id)
            {
                return "";
            }

            var string:String = id.substring(0, DIGITS_IN_PREFIX + DIGITS_IN_NUMBER);

            return string;
        }

        //
        // id numbers can change, identifying a log by number is discouraged
        public static function idNumber(id:String):int
        {
            if (! id)
            {
                return -1;
            }

            // extract the numbers
            var string:String = id.substring(DIGITS_IN_PREFIX, DIGITS_IN_PREFIX + DIGITS_IN_NUMBER);
            var idNumber:uint = uint(string);

            return idNumber;
        }
        
        //
        // accessors and mutators
        //

        public static function set logLevel(value:uint):void
        {
            if (value != _logLevel)
            {
                switch(value)
                {
                    case LOG_LEVEL_NONE:
                        trace("Logger logging level set to LOG_LEVEL_NONE.");
                        break;
                    case LOG_LEVEL_SEVERE:
                        trace("Logger logging level set to LOG_LEVEL_SEVERE.");
                        break;
                    case LOG_LEVEL_WARNING:
                        trace("Logger logging level set to LOG_LEVEL_WARNING.");
                        break;
                    case LOG_LEVEL_INFO:
                        trace("Logger logging level set to LOG_LEVEL_INFO.");
                        break;
                    case LOG_LEVEL_PRINT:
                        trace("Logger logging level set to LOG_LEVEL_PRINT.");
                        break;
                    case LOG_LEVEL_DEBUG:
                        trace("Logger logging level set to LOG_LEVEL_DEBUG.");
                        break;
                    default:
                        throw new Error("Logger cannot change logging level to " + value + ".");
                }
                _logLevel = value;
            }
        }

        public static function get logLevel():uint
        {
            return _logLevel;
        }

        
        public static function set traceLogs(value:Boolean):void
        {
            if (value != _logLevel) 
            {
                if (value) 
                {
                    trace("Logger traceLogs switched ON");
                } 
                else 
                {
                    trace("Logger traceLogs switched OFF");
                }
                _traceLogs = value; 
            }
        }
        
        public static function get traceLogs():Boolean
        {
            return _traceLogs;
        }

        public static function set showAlert(value:Boolean):void
        {
            _showAlert = value;
        }

        public static function get showAlert():Boolean
        {
            return _showAlert;
        }

    }
}