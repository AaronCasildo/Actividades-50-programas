// Programa: suma_matrices.s
// Descripción: Realiza la suma de dos matrices 3x3
// Entrada: Matrices predefinidas en .data
// Salida: Matriz resultante y visualización del proceso
// Autor: Casildo Rubalcava Aaron 

//Código del programa en c
// #include <iostream>
// #include <iomanip>
//
// // Dimensión de la matriz
// const int DIM = 3;
//
// // Definición de las matrices de entrada
// long matriz1[DIM][DIM] = {
//     {1, 2, 3},
//     {4, 5, 6},
//     {7, 8, 9}
// };
//
// long matriz2[DIM][DIM] = {
//     {9, 8, 7},
//     {6, 5, 4},
//     {3, 2, 1}
// };
//
// long resultado[DIM][DIM] = {0}; // Espacio para matriz resultado
//
// // Mensajes para la salida
// const char* msg_titulo = "\nSuma de Matrices 3x3\n";
// const char* msg_mat1 = "\nMatriz 1:\n";
// const char* msg_mat2 = "\nMatriz 2:\n";
// const char* msg_res = "\nMatriz Resultado:\n";
//
// // Declaración de funciones
// void sumar_matrices();
// void imprimir_matriz(const long matriz[DIM][DIM]);
//
// int main() {
//     // Imprimir título
//     std::cout << msg_titulo;
//
//     // Mostrar matriz 1
//     std::cout << msg_mat1;
//     imprimir_matriz(matriz1);
//
//     // Mostrar matriz 2
//     std::cout << msg_mat2;
//     imprimir_matriz(matriz2);
//
//     // Realizar la suma de matrices
//     sumar_matrices();
//
//     // Mostrar resultado
//     std::cout << msg_res;
//     imprimir_matriz(resultado);
//
//     return 0;
// }
//
// //---------------------------------------------------------------
// // Función para sumar las matrices
// //---------------------------------------------------------------
// void sumar_matrices() {
//     for (int i = 0; i < DIM; ++i) {                // mov x19, #0 y cmp x19, x21
//         for (int j = 0; j < DIM; ++j) {            // ldr x20, =dim y mul x21, x20, x20
//             resultado[i][j] = matriz1[i][j] + matriz2[i][j];  // add x24, x24, x25
//         }
//     }
// }
//
// //---------------------------------------------------------------
// // Función para imprimir una matriz
// //---------------------------------------------------------------
// void imprimir_matriz(const long matriz[DIM][DIM]) {
//     for (int i = 0; i < DIM; ++i) {                // mov x19, #0, iteración de filas
//         for (int j = 0; j < DIM; ++j) {            // cmp x19, x21 para recorrer columnas
//             std::cout << std::setw(3) << matriz[i][j] << " "; // ldr x0, =msg_elem y bl printf
//         }
//         std::cout << "\n";                         // ldr x0, =newline y bl printf
//     }
// }

//Inicio del programa en assembly
.data
    // Definición de las matrices de entrada
    matriz1:    .quad   1, 2, 3,     // Primera matriz 3x3
                .quad   4, 5, 6,
                .quad   7, 8, 9

    matriz2:    .quad   9, 8, 7,     // Segunda matriz 3x3
                .quad   6, 5, 4,
                .quad   3, 2, 1

    resultado:  .skip   72           // Espacio para matriz resultado (3x3 * 8 bytes)
    
    dim:        .quad   3            // Dimensión de las matrices (3x3)

    // Mensajes para la salida
    msg_titulo: .asciz  "\nSuma de Matrices 3x3\n"
    msg_mat1:   .asciz  "\nMatriz 1:\n"
    msg_mat2:   .asciz  "\nMatriz 2:\n"
    msg_res:    .asciz  "\nMatriz Resultado:\n"
    msg_elem:   .asciz  "%3ld "      // Formato para imprimir elementos
    newline:    .asciz  "\n"

.text
.global main
main:
    // Prólogo
    stp     x29, x30, [sp, -64]!
    mov     x29, sp

    // Imprimir título
    ldr     x0, =msg_titulo
    bl      printf

    // Mostrar matriz 1
    ldr     x0, =msg_mat1
    bl      printf
    ldr     x0, =matriz1
    bl      imprimir_matriz

    // Mostrar matriz 2
    ldr     x0, =msg_mat2
    bl      printf
    ldr     x0, =matriz2
    bl      imprimir_matriz

    // Realizar la suma de matrices
    bl      sumar_matrices

    // Mostrar resultado
    ldr     x0, =msg_res
    bl      printf
    ldr     x0, =resultado
    bl      imprimir_matriz

    // Epílogo y retorno
    mov     w0, #0
    ldp     x29, x30, [sp], 64
    ret

// Subrutina para sumar las matrices
sumar_matrices:
    stp     x29, x30, [sp, -64]!
    mov     x29, sp

    mov     x19, #0          // i = 0
    ldr     x20, =dim
    ldr     x20, [x20]       // cargar dimensión
    mul     x21, x20, x20    // total de elementos (n^2)

suma_loop:
    cmp     x19, x21
    bge     suma_done

    // Cargar elementos de ambas matrices
    ldr     x22, =matriz1
    ldr     x23, =matriz2
    ldr     x24, [x22, x19, lsl #3]  // elemento de matriz1
    ldr     x25, [x23, x19, lsl #3]  // elemento de matriz2

    // Sumar elementos
    add     x24, x24, x25

    // Guardar resultado
    ldr     x22, =resultado
    str     x24, [x22, x19, lsl #3]

    add     x19, x19, #1     // incrementar contador
    b       suma_loop

suma_done:
    ldp     x29, x30, [sp], 64
    ret

// Subrutina para imprimir una matriz
imprimir_matriz:
    stp     x29, x30, [sp, -64]!
    mov     x29, sp
    str     x0, [sp, #16]    // guardar dirección de la matriz

    mov     x19, #0          // i = 0
    ldr     x20, =dim
    ldr     x20, [x20]       // cargar dimensión
    mul     x21, x20, x20    // total de elementos (n^2)

print_loop:
    cmp     x19, x21
    bge     print_done

    // Imprimir elemento
    ldr     x0, =msg_elem
    ldr     x22, [sp, #16]   // recuperar dirección de la matriz
    ldr     x1, [x22, x19, lsl #3]
    bl      printf

    // Nueva línea al final de cada fila
    add     x23, xzr, x19
    add     x23, x23, #1
    udiv    x24, x23, x20
    msub    x24, x24, x20, x23
    cbnz    x24, no_newline

    ldr     x0, =newline
    bl      printf

no_newline:
    add     x19, x19, #1     // incrementar contador
    b       print_loop

print_done:
    ldp     x29, x30, [sp], 64
    ret
