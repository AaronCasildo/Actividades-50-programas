/*******************************************************************************
* Nombre: Aaron Casildo Rubalcava
* Fecha: 7/11/24
* Descripción: Implementación de Merge Sort en ensamblador ARM64.
* El programa toma un array, lo ordena usando el método de ordenación por mezcla
* y lo muestra en pantalla antes y después de la ordenación.
*
* Pseudocódigo (en C para referencia):
* 
* #include <stdio.h>
* #define SIZE 8
* void print_array(long *array, int n);
* void merge_sort(long *array, long *temp, int left, int right);
* void merge(long *array, long *temp, int left, int mid, int right);
*
* int main() {
*   long array[SIZE] = {64, 34, 25, 12, 22, 11, 90, 1};
*   long temp[SIZE];
*   printf("Array original:\n");
*   print_array(array, SIZE);
*   merge_sort(array, temp, 0, SIZE - 1);
*   printf("Array ordenado:\n");
*   print_array(array, SIZE);
*   return 0;
* }
* 
*******************************************************************************/

.data
array:      .quad   64, 34, 25, 12, 22, 11, 90, 1    // Array inicial
temp:       .fill   8, 8, 0                          // Array temporal para merge
n:          .quad   8                                // Tamaño del array
fmt_str:    .string "%ld "                           // Formato para imprimir
newline:    .string "\n"                             // Nueva línea para el final de la impresión
msg1:       .string "Array original:\n"              // Mensaje para el array original
msg2:       .string "Array ordenado:\n"              // Mensaje para el array ordenado

.text
.global main

// Función principal
main:
    stp     x29, x30, [sp, -16]!     // Guardar frame pointer y link register
    mov     x29, sp                  // Actualizar frame pointer

    // Imprimir mensaje inicial "Array original"
    adrp    x0, msg1
    add     x0, x0, :lo12:msg1
    bl      printf

    // Imprimir array original
    adrp    x0, fmt_str
    add     x0, x0, :lo12:fmt_str
    bl      print_array

    // Llamar a merge sort
    mov     x0, #0                   // left = 0
    adrp    x1, n
    add     x1, x1, :lo12:n
    ldr     x1, [x1]
    sub     x1, x1, #1               // right = n-1
    bl      merge_sort

    // Imprimir mensaje final "Array ordenado"
    adrp    x0, msg2
    add     x0, x0, :lo12:msg2
    bl      printf

    // Imprimir array ordenado
    adrp    x0, fmt_str
    add     x0, x0, :lo12:fmt_str
    bl      print_array

    // Finalizar y retornar 0
    mov     w0, #0                   // Retornar 0
    ldp     x29, x30, [sp], 16       // Restaurar registros
    ret

/*******************************************************************************
* merge_sort: Implementación de la función recursiva de ordenación merge sort
* Entradas:
*   x0 - índice izquierdo (left)
*   x1 - índice derecho (right)
*******************************************************************************/
merge_sort:
    stp     x29, x30, [sp, -48]!     // Guardar registros de frame pointer y link register
    mov     x29, sp                  // Actualizar frame pointer

    // Guardar left y right en la pila
    str     x0, [sp, 16]
    str     x1, [sp, 24]

    cmp     x0, x1                  // Si left >= right, retornar
    bge     merge_sort_end

    // Calcular medio = (left + right) / 2
    add     x2, x0, x1
    lsr     x2, x2, #1               // x2 = mid
    str     x2, [sp, 32]

    // Llamada recursiva a merge_sort para la mitad izquierda
    mov     x1, x2                   // right = mid
    bl      merge_sort

    // Llamada recursiva a merge_sort para la mitad derecha
    ldr     x0, [sp, 32]             // Recuperar mid
    add     x0, x0, #1               // left = mid + 1
    ldr     x1, [sp, 24]             // Recuperar right original
    bl      merge_sort

    // Merge de las dos mitades
    ldr     x0, [sp, 16]             // left original
    ldr     x1, [sp, 32]             // mid
    ldr     x2, [sp, 24]             // right
    bl      merge

merge_sort_end:
    ldp     x29, x30, [sp], 48       // Restaurar registros y retornar
    ret

/*******************************************************************************
* merge: Función de mezcla que combina dos mitades ordenadas en una sola.
* Entradas:
*   x0 -
