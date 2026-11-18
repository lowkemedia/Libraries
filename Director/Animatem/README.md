# Animatem for Director / Lingo

[ANIMATEM_1_02.DIR](ANIMATEM_1_02.DIR) preserves an early Lingo
version of [Animatem](../../Unity/General/Animatem/README.md), written by Russell
J Lowke. It is an unchanged copy of the standalone file preserved alongside the
Crusades Director prototype, including its original spelling, comments and
attribution.

## The file

This is an actual Director movie, not a ZIP or self-extracting archive. Its
`RIFX` / `MV93` container holds cast members, images, compiled scripts and
readable Lingo source. No unpacking is needed. The archive filename was
`ANIMATEM.DIR 1.02 conv`; only the name has been changed here to give the file
a `.DIR` extension. `1.02` suggests the circulated version number, but the
meaning of `conv` has not been established.

The embedded source includes `Ancestor script for animate`, `Parent script for
animate`, `External animator calls`, `ANIMATEM` and `Animatem ancestor`, along
with behaviours for velocity, acceleration, positioning, animation cycles,
boundaries and collisions. The source can be inspected inside the movie; loose
Lingo files are not required for it to survive.

The binary is stored with Git LFS. Obtain the actual file through Git LFS or
GitHub's download control, rather than an LFS pointer. Playback and editing in
Director have not been verified as part of this preservation work.

## Origins and attribution

The Animatem scripts carry a 1998 MOCAZ copyright and Russell J Lowke's authorship
credit. MOCAZ was his company name before Lowke Media; Lowke Media retained the
MOCAZ logo. Earlier animator scripts preserved in Frogger carry an explicit
2 November 1995 authorship date, and Asteroid animation scripts carry 1996
copyright notices. These source dates do not establish when this package was
published. Archived MOCAZ web pages provide contemporary context for the games
and their author.[^mocaz]

The Crusades `COMBAT.DIR` contains a different variant with game-specific audio
and callbacks; `MAP.DIR` contains a variant with 1996 headers. Neither establishes
a definitive latest standalone release. This file preserves the packaged copy
without merging those variants.

Keep the embedded copyright and attribution notices intact, including the
James Newton credit on `Rotate Continuously (frame-based)`. The original notices
are preserved; no new licence is assigned to this historical file.

The original online repository remains unidentified. See the
[SVN archive guide](../../README%20SVN%20Archives.md) for the later Google Code
repositories and source downloads.

[^mocaz]: Wayback Machine snapshots: [Asteroids, 21 October 1999](https://web.archive.org/web/19991021224730/http://www.mocaz.com:80/asteroids.html), [Russell Lowke's résumé, 13 October 1999](https://web.archive.org/web/19991013055017/http://www.mocaz.com:80/Russ.html), and [Crusades, 22 February 2001](https://web.archive.org/web/20010222203907/http://www.mocaz.com:80/crusades.html). These document the MOCAZ site and game material at the time; they do not establish where the standalone Animatem source was published.
