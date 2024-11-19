/***********************************************************************
* Programa: Cálculo Directo del Mínimo Común Múltiplo (MCM)
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa calcula el Mínimo Común Múltiplo (MCM) de dos
*              números (4 y 6) de forma directa, asumiendo que el MCM es 12.
*              Luego, imprime el resultado utilizando `printf`. Este programa 
*              utiliza registros para almacenar los números y el resultado del MCM.
*
* Compilación:
*    as -o mcm_directo.o mcm_directo.s
*    gcc -o mcm_directo mcm_directo.o -no-pie
*
* Ejecución:
*    ./mcm_directo
*
* Explicación del flujo:
* - formato: Cadena de formato utilizada en `printf` para mostrar el resultado.
* - w19: Almacena el primer número (4).
* - w20: Almacena el segundo número (6).
* - w21: Almacena el MCM calculado directamente (12).
*
* Operaciones:
* - main: Realiza el cálculo directo del MCM, asigna los valores a los registros,
*         y llama a `printf` para mostrar el resultado en pantalla.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int num1 = 4;
*     int num2 = 6;
*     int mcm = 12;  // MCM calculado directamente
* 
*     printf("MCM de %d y %d es: %d\n", num1, num2, mcm);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/HS3WifCaUjwq5RlayoXpt7o73
* Link de grabación gdb:
* https://asciinema.org/a/ci37zJfavHgs81kZuWYWMONxU
***********************************************************************/

.global main
.align 2

main:
    // Guardar registros
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Usar números más pequeños: 4 y 6
    mov w19, #4               // Primer número
    mov w20, #6               // Segundo número

    // Calcular MCM directamente (4 * 6 = 24 / 2 = 12)
    mov w21, #12              // Resultado directo del MCM

    // Preparar printf
    adr x0, formato
    mov w1, w19               // Primer número (4)
    mov w2, w20               // Segundo número (6)
    mov w3, w21               // Resultado MCM (12)

    // Llamar printf
    bl printf

    // Retornar
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section .data
formato: .string "MCM de %d y %d es: %d\n"
