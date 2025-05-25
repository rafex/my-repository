

# curp_verifier

Este proyecto implementa en Rust el algoritmo de verificación del **dígito verificador de la CURP**, conforme a lo estipulado en el [Instructivo Normativo para la Asignación de la Clave Única de Registro de Población](https://curp.readthedocs.io/es/latest/instructivo/verificacion.html) y publicado oficialmente en el Diario Oficial de la Federación (DOF) el 18 de octubre de 2021.

## Origen de la especificación

El algoritmo que usamos está sustentado por:
- [Instructivo en línea](https://curp.readthedocs.io/es/latest/instructivo/verificacion.html)
- [DOF 18-10-2021 - Instructivo Normativo para la Asignación de la CURP](https://www.dof.gob.mx/nota_detalle.php?codigo=5638826&fecha=18/10/2021)

## Algoritmo del dígito verificador (resumen)

La CURP es una clave alfanumérica de 18 caracteres. El **último carácter (posición 18)** se calcula con base en los primeros 17 mediante una suma ponderada, como sigue:

1. A cada carácter se le asigna un valor numérico según una tabla de equivalencias.
2. Cada valor se multiplica por su peso, decreciendo desde 17 hasta 1.
3. Se suman los productos.
4. Se obtiene el residuo de la división entre 10.
5. El dígito verificador es `0` si el residuo es `0`; en otro caso, es `10 - residuo`.

Este dígito sirve para validar que la CURP no tenga errores de captura.

## Tabla de equivalencias usada (extraída del instructivo del DOF)

| Carácter | Valor |
|----------|-------|
| 0-9      | 0-9   |
| A        | 10    |
| B        | 11    |
| C        | 12    |
| D        | 13    |
| E        | 14    |
| F        | 15    |
| G        | 16    |
| H        | 17    |
| I        | 18    |
| J        | 19    |
| K        | 20    |
| L        | 21    |
| M        | 22    |
| N        | 23    |
| Ñ        | 24    |
| O        | 25    |
| P        | 26    |
| Q        | 27    |
| R        | 28    |
| S        | 29    |
| T        | 30    |
| U        | 31    |
| V        | 32    |
| W        | 33    |
| X        | 34    |
| Y        | 35    |
| Z        | 36    |

Este repositorio incluye pruebas para validar CURPs correctamente y garantiza que la validación esté alineada con el marco legal actual.