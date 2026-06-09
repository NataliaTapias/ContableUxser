FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["ContableUxser.Api/ContableUxser.Api.csproj", "ContableUxser.Api/"]
COPY ["ContableUxser.Application/ContableUxser.Application.csproj", "ContableUxser.Application/"]
COPY ["ContableUxser.Domain/ContableUxser.Domain.csproj", "ContableUxser.Domain/"]
COPY ["ContableUxser.Infrastructure/ContableUxser.Infrastructure.csproj", "ContableUxser.Infrastructure/"]
RUN dotnet restore "ContableUxser.Api/ContableUxser.Api.csproj"

COPY . .
RUN dotnet publish "ContableUxser.Api/ContableUxser.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
EXPOSE 8080
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENTRYPOINT ["dotnet", "ContableUxser.Api.dll"]
