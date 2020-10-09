//
//  Localizer v 1.0 - Localizer package
//  Russell Lowke, October 7th 2020
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
using System.Collections.Generic;

public class Localizer : MonoBehaviour
{
    private static Dictionary<string, StringKeyValue> _stringKeys;
    private static List<string> _files;

    private static LanguageCode _languageCode = LanguageCode.en_GB;
    public static LanguageCode LanguageCode {
        get { return _languageCode; }
        set { Initialize(value); }
    }

    public static LanguageType LanguageType {
        get { return (LanguageType)(int)_languageCode; }
        set { Initialize((LanguageCode)(int)value); }
    }
    public static LanguageType GetLanguageType(LanguageCode value) {
        return (LanguageType)(int)value;
	}

    public static LanguageName LanguageName {
        get { return (LanguageName)(int)_languageCode; }
        set { Initialize((LanguageCode)(int)value); }
    }
    public static LanguageName GetLanguageName(LanguageCode value) {
        return (LanguageName)(int)value;
    }

    public static bool Initialized {
        get { return _stringKeys != null; }
	}

    public static void Initialize(LanguageCode languageCode, bool clearFiles = false)
    {
        _languageCode = languageCode;
        _stringKeys = new Dictionary<string, StringKeyValue>();
        if (_files == null || clearFiles) {
            _files = new List<string>();
        }

        foreach (string file in _files) {
            LoadFile(file, true);
        }
    }

    public static void AddFile(string fileName, bool giveWarning = true)
	{
        _files.Add(fileName);
        LoadFile(fileName, giveWarning);
    }

    public static void LoadFile(string fileName, bool giveWarning = true)
    {
        if (!Initialized) {
            Logger.Severe("Can't load localization file:\"" + fileName + "\" as Localizer not initialized.", LocalizerID.SEVERE_CANT_LOAD_FILE);
            return;
        }

        string fullFileName = fileName + "_" + _languageCode;
        LocalizationValue localizationValue = JsonReader.ReadJson<LocalizationValue>(fullFileName);

        if (localizationValue == default) {
            return;
		}

        // add keys to dictionary
        foreach (StringKeyValue value in localizationValue.keys) {
            string key = value.key.ToLower();
            bool found = _stringKeys.TryGetValue(key, out StringKeyValue stringKeyValue);
            if (found && giveWarning) {
                Logger.Warning("Duplicate key:\"" + key + "\" in file:\"" + fileName + "\" existing:\"" + stringKeyValue.value + "\" replacement:\"" + value.value + "\"", LocalizerID.WARNING_DUPLICATE_KEY);
            }
            _stringKeys[key] = value;
        }
    }

    public static StringKeyValue Key(string key, bool giveWarning = true)
    {
        if (!Initialized) {
            Logger.Severe("Can't localize key:\"" + key + "\" as Localizer not initialized.", LocalizerID.SEVERE_CANT_READ_KEY);
            return null;
        }

        // force all keys to lower case
        key = key.ToLower();

        bool found = _stringKeys.TryGetValue(key, out StringKeyValue stringKeyValue);
        if (!found && giveWarning) {
            Logger.Warning("Can't find key:\"" + key + "\" in localization dictionary.", LocalizerID.WARNING_COULD_NOT_FIND_KEY, true);
        }
        
        return stringKeyValue;
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
        StringKeyValue stringKeyValue = Key(key);
        string value = (stringKeyValue != null) ? stringKeyValue.value : key;

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
}
