using System.IO;
using System.Collections.Generic;

public static class LocalizerExport
{
    public static void ExportFile(string fileName)
    {
        // load original file
        string fullFileName = Localizer.FullFileName(fileName);
        LocalizerKeys localizationKeys = JsonReader.ReadJson<LocalizerKeys>(fullFileName);
        if (localizationKeys == default) {
            return;     // file failed to load
        }

        // collect keys
        int nKeys = localizationKeys.keys.Length;
        string[] keys = new string[nKeys];
        for (int i = 0; i < nKeys; ++i) {
            LocalizerValue localizerValue = localizationKeys.keys[i];
            keys[i] = localizerValue.key;
        }

        // export keys
        CreateFile(fileName, keys);
    }

    public static void ExportKeys(string fileName, string[] keys)
    {
        List<string> keysList = new List<string>();         // includes variables at end
        List<string> justKeysList = new List<string>();
        string[] expandedKeys;
        foreach (string key in keys)
        {
            // expand compound keys
            expandedKeys = Localizer.GetKeys(key);
            foreach (string expandedKey in expandedKeys) {
                if (Localizer.IsKey(expandedKey))
                {
                    // prune duplicate keys
                    string justKey = Localizer.JustKey(expandedKey);
                    if (justKeysList.IndexOf(justKey) != -1)
                    {
                        // skip duplicate key
                        if (keysList.IndexOf(expandedKey) == -1)
                        {
                            // warn non-matching duplicate key
                            Logger.Warning("Found non-matching duplicate key while exporting.  key:" + justKey);
                        }
                    } else {
                        // add key
                        keysList.Add(expandedKey);
                        justKeysList.Add(justKey);
                    }
                }
            }
        }

        expandedKeys = keysList.ToArray();
        CreateFile(fileName, expandedKeys, true);
    }

    // Export localization string file with all variables removed from the key
    private static void CreateFile(string fileName, string[] keys, bool variablesInKeys = false)
	{
        // header
        string exportFileName = fileName + "_" + Localizer.LanguageCode + ".json";
        StreamWriter streamWriter = File.CreateText(exportFileName);
        streamWriter.WriteLine("{");
        streamWriter.WriteLine("    \"keys\": [");
        bool isFirst = true;

        // body
        foreach (string key in keys)
        {
            LocalizerValue value = Localizer.LocalizerValue(key);
            if (value == null) {
                continue;
			}

            if (!isFirst) {
                streamWriter.WriteLine("        },");
            }
            isFirst = false;

            string justKey = Localizer.JustKey(key);
            streamWriter.WriteLine("        {");
            streamWriter.WriteLine("            \"key\": \"" + justKey + "\",");
            if (!string.IsNullOrEmpty(value.context)) {
                streamWriter.WriteLine("            \"context\": \"" + value.context + "\",");
            }
            if (!string.IsNullOrEmpty(value.citation)) {
                streamWriter.WriteLine("            \"citation\": \"" + value.citation + "\",");
            }
            if (!string.IsNullOrEmpty(value.note)) {
                streamWriter.WriteLine("            \"note\": \"" + value.note + "\",");
            }
            string[] variables = variablesInKeys ? null : value.Variables;
            string export = Localizer.Value(key, variables);
            export = UtilsString.CorrectForQuotes(export);
            export = UtilsString.CorrectForTabs(export);

            // check for single quote
            if (UtilsString.CheckForQuote(export, false)) {
                Logger.Warning("Found \' in key:" + key);
			}
            
            streamWriter.WriteLine("            \"original\": \"" + export + "\",");
            streamWriter.WriteLine("            \"value\": \"" + export + "\"");
        }

        // footer
        streamWriter.WriteLine("        }");
        streamWriter.WriteLine("    ]");
        streamWriter.WriteLine("}");
        streamWriter.Close();

        Logger.Print(">>> Exported file:" + fileName);
    }
}