using System;
using UnityEngine;
using TMPro;
using LocalizerTypes;

[CreateAssetMenu]
public class SetOfFonts : ScriptableObject
{
    // Primary fonts
    public TMP_FontAsset goudy_lombardic_capitals_116;
    public TMP_FontAsset friz_quadrata_italic_32;
    public TMP_FontAsset friz_quadrata_italic_42;
    public TMP_FontAsset friz_quadrata_regular_36;
    public TMP_FontAsset friz_quadrata_regular_42;
    public TMP_FontAsset friz_quadrata_regular_52;

    // Russian fonts - Cyrillic
    public TMP_FontAsset oswald_110;
    public TMP_FontAsset ubuntu_32;
    public TMP_FontAsset ubuntu_36;
    public TMP_FontAsset ubuntu_42;
    public TMP_FontAsset ubuntu_italic_32;
    public TMP_FontAsset ubuntu_italic_36;
    public TMP_FontAsset ubuntu_italic_42;

    // Japanese fonts - Kanji
    public TMP_FontAsset hiragino_mincho_32;
    public TMP_FontAsset hiragino_mincho_36;
    public TMP_FontAsset hiragino_mincho_42;
    public TMP_FontAsset hiragino_mincho_112;

    public static SetOfFonts _instance;
    public static SetOfFonts Instance {
        get {
            if (_instance == default) {
                _instance = Resources.Load("LocalizerFonts") as SetOfFonts;
                if (_instance == default) {
                    throw new Exception("Could not find \"LocalizerFonts\" Scriptable resource.");
				}
            }
            return _instance;
        }
    }

    public TMP_FontAsset GetFont(string font)
    {
        switch (font) {

            // Primary fonts
            case "Goudy Text MT Lombardic Capitals SDF 116pt":
                return goudy_lombardic_capitals_116;
            case "Friz Quadrata Regular Italic SDF 32pt":
                return friz_quadrata_italic_32;
            case "Friz Quadrata Regular Italic SDF 42pt":
                return friz_quadrata_italic_42;
            case "Friz Quadrata Regular SDF 36pt":
                return friz_quadrata_regular_36;
            case "Friz Quadrata Regular SDF 42pt":
                return friz_quadrata_regular_42;
            case "Friz Quadrata Regular SDF 52pt":
                return friz_quadrata_regular_52;

            // Russian fonts - Cyrillic
            case "Oswald-VariableFont_wght SDF 110pt":
                return oswald_110;
            case "Ubuntu-Regular SDF 32pt":
                return ubuntu_32;
            case "Ubuntu-Regular SDF 36pt":
                return ubuntu_36;
            case "Ubuntu-Regular SDF 42pt":
                return ubuntu_42;
            case "Ubuntu-Italic SDF 32pt":
                return ubuntu_italic_32;
            case "Ubuntu-Italic SDF 36pt":
                return ubuntu_italic_36;
            case "Ubuntu-Italic SDF 42pt":
                return ubuntu_italic_42;

            // Japanese fonts - Kanji
            case "Hiragino Mincho ProN SDF 32pt":
                return hiragino_mincho_32;
            case "Hiragino Mincho ProN SDF 36pt":
                return hiragino_mincho_36;
            case "Hiragino Mincho ProN SDF 42pt":
                return hiragino_mincho_42;
            case "Hiragino Mincho ProN SDF 112pt":
                return hiragino_mincho_112;

            default:
                Logger.Severe("Could not find font " + font, LocalizerID.SEVERE_CANT_FIND_FONT, true);
                return null;
        }
    }
}
