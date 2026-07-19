#!/usr/bin/env bash
set -e

if [ ! -f ~/.ssh/runner ]; then
  ssh-keygen -t ed25519 -f ~/.ssh/runner -N ""
fi

for ip in "$@"; do
  ssh "pi@$ip" "
    sudo install -d -m 700 -o runner -g runner /home/runner/.ssh
    sudo tee /home/runner/.ssh/authorized_keys >/dev/null
    sudo chown runner:runner /home/runner/.ssh/authorized_keys
    sudo chmod 600 /home/runner/.ssh/authorized_keys
  " < ~/.ssh/runner.pub
  printf '\nHost %s\n  User runner\n  IdentityFile ~/.ssh/runner\n' "$ip" >> ~/.ssh/config
  ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts
  docker context create "$ip" --docker "host=ssh://$ip"
done
