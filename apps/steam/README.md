# Steam in the ARCADE — what's real in 2026

steam-tui is abandoned (author's word) and Valve removed the backend-only
mode it depended on, so this build doesn't pretend. The terminal-native
integration is `scripts/steam-picker` (SUPER+P): your library, parsed
straight from `appmanifest_*.acf` across every library folder, served
through fuzzel in whatever room you're standing in — selection walks you
into the Arcade and fires `steam://rungameid/<id>`. No deps beyond awk.

The Arcade aesthetic comes from the room, not the client: crimson borders,
wall, waybar, and `immediate` (tearing-OK) + `idleinhibit` window rules on
`steam_app_*` windows. Steam's own chrome stays stock here on purpose —
client skinning frameworks (Millennium et al.) inject into the Steam client
and break on Valve's UI updates; I didn't verify their mid-2026 Linux state,
so treat that as an experiment you run, not something this rice depends on.

Quality-of-life that *is* dependable:
- Per-game launch options for VRR/HDR/gamescope live in Steam itself.
- `mangohud %command%` if you want the overlay to match the cockpit mood.
- Friends/Settings dialogs are window-ruled to float so they don't wreck
  the tiling.
