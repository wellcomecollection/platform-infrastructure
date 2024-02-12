# AWSTOE 

This image allows the local testing and development of AWS Image Builder components using the [AWS Task Orchestrator and Executor component manager](https://docs.aws.amazon.com/imagebuilder/latest/userguide/toe-component-manager.html).

## Development

Put component YAML in the ./components directory and run `./run.sh` this will start a docker container with `awstoe` installed and give you an interactive shell on that container. Exiting gracefully should stop and clean up the created container.

You can run a component like this:

```console
awstoe run --trace --documents /components/hello-world.yml --phases build
```

It will attempt to run the component within the running container image.

