using System;
using System.Collections.Generic;
using LocalizerTypes;

/// <summary>Matches OS preferences against the locales supplied by the application.</summary>
public static class StartupLanguage
{
    public enum MatchKind { Exact, Regional, Fallback }

    public readonly struct Result
    {
        public LanguageCode Language { get; }
        public MatchKind Match { get; }
        public string FirstPreference { get; }
        public string MatchedPreference { get; }

        internal Result(LanguageCode language, MatchKind match, string firstPreference, string matchedPreference)
        {
            Language = language;
            Match = match;
            FirstPreference = firstPreference;
            MatchedPreference = matchedPreference;
        }
    }

    /// <summary>
    /// Selects the first supported preference. Supported-locale order determines
    /// regional defaults; defaultLanguage must be included in that list.
    /// Returns the selection without changing Localizer, logging or showing UI.
    /// </summary>
    public static Result Resolve(IEnumerable<string> preferences,
                                 IEnumerable<LanguageCode> supportedLanguages,
                                 LanguageCode defaultLanguage)
    {
        if (supportedLanguages == null) {
            throw new ArgumentNullException(nameof(supportedLanguages));
        }
        var supported = new List<LanguageCode>(supportedLanguages);
        if (!supported.Contains(defaultLanguage)) {
            throw new ArgumentException("The default language must be included in the supported languages.",
                nameof(defaultLanguage));
        }

        var tags = new List<string>();
        if (preferences != null) {
            foreach (string preference in preferences) {
                if (!string.IsNullOrWhiteSpace(preference)) {
                    tags.Add(preference.Trim().Replace('_', '-'));
                }
            }
        }
        string firstPreference = tags.Count == 0 ? null : tags[0];
        bool skippedPreference = false;
        foreach (string tag in tags) {
            // Exact supported locale, including appended locale extensions.
            foreach (LanguageCode candidate in supported) {
                string supportedTag = candidate.ToString().Replace('_', '-');
                if (tag.Equals(supportedTag, StringComparison.OrdinalIgnoreCase) ||
                    (supportedTag.Contains("-") && tag.StartsWith(supportedTag + "-", StringComparison.OrdinalIgnoreCase))) {
                    MatchKind match = candidate == defaultLanguage && skippedPreference
                        ? MatchKind.Fallback : MatchKind.Exact;
                    return new Result(candidate, match, firstPreference, tag);
                }
            }

            // The application's ordering chooses the preferred locale of each language.
            string language = tag.Split('-')[0];
            foreach (LanguageCode candidate in supported) {
                string supportedLanguage = candidate.ToString().Split('_')[0];
                if (language.Equals(supportedLanguage, StringComparison.OrdinalIgnoreCase)) {
                    MatchKind match = candidate == defaultLanguage && skippedPreference
                        ? MatchKind.Fallback : MatchKind.Regional;
                    return new Result(candidate, match, firstPreference, tag);
                }
            }
            skippedPreference = true;
        }
        return new Result(defaultLanguage, MatchKind.Fallback, firstPreference, null);
    }
}
