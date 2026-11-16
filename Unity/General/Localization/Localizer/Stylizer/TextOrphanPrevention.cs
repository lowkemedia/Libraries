// Reflows resolved localized text without changing its words or rich-text markup.
using System.Collections.Generic;
using TMPro;

public static class TextOrphanPrevention
{
    // Call outside TMP's graphic rebuild (for example, from LateUpdate).
    // Always supply the original resolved text when the language or width changes.
    public static void Apply(TextMeshProUGUI textField, string localizedText,
        float maxOrphanPairWidthRatio = 0.35f)
    {
        textField.text = localizedText;
        textField.ForceMeshUpdate();
        var rejectedSpaces = new HashSet<int>();

        // Each attempt either removes a breakable space or rejects that position.
        // This bounds the work even when a pair cannot fit in the available width.
        for (int attempt = 0; attempt < localizedText.Length; ++attempt) {
            if (!FindOrphan(textField.textInfo, rejectedSpaces,
                out int previousWordStart, out int previousWordEnd,
                out int orphanStart, out int orphanEnd, out int spaceIndex)) {
                break;
            }

            TMP_CharacterInfo[] characters = textField.textInfo.characterInfo;

            string before = textField.text;
            char[] adjusted = before.ToCharArray();
            for (int i = previousWordEnd + 1; i < orphanStart; ++i) {
                if (characters[i].character == ' ' || characters[i].character == '\t') {
                    int sourceIndex = characters[i].index;
                    if (before[sourceIndex] == ' ' || before[sourceIndex] == '\t') {
                        adjusted[sourceIndex] = '\u00a0';
                    }
                }
            }
            string candidate = new string(adjusted);
            if (candidate == before) {
                rejectedSpaces.Add(spaceIndex);
                continue;
            }
            textField.text = candidate;
            textField.ForceMeshUpdate();

            // TMP may split an over-wide nonbreaking group. Keep the original layout
            // if the two whole words still cannot share a line.
            characters = textField.textInfo.characterInfo;
            bool pairFitsOnOneLine = characters[previousWordStart].lineNumber == characters[orphanEnd].lineNumber;
            float pairWidth = characters[orphanEnd].xAdvance - characters[previousWordStart].origin;
            float availableWidth = textField.rectTransform.rect.width - textField.margin.x - textField.margin.z;
            // Measure the joined pair, including its space, after TMP has laid it out.
            bool pairReachesWidthLimit = !float.IsNaN(maxOrphanPairWidthRatio) &&
                pairWidth >= availableWidth * maxOrphanPairWidthRatio;
            if (!pairFitsOnOneLine || pairReachesWidthLimit) {
                rejectedSpaces.Add(spaceIndex);
                textField.text = before;
                textField.ForceMeshUpdate();
            }
        }
    }

    private static bool FindOrphan(TMP_TextInfo textInfo, HashSet<int> rejectedSpaces,
        out int previousWordStart, out int previousWordEnd,
        out int orphanStart, out int orphanEnd, out int spaceIndex)
    {
        previousWordStart = previousWordEnd = orphanStart = orphanEnd = spaceIndex = -1;
        for (int line = 1; line < textInfo.lineCount; ++line) {
            if (CountWords(textInfo, line, out orphanStart, out orphanEnd) != 1 ||
                CountWords(textInfo, line - 1, out previousWordStart, out previousWordEnd) < 2) {
                continue;
            }

            TMP_CharacterInfo[] characters = textInfo.characterInfo;
            // Do not split a group already joined by a nonbreaking space.
            if (previousWordStart > 0 && characters[previousWordStart - 1].character == '\u00a0') {
                continue;
            }

            bool explicitBreak = false;
            spaceIndex = -1;
            for (int i = previousWordEnd + 1; i < orphanStart; ++i) {
                char character = characters[i].character;
                if (character == '\n' || character == '\r' || character == '\u2028' || character == '\u2029') {
                    explicitBreak = true;
                }
                if (character == ' ' || character == '\t') {
                    spaceIndex = characters[i].index;
                }
            }
            if (!explicitBreak && spaceIndex >= 0 && !rejectedSpaces.Contains(spaceIndex)) {
                return true;
            }
        }
        return false;
    }

    // Words are whitespace-separated runs, including their punctuation. Sprites
    // count as content too, so a word accompanied by an icon is not an orphan.
    private static int CountWords(TMP_TextInfo textInfo, int lineIndex, out int lastStart, out int lastEnd)
    {
        lastStart = lastEnd = -1;
        TMP_LineInfo line = textInfo.lineInfo[lineIndex];
        int count = 0;
        bool insideWord = false;
        for (int i = line.firstCharacterIndex; i <= line.lastCharacterIndex && i < textInfo.characterCount; ++i) {
            TMP_CharacterInfo character = textInfo.characterInfo[i];
            if (char.IsWhiteSpace(character.character) || character.character == '\u200b') {
                insideWord = false;
                continue;
            }
            if (!insideWord) {
                ++count;
                lastStart = i;
                insideWord = true;
            }
            lastEnd = i;
        }
        return count;
    }
}
