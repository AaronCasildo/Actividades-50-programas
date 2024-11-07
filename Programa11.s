// Programa: palindromo.s
// Autor: Claude Assistant
// Descripción: Verifica si una cadena es palíndromo, mostrando primero la frase
// Entrada: Cadena predefinida en .data
// Salida: La frase y mensaje indicando si es palíndromo o no
//
// Implementación equivalente en C++:
// ```cpp
// #include <iostream>
// #include <string.h>
// using namespace std;
// int main() {
//     char str[] = "anita lava la tina";
//     cout << str << endl;
//     int i = 0;
//     int j = strlen(str) - 1;
//     bool esPalindromo = true;
//     
//     while(i < j) {
//         while(i < j && !isalpha(str[i])) i++;
//         while(i < j && !isalpha(str[j])) j--;
//         if(tolower(str[i]) != tolower(str[j])) {
//             esPalindromo = false;
//             break;
//         }
//         i++;
//         j--;
//     }
//     cout << (esPalindromo ? "Es palíndromo" : "No es palíndromo") << endl;
//     return 0;
// }
// ```

.data
    cadena:         .asciz "anita lava la tina"    // Cadena a verificar
    msg_frase:      .asciz "Frase a analizar: %s\n"
    msg_es:         .asciz "Es palíndromo\n"
    msg_no_es:      .asciz "No es palíndromo\n"

.text
.global main

// Función para convertir a minúscula
toLower:
    // Si el carácter está entre 'A' y 'Z', convertir a minúscula
    cmp     w0, #'A'
    blt     toLower_end
    cmp     w0, #'Z'
    bgt     toLower_end
    add     w0, w0, #32
toLower_end:
    ret

// Función para verificar si es letra
isAlpha:
    // Convertir a minúscula primero
    bl      toLower
    // Verificar si está entre 'a' y 'z'
    cmp     w0, #'a'
    blt     notAlpha
    cmp     w0, #'z'
    bgt     notAlpha
    mov     w0, #1
    ret
notAlpha:
    mov     w0, #0
    ret

main:
    // Prólogo
    stp     x29, x30, [sp, -48]!
    mov     x29, sp

    // Imprimir la frase a analizar
    ldr     x0, =msg_frase
    ldr     x1, =cadena
    bl      printf

    // Inicializar punteros
    ldr     x19, =cadena          // x19 = inicio de la cadena
    mov     x20, x19              // x20 = también apunta al inicio
    
    // Encontrar el final de la cadena
    mov     x21, #0               // Contador de longitud
findEnd:
    ldrb    w0, [x20, x21]
    cbz     w0, findEndDone
    add     x21, x21, #1
    b       findEnd
findEndDone:
    sub     x21, x21, #1          // x21 = índice final (longitud - 1)

checkLoop:
    cmp     x19, x21
    bge     isPalindrome          // Si los punteros se cruzan, es palíndromo

    // Saltar espacios y caracteres no alfabéticos desde el inicio
skipNonAlphaStart:
    ldrb    w0, [x19]
    bl      isAlpha
    cbnz    w0, skipNonAlphaStartDone
    add     x19, x19, #1
    b       skipNonAlphaStart
skipNonAlphaStartDone:

    // Saltar espacios y caracteres no alfabéticos desde el final
skipNonAlphaEnd:
    ldrb    w0, [x21]
    bl      isAlpha
    cbnz    w0, skipNonAlphaEndDone
    sub     x21, x21, #1
    b       skipNonAlphaEnd
skipNonAlphaEndDone:

    // Comparar caracteres
    ldrb    w0, [x19]
    bl      toLower
    mov     w22, w0               // Guardar primer carácter en w22
    ldrb    w0, [x21]
    bl      toLower
    cmp     w22, w0
    bne     notPalindrome         // Si no son iguales, no es palíndromo

    add     x19, x19, #1          // Avanzar puntero de inicio
    sub     x21, x21, #1          // Retroceder puntero de final
    b       checkLoop

isPalindrome:
    ldr     x0, =msg_es
    bl      printf
    b       done

notPalindrome:
    ldr     x0, =msg_no_es
    bl      printf

done:
    // Epílogo y retorno
    mov     w0, #0
    ldp     x29, x30, [sp], 48
    ret
