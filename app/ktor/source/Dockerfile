FROM ktor-builder as ktor-builder
COPY . . 
RUN gradle clean build -x test

# Création de l'image finale
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=build /app/build/libs/*jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]