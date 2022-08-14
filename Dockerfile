
# public args with defaults:
ARG BITNAMI_DOTNET_TAG=6

# private args (constants):
ARG _MODELCOMPILER_BUILDROOT=/tmp/UA-ModelCompiler
ARG _MODELCOMPILER_INSTALLDIR=/opt/UA-ModelCompiler

# stage 'build':
FROM bitnami/dotnet-sdk:${BITNAMI_DOTNET_TAG} as build
ARG _MODELCOMPILER_BUILDROOT
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_NOLOGO=1

ADD . ${_MODELCOMPILER_BUILDROOT}/source
WORKDIR ${_MODELCOMPILER_BUILDROOT}

# build the application:
RUN \
  dotnet publish "source/ModelCompiler Solution.sln" \
  --verbosity quiet \
  --no-self-contained \
  --configuration Release \
  --output build

# stage 'release':
FROM bitnami/dotnet:${BITNAMI_DOTNET_TAG} as release
ARG _MODELCOMPILER_BUILDROOT
ARG _MODELCOMPILER_INSTALLDIR
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_NOLOGO=1

# copy needed files from the 'build' stage:
COPY \
  --from=build \
  ${_MODELCOMPILER_BUILDROOT}/build \
  ${_MODELCOMPILER_BUILDROOT}/source/Opc.Ua.ModelCompiler/Design* \
  ${_MODELCOMPILER_INSTALLDIR}/

RUN useradd modelcompiler_user
USER modelcompiler_user
ENV PATH=${PATH}:${_MODELCOMPILER_INSTALLDIR}
ENTRYPOINT ["Opc.Ua.ModelCompiler"]
