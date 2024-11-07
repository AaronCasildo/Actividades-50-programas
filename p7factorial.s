// Programa: factorial.s
// Autor: Casildo Rubalcava Aaron
// Descripción: Calcula el factorial de un número N ingresado por el usuario
// Entrada: Un número entero positivo N
// Salida: El factorial de N (N!)
//
// Implementación equivalente en C++:
// ```cpp
// #include <iostream>
// using namespace std;
// int main() {
//     long n, factorial = 1;
//     cout << "Ingrese un número para calcular su factorial: ";
//     cin >> n;
//     if (n < 0) {
//         cout << "Error: No existe factorial de números negativos" << endl;
//         return 1;
//     }
//     for(long i = 1; i <= n; i++) {
//         factorial *= i;
//     }
//     cout << "El factorial de " << n << " es: " << factorial << endl;
//     return 0;
// }
// ```

.data
msg_prompt:    .asciz "Ingrese un número para calcular su factorial: "
msg_result:    .asciz "El factorial de %ld es: %ld\n"
msg_error:     .asciz "Error: No existe factorial de números negativos\n"
fmt_int:       .asciz "%ld"

.text
.global main

main:
    // Prólogo
    stp x29, x30, [sp, -16]!    // Guardar frame pointer y link register
    mov x29, sp                  // Establecer frame pointer
    sub sp, sp, #16             // Reservar espacio para variables locales

    // Solicitar número N
    ldr x0, =msg_prompt         // Cargar dirección del mensaje
    bl printf                   // Imprimir mensaje
    
    // Leer N
    ldr x0, =fmt_int           // Formato para scanf
    mov x1, sp                 // Dirección donde guardar N
    bl scanf                   // Leer N
    
    // Verificar si N es negativo
    ldr x19, [sp]              // x19 = N (número ingresado)
    cmp x19, #0                // Comparar N con 0
    blt error_negative         // Si N < 0, mostrar error

    // Inicializar variables
    mov x20, #1                // x20 = factorial = 1
    mov x21, #1                // x21 = i = 1

factorial_loop:
    cmp x21, x19               // Comparar i con N
    bgt end_loop               // Si i > N, salir del loop
    
    mul x20, x20, x21          // factorial *= i
    add x21, x21, #1           // i++
    b factorial_loop           // Volver al inicio del loop

error_negative:
    // Mostrar mensaje de error para números negativos
    ldr x0, =msg_error         // Cargar mensaje de error
    bl printf                  // Imprimir mensaje
    mov x0, #1                 // Código de error
    b end_program             // Saltar a fin del programa

end_loop:
    // Imprimir resultado
    ldr x0, =msg_result        // Cargar formato del mensaje
    mov x1, x19                // Primer argumento (N)
    mov x2, x20                // Segundo argumento (factorial)
    bl printf                  // Imprimir resultado
    mov x0, #0                 // Código de éxito

end_program:
    // Epílogo
    mov sp, x29                // Restaurar stack pointer
    ldp x29, x30, [sp], #16    // Restaurar frame pointer y link register
    ret                        // Retornar al sistema operativo
