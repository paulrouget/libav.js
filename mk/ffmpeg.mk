

# NOTE: This file is generated by m4! Make sure you're editing the .m4 version,
# not the generated version!

FFMPEG_CONFIG=--prefix=/opt/ffmpeg \
	--target-os=none \
	--enable-cross-compile \
	--disable-x86asm --disable-inline-asm \
	--disable-runtime-cpudetect \
	--cc=emcc --ranlib=emranlib \
	--disable-doc \
	--disable-stripping \
	--disable-programs \
	--disable-ffplay --disable-ffprobe --disable-network --disable-iconv --disable-xlib \
	--disable-sdl2 --disable-zlib \
	--disable-everything


build/ffmpeg-$(FFMPEG_VERSION)/build-%/libavformat/libavformat.a: \
	build/ffmpeg-$(FFMPEG_VERSION)/build-%/ffbuild/config.mak
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-$* && $(MAKE)

# General build rule for any target
# Use: buildrule(target name, configure flags, CFLAGS)


# Base (asm.js and wasm)

build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/ffbuild/config.mak: \
	build/ffmpeg-$(FFMPEG_VERSION)/PATCHED \
	configs/configs/%/ffmpeg-config.txt | \
	build/inst/base/cflags.txt
	mkdir -p build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) && \
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) && \
	emconfigure env PKG_CONFIG_PATH="$(PWD)/build/inst/base/lib/pkgconfig" \
		../configure $(FFMPEG_CONFIG) \
                --disable-pthreads --arch=emscripten \
		--optflags="$(OPTFLAGS)" \
		--extra-cflags="-I$(PWD)/build/inst/base/include " \
		--extra-ldflags="-L$(PWD)/build/inst/base/lib " \
		`cat ../../../configs/configs/$(*)/ffmpeg-config.txt`
	sed 's/--extra-\(cflags\|ldflags\)='\''[^'\'']*'\''//g' < build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/config.h > build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/config.h.tmp
	mv build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/config.h.tmp build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/config.h
	touch $(@)

part-install-base-%: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) ; \
	$(MAKE) install prefix="$(PWD)/build/inst/base"

# wasm + threads

build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/ffbuild/config.mak: \
	build/ffmpeg-$(FFMPEG_VERSION)/PATCHED \
	configs/configs/%/ffmpeg-config.txt | \
	build/inst/thr/cflags.txt
	mkdir -p build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*) && \
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*) && \
	emconfigure env PKG_CONFIG_PATH="$(PWD)/build/inst/thr/lib/pkgconfig" \
		../configure $(FFMPEG_CONFIG) \
                --enable-pthreads --arch=emscripten \
		--optflags="$(OPTFLAGS)" \
		--extra-cflags="-I$(PWD)/build/inst/thr/include $(THRFLAGS)" \
		--extra-ldflags="-L$(PWD)/build/inst/thr/lib $(THRFLAGS)" \
		`cat ../../../configs/configs/$(*)/ffmpeg-config.txt`
	sed 's/--extra-\(cflags\|ldflags\)='\''[^'\'']*'\''//g' < build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/config.h > build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/config.h.tmp
	mv build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/config.h.tmp build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/config.h
	touch $(@)

part-install-thr-%: build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/libavformat/libavformat.a
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*) ; \
	$(MAKE) install prefix="$(PWD)/build/inst/thr"


# All dependencies
include configs/configs/*/deps.mk

install-%: part-install-base-% part-install-thr-%
	true

extract: build/ffmpeg-$(FFMPEG_VERSION)/PATCHED

build/ffmpeg-$(FFMPEG_VERSION)/PATCHED: build/ffmpeg-$(FFMPEG_VERSION)/configure
	( \
		cd patches/ffmpeg && \
		cat `cat series$(FFMPEG_VERSION_MAJOR)` \
	) | ( \
		cd build/ffmpeg-$(FFMPEG_VERSION) && \
		patch -p1 \
	)
	touch $@

build/ffmpeg-$(FFMPEG_VERSION)/configure: build/ffmpeg-$(FFMPEG_VERSION).tar.xz
	cd build && tar Jxf ffmpeg-$(FFMPEG_VERSION).tar.xz
	touch $@

build/ffmpeg-$(FFMPEG_VERSION).tar.xz:
	mkdir -p build
	curl https://ffmpeg.org/releases/ffmpeg-$(FFMPEG_VERSION).tar.xz -o $@

ffmpeg-release:
	cp build/ffmpeg-$(FFMPEG_VERSION).tar.xz libav.js-$(LIBAVJS_VERSION)/sources/

.PRECIOUS: \
	build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/PATCHED \
	build/ffmpeg-$(FFMPEG_VERSION)/configure
