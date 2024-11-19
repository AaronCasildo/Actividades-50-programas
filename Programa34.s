/***********************************************************************
* Programa: Inversión de Elementos en un Arreglo
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa muestra los elementos de un arreglo en su 
*              orden original, luego invierte el orden de los elementos 
*              en el arreglo y los imprime nuevamente. La inversión se 
*              realiza mediante intercambio de elementos desde los extremos 
*              hacia el centro del arreglo.
*
* Compilación:
*    as -o invertir_arreglo.o invertir_arreglo.s
*    gcc -o invertir_arreglo invertir_arreglo.o -no-pie
*
* Ejecución:
*    ./invertir_arreglo
*
* Explicación del flujo:
* - format_antes: Mensaje que indica el inicio de la impresión del arreglo original.
* - format_despues: Mensaje que indica el inicio de la impresión del arreglo invertido.
* - format_elemento: Cadena de formato que muestra cada elemento y su índice en el arreglo.
* - array: Arreglo de enteros con los elementos a invertir.
* - array_size: Tamaño del arreglo (número de elementos).
* - x19: Índice inicial para el proceso de inversión (inicio).
* - x20: Índice final para el proceso de inversión (fin).
* - x21: Dirección base del arreglo.
* - x22: Tamaño del arreglo (número de elementos).
* - w23, w24: Registros temporales que almacenan los valores de los elementos a intercambiar.
*
* Funciones:
* - main: Controla el flujo principal del programa, muestra el arreglo original, 
*         invierte los elementos y muestra el arreglo invertido.
* - print_original: Bucle que recorre el arreglo original y muestra cada elemento en su posición.
* - start_inversion: Configura los índices `inicio` y `fin` para comenzar el proceso de inversión.
* - loop_inversion: Bucle que intercambia los elementos de los extremos del arreglo, avanzando hacia el centro.
* - print_invertido: Muestra el arreglo después de haber sido invertido.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int array[] = {1, 2, 3, 4, 5, 6, 7, 8};
*     int array_size = 8;
*     
*     printf("\nArreglo original:\n");
*     for (int i = 0; i < array_size; i++) {
*         printf("Elemento[%d] = %d\n", i, array[i]);
*     }
*     
*     // Invertir el arreglo
*     for (int inicio = 0, fin = array_size - 1; inicio < fin; inicio++, fin--) {
*         int temp = array[inicio];
*         array[inicio] = array[fin];
*         array[fin] = temp;
*     }
*     
*     printf("\nArreglo invertido:\n");
*     for (int i = 0; i < array_size; i++) {
*         printf("Elemento[%d] = %d\n", i, array[i]);
*     }
*     
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/ZtKkEzPXv8aiZftTLHu6hd35E
* Link de grabación gdb:
* https://asciinema.org/a/bIdeVpXQjxO6yRXEAu6wLKKEK
***********************************************************************/


.section .rodata
format_antes: .asciz "\nArreglo original:\n"
format_despues: .asciz "\nArreglo invertido:\n"
format_elemento: .asciz "Elemento[%d] = %d\n"

.section .data
array: .word 1, 2, 3, 4, 5, 6, 7, 8    // Arreglo de 8 elementos
array_size: .word 8                     // Tamaño del arreglo

.text
.global main
.type main, %function

main:
    // Prólogo de la función
    stp     x29, x30, [sp, -16]!   // Guardar frame pointer y link register
    mov     x29, sp                 // Establecer frame pointer

    // Guardar registros callee-saved
    stp     x19, x20, [sp, -16]!   // x19 = inicio, x20 = fin
    stp     x21, x22, [sp, -16]!   // x21 = dirección base, x22 = tamaño

    // Cargar dirección del arreglo y su tamaño
    adrp    x21, array
    add     x21, x21, :lo12:array   // x21 = dirección base del arreglo
    adrp    x22, array_size
    add     x22, x22, :lo12:array_size
    ldr     w22, [x22]             // w22 = tamaño del arreglo

    // Imprimir mensaje "Arreglo original"
    adrp    x0, format_antes
    add     x0, x0, :lo12:format_antes
    bl      printf

    // Mostrar arreglo original
    mov     x20, #0                // contador = 0
print_original:
    cmp     x20, x22
    b.ge    start_inversion

    // Imprimir elemento actual
    adrp    x0, format_elemento
    add     x0, x0, :lo12:format_elemento
    mov     x1, x20                // índice
    ldr     w2, [x21, x20, lsl #2] // valor
    bl      printf

    add     x20, x20, #1          // contador++
    b       print_original

start_inversion:
    // Inicializar índices para inversión
    mov     x19, #0               // inicio = 0
    sub     x20, x22, #1          // fin = tamaño - 1

loop_inversion:
    // Verificar si hemos terminado
    cmp     x19, x20
    b.ge    print_invertido

    // Cargar elementos a intercambiar
    ldr     w23, [x21, x19, lsl #2]  // temp1 = array[inicio]
    ldr     w24, [x21, x20, lsl #2]  // temp2 = array[fin]

    // Intercambiar elementos
    str     w24, [x21, x19, lsl #2]  // array[inicio] = temp2
    str     w23, [x21, x20, lsl #2]  // array[fin] = temp1

    // Actualizar índices
    add     x19, x19, #1          // inicio++
    sub     x20, x20, #1          // fin--
    b       loop_inversion

print_invertido:
    // Imprimir mensaje "Arreglo invertido"
    adrp    x0, format_despues
    add     x0, x0, :lo12:format_despues
    bl      printf

    // Mostrar arreglo invertido
    mov     x20, #0               // contador = 0
print_final:
  cmp     x20, x22
    b.ge    end

    // Imprimir elemento actual
    adrp    x0, format_elemento
    add     x0, x0, :lo12:format_elemento
    mov     x1, x20               // índice
    ldr     w2, [x21, x20, lsl #2] // valor
    bl      printf

    add     x20, x20, #1         // contador++
    b       print_final

end:
    // Restaurar registros
    ldp     x21, x22, [sp], 16
    ldp     x19, x20, [sp], 16

    // Epílogo de la función
    mov     w0, #0               // Valor de retorno
    ldp     x29, x30, [sp], 16
    ret

.size main, .-main
