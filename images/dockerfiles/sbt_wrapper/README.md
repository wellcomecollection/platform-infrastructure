# sbt_wrapper

This image is the wrapper around [sbt] that we use when running build tasks for our Scala apps.

This image also includes Docker Compose, which we use to run mocks of certain services.

[sbt]: https://www.scala-sbt.org/



## Building and publishing the image

To build the image:

```console
$ docker build -t sbt_wrapper .
```

To publish the image to ECR:

```console
$ # log in to ECR
$ eval $(AWS_PROFILE=platform-dev aws ecr get-login --no-include-email)

$ # push the image
$ docker tag sbt_wrapper 760097843905.dkr.ecr.eu-west-1.amazonaws.com/wellcome/sbt_wrapper
$ docker push 760097843905.dkr.ecr.eu-west-1.amazonaws.com/wellcome/sbt_wrapper
```

All our Scala builds pull the `latest` tag; you may want to test with a different tag if you're making major changes to the image.



## How the image is built

Most of the image is a standard Dockerfile build.
The `install_*.sh` scripts install the major dependencies, and remove stuff we don't need in the final image to reduce the time it takes to pull the image from ECR (because we pull this image hundreds of times a week).



## How we cache the sbt installation

If you run sbt with no cache, you see something like:

```
getting org.scala-sbt sbt 1.4.1  (this may take some time)...
```

The exact time varies, but either way we don't want to do this on every Scala build, so we fetch sbt as part of the Docker image (see `install_sbt.sh`).
This gets saved in the `~/.sbt` folder.

When we run the image, we mount the `~/.ivy2` and `~/.sbt` caches from persistent folders on the host -- so if we run multiple sbt tasks on the same host, they use the same cache and don't have to redownload dependencies each time.
But this overwrites whatever was in those folders in the image – so the cached version of sbt in `~/.sbt` would be lost.

To get around this, we move the in-image cache to `~/.ivy2.image` and `~/.sbt.image` as part of building the Docker image.
Then, when the image is run, it moves those files back into `~/.ivy2` and `~/.sbt`, so we don't have to redownload sbt.

This is handled by the scripts `install_sbt.sh` and `run_sbt.sh`.
It should be completely transparent to end users, but does seem to speed up builds slightly.
