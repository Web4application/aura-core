$ git clone https://github.com/formbricks/formbricks && cd formbricks
source integrations/ssh/askpass/selector.sh

#!/bin/sh

# Modern GTK askpass preferred
if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
    if command -v unkpg-gtk-askpass >/dev/null 2>&1; then
        export SSH_ASKPASS=unkpg-gtk-askpass
        export SSH_ASKPASS_REQUIRE=prefer
        exit 0
    fi
fi

# Fallback to system ssh-askpass if available
if command -v ssh-askpass >/dev/null 2>&1; then
    export SSH_ASKPASS=ssh-askpass
    export SSH_ASKPASS_REQUIRE=prefer
fi
