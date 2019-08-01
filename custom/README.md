Deep learning Custom Image
==========================

This directory contains a template `Dockerfile` and example `environment.yml` file which install several optimisation packages. Any packages available through conda or pip may be installed by adding them to the `environment.yml` file (with additional channels as necessary) then a custom image may be built from within this directory with the command:

```
docker build -t dl-custom .
```

Similarly, any additional files or environment variables required may be added through editing the `Dockerfile`. For more information, see: https://docs.docker.com/engine/reference/commandline/build/.

To run the image, use the following command (modifying the mounted folder as necessary):

    $ docker run --runtime=nvidia -it --rm --net=host -v $(pwd):/work/code dl-custom

Alternatively, the `Makefile` can be used by setting the `TAG` variable to `dl-custom` (or whatever you choose to call it) e.g.:

    $ make lab TAG=dl-custom

Please visit the main documentation site for further help using this image and others.

* [MMRL Jupyter Docker Stacks on GitHub](https://github.com/mmrl/dl)
