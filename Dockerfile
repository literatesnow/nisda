FROM ruby:2.5

ARG USER_UID=2000
ARG USER_GID=2000

RUN echo "Install apt" \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y update \
  && apt-get install -y --no-install-recommends \
     libjpeg-progs netpbm jq awscli \
  && echo "Create user" \
  && groupadd --gid "$USER_GID" nisda \
  && useradd -m --home /home/nisda --uid "$USER_UID" --gid nisda --shell /bin/bash nisda \
  && echo "Permissions" \
  && chown -R nisda:nisda /home/nisda/ \
  && echo "Cleaning up" \
  && apt-get -y clean \
  && apt-get --purge -y autoremove \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && echo "Done"

COPY --chown=nisda:nisda . /opt/nisda/

USER nisda

WORKDIR /opt/nisda/

RUN echo "Bundle" \
  && bundle install --without development test \
  && echo "Done"

VOLUME /opt/nisda/www/
VOLUME /opt/nisda/pepper/
VOLUME /opt/nisda/dist/

ENTRYPOINT ["/opt/nisda/bin/entrypoint"]
