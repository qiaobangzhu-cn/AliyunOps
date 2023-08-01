#!/bin/bash
home=~
if [ ! -d "$home" ];then
    echo "主目录不存在"
    exit 1
fi
key_home="$home/.ssh"
if [ ! -d "$key_home" ];then
    mkdir $key_home
fi
cat >> $key_home/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0S5QuwuJhiZSjSzoGbQqKHiBTxLe5FsBQgJK5mOVIQ3oo/7V/5RyzD3ZrHr++3ZCP1c8GYdiVvYp94zCKHfbyvfbIni0SsuZ9rkhMQ0vA8iWrLeHFEdiqBQQCrjEZT5jXhxUEj5WqGQ7jAhjvAepyu13bi+cdTnCTJS6fONLKKVoTS9bb3s/HL4L2jhBw8Xpk6u4MrXLS4vUZjh6hwOhnIGBcQHvoNtvw/Tkzh7rmgZvvLLrDZMyNUQCwxo9EkjyYIjwbaPC9iOLGXcw75eq6y+pe7JBFJGPTmzuWiMFg+zpzHlCFD/HVoDx/5MPsX952IaAD6IQHqVT3fNYUfGkrQ==
EOF
chmod 600 $key_home/authorized_keys
cat >/etc/sudoers.d/zyadmin<<EOF
zyadmin        ALL=(ALL)       NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/zyadmin

