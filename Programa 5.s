/***********************************************************************
* Programa: División de Dos Números en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Solicita dos números enteros al usuario, realiza la división
*              del primer número entre el segundo y muestra el resultado
*              en pantalla usando ARM64 Assembly en RaspbianOS. Verifica
*              la división por cero e imprime un mensaje de error si es el caso.
* 
* Compilación:
*    as -o division.o division.s
*    gcc -o division division.o -no-pie
*
* Ejecución:
*    ./division
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long num1, num2, division;
*     printf("Ingresa el primer número: ");
*     scanf("%ld", &num1);
*     printf("Ingresa el segundo número: ");
*     scanf("%ld", &num2);
*     if (num2 == 0) {
*         printf("Error: División por cero\n");
*     } else {
*         division = num1 / num2;
*         printf("División: %ld\n", division);
*     }
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/hOhwgAOuwaZ3yRUqvkeQSRY0X
***********************************************************************/

.data
msg_prompt1:   .asciz "Ingresa el primer número: "
msg_prompt2:   .asciz "Ingresa el segundo número: "
msg_div:       .asciz "División: %ld\n"
msg_div_zero:  .asciz "Error: División por cero\n"
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

    // Verificar división por cero y realizar operación
    ldr x0, [sp]                   // Carga el primer número
    ldr x1, [sp, #8]               // Carga el segundo número
    cmp x1, #0                     // Compara el segundo número con 0
    b.eq div_by_zero               // Si es 0, salta a manejo de error
    udiv x2, x0, x1                // Realiza la división entera sin signo
    ldr x0, =msg_div               // Carga el mensaje de resultado
    mov x1, x2                     // Prepara el resultado para imprimir
    bl printf                      // Imprime el resultado de la división
    b end                          // Salta al final del programa

div_by_zero:
    ldr x0, =msg_div_zero          // Carga el mensaje de error por división por cero
    bl printf                      // Imprime el mensaje de error

end:
    // Epílogo y retorno
    add sp, sp, #16                // Limpia el espacio en la pila
    ldp x29, x30, [sp], 16         // Restaura el frame pointer y link register
    ret                            // Retorna del programa
