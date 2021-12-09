//
//  Localizer v 1.0 - Localizer package
//  Russell Lowke, December 20th 2020
//
//  Copyright (c) 2019-2020 Lowke Media
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
using CallbackTypes;

public class Localizer : MonoBehaviour
{
    public const char KEY_PREFEX = '.';             // all keys begin with a '.'
    public const char SEPERATOR = '+';              // compound keys are seperated by '+'
    public const char BAR = '|';                    // varables passed into keys are separated by '|'
    public const string BRACES = "{}";              // curly braces indicate a variable
    public const char DELIMINATOR = ' ';            // deliminator added between keys, e.g. ".angry+.bees" returns "Angry Bees"
    public const string TEST_RETURN = "*";          // when testing, all keys return "*"

    public static event Callback OnLanguageChangedEvent;

    // delegate allowing external modification of variables passed into keys
    public delegate string[] VariablesDelegate(string[] variables);
    public static VariablesDelegate VariablesTinkerer;  // call to modify variables passed into keys

    private static Dictionary<string, LocalizerValue> _keyValuePairs;
    private static List<string> _files;             // files used for localization
    private static string _styleFile;               // file used for stylesheet

    private static LanguageCode _languageCode = LanguageCode.en_GB;
    public static LanguageCode LanguageCode {
        get { return _languageCode; }
        set { Initialize(value); }
    }

    public static LanguageType LanguageType {
        get { return (LanguageType) (int) _languageCode; }
        set { Initialize((LanguageCode) (int) value); }
    }
    public static LanguageType GetLanguageType(LanguageCode value)
    {
        return (LanguageType) (int) value;
    }

    public static LanguageName LanguageName {
        get { return (LanguageName) (int) _languageCode; }
        set { Initialize((LanguageCode) (int) value); }
    }
    public static LanguageName GetLanguageName(LanguageCode value)
    {
        return (LanguageName) (int) value;
    }

    public static string LanguageString {
        get { return GetLanguageNameString(LanguageCode); }
    }
    public static string GetLanguageNameString(LanguageCode value)
    {
        switch (value) {
            case LanguageCode.en_GB:
                return "English (UK)";
            case LanguageCode.en_US:
                return "English (US)";
            default:
                return GetLanguageName(value).ToString();
        }
    }

    public static bool Initialized {
        get { return _keyValuePairs != null; }
    }

    // A root folder may be set for Localization
    public static string Root { get; set; }         // filepath root, if any.

    // This is for testing if all strings pass through the Localizer
    public static bool Testing { get; set; }    // when true all keys return "*"

    public static void Initialize(LanguageCode languageCode, bool clearFiles = false)
    {
        _languageCode = languageCode;
        _keyValuePairs = new Dictionary<string, LocalizerValue>();
        if (_files is null || clearFiles) {
            _files = new List<string>();
        }

        if (!string.IsNullOrEmpty(_styleFile)) {
            SetStyle(_styleFile);
        }

        foreach (string file in _files) {
            LoadFile(file, true);
        }

        OnLanguageChangedEvent?.Invoke();
    }

    public static void SetStyle(string fileName, bool giveWarning = true)
    {
        _styleFile = fileName;
        Stylizer.LoadStyle(fileName, true, giveWarning);
    }

    public static void AddFile(string fileName, bool giveWarning = true)
    {
        _files.Add(fileName);
        LoadFile(fileName, giveWarning);
    }

    public static string FullFileName(string fileName)
    {
        string fullFileName = "";
        if (!string.IsNullOrEmpty(Root)) {
            // include language type folder to path
            fullFileName += Root + LanguageType + "/";
        }
        fullFileName += fileName + "_" + _languageCode;

        return fullFileName;
	}

    public static void LoadFile(string fileName, bool giveWarning = true)
    {
        if (!Initialized) {
            Logger.Severe("Can't load localization file:\"" + fileName + "\" as Localizer not initialized.", LocalizerID.SEVERE_CANT_LOAD_FILE);
            return;
        }

        string fullFileName = FullFileName(fileName);
        LocalizerKeys localizationKeys = JsonReader.ReadJson<LocalizerKeys>(fullFileName);
        if (localizationKeys == default) {
            return;     // file failed to load
        }

        // add keys to dictionary
        foreach (LocalizerValue value in localizationKeys.keys) {
            value.FileName = fullFileName;
            string key = value.key.ToLower();
            bool found = _keyValuePairs.TryGetValue(key, out LocalizerValue stringKeyValue);
            if (found && giveWarning) {
                Logger.Warning("Duplicate key:\"" + key + "\" value:\"" + value + "\" file:\"" + fullFileName + "\" existing:\"" + stringKeyValue.value + "\" file:\"" + stringKeyValue.FileName + "\"", LocalizerID.WARNING_DUPLICATE_KEY);
            }
            
            _keyValuePairs[key] = value;
        }
    }

    // retrieve LocalizerValue of key
    public static LocalizerValue LocalizerValue(string key, bool giveWarning = true)
    {
        key = JustKey(key);

        if (!Initialized) {
            Logger.Severe("Can't localize key:\"" + key + "\" as Localizer not initialized.", LocalizerID.SEVERE_CANT_READ_KEY);
            return null;
        }

        // force all keys to lower case
        key = key.ToLower();

        bool found = _keyValuePairs.TryGetValue(key, out LocalizerValue stringKeyValue);
        if (!found && giveWarning) {
            Logger.Warning("Can't find key:\"" + key + "\" in localization dictionary " + LanguageCode + ".", LocalizerID.WARNING_COULD_NOT_FIND_KEY, true);
        }

        return stringKeyValue;
    }

    // retrieve Value of key
    public static string Value(string key,
                               string[] variables = null,
                               bool giveWarning = true)
    {
        //
        // check for compound key
        if (key.IndexOf(SEPERATOR) > -1) {
            return CompoundKey(key, variables, giveWarning);
        }

        //
        // ensure key starts with a '.'
        if (!IsKey(key)) {
            if (giveWarning) {
                Logger.Warning("Received invalid key \"" + key + "\"", LocalizerID.WARNING_INVALID_KEY_PASSED);
            }

            return (Testing) ? TEST_RETURN : key;
        }

        string[] strlist = ExpandKey(key);
        if (strlist.Length > 1) {
            // found embedded variables in key
            if (variables != null) {
                if (giveWarning) {
                    // but variables were passed into Value()
                    Logger.Warning("Key \"" + key + "\" has embedded variables: " + UtilsArray.Print(strlist) + ", but was passed in variable parameters: " + UtilsArray.Print(variables), LocalizerID.WARNING_HAS_EMBEDDED_AND_PASSED_VARIABLES);
                }
            } else {
                // transfer embedded vars to variables list
                variables = new string[strlist.Length - 1];
                for (int i = 0; i < variables.Length; i++) {
                    variables[i] = strlist[i + 1];
                }
            }
        }
        key = strlist[0];

        // if assigned, use VariablesTinkerer delegate to modify variables list
        if (VariablesTinkerer != null && UtilsArray.HasValue(variables)) {
            variables = VariablesTinkerer(variables);
        }

        //
        // retrieve value
        LocalizerValue stringKeyValue = LocalizerValue(key);
        string value;
        if (stringKeyValue != null) {
            value = stringKeyValue.value;

            //
            // replace variables
            if (variables != null) {

                // save variables last used with this key
                stringKeyValue.Variables = variables;

                // substitute variables
                int counter = 0;
                foreach (string variableKey in variables) {
                    string variableValue = Value(variableKey, null, false);
                    string replaceWithVariable = "";
                    replaceWithVariable += BRACES[0];
                    replaceWithVariable += counter++;
                    replaceWithVariable += BRACES[1];
                    value = value.Replace(replaceWithVariable, variableValue);
                }
            }

        } else {

            // if failed to get value, then use the key
            value = key;
        }

        return (Testing) ? TEST_RETURN : value;
    }

    private static string CompoundKey(string key,
                                      string[] variables = null,
                                      bool giveWarning = true)
    {
        string[] keylist = GetKeys(key);
        string value = "";
        string previousKey = default;
        for (int i = 0; i < keylist.Length; ++i) {
            string thisKey = keylist[i];
            if (IsKey(previousKey) && IsKey(thisKey)) {
                value += DELIMINATOR;
            }
            bool warn = giveWarning && IsKey(thisKey);     // compound keys warn only for embedded keys
            value += Value(thisKey, variables, warn);
            previousKey = thisKey;
        }

        return value;
    }

    // find Key used for a value
    public static string FindKey(string value, bool giveWarning = true)
    {
        foreach (KeyValuePair<string, LocalizerValue> keyValuePair in _keyValuePairs) {
            LocalizerValue keyValue = keyValuePair.Value;
            if (keyValue.value == value) {
                return keyValue.key;
            }
        }

        if (giveWarning) {
            Logger.Warning("Coud not find value:\"" + value + "\" in localization dictionary.", LocalizerID.WARNING_COULD_NOT_FIND_VALUE);
        }

        return null;
    }

    public static bool IsKey(string value)
    {
        // return true if value starts with '.'
        return !string.IsNullOrEmpty(value) && value[0] == KEY_PREFEX;
    }

    public static string JustKey(string key)
    {
        // remove any embedded variables from end of key
        return ExpandKey(key)[0];
    }

    public static string[] ExpandKey(string key)
    {
        // break key into key and variables
        //  embedded variables seperated by '|'
        char[] spearator = { BAR };
        return key.Split(spearator);
    }

    public static string[] GetKeys(string key)
	{
        // break compound key into individual keys
        //  compound keys seperated by '+'
        char[] seperator = { SEPERATOR };
        return key.Split(seperator);
	}

    public static string Citation(string key)
    {
        return LocalizerValue(key).citation;
    }
}