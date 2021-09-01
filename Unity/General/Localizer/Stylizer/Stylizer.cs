//
//  Stylizer v 1.0 - Localizer package
//  Russell Lowke, November 22nd 2020
//
//  Copyright (c) 2020 Lowke Media
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


using TMPro;
using UnityEngine;
using LocalizerTypes;
using System.Collections.Generic;

public static class Stylizer
{
    private static Dictionary<string, LocalizerStyle> _styles;

    public static bool Initialized {
        get { return _styles != null; }
    }

    public static void LoadStyle(string fileName, bool clearExistingStyles, bool giveWarning = true)
    {
        if (_styles == default || clearExistingStyles) {
            _styles = new Dictionary<string, LocalizerStyle>();
        }

        string fullFileName = "";
        if (!string.IsNullOrEmpty(Localizer.Root)) {
            // include language type folder to path
            fullFileName += Localizer.Root + Localizer.LanguageType + "/";
        }
        fullFileName += fileName + "_" + Localizer.LanguageCode;
        LocalizerStyles styles = JsonReader.ReadJson<LocalizerStyles>(fullFileName);
        if (styles == default) {
            return;     // file failed to load
        }

        foreach (LocalizerStyle value in styles.styles) {
            string style = value.style.ToLower();
            bool found = _styles.TryGetValue(style, out LocalizerStyle localizerStyle);
            if (found && giveWarning) {
                Logger.Warning("Duplicate style:\"" + style + "\" in file:\"" + fileName + "\" existing:\"" + localizerStyle.style + "\" replacement:\"" + value.style + "\"", LocalizerID.WARNING_DUPLICATE_STYLE);
            }
            _styles[style] = value;
        }
    }

    // retrieve LocalizerStyle
    public static LocalizerStyle LocalizerStyle(string style, bool giveWarning = true)
    {
        if (string.IsNullOrEmpty(style)) {
            return default;
		}

        if (!Initialized) {
            Logger.Severe("Can't find style:\"" + style + "\" as Stylizer not initialized.", LocalizerID.SEVERE_CANT_READ_STYLE, true);
            return default;
        }

        // force style to lower case
        style = style.ToLower();

        bool found = _styles.TryGetValue(style, out LocalizerStyle localizerStyle);
        if (!found && giveWarning) {
            Logger.Warning("Can't find style:\"" + style + "\" in stylizer dictionary.", LocalizerID.WARNING_COULD_NOT_FIND_STYLE, true);
        }

        return localizerStyle;
    }

    public static void ApplyStyle(TextMeshProUGUI textField, string style, bool giveWarning = true)
    {
        string alignment = textField.alignment.ToString();
        if (giveWarning && !alignment.Contains("Baseline")) {
            Logger.Warning("Localized textfield \"" + textField.name + "\" should use baseline alignment.", LocalizerID.WARNING_NEEDS_BASELINE_ALIGNMENT, true);
        }

        LocalizerStyle localizerStyle = LocalizerStyle(style, giveWarning);
        if (localizerStyle != default) {
            if (localizerStyle.font != default) {
                SetOfFonts setOfFonts = SetOfFonts.Instance;
                TMP_FontAsset fontAsset = setOfFonts.GetFont(localizerStyle.font);
                if (fontAsset != default) {
                    textField.font = fontAsset;
                }
            }

            if (!float.IsNaN(localizerStyle.fontSize)) {
                // TODO: setting font size not always working?
                textField.fontSize = localizerStyle.fontSize;
            }

            if (!float.IsNaN(localizerStyle.lineSpacing)) {
                textField.lineSpacing = localizerStyle.lineSpacing;
            }
            if (!float.IsNaN(localizerStyle.characterSpacing)) {
                textField.characterSpacing = localizerStyle.characterSpacing;
            }
        }
    }

    public static void AddStyle(this TextMeshProUGUI textField,
                                string text,
                                string style)
    {
        textField.AddKey(text, default, style, false);
    }

	public static void AddKey(this TextMeshProUGUI textField,
                              string key,
                              string[] variables = default,
                              string style = default,               // TODO: Put style before variables, no need for AddStyle()
                              bool giveWarning = true)
    {
        GameObject gameObject = textField.gameObject;
        if (gameObject is null) {
            Logger.Severe("Could not add localization key:\"" + key + "\" to null TextField");
            return;
        }
        LocalizedText localizedText;
        localizedText = gameObject.GetComponent<LocalizedText>();
        if (localizedText is null) {
            localizedText = gameObject.AddComponent<LocalizedText>();
        }
        localizedText.SetKey(key, variables, style, giveWarning);
    }
}