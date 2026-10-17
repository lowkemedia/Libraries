# Lowke Media Libraries

Small, useful libraries and examples from Lowke Media, primarily Unity/C# and Adobe ActionScript 3, with C++ utilities and teaching material.

**“Do one thing well and people will use it.”** The aim is many focused utilities that interconnect naturally. Prefer straightforward code, clear responsibilities and few dependencies. Changes should solve a concrete problem; age alone is not a reason to replace useful code, and cosmetic consistency is not a reason to introduce an overarching architecture.

**Learning C++?** Explore [Russell Lowke's C++ teaching collection](C%2B%2B%20Teaching/README.md), assembled while teaching at the Seattle Art Institute: 34 topics with PDF notes, source examples, homework and solutions, quizzes, an eight-part chess exercise and final game projects. Start with the course guide for a reading path and runnable examples.

## Directory guide

| Directory | Contents |
| --- | --- |
| [Unity/General](Unity/General/) | C# utilities for alerts, logging, synthesized and configured audio, animation/tweening, coroutines, buttons, dialogs, localization, paging, pointer events, video and general helpers. |
| [Adobe/src/com/lowke](Adobe/src/com/lowke/) | ActionScript 3 utilities for animation, action queues, asset loading/caching, sound, buttons, alerts, fonts, tooltips and display/data helpers; includes some FLA/SWC examples. |
| [C++/C++/src](C%2B%2B/C%2B%2B/src/) | Matrix and other helpers, plus an OpenGL/GLUT sprite animator. |
| [C++ Teaching](C%2B%2B%20Teaching/README.md) | C++ Programming I and II teaching materials: a linked course guide, PDF lessons, exercises, worked solutions, quizzes and projects. |
| [C++/Mersenne Twister](C%2B%2B/Mersenne%20Twister/) | Historical random-number implementation with external `ig*` dependencies and unresolved licensing notices; see below before reuse. |

## Using the code

Copy the utilities you need and their dependencies into your project, retaining copyright and attribution notices. This repository does not supply a Unity Package Manager package or a complete Unity project.

- **Unity:** copy selected files under your project's `Assets` tree. Follow their references as well as `using` directives: many classes share the global namespace. Components such as `Delayer`, `Animator`, `DialogManager` and `SoundHelper` need scene setup; Alert installs its own runtime host, and Click/Beep create theirs on first use. Preserve existing consumer `.meta` files when updating scripts: this repository ignores them and cannot supply stable Unity asset GUIDs.
- **ActionScript:** use `Adobe/src` as a source root, preserve package paths, and include imported helpers and any required assets. The source includes Flash APIs and some Flex dependencies; inspect the chosen utility's imports and comments rather than assuming every file has the same runtime requirements.
- **C++:** integrate individual sources/examples with their required headers and libraries. No single build configuration covers this collection.

See the [project map](PROJECT_MAP.md) for important dependencies and integration boundaries, [System alerts](Unity/General/Alert/README%20System%20Alerts.md) for Alert/Logger setup and lifecycle, and [Sound helpers](Unity/General/Sound/README.md) for Click, Beep and SoundHelper. Most other API documentation is in source comments; [Event and Delegate](Unity/General/Event%20and%20Delegate/) contains usage examples.

## Compatibility and verification

There is no declared or tested repository-wide minimum Unity, C# or ActionScript toolchain version. Unity dependencies visible in the source include uGUI/EventSystems, TextMeshPro for several text/UI utilities, Unity video APIs, and legacy `UnityEngine.Input`. Alert and the synthesized sounds use `RuntimeInitializeLoadType.SubsystemRegistration`; Alert also uses IMGUI and `Screen.safeArea`. These are integration requirements to check in the consuming project, not a verified version or platform support matrix.

No automated test suite, CI workflow, Unity scenes/prefabs, assembly definitions or Unity project settings are tracked here. Examples and application test history are not standalone library verification. Compile and exercise the selected utilities in the consuming project, especially UI input, scene lifetime and audio on target devices. Binary documents and assets use Git LFS according to [.gitattributes](.gitattributes); source files can be read independently.

## Licensing and attribution

Many Lowke Media source files carry an MIT permission notice in their headers. Preserve each file's copyright, permission and attribution text when copying or modifying it. There is no root licence file establishing uniform terms for every item, and some files have no licence header.

Third-party material has its own notices, including [FZip](Adobe/src/com/lowke/loadZip/deng/fzip/FZip.as) (Claus Wahlers and Max Herkender) and [Adobe/Robert Penner easing equations](Adobe/src/com/lowke/animator/effect/tween/easing/adobe/easing_readme.txt). The [Mersenne Twister header](C%2B%2B/Mersenne%20Twister/igMersenneTwisterRandomNumber.h) and implementation contain restrictive Vicarious Visions proprietary notices; the header also mentions an Artistic-licensed upstream algorithm. Permission to redistribute/reuse this particular implementation needs clarification from the maintainer. Do not infer a blanket MIT grant from the other files.

## Development and manual copies

Ages of Chess is a major consumer and development source. The usual workflow is to develop utilities in its `Assets/Code/General`, manually copy/replace General here, then review the Git differences. Neither copy is permanently authoritative. Compare changes and preserve library-only files, documentation and unrelated work before any future copy; synchronization is not automatic. See the [project map](PROJECT_MAP.md) for the October 2026 update and change boundaries.
