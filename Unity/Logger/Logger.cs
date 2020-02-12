//
//  Logger - Logger package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2019 Lowke Media
//  see http://www.lowkemedia.com for more information
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

using System;
using System.Collections.Generic;
using UnityEngine;

// TODO: replace with Debug.Log("I'm gone! (bye, bye)");  ?

public class Logger : MonoBehaviour
{
    public enum LogLevel
    {
        NONE,                // don't log
        SEVERE,
        WARNING,
        INFO,
        PRINT,               // PRINT is a less spammy version of DEBUG for one-off testing
        DEBUG
    };

    // private static bool _showAlert = true;      // TODO: if true Alert box is shown

    private static LogLevel _logLevel = LogLevel.PRINT; // default logging level is LOG_LEVEL_PRINT

    // map of "once only" reports that have been logged so far
    private static Dictionary<string, bool> _onceOnlyErrors = new Dictionary<string, bool>();

    public static void Log(LogLevel logLevel,
                           string message,
                           string id = null,
                           bool showStackTrace = false,
                           bool showOnlyOnce = false)
    {

        // some errors are displayed only once, otherwise they get too spammy
        if (showOnlyOnce)
        {
            _onceOnlyErrors.TryGetValue(id, out bool flag);
            if (flag)
            {
                // this error has already been displayed
                return;
            }

            // flag this error as having been displayed
            _onceOnlyErrors[id] = true;
        }

        if (logLevel <= _logLevel)
        {
            string logMessage = LogPrefix(logLevel, id) + message;

            if (showStackTrace)
            {
                try
                {
                    // intentionally throw error so we can get a stack trace
                    throw new Exception();
                }
                catch (Exception error)
                {
                    logMessage += error.StackTrace + '\n';
                }
            }

            print(logMessage);
        }
    }

    private static string LogPrefix(LogLevel level,
                                   string id = null)
    {
        string prefix = "";
        if (level != LogLevel.PRINT)    // level PRINT does not add an indicator
        {
            prefix += LogLevelString(level) + " ";
        }

        if (id != null)
        {
            prefix += "#" + id + ": ";
        }

        return prefix;
    }

    private static string LogLevelString(LogLevel logLevel)
    {
        switch (logLevel)
        {
            case LogLevel.NONE:
                return "NONE";
            case LogLevel.SEVERE:
                return "SEVERE";
            case LogLevel.WARNING:
                return "WARNING";
            case LogLevel.INFO:
                return "INFO";
            case LogLevel.PRINT:
                return "PRINT";
            case LogLevel.DEBUG:
                return "DEBUG";
            default:
                return "";
        }
    }

    //
    // static helper methods

    public static void Severe(string message,
                              string id = null,
                              bool stackTrace = true,       // by default severe logs show the stack trace
                              bool showOnlyOnce = false)
    {
        Log(LogLevel.SEVERE, message, id, stackTrace, showOnlyOnce);
    }

    public static void Warning(string message,
                               string id = null,
                               bool stackTrace = false,
                               bool showOnlyOnce = false)
    {
        Log(LogLevel.WARNING, message, id, stackTrace, showOnlyOnce);
    }

    public static void Info(string message,
                            string id = null,
                            bool stackTrace = false,
                            bool showOnlyOnce = false)
    {
        Log(LogLevel.INFO, message, id, stackTrace, showOnlyOnce);
    }

    public static void Print(string message,
                             string id = null,
                             bool stackTrace = false,
                             bool showOnlyOnce = false)
    {
        Log(LogLevel.PRINT, message, id, stackTrace, showOnlyOnce);
    }

    public static void Debug(string message,
                             string id = null,
                             bool stackTrace = false,
                             bool showOnlyOnce = false)
    {
        Log(LogLevel.DEBUG, message, id, stackTrace, showOnlyOnce);
    }

    public static LogLevel Level
    {
        get { return _logLevel; }
        set
        {
            if (value != _logLevel)
            {
                _logLevel = value;
                print("Logging level set to " + LogLevelString(_logLevel));
            }
        }
    }
}
