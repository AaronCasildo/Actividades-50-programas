/***********************************************************************
* Programa: Multiplicación de Matrices en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa realiza la multiplicación de dos matrices
*              de tamaño 2x3 y 3x2 utilizando ARM64 Assembly. Imprime
*              las matrices de entrada, luego efectúa la multiplicación
*              de las mismas y muestra la matriz resultado (2x2).
*              Las matrices y los valores de configuración están definidos
*              de manera estática en la sección de datos.
*
* Compilación:
*    as -o multiplicacion_matrices.o multiplicacion_matrices.s
*    gcc -o multiplicacion_matrices multiplicacion_matrices.o -no-pie
*
* Ejecución:
*    ./multiplicacion_matrices
*
* Explicación de matrices:
* - matrix1: Matriz de tamaño 2x3
* - matrix2: Matriz de tamaño 3x2
* - result: Matriz de tamaño 2x2 para almacenar el resultado de la multiplicación.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
*
* void print_matrix(long matrix[], long rows, long cols) {
*     for (long i = 0; i < rows; i++) {
*         for (long j = 0; j < cols; j++) {
*             printf("%ld ", matrix[i * cols + j]);
*         }
*         printf("\n");
*     }
* }
*
* void multiply_matrices(long matrix1[], long matrix2[], long result[], long rows1, long cols1, long rows2, long cols2) {
*     for (long i = 0; i < rows1; i++) {
*         for (long j = 0; j < cols2; j++) {
*             long sum = 0;
*             for (long k = 0; k < cols1; k++) {
*                 sum += matrix1[i * cols1 + k] * matrix2[k * cols2 + j];
*             }
*             result[i * cols2 + j] = sum;
*         }
*     }
* }
*
* int main() {
*     long matrix1[6] = {1, 2, 3, 4, 5, 6};  // 2x3 matrix
*     long matrix2[6] = {7, 8, 9, 10, 11, 12};  // 3x2 matrix
*     long result[4];  // 2x2 result matrix
*     long rows1 = 2, cols1 = 3, rows2 = 3, cols2 = 2;
*
*     printf("Matriz 1:\n");
*     print_matrix(matrix1, rows1, cols1);
*     printf("Matriz 2:\n");
*     print_matrix(matrix2, rows2, cols2);
*
*     multiply_matrices(matrix1, matrix2, result, rows1, cols1, rows2, cols2);
*
*     printf("Resultado:\n");
*     print_matrix(result, rows1, cols2);
*
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/vz6kW3kpkyV2qMLPRQbSv8zrA
* Link de grabación gdb:
* https://asciinema.org/a/KHIa55kSxpM3JKLO6elhCwmKm
***********************************************************************/

.data
// Matrices y valores de configuración
matrix1:    .quad   1, 2, 3
            .quad   4, 5, 6
matrix2:    .quad   7, 8
            .quad   9, 10
            .quad   11, 12
result:     .fill   4, 8, 0            // Matriz resultado (2x2), inicializada en 0
rows1:      .quad   2                  // Filas de matrix1
cols1:      .quad   3                  // Columnas de matrix1
rows2:      .quad   3                  // Filas de matrix2
cols2:      .quad   2                  // Columnas de matrix2
fmt_str:    .string "%ld "             // Formato para imprimir
newline:    .string "\n"
msg1:       .string "Matriz 1:\n"
msg2:       .string "Matriz 2:\n"
msg3:       .string "Resultado:\n"

.global main
.text

// Función principal
main:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    // Imprimir matriz 1
    adrp    x0, msg1
    add     x0, x0, :lo12:msg1
    bl      printf
    adrp    x0, matrix1
    add     x0, x0, :lo12:matrix1
    mov     x1, #2                   // rows
    mov     x2, #3                   // cols
    bl      print_matrix

    // Imprimir matriz 2
    adrp    x0, msg2
    add     x0, x0, :lo12:msg2
    bl      printf
    adrp    x0, matrix2
    add     x0, x0, :lo12:matrix2
    mov     x1, #3                   // rows
    mov     x2, #2                   // cols
    bl      print_matrix

    // Llamar a la multiplicación de matrices
    bl      multiply_matrices

    // Imprimir resultado
    adrp    x0, msg3
    add     x0, x0, :lo12:msg3
    bl      printf
    adrp    x0, result
    add     x0, x0, :lo12:result
    mov     x1, #2                   // rows
    mov     x2, #2                   // cols
    bl      print_matrix

    mov     w0, #0                   // Retornar 0
    ldp     x29, x30, [sp], 16
    ret

// Función para multiplicar matrices
multiply_matrices:
    stp     x29, x30, [sp, -64]!
    mov     x29, sp

    mov     x9, #0                   // i = 0
outer_loop:
    cmp     x9, #2
    bge     mult_end

    mov     x10, #0                  // j = 0
middle_loop:
    cmp     x10, #2
    bge     outer_next

    mov     x12, #0                  // acumulador = 0
    mov     x11, #0                  // k = 0
inner_loop:
    cmp     x11, #3
    bge     store_result

    adrp    x13, matrix1
    add     x13, x13, :lo12:matrix1
    mov     x14, #3                  // cols1
    mul     x14, x9, x14
    add     x14, x14, x11
    ldr     x14, [x13, x14, lsl #3]  // matrix1[i][k]

    adrp    x13, matrix2
    add     x13, x13, :lo12:matrix2
    mov     x15, #2                  // cols2
    mul     x15, x11, x15
    add     x15, x15, x10
    ldr     x15, [x13, x15, lsl #3]  // matrix2[k][j]

    mul     x14, x14, x15
    add     x12, x12, x14

    add     x11, x11, #1
    b       inner_loop

store_result:
    adrp    x13, result
    add     x13, x13, :lo12:result
    mov     x14, #2
    mul     x14, x9, x14
    add     x14, x14, x10
    str     x12, [x13, x14, lsl #3]

    add     x10, x10, #1
    b       middle_loop

outer_next:
    add     x9, x9, #1
    b       outer_loop

mult_end:
    ldp     x29, x30, [sp], 64
    ret

// Función para imprimir matriz
print_matrix:
    stp     x29, x30, [sp, -48]!
    mov     x29, sp

    str     x0, [sp, 16]
    str     x1, [sp, 24]
    str     x2, [sp, 32]

    mov     x19, #0
print_outer:
    ldr     x1, [sp, 24]
    cmp     x19, x1
    bge     print_end

    mov     x20, #0
print_inner:
    ldr     x2, [sp, 32]
    cmp     x20, x2
    bge     print_next_row

    ldr     x21, [sp, 32]
    mul     x21, x19, x21
    add     x21, x21, x20
    ldr     x0, [sp, 16]
    ldr     x1, [x0, x21, lsl #3]

    adrp    x0, fmt_str
    add     x0, x0, :lo12:fmt_str
    bl      printf

    add     x20, x20, #1
    b       print_inner

print_next_row:
    adrp    x0, newline
    add     x0, x0, :lo12:newline
    bl      printf

    add     x19, x19, #1
    b       print_outer

print_end:
    ldp     x29, x30, [sp], 48
    ret
