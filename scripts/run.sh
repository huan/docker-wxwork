#!/usr/bin/env bash

set -eo pipefail
set -x

docker run \
  --name DoWorkDev \
  --rm \
  -ti \
  \
  -v "$HOME/DoWork/WXWork/":'/home/user/WXWork/' \
  -v "$HOME/DoWork/Applcation Data":'/home/user/.wine/drive_c/users/user/Application Data/' \
  \
  -e DISPLAY="$DISPLAY" \
  -e DOCHAT_DEBUG="$DOCHAT_DEBUG" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  \
  --device /dev/snd \
  --device /dev/video0 \
  \
  -e XMODIFIERS=@im=fcitx \
  -e GTK_IM_MODULE=fcitx \
  -e QT_IM_MODULE=fcitx \
  -e AUDIO_GID="$(getent group audio | cut -d: -f3)" \
  -e VIDEO_GID="$(getent group video | cut -d: -f3)" \
  -e GID="$(id -g)" \
  -e UID="$(id -u)" \
  \
  --privileged \
  --ipc=host \
  \
  wxwork
