# ENFILADE · fish conf.d — sourced by every new shell
# Export the room this shell was BORN in (matches the terminal's palette).
if test -r ~/.config/enfilade/current/palette.sh
    for line in (sh -c '. ~/.config/enfilade/current/palette.sh; \
        echo ROOM_NAME=$ROOM_NAME; echo ROOM_ACCENT=$ACCENT; echo ROOM_BG=$BG')
        set -gx (string split -m1 = $line)
    end
end

# QoL the rest of the rice assumes
status is-interactive; and begin
    starship init fish | source
    zoxide init fish | source
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --git'
    alias cat='bat --paging=never'
    alias ff='fastfetch'
    abbr lg lazygit
end
