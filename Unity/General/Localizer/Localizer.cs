//
//  Localizer v 1.0 - Localizer package
//  Russell Lowke, November 15th 2019
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

using UnityEngine;
using LocalizerTypes;
using System;

public class Localizer : MonoBehaviour
{
    private static LanguageCode _languageCode = LanguageCode.en;
    private static LocalizationValue _localizationValue;
    // TODO: use Dictionary

    public static LanguageType Language
    {
        get { return ConvertLanguageCode(_languageCode); }
        set { Initialize(ConvertLanguageType(value)); }
    }

    public static LanguageCode LanguageCode
    {
        get { return _languageCode; }
        set { Initialize(value); }
    }

    public static void Initialize(LanguageCode languageCode)
    {
        _languageCode = languageCode;
        string fileName = "Localization/StringKeys_" + _languageCode;
        _localizationValue = JsonReader.ReadJson<LocalizationValue>(fileName);
    }

    public static StringKeyValue Key(string key)
    {
        if (_localizationValue == null) {
            Initialize(_languageCode);
        }

        // force all keys to lower case
        key = key.ToLower();

        // TODO: Use Dictionary
        foreach (StringKeyValue value in _localizationValue.keys)
        {
            string valueKey = value.key.ToLower();
            if (valueKey == key) {
                return value;
            }
        }

        Logger.Severe("Could not find localization key \"" + key + "\"", LocalizerID.SEVERE_COULD_NOT_FIND_KEY);
        return null;
    }

    public static string Value(string key, 
                               string[] variables = null,
                               bool giveWarning = true)
    {
        //
        // ensure key starts with a '.'
        if (key[0] != '.')
        {
            if (giveWarning) {
                Logger.Warning("Received invalid key \"" + key + "\"", LocalizerID.WARNING_INVALID_KEY_PASSED);
            }
            return key;
        }

        //
        // check for compound key
        if (key.IndexOf('+') > -1) {
            return CompoundKey(key, variables, giveWarning);
        }

        //
        // parse embedded variables, seperated by '|'
        char[] spearator = { '|' };
        string[] strlist = key.Split(spearator);

        if (strlist.Length > 1)
        {
            // found embedded variables
            if (variables != null) {
                if (giveWarning) {
                    // but variables were passed in
                    Logger.Warning("Key \"" + key + "\" has embedded variables, but was passed in variables " + variables, LocalizerID.WARNING_HAS_EMBEDDED_AND_PASSED_VARIABLES);
                }
            }
            else
            {
                // transfer embedded vars to variables list
                variables = new string[strlist.Length - 1];
                for (int i = 0; i < variables.Length; i++) {
                    variables[i] = strlist[i + 1];
                }
            }
        }
        key = strlist[0];

        //
        // retrieve value
        string value = Key(key).value;

        //
        // replace variables
        if (variables != null)
        {
            int counter = 0;
            foreach (string variableKey in variables) {
                string variableValue = Value(variableKey, null, false);
                value = value.Replace("{" + counter++ + "}", variableValue);
            }
        }

        return value;
    }

    private static string CompoundKey(string key, 
                                      string[] variables = null,
                                      bool giveWarning = true, 
                                      string delimiter = " ")
    {
        //
        // parse compound keys, seperated by '+'
        char[] spearator = { '+' };
        string[] keylist = key.Split(spearator);

        string value = "";
        foreach (string kkey in keylist) {
            value += Value(kkey, variables, giveWarning) + delimiter;
            // TODO: Don't add delimiter after last item
        }
        return value;
    }

    public static string Citation(string key)
    {
        return Key(key).citation;
    }

    public static LanguageCode ConvertLanguageType(LanguageType languageType)
    {
        return (LanguageCode) (int) languageType;
    }

    public static LanguageType ConvertLanguageCode(LanguageCode languageCode)
    {
        return (LanguageType) (int) languageCode;
    }
}
