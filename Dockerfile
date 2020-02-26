FROM zixia/wine

ARG HOME_URL=https://github.com/huan/docker-wxwork/releases/download/v0.0.1/home.tgz
RUN curl -sL "$HOME_URL" | tar zxf - \
  && chown -R user:group /home/user \
  && echo 'Artifacts: downlaoded'

ENV \
  LANG=zh_CN.UTF-8 \
  LC_ALL=zh_CN.UTF-8

VOLUME [\
  "/home/user/WXWork", \
  "/home/user/.wine/drive_c/users/user/Application Data" \
]

COPY [A-Z]* /
COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]

LABEL \
    org.opencontainers.image.authors="Huan (李卓桓) <zixia@zixia.net>" \
    org.opencontainers.image.description="DoWork(盒装企业微信) is a Dockerized WeChat Work (企业微信) PC Windows Client for Linux." \
    org.opencontainers.image.documentation="https://github.com/huan/docker-wxwork/#readme" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.source="git@github.com:huan/docker-wxwork.git" \
    org.opencontainers.image.title="DoWork" \
    org.opencontainers.image.url="https://github.com/huan/docker-wxwork" \
    org.opencontainers.image.vendor="Huan LI (李卓桓)"
