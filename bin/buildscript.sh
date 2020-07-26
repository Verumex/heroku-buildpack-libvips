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
  mkdir -p $CACHE_DIR
}

cleanup_build() {
  rm -Rf $TMP_DIR
}

export_profile() {
  mkdir -p $BUILD_DIR/.profile.d
  cp $BP_DIR/.profile.d/* $BUILD_DIR/.profile.d/
}

install_libvips() {
  detect_libvips_version

  if [[ -d "$CACHE_DIR/$LIBVIPS_VERSION" ]]; then
    restore_cached_build
  else
    build_libvips
  fi
}

detect_libvips_version() {
  [[ ! -d $ENV_DIR ]] && exit 1

  if [[ -r "$ENV_DIR/LIBVIPS_VERSION" ]]; then
    export LIBVIPS_VERSION=$(cat "$ENV_DIR/LIBVIPS_VERSION")
  else
    echo "Checking for latest libvips version" | indent
    export LIBVIPS_VERSION=$(detect_latest_version)
  fi
}

detect_latest_version() {
  curl -s https://api.github.com/repos/libvips/libvips/releases/latest \
    | grep "browser_download_url.*tar.gz" \
    | head -1 \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | grep "[0-9]*\.[0-9]*\.[0-9]" -o \
    | head -1
}

restore_cached_build() {
  echo "Restoring cached libvips build" | indent
  cp -R "$CACHE_DIR/$LIBVIPS_VERSION/." $VIPS_PATH
}

build_libvips() {
  echo "Building libvips binary..." | arrow

  download_libvips \
    && unpack_source_archive \
    && cd $TMP_DIR \
    && configure_and_compile \
    && make -s install > /dev/null 2>& 1 \
    && cd ~ \
    && cache_build
}

download_libvips() {
  rm -Rf $CACHE_DIR/*

  local download_path="$TMP_DIR/libvips.tar.gz"

  echo "Downloading libvips ${LIBVIPS_VERSION} source archive" | indent
  curl -sL "https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.gz" -o $download_path
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

cache_build() {
  echo "Caching binaries" | indent

  cp -R "$VIPS_PATH/." "$CACHE_DIR/$LIBVIPS_VERSION"
}
