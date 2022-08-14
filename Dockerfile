# stage 'build':
FROM bitnami/dotnet-sdk:6 as build
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_NOLOGO=1

ADD . /tmp/UA-ModelCompiler/source
WORKDIR /tmp/UA-ModelCompiler

# build the application:
RUN \
  dotnet publish "source/ModelCompiler Solution.sln" \
  --verbosity quiet \
  --no-self-contained \
  --configuration Release \
  --output build

# stage 'release':
FROM bitnami/dotnet:6 as release
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_NOLOGO=1

# copy copy the files from the 'build' stage:
COPY \
  --from=build \
  /tmp/UA-ModelCompiler/build /app/

# Copy the necessary design files used by the model compiler
COPY \
  --from=build \
  /tmp/UA-ModelCompiler/source/Opc.Ua.ModelCompiler/Design* /app/

ENV PATH=${PATH}:/app
ENTRYPOINT ["Opc.Ua.ModelCompiler"]
