# Project map

A guide to the utilities, their dependencies and integration points. Start with the
[Unity utilities guide](Unity/General/README.md) for setup and examples.

## Animatem

[Animatem](Unity/General/Animatem/README.md) provides code-driven movement, scaling,
fades and delays for Unity. Each target's Anime holds composable effects that can
run together, repeat, reverse and invoke completion callbacks.
[Parabola easing](Unity/General/Animatem/README%20Parabola.md) fits a curve through
a chosen time/value point for control over acceleration and overshoot.

Attach one Animatem component to a scene. Include AnimatemTypes, CallbackTypes,
Logger and GlobalState; the supplied UI effects also use uGUI. Its `Start()` sets
application frame-rate and Unity timing values on handheld devices. See the
[setup guide](Unity/General/Animatem/README.md#setup) for integration details.

## General Unity utilities

| Utility | Responsibility and important dependencies/setup |
| --- | --- |
| [SystemUI](Unity/General/SystemUI/README.md) | Alert provides queued runtime prompts with a persistent IMGUI host and uGUI pointer blocker. Include its Alert folder, Beep.cs, Click.cs and Rollover.cs from SystemUI/SystemSound, plus Logger.cs and CallbackTypes.cs. LoggerAlertBridge connects optional automatic alerts. No scene component is needed for the alert host. |
| [Logger](Unity/General/Logger/README.md) | Static Unity logging utility for severity filtering, searchable diagnostic IDs, once-only messages, stack traces, Print tracing and shared diagnostic-scenario labels. Copy [Logger.cs](Unity/General/Logger/Logger.cs); no other General utility, scene component or initialization call is required. `ShowAlert` enables requests through `AlertRequested` for eligible messages; connect a presenter such as LoggerAlertBridge to display them. Logger itself has no dependency on Alert. |
| [SoundHelper](Unity/General/Sound/README.md) | Plays configured AudioSources with optional completion callbacks. Uses CallbackTypes and Logger; attach the component and supply sources and an AudioListener. Sources can use audio assets or clips supplied by SystemSound. |
| [SystemSound](Unity/General/SystemUI/SystemSound/README.md) | Independent Click, Beep and Rollover helpers provide direct playback and shared generated clips using only Unity/System APIs. Each creates a persistent host on demand; playback needs an AudioListener. The optional SystemSound component assigns a clip to an AudioSource and requires all three helpers. |
| [Coroutine](Unity/General/Coroutine/README.md) | `Delayer` queues work for a later update or scaled-time delay; `Fader` fades uGUI Text; `Mover` moves transforms. Each requires its own attached component. Uses Logger, with `CallbackTypes` for Delayer/Mover. Do not assume work survives scene changes. |
| [Button](Unity/General/CanvasUI/Button/README.md) | Pointer-driven `ClickButton` and variants/styles. TextButton supports a pressed label offset while keeping the hit area stationary. Uses uGUI/EventSystems, SoundHelper and Delayer; text variants/factory also use TextMeshPro and localization/styling helpers. Consumers supply UI objects and styles. |
| [DialogManager](Unity/General/CanvasUI/DialogManager/README.md) | Scene-configured dialog stack with buttons, TextMeshPro, localization/styles, ClickBlocker and SoundHelper. Standard Dialog panels fit their height to rendered message text and prevent orphan lines. Keep messages top-anchored and buttons bottom-anchored; the authored height is the minimum. |
| [TextBacking](Unity/General/CanvasUI/README.md#text-backing-for-headings) | Generates a padded Image behind rendered TextMesh Pro text and follows its bounds. Attach TextBacking or call `AddTextBacking()` on a label. Uses TextMesh Pro and uGUI; independent of Localizer. |
| [Language selection](Unity/General/Localization/README.md) | LanguagePreference reads ordered device language tags, including the native Apple bridge; StartupLanguage matches them against supported locales and a default supplied by the application. Selection, persistence and localization initialization remain application responsibilities. |
| [Localizer](Unity/General/Localization/Localizer/README.md) | Loads JSON translations and recursively resolves keys supplied as arguments. `AddKey(key, style, variables, preventOrphans, giveWarning)` binds text/styles and returns a LocalizedText component that refreshes on language changes. Optional orphan prevention reflows single-word lines within a configurable pair-width limit. `AddFile` registers files for reloading; `LoadFile` loads transient content. Uses JsonReader, Logger, callback and utility helpers. Supply translations, styles, fonts and `Stylizer.FontResolver`; see the [font catalog example](Unity/General/Localization/Localizer/README.md#creating-your-own-font-catalog). Inline font references resolve on refresh. `LocalizerExport` writes files and accepts optional `PageFooterLines` for proofreading text exports. |
| [JsonReader](Unity/General/Json/README.md) | Reads JSON TextAssets from Resources through Unity `JsonUtility`. Include Logger and supply serializable data types matching the JSON. |
| [PopupMenu](Unity/General/CanvasUI/PopupMenu/README.md) | Popup, DropDown and Hamburger variants assembled from buttons, TextMeshPro, ClickBlocker and utility helpers; localized variants use Localizer. Needs consumer UI/assets. |
| [PageSwiper](Unity/General/CanvasUI/PageSwiper/README.md) | Drag/page navigation, page dots and numbers. Uses Mover, Utils/UtilsRect and callbacks; uGUI and TextMeshPro for relevant display components. |
| [PointerEventCopier](Unity/General/CanvasUI/PointerEventCopier/), [SwipeDetector](Unity/General/CanvasUI/SwipeDetector/), [ClickBlocker](Unity/General/CanvasUI/ClickBlocker/) | Event forwarding, swipe detection and pointer interception using uGUI/EventSystems. Application input polling is a separate concern. |
| [Utils](Unity/General/Utils/README.md), [GlobalState](Unity/General/GlobalState.cs), [ImageComposite](Unity/General/ImageComposite/README.md) | Array/string/number helpers, Unity object/geometry/color helpers, drag/device state and image composition. Numeric helpers include invariant formatting, K/M/B abbreviations and time-remaining labels. Dependencies differ by file: `UtilsRect`, for example, imports TextMeshPro. |
| [Video](Unity/General/Video/README.md) | Video playback and progress controls using Unity video APIs, configured UI/RenderTexture references, ClickButton and callbacks. |

Most C# classes live in the global namespace. Check name collisions and the full referenced helper set when copying a subset; folder boundaries are not assembly boundaries. Utilities that reference Logger require Logger.cs, but can omit SystemUI. Alert and Logger must share an assembly because explicit alerts use the internal LogNoAlert entry point.

## C++ Teaching

The root-level [C++ Teaching collection](C%2B%2B%20Teaching/README.md) covers
Programming I and II through 34 topics, with PDF notes, source examples,
homework and solutions, quizzes and final projects. Start with the course guide
and [Getting Started](C%2B%2B%20Teaching/02%20Getting%20Started/README.md) for
compilation instructions. The [eight-part chess exercise](C%2B%2B%20Teaching/_Chess%20Example/README.md)
progresses through classes, inheritance and polymorphism. Examples are individual
programs with their own setup; there is no single build for the collection.

## Boundaries for future work

- Keep utilities focused. Change abstractions or dependencies only for a demonstrated need, considering the requirements of consuming projects.
- Preserve public APIs, callback order/lifetime and serialized field names unless a change is intentional and reviewed. Use `_camelCase` for private C# fields and Logger helpers for ordinary diagnostics. Catch exceptions only where there is concrete recovery behaviour.
- Keep application recovery, persistence and navigation decisions in the consumer. Alert reports choices; it does not own those policies. Keep sound synthesis independent of SoundHelper; SystemSound supplies shared clips while the configured AudioSources and their callers control playback.
- When copying utilities between a consuming project and this repository, compare both sides first, retain library-only documentation and unrelated changes, and do not assume either side is permanently authoritative. No automatic synchronization is configured.
- Review, commit and push manually. Unity launch/upgrades, package installation and source changes require their own task scope.

## Uncertainties

Minimum toolchain versions and a target-platform verification matrix are not established. No tracked automated tests or runnable Unity fixture were found; delegate examples are demonstrations. Scene/resource setup for older UI utilities needs consumer validation. Root licence coverage for files without headers needs maintainer clarification. Compile and exercise selected utilities in the consuming project, including UI, audio and native plug-ins on target devices.

## Other reference material

[Legacy ActionScript 3 libraries](Adobe/src/com/lowke/) are retained for reference.
They include animation, action queues, asset loading, sound and UI helpers. Use
`Adobe/src` as the source root and keep imported companion classes and assets;
some utilities depend on Flex. FLA/SWC examples and bundled FZip/easing code
retain their own notices. A complete ActionScript build has not been verified here.

[A few C++ helpers](C%2B%2B/C%2B%2B/src/) include matrix utilities and an
OpenGL/GLUT sprite animator. Integrate individual sources with their required
headers and libraries.
