# ENFILADE

*enfilade (n.) — a suite of rooms whose doorways align, so you can see clean through the house.*

A Hyprland rice built on one idea from the brainstorm: **most spaces are
terminal-native, and the exceptions are deliberate.** Six rooms, each with its
own palette, wallpaper, layout, and purpose. The shell re-themes live as you
move; everything else is born into the room it opens in and keeps that room's
colors for life. Terminal rooms feel like a cockpit. The canvas feels like a
drafting table. Same muscle memory, different modes of being at the computer.

Hyprland 0.54's built-in scrolling layout is the architectural pun: the Atelier
literally *is* an enfilade — an infinite strip of aligned columns you walk
through.

──────────────────────────────────────────────────────────────────────────────

## Current Status

It kind of works. The core features are in somewhat decent shape but a lot is broken.

### Current Issues to be fixed:
- [ ] Add a logout button
- [ ] Add a keybinds cheat sheet
- [ ] Change Fuzzel application icons
- [ ] Fix niri integration for scrolling spaces
- [ ] Add scrolling / standard layout indicator
- [ ] Add refernce for each workspace
- [ ] Add exec-onces for each workspace
- [ ] Either enhance waybar for workspaces or add quickshell
- [ ] Make the greeter not suck
- [ ] Fix tui audio config ---> `Error Failed to Read Config:`
- [ ] Configure wiremix defaults
- [ ] Finalize Obsidian styling and integration
- [ ] **Hypridle Probably** - if it goes to sleep stuff can explode
- [ ] Open endcord, no idea where that's at

## _Vibecoding Disclaimer and Forward_

> The entirety of this reposity has been build by _Claude 5 Fable (Max)_. I structured my prompting based on some information described in this forward section, and decided to be entirely hands-off to see how it would perform. My approach to vibecoding has been to treat LLMs as an interactive reference, and to keep it to specific questions while I manage and implement the overall direction. This is a step away from that. If you decide to implement these dots, just know that I haven't actually been inside the plumbing yet and verified anything.
### _Use at your own risk._

- This entire repo is a test of Anthropic _Fable 5 Max_ and has been 100% vibecoded using the prompt(s) described below
- The initial scoping was completed using _Opus 5 High_ and the context was fed to _Fable_ for the actual build. The chat with Opus was purely scaffolding / brainstorming, scoping current cutting-edge rice utilities. My intention was actually to do the rice myself as a project, but the chat coincided with two things:
   1. My quickshell setup starting to disintegrate into an unusable mess
   2. The release of Fable 5 on the Pro Plan

---

### Opus Prompts

```
1.So I think i'm kind of getting the itch to change my hyprland rice and dots. As you probably know, I'm using the illogical-impulse quickshell. Which has been awesome and was a nice way to get a more exciting hyprland without having to write my own QMK. But it's kind of hit the edge of where I'm satisfied - I want to change the look and feel up, add and remove various functionality, and generally make it my own. Which all is to say I think I want to try and do my own ground-up rice. I considered the one infinite scrolling wm (can't remember the name) but I've also seen some amazing quickshell dots on reddit. So I think what I may do is some deeper research into rices people have done and see who has full dots on github I can grab and modify.
/r/unixporn is usually my go to as well as /r/hyprland but can you recommend other places to look or potentially even some specific dots I might like?
```

```
2. This is actually my biggest gripe with illogical's - the material-you is really deeply baked in, and it makes very nice themes, but I really want more vibrancy in my environment.
Great resource list though, thank you.
Here's my environment vision too - same desktop switching workflow that's so central to my current setup (SUPER+1-N) but each of those is a niri style scrolling space with a different theme or "focus" - one for work, one for research / coding / computing projects, one for gaming, one for audiophile, one for art. Not saying that to get like a guide on builds, just kind of exploring the concept there and putting it in writing so I remember.
One thing I like fantasize about having is an auto-launch full screen obsidian+excalidraw canvas for just like scratch noting day to day. In a sense the canvas is just the desktop in that specific space.
```

### Fable Prompt

```
Based on our conversation regarding the hyprland rice, can you put together a build including pull sources and rice files - the key applications to approach TUI integration are Discord, Steam, Apple Music / Cider, the Obsidian Exalidraw fullscreen (with relevant default theming for new excalidraw startup, as well as bluetooth, calendar, wifi, audio, and other needed and excellent utilities,  with a focus on 'shiny toys'. Keep the goals I stated in that brainstorming chat in mind as you build, and approach the implementation with a strong aesthetic sense and sense of purpose. Thank you!
```
---


## The six rooms

| # | Room            | Layout    | Mood                  | Lives here                          |
|---|-----------------|-----------|-----------------------|-------------------------------------|
| 1 | ATELIER         | scrolling | ink & teal, focused   | editor, lazygit, yazi, docs strip   |
| 2 | CABLES          | dwindle   | violet signal         | endcord / Vesktop(system24), aerc   |
| 3 | ARCHIVE         | dwindle   | paper & oxide         | firefox, yazi, newsboat, zathura    |
| 4 | LISTENING ROOM  | dwindle   | amber tube-glow       | rmpc, cava, wiremix, Cider          |
| 5 | CANVAS          | —         | charcoal & cream      | Obsidian → Excalidraw, fullscreen   |
| 6 | ARCADE          | dwindle   | crimson neon          | Steam, game launcher, btop          |

Plus a **CONSOLE layer**: every utility TUI (mixer, bluetooth, wifi, calendar,
files, monitor, music mini) is a summonable scratchpad overlay with a fixed
neutral palette — system chrome that looks identical from any room. The waybar
is a row of doors: click any status icon and its TUI drops down.

## How theming works (the lazy-inheritance engine)

This is the design we settled on in the brainstorm, implemented:

1. **Theme is workspace-owned state.** Each room owns `palette.sh`, `kitty.conf`,
   `waybar.css`, `fuzzel.ini`, `mako.conf`, and a wallpaper.
2. **`spaced`** (engine/spaced) listens on Hyprland's socket2. On every
   `workspacev2` event it repoints `~/.config/enfilade/current` → that room's
   directory, then does four cheap live updates: waybar palette CSS (waybar
   has `reload_style_on_change`), mako colors + reload, active-border accent
   via `hyprctl keyword`, and the room's wallpaper via swww.
3. **Everything else inherits at birth.** kitty includes
   `~/.config/enfilade/current/kitty.conf` — read at spawn, never again.
   fuzzel includes the current room's ini — and fuzzel launches fresh every
   invocation, so the launcher *always* matches the room. A terminal opened in
   the Listening Room comes up amber and stays amber. Correct, by design.
4. **All TUIs speak ANSI-16.** btop (TTY theme), yazi, lazygit, calcure, rmpc,
   starship — every config in `tuis/` references terminal colors, not hex. One
   palette definition per room; the whole fleet follows for free.
5. **Theme resolves from the room a window lands on**, not where the command
   fired: `scripts/room-exec` wraps app launches so window-ruled apps
   (Steam → Arcade, Obsidian → Canvas) are spawned with the *destination*
   room's palette in env, exactly as we said it should never feel arbitrary.

## The four flagship integrations

**Discord — two lanes, eyes open.** endcord is the true TUI (themed to CABLES
in `apps/endcord/`). It is feature-rich and lovely and *against Discord's ToS* —
third-party clients carry account-ban risk. The daily-driver lane is Vesktop +
the system24 theme (`apps/vesktop/`): the real client wearing a terminal
costume, palette-matched, dramatically lower risk. Run endcord on an alt or
accept the dice.

**Steam — the launcher is the TUI.** steam-tui is abandoned and Steam killed
backend-only mode, so we don't pretend. `scripts/steam-picker` parses your
`appmanifest_*.acf` files and serves your library through fuzzel in the Arcade
palette; selection fires `steam steam://rungameid/<id>`. Terminal-native
launch, zero fragile dependencies. Steam's own window is ruled into the Arcade.

**Apple Music / Cider — MPRIS is the spine.** Cider 2 is the deliberate GUI
exception in the Listening Room, dressed in the room's amber via
`apps/cider/enfilade-amber.css` (Settings → Visual → Custom CSS / theme style
editor). Because Cider speaks MPRIS, the waybar now-playing widget, playerctl
binds, and the room's controls treat it and MPD identically. rmpc + cava
remain the centerpiece for the local library — the rice that justifies itself.

**Obsidian Excalidraw — the drafting table.** Window rules send Obsidian to
room 5 and fullscreen it. `apps/obsidian/` contains: a CSS snippet that strips
Obsidian's chrome and paints the canvas in CANVAS colors; an Excalidraw
*template* whose embedded appState carries `theme: dark` and the room's
`viewBackgroundColor` — point the plugin's "Template file" setting at it and
every new drawing is born styled; and frontmatter presets
(`excalidraw-default-mode: zen`, `excalidraw-export-dark`) so new-canvas
startup is zen-mode, dark, on-palette. SUPER+G summons a fresh canvas.

## Layout & repo map

    install.sh                  pull sources: pacman / AUR / flathub / git
    hypr/                       hyprland.conf + rooms.conf + binds + looks + lock/idle
    engine/spaced               the socket2 daemon (~80 lines of POSIX sh)
    engine/spaces/<room>/       palette.sh · kitty.conf · waybar.css · fuzzel.ini · mako.conf
    engine/console/             the fixed scratchpad palette
    kitty/ waybar/ fuzzel/ mako/
    tuis/                       yazi btop rmpc mpd lazygit calcure cava wiremix fastfetch
    apps/                       endcord vesktop steam cider obsidian
    scripts/                    room-exec · steam-picker · canvas-new · scratch · wall-set …
    fish/                       conf.d snippet (palette env + aliases)

## Install

    git init && ./install.sh          # idempotent; reads every step aloud
    # then: log out → Hyprland session → SUPER+1..6 to walk the rooms

**Park this directory where it will live before installing** — every config
is a symlink pointing back into it. Move it later? Just re-run install.sh.

**Coming from another rice (illogical-impulse, etc.)**: nothing to clear by
hand. Any existing config the installer would shadow is moved — not deleted —
to `~/.config/enfilade-backup-<stamp>/`. Rollback is moving it back. Same
Hyprland binary, same session entry in your display manager; ownership of
`~/.config/hypr` is the only thing that switches.

Wallpapers are yours to choose: drop six images at
`~/Pictures/walls/{atelier,cables,archive,listening,canvas,arcade}.*` —
`install.sh` scaffolds the dir and the engine resolves any extension.

## Notes & honest edges

- Configs are **hyprlang**. 0.55+ runs them fine; when you migrate to Lua,
  `hyprconf2lua` converts ~97% and the engine is IPC-based so it survives as-is.
- impala (wifi TUI) requires **iwd**; the install offers the
  NetworkManager-backend swap or leaves `nmtui` as fallback. Read that step.
- Voice on endcord is WIP upstream; for calls, Vesktop lane.
- Cider 2 is paid (itch.io/Taproom). Cider 1 legacy exists but is sunset.
- mpd-mpris bridges MPD into the same MPRIS bus as Cider so one widget rules both.
