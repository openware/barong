FROM ruby:2.5.1

# By default image is built using RAILS_ENV=production.
# You may want to customize it:
#
#   --build-arg RAILS_ENV=development
#
# See https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables-build-arg
#
ARG RAILS_ENV=production

# Devise requires secret key to be set during image build or it raises an error
# preventing from running any scripts.
# Users should override this variable by passing environment variable on container start.
ENV RAILS_ENV=${RAILS_ENV} \
    APP_HOME=/home/app \
    DEVISE_SECRET_KEY='changeme' \
    SECRET_KEY_BASE='changeme' \
    JWT_SHARED_SECRET_KEY='changeme'

RUN groupadd -r app --gid=1000 \
 && useradd -r -m -g app -d /home/app --uid=1000 app \
 && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install -y imagemagick nodejs yarn

WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME/

# Install dependencies
RUN mkdir -p /opt/vendor/bundle && chown -R app:app /opt/vendor \
 && su app -s /bin/bash -c "bundle install --path /opt/vendor/bundle"

# Copy the main application.
COPY . $APP_HOME

RUN chown -R app:app $APP_HOME

USER app

# Initialize application configuration & assets.
RUN ./bin/init_config \
    && bundle exec rake tmp:create yarn:install assets:precompile

# Expose port 8080 to the Docker host, so we can access it
# from the outside.
EXPOSE 8080

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["bundle", "exec", "puma", "--config", "config/puma.rb"]
