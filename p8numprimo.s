// Programa: numero_primo.s
// Autor: Casildo Rubalcava Aaron
// Descripción: Verifica si un número ingresado por el usuario es primo
// Entrada: Un número entero positivo N
// Salida: Mensaje indicando si el número es primo o no
//
// Implementación equivalente en C++:
// ```cpp
// #include <iostream>
// using namespace std;
// int main() {
//     long n;
//     bool es_primo = true;
//     
//     cout << "Ingrese un número para verificar si es primo: ";
//     cin >> n;
//     
//     if (n <= 1) {
//         es_primo = false;
//     } else {
//         for(long i = 2; i * i <= n; i++) {
//             if (n % i == 0) {
//                 es_primo = false;
//                 break;
//             }
//         }
//     }
//     
//     if (es_primo) {
//         cout << n << " es un número primo" << endl;
//     } else {
//         cout << n << " no es un número primo" << endl;
//     }
//     return 0;
// }
// ```

.data
msg_prompt:    .asciz "Ingrese un número para verificar si es primo: "
msg_es_primo:  .asciz "%ld es un número primo\n"
msg_no_primo:  .asciz "%ld no es un número primo\n"
fmt_int:       .asciz "%ld"

.text
.global main

main:
    // Prólogo
    stp x29, x30, [sp, -16]!    // Guardar frame pointer y link register
    mov x29, sp                  // Establecer frame pointer
    sub sp, sp, #16             // Reservar espacio para variables locales

    // Solicitar número
    ldr x0, =msg_prompt         // Cargar dirección del mensaje
    bl printf                   // Imprimir mensaje
    
    // Leer número
    ldr x0, =fmt_int           // Formato para scanf
    mov x1, sp                 // Dirección donde guardar el número
    bl scanf                   // Leer número
    
    // Cargar número en x19
    ldr x19, [sp]              // x19 = número ingresado
    
    // Verificar si es menor o igual a 1
    cmp x19, #1
    ble no_primo               // Si N <= 1, no es primo
    
    // Inicializar variables para el bucle
    mov x20, #2                // x20 = i = 2 (divisor inicial)

check_loop:
    // Comparar i * i con n
    mul x21, x20, x20          // x21 = i * i
    cmp x21, x19               // Comparar i * i con n
    bgt es_primo               // Si i * i > n, es primo
    
    // Verificar si es divisible por i
    udiv x22, x19, x20         // x22 = n / i
    mul x22, x22, x20          // x22 = (n / i) * i
    cmp x22, x19               // Comparar el resultado con n
    beq no_primo               // Si son iguales, encontramos un divisor
    
    // Incrementar i y continuar el bucle
    add x20, x20, #1           // i++
    b check_loop               // Volver al inicio del bucle

es_primo:
    // Imprimir mensaje de número primo
    ldr x0, =msg_es_primo      // Cargar formato del mensaje
    mov x1, x19                // Pasar el número como argumento
    bl printf                  // Imprimir mensaje
    b end_program             // Saltar a fin del programa

no_primo:
    // Imprimir mensaje de número no primo
    ldr x0, =msg_no_primo      // Cargar formato del mensaje
    mov x1, x19                // Pasar el número como argumento
    bl printf                  // Imprimir mensaje

end_program:
    // Epílogo
    mov sp, x29                // Restaurar stack pointer
    ldp x29, x30, [sp], #16    // Restaurar frame pointer y link register
    mov x0, #0                 // Código de retorno 0
    ret                        // Retornar al sistema operativo
