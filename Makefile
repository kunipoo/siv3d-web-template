# ==========================================
# OpenSiv3D for Web - Makefile
# ==========================================

# コンパイラ設定 (Emscripten)
CXX = emcc

# コンパイルオプション
CXXFLAGS =	-std=c++20 \
			-O1 \
			-D_XM_NO_INTRINSICS_ \
			-isystem OpenSiv3D/include/Siv3D \
			-isystem OpenSiv3D/include/Siv3D/ThirdParty

# リンカオプション
LDFLAGS = \
	-LOpenSiv3D/lib  \
	-LOpenSiv3D/lib/Siv3D/freetype \
	-LOpenSiv3D/lib/Siv3D/giflib \
	-LOpenSiv3D/lib/Siv3D/harfbuzz \
	-LOpenSiv3D/lib/Siv3D/opencv \
	-LOpenSiv3D/lib/Siv3D/opus \
	-LOpenSiv3D/lib/Siv3D/png \
	-LOpenSiv3D/lib/Siv3D/tiff \
	-LOpenSiv3D/lib/Siv3D/turbojpeg \
	-LOpenSiv3D/lib/Siv3D/SDL2 \
	-LOpenSiv3D/lib/Siv3D/webp \
	-LOpenSiv3D/lib/Siv3D/zlib \
	-lSiv3D \
	-lfreetype \
	-lgif \
	-lharfbuzz \
	-lopencv_core \
	-lopencv_imgproc \
	-lopencv_objdetect \
	-lopencv_photo \
	-lturbojpeg \
	-ltiff \
	-lopus \
	-lopusfile \
	-lpng \
	-lSDL2 \
	-lwebp \
	-lz \
	--emrun \
	-s FULL_ES3=1 \
	-s MIN_WEBGL_VERSION=2 \
	-s MAX_WEBGL_VERSION=2 \
	-s USE_GLFW=3 \
	-s USE_OGG=1 \
	-s USE_VORBIS=1 \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s WARN_ON_UNDEFINED_SYMBOLS=0 \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
	-s ASYNCIFY=1 \
	-s ASYNCIFY_IGNORE_INDIRECT=1 \
	-s ASYNCIFY_IMPORTS="['siv3dRequestAnimationFrame','siv3dGetClipboardText','siv3dDecodeImageFromFile','siv3dSleepUntilWaked','invoke_vi','invoke_v']" \
	-s ASYNCIFY_ADD="['main','Main()','dynCall_v','dynCall_vi','s3d::TryMain()','s3d::CSystem::init()','s3d::System::Update()','s3d::AACDecoder::decode(*) const','s3d::MP3Decoder::decode(*) const','s3d::CAudioDecoder::decode(*)','s3d::AudioDecoder::Decode(*)','s3d::Wave::Wave(*)','s3d::Audio::Audio(*)','s3d::Clipboard::GetText(*)','s3d::CClipboard::getText(*)','s3d::GenericDecoder::decode(*) const','s3d::CImageDecoder::decode(*)','s3d::Image::Image(*)','s3d::Texture::Texture(*)','s3d::ImageDecoder::Decode(*)','s3d::ImageDecoder::GetImageInfo(*)','s3d::CRenderer2D_GLES3::init()','s3d::CRenderer2D_WebGPU::init()','s3d::Clipboard::GetText(*)','s3d::CClipboard::getText(*)','s3d::SimpleHTTP::Save(*)','s3d::SimpleHTTP::Load(*)','s3d::SimpleHTTP::Get(*)','s3d::SimpleHTTP::Post(*)','s3d::VideoReader::VideoReader(*)','s3d::VideoReader::open(*)','s3d::Platform::Web::FetchFile(*)']" \
	-s EXPORT_NAME=Runtime \
	-s MODULARIZE=1 \
	--preload-file resources@/resources \
	--shell-file OpenSiv3D/Templates/Embeddable/web-player.html \
	--pre-js OpenSiv3D/lib/Siv3D/Siv3D.pre.js \
	--post-js OpenSiv3D/lib/Siv3D/Siv3D.post.js \
	--post-js OpenSiv3D/Templates/Embeddable/web-player.js \
	--js-library OpenSiv3D/lib/Siv3D/Siv3D.js

# プリコンパイル済みヘッダー (PCH) の設定
PCH_SRC = OpenSiv3D/include/Siv3D/Siv3D.hpp
PCH_OUT = output/Siv3D.hpp.pch

.PHONY: all

all: output output/index.html

output:
	mkdir -p output

# PCHの生成ルール
$(PCH_OUT): $(PCH_SRC) | output
	$(CXX) $(CXXFLAGS) -x c++-header $(PCH_SRC) -o $(PCH_OUT)

output/index.html: Main.cpp $(PCH_OUT)
	$(CXX) Main.cpp $(CXXFLAGS) -include-pch $(PCH_OUT) $(LDFLAGS) -o output/index.html 2> build.log; \
	RESULT=$$?; \
	grep -v "warning: Asyncify addlist contained a" build.log; \
	rm -f build.log; \
	exit $$RESULT

clean:
	rm -rf output

install:
	sudo cp output/index.* /var/www/html
