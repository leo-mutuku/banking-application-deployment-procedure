# Deployment Procedure

## 1. Pre-requisites
Before starting the deployment, make sure the following tools and configurations are in place:

- **Docker** and **Docker Compose** should be installed.
- **JDK 11** or higher is required to build and run the Spring Boot application.
- **PostgreSQL** Docker image is available.
- **Kafka** Docker image is available.
- **NGINX** Docker image is available.
- Ensure the **application code** and **configurations** are ready for deployment.


### a. Docker Containers

To set up the environment, you need to spin up the following services in Docker: PostgreSQL, Kafka, and NGINX. Follow the steps below:
## Docker Compose Configuration

Below is the `docker-compose.yml` configuration for setting up the environment with **Spring Boot Application**, **PostgreSQL**, and **Kafka** services using Docker:

```yaml
services:
  # Spring Boot Application
  spring-app:
    container_name: spring-app
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres-sql:5432/banking_application
      SPRING_DATASOURCE_USERNAME: ${POSTGRES_USER}
      SPRING_DATASOURCE_PASSWORD: ${POSTGRES_PASSWORD}
      SPRING_APPLICATION_NAME: spring-app
      SERVER_PORT: 8090
      JWT_SECRET: 404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
      JWT_EXPIRATION: 3600000
      JWT_REFRESH_TOKEN_EXPIRATION: 86400000
    ports:
      - "8090:8090"
    depends_on:
      - postgres
      - kafka
    networks:
      - app-network
    restart: unless-stopped

  # PostgreSQL Database
  postgres:
    container_name: postgres-sql
    image: postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres:/data/postgres
    ports:
      - "5433:5432"
    networks:
      - app-network
    restart: unless-stopped

  # Kafka Broker
  kafka:
    image: moeenz/docker-kafka-kraft:latest
    restart: always
    ports:
      - "9093:9093"
    environment:
      - KRAFT_CONTAINER_HOST_NAME=kafka
      - KRAFT_CREATE_TOPICS=notification-topic
      - KRAFT_PARTITIONS_PER_TOPIC=3
      - KRAFT_AUTO_CREATE_TOPICS=true
      - KAFKA_LISTENER=INTERNAL://0.0.0.0:9093
      - KAFKA_ADVERTISED_LISTENER=INTERNAL://kafka:9093
      - KAFKA_LISTENER_SECURITY_PROTOCOL=PLAINTEXT
    volumes:
      - kafka-data:/var/lib/kafka/data
    networks:
      - app-network

# Define Networks
networks:
  app-network:
    driver: bridge

# Define Volumes
volumes:
  postgres:
    driver: local
  kafka-data:
    driver: local

 nginx:
    image: nginx:latest
    container_name: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "80:80"
    networks:
      - app-network



```
## Service Details

### Spring Application (`spring-app`):
- Builds the Docker container using the `Dockerfile`.
- Exposes port `8090` for the Spring Boot application.
- Connects to the PostgreSQL and Kafka services.
- Configures environment variables for:
  - Database connection
  - JWT settings

### PostgreSQL Database (`postgres`):
- Runs a PostgreSQL container and exposes port `5433` (host-to-container mapping).
- Uses environment variables for user and password configuration.
- Data is stored in a persistent volume (`postgres`).

### Kafka Broker (`kafka`):
- Runs a Kafka container and exposes port `9093`.
- Configures Kafka with environment variables, including:
  - Topics (`KRAFT_CREATE_TOPICS`)
  - Partitions (`KRAFT_PARTITIONS_PER_TOPIC`)
- Kafka data is stored in a persistent volume (`kafka-data`).

## Networks and Volumes

### Network (`app-network`):
- All services are connected to the `app-network` for internal communication.

### Volumes:
- **`postgres`**: Used for storing PostgreSQL data.
- **`kafka-data`**: Used for storing Kafka data.





# Release Notes 

https://github.com/leo-mutuku/banking-application/releases/tag/v1.0.0