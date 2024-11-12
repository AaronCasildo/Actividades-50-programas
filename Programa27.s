/***********************************************************************
* Programa: Desplazamiento de Bits
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa realiza desplazamientos de bits en un número 
*              dado y muestra los resultados. Utiliza instrucciones LSL y LSR 
*              para realizar desplazamientos a la izquierda y derecha. 
*              Primero muestra el valor original, luego el resultado tras 
*              desplazar a la izquierda y, finalmente, tras desplazar a la derecha.
* 
* Compilación:
*    as -o desplazamiento_bits.o desplazamiento_bits.s
*    gcc -o desplazamiento_bits desplazamiento_bits.o -no-pie
*
* Ejecución:
*    ./desplazamiento_bits
*
* Explicación del flujo:
* - msg1: Mensaje que muestra el valor original.
* - msg2: Mensaje que muestra el valor tras desplazamiento a la izquierda (multiplicación por 4).
* - msg3: Mensaje que muestra el valor tras desplazamiento a la derecha (división por 2).
* - x19: Registro que almacena el valor original para aplicar los desplazamientos.
* - x20: Registro que almacena el resultado del desplazamiento a la izquierda.
* - x21: Registro que almacena el resultado del desplazamiento a la derecha.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int original = 8;
*     printf("Valor original: %d\n", original);
* 
*     // Desplazamiento a la izquierda
*     int left_shift = original << 2;
*     printf("Después de desplazamiento a la izquierda (x2): %d\n", left_shift);
* 
*     // Desplazamiento a la derecha
*     int right_shift = original >> 1;
*     printf("Después de desplazamiento a la derecha (÷2): %d\n", right_shift);
*     
*     return 0;
* }
*
* Link de grabación:
* https://asciinema.org/a/FkEVrKGAtDF9CGMRacmIw8vev
***********************************************************************/

.global main
.text

main:
    // Guardamos el link register
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Inicializamos un número para hacer los desplazamientos
    mov     x19, #8        // x19 = 8 (1000 en binario)

    // Imprimir valor original
    adr     x0, msg1
    mov     x1, x19
    bl      printf

    // Desplazamiento a la izquierda por 2 posiciones (LSL)
    lsl     x20, x19, #2     // x20 = x19 << 2
    
    // Imprimir resultado del desplazamiento a la izquierda
    adr     x0, msg2
    mov     x1, x20
    bl      printf

    // Desplazamiento a la derecha por 1 posición (LSR)
    lsr     x21, x19, #1     // x21 = x19 >> 1
    
    // Imprimir resultado del desplazamiento a la derecha
    adr     x0, msg3
    mov     x1, x21
    bl      printf

    // Restauramos el stack y retornamos
    ldp     x29, x30, [sp], #16
    mov     w0, #0
    ret

.section .rodata
msg1:
    .string "Valor original: %d\n"
msg2:
    .string "Después de desplazamiento a la izquierda (x2): %d\n"
msg3:
    .string "Después de desplazamiento a la derecha (÷2): %d\n"
