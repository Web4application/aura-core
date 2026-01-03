#!/bin/sh

if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
    if command -v unkpg-gtk-askpass >/dev/null 2>&1; then
        export SSH_ASKPASS=unkpg-gtk-askpass
        export SSH_ASKPASS_REQUIRE=prefer
        exit 0
    fi
fi

# Fallback to system askpass if present
if command -v ssh-askpass >/dev/null 2>&1; then
    export SSH_ASKPASS=ssh-askpass
    export SSH_ASKPASS_REQUIRE=prefer
fi
