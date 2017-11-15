#
# Scala and sbt Dockerfile
#
# Original repo:
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM openjdk:8u131-alpine

# Env variables
ENV SCALA_VERSION 2.12.4
ENV SBT_VERSION 0.13.16
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

# Scala expects this file
#RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

# Install base packages
RUN apk update && apk upgrade && \
    apk add curl wget bash tree tar && \
    echo -ne "Alpine Linux 3.5 image. (`uname -rsv`)\n" >> /root/.built

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
      mkdir -p "$SBT_HOME" && \
      wget -q --no-check-certificate -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
      wget -q --no-check-certificate https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk && apk add glibc-2.25-r0.apk && rm glibc-2.25-r0.apk && \
      wget -qO - --no-check-certificate "https://cocl.us/sbt-$SBT_VERSION.tgz" | tar xz -C $SBT_HOME --strip-components=1 && \
      sbt sbtVersion

# Define working directory
WORKDIR /app
