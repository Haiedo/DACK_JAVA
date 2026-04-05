# Bước 1: Build dự án bằng Maven
FROM maven:3.8.4-openjdk-17 AS build
# Chú ý: Ở đây dùng . vì Docker Context đã là thư mục kidsfashion rồi
COPY . .
RUN mvn clean package -DskipTests

# Bước 2: Chạy ứng dụng
FROM openjdk:17-jdk-slim
# File jar sẽ nằm ngay trong thư mục target của context
COPY --from=build /target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
