using System;
using UnityEngine;

public static class JsonReader
{
	public static T ReadJson<T>(string path)
	{
		// Logger.Print(">> Loading Json file:" + fileName);
		TextAsset textJsonAsset = Resources.Load<TextAsset>(path);
		string jsonString = textJsonAsset.ToString();
		T gameValue = default(T);
		try {
			gameValue = JsonUtility.FromJson<T>(jsonString);
		} catch (Exception error) {
			string errorMessage = error.Message;
			string className = typeof(T).FullName;
			Logger.Severe("Coudn't read JSON file \"" + path + "\" for class: " + className + " with error:" + errorMessage);
		}

		return gameValue;
	}
}
