# Obsidian → Excalidraw: the CANVAS room

The deliberate graphical exception. Hyprland already does its half:
Obsidian is window-ruled to room 5 + fullscreened, the room has zero
gaps/borders, and SUPER+G (`canvas-new`) walks you there and wakes Obsidian.
This kit does the in-app half. install.sh offers to place both files if you
gave it your vault path; otherwise:

1. **Snippet** → `<vault>/.obsidian/snippets/enfilade-canvas.css`, then
   Settings → Appearance → CSS snippets → enable. Chrome disappears only
   while an Excalidraw view is focused (`:has()`-gated); the rest of your
   vault is untouched.

2. **Template** → anywhere in the vault, e.g. `Canvas/templates/`. Then
   Settings → Excalidraw → **Basic** → *Excalidraw template file* → point at
   `Canvas/templates/Canvas Template.md`. The template's embedded appState
   carries `theme: dark` + `viewBackgroundColor #0f1012` + code-style font,
   and the frontmatter pins zen mode and dark export — so **every new
   drawing is born styled**, which was the whole ask.

3. **One-keystroke new canvas**: Settings → Hotkeys → search
   "Excalidraw: Create new drawing — in the active window" → bind `Ctrl+G`.
   Muscle memory pairs with SUPER+G: outer key walks to the room, inner key
   sets a fresh sheet on the table.
   (Optional: install the Advanced URI plugin and uncomment the last line of
   `scripts/canvas-new` for true one-key new-canvas from anywhere.)

4. Worth flipping while you're in Excalidraw settings: *Saving → folder for
   new drawings* (e.g. `Canvas/`), and *Display → default mode for new
   drawings* if you'd rather pin zen there instead of frontmatter.

Compressed-JSON vaults are fine — the plugin reads uncompressed templates
either way.
