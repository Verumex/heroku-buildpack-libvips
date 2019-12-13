heroku-buildpack-libvips
======================

Install [**libvips**](https://github.com/libvips/libvips) to your Heroku
instance.

## Usage

    heroku buildpacks:add https://github.com/Verumex/heroku-buildpack-libvips

## Using a specific version of `libvips`

By default the buildpack will install the latest release of **libvips** to your
application, but you can install a specific version of **libvips** by setting a
`LIBVIPS_VERSION` [configuration
variable](https://devcenter.heroku.com/articles/config-vars). For example:

    heroku config:set LIBVIPS_VERSION=8.7.4

The buildpack will install the latest libvips if the value of `LIBVIPS_VERSION` is
`latest` or the variable is omitted.
