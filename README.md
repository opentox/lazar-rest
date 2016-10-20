# lazar-rest

REST API webservice for lazar and nano-lazar.
lazar (lazy structure–activity relationships) is a modular framework for read across predictions of chemical toxicities. Within the European Union’s FP7 eNanoMapper project lazar was extended with capabilities to handle nanomaterial data, interfaces to other eNanoMapper services (databases and ontologies) and a stable and user-friendly graphical interface for nanoparticle read-across predictions. **lazar-rest** provides a new Restful webservice to this developments.

## Installation

Download the code from github.

```
git clone https://github.com/opentox/lazar-rest.git
```
Install the required library gems with bundler
```
cd lazar-gem
bundle install
```

In development environment use lazar and qsar-report library from source

```ruby
    require "../lazar/lib/lazar.rb"
    require "../qsar-report/lib/qsar-report.rb"
```

In production environment change this to the following to have lazar and qsar-report library from ruby gem

```ruby
    require "../lazar/lib/lazar.rb"
    require "../qsar-report/lib/qsar-report.rb"
```

start the service with unicorn on an assigned port
```
unicorn -p 8080 -D
```
(satrt without daemonize option *-D* for debugging)

## Documentation

For full Swagger API documentation open /api/api.json with Swagger UI.

## Copyright

Copyright (c) 2015-2016 Christoph Helma, Micha Rautenberg, Denis Gebele. See LICENSE for details.