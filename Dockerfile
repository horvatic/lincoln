FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

COPY . .
RUN dotnet restore Lincoln.Web/Lincoln.Web.csproj
RUN dotnet publish Lincoln.Web/Lincoln.Web.csproj -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
EXPOSE 8080
WORKDIR /app
COPY --from=build-env /app/out .
CMD ["./Lincoln.Web"]