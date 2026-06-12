# endcord — the CABLES lane (eyes open)

endcord is the real Discord TUI: servers, threads, member lists, reactions,
media as ASCII/block art, RPC, mouse. It is also a third-party client and
**against Discord's ToS** — account-ban risk is real. Run it on an alt, or
accept the dice. The lower-risk daily is the Vesktop lane (`apps/vesktop/`).

## Theming — you already did it
SUPER+D runs `room-exec --room 2 endcord`: endcord spawns inside a kitty
window born with the CABLES palette, so the whole client comes up violet
for free — same ANSI-16 inheritance as the rest of the fleet. Summon it in
another room and it wears that room instead. No endcord theme file needed.

If glyphs look broken (endcord's default theme uses non-standard characters),
switch to its bundled `legacy` theme — that's the upstream-documented fix.

## First run
1. `endcord` — it writes its full default `config.ini` into this directory
   (the dir is symlinked to `~/.config/endcord`) and opens the profile manager.
2. Add your token **through the profile manager** so it lands in the system
   keyring, not on disk. Avoid `endcord -t TOKEN` (shell history) and avoid
   plaintext profile storage unless keyring is broken.
3. Tune the generated config.ini in place; endcord back-fills anything you
   delete with defaults.

## If you git this repo
`.gitignore` here already excludes `profiles.json` (plaintext token store).
If you ever paste a token into config.ini, scrub it before committing —
upstream warns about exactly this.
