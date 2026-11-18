# Lowke Media Libraries

Unity animation and focused C# utilities from Lowke Media, alongside a C++ teaching collection.

**“Do one thing well and people will use it.”** The aim is many focused utilities that interconnect naturally. Prefer straightforward code, clear responsibilities and few dependencies. Changes should solve a concrete problem; age alone is not a reason to replace useful code, and cosmetic consistency is not a reason to introduce an overarching architecture.

## Animatem — animation for Unity

**[Animatem](Unity/General/Animatem/README.md) earns its place when you need consistent easing, replacement, cancellation, grouping and callbacks across many animations.** It coordinates small effects, each responsible for a particular change, so callers can compose movement and timing without rebuilding that coordination for every interaction.

It grew out of synchronizing movement and timing in games. Carefully tuned motion is part of a game's feel: retaining familiar durations, easing parameters and sequences can matter as much as adding new effects. The ActionScript lineage also makes existing animation values a useful starting point when porting games; verify the resulting feel in Unity rather than assuming an exact match.

Reuse existing FXs first and add small reusable effects for missing capabilities. Use timed effects for transitions and settling; keep pointer-driven movement tied directly to drag progress. Coroutines are not inherently smoother or faster: with the same values and update cadence, they can produce the same motion. Animatem's value is its shared coordination and control over that motion.

Its distinctive **[Parabola easing](Unity/General/Animatem/README%20Parabola.md)** lets you specify a point along the motion: **“be 76.5% of the way there at half time.”** A quadratic curve through that point gives control over acceleration, anticipation and overshoot.

Start with the [first animation example](Unity/General/Animatem/README.md#a-first-animation), browse the [available effects](Unity/General/Animatem/README.md#available-effects), or explore the illustrated [Parabola guide](Unity/General/Animatem/README%20Parabola.md).

## General Unity libraries

[Unity/General](Unity/General/README.md) contains small C# utilities for logging, alerts, audio, localization, Canvas controls and everyday programming tasks. Copy the utilities you need with their companion dependencies. The [project map](PROJECT_MAP.md) explains how they fit together.

- [Logger](Unity/General/Logger/README.md): practical debugging with severity filtering, searchable diagnostic IDs, once-only messages, stack traces and Print tracing. Optional alert presentation makes diagnostics visible on devices without a debugger; test-context labels identify the scenario producing a message.
- [System alerts](Unity/General/SystemUI/README.md): Alert/Logger setup and lifecycle.
- [System sounds](Unity/General/SystemUI/SystemSound/README.md): synthesized Click, Beep and Rollover, shared clips and the AudioSource adapter.
- [SoundHelper](Unity/General/Sound/README.md): configured audio and playback callbacks.
- [Localizer](Unity/General/Localization/Localizer/README.md): JSON translations with [recursive keys](Unity/General/Localization/Localizer/README.md#recursive-keys-compose-translations), so a sentence can reuse translated names and phrases, including keys with their own arguments. `AddKey` binds text and styles to TextMesh Pro labels that refresh when the language changes, with optional [orphan prevention](Unity/General/Localization/Localizer/README.md#preventing-single-word-orphan-lines) for single-word lines.
- [Language preferences](Unity/General/Localization/LanguagePreference/README.md): Apple language detection and native plug-in setup.
- [CanvasUI](Unity/General/CanvasUI/README.md): buttons, content-sized dialogs, popup menus, paging and generated text backings.
- [General helpers](Unity/General/Utils/README.md): object, array, color, string and numeric utilities, including invariant number and time formatting.

Further guides cover [coroutines](Unity/General/Coroutine/README.md), [JSON resources](Unity/General/Json/README.md), [image composition](Unity/General/ImageComposite/README.md), [video controls](Unity/General/Video/README.md) and [events and delegates](Unity/General/Event%20and%20Delegate/README.md). Source comments provide additional API details.

## C++ Teaching

[Russell Lowke's C++ teaching collection](C%2B%2B%20Teaching/README.md), assembled while teaching at the Seattle Art Institute, covers Programming I and II through 34 topics. It includes PDF notes, source examples, homework and solutions, quizzes, an eight-part chess exercise and final game projects.

Start with the [course guide](C%2B%2B%20Teaching/README.md) for a reading path and runnable examples, or work through the [chess exercise](C%2B%2B%20Teaching/_Chess%20Example/README.md) to explore classes, inheritance and polymorphism.

## Using the code

Copy the utilities you need and their dependencies into your project, retaining copyright and attribution notices. This repository does not supply a Unity Package Manager package or a complete Unity project.

- **Unity:** copy selected files under your project's `Assets` tree. Follow their references as well as `using` directives: many classes share the global namespace. Components such as `Delayer`, `Animatem`, `DialogManager` and `SoundHelper` need scene setup; Alert installs its own runtime host, and Click, Beep and Rollover create theirs on demand. The optional `SystemSound` component supplies generated clips to configured AudioSources. Preserve existing consumer `.meta` files when updating scripts: this repository ignores them and cannot supply stable Unity asset GUIDs.
- **C++:** integrate individual sources/examples with their required headers and libraries. No single build configuration covers this collection.

## Compatibility and verification

There is no declared or tested repository-wide minimum Unity, C# or ActionScript toolchain version. Unity dependencies visible in the source include uGUI/EventSystems, TextMeshPro for several text/UI utilities, Unity video APIs, and legacy `UnityEngine.Input`. Alert and the synthesized sounds use `RuntimeInitializeLoadType.SubsystemRegistration`; Alert also uses IMGUI and `Screen.safeArea`. These are integration requirements to check in the consuming project, not a verified version or platform support matrix.

No automated test suite, CI workflow, Unity scenes/prefabs, assembly definitions or Unity project settings are tracked here. Examples and application test history are not standalone library verification. Compile and exercise the selected utilities in the consuming project, especially UI input, scene lifetime and audio on target devices. Binary documents and assets use Git LFS according to [.gitattributes](.gitattributes); source files can be read independently.

## Other reference material

[Legacy ActionScript 3 libraries](Adobe/src/com/lowke/) are retained for reference. Use `Adobe/src` as the source root and preserve package paths; dependencies include Flash APIs and, for some utilities, Flex. The repository also contains [a few C++ helpers](C%2B%2B/C%2B%2B/src/), including matrix utilities and an OpenGL/GLUT sprite animator.

The [historical SVN archive guide](README%20SVN%20Archives.md) provides links to the preserved Google Code projects and source downloads for earlier Lowke Media utilities.

The original [Director / Lingo Animatem](Director/Animatem/README.md) is also preserved as a Director movie with its embedded source.

## Licensing and attribution

Many Lowke Media source files carry an MIT permission notice in their headers. Preserve each file's copyright, permission and attribution text when copying or modifying it. There is no root licence file establishing uniform terms for every item, and some files have no licence header.

Third-party material has its own notices, including [FZip](Adobe/src/com/lowke/loadZip/deng/fzip/FZip.as) (Claus Wahlers and Max Herkender) and [Adobe/Robert Penner easing equations](Adobe/src/com/lowke/animator/effect/tween/easing/adobe/easing_readme.txt). Do not infer a blanket MIT grant from the other files.

## Development and manual copies

Utilities can be developed in a consuming project and copied here manually for review. Compare both copies before replacing files, preserving library-only documentation and unrelated work; neither copy is permanently authoritative. Synchronization is not automatic. See the [project map](PROJECT_MAP.md) for utility dependencies and integration boundaries.
