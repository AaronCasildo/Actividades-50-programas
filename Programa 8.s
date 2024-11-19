/***********************************************************************
* Programa: Verificación de Número Primo en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Solicita un número entero al usuario y verifica si el número
*              es primo. Si es primo, muestra un mensaje indicando que el 
*              número es primo; en caso contrario, muestra que no es primo.
*              Implementado en ARM64 Assembly para RaspbianOS.
* 
* Compilación:
*    as -o es_primo.o es_primo.s
*    gcc -o es_primo es_primo.o -no-pie
*
* Ejecución:
*    ./es_primo
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long n;
*     printf("Ingrese un número para verificar si es primo: ");
*     scanf("%ld", &n);
*     
*     if (n <= 1) {
*         printf("%ld no es un número primo\n", n);
*         return 0;
*     }
*     
*     for (long i = 2; i * i <= n; i++) {
*         if (n % i == 0) {
*             printf("%ld no es un número primo\n", n);
*             return 0;
*         }
*     }
*     printf("%ld es un número primo\n", n);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/G0Q561ThzXzkBG3yOH7oYiR7s
* Link corrida con gdb:
* https://asciinema.org/a/OFcrHkUsoUkPb71QYpGFlXgeJ
***********************************************************************/

.data
msg_prompt:    .asciz "Ingrese un número para verificar si es primo: "
msg_es_primo:  .asciz "%ld es un número primo\n"
msg_no_primo:  .asciz "%ld no es un número primo\n"
fmt_int:       .asciz "%ld"

.text
.global main

main:
    // Prólogo
    stp x29, x30, [sp, -16]!       // Guarda el frame pointer y link register
    mov x29, sp                    // Establece el frame pointer
    sub sp, sp, #16                // Reserva espacio para variables locales

    // Solicitar número
    ldr x0, =msg_prompt            // Carga el mensaje de entrada
    bl printf                      // Imprime el mensaje

    // Leer número
    ldr x0, =fmt_int               // Formato de entrada para scanf
    mov x1, sp                     // Dirección donde guardar el número
    bl scanf                       // Lee el número ingresado

    // Cargar número en x19
    ldr x19, [sp]                  // x19 = número ingresado

    // Verificar si es menor o igual a 1
    cmp x19, #1
    ble no_primo                   // Si N <= 1, no es primo

    // Inicializar variables para el bucle
    mov x20, #2                    // x20 = i = 2 (divisor inicial)

check_loop:
    // Comparar i * i con n
    mul x21, x20, x20              // x21 = i * i
    cmp x21, x19                   // Compara i * i con n
    bgt es_primo                   // Si i * i > n, es primo

    // Verificar si es divisible por i
    udiv x22, x19, x20             // x22 = n / i
    mul x22, x22, x20              // x22 = (n / i) * i
    cmp x22, x19                   // Compara el resultado con n
    beq no_primo                   // Si son iguales, encontramos un divisor

    // Incrementar i y continuar el bucle
    add x20, x20, #1               // i++
    b check_loop                   // Vuelve al inicio del bucle

es_primo:
    // Imprimir mensaje de número primo
    ldr x0, =msg_es_primo          // Carga el mensaje de número primo
    mov x1, x19                    // Pasa el número como argumento
    bl printf                      // Imprime mensaje
    b end_program                  // Salta al final del programa

no_primo:
    // Imprimir mensaje de número no primo
    ldr x0, =msg_no_primo          // Carga el mensaje de número no primo
    mov x1, x19                    // Pasa el número como argumento
    bl printf                      // Imprime mensaje

end_program:
    // Epílogo y retorno
    mov sp, x29                    // Restaura el stack pointer
    ldp x29, x30, [sp], #16        // Restaura el frame pointer y link register
    mov x0, #0                     // Código de retorno 0
    ret                            // Retorna al sistema operativo
