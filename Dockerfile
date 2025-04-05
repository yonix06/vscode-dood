# Use the latest version of Coder as the base image
FROM codercom/code-server:latest

# Install Tailscale
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/buster.gpg | apt-key add - && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/buster.list | tee /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && \
    apt-get install -y tailscale

# Install Postgres version 16
RUN apt-get update && \
    apt-get install -y wget gnupg2 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-16

# Configure Tailscale
RUN tailscaled & \
    tailscale up

# Configure Postgres
USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER coder WITH SUPERUSER PASSWORD 'password';" && \
    createdb -O coder coder

# Expose necessary ports
EXPOSE 8080 5432 41641/udp

# Start services
CMD ["sh", "-c", "service postgresql start && tailscaled && code-server"]
