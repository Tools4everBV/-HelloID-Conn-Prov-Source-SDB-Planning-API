# HelloID-Conn-Prov-Source-SDB-Planning-API

<!--
** for extra information about alert syntax please refer to [Alerts](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts)
-->

> [!IMPORTANT]
> This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.

<p align="center">
  <img src="">
</p>

## Table of contents

- [HelloID-Conn-Prov-Source-SDB-Planning-API](#helloid-conn-prov-source-sdb-planning-api)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting started](#getting-started)
    - [Connection settings](#connection-settings)
  - [Development resources](#development-resources)
    - [API endpoints](#api-endpoints)
    - [API documentation](#api-documentation)
  - [Getting help](#getting-help)
  - [HelloID docs](#helloid-docs)

## Introduction

_HelloID-Conn-Prov-Source-SDB-Planning-API_ is a _Source_ connector. _SDB-Planning-API_ provides a set of REST API's that allow you to programmatically interact with its data.

## Getting started

### Connection settings

The following settings are required to connect to the SDB API.

| Setting        | Description                                                              | Mandatory |
| -------------- | ------------------------------------------------------------------------ | --------- |
| ApiKey         | The ApiKey to connect to the API                                         | Yes       |
| BaseUrl        | The URL to the API                                                       | Yes       |
| HistoricalDays | - The number of days in the past from which the duties will be imported. | Yes       |
| FutureDays     | - The number of days in the past from which the duties will be imported. | Yes       |

## Development resources

### API endpoints

The following endpoints are used by the connector

| Endpoint | Description               |
| -------- | ------------------------- |
| /duties   | Retrieve duties and employee information |

### API documentation

https://standalone.sdbplanning.nl/redoc/index.html

## Getting help

> [!TIP]
> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/en/provisioning/Source-systems/powershell-v2-Source-systems.html) pages_.


## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/
