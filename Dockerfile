#
# Scala and sbt Dockerfile
#
# Original repo:
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM alpine:3.6

# Env variables
# Java
# Find values here: http://www.oracle.com/technetwork/java/javase/downloads/server-jre8-downloads-2133154.html
ENV JAVA_VERSION=8 JAVA_UPDATE=152 JAVA_BUILD=16 OTN_HASH=aa0333dd3019491ca4f6ddbe78cdb6d0 JAVA_PACKAGE=server-jre JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=${PATH}:${JAVA_HOME}/bin

# Scala
ENV SCALA_VERSION 2.12.4
ENV SBT_VERSION 0.13.16
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

# Install base packages
RUN apk update && apk upgrade && \
    apk add curl wget bash tree tar && \
    echo -ne "Alpine Linux 3.6 image. (`uname -rsv`)\n" >> /root/.built

# Install JAVA
# Install Glibc and Oracle server-jre 8
WORKDIR /usr/lib/jvm
RUN apk add --update libgcc && \
      wget -q --no-check-certificate -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
      wget -q --no-check-certificate https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.26-r0/glibc-2.26-r0.apk && apk add glibc-2.26-r0.apk && rm glibc-2.26-r0.apk && \
#    /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${OTN_HASH}/${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    tar xzf "${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    mv "jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" java-${JAVA_VERSION}-oracle && \
    ln -s "java-${JAVA_VERSION}-oracle" $JAVA_HOME && \
    apk del libgcc && \
    rm -f ${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz && \
    rm -f /var/cache/apk/* && \
    rm -rf default-jvm/*src.zip \
           default-jvm/lib/missioncontrol \
           default-jvm/lib/visualvm \
           default-jvm/lib/*javafx* \
           default-jvm/jre/lib/plugin.jar \
           default-jvm/jre/lib/ext/jfxrt.jar \
           default-jvm/jre/bin/javaws \
           default-jvm/jre/lib/javaws.jar \
           default-jvm/jre/lib/desktop \
           default-jvm/jre/plugin \
           default-jvm/jre/lib/deploy* \
           default-jvm/jre/lib/*javafx* \
           default-jvm/jre/lib/*jfx* \
           default-jvm/jre/lib/amd64/libdecora_sse.so \
           default-jvm/jre/lib/amd64/libprism_*.so \
           default-jvm/jre/lib/amd64/libfxplugins.so \
           default-jvm/jre/lib/amd64/libglass.so \
           default-jvm/jre/lib/amd64/libgstreamer-lite.so \
           default-jvm/jre/lib/amd64/libjavafx*.so \
           default-jvm/jre/lib/amd64/libjfx*.so && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    echo -ne "- with `java -version 2>&1 | awk 'NR == 2'`\n" >> /root/.built

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
      mkdir -p "$SBT_HOME" && \
      wget -qO - --no-check-certificate "https://cocl.us/sbt-$SBT_VERSION.tgz" | tar xz -C $SBT_HOME --strip-components=1 && \
      sbt sbtVersion

# Define working directory
WORKDIR /app

# Trigger compiler-interface compilation
RUN \
  mkdir -p project src/main/scala && \
  echo "sbt.version = ${SBT_VERSION}" > project/build.properties && \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
  touch src/main/scala/scratch.scala && \
  sbt compile && \
  rm -rf *

