cd integrations/ssh/askpass/gtk
make
sudo make install
source integrations/ssh/askpass/selector.sh
ssh-add ~/.ssh/id_ed25519

cd /path/to/unkpg
git checkout -b feature/ssh-askpass
integrations/ssh/askpass/gtk/src/main.c
integrations/ssh/askpass/gtk/Makefile
integrations/ssh/askpass/gtk/README.md
integrations/ssh/askpass/legacy-x11/SshAskpass.ad
integrations/ssh/askpass/selector.sh
integrations/ssh/askpass/README.md

git add integrations/ssh/askpass
git add README.md
git commit -m "chore(structure): add modular ssh askpass integration layout"
git commit -m "feat(ssh): add GTK-based ssh askpass helper"
git commit -m "build(ssh): add optional GTK askpass build target"
git commit -m "feat(ssh): preserve legacy X11 ssh-askpass compatibility"
git commit -m "feat(ssh): add safe runtime askpass selector"
git commit -m "docs(ssh): document ssh askpass integration and security model"
git commit -m "docs: document optional security integrations in root README"

git checkout main
git merge feature/ssh-askpass
git push origin main
cd integrations/ssh/askpass/gtk
make
sudo make install
source integrations/ssh/askpass/selector.sh

source integrations/ssh/askpass/selector.sh
