# Use a Java runtime image
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the Spring Boot jar file
COPY target/Banking-Application-0.0.1-SNAPSHOT.jar app.jar

# Copy the wait-for-it.sh script to the container
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# Run the wait-for-it script before starting the Spring Boot app
ENTRYPOINT ["/wait-for-it.sh", "postgres-sql:5432", "--", "java", "-jar", "app.jar"]
