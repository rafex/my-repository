#include <stdio.h>

// Declaración de struct esperada por la función generar_curp_c
typedef struct {
    const char* nombre;
    const char* primer_apellido;
    const char* segundo_apellido;
    char sexo;
    const char* fecha_nacimiento;
    const char* entidad;
} DatosPersonales;

// Declaraciones FFI manuales (sin includes)
extern int verify_curp(const char* curp);
extern char* generar_curp_c(const DatosPersonales* datos);

int main() {
    //const char* prueba = "GOCJ850528HDFRNL08";  // CURP inválida
    const char* prueba = "GOAR881103HDFNRL04";  // CURP válida
    int valido = verify_curp(prueba);
    printf("Resultado: %d\n", valido);

    if (valido == 1) {
        printf("La CURP es válida.\n");
    } else if (valido == 0) {
        printf("La CURP es inválida.\n");
    } else {
        printf("Error al verificar la CURP.\n");
    }

    struct DatosPersonales persona = {
        .nombre = "RAUL EDUARDO",
        .primer_apellido = "GONZALEZ",
        .segundo_apellido = "ARGOTE",
        .sexo = 'H',
        .fecha_nacimiento = "1988-11-03",
        .entidad = "DF"
    };

    char* curp = generar_curp_c(&persona);
    if (curp != NULL) {
        printf("CURP generada: %s\n", curp);
    } else {
        fprintf(stderr, "Error al generar la CURP.\n");
    }

    return 0;
}