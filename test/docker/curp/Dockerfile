FROM debian:stable

RUN apt-get update && apt-get install -y curl gnupg ca-certificates

# Evita errores por firmas
RUN echo "deb [trusted=yes] https://repository.rafex.app/debian stable main" > /etc/apt/sources.list.d/rafex.list

RUN apt-get update && apt-get install -y curp-verifier

CMD ["ls", "-l", "/usr/lib/libcurp_verifier.so"]