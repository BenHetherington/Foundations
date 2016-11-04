# Foundations
**The beginnings of an RPG for the Game Boy Color.**

This is still very much a work-in-progress, and isn't properly playable yet. However, lots has gone into this project in order to lay out the foundations for a fully playable RPG.

Some of the implemented features so far include:
- [Variable-width text display](Strings/) (with support for [prompts](Strings/Prompts.asm)).
- A [sound engine](Sound/). Still WIP, but includes features like LSDJ-style tables.
- [Sample playback](Sound/Samples/), including the [Antispike technique](http://blog.gg8.se/wordpress/2013/02/11/gameboy-project-week-6-can-i-have-an-a-men/) for GBAs.
- A [fixed version](https://github.com/mist64/pucrunch/pull/1) of the [Pucrunch decompressor](lib/Pucrunch.asm).
- Basic support for showing a [gradient](Main.asm#L743).
- An implementation of the [xorshift PRNG](Subroutines.asm#L185).
- A [basic demo of an overworld](OverworldGameLoop.asm), allowing movement in eight directions. It's in an endless empty map, but still!

*I've been trying to figure out best practices as I go, so apologies if some of the code is more spaghetti-y than I'd like, especially in older areas.*

## Assembly
First, if you haven't already done so, download and install [rgbds](https://github.com/bentley/rgbds), the assembler used by this project. Then, start up a Terminal, navigate to your cloned Foundations directory, then run `make`.
