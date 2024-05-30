FROM ubuntu:22.04

RUN apt update && apt install -y git curl unzip cmake libgtk-3-dev clang ninja-build wget

RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/flutter/bin"

# Run basic check to download Dark SDK
RUN flutter doctor

RUN wget -O appimage-builder-x86_64.AppImage https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.1.0/appimage-builder-1.1.0-x86_64.AppImage
RUN chmod +x appimage-builder-x86_64.AppImage

RUN mv appimage-builder-x86_64.AppImage /usr/local/bin/appimage-builder

RUN mkdir /app
WORKDIR /app