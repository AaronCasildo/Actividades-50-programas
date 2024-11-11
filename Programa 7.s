
/***********************************************************************
* Programa: Cálculo del Factorial en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Solicita un número entero N al usuario y calcula su 
*              factorial. Si N es negativo, muestra un mensaje de error.
*              Implementado en ARM64 Assembly para RaspbianOS.
* 
* Compilación:
*    as -o factorial.o factorial.s
*    gcc -o factorial factorial.o -no-pie
*
* Ejecución:
*    ./factorial
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long N, factorial = 1;
*     printf("Ingrese un número para calcular su factorial: ");
*     scanf("%ld", &N);
*     if (N < 0) {
*         printf("Error: No existe factorial de números negativos\n");
*         return 1;
*     }
*     for (long i = 1; i <= N; i++) {
*         factorial *= i;
*     }
*     printf("El factorial de %ld es: %ld\n", N, factorial);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/HdbawAoMHckCWxqyTljAzPR7F
***********************************************************************/

.data
msg_prompt:    .asciz "Ingrese un número para calcular su factorial: "
msg_result:    .asciz "El factorial de %ld es: %ld\n"
msg_error:     .asciz "Error: No existe factorial de números negativos\n"
fmt_int:       .asciz "%ld"

.text
.global main

main:
    // Prólogo
    stp x29, x30, [sp, -16]!       // Guarda el frame pointer y link register
    mov x29, sp                    // Establece el frame pointer
    sub sp, sp, #16                // Reserva espacio para variables locales

    // Solicitar número N
    ldr x0, =msg_prompt            // Carga el mensaje de entrada
    bl printf                      // Imprime el mensaje

    // Leer N
    ldr x0, =fmt_int               // Formato de entrada para scanf
    mov x1, sp                     // Dirección donde guardar N
    bl scanf                       // Lee el valor de N

    // Verificar si N es negativo
    ldr x19, [sp]                  // x19 = N (número ingresado)
    cmp x19, #0                    // Compara N con 0
    blt error_negative             // Si N < 0, mostrar error

    // Inicializar variables para cálculo del factorial
    mov x20, #1                    // x20 = factorial = 1
    mov x21, #1                    // x21 = i = 1

factorial_loop:
    cmp x21, x19                   // Compara i con N
    bgt end_loop                   // Si i > N, salir del loop

    mul x20, x20, x21              // factorial *= i
    add x21, x21, #1               // i++
    b factorial_loop               // Vuelve al inicio del loop

error_negative:
    // Mostrar mensaje de error para números negativos
    ldr x0, =msg_error             // Carga mensaje de error
    bl printf                      // Imprime el mensaje de error
    mov x0, #1                     // Código de error
    b end_program                  // Salta al final del programa

end_loop:
    // Imprimir resultado del factorial
    ldr x0, =msg_result            // Carga el mensaje de resultado
    mov x1, x19                    // Primer argumento (N)
    mov x2, x20                    // Segundo argumento (factorial)
    bl printf                      // Imprime el resultado
    mov x0, #0                     // Código de éxito

end_program:
    // Epílogo y retorno
    mov sp, x29                    // Restaura el stack pointer
    ldp x29, x30, [sp], #16        // Restaura el frame pointer y link register
    ret                            // Retorna al sistema operativo
