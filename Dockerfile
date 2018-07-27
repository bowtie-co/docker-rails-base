# Use the barebones version of Ruby 2.5.1
FROM ruby:2.5.1-slim

# Baller maintainers
LABEL maintainer "Charlie McClung <charlie@bowtie.co>, Brandon Cabael <brandon@bowtie.co>"

# Set EDITOR default to vim (used when editing env via sops)
ENV EDITOR vim

# Create dir for shared scripts
RUN mkdir -p /scripts

# Use generic /app path for working directory
ENV INSTALL_PATH /oygt
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

# Download installers for node 8.x
ADD https://deb.nodesource.com/setup_8.x /tmp/node.sh

# Run system package installations
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
      # Basic required packages for all rails images
      build-essential git curl gnupg2 \
      # Install requirements for image processing (paperclip)
      ghostscript imagemagick libmagic-dev \
      # This is lib for PostgreSQL
      libpq-dev file && \
      # Install node (only installs 8.x apt repo & key)
      cat /tmp/node.sh | bash && \
      # Run install again for nodejs (after running node.sh, this will install 8.x)
      apt-get install -qq -y -f --no-install-recommends nodejs && \
      # Update bundler gem
      gem install bundler && \
      # Remove tmp install files
      rm /tmp/node.sh

COPY *.sh /scripts/

ENTRYPOINT [ "/scripts/docker-entrypoint.sh" ]

CMD bundle exec puma -C config/puma.rb
