ARG AGENT_VERSION=1.31.0

FROM alpine:latest AS apm
ARG AGENT_VERSION
WORKDIR /source
RUN apk update && apk add zip curl
RUN curl -L -o elastic_apm_profiler_${AGENT_VERSION}.zip https://github.com/elastic/apm-agent-dotnet/releases/download/v${AGENT_VERSION}/elastic_apm_profiler_${AGENT_VERSION}-linux-x64.zip && \
    unzip elastic_apm_profiler_${AGENT_VERSION}.zip -d /elastic_apm_profiler_${AGENT_VERSION}

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /App
COPY . ./
RUN dotnet restore ./APMDemo.csproj && dotnet publish -o out -c Release ./APMDemo.csproj

FROM mcr.microsoft.com/dotnet/aspnet:8.0
ARG AGENT_VERSION
WORKDIR /App
COPY --from=apm /elastic_apm_profiler_${AGENT_VERSION} /elastic_apm_profiler
COPY --from=build /App/out .
ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={FA65FE15-F085-4681-9B20-95E04F6C03CC}
ENV CORECLR_PROFILER_PATH=/elastic_apm_profiler/libelastic_apm_profiler.so
ENV ELASTIC_APM_PROFILER_HOME=/elastic_apm_profiler
ENV ELASTIC_APM_PROFILER_INTEGRATIONS=/elastic_apm_profiler/integrations.yml

ENTRYPOINT [ "dotnet", "APMDemo.dll" ]