
CC  = emcc
CXX = em++
LD  = em++
AR  = emar

EMSCRIPTEN_TARGET?=asmjs

ifeq ($(EMSCRIPTEN_TARGET),js)

CPPFLAGS += 
CXXFLAGS += -std=c++11 -fPIC -O2 -s ASM_JS=2 -s DISABLE_EXCEPTION_CATCHING=0 -s PRECISE_F32=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -ffast-math 
CFLAGS   += -std=c99   -fPIC -O2 -s ASM_JS=2 -s DISABLE_EXCEPTION_CATCHING=0 -s PRECISE_F32=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -ffast-math -fno-strict-aliasing 
LDFLAGS  += -O2 -s ASM_JS=2 -s DISABLE_EXCEPTION_CATCHING=0 -s PRECISE_F32=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -s EXPORT_NAME="'libopenmpt'"
LDLIBS   += 
ARFLAGS  := rcs

# allow growing heap (might be slower, especially with V8 (as used by Chrome))
#LDFLAGS += -s ALLOW_MEMORY_GROWTH=1
# limit memory to 64MB, faster but loading modules bigger than about 16MB will not work
#LDFLAGS += -s TOTAL_MEMORY=67108864

LDFLAGS += -s ALLOW_MEMORY_GROWTH=1

else ifeq ($(EMSCRIPTEN_TARGET),asmjs)

CPPFLAGS += 
CXXFLAGS += -std=c++11 -fPIC -O2 -s DISABLE_EXCEPTION_CATCHING=0 -s PRECISE_F32=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -ffast-math 
CFLAGS   += -std=c99   -fPIC -O2 -s DISABLE_EXCEPTION_CATCHING=0 -s PRECISE_F32=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -ffast-math -fno-strict-aliasing 
LDFLAGS  += -O2 -s DISABLE_EXCEPTION_CATCHING=0 -s PRECISE_F32=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -s EXPORT_NAME="'libopenmpt'"
LDLIBS   += 
ARFLAGS  := rcs

# allow growing heap (might be slower, especially with V8 (as used by Chrome))
#LDFLAGS += -s ALLOW_MEMORY_GROWTH=1
# limit memory to 64MB, faster but loading modules bigger than about 16MB will not work
#LDFLAGS += -s TOTAL_MEMORY=67108864

LDFLAGS += -s ALLOW_MEMORY_GROWTH=1

else ifeq ($(EMSCRIPTEN_TARGET),wasm)

CPPFLAGS += -DMPT_BUILD_WASM
CXXFLAGS += -std=c++11 -fPIC -Os -s WASM=1 -s DISABLE_EXCEPTION_CATCHING=0 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -ffast-math 
CFLAGS   += -std=c99   -fPIC -Os -s WASM=1 -s DISABLE_EXCEPTION_CATCHING=0 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -ffast-math -fno-strict-aliasing 
LDFLAGS  += -Os -s WASM=1 -s DISABLE_EXCEPTION_CATCHING=0 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -s EXPORT_NAME="'libopenmpt'"
LDLIBS   += 
ARFLAGS  := rcs

# allow growing heap (might be slower, especially with V8 (as used by Chrome))
#LDFLAGS += -s ALLOW_MEMORY_GROWTH=1
# limit memory to 64MB, faster but loading modules bigger than about 16MB will not work
#LDFLAGS += -s TOTAL_MEMORY=67108864

LDFLAGS += -s ALLOW_MEMORY_GROWTH=1

endif

CFLAGS_SILENT += -Wno-unused-parameter -Wno-unused-function -Wno-cast-qual

CXXFLAGS_WARNINGS += -Wmissing-declarations
CFLAGS_WARNINGS   += -Wmissing-prototypes

REQUIRES_RUNPREFIX=1

ifeq ($(EMSCRIPTEN_TARGET),wasm)

EXESUFFIX=.html
SOSUFFIX=.wasm
SO_LDFLAGS=-s SIDE_MODULE=1
BIN_LDFLAGS=-s SIDE_MODULE=0
TEST_LDFLAGS=-s SIDE_MODULE=0 --emrun

else

EXESUFFIX=.js
SOSUFFIX=.js
RUNPREFIX=nodejs 
TEST_LDFLAGS= --pre-js build/make/test-pre.js 

endif

DYNLINK=0
SHARED_LIB=1
STATIC_LIB=0
EXAMPLES=1
OPENMPT123=0
SHARED_SONAME=0

# Disable the generic compiler optimization flags as emscripten is sufficiently different.
# Optimization flags are hard-coded for emscripten in this file.
DEBUG=0
OPTIMIZE=0
OPTIMIZE_SIZE=0

NO_ZLIB=1
NO_LTDL=1
NO_DL=1
NO_MPG123=1
NO_OGG=1
NO_VORBIS=1
NO_VORBISFILE=1
NO_PORTAUDIO=1
NO_PORTAUDIOCPP=1
NO_PULSEAUDIO=1
NO_SDL=1
NO_SDL2=1
NO_FLAC=1
NO_SNDFILE=1

