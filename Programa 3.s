/***********************************************************************
* Programa: Resta de Dos Números en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Solicita dos números enteros al usuario, realiza la resta
*              del primer número menos el segundo y muestra el resultado
*              en pantalla usando ARM64 Assembly en RaspbianOS.
* 
* Compilación:
*    as -o resta.o resta.s
*    gcc -o resta resta.o -no-pie
*
* Ejecución:
*    ./resta
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long num1, num2, resta;
*     printf("Ingresa el primer número: ");
*     scanf("%ld", &num1);
*     printf("Ingresa el segundo número: ");
*     scanf("%ld", &num2);
*     resta = num1 - num2;
*     printf("Resta: %ld\n", resta);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/FRH1dEhzOqFrLZfsTXWFJfbGp
* Link corrida con gdb:
* https://asciinema.org/a/gtVsJtiEoiFrzAeLrWUifkaRO
***********************************************************************/

.data
msg_prompt1:   .asciz "Ingresa el primer número: "
msg_prompt2:   .asciz "Ingresa el segundo número: "
msg_sub:       .asciz "Resta: %ld\n"
fmt_int:       .asciz "%ld"

.text
.global main

main:
    // Prólogo
    stp x29, x30, [sp, -16]!       // Guarda el frame pointer y link register
    mov x29, sp                    // Establece el frame pointer
    sub sp, sp, #16                // Reserva espacio en la pila para dos enteros

    // Solicitar primer número
    ldr x0, =msg_prompt1           // Carga el mensaje del primer número
    bl printf                      // Llama a printf para mostrar el mensaje
    ldr x0, =fmt_int               // Formato de entrada de scanf
    mov x1, sp                     // Dirección donde guardar el primer número
    bl scanf                       // Lee el primer número

    // Solicitar segundo número
    ldr x0, =msg_prompt2           // Carga el mensaje del segundo número
    bl printf                      // Llama a printf para mostrar el mensaje
    ldr x0, =fmt_int               // Formato de entrada de scanf
    add x1, sp, #8                 // Dirección donde guardar el segundo número
    bl scanf                       // Lee el segundo número

    // Realizar resta y mostrar resultado
    ldr x0, [sp]                   // Carga el primer número
    ldr x1, [sp, #8]               // Carga el segundo número
    sub x2, x0, x1                 // Resta el segundo número del primero
    ldr x0, =msg_sub               // Carga el mensaje de salida
    mov x1, x2                     // Prepara el resultado para imprimir
    bl printf                      // Imprime la resta

    // Epílogo y retorno
    add sp, sp, #16                // Limpia el espacio en la pila
    ldp x29, x30, [sp], 16         // Restaura el frame pointer y link register
    ret                            // Retorna del programa
