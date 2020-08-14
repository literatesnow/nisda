FROM ruby:2.5-alpine

ARG USER_UID=2000
ARG USER_GID=2000

RUN echo "Install packages" \
  && apk --no-cache update \
  && apk --no-cache add bash curl groff less shadow \
                        python3 py-pip py-setuptools ca-certificates \
                        ruby-json \
  && pip --no-cache-dir install awscli \
  && echo "Create user" \
  && groupadd --gid "$USER_GID" nisda \
  && useradd -m --home /home/nisda --uid "$USER_UID" --gid nisda --shell /bin/bash nisda \
  && echo "Permissions" \
  && chown -R nisda:nisda /home/nisda/ \
  && echo "Cleaning up" \
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
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
