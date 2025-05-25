#ifndef CURP_GENERATOR_H
#define CURP_GENERATOR_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif


/* Generated with cbindgen:0.29.0 */

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct DatosPersonales {
  const char *nombre;
  const char *primer_apellido;
  const char *segundo_apellido;
  char sexo;
  const char *fecha_nacimiento;
  const char *entidad;
} DatosPersonales;

char *generar_curp_c(const struct DatosPersonales *datos);

#ifdef __cplusplus
}
#endif

#endif // CURP_GENERATOR_H
