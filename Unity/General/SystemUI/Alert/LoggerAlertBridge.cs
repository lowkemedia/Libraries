//
//  LoggerAlertBridge - optional Logger/SystemUI integration
//  Extracted from Russell Lowke's Logger, October 2026.
//
//  Copyright (c) 2019-2026 Lowke Media
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

using UnityEngine;

// Keep this adapter with SystemUI; Logger itself has no UI dependency.
internal static class LoggerAlertBridge
{
    // Runs after subsystem resets and before scene Awake/OnEnable, even without domain reload.
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
    private static void Install()
    {
        Logger.AlertRequested -= ShowAlert;
        Logger.AlertRequested += ShowAlert;
    }

    private static void ShowAlert(Logger.LogLevel level, string message)
    {
        // Alert queues requests safely; never log them again or touch UI on the caller's thread.
        switch (level) {
            case Logger.LogLevel.SEVERE:
                Alert.Severe(message, log: false);
                break;
            case Logger.LogLevel.WARNING:
                Alert.Warning(message, log: false);
                break;
            case Logger.LogLevel.INFO:
                Alert.Info(message, log: false);
                break;
        }
    }
}
