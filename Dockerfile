#
# Scala and sbt Dockerfile
#
# Original repo:
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM openjdk:8u171-jdk-alpine3.8

# Scala
ENV SCALA_VERSION 2.12.10
ENV SBT_VERSION 1.3.3
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin

# Install base packages
RUN apk update && apk upgrade && \
  apk add curl wget bash tree tar && \
  echo -ne "Alpine Linux 3.8 image. (`uname -rsv`)\n" >> /root/.built

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
  mkdir -p "$SBT_HOME" && \
  wget -qO - --no-check-certificate "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" | tar xz -C $SBT_HOME --strip-components=1 && \
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
