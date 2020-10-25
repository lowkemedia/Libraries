using System;
using UnityEngine;

public static class JsonReader
{
	public static T ReadJson<T>(string path)
	{
        // Logger.Print(">> Loading Json file:" + fileName);

        T gameValue = default(T);
        TextAsset textJsonAsset = Resources.Load<TextAsset>(path);
        if (textJsonAsset is null) {
            Logger.Warning("Coudn't load file \"" + path + "\".", JsonReaderID.WARNING_CANT_LOAD_FILE);
        } else {
            string jsonString = textJsonAsset.ToString();
            try {
                gameValue = JsonUtility.FromJson<T>(jsonString);
            } catch (Exception error) {
                string errorMessage = error.Message;
                string className = typeof(T).FullName;
                Logger.Severe("Coudn't read JSON file \"" + path + "\" for class: " + className + " with error:" + errorMessage, JsonReaderID.SEVERE_CANT_LOAD_FILE);
            }
        }
		return gameValue;
	}
}

public static class JsonReaderID
{
	//
	// error, warning and info IDs
	public const string LOG_PREFIX = "JSN";
	public const string WARNING_CANT_LOAD_FILE = LOG_PREFIX + "00";
	public const string SEVERE_CANT_LOAD_FILE = LOG_PREFIX + "01";
}
