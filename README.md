heroku-buildpack-vips
======================

Install [**libvips**](https://github.com/libvips/libvips) to your Heroku
instance.

## Usage

    heroku buildpacks:add https://github.com/Verumex/heroku-buildpack-vips

## Using specific version of `libvips`

By default, the buildpack will install the latest release of **libvips** to your
application but you can install specific version of **libvips** by setting
`LIBVIPS_VERSION` variable to the application's [configuration
variables](https://devcenter.heroku.com/articles/config-vars). For example,

    heroku config:set LIBVIPS_VERSION=8.7.4

or by simply setting it in your app's settings page.

The buildpack will install the latest libvips if value of `LIBVIPS_VERSION` is
`latest`.
