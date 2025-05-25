

# Nombre del crate
CRATE=curp_verifier
TARGET=target/release/lib$(CRATE).dylib
HEADER=include/$(CRATE).h

.PHONY: all build clean cbindgen install

# Compila el proyecto en modo release
build:
	cargo build --release

# Genera el archivo .h con cbindgen
cbindgen:
	cbindgen --crate $(CRATE) --output $(HEADER)

# Compila y genera el header
all: build cbindgen

# Limpia la compilación
clean:
	cargo clean

# Instala la librería y el header (requiere sudo)
install:
	sudo install -m 0755 $(TARGET) /usr/lib/
	sudo install -m 0644 $(HEADER) /usr/include/