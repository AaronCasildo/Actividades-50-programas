// Programa: fibonacci.s
// Autor: Claude Assistant
// Descripción: Genera y muestra los primeros 8 números de la serie de Fibonacci
// Entrada: Ninguna
// Salida: Los primeros 8 números de la serie de Fibonacci
//
// Implementación equivalente en C++:
// ```cpp
// #include <iostream>
// using namespace std;
// int main() {
//     long fib[8] = {0, 1};
//     cout << "Serie de Fibonacci:" << endl;
//     cout << fib[0] << " " << fib[1] << " ";
//     for(int i = 2; i < 8; i++) {
//         fib[i] = fib[i-1] + fib[i-2];
//         cout << fib[i] << " ";
//     }
//     cout << endl;
//     return 0;
// }
// ```

.data
    msg_titulo:     .asciz "Serie de Fibonacci:\n"
    msg_numero:     .asciz "%ld "           // Formato para imprimir cada número
    msg_newline:    .asciz "\n"             // Salto de línea
    cantidad:       .quad 8                  // Cantidad de números a generar

.text
.global main
main:
    // Prólogo
    stp     x29, x30, [sp, -48]!   // Reservamos espacio para variables locales
    mov     x29, sp

    // Imprimir título
    ldr     x0, =msg_titulo
    bl      printf

    // Inicializar primeros dos números de Fibonacci
    mov     x19, #0                 // First number (F0)
    mov     x20, #1                 // Second number (F1)
    
    // Imprimir primer número (0)
    ldr     x0, =msg_numero
    mov     x1, x19
    bl      printf

    // Imprimir segundo número (1)
    ldr     x0, =msg_numero
    mov     x1, x20
    bl      printf

    // Inicializar contador
    mov     x21, #2                 // Empezamos desde el tercer número
    ldr     x22, =cantidad
    ldr     x22, [x22]             // Cargar cantidad total (8)

fibonacci_loop:
    // Verificar si hemos terminado
    cmp     x21, x22
    bge     done

    // Calcular siguiente número (F[n] = F[n-1] + F[n-2])
    mov     x23, x20               // Temporal = F[n-1]
    add     x20, x19, x20         // F[n-1] = F[n-2] + F[n-1]
    mov     x19, x23              // F[n-2] = Temporal

    // Imprimir número actual
    ldr     x0, =msg_numero
    mov     x1, x20
    bl      printf

    // Incrementar contador
    add     x21, x21, #1
    b       fibonacci_loop

done:
    // Imprimir salto de línea final
    ldr     x0, =msg_newline
    bl      printf

    // Epílogo y retorno
    mov     w0, #0                // Código de retorno
    ldp     x29, x30, [sp], 48
    ret
