# Peatio - an open-source crypto currency exchange

[![Build Status](https://travis-ci.org/rubykube/peatio.svg?branch=master)](https://travis-ci.org/rubykube/peatio)
[![Telegram Chat](https://cdn.rawgit.com/Patrolavia/telegram-badge/8fe3382b/chat.svg)](https://t.me/peatio)

## [Peatio.tech](https://www.peatio.tech) Introduction

Peatio is a free and open-source crypto currency exchange implementation with the Rails framework.
Peatio.tech is a fork of Peatio designed for micro-services architecture. We have simplified the code
in order to use only Peatio API with external frontend and server components.

To build your own exchange you should now run Peatio as a backend instead of forking the repository,
and extend it using other microservices such as [Barong](https://www.github.com/rubykube/barong).

## Mission

Our mission is to build an open-source crypto currency exchange with a high performance trading engine and incomparable security. We are moving toward dev/ops best practices of running an enterprise grade exchange.

We provide webinar or on site training for installing, configuring and administration best practices of Peatio.
Feel free to contact us for joining the next training session: [Peatio.tech](https://www.peatio.tech)

Help is greatly appreciated, feel free to submit pull-requests or open issues.

## Things You Should Know

**RUNNING AN EXCHANGE IS HARD.**

This repository is not a turn key solution and will require engineering and design of security process by your company, with or without our assistance. This repository is one component among many we recommend using for composing an enterprise grade exchange. It is highly recommended to deploy a UAT environment and build automated tests for your needs, including Functional tests, Smoke tests and Security vulnerability scans. You may not need to have an active developer on Peatio source code, however, we recommend the following team setup: 1 dev/ops, 3 frontend developers (react / angular), 2 QA engineers, 1 Security Officer.

**SECURITY KNOWLEDGE IS A REQUIREMENT.**

Peatio cannot protect your customers if you leave your admin password 1234567, or open sensitive ports to public internet. No one can. Running an exchange is a very risky task because you're dealing with money directly. If you don't know how to make your exchange secure, hire an expert.

You must know what you're doing, there's no shortcut. Please get prepared before you continue:

* Rails knowledge
* Security knowledge
* Cloud and Linux administration
* Docker and Kubernetes administration
* Micro-services and OAuth 2.0

## Features

* Designed as high performance crypto currency exchange
* Built-in high performance matching-engine
* Built-in [Proof of Solvency](https://iwilcox.me.uk/2014/proving-bitcoin-reserves) Audit
* Usability and scalability
* Websocket API and high frequency trading support
* Support multiple digital currencies (eg. Bitcoin, Litecoin, Ethereum, Ripple etc.)
* Support ERC20 Tokens
* API end point for FIAT deposits or payment gateways.
* Powerful admin dashboard and management tools
* Highly configurable and extendable
* Industry standard security out of box
* Maintained by [peatio.tech](https://www.peatio.tech)
* [KYC Verification](http://en.wikipedia.org/wiki/Know_your_customer) provided by [Barong](https://www.github.com/rubykube/barong)

## Requirements

* Linux / Mac OSX
* Docker / Kubernetes
* Ruby 2.5.0
* Rails 4.2+
* Redis 2.0+
* MySQL 5.7
* RabbitMQ

Find more details in the [docs directory](docs).

## Getting Started

### Local development setup:

* ### [Docker compose](https://github.com/rubykube/peatio-workbench)
We suggest you to start using Peatio by installing [Workbench](https://github.com/rubykube/workbench). [Workbench](https://github.com/rubykube/workbench) which is based on [Docker containers](https://www.docker.com/what-docker) is a convenient and straightforward way to start Peatio development environment.

#### Prerequisites
1. [Docker](https://docs.docker.com/install/) installed
2. [Docker compose](https://docs.docker.com/compose/install/) installed

#### Prepare the workbench

1. Recursive clone : `git clone --recursive https://github.com/rubykube/workbench.git`
2. Move to workbench `cd workbench`
3. Build the images: `make build`
4. Run the application: `make run`

You should add those hosts to your `/etc/hosts` file:

```
0.0.0.0 api.wb.local
0.0.0.0 auth.wb.local

0.0.0.0 api.slanger.wb.local
0.0.0.0 ws.slanger.wb.local

0.0.0.0 pma.wb.local
0.0.0.0 monitor.wb.local

0.0.0.0 btc.wb.local
0.0.0.0 eth.wb.local
```
Now you have peatio up and running.

##### [Barong](https://github.com/rubykube/barong)

Barong is an essential part of Rubykube Peatio. It is a KYC OAuth 2.0 provider. Barong replace the KYC, 2FA, Phone verification from legacy Peatio.
Barong manage roles and kyc level across all applications from the RKCP. It's easy to extend by using the EventAPI or Rest API.

##### Barong key features

* KYC Verification for individuals
* SMS and Google two-factor authentication
* OAuth 2.0 provider
* Transaction Signature support
* Supply JWT tokens to frontend and mobile app


Start barong:

```sh
$> docker-compose run --rm barong bash -c "./bin/link_config && ./bin/setup"
$> docker-compose up -d barong
```

This will output password for **admin@barong.io**. Default password is **`Qwerty123`**

##### Peatio

Start peatio server

```sh
$> docker-compose run --rm peatio bash -c "./bin/link_config && rake db:create db:migrate db:seed"
$> docker-compose up -d peatio
```

After all of that you can start using Peatio in your brouser just by following one of the hosts which you added earlier.

##### Frontend

Simply start your local server. Now you're able to log in with your local Barong and Peatio.

* ### [on Mac OS X](docs/setup-osx.md)

* ### [on Ubuntu](docs/setup-ubuntu.md)

### Production setup:

* [Deploy production cluster with kite](https://github.com/rubykube/kite/blob/master/README.md)
* [Kubernetes deployment architecture](docs/architecture.md)

## API

You can interact with Peatio through API:

* [API v2 docs](https://demo.peatio.tech/documents/api_v2?lang=en)
* [Websocket API docs](https://demo.peatio.tech/documents/websocket_api)

Here are some API clients/wrappers:

* [peatio-client-ruby](https://github.com/peatio/peatio-client-ruby) is the official ruby client of both HTTP/Websocket API.
* [peatio-client-python by JohnnyZhao](https://github.com/JohnnyZhao/peatio-client-python) is a python client written by JohnnyZhao.
* [peatio-client-python by czheo](https://github.com/JohnnyZhao/peatio-client-python) is a python wrapper similar to peatio-client-ruby written by czheo.
* [peatioJavaClient](https://github.com/classic1999/peatioJavaClient.git) is a java client written by classic1999.
* [yunbi-client-php](https://github.com/panlilu/yunbi-client-php) is a php client written by panlilu.

## Getting Involved
We want to make it super-easy for Peatio users and contributors to talk to us and connect with each other, to share ideas, solve problems and help make Peatio awesome. Here are the main channels we're running currently, we'd love to hear from you on one of them:

### Discourse

[Rubykube Discourse Forum](https://discuss.rubykube.io)

This is for all Peatio users. You can find guides, recipes, questions, and answers from Snowplow users including the Peatio.tech team.
We welcome questions and contributions!

### Telegram

[@peatio](https://t.me/peatio)

Chat with us and other community members on Telegram.

### GitHub
Peatio issues

If you spot a bug, then please raise an issue in our main GitHub project (rubykube/peatio); likewise, if you have developed a cool new feature or improvement in your Rubykube Peatio fork, then send us a pull request!
If you want to brainstorm a potential new feature, then the Rubykube Discourse Forum (see above) is probably a better place to start.

### Email
hello@peatio.tech

If you want to talk directly to us (e.g. about a commercially sensitive issue), email is the easiest way.

## Getting Support and Customization

If you need help with running/deploying/customizing Peatio,
you can contact us on [peatio.tech](https://www.peatio.tech).

Contact us by email: [hello@peatio.tech](mailto:hello@peatio.tech)

## License

Peatio is released under the terms of the [MIT license](http://peatio.mit-license.org).

## What is Peatio?

[Peatio](http://en.wikipedia.org/wiki/Pixiu) (Chinese: 貔貅) is a Chinese mythical hybrid creature
considered to be a very powerful protector to practitioners of Feng Shui.

**[This illustration copyright for Peatio Team]**

![logo](public/peatio.png)
