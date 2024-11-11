/*****************************************************
 * Título: Transposición de una Matriz 3x3
 * Autor: Aaron Casildo Rubalcava
 * Descripción: Este programa en lenguaje ensamblador ARM64 realiza la transposición de una matriz 3x3,
 *              intercambiando sus filas por columnas. El programa imprime la matriz original y la matriz transpuesta.
 *
 * Funciones principales:
 *   - main: Imprime la matriz original, realiza la transposición y luego imprime la matriz transpuesta.
 *   - transpose_matrix: Realiza la operación de transposición de la matriz.
 *   - print_matrix: Imprime una matriz de acuerdo con su formato de filas y columnas.
 *
 * Notas:
 *   - El programa utiliza ARM64 Assembly para manipular los registros y manejar las operaciones aritméticas.
 *   - Usa la librería estándar `printf` para imprimir las matrices en formato alineado.
 * 
* Traducción en C (para referencia):
* ----------------------------------------------------
 * #include <stdio.h>
 *
 * void print_matrix(int matrix[3][3]) {
 *     for (int i = 0; i < 3; i++) {
 *         for (int j = 0; j < 3; j++) {
 *             printf("%4d ", matrix[i][j]);
 *         }
 *         printf("\n");
 *     }
 * }
 *
 * void transpose_matrix(int matrix[3][3], int result[3][3]) {
 *     for (int i = 0; i < 3; i++) {
 *         for (int j = 0; j < 3; j++) {
 *             result[j][i] = matrix[i][j];
 *         }
 *     }
 * }
 *
 * int main() {
 *     int matrix[3][3] = {
 *         {1, 2, 3},
 *         {4, 5, 6},
 *         {7, 8, 9}
 *     };
 *     
 *     int result[3][3] = {0};  // Matriz para el resultado de la transposición
 *     
 *     printf("Matriz Original:\n");
 *     print_matrix(matrix);
 *     
 *     transpose_matrix(matrix, result);
 *     
 *     printf("Matriz Transpuesta:\n");
 *     print_matrix(result);
 *     
 *     return 0;
 * }
 *
* Link de grabación asciinema:
* https://asciinema.org/a/nC6Em0DdMjElPfnjmKbHyjIP1
 ******************************************************/
 
.data
// Matriz original y resultado
matrix:     .quad   1, 2, 3
           .quad   4, 5, 6
           .quad   7, 8, 9            // Matriz 3x3 original
rows:      .quad   3                  // Filas de la matriz
cols:      .quad   3                  // Columnas de la matriz
result:    .fill   9, 8, 0           // Matriz resultado (3x3), inicializada en 0
fmt_str:   .string "%4ld "           // Formato para imprimir (alineado)
newline:   .string "\n"
msg1:      .string "Matriz Original:\n"
msg2:      .string "Matriz Transpuesta:\n"

.text
.global main

// Función principal
main:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    // Imprimir matriz original
    adrp    x0, msg1
    add     x0, x0, :lo12:msg1
    bl      printf

    adrp    x0, matrix
    add     x0, x0, :lo12:matrix
    ldr     x1, =rows
    ldr     x1, [x1]                  // rows
    ldr     x2, =cols
    ldr     x2, [x2]                  // cols
    bl      print_matrix

    // Llamar a la transposición de matriz
    bl      transpose_matrix

    // Imprimir matriz transpuesta
    adrp    x0, msg2
    add     x0, x0, :lo12:msg2
    bl      printf

    adrp    x0, result
    add     x0, x0, :lo12:result
    ldr     x1, =cols                 // En la transpuesta, cols son las filas
    ldr     x1, [x1]
    ldr     x2, =rows                 // En la transpuesta, rows son las columnas
    ldr     x2, [x2]
    bl      print_matrix

    mov     w0, #0                    // Retornar 0
    ldp     x29, x30, [sp], 16
    ret

// Función para transponer matriz
transpose_matrix:
    stp     x29, x30, [sp, -48]!
    mov     x29, sp

    mov     x9, #0                    // i = 0
outer_loop:
    ldr     x0, =rows
    ldr     x0, [x0]
    cmp     x9, x0                    // comparar con filas
    bge     trans_end

    mov     x10, #0                   // j = 0
inner_loop:
    ldr     x0, =cols
    ldr     x0, [x0]
    cmp     x10, x0                   // comparar con columnas
    bge     outer_next

    // Calcular índice para matrix[i][j]
    ldr     x11, =cols
    ldr     x11, [x11]               // cols
    mul     x12, x9, x11             // i * cols
    add     x12, x12, x10            // + j
    
    // Cargar elemento de la matriz original
    adrp    x13, matrix
    add     x13, x13, :lo12:matrix
    ldr     x14, [x13, x12, lsl #3]  // cargar matrix[i][j]

    // Calcular índice para result[j][i]
    ldr     x11, =rows
    ldr     x11, [x11]               // rows (será cols en resultado)
    mul     x12, x10, x11            // j * rows
    add     x12, x12, x9             // + i

    // Guardar en la matriz resultado
    adrp    x13, result
    add     x13, x13, :lo12:result
    str     x14, [x13, x12, lsl #3]  // result[j][i] = matrix[i][j]

    add     x10, x10, #1             // j++
    b       inner_loop

outer_next:
    add     x9, x9, #1               // i++
    b       outer_loop

trans_end:
    ldp     x29, x30, [sp], 48
    ret

// Función para imprimir matriz
print_matrix:
    stp     x29, x30, [sp, -48]!
    mov     x29, sp
    
    // Guardar parámetros
    str     x0, [sp, 16]             // dirección de la matriz
    str     x1, [sp, 24]             // filas
    str     x2, [sp, 32]             // columnas
    
    mov     x19, #0                  // i = 0
print_outer:
    ldr     x1, [sp, 24]             // cargar filas
    cmp     x19, x1
    bge     print_end
    
    mov     x20, #0                  // j = 0
print_inner:
    ldr     x2, [sp, 32]             // cargar columnas
    cmp     x20, x2
    bge     print_next_row
    
    // Calcular índice = i * cols + j
    ldr     x21, [sp, 32]            // cargar columnas
    mul     x21, x19, x21            // i * cols
    add     x21, x21, x20            // + j
    
    // Cargar y imprimir elemento
    ldr     x0, [sp, 16]             // dirección matriz
    ldr     x1, [x0, x21, lsl #3]    // cargar elemento
    adrp    x0, fmt_str
    add     x0, x0, :lo12:fmt_str
    bl      printf
    
    add     x20, x20, #1             // j++
    b       print_inner
    
print_next_row:
    adrp    x0, newline
    add     x0, x0, :lo12:newline
    bl      printf
    add     x19, x19, #1             // i++
    b       print_outer
    
print_end:
    ldp     x29, x30, [sp], 48
    ret
