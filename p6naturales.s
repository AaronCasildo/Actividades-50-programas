// Programa: suma_naturales.s
// Autor: Aaron Casildo Rubalcava
// Descripción: Calcula la suma de los primeros N números naturales
// Entrada: Un número entero positivo N ingresado por el usuario
// Salida: La suma de los números desde 1 hasta N
//
// Implementación equivalente en C++:
// ```cpp
// #include <iostream>
// using namespace std;
// int main() {
//     long n, sum = 0;
//     cout << "Ingrese un número N: ";
//     cin >> n;
//     for(long i = 1; i <= n; i++) {
//         sum += i;
//     }
//     cout << "La suma de los primeros " << n << " números es: " << sum << endl;
//     return 0;
// }
// ```

.data
msg_prompt:    .asciz "Ingrese un número N: "
msg_result:    .asciz "La suma de los primeros %ld números es: %ld\n"
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
    
    // Inicializar variables
    ldr x19, [sp]              // x19 = N (número ingresado)
    mov x20, #0                // x20 = sum = 0
    mov x21, #1                // x21 = i = 1

loop:
    cmp x21, x19               // Comparar i con N
    bgt end_loop              // Si i > N, salir del loop
    
    add x20, x20, x21         // sum += i
    add x21, x21, #1          // i++
    b loop                    // Volver al inicio del loop

end_loop:
    // Imprimir resultado
    ldr x0, =msg_result       // Cargar formato del mensaje
    mov x1, x19               // Primer argumento (N)
    mov x2, x20               // Segundo argumento (sum)
    bl printf                 // Imprimir resultado

    // Epílogo
    mov sp, x29               // Restaurar stack pointer
    ldp x29, x30, [sp], #16   // Restaurar frame pointer y link register
    
    // Retornar
    mov x0, #0                // Código de retorno 0
    ret                       // Retornar al sistema operativo
