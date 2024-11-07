// Programa: division.s
// Autor: Fernando
// Descripción: Realiza la división de dos números enteros ingresados por el usuario
// Entrada: Dos números enteros ingresados por consola
// Salida: El resultado de la división de los dos números o mensaje de error si es división por cero
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
//     if (num2 == 0) {
//         cout << "Error: División por cero" << endl;
//     } else {
//         cout << "División: " << num1 / num2 << endl;
//     }
//     return 0;
// }
// ```

.data
msg_prompt1:   .asciz "Ingresa el primer número: "
msg_prompt2:   .asciz "Ingresa el segundo número: "
msg_div:       .asciz "División: %ld\n"
msg_div_zero:  .asciz "Error: División por cero\n"
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

    // Verificar división por cero y realizar operación
    ldr x0, [sp]
    ldr x1, [sp, #8]
    cmp x1, #0
    b.eq div_by_zero
    udiv x2, x0, x1
    ldr x0, =msg_div
    mov x1, x2
    bl printf
    b end

div_by_zero:
    ldr x0, =msg_div_zero
    bl printf

end:
    add sp, sp, #16
    ldp x29, x30, [sp], 16
    ret
