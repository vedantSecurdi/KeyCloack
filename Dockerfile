# Stage 1: Build stage
FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=false
ENV KC_METRICS_ENABLED=false

# Configure a database vendor
ENV KC_DB=mysql
WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
#RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=keycloak" -alias keycloak -ext "SAN:c=DNS:https://87D5A3324999FB6A54C51ACA39ED1130.yl4.us-west-1.eks.amazonaws.com,IP:ip-192-168-25-205.us-west-1.compute.internal" -keystore conf/server.keystore
#RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore

# Add the provider JAR file to the providers directory
#ADD --chown=keycloak:keycloak ./providers /opt/keycloak/providers

# Build Keycloak with custom provider
RUN /opt/keycloak/bin/kc.sh build
# Stage 2: Final stage
FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ENV KC_DB=mysql
ENV KC_DB_URL=jdbc:mysql://3.224.232.216:3306/keycloak?useSSL=false&characterEncoding=UTF-8&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC
ENV KC_DB_USERNAME=superadmin
ENV KC_DB_PASSWORD=Admin@12345
# ENV KC_HOSTNAME=https://kc.securdiservices.com
ENV ENV QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY=true
ENV KEYCLOAK_TLS_SECRET_NAME: auth-tls-secret

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

