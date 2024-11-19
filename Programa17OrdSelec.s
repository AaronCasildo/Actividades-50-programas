/***********************************************************************
* Programa: Ordenamiento por Selección en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Implementa el algoritmo de ordenamiento por selección (Selection Sort)
*              en un array de números enteros en ARM64 Assembly. El programa 
*              imprime el array original, luego lo ordena en orden ascendente 
*              y finalmente imprime el array ordenado.
*              Implementado en ARM64 Assembly para RaspbianOS.
* 
* Compilación:
*    as -o selection_sort.o selection_sort.s
*    gcc -o selection_sort selection_sort.o -no-pie
*
* Ejecución:
*    ./selection_sort
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* void selection_sort(long arr[], long n) {
*     long i, j, min_idx, temp;
*     for (i = 0; i < n-1; i++) {
*         min_idx = i;
*         for (j = i+1; j < n; j++) {
*             if (arr[j] < arr[min_idx]) {
*                 min_idx = j;
*             }
*         }
*         temp = arr[i];
*         arr[i] = arr[min_idx];
*         arr[min_idx] = temp;
*     }
* }
* 
* int main() {
*     long arr[] = {64, 34, 25, 12, 22, 11, 90, 1};
*     long n = 8;
*     long i;
*     
*     printf("Array original: ");
*     for (i = 0; i < n; i++) {
*         printf("%ld ", arr[i]);
*     }
*     printf("\n");
*     
*     selection_sort(arr, n);
*     
*     printf("Array ordenado: ");
*     for (i = 0; i < n; i++) {
*         printf("%ld ", arr[i]);
*     }
*     printf("\n");
*     
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/xyH6WMfIRPS4YFxtVUbMVzNYD
* Link de grabación gdb:
* https://asciinema.org/a/6SOPy5yM24zcKYtAa1wtA7gA4
***********************************************************************/

.data
array:      .quad   64, 34, 25, 12, 22, 11, 90, 1    // Array inicial
n:          .quad   8                                 // Tamaño del array
fmt_str:    .string "%ld "                           // Formato para imprimir
newline:    .string "\n"

.global main
.text

// Función principal
main:
    stp     x29, x30, [sp, -16]!    // Guardar frame pointer y link register
    mov     x29, sp                  // Actualizar frame pointer

    // Imprimir array original
    adrp    x0, fmt_str              // Cargar dirección de formato
    add     x0, x0, :lo12:fmt_str
    bl      printf_array

    // Llamar a selection sort
    bl      selection_sort

    // Imprimir array ordenado
    adrp    x0, fmt_str              // Cargar dirección de formato
    add     x0, x0, :lo12:fmt_str
    bl      printf_array

    mov     w0, #0                   // Retornar 0
    ldp     x29, x30, [sp], 16       // Restaurar registros
    ret

// Función de ordenamiento por selección
selection_sort:
    stp     x29, x30, [sp, -32]!     // Guardar registros
    mov     x29, sp

    adrp    x9, array                // Cargar dirección base del array
    add     x9, x9, :lo12:array
    adrp    x10, n                   // Cargar tamaño del array
    add     x10, x10, :lo12:n
    ldr     x10, [x10]
    mov     x11, #0                  // i = 0

outer_loop:
    cmp     x11, x10                 // Comparar i con n
    bge     sort_end                 // Si i >= n, terminar
    mov     x12, x11                 // min_idx = i
    mov     x13, x11                 // j = i
    add     x13, x13, #1             // j = i + 1

inner_loop:
    cmp     x13, x10                 // Comparar j con n
    bge     swap_min                 // Si j >= n, hacer swap

    ldr     x14, [x9, x13, lsl #3]   // arr[j]
    ldr     x15, [x9, x12, lsl #3]   // arr[min_idx]
    cmp     x14, x15                 // Comparar arr[j] con arr[min_idx]
    bge     next_j                   // Si arr[j] >= arr[min_idx], siguiente j
    mov     x12, x13                 // min_idx = j

next_j:
    add     x13, x13, #1             // j++
    b       inner_loop

swap_min:
    cmp     x12, x11                 // Comparar min_idx con i
    beq     next_i                   // Si son iguales, no hacer swap

    // Hacer swap
    ldr     x14, [x9, x11, lsl #3]   // temp = arr[i]
    ldr     x15, [x9, x12, lsl #3]   // arr[min_idx]
    str     x15, [x9, x11, lsl #3]   // arr[i] = arr[min_idx]
    str     x14, [x9, x12, lsl #3]   // arr[min_idx] = temp

next_i:
    add     x11, x11, #1             // i++
    b       outer_loop

sort_end:
    ldp     x29, x30, [sp], 32       // Restaurar registros
    ret

// Función para imprimir array
printf_array:
    stp     x29, x30, [sp, -32]!
    mov     x29, sp

    str     x0, [sp, 16]             // Guardar formato
    mov     x19, #0                  // i = 0
    adrp    x20, array               // Cargar dirección del array
    add     x20, x20, :lo12:array
    adrp    x21, n                   // Cargar tamaño
    add     x21, x21, :lo12:n
    ldr     x21, [x21]

print_loop:
    cmp     x19, x21                 // Comparar i con n
    bge     print_end                // Si i >= n, terminar

    ldr     x1, [x20, x19, lsl #3]   // Cargar array[i]
    ldr     x0, [sp, 16]             // Cargar formato
    bl      printf                   // Llamar printf

    add     x19, x19, #1             // i++
    b       print_loop

print_end:
    adrp    x0, newline              // Imprimir salto de línea
    add     x0, x0, :lo12:newline
    bl      printf

    ldp     x29, x30, [sp], 32
    ret
