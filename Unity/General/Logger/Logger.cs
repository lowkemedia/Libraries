//
//  Logger - Logger package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2019 Lowke Media
//  see https://github.com/lowkemedia/Libraries for more information
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


public class Logger : MonoBehaviour
{
    public enum LogLevel
    {
        NONE,                // don't log
        SEVERE,
        WARNING,
        INFO,
        DETAIL,              // lasting diagnostics below Info; never automatic alerts
        PRINT,               // "old-school" development trace; repeated calls remain visible
        DEBUG
    };

    // Optional automatic alerts preserve the existing log-only default.
    private static bool _showAlert;
    public static bool ShowAlert {
        get { return _showAlert; }
        set { _showAlert = value; }
    }

    // Optional presentation hook. Console logging works without a subscriber.
    // Receives the filtered, formatted message on the logging caller's thread.
    private static Action<LogLevel, string> _alertRequested;
    public static event Action<LogLevel, string> AlertRequested {
        add { _alertRequested += value; }
        remove { _alertRequested -= value; }
    }

    private static LogLevel _logLevel = LogLevel.PRINT; // default logging level is LOG_LEVEL_PRINT

    // map of "once only" reports that have been logged so far
    private static Dictionary<string, bool> _onceOnlyErrors = new Dictionary<string, bool>();

    // For explicit Alert logging only: prevents duplicate automatic alerts.
    // Use the severity helpers for ordinary diagnostics; they honour ShowAlert.
    internal static void LogNoAlert(LogLevel logLevel, string message, string id = null)
    {
        Log(logLevel, message, id, allowAlert: false);
    }

    // Internal logging pipeline. Call Severe, Warning, Info, Detail, Print or Debug instead.
    private static void Log(LogLevel logLevel,
                           string message,
                           string id = null,
                           bool showOnlyOnce = false,
                           bool showStackTrace = false,
                           bool allowAlert = true)
    {
        // some errors are displayed only once, otherwise they get too spammy
        if (showOnlyOnce)
        {
            _onceOnlyErrors.TryGetValue(message, out bool flag);

            if (flag) {
                // this error has already been displayed
                return;
            }

            // flag this error as having been displayed
            _onceOnlyErrors[message] = true;
        }

        if (logLevel <= _logLevel)
        {
            string logMessage = LogPrefix(logLevel, id) + message + "\n";

            if (showStackTrace) {
                logMessage += Environment.StackTrace + "\n";
            }

            switch (logLevel) {
                case LogLevel.SEVERE:
                    UnityEngine.Debug.LogError(logMessage);
                    break;
                case LogLevel.WARNING:
                    UnityEngine.Debug.LogWarning(logMessage);
                    break;
                default:
                    UnityEngine.Debug.Log(logMessage);
                    break;
            }

            if (_showAlert && allowAlert) {
                switch (logLevel) {
                    case LogLevel.SEVERE:
                    case LogLevel.WARNING:
                    case LogLevel.INFO:
                        _alertRequested?.Invoke(logLevel, logMessage);
                        break;
                    case LogLevel.DETAIL:
                    case LogLevel.PRINT:
                    case LogLevel.DEBUG:
                    case LogLevel.NONE:
                    default:
                        break;
                }
            }
        }
    }

    private static string LogPrefix(LogLevel level,
                                   string id = null)
    {
        string prefix = "";
        if (level != LogLevel.PRINT) {
            // level PRINT does not add an indicator
            prefix += LogLevelString(level) + " ";
        }

        if (id != null) {
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
            case LogLevel.DETAIL:
                return "DETAIL";
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
                              bool showOnlyOnce = false,
                              bool stackTrace = false) {
        Log(LogLevel.SEVERE, message, id, showOnlyOnce, stackTrace);
    }

    public static void Warning(string message,
                               string id = null,
                               bool showOnlyOnce = false,
                               bool stackTrace = false) {
        Log(LogLevel.WARNING, message, id, showOnlyOnce, stackTrace);
    }

    public static void Info(string message,
                            string id = null,
                            bool showOnlyOnce = false,
                            bool stackTrace = false) {
        Log(LogLevel.INFO, message, id, showOnlyOnce, stackTrace);
    }

    // Useful diagnostic detail that does not warrant Info or an automatic alert.
    public static void Detail(string message,
                              string id = null,
                              bool showOnlyOnce = false,
                              bool stackTrace = false) {
        Log(LogLevel.DETAIL, message, id, showOnlyOnce, stackTrace);
    }

    // "Old-school" development trace: repeat every call that passes the log level.
    // No IDs or once-only suppression. Use Debug for once-only traces, or a higher
    // severity for diagnostics that deserve an ID. Stack traces are optional.
    public static void Print(string message, bool stackTrace = false) {
        Log(LogLevel.PRINT, message, showStackTrace: stackTrace);
    }

    public static void Debug(string message,
                             string id = null,
                             bool showOnlyOnce = false,
                             bool stackTrace = false) {
        Log(LogLevel.DEBUG, message, id, showOnlyOnce, stackTrace);
    }

    public static LogLevel Level
    {
        get { return _logLevel; }

        set {
            if (value != _logLevel) {
                _logLevel = value;
                print("Logging level set to " + LogLevelString(_logLevel));
            }
        }
    }
}
