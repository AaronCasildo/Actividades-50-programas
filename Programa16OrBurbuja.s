/***********************************************************************
* Programa: Ordenación de un Arreglo con el Algoritmo de Bubble Sort
* Autor: Aaron Casildo Rubalcava
* Descripción: Implementa el algoritmo de Bubble Sort en un arreglo desordenado
*              e imprime el estado del arreglo en cada paso. Se intercambian
*              elementos cuando están desordenados y se repite el proceso
*              hasta que el arreglo esté completamente ordenado.
* 
* Compilación:
*    as -o bubble_sort.o bubble_sort.s
*    gcc -o bubble_sort bubble_sort.o -no-pie
*
* Ejecución:
*    ./bubble_sort
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* void imprimir_arreglo(long arreglo[], long longitud) {
*     for (long i = 0; i < longitud; i++) {
*         printf("%ld ", arreglo[i]);
*     }
*     printf("\n");
* }
* 
* int main() {
*     long arreglo[] = {45, 23, 11, 15, 6, 18, 7, 3, 12, 9};
*     long longitud = 10;
*     long paso = 1;
* 
*     // Imprimir arreglo original
*     printf("Arreglo original: ");
*     imprimir_arreglo(arreglo, longitud);
* 
*     // Algoritmo Bubble Sort
*     for (long i = 0; i < longitud - 1; i++) {
*         printf("Paso %ld: ", paso++);
*         for (long j = 0; j < longitud - 1 - i; j++) {
*             if (arreglo[j] > arreglo[j + 1]) {
*                 printf("Intercambiando posiciones %ld y %ld (%ld <-> %ld)\n", j, j + 1, arreglo[j], arreglo[j + 1]);
*                 long temp = arreglo[j];
*                 arreglo[j] = arreglo[j + 1];
*                 arreglo[j + 1] = temp;
*             }
*         }
*         imprimir_arreglo(arreglo, longitud);
*     }
* 
*     // Imprimir arreglo final
*     printf("Arreglo ordenado: ");
*     imprimir_arreglo(arreglo, longitud);
* 
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/sxGvzFSeG2b1MZ70XPjvCg3xR
***********************************************************************/

.data
    arreglo:    .quad   45, 23, 11, 15, 6, 18, 7, 3, 12, 9  // Arreglo desordenado
    longitud:   .quad   10                                   // Longitud del arreglo
    msg_inicio: .asciz  "Arreglo original: "
    msg_paso:   .asciz  "\nPaso %d: "
    msg_num:    .asciz  "%ld "
    msg_swap:   .asciz  "\nIntercambiando posiciones %d y %d (%ld <-> %ld)\n"
    msg_final:  .asciz  "\nArreglo ordenado: "
    newline:    .asciz  "\n"

.text
.global main
main:
    // Prólogo
    stp     x29, x30, [sp, -64]!
    mov     x29, sp

    // Imprimir arreglo original
    ldr     x0, =msg_inicio
    bl      printf
    bl      imprimir_arreglo

    // Inicializar variables para bubble sort
    mov     x19, #0              // i = 0
    ldr     x20, =longitud       
    ldr     x20, [x20]           // x20 = longitud
    sub     x20, x20, #1         // x20 = longitud - 1
    ldr     x21, =arreglo        // x21 = dirección base del arreglo
    mov     x28, #1              // contador de pasos

outer_loop:
    cmp     x19, x20             // compara i con (n-1)
    bge     sort_done            // si i >= n-1, terminar
    
    // Imprimir número de paso
    ldr     x0, =msg_paso
    mov     w1, w28              // Número de paso
    bl      printf
    
    mov     x22, #0              // j = 0
    sub     x23, x20, x19        // x23 = (n-1) - i

inner_loop:
    cmp     x22, x23             // compara j con (n-1-i)
    bge     next_outer           // si j >= n-1-i, siguiente iteración externa
    
    // Cargar elementos a comparar
    lsl     x24, x22, #3         // x24 = j * 8 (offset para quad word)
    ldr     x26, [x21, x24]      // x26 = arreglo[j]
    add     x24, x24, #8         // siguiente elemento
    ldr     x27, [x21, x24]      // x27 = arreglo[j+1]
    sub     x24, x24, #8         // volver al elemento actual
    
    // Comparar elementos
    cmp     x26, x27
    ble     no_swap              // si arreglo[j] <= arreglo[j+1], no intercambiar
    
    // Intercambiar elementos
    str     x27, [x21, x24]      // arreglo[j] = arreglo[j+1]
    add     x24, x24, #8
    str     x26, [x21, x24]      // arreglo[j+1] = temp
    
    // Imprimir mensaje de intercambio
    stp     x19, x20, [sp, #16]  // Guardar registros
    stp     x21, x22, [sp, #32]
    
    ldr     x0, =msg_swap
    mov     w1, w22              // posición j
    add     w2, w22, #1          // posición j+1
    mov     x3, x26              // valor original
    mov     x4, x27              // valor a intercambiar
    bl      printf
    
    bl      imprimir_arreglo
    
    ldp     x19, x20, [sp, #16]  // Restaurar registros
    ldp     x21, x22, [sp, #32]

no_swap:
    add     x22, x22, #1         // j++
    b       inner_loop

next_outer:
    add     x19, x19, #1         // i++
    add     x28, x28, #1         // incrementar contador de pasos
    b       outer_loop

sort_done:
    // Imprimir resultado final
    ldr     x0, =msg_final
    bl      printf
    bl      imprimir_arreglo
    
    // Imprimir nueva línea final
    ldr     x0, =newline
    bl      printf
    
    // Epílogo y retorno
    mov     w0, #0
    ldp     x29, x30, [sp], 64
    ret

// Subrutina para imprimir el arreglo completo
imprimir_arreglo:
    stp     x29, x30, [sp, -32]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]  // Guardar registros que usaremos
    
    mov     x19, #0              // i = 0
    ldr     x20, =longitud
    ldr     x20, [x20]           // cargar longitud

print_loop:
    cmp     x19, x20
    bge     print_done
    
    // Imprimir número actual
    ldr     x0, =msg_num
    ldr     x21, =arreglo
    ldr     x1, [x21, x19, lsl #3]  // cargar arreglo[i]
    bl      printf
    
    add     x19, x19, #1         // i++
    b       print_loop

print_done:
    ldp     x19, x20, [sp, #16]  // Restaurar registros
    ldp     x29, x30, [sp], 32
    ret
