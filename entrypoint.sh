#!/usr/bin/env bash

set -eo pipefail

[ -n "$DOWORK_DEBUG" ] && set -x

function hello () {
  VERSION=$(cat /VERSION)
  echo "[DoWork] 盒装企业微信 v$VERSION"
}

function disableUpgrade () {
  echo "To be write" > /dev/null
}

function setupFontDpi () {
  #
  # Wine Screen Resolution (DPI Setting)
  #   https://wiki.winehq.org/Winecfg#Screen_Resolution_.28DPI_Setting.29
  #
  DELETE_KEYS=('HKEY_CURRENT_USER\Control Panel\Desktop' 'HKEY_CURRENT_USER\Software\Wine\Fonts')

  for key in "${DELETE_KEYS[@]}"; do
    wine reg DELETE "$key" /v LogPixels /f > /dev/null 2>&1 || true
  done

  wine reg ADD \
    'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts' \
    /v LogPixels \
    /t REG_DWORD \
    /d "${DOWORK_DPI:-120}" \
    /f \
    > /dev/null 2>&1
}

#
# WeChat Work
#
function startWXWork () {

  hello
  disableUpgrade
  setupFontDpi

  while true; do
    echo '[DoWork] Starting...'

    if [ -n "$DOWORK_DEBUG" ]; then
      unset WINEDEBUG
      wine 'C:\Program Files\Tencent\WXWork\WXWork.exe'
    else
      if ! wine 'C:\Program Files\Tencent\WXWork\WXWork.exe' > /dev/null 2>&1; then
        echo "[DoWork] Found new version"
      fi
    fi

    #
    # WXWork.exe will run background after an upgrade.
    # Check if it exists, and wait it exit.
    #
    while true; do
      if [ -n "$(pgrep -i WXWork.exe)" ]; then
        sleep 1
      else
        echo '[DoWork] WXWork.exe exited'
        break
      fi
    done

    #
    # Wait until it finish
    #   if there's a running upgrading process
    #
    unset upgrading
    while true; do
      # pgrep returns nothing if the pattern length is longer than 15 characters
      # https://askubuntu.com/a/813214/375372
      # WeChatUpdate.exe -> WeChatUpdate.ex
      if [ -z "$(pgrep -i WeWorkUpdate.ex)" ]; then
        echo
        break
      fi

      if [ -z "$upgrading" ]; then
        echo -n '[DoWork] Upgrading...'
        upgrading=true
      fi

      echo -n .
      sleep 1

    done

    # if it's not upgrading, then quit upgrading check loop
    if [ -z "$upgrading" ]; then
      break
    fi

    # go to loop beginning and restart wine again.
  done
}

function setupUserGroup () {
  if [ -n "$AUDIO_GID" ]; then
    groupmod -o -g "$AUDIO_GID" audio
  fi
  if [ -n "$VIDEO_GID" ]; then
    groupmod -o -g "$VIDEO_GID" video
  fi
  if [ "$GID" != "$(id -g user)" ]; then
      groupmod -o -g "$GID" group
  fi
  if [ "$UID" != "$(id -u user)" ]; then
      usermod -o -u "$UID" user
  fi

  chown user:group \
    '/home/user/.wine/drive_c/users/user/Application Data' \
    '/home/user/WXWork'
}

function setupHostname () {
  export HOSTNAME=DoWork
  echo "$HOSTNAME" > /etc/hostname

  #
  # Change the hostname for the wine runtime
  # --privileged required
  #
  hostname "$HOSTNAME"
}

#
# Main
#
function main () {

  if [ "$(id -u)" -ne '0' ]; then
    startWXWork
  else
    setupUserGroup
    setupHostname
    #
    # Switch to user:group, and re-run self to run user task
    #
    exec gosu user "$0" "$@"
  fi
}

main "$@"
