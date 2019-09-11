# Hyscale resources JSON Schemas

This repository contains a set of json schemas for Hyscale Resources. For each specified Hyscale versions you can find json schemas for hyscale resources.

## Example

Here are the links to the `service-spec` schemas for Hyscale:

* [v1.0.0-local/service-spec.json](v1.0.0-local/service-spec.json)

## Usage

There are lots of use cases for these schemas, they are primarily useful as a
low-level part of other developer workflow tools. But at a most basic level you can
validate a Hyscale definition.

Here is a very simply example using the Python [jsonschema client](https://github.com/Julian/jsonschema) and an invalid deployment file:

```
$ jsonschema -F "{error.message}" -i tests/hrms-frontend.json v1.0.0-local/deployment.json

```

## Uses:


* Testing tools to show your Hyscale service spec files are valid,
  and against which versions of Hyscale.
* Integration with code editors, for instance via something like [Schema
  Store](http://schemastore.org/json/)
* Visual tools for crafting Hyscale Configuration files.
* Tools to show changes between Hyscale versions

