# AWS LAMBDA LOG API

This Repo is an example written in Python that shows how is possible to send the Lambda logs to a S3 Bucket without the need of Cloudwatch. This is done using the Lambda Log API data streams.

# Pre-Requisites

To run this example, it's required the following depedencies:

 * tfenv
 * terraform
 * make

## How To Run the Example

This code runs using a Makfile file.

You need first to setup the remote terraform state file in a bucket and to create the relevant DynamoDB containing the log file.

```
make onetimes3
```
To Install the lambdas:

```
make tinit
make tlan
make tapply
```

To destroy the setup

```
make tdestroy
```

## Documentation

 * <https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtime-environment.html>
 * <https://docs.aws.amazon.com/lambda/latest/dg/runtimes-extensions-api.html>
 * <https://docs.aws.amazon.com/lambda/latest/dg/runtimes-logs-api.html>
 * <https://github.com/aws-samples/aws-lambda-extensions>