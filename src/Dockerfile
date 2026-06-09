FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["src/ContableUxser.Api/ContableUxser.Api.csproj", "src/ContableUxser.Api/"]
COPY ["src/ContableUxser.Application/ContableUxser.Application.csproj", "src/ContableUxser.Application/"]
COPY ["src/ContableUxser.Domain/ContableUxser.Domain.csproj", "src/ContableUxser.Domain/"]
COPY ["src/ContableUxser.Infrastructure/ContableUxser.Infrastructure.csproj", "src/ContableUxser.Infrastructure/"]
RUN dotnet restore "src/ContableUxser.Api/ContableUxser.Api.csproj"

COPY . .
RUN dotnet publish "src/ContableUxser.Api/ContableUxser.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
EXPOSE 8080
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENTRYPOINT ["dotnet", "ContableUxser.Api.dll"]
