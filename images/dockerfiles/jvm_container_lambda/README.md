# Java / Scala Lambda Container Image

This Dockerfile is used to build a container image that can be used to run JVM 
code in AWS Lambda as a container based Lambda.

It is based on the Corretto 11 image, and includes the AWS CLI and an extension 
to deal with passing secrets from AWS Secrets Manager to the container.

## Usage

```Dockefile
FROM wellcome/jvm-container-lambda:latest

# Add your artifacts to the container
COPY target/lambda.jar /opt/docker

ENTRYPOINT [ "/usr/bin/java", "com.amazonaws.services.lambda.runtime.api.client.AWSLambda" ]

# Set the handler
CMD ["com.example.MyHandler::handleRequest"]
```

### Accessing Secrets

This approach uses the [Lambda Extension API](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-extensions-api.html), which is [available to containerised Lambdas](https://aws.amazon.com/blogs/compute/working-with-lambda-layers-and-extensions-in-container-images/) by adding files to `/opt/extensions/`.

For simplicity (by comparison to including some other language runtime to run extension code and/or providing a binary to package), we use a bash script extension, based on [the example here.](https://github.com/aws-samples/aws-lambda-extensions/tree/main/bash-example-wrapper).

#### How it works:

- `bash_secrets_extension.sh` looks for environment variables values that have been passed to the lambda that have been prefixed with `secret:` and retrieves them from AWS Secrets Manager.
- The extension creates a file in the containerised environment called `/tmp/config` that will persist between invocations, the file uses the [Typesafe Config](https://lightbend.github.io/config/) format (HOCON).
- Inside the application this file can be read and parsed to access the secrets.

#### Example usage:

- [Use in terraform in the catalogue pipeline.](https://github.com/wellcomecollection/catalogue-pipeline/tree/6f6e8426af58e5b617d08d4cf2c810bf61ebce3e/pipeline/terraform/modules/pipeline_lambda )

- [Layering Typesafe Config in Scala in the catalogue pipeline.](https://github.com/wellcomecollection/catalogue-pipeline/blob/main/common/lambda/src/6f6e8426af58e5b617d08d4cf2c810bf61ebce3e/scala/weco/lambda/LambdaConfiguration.scala#L21)