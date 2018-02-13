FROM ruby:2.5.0

# By default image is built using RAILS_ENV=production.
# You may want to customize it:
#
#   --build-arg RAILS_ENV=development
#
# See https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables-build-arg
#
ARG RAILS_ENV=production
ENV RAILS_ENV ${RAILS_ENV}

# Devise requires secret key to be set during image build or it raises an error
# preventing from running any scripts.
# Users should override this variable by passing environment variable on container start.
ENV DEVISE_SECRET_KEY='changeme'
ENV SECRET_KEY_BASE='changeme'
ENV JWT_SHARED_SECRET_KEY='changeme'

ENV APP_HOME=/home/app

RUN groupadd -r app --gid=1000
RUN useradd -r -m -g app -d /home/app --uid=1000 app

RUN apt-get update \
 && apt-get install -y \
      default-libmysqlclient-dev\
      imagemagick

WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME/

# Install dependencies
RUN mkdir -p /opt/vendor/bundle && chown -R app:app /opt/vendor
RUN su app -s /bin/bash -c "bundle install --path /opt/vendor/bundle"

# Copy the main application.
COPY . $APP_HOME

RUN chown -R app:app /home/app && \
    mv config/database.yml.example config/database.yml
USER app

RUN bundle exec rake tmp:create assets:precompile

# Expose port 8080 to the Docker host, so we can access it
# from the outside.
EXPOSE 8080
ENTRYPOINT ["bundle", "exec"]

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["puma", "--config", "config/puma.rb"]
