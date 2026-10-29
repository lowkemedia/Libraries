//
//  LanguagePreference - Lowke Media General utilities
//  Copyright (c) 2026 Lowke Media
//  https://github.com/lowkemedia/Libraries
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

using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
#if UNITY_EDITOR_OSX || ((UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR)
using System.Runtime.InteropServices;
#endif
#if UNITY_EDITOR_OSX
using System.Text;
#endif

/// <summary>
/// Reads the user's ordered OS language preferences. Does not select a translation,
/// change Localizer, save settings, or infer a language from location.
/// </summary>
public static class LanguagePreference
{
    // Shape check only: do not depend on the runtime's possibly older culture registry.
    private static readonly Regex _languageTag = new Regex(@"\A[a-zA-Z]{2,8}(?:-[a-zA-Z0-9]{1,8})*\z");
    private static bool _reportedBindingFailure;

    [UnityEngine.RuntimeInitializeOnLoadMethod(UnityEngine.RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void ResetSession()
    {
        _reportedBindingFailure = false;
    }

    /// <summary>
    /// Returns a fresh array of language tags, most preferred first (e.g. fr-CH, de-CH).
    /// In the macOS Editor, reads the Mac's preferences regardless of the build target.
    /// Empty means unavailable, including platforms not yet implemented.
    /// Call on Unity's main thread. Query again after returning from OS settings;
    /// the OS may require an app restart before its updated preferences are visible.
    /// </summary>
    public static string[] GetPreferredLanguages()
    {
        return ReadLanguages(GetPlatformLanguages);
    }

    /// <summary>Returns the first OS preference, or null when unavailable.</summary>
    public static string GetPreferredLanguage()
    {
        string[] languages = GetPreferredLanguages();
        return languages.Length == 0 ? null : languages[0];
    }

    private static string GetPlatformLanguages()
    {
#if UNITY_EDITOR_OSX
        return GetMacEditorLanguages();
#elif UNITY_EDITOR
        return null;
#elif UNITY_IOS || UNITY_TVOS
        return GetAppleLanguages();
#elif UNITY_ANDROID
        return GetAndroidLanguages();
#elif UNITY_WEBGL
        return GetWebGLLanguages();
#else
        return null;
#endif
    }

    private static string GetAndroidLanguages()
    {
        // Extension point: read the app's effective LocaleList, honoring per-app languages.
        return null;
    }

    private static string GetWebGLLanguages()
    {
        // Extension point: read navigator.languages through a .jslib bridge.
        return null;
    }

    private static string[] ReadLanguages(Func<string> read)
    {
        try {
            return ParseLanguages(read());
        }
        catch (Exception exception) when (exception is DllNotFoundException ||
                                           exception is EntryPointNotFoundException ||
                                           exception is BadImageFormatException) {
            if (!_reportedBindingFailure) {
                _reportedBindingFailure = true;
                Alert.Warning("Language preferences unavailable: check the native plug-in import settings.\n\n" +
                    exception.GetType().Name + ": " + exception.Message,
                    "Language detection", id: LanguagePreferenceID.WARNING_NATIVE_BINDING_UNAVAILABLE);
            }
            return Array.Empty<string>();
        }
    }

    private static string[] ParseLanguages(string value)
    {
        if (string.IsNullOrWhiteSpace(value)) {
            return Array.Empty<string>();
        }

        var languages = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (string entry in value.Split('\n')) {
            string tag = entry.Trim().Replace('_', '-');
            // "und" is the language code for undetermined, not a usable preference.
            if (!_languageTag.IsMatch(tag) ||
                tag.Equals("und", StringComparison.OrdinalIgnoreCase) ||
                tag.StartsWith("und-", StringComparison.OrdinalIgnoreCase)) {
                continue;
            }
            if (seen.Add(tag)) {
                languages.Add(tag);
            }
        }
        return languages.ToArray();
    }

#if UNITY_EDITOR_OSX
    // Call the system framework directly; the mobile source plug-in is not an
    // Editor binary. CFIndex is pointer-sized, and CoreFoundation Boolean is one byte.
    private const string CORE_FOUNDATION = "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation";
    private const uint UTF8_ENCODING = 0x08000100;

    [DllImport(CORE_FOUNDATION)]
    private static extern IntPtr CFLocaleCopyPreferredLanguages();

    [DllImport(CORE_FOUNDATION)]
    private static extern IntPtr CFArrayGetCount(IntPtr array);

    [DllImport(CORE_FOUNDATION)]
    private static extern IntPtr CFArrayGetValueAtIndex(IntPtr array, IntPtr index);

    [DllImport(CORE_FOUNDATION)]
    private static extern IntPtr CFStringGetLength(IntPtr value);

    [DllImport(CORE_FOUNDATION)]
    [return: MarshalAs(UnmanagedType.I1)]
    private static extern bool CFStringGetCString(IntPtr value, [Out] byte[] buffer,
        IntPtr bufferSize, uint encoding);

    [DllImport(CORE_FOUNDATION)]
    private static extern void CFRelease(IntPtr value);

    private static string GetMacEditorLanguages()
    {
        IntPtr preferences = CFLocaleCopyPreferredLanguages();
        if (preferences == IntPtr.Zero) {
            return null;
        }
        try {
            var languages = new string[CFArrayGetCount(preferences).ToInt32()];
            for (int i = 0; i < languages.Length; ++i) {
                // The array owns its CFStrings; release only the copied array below.
                IntPtr language = CFArrayGetValueAtIndex(preferences, new IntPtr(i));
                int length = CFStringGetLength(language).ToInt32();
                // At most three UTF-8 bytes per UTF-16 code unit, plus the terminator.
                var buffer = new byte[checked(length * 3 + 1)];
                if (CFStringGetCString(language, buffer, new IntPtr(buffer.Length), UTF8_ENCODING)) {
                    languages[i] = Encoding.UTF8.GetString(buffer, 0, Array.IndexOf(buffer, (byte)0));
                }
            }
            return string.Join("\n", languages);
        }
        finally {
            CFRelease(preferences);
        }
    }
#endif

#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern IntPtr LowkeLanguagePreference_CopyLanguages();

    [DllImport("__Internal")]
    private static extern void LowkeLanguagePreference_FreeLanguages(IntPtr languages);

    private static string GetAppleLanguages()
    {
        IntPtr languages = LowkeLanguagePreference_CopyLanguages();
        if (languages == IntPtr.Zero) {
            return null;
        }
        try {
            // Language tags contain ASCII characters only; native storage is UTF-8.
            return Marshal.PtrToStringAnsi(languages);
        }
        finally {
            LowkeLanguagePreference_FreeLanguages(languages);
        }
    }
#endif
}

public static class LanguagePreferenceID
{
    // Error, warning and info IDs.
    public const string WARNING_NATIVE_BINDING_UNAVAILABLE = "LANG00";
}
