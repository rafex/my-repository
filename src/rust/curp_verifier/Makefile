# Nombre del crate
CRATE=curp_verifier
TARGET=target/release/lib$(CRATE).dylib
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
	install -m 0755 $(TARGET) $(if $(DESTDIR),$(DESTDIR)/usr/lib,/usr/lib)
	install -m 0644 $(HEADER) $(if $(DESTDIR),$(DESTDIR)/usr/include,/usr/include)

# Empaqueta el binario y el header en un .deb para amd64
package-deb: all
	mkdir -p deb_pkg/usr/lib
	mkdir -p deb_pkg/usr/include
	mkdir -p deb_pkg/DEBIAN
	cp $(TARGET) deb_pkg/usr/lib/
	cp $(HEADER) deb_pkg/usr/include/
	cp packaging/deb/amd64/control deb_pkg/DEBIAN/control
	dpkg-deb --build deb_pkg curp-verifier-amd64.deb

# Empaqueta para ARM64
package-deb-arm64:
	cargo build --release --target aarch64-unknown-linux-gnu
	mkdir -p deb_pkg/usr/lib
	mkdir -p deb_pkg/usr/include
	mkdir -p deb_pkg/DEBIAN
	cp target/aarch64-unknown-linux-gnu/release/lib$(CRATE).* deb_pkg/usr/lib/
	cp $(HEADER) deb_pkg/usr/include/
	cp packaging/deb/arm64/control deb_pkg/DEBIAN/control
	dpkg-deb --build deb_pkg curp-verifier-arm64.deb