.PHONY: build-docker run-docker clean format run-debug appimage

build-docker: Dockerfile clean-docker
	docker build -t flutterdocker .

clean-docker: Dockerfile
	docker container stop flutterdocker || true
	docker rm flutterdocker || true
	docker image rm flutterdocker || true

run-docker:
	docker run --rm -t -d --name flutterdocker flutterdocker || true

docker:
	docker build -t flutterdocker .
	docker run --rm -t -d --name appimage-builder appimagecrafters/appimage-builder:latest
	docker cp ./ flutterdocker:/app
	docker exec -it flutterdocker bash -c "appimage-builder --recipe ./AppImageBuilder.yml --skip-test"
	docker cp flutterdocker:/app/LinuxPowerToys-latest-x86_64.AppImage .
	docker rm -f appimage-builder

run-debug:
	flutter run -d linux

release:
	flutter build linux --release

appimage: run-docker
	docker cp ./ flutterdocker:/app
	docker exec -it flutterdocker bash -c "make clean; make release"
	docker exec -it flutterdocker bash -c "appimage-builder --appimage-extract-and-run --recipe ./AppImageBuilder.yml --skip-test"
	docker cp flutterdocker:/app/LinuxPowerToys-latest-x86_64.AppImage .
	docker rm -f flutterdocker

docker-%:
	@cmd=$$(echo $@ | sed 's/^.......//'); \
	docker exec -it flutterdocker bash -c "make $$cmd"

docker-run-debug:
	docker exec -it flutterdocker bash -c "flutter build linux"
	rm -rf build
	docker cp flutterdocker:/home/developer/app/build .
	flutter run --no-build -d linux

format:
	dart format .

clean:
	rm -rf pubspec.lock
	flutter clean
	rm LinuxPowerToys*.AppImage || true
