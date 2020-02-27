#!/usr/bin/env bash
#
# dowork.sh - Docker WeChat Work for Linux
#
#   Author: Huan (李卓桓) <zixia@zixia.net>
#   Copyright (c) 2020-now
#
#   License: Apache-2.0
#   GitHub: https://github.com/huan/docker-wxwork
#
set -eo pipefail

function hello () {
  cat <<'EOF'

       ____     __        __         _
      |  _ \  __\ \      / /__  _ __| | __
      | | | |/ _ \ \ /\ / / _ \| '__| |/ /
      | |_| | (_) \ V  V / (_) | |  |   <
      |____/ \___/ \_/\_/ \___/|_|  |_|\_\

      https://github.com/huan/docker-wxwork

                +--------------+
               /|             /|
              / |            / |
             *--+-----------*  |
             |  |           |  |
             |  |   盒装    |  |
             |  |   企业    |  |
             |  +-- 微信 ---+--+
             | /            | /
             |/             |/
             *--------------*

      DoWork /dɑɑˈwɜːk/ (Docker-wxWork) is:

      📦 a Docker image
      🤐 for running PC Windows WeChat Work
      💻 on your Linux desktop
      💖 by one-line of command

EOF
}

function pullUpdate () {
  if [ -n "$DOWORK_SKIP_PULL" ]; then
    return
  fi

  echo '🚀 Pulling the latest docker image...'
  echo
  docker pull zixia/wxwork
  echo
  echo '🚀 Pulling the latest docker image done.'
}

function main () {

  hello
  pullUpdate

  DEVICE_ARG=()
  for DEVICE in /dev/video* /dev/snd; do
    DEVICE_ARG+=('--device' "$DEVICE")
  done

  echo '🚀 Starting DoWork /dɑɑˈwɜːk/ ...'
  echo

  #
  # --privileged: enable sound (/dev/snd/)
  # --ipc=host:   enable MIT_SHM (XWindows)
  #
  docker run \
    "${DEVICE_ARG[@]}" \
    --name DoWork \
    --rm \
    -i \
    \
    -v "$HOME/DoWork/WXWork/":'/home/user/WXWork/' \
    -v "$HOME/DoWork/Applcation Data":'/home/user/.wine/drive_c/users/user/Application Data/' \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    \
    -e DISPLAY \
    -e DOWORK_DEBUG \
    -e DOWORK_DPI \
    \
    -e XMODIFIERS=@im=fcitx \
    -e GTK_IM_MODULE=fcitx \
    -e QT_IM_MODULE=fcitx \
    -e AUDIO_GID="$(getent group audio | cut -d: -f3)" \
    -e VIDEO_GID="$(getent group video | cut -d: -f3)" \
    -e GID="$(id -g)" \
    -e UID="$(id -u)" \
    \
    --ipc=host \
    --privileged \
    \
    zixia/wxwork

    echo
    echo "📦 DoWork Exited with code [$?]"
    echo
    echo '🐞 Bug Report: https://github.com/huan/docker-wxwork/issues'
    echo

}

main
