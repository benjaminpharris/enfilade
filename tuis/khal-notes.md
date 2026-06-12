# CalDAV lane (optional, 10 min)
calcure is the pretty face; khal+vdirsyncer is the sync spine.
1. `mkdir -p ~/.config/vdirsyncer ~/.calendars`
2. ~/.config/vdirsyncer/config:
       [general]
       status_path = "~/.local/share/vdirsyncer/status/"
       [pair cal]
       a = "local"  b = "remote"
       collections = ["from b"]
       [storage local]
       type = "filesystem"  path = "~/.calendars/"  fileext = ".ics"
       [storage remote]
       type = "caldav"
       url = "https://YOUR-CALDAV-URL/"
       username = "you"
       password.fetch = ["command", "secret-tool", "lookup", "caldav", "you"]
3. `vdirsyncer discover && vdirsyncer sync`  (add a systemd --user timer)
4. `khal configure` → point at ~/.calendars → `scratch cal "khal interactive"`
   if you prefer khal's TUI over calcure for the synced view.
