using BinaryBuilder

name = "LibSSH2"
version = v"1.8.0"

# Collection of sources required to build Ogg
sources = [
   "https://github.com/libssh2/libssh2/releases/download/libssh2-$(version)/libssh2-$(version).tar.gz" =>
   "39f34e2f6835f4b992cafe8625073a88e5a28ba78f83e8099610a7b3af4676d4",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libssh2*/

BUILD_FLAGS=(
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTING=OFF
    -DENABLE_ZLIB_COMPRESSION=OFF
    "-DCMAKE_INSTALL_PREFIX=${prefix}"
    "-DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain"
)

if [[ ${target} == *mingw* ]]; then
    BUILD_FLAGS+=(-DCRYPTO_BACKEND=WinCNG)
else
    BUILD_FLAGS+=(-DCRYPTO_BACKEND=mbedTLS)
fi

mkdir build
cd build

cmake .. "${BUILD_FLAGS[@]}"
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = prefix -> [
    LibraryProduct(prefix, "libssh2", :libssh2),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaWeb/MbedTLSBuilder/releases/download/v0.16.0/build_MbedTLS.v2.13.1.jl",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
