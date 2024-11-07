// Programa: multiplicacion.s
// Autor: Aaron Casildo Rubalcava
// Descripción: Realiza la multiplicación de dos números enteros ingresados por el usuario
// Entrada: Dos números enteros ingresados por consola
// Salida: El resultado de la multiplicación de los dos números
//
// Implementación equivalente en C++:
// ```cpp
// #include <iostream>
// using namespace std;
// int main() {
//     long num1, num2;
//     cout << "Ingresa el primer número: ";
//     cin >> num1;
//     cout << "Ingresa el segundo número: ";
//     cin >> num2;
//     cout << "Multiplicación: " << num1 * num2 << endl;
//     return 0;
// }
// ```

.data
msg_prompt1:   .asciz "Ingresa el primer número: "
msg_prompt2:   .asciz "Ingresa el segundo número: "
msg_mul:       .asciz "Multiplicación: %ld\n"
fmt_int:       .asciz "%ld"

.text
.global main

main:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    sub sp, sp, #16

    // Solicitar primer número
    ldr x0, =msg_prompt1
    bl printf
    ldr x0, =fmt_int
    mov x1, sp
    bl scanf

    // Solicitar segundo número
    ldr x0, =msg_prompt2
    bl printf
    ldr x0, =fmt_int
    add x1, sp, #8
    bl scanf

    // Realizar multiplicación y mostrar resultado
    ldr x0, [sp]
    ldr x1, [sp, #8]
    mul x2, x0, x1
    ldr x0, =msg_mul
    mov x1, x2
    bl printf

    // Salida del programa
    add sp, sp, #16
    ldp x29, x30, [sp], 16
    ret
