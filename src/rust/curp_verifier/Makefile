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
	sudo install -m 0755 $(TARGET) /usr/lib/
	sudo install -m 0644 $(HEADER) /usr/include/