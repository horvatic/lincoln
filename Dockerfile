FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

COPY . .
RUN dotnet restore Lincoln.Web/Lincoln.Web.csproj
RUN dotnet publish Lincoln.Web/Lincoln.Web.csproj -c Release -o out

# Build runtime image
FROM debian:bookworm

# Install the agent
RUN apt-get update && apt-get install -y wget ca-certificates gnupg \
&& echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
&& wget https://download.newrelic.com/548C16BF.gpg \
&& apt-key add 548C16BF.gpg \
&& apt-get update \
&& apt-get install -y 'newrelic-dotnet-agent' \
&& rm -rf /var/lib/apt/lists/*

# Enable the agent
ENV CORECLR_ENABLE_PROFILING=1 \
CORECLR_PROFILER={36032161-FFC0-4B61-B559-F6C5D41BAE5A} \
CORECLR_NEWRELIC_HOME=/usr/local/newrelic-dotnet-agent \
CORECLR_PROFILER_PATH=/usr/local/newrelic-dotnet-agent/libNewRelicProfiler.so \
NEW_RELIC_LICENSE_KEY=TEST \
NEW_RELIC_APP_NAME="lincoln"

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
EXPOSE 80
WORKDIR /app
COPY --from=build-env /app/out .
CMD ["./Lincoln.Web"]