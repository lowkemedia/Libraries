# Project map

A guide to the utilities, their dependencies and integration points. Start with the
[Unity utilities guide](Unity/General/README.md) for setup and examples.

## Unity/General

| Utility | Responsibility and important dependencies/setup |
| --- | --- |
| [SystemUI](Unity/General/SystemUI/README.md) | Alert provides queued runtime prompts with a persistent IMGUI host and uGUI pointer blocker. Include its Alert folder, Beep.cs, Click.cs and Rollover.cs from SystemUI/SystemSound, plus Logger.cs and CallbackTypes.cs. LoggerAlertBridge connects optional automatic alerts. No scene component is needed for the alert host. |
| [Logger](Unity/General/Logger/README.md) | Static Unity logging utility for severity filtering, searchable diagnostic IDs, once-only messages, stack traces, Print tracing and shared diagnostic-scenario labels. Copy [Logger.cs](Unity/General/Logger/Logger.cs); no other General utility, scene component or initialization call is required. `ShowAlert` enables requests through `AlertRequested` for eligible messages; connect a presenter such as LoggerAlertBridge to display them. Logger itself has no dependency on Alert. |
| [SoundHelper](Unity/General/Sound/README.md) | Plays configured AudioSources with optional completion callbacks. Uses CallbackTypes and Logger; attach the component and supply sources and an AudioListener. Sources can use audio assets or clips supplied by SystemSound. |
| [SystemSound](Unity/General/SystemUI/SystemSound/README.md) | Independent Click, Beep and Rollover helpers provide direct playback and shared generated clips using only Unity/System APIs. Each creates a persistent host on demand; playback needs an AudioListener. The optional SystemSound component assigns a clip to an AudioSource and requires all three helpers. |
| [Animatem](Unity/General/Animatem/README.md) | Animatem owns Anime objects and composable AnimatemEffect/tween effects. Uses AnimatemTypes, CallbackTypes, Logger and GlobalState; some effects use uGUI. Attach the component to a scene. Start changes application frame-rate and Unity timing settings on handheld devices. |
| [Coroutine](Unity/General/Coroutine/) | `Delayer` queues work for a later update or scaled-time delay; `Fader` fades uGUI Text; `Mover` moves transforms. Each requires its own attached component. Uses Logger, with `CallbackTypes` for Delayer/Mover. Do not assume work survives scene changes. |
| [Button](Unity/General/CanvasUI/Button/) | Pointer-driven `ClickButton` and variants/styles. Uses uGUI/EventSystems, SoundHelper and Delayer; text variants/factory also use TextMeshPro and localization/styling helpers. Consumers supply UI objects and styles. |
| [DialogManager](Unity/General/CanvasUI/DialogManager/) | Scene-configured `DialogManager`, `DialogBase` and `Dialog` with buttons, TextMeshPro, localization/styles, ClickBlocker and SoundHelper. Separate from the self-installed system Alert. |
| [Language selection](Unity/General/Localization/README.md) | LanguagePreference reads ordered device language tags, including the native Apple bridge; StartupLanguage matches them against supported locales and a default supplied by the application. Selection, persistence and localization initialization remain application responsibilities. |
| [Localizer](Unity/General/Localization/Localizer/README.md) / [JsonReader](Unity/General/Json/JsonReader.cs) | Loads JSON translations from Resources through Unity `JsonUtility`. Recursively resolves keys supplied as arguments, including keys with their own arguments, before substituting them into translated sentences. `AddKey` binds expressions to TextMesh Pro labels that refresh on language changes. `AddFile` registers files for reloading; `LoadFile` loads transient content. Uses Logger, callback and utility helpers. Supply translations, styles, fonts and `Stylizer.FontResolver` for font selection. LocalizedText also resolves inline font style references on each refresh. See the [font catalogue example](Unity/General/Localization/Localizer/README.md#creating-your-own-font-catalogue) for setup. `LocalizerExport` writes files; inspect its output conventions before use. |
| [PopupMenu](Unity/General/CanvasUI/PopupMenu/) | Popup, drop-down and hamburger variants assembled from buttons, TextMeshPro, ClickBlocker and utility helpers; localized variants use Localizer. Needs consumer UI/assets. |
| [PageSwiper](Unity/General/CanvasUI/PageSwiper/) | Drag/page navigation, page dots and numbers. Uses Mover, Utils/UtilsRect and callbacks; uGUI and TextMeshPro for relevant display components. |
| [PointerEventCopier](Unity/General/CanvasUI/PointerEventCopier/), [SwipeDetector](Unity/General/CanvasUI/SwipeDetector/), [ClickBlocker](Unity/General/CanvasUI/ClickBlocker/) | Event forwarding, swipe detection and pointer interception using uGUI/EventSystems. Application input polling is a separate concern. |
| [Utils](Unity/General/Utils/), [GlobalState](Unity/General/GlobalState.cs), [ImageComposite](Unity/General/ImageComposite/) | Array/string/number helpers, Unity object/geometry/color helpers, drag/device state and image composition. Dependencies differ by file: `UtilsRect`, for example, imports TextMeshPro. |
| [Video](Unity/General/Video/) | Video playback and progress controls using Unity video APIs, configured UI/RenderTexture references, ClickButton and callbacks. |

Most C# classes live in the global namespace. Check name collisions and the full referenced helper set when copying a subset; folder boundaries are not assembly boundaries. Utilities that reference Logger require Logger.cs, but can omit SystemUI. Alert and Logger must share an assembly because explicit alerts use the internal LogNoAlert entry point.

## Adobe and C++

The ActionScript collection under `Adobe/src/com/lowke` includes `Animator`/effects, `ActionQueue`, `AssetLoader`, `AssetManager`, `SoundManager`, UI helpers and `util`. Keep imported event, loader and value-object classes with the selected utility. Source comments provide examples and historical runtime annotations (for example, the Adobe Animator says ActionScript 3.0 / Flash 10); these do not establish a tested minimum for the entire tree. FLA/SWC examples and bundled FZip/easing code retain their own provenance. Some imports refer to Flex or older package paths; a complete ActionScript build has not been verified here.

The `C++` tree contains independent helpers and an OpenGL/GLUT animator. The separate root-level [C++ Teaching](C%2B%2B%20Teaching/README.md) collection contains the course notes, exercises and projects. The Mersenne Twister files depend on `ig*` headers not supplied here, and their permission status is unresolved; see [licensing](README.md#licensing-and-attribution).

## Boundaries for future work

- Keep utilities focused. Change abstractions or dependencies only for a demonstrated need, considering consumers beyond Ages of Chess.
- Preserve public APIs, callback order/lifetime and serialized field names unless a change is intentional and reviewed. Use `_camelCase` for private C# fields and Logger helpers for ordinary diagnostics. Catch exceptions only where there is concrete recovery behaviour.
- Keep application recovery, persistence and navigation decisions in the consumer. Alert reports choices; it does not own those policies. Keep sound synthesis independent of SoundHelper; SystemSound supplies shared clips while the configured AudioSources and their callers control playback.
- Manual synchronization normally comes from Ages of Chess's `Assets/Code/General`. Compare both sides first, retain library-only documentation and unrelated changes, and do not assume either side is permanently authoritative. No automatic synchronization is configured.
- Review, commit and push manually. Unity launch/upgrades, package installation and source changes require their own task scope.

## Uncertainties

Minimum toolchain versions and a target-platform verification matrix are not established. No tracked automated tests or runnable Unity fixture were found; delegate examples are demonstrations. Scene/resource setup for older UI utilities needs consumer validation. Root licence coverage for files without headers and the restrictive C++ notices need maintainer clarification. Compile and exercise selected utilities in the consuming project, including UI, audio and native plug-ins on target devices.
