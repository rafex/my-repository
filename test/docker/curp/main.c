#include <stdio.h>

extern int verificar_curp(const char* curp); // o el nombre real de tu función

int main() {
    //const char* prueba = "GOCJ850528HDFRNL08";  // CURP inválida
    const char* prueba = "GOAR881103HDFNRL04";  // CURP válida
    int valido = verificar_curp(prueba);
    printf("Resultado: %d\n", valido);
    return 0;
}