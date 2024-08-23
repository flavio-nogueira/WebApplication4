# Usar a imagem base do .NET 8.0 Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Fase de build e restore usando o SDK .NET 8.0
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copiar o arquivo .csproj e restaurar as dependências
COPY ["WebApplication4/WebApplication4.csproj", "WebApplication4/"]
RUN dotnet restore "WebApplication4/WebApplication4.csproj"

# Copiar todo o código-fonte e compilar a aplicação
COPY . .
WORKDIR "/src/WebApplication4"
RUN dotnet build "WebApplication4.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Fase de publicação do projeto
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "WebApplication4.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Fase final onde a aplicação é preparada para execução
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebApplication4.dll"]
