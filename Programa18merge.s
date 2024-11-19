/*******************************************************************************
* Programa: Merge Sort en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Implementación de Merge Sort en ensamblador ARM64.
* El programa toma un array, lo ordena usando el método de ordenación por mezcla
* y lo muestra en pantalla antes y después de la ordenación.
*
* Compilación:
*    as -o merge_sort.o merge_sort.s
*    gcc -o merge_sort merge_sort.o -no-pie
*
* Ejecución:
*    ./merge_sort
*
* Traducción a C (para referencia):
* ----------------------------------------------------
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
* Link de grabación asciinema:
* https://asciinema.org/a/p2m5WGoiXk2J1jwDOKrRsKvqY
* Link de grabación gdb:
* https://asciinema.org/a/mtWhnFVuNP3LeeSEcmUt4Rh6m
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

// Función para imprimir el array
print_array:
    stp     x29, x30, [sp, -32]!     // Guardar registros
    mov     x29, sp
    str     x0, [sp, 16]             // Guardar dirección del formato
    
    mov     x19, #0                  // Índice = 0
print_loop:
    adrp    x1, n                    // Cargar dirección de n
    add     x1, x1, :lo12:n
    ldr     x1, [x1]                 // Cargar valor de n
    cmp     x19, x1                  // Comparar índice con n
    bge     print_end                // Si índice >= n, terminar
    
    ldr     x0, [sp, 16]             // Recuperar formato
    adrp    x2, array                // Cargar dirección del array
    add     x2, x2, :lo12:array
    ldr     x1, [x2, x19, lsl #3]    // Cargar elemento array[i]
    bl      printf
    
    add     x19, x19, #1             // Incrementar índice
    b       print_loop
    
print_end:
    adrp    x0, newline              // Imprimir nueva línea
    add     x0, x0, :lo12:newline
    bl      printf
    
    ldp     x29, x30, [sp], 32       // Restaurar registros
    ret

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

merge_sort:
    stp     x29, x30, [sp, -48]!     // Guardar registros
    mov     x29, sp                  
    
    // Guardar left y right en la pila
    str     x0, [sp, 16]
    str     x1, [sp, 24]
    
    cmp     x0, x1                   // Si left >= right, retornar
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

// Función merge para combinar dos sub-arrays ordenados
merge:
    stp     x29, x30, [sp, -64]!     // Guardar registros
    mov     x29, sp
    
    // Guardar parámetros
    str     x0, [sp, 16]             // left
    str     x1, [sp, 24]             // mid
    str     x2, [sp, 32]             // right
    
    // Copiar elementos al array temporal
    mov     x3, x0                   // i = left
copy_loop:
    cmp     x3, x2                   // mientras i <= right
    bgt     copy_end
    
    adrp    x4, array
    add     x4, x4, :lo12:array
    ldr     x5, [x4, x3, lsl #3]     // cargar array[i]
    
    adrp    x4, temp
    add     x4, x4, :lo12:temp
    str     x5, [x4, x3, lsl #3]     // temp[i] = array[i]
    
    add     x3, x3, #1               // i++
    b       copy_loop
    
copy_end:
    ldr     x3, [sp, 16]             // i = left
    ldr     x4, [sp, 16]             // k = left
    ldr     x5, [sp, 24]
    add     x5, x5, #1               // j = mid + 1
    
merge_loop:
    ldr     x6, [sp, 24]             // Cargar mid
    cmp     x3, x6                   // Si i > mid
    bgt     copy_remaining_right
    
    ldr     x6, [sp, 32]             // Cargar right
    cmp     x5, x6                   // Si j > right
    bgt     copy_remaining_left
    
    // Comparar temp[i] y temp[j]
    adrp    x6, temp
    add     x6, x6, :lo12:temp
    ldr     x7, [x6, x3, lsl #3]     // temp[i]
    ldr     x8, [x6, x5, lsl #3]     // temp[j]
    
    cmp     x7, x8
    bgt     copy_right
    
copy_left:
    adrp    x6, array
    add     x6, x6, :lo12:array
    str     x7, [x6, x4, lsl #3]     // array[k] = temp[i]
    add     x3, x3, #1               // i++
    b       next_merge
    
copy_right:
    adrp    x6, array
    add     x6, x6, :lo12:array
    str     x8, [x6, x4, lsl #3]     // array[k] = temp[j]
    add     x5, x5, #1               // j++
    
next_merge:
    add     x4, x4, #1               // k++
    b       merge_loop
    
copy_remaining_left:
    ldr     x6, [sp, 24]             // Cargar mid
    cmp     x3, x6                   // Si i > mid
    bgt     merge_end
    
    adrp    x6, temp
    add     x6, x6, :lo12:temp
    ldr     x7, [x6, x3, lsl #3]     // temp[i]
    
    adrp    x6, array
    add     x6, x6, :lo12:array
    str     x7, [x6, x4, lsl #3]     // array[k] = temp[i]
    
    add     x3, x3, #1               // i++
    add     x4, x4, #1               // k++
    b       copy_remaining_left
    
copy_remaining_right:
    ldr     x6, [sp, 32]             // Cargar right
    cmp     x5, x6                   // Si j > right
    bgt     merge_end
    
    adrp    x6, temp
    add     x6, x6, :lo12:temp
    ldr     x7, [x6, x5, lsl #3]     // temp[j]
    
    adrp    x6, array
    add     x6, x6, :lo12:array
    str     x7, [x6, x4, lsl #3]     // array[k] = temp[j]
    
    add     x5, x5, #1               // j++
    add     x4, x4, #1               // k++
    b       copy_remaining_right
    
merge_end:
    ldp     x29, x30, [sp], 64       // Restaurar registros
    ret
