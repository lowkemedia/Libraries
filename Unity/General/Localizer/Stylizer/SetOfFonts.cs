﻿using System;
using UnityEngine;
using TMPro;
using LocalizerTypes;

[CreateAssetMenu]
public class SetOfFonts : ScriptableObject
{
    // Primary fonts
    public TMP_FontAsset black_castle_50;
    public TMP_FontAsset black_castle_72_ruby;
    public TMP_FontAsset black_castle_72_coin;
    public TMP_FontAsset black_castle_88;
    public TMP_FontAsset black_castle_118;
    public TMP_FontAsset black_castle_166;

    public TMP_FontAsset bookerly_italic_32;
    public TMP_FontAsset bookerly_regular_38;
    public TMP_FontAsset bookerly_regular_50;
    public TMP_FontAsset bookerly_bold_54;


    // Russian fonts - Cyrillic
    public TMP_FontAsset oswald_46;
    public TMP_FontAsset oswald_96;
    public TMP_FontAsset oswald_150;


    // Japanese fonts - Kanji
    public TMP_FontAsset hiragino_mincho_32;
    public TMP_FontAsset hiragino_mincho_38;
    public TMP_FontAsset hiragino_mincho_50;
    public TMP_FontAsset hiragino_mincho_96;


    public static SetOfFonts _instance;
    public static SetOfFonts Instance {
        get {
            if (_instance == default) {
                _instance = Resources.Load("Localizer Fonts") as SetOfFonts;
                if (_instance == default) {
                    throw new Exception("Could not find \"Localizer Fonts\" Scriptable resource.");
				}
            }
            return _instance;
        }
    }

    public TMP_FontAsset GetFont(string font)
    {
        switch (font) {

            //
            // Primary fonts

            //  title font
            case "BlackCastleMF SDF 50 px":
                return black_castle_50;
            case "BlackCastleMF SDF 72 px 12 pd ruby #":
                return black_castle_72_ruby;
            case "BlackCastleMF SDF 72 px 12 pd coin #":
                return black_castle_72_coin;
            case "BlackCastleMF SDF 88 px":
                return black_castle_88;
            case "BlackCastleMF SDF 118 px":
                return black_castle_118;
            case "BlackCastleMF SDF 166 px":
                return black_castle_166;

            //  body font
            case "Bookerly-RegularItalic SDF 32 px":
                return bookerly_italic_32;
            case "Bookerly-Regular SDF 38 px":
                return bookerly_regular_38;
            case "Bookerly-Regular SDF 50 px":
                return bookerly_regular_50;
            case "Bookerly-Bold SDF 54 px":
                return bookerly_bold_54;

            //
            // Russian fonts - Cyrillic

            case "Oswald-VariableFont_wght SDF 46 px":
                return oswald_46;
            case "Oswald-VariableFont_wght SDF 96 px":
                return oswald_96;
            case "Oswald-VariableFont_wght SDF 150 px":
                return oswald_150;

            //
            // Japanese fonts - Kanji

            case "Hiragino Mincho ProN SDF 32 px":
                return hiragino_mincho_32;
            case "Hiragino Mincho ProN SDF 38 px":
                return hiragino_mincho_38;
            case "Hiragino Mincho ProN SDF 50 px":
                return hiragino_mincho_50;
            case "Hiragino Mincho ProN SDF 96 px":
                return hiragino_mincho_96;


            default:
                Logger.Severe("Could not find font " + font, LocalizerID.SEVERE_CANT_FIND_FONT, true);
                return null;
        }
    }
}
