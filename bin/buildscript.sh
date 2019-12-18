#!/usr/bin/env bash

indent() {
  sed 's/^/       /'
}

arrow() {
  sed 's/^/-----> /'
}

ensure_dirs() {
  mkdir -p $TMP_DIR
  mkdir -p $VIPS_PATH
}

export_profile() {
  mkdir -p $BUILD_DIR/.profile.d
  cp $BP_DIR/.profile.d/* $BUILD_DIR/.profile.d/
}

cleanup_build() {
  rm -Rf $TMP_DIR
}

detect_libvips_version() {
  [[ ! -d $ENV_DIR ]] && exit 1

  if [[ -r "$ENV_DIR/LIBVIPS_VERSION" ]]; then
    export LIBVIPS_VERSION=$(cat "$ENV_DIR/LIBVIPS_VERSION")
  else
    export LIBVIPS_VERSION="latest"
  fi

  echo $LIBVIPS_VERSION
}

download_libvips() {
  local version=$(detect_libvips_version)
  local download_path="$TMP_DIR/libvips.tar.gz"

  if [[ "latest" == $version ]]; then
    echo "Downloading latest libvips source archive" | indent
    curl -s https://api.github.com/repos/libvips/libvips/releases/latest \
      | grep "browser_download_url.*tar.gz" \
      | head -1 \
      | cut -d : -f 2,3 \
      | tr -d \" \
      | xargs curl -sL -o $download_path
  else
    echo "Downloading libvips ${version} source archive" | indent
    curl -sL "https://github.com/libvips/libvips/releases/download/v${version}/vips-${version}.tar.gz" -o $download_path
  fi
}

unpack_source_archive() {
  echo "Unpacking libvips source archive" | indent \
    && tar xf "$TMP_DIR/libvips.tar.gz" -C $TMP_DIR --strip 1
}

configure_and_compile() {
  echo "Compiling libvips" | indent \
    && ./configure --prefix $VIPS_PATH --enable-shared --disable-static \
      --disable-dependency-tracking --disable-debug --disable-introspection \
      --without-fftw --without-pangoft2 --without-ppm \
      --without-analyze --without-radiance > /dev/null 2>& 1 \
    && make -s > /dev/null 2>& 1
}

build_libvips() {
  echo "Building libvips binary..." | arrow

  download_libvips \
    && unpack_source_archive \
    && cd $TMP_DIR \
    && configure_and_compile \
    && make -s install > /dev/null 2>& 1
}
