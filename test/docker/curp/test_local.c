#include <stdio.h>
#include "curp_generator.h"
#include "curp_verifier.h"

//extern int verify_curp(const char* curp); // o el nombre real de tu función

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

    char* resultado = generar_curp_c(&persona);
    printf("CURP generada: %s\n", resultado);

    return 0;
}