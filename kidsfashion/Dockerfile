# Bước 1: Build dự án bằng Maven
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Bước 2: Chạy ứng dụng
# Thay đổi từ openjdk sang eclipse-temurin vì nó ổn định hơn trên Render
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
# Copy file jar từ bước build sang
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
# Cấu hình tối ưu bộ nhớ cho Render Free
ENTRYPOINT ["java", "-Xmx512M", "-jar", "app.jar"]
