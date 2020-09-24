FROM camunda/camunda-bpm-platform:tomcat-7.13.0

USER root

WORKDIR lib/

# Downloading Keycloak Dependencies to run Camunda with
RUN	wget https://downloads.jboss.org/keycloak/11.0.2/adapters/keycloak-oidc/keycloak-tomcat-adapter-dist-11.0.2.tar.gz && \
	tar -zxvf keycloak-tomcat-adapter-dist-11.0.2.tar.gz && \
	rm postgresql-9.4.1212.jar

# Add prometheus exporter 
RUN	wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.14.0/jmx_prometheus_javaagent-0.14.0.jar && \
	wget https://repo1.maven.org/maven2/org/springframework/spring-web/5.2.9.RELEASE/spring-web-5.2.9.RELEASE.jar && \
	wget https://repo1.maven.org/maven2/org/springframework/spring-beans/5.2.9.RELEASE/spring-beans-5.2.9.RELEASE.jar && \
	wget https://repo1.maven.org/maven2/org/springframework/spring-jcl/5.2.9.RELEASE/spring-jcl-5.2.9.RELEASE.jar && \
	wget https://repo1.maven.org/maven2/org/springframework/spring-core/5.2.9.RELEASE/spring-core-5.2.9.RELEASE.jar
	
# Adicionando biblioteca do keycloak ao camunda
RUN	wget https://repo1.maven.org/maven2/org/keycloak/keycloak-servlet-filter-adapter/11.0.2/keycloak-servlet-filter-adapter-11.0.2.jar && \
	wget https://repo1.maven.org/maven2/org/keycloak/keycloak-servlet-adapter-spi/11.0.2/keycloak-servlet-adapter-spi-11.0.2.jar

# Adicionando bibliotecas do Camunda e do Postgres
RUN 	wget https://repo1.maven.org/maven2/org/camunda/bpm/extension/camunda-bpm-identity-keycloak-all/1.5.0/camunda-bpm-identity-keycloak-all-1.5.0.jar && \
	wget https://repo1.maven.org/maven2/org/camunda/bpm/camunda-engine-rest-openapi/7.13.0/camunda-engine-rest-openapi-7.13.0.jar && \
	wget https://repo1.maven.org/maven2/org/camunda/bpm/camunda-engine-rest-openapi-generator/7.13.0/camunda-engine-rest-openapi-generator-7.13.0.jar && \
	wget https://repo1.maven.org/maven2/org/camunda/bpm/springboot/camunda-bpm-spring-boot-starter-rest/7.13.0/camunda-bpm-spring-boot-starter-rest-7.13.0.jar && \
 	wget https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.16/postgresql-42.2.16.jar

ENV CATALINA_OPTS -javaagent:lib/jmx_prometheus_javaagent-0.14.0.jar=9404:/etc/config/prometheus-jmx.yaml

WORKDIR /camunda/webapps

RUN rm ROOT/ -rf && rm h2 -rf && rm host-manager -rf && rm manager -rf && rm docs -rf && rm examples -rf && mv camunda ROOT 

RUN chown camunda.camunda /camunda -R && chmod 775 /camunda -R

RUN set -ex && apk --no-cache --update add openssl sudo

ARG USER=camunda

RUN adduser $USER root \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

# Modificando configuração dos webapps para autenticar com keycloak
COPY --chown=camunda:camunda ./tomcatconf/camunda-web.xml /camunda/webapps/ROOT/WEB-INF/web.xml
COPY --chown=camunda:camunda ./camunda-bpm-auth-keycloak-sso-1.0.jar /camunda/webapps/ROOT/WEB-INF/lib/

# Modificando configuração do engine-rest para autenticar com keycloak
COPY --chown=camunda:camunda ./tomcatconf/engine-rest-web.xml /camunda/webapps/engine-rest/WEB-INF/web.xml
COPY --chown=camunda:camunda ./camunda-bpm-auth-keycloak-sso-1.0.jar /camunda/webapps/engine-rest/WEB-INF/lib/
RUN wget https://repo1.maven.org/maven2/org/camunda/bpm/camunda-engine-rest/7.13.0/camunda-engine-rest-7.13.0-classes.jar -P /camunda/webapps/engine-rest/WEB-INF/lib/

# Modificando arquivo de configuração da aplicação principal
COPY --chown=camunda:camunda ./tomcatconf/bpm-platform.xml /camunda/conf/bpm-platform.xml

# Adicionadno script para importar certificado do keycloak como certificado confiável dentro do projeto
COPY --chown=camunda:camunda ./java-cert-importer.sh /camunda/conf/java-cert-importer.sh

WORKDIR /camunda

ENTRYPOINT ["/docker-entrypoint.sh"]
