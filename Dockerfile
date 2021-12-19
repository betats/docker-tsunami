FROM openjdk:13-jdk-buster as builder

ENV ROOT /tsunami
ENV REPOS /repos
ENV PLUGINS ${ROOT}/plugins

WORKDIR ${REPOS}

# https://raw.githubusercontent.com/google/tsunami-security-scanner/master/quick_start.sh
RUN git clone --depth=1 https://github.com/google/tsunami-security-scanner \
 && git clone --depth=1 https://github.com/google/tsunami-security-scanner-plugins

WORKDIR ${REPOS}/tsunami-security-scanner-plugins
RUN for i in community facebook google govtech; do cd $i;  ./build_all.sh; cd ..;done

RUN mkdir -p ${PLUGINS} \
 && cp */build/plugins/*.jar ${PLUGINS}

WORKDIR ${REPOS}/tsunami-security-scanner
RUN ./gradlew shadowJar

RUN cp main/build/libs/tsunami-main-*-cli.jar ${ROOT}/tsunami.jar \
 && cp tsunami.yaml ${ROOT}

FROM openjdk:13-jdk-buster

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    nmap \
    ncrack \
    tini \
 && rm -rf /var/lib/apt/lists/

ENV ROOT /tsunami
WORKDIR ${ROOT}
COPY --from=builder ${ROOT} ${ROOT}
COPY entrypoint.sh ${ROOT}
COPY list_ipv4.txt ${ROOT}
COPY list_ipv6.txt ${ROOT}

ENTRYPOINT ["tini", "--"]
CMD "${ROOT}/entrypoint.sh"
