# Original Lingo source

These 30 files contain the readable script text embedded in
[ANIMATEM_1_02.DIR](../ANIMATEM_1_02.DIR), extracted directly from the movie's
cast-member records. They are original source, not decompiled reconstructions.
See the [Director Animatem guide](../README.md) for provenance and attribution.

Only text storage has been adapted: Macintosh Roman encoding becomes UTF-8,
classic Mac carriage returns become LF line endings, and a trailing null
terminator is omitted from `Rotate Continuously (frame-based).lingo`. Spelling,
comments, whitespace and code are otherwise preserved, with no added headers.
Each exported file was checked by reversing those conversions and comparing it
with its embedded source bytes. The Director movie is unchanged.

Filenames use the original cast-member names with a `.lingo` extension;
`Activate/Deactivate` uses a hyphen in place of the slash. Cast slots below are
the one-based positions in the movie's cast list. The source files are for
browsing and reference; they do not include the movie's images, score or other
Director setup, and have not been independently run.

Start with [ANIMATEM](ANIMATEM.lingo) and
[Animatem ancestor](Animatem%20ancestor.lingo), or the separate
[ancestor](Ancestor%20script%20for%20animate.lingo),
[parent](Parent%20script%20for%20animate.lingo) and
[callback](External%20animator%20calls.lingo) scripts. All scripts are retained,
including the demonstration behaviours and James Newton's rotation behaviour.
Their embedded copyright and attribution notices remain intact; extraction
does not assign a new licence.

| Cast slot | Original script name |
| --- | --- |
| 1 | [Go the Frame](Go%20the%20Frame.lingo) |
| 2 | [Start Movie](Start%20Movie.lingo) |
| 3 | [Ancestor script for animate](Ancestor%20script%20for%20animate.lingo) |
| 4 | [Parent script for animate](Parent%20script%20for%20animate.lingo) |
| 5 | [External animator calls](External%20animator%20calls.lingo) |
| 7 | [pressBtn](pressBtn.lingo) |
| 16 | [ANIMATEM](ANIMATEM.lingo) |
| 17 | [Animatem ancestor](Animatem%20ancestor.lingo) |
| 28 | [Rotate Continuously (frame-based)](Rotate%20Continuously%20%28frame-based%29.lingo) |
| 171 | [Activate/Deactivate](Activate-Deactivate.lingo) |
| 172 | [Velocity](Velocity.lingo) |
| 173 | [Velocity Horizontal](Velocity%20Horizontal.lingo) |
| 174 | [Velocity Vertical](Velocity%20Vertical.lingo) |
| 175 | [Acceleration Horizontal](Acceleration%20Horizontal.lingo) |
| 176 | [Acceleration Vertical](Acceleration%20Vertical.lingo) |
| 177 | [Velocity Maximum](Velocity%20Maximum.lingo) |
| 178 | [Location](Location.lingo) |
| 179 | [LocationH](LocationH.lingo) |
| 180 | [LocationV](LocationV.lingo) |
| 181 | [Animation Area](Animation%20Area.lingo) |
| 182 | [Walls](Walls.lingo) |
| 183 | [Cycles](Cycles.lingo) |
| 184 | [Turn Cycle](Turn%20Cycle.lingo) |
| 185 | [Walk Cycle 2 step](Walk%20Cycle%202%20step.lingo) |
| 186 | [Walk Cycle 3 step](Walk%20Cycle%203%20step.lingo) |
| 187 | [Walk Cycle 4 step](Walk%20Cycle%204%20step.lingo) |
| 188 | [Walk Cycle 5 step](Walk%20Cycle%205%20step.lingo) |
| 189 | [Walk Cycle 6 step](Walk%20Cycle%206%20step.lingo) |
| 190 | [MouseControl](MouseControl.lingo) |
| 191 | [Add Collision](Add%20Collision.lingo) |
