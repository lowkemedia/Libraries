# Lowke Media Libraries

Small, useful libraries and examples from Lowke Media, primarily Unity/C# and Adobe ActionScript 3, with C++ utilities and teaching material.

**“Do one thing well and people will use it.”** The aim is many focused utilities that interconnect naturally. Prefer straightforward code, clear responsibilities and few dependencies. Changes should solve a concrete problem; age alone is not a reason to replace useful code, and cosmetic consistency is not a reason to introduce an overarching architecture.

**Learning C++?** Explore [Russell Lowke's C++ teaching collection](C%2B%2B%20Teaching/README.md), assembled while teaching at the Seattle Art Institute: 34 topics with PDF notes, source examples, homework and solutions, quizzes, an eight-part chess exercise and final game projects. Start with the course guide for a reading path and runnable examples.

## Directory guide

| Directory | Contents |
| --- | --- |
| [Unity/General](Unity/General/README.md) | C# utilities for alerts, logging, synthesized and configured audio, animation/tweening, coroutines, buttons, dialogs, localization, paging, pointer events, video and general helpers. |
| [C++ Teaching](C%2B%2B%20Teaching/README.md) | C++ Programming I and II teaching materials: a linked course guide, PDF lessons, exercises, worked solutions, quizzes and projects. |
| [Adobe/src/com/lowke](Adobe/src/com/lowke/) | Legacy ActionScript 3 utilities retained for reference: animation, action queues, asset loading/caching, sound, buttons, alerts, fonts, tooltips and display/data helpers; includes some FLA/SWC examples. |
| [C++/C++/src](C%2B%2B/C%2B%2B/src/) | A few C++ helpers, including matrix utilities and an OpenGL/GLUT sprite animator. |

## Using the code

Copy the utilities you need and their dependencies into your project, retaining copyright and attribution notices. This repository does not supply a Unity Package Manager package or a complete Unity project.

- **Unity:** copy selected files under your project's `Assets` tree. Follow their references as well as `using` directives: many classes share the global namespace. Components such as `Delayer`, `Animatem`, `DialogManager` and `SoundHelper` need scene setup; Alert installs its own runtime host, and Click, Beep and Rollover create theirs on demand. The optional `SystemSound` component supplies generated clips to configured AudioSources. Preserve existing consumer `.meta` files when updating scripts: this repository ignores them and cannot supply stable Unity asset GUIDs.
- **ActionScript:** use `Adobe/src` as a source root, preserve package paths, and include imported helpers and any required assets. The source includes Flash APIs and some Flex dependencies; inspect the chosen utility's imports and comments rather than assuming every file has the same runtime requirements.
- **C++:** integrate individual sources/examples with their required headers and libraries. No single build configuration covers this collection.

The [Unity utilities guide](Unity/General/README.md) and [project map](PROJECT_MAP.md) provide starting points and dependency overviews. Useful guides include:

- [Logger](Unity/General/Logger/README.md): practical debugging with severity filtering, searchable diagnostic IDs, once-only messages, stack traces and Print tracing. Optional alert presentation makes diagnostics visible on devices without a debugger; test-context labels identify the scenario producing a message.
- [System alerts](Unity/General/SystemUI/README.md): Alert/Logger setup and lifecycle.
- [System sounds](Unity/General/SystemUI/SystemSound/README.md): synthesized Click, Beep and Rollover, shared clips and the AudioSource adapter.
- [SoundHelper](Unity/General/Sound/README.md): configured audio and playback callbacks.
- [Animatem](Unity/General/Animatem/README.md): tweens, groups, easing and animation lifetime.
- [Localizer](Unity/General/Localization/Localizer/README.md): JSON translations with [recursive keys](Unity/General/Localization/Localizer/README.md#recursive-keys-compose-translations), so a sentence can reuse translated names and phrases, including keys with their own arguments. `AddKey` binds text and styles to TextMesh Pro labels that refresh when the language changes, with optional [orphan prevention](Unity/General/Localization/Localizer/README.md#preventing-single-word-orphan-lines) for single-word lines.
- [Language preferences](Unity/General/Localization/LanguagePreference/README.md): Apple language detection and native plug-in setup.
- [CanvasUI](Unity/General/CanvasUI/README.md): buttons, content-sized dialogs, popup menus, paging and generated text backings.
- [General helpers](Unity/General/Utils/README.md): object, array, color, string and numeric utilities, including invariant number and time formatting.

Further guides cover [coroutines](Unity/General/Coroutine/README.md), [JSON resources](Unity/General/Json/README.md), [image composition](Unity/General/ImageComposite/README.md), [video controls](Unity/General/Video/README.md) and [events and delegates](Unity/General/Event%20and%20Delegate/README.md). Source comments provide additional API details.

## Compatibility and verification

There is no declared or tested repository-wide minimum Unity, C# or ActionScript toolchain version. Unity dependencies visible in the source include uGUI/EventSystems, TextMeshPro for several text/UI utilities, Unity video APIs, and legacy `UnityEngine.Input`. Alert and the synthesized sounds use `RuntimeInitializeLoadType.SubsystemRegistration`; Alert also uses IMGUI and `Screen.safeArea`. These are integration requirements to check in the consuming project, not a verified version or platform support matrix.

No automated test suite, CI workflow, Unity scenes/prefabs, assembly definitions or Unity project settings are tracked here. Examples and application test history are not standalone library verification. Compile and exercise the selected utilities in the consuming project, especially UI input, scene lifetime and audio on target devices. Binary documents and assets use Git LFS according to [.gitattributes](.gitattributes); source files can be read independently.

## Licensing and attribution

Many Lowke Media source files carry an MIT permission notice in their headers. Preserve each file's copyright, permission and attribution text when copying or modifying it. There is no root licence file establishing uniform terms for every item, and some files have no licence header.

Third-party material has its own notices, including [FZip](Adobe/src/com/lowke/loadZip/deng/fzip/FZip.as) (Claus Wahlers and Max Herkender) and [Adobe/Robert Penner easing equations](Adobe/src/com/lowke/animator/effect/tween/easing/adobe/easing_readme.txt). Do not infer a blanket MIT grant from the other files.

## Development and manual copies

Utilities can be developed in a consuming project and copied here manually for review. Compare both copies before replacing files, preserving library-only documentation and unrelated work; neither copy is permanently authoritative. Synchronization is not automatic. See the [project map](PROJECT_MAP.md) for utility dependencies and integration boundaries.
