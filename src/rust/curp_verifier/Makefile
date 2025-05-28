# Soporte para instalación personalizada
PREFIX ?= /usr
# Nombre del crate
CRATE=curp_verifier
NAME=curp-verifier
EXT=$(shell uname | grep -q Darwin && echo dylib || echo so)
TARGET=target/release/lib$(CRATE).$(EXT)
HEADER=include/$(CRATE).h
TEMPLATE=packaging/deb/control
REVISION=2+rafex
# FULL_VERSION=$(VERSION)-$(REVISION)  # Eliminado según instrucciones

.PHONY: all build clean cbindgen install install-tools

# Compila el proyecto en modo release
build:
	cargo build --release

# Genera el archivo .h con cbindgen
cbindgen:
	cbindgen --crate $(CRATE) --output $(HEADER)

# Instala herramientas necesarias si no existen
install-tools:
	cargo install --list | grep -q cbindgen || cargo install cbindgen

# Compila y genera el header
all: install-tools build cbindgen

# Limpia la compilación
clean:
	cargo clean

# Instala la librería y el header (requiere sudo)
install:
	mkdir -p $(DESTDIR)/$(PREFIX)/lib
	mkdir -p $(DESTDIR)/$(PREFIX)/include
	install -m 0755 $(TARGET) $(DESTDIR)/$(PREFIX)/lib
	install -m 0644 $(HEADER) $(DESTDIR)/$(PREFIX)/include

# Empaqueta el binario y el header en un .deb para la arquitectura especificada
package-deb:
	@if [ -z "$(ARCH)" ]; then \
		echo "❌ Debes especificar ARCH=amd64 o ARCH=arm64"; \
		exit 1; \
	fi
	@echo "📦 Empaquetando para arquitectura: $(ARCH)"
	mkdir -p deb_pkg/usr/lib
	chown -R 0:0 deb_pkg
	@if [ "$(ARCH)" = "arm64" ]; then \
		RUSTFLAGS="-C link-arg=-Wl,-soname,libcurp_verifier.so" cargo build --release --target aarch64-unknown-linux-gnu; \
		cp target/aarch64-unknown-linux-gnu/release/lib$(CRATE).$(EXT) deb_pkg/usr/lib/; \
	else \
		RUSTFLAGS="-C link-arg=-Wl,-soname,libcurp_verifier.so" cargo build --release; \
		cp $(TARGET) deb_pkg/usr/lib/; \
	fi

	mkdir -p deb_pkg/usr/include
	mkdir -p deb_pkg/DEBIAN
	cp $(HEADER) deb_pkg/usr/include/
	mkdir -p packaging/deb/$(ARCH)
	strip deb_pkg/usr/lib/lib$(CRATE).so
	mkdir -p deb_pkg/usr/share/doc/$(NAME)
	gzip -c README.md > deb_pkg/usr/share/doc/$(NAME)/README.md.gz
	gzip -c packaging/deb/$(ARCH)/changelog > deb_pkg/usr/share/doc/$(NAME)/changelog.Debian.gz
	cp LICENSE deb_pkg/usr/share/doc/$(NAME)/copyright

	@VERSION=$$(grep "^version" Cargo.toml | head -n1 | cut -d'"' -f2); \
	FULL_VERSION=$${VERSION}-$(REVISION); \
	DEPENDS=$$(ldd deb_pkg/usr/lib/lib$(CRATE).so | awk '{ if ($$3 ~ /^\//) print $$1 }' | xargs -r dpkg -S | cut -d: -f1 | sort -u | paste -sd "," -); \
	FINAL=packaging/deb/$(ARCH)/control; \
	cp $(TEMPLATE) $$FINAL; \
	sed -i "s|{{PACKAGE}}|$(NAME)|g; \
	        s|{{VERSION}}|$$FULL_VERSION|g; \
	        s|{{ARCHITECTURE}}|$(ARCH)|g; \
	        s|{{MAINTAINER}}|Raúl González <rafex@rafex.dev>|g; \
	        s|{{PRIORITY}}|optional|g; \
	        s|{{SECTION}}|libs|g; \
	        s|{{RUNTIME_DEPENDENCIES}}|$$DEPENDS|g; \
	        s|{{HOMEPAGE}}|https://github.com/rafex/my-repository/tree/main/src/rust/$(CRATE)|g; \
	        s|{{SUMMARY}}|Validador CURP|g; \
	        s|{{DESCRIPTION}}|Verificar CURP conforme al instructivo oficial del RENAPO.|g" $$FINAL; \
	cp $$FINAL deb_pkg/DEBIAN/control; \
	echo "📄 Control final generado:" && cat $$FINAL; \
	SIZE=$$(du -ks deb_pkg/usr | cut -f1); \
	echo "Installed-Size: $$SIZE" >> deb_pkg/DEBIAN/control; \
	echo "📄 Control final generado:" && cat deb_pkg/DEBIAN/control; \
	dpkg-deb --build deb_pkg "$(NAME)_$${FULL_VERSION}_$${ARCH}.deb"; \
	echo "📦 Paquete generado: $(NAME)_$${FULL_VERSION}_$${ARCH}.deb"

changelog-deb:
	@PACKAGE=$(NAME); \
	VERSION=$$(grep "^version" Cargo.toml | head -n1 | cut -d'"' -f2); \
	FULL_VERSION=$${VERSION}-$(REVISION); \
	EMAIL="rafex@rafex.dev"; \
	FULLNAME="Raúl González"; \
	DATE=$$(date -R); \
	MESSAGE=$$(git log -1 --pretty=format:'  * %s'); \
	echo "$$PACKAGE ($$FULL_VERSION) stable; urgency=medium\n\n$$MESSAGE\n\n -- $$FULLNAME <$$EMAIL>  $$DATE\n" > packaging/deb/$(ARCH)/changelog

changelog-md:
	@echo "# Changelog" > CHANGELOG.md
	@echo "\n## [Unreleased]" >> CHANGELOG.md
	@git log --pretty=format:'- %s (%h)' --no-merges -n 10 >> CHANGELOG.md
	
changelog-deb-dch:
	@if [ -z "$(ARCH)" ]; then \
		echo "❌ Debes especificar ARCH=amd64 o ARCH=arm64"; \
		exit 1; \
	fi
	@if ! command -v dch >/dev/null 2>&1; then \
		echo "❌ 'dch' no está instalado. Instala el paquete 'devscripts'."; \
		exit 1; \
	fi
	dch --changelog packaging/deb/$(ARCH)/changelog

# Actualiza la versión en README.md usando el valor en el archivo control
update-readme-version:
	@VERSION=$$(grep '^Version:' packaging/deb/amd64/control | cut -d' ' -f2); \
	sed -i.bak -E "s|^> Versión actual: .*|> Versión actual: $$VERSION|" README.md; \
	rm -f README.md.bak

lint:
	@if [ -z "$(ARCH)" ]; then \
		echo "❌ Debes especificar ARCH=amd64 o ARCH=arm64"; \
		exit 1; \
	fi
	pwd
	ls -la
	@VERSION=$$(grep "^version" Cargo.toml | head -n1 | cut -d'"' -f2); \
	FULL_VERSION=$${VERSION}-$(REVISION); \
	FILE=$${file:-$(NAME)_$${FULL_VERSION}_$${ARCH}.deb}; \
	if [ -f $$FILE ]; then \
		echo "🔍 Ejecutando lintian sobre $$FILE"; \
		lintian $$FILE; \
	else \
		echo "❌ No se encontró el paquete $$FILE. Ejecuta primero 'make package-deb ARCH=...'"; \
		exit 1; \
	fi

docker-build:
	@if [ -z "$(ARCH)" ]; then \
		echo "❌ Debes especificar ARCH=amd64 o ARCH=arm64"; \
		exit 1; \
	fi
	NO_CACHE_FLAG=$$( [ "$(NO_CACHE)" = "true" ] && echo "--no-cache" ); \
	docker buildx build --platform linux/$(ARCH) $$NO_CACHE_FLAG --build-arg ARCH=$(ARCH) -t curp-verifier-deb-builder -f Dockerfile --load --progress plain .
	docker run --rm -v "$$(pwd)/output:/app/src/rust/curp_verifier" curp-verifier-deb-builder