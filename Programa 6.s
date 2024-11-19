/***********************************************************************
* Programa: Suma de los Primeros N Números en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Solicita un número entero N al usuario y calcula la suma de 
*              los primeros N números naturales. Muestra el resultado en 
*              pantalla usando ARM64 Assembly en RaspbianOS.
* 
* Compilación:
*    as -o suma_n.o suma_n.s
*    gcc -o suma_n suma_n.o -no-pie
*
* Ejecución:
*    ./suma_n
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long N, sum = 0;
*     printf("Ingrese un número N: ");
*     scanf("%ld", &N);
*     for (long i = 1; i <= N; i++) {
*         sum += i;
*     }
*     printf("La suma de los primeros %ld números es: %ld\n", N, sum);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/tqJx6cF0jXSk3QeEe0bcRFZVU
* Link corrida con gdb:
* https://asciinema.org/a/gTdDHZdk5bIIwoAQwOBZkDfNM
***********************************************************************/

.data
msg_prompt:    .asciz "Ingrese un número N: "
msg_result:    .asciz "La suma de los primeros %ld números es: %ld\n"
fmt_int:       .asciz "%ld"

.text
.global main

main:
    // Prólogo
    stp x29, x30, [sp, -16]!      // Guarda el frame pointer y link register
    mov x29, sp                   // Establece el frame pointer
    sub sp, sp, #16               // Reserva espacio para variables locales

    // Solicitar número N
    ldr x0, =msg_prompt           // Carga el mensaje de entrada
    bl printf                     // Imprime el mensaje

    // Leer N
    ldr x0, =fmt_int              // Formato de entrada para scanf
    mov x1, sp                    // Dirección donde guardar N
    bl scanf                      // Lee el valor de N

    // Inicializar variables
    ldr x19, [sp]                 // x19 = N (número ingresado)
    mov x20, #0                   // x20 = sum = 0
    mov x21, #1                   // x21 = i = 1

loop:
    cmp x21, x19                  // Compara i con N
    bgt end_loop                  // Si i > N, salir del loop

    add x20, x20, x21             // sum += i
    add x21, x21, #1              // i++
    b loop                        // Volver al inicio del loop

end_loop:
    // Imprimir resultado
    ldr x0, =msg_result           // Cargar el formato del mensaje de salida
    mov x1, x19                   // Primer argumento (N)
    mov x2, x20                   // Segundo argumento (sum)
    bl printf                     // Imprime el resultado

    // Epílogo
    mov sp, x29                   // Restaura el stack pointer
    ldp x29, x30, [sp], #16       // Restaura el frame pointer y link register
    
    // Retornar
    mov x0, #0                    // Código de retorno 0
    ret                           // Retorna al sistema operativo
