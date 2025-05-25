# Nombre del crate
CRATE=curp_verifier
EXT=$(shell uname | grep -q Darwin && echo dylib || echo so)
TARGET=target/release/lib$(CRATE).$(EXT)
HEADER=include/$(CRATE).h

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
	mkdir -p $(if $(DESTDIR),$(DESTDIR)/usr/lib,/usr/lib)
	mkdir -p $(if $(DESTDIR),$(DESTDIR)/usr/include,/usr/include)
	install -m 0755 $(TARGET) $(if $(DESTDIR),$(DESTDIR)/usr/lib,/usr/lib)
	install -m 0644 $(HEADER) $(if $(DESTDIR),$(DESTDIR)/usr/include,/usr/include)

# Empaqueta el binario y el header en un .deb para la arquitectura especificada
package-deb:
	@if [ -z "$(ARCH)" ]; then \
		echo "❌ Debes especificar ARCH=amd64 o ARCH=arm64"; \
		exit 1; \
	fi
	@echo "📦 Empaquetando para arquitectura: $(ARCH)"
	@if [ "$(ARCH)" = "arm64" ]; then \
		cargo build --release --target aarch64-unknown-linux-gnu; \
		cp target/aarch64-unknown-linux-gnu/release/lib$(CRATE).$(EXT) deb_pkg/usr/lib/; \
	else \
		cargo build --release; \
		cp $(TARGET) deb_pkg/usr/lib/; \
	fi
	mkdir -p deb_pkg/usr/lib
	mkdir -p deb_pkg/usr/include
	mkdir -p deb_pkg/DEBIAN
	cp $(HEADER) deb_pkg/usr/include/
	cp packaging/deb/$(ARCH)/control deb_pkg/DEBIAN/control
	mkdir -p deb_pkg/usr/share/doc/curp-verifier
	gzip -c README.md > deb_pkg/usr/share/doc/curp-verifier/README.md.gz
	cp packaging/deb/$(ARCH)/changelog deb_pkg/usr/share/doc/curp-verifier/changelog
	gzip -c packaging/deb/$(ARCH)/changelog > deb_pkg/usr/share/doc/curp-verifier/changelog.Debian.gz
	@VERSION=$$(grep '^Version:' packaging/deb/$(ARCH)/control | cut -d' ' -f2); \
	SIZE=$$(du -ks deb_pkg/usr | cut -f1); \
	DEPENDS=$$(ldd deb_pkg/usr/lib/libcurp_verifier.so | awk '{print $$1}' | grep -E '^lib' | while read -r lib; do dpkg -S "$$lib" 2>/dev/null | cut -d: -f1; done | sort -u | paste -sd "," -); \
	grep -q '^Installed-Size:' deb_pkg/DEBIAN/control && \
		sed -i "s/^Installed-Size:.*/Installed-Size: $$SIZE/" deb_pkg/DEBIAN/control || \
		echo "Installed-Size: $$SIZE" >> deb_pkg/DEBIAN/control; \
	grep -q '^Depends:' deb_pkg/DEBIAN/control && \
		sed -i "s/^Depends:.*/Depends: $$DEPENDS/" deb_pkg/DEBIAN/control || \
		echo "Depends: $$DEPENDS" >> deb_pkg/DEBIAN/control; \
	dpkg-deb --build deb_pkg curp-verifier_$${VERSION}_$(ARCH).deb

changelog-deb:
	@PACKAGE=curp-verifier; \
	VERSION=0.1.0; \
	EMAIL="rafex@rafex.dev"; \
	FULLNAME="Raúl González"; \
	DATE=$$(date -R); \
	MESSAGE=$$(git log -1 --pretty=format:'  * %s'); \
	echo "$$PACKAGE ($$VERSION-1) stable; urgency=medium\n\n$$MESSAGE\n\n -- $$FULLNAME <$$EMAIL>  $$DATE\n" > packaging/deb/amd64/changelog

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
	sed -i.bak "s/^Versión actual: .*$$/Versión actual: $$VERSION/" README.md; \
	rm -f README.md.bak