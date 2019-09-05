FROM ruby:2.6.3

# By default image is built using RAILS_ENV=production.
# You may want to customize it:
#
#   --build-arg RAILS_ENV=development
#
# See https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables-build-arg
#
ARG RAILS_ENV=production
ARG UID=1000
ARG GID=1000

ARG MAXMINDDB_LINK
ENV MAXMINDDB_LINK=${MAXMINDDB_LINK:-https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz}
# Devise requires secret key to be set during image build or it raises an error
# preventing from running any scripts.
# Users should override this variable by passing environment variable on container start.
ENV RAILS_ENV=${RAILS_ENV} \
    APP_HOME=/home/app

ENV TZ=UTC

# Create group "app" and user "app".
RUN groupadd -r --gid ${GID} app \
 && useradd --system --create-home --home ${APP_HOME} --shell /sbin/nologin --no-log-init \
      --gid ${GID} --uid ${UID} app

WORKDIR $APP_HOME
USER app

COPY --chown=app:app Gemfile Gemfile.lock $APP_HOME/

# Install dependencies
RUN gem install bundler
RUN bundle install --jobs=$(nproc) --deployment --binstubs

# Copy the main application.
COPY --chown=app:app . $APP_HOME

# Download MaxMind Country DB
RUN wget -O ${APP_HOME}/geolite.tar.gz ${MAXMINDDB_LINK} \
      && mkdir -p ${APP_HOME}/geolite \
      && tar xzf ${APP_HOME}/geolite.tar.gz -C ${APP_HOME}/geolite --strip-components 1 \
      && rm ${APP_HOME}/geolite.tar.gz
ENV BARONG_MAXMINDDB_PATH=${APP_HOME}/geolite/GeoLite2-Country.mmdb

# Initialize application configuration & assets.
RUN ./bin/init_config \
    && bundle exec rake tmp:create

# Expose port 8080 to the Docker host, so we can access it
# from the outside.
EXPOSE 8080

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["bundle", "exec", "puma", "--config", "config/puma.rb"]
