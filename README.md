# Scala and sbt Dockerfile

This repository contains **Dockerfile** of [Scala](http://www.scala-lang.org) and [sbt](http://www.scala-sbt.org).


## Base Docker Image ##

* [openjdk](https://hub.docker.com/_/openjdk)


## Change versions ##

In order to build a new image just change the values in `.circleci/config.yml`:

```
      OPENJDK_VERSION: 8u171-jdk-alpine3.8
      SCALA_VERSION: 2.12.10
      SBT_VERSION: 1.3.4
```

The repository `paytouch/scala-sbt` is setup with `"imageTagMutability": "IMMUTABLE"`, so builds will fail if it will attempt to push the same tag to the ECR repo.

## License ##

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
