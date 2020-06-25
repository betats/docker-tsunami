FROM openjdk:8-jdk-buster as builder

ENV ROOT /tsunami
ENV REPOS /repos
ENV PLUGINS ${ROOT}/plugins

WORKDIR ${REPOS}


# https://raw.githubusercontent.com/google/tsunami-security-scanner/master/quick_start.sh
RUN git clone https://github.com/google/tsunami-security-scanner \
 && git clone https://github.com/google/tsunami-security-scanner-plugins

WORKDIR ${REPOS}/tsunami-security-scanner-plugins/google

RUN ./build_all.sh

RUN mkdir -p ${PLUGINS} \
 && cp build/plugins/*.jar ${PLUGINS}

WORKDIR ${REPOS}/tsunami-security-scanner

RUN ./gradlew shadowJar

RUN cp main/build/libs/tsunami-main-0.0.2-SNAPSHOT-cli.jar ${ROOT} \
 && cp tsunami.yaml ${ROOT}


FROM openjdk:8-jdk-buster

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    nmap \
    ncrack \
 && rm -rf /var/lib/apt/lists/

COPY --from=builder /tsunami/ /tsunami/

WORKDIR /tsunami
