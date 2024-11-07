// Programa: reverse_string.s
// Autor: Aaron Casildo Rubalcava
// Descripción: Invierte una cadena de texto ingresada
// Entrada: Una cadena de texto definida en la sección .data
// Salida: La cadena invertida almacenada en el buffer result
//
// Implementación equivalente en C++:
// ```cpp
// #include <iostream>
// #include <string>
// using namespace std;
// int main() {
//     string texto = "Hola Mundo!";
//     string resultado;
//     for(int i = texto.length() - 1; i >= 0; i--) {
//         resultado += texto[i];
//     }
//     cout << "Texto invertido: " << resultado << endl;
//     return 0;
// }
// ```

.data
    // Mensajes y cadenas
    input_string:    .asciz "Hola Mundo!"           // Cadena a invertir
    msg_result:      .asciz "Texto invertido: %s\n" // Mensaje para mostrar resultado
    len = . - input_string - 1                      // Longitud de la cadena (sin null)
    result:          .skip 256                      // Buffer para el resultado

.text
.global main
main:
    // Prólogo
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    // Inicializar registros
    adr     x0, input_string  // Dirección de la cadena origen
    adr     x1, result        // Dirección del buffer destino
    mov     x2, #len          // Longitud de la cadena

    // Posicionar x0 al final de la cadena
    add     x0, x0, x2
    sub     x0, x0, #1

reverse_loop:
    // Verificar si hemos terminado
    cmp     x2, #0
    ble     print_result

    // Copiar un carácter
    ldrb    w3, [x0]          // Cargar byte de la cadena origen
    strb    w3, [x1]          // Almacenar byte en el destino

    // Actualizar punteros y contador
    sub     x0, x0, #1        // Mover puntero origen hacia atrás
    add     x1, x1, #1        // Mover puntero destino hacia adelante
    sub     x2, x2, #1        // Decrementar contador

    b       reverse_loop      // Repetir ciclo

print_result:
    // Agregar null terminator al resultado
    mov     w3, #0
    strb    w3, [x1]

    // Imprimir resultado
    ldr     x0, =msg_result
    ldr     x1, =result
    bl      printf

    // Epílogo y retorno
    mov     w0, #0            // Código de retorno
    ldp     x29, x30, [sp], 16
    ret
