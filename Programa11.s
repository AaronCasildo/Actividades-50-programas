/***********************************************************************
* Programa: Verificar si una cadena es palíndromo
* Autor: Aaron Casildo Rubalcava
* Descripción: El programa verifica si la cadena "anita lava la tina" 
*              es un palíndromo, considerando solo los caracteres alfabéticos
*              y sin importar si son mayúsculas o minúsculas.
*
* Compilación:
*    as -o palindrome.o palindrome.s
*    gcc -o palindrome palindrome.o -no-pie
*
* Ejecución:
*    ./palindrome
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #include <ctype.h>
* int isAlpha(char c) {
*    /* Verifica si el carácter es alfabético (letra) */
*    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
* }
* char toLower(char c) {
*    /* Convierte el carácter a minúscula si es mayúscula */
*    return (c >= 'A' && c <= 'Z') ? c + 32 : c;
* }
* int main() {
*    char cadena[] = "anita lava la tina";  /* Cadena a verificar */
*    char *start = cadena;                  /* Puntero al inicio de la cadena */
*    char *end = cadena;                    /* Puntero al final de la cadena */
*    /* Encontrar el final de la cadena */
*    while (*end != '\0') {
*        end++;
*    }
*    end--;  /* Apuntar al último carácter no nulo */
*    /* Imprimir la frase a analizar */
*    printf("Frase a analizar: %s\n", cadena);
*    /* Comprobar si es un palíndromo */
*    while (start < end) {
*        /* Saltar caracteres no alfabéticos desde el inicio */
*        while (*start && !isAlpha(*start)) {
*            start++;
*        }
*        /* Saltar caracteres no alfabéticos desde el final */
*        while (end >= start && !isAlpha(*end)) {
*            end--;
*        }
*        /* Comparar caracteres (sin distinguir mayúsculas de minúsculas) */
*        if (toLower(*start) != toLower(*end)) {
*            printf("No es palíndromo\n");
*            return 0;
*        }
*        /* Avanzar y retroceder los punteros */
*        start++;
*        end--;
*    }
*    /* Si el bucle termina, es un palíndromo */
*    printf("Es palíndromo\n");
*    return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/SJHvlZ8SEgtzgGA8kxBhwpELs
***********************************************************************/

.data
    cadena:         .asciz "anita lava la tina"    // Cadena a verificar
    msg_frase:      .asciz "Frase a analizar: %s\n" // Mensaje de la frase a analizar
    msg_es:         .asciz "Es palíndromo\n"       // Mensaje si es palíndromo
    msg_no_es:      .asciz "No es palíndromo\n"    // Mensaje si no es palíndromo

.text
.global main

// Función para convertir a minúscula
toLower:
    // Si el carácter está entre 'A' y 'Z', convertir a minúscula
    cmp     w0, #'A'              // Compara si el carácter es mayor o igual a 'A'
    blt     toLower_end           // Si es menor a 'A', no hacer nada
    cmp     w0, #'Z'              // Compara si el carácter es mayor o igual a 'Z'
    bgt     toLower_end           // Si es mayor que 'Z', no hacer nada
    add     w0, w0, #32           // Convertir a minúscula sumando 32
toLower_end:
    ret

// Función para verificar si es letra
isAlpha:
    // Convertir a minúscula primero
    bl      toLower
    // Verificar si está entre 'a' y 'z'
    cmp     w0, #'a'              // Compara si el carácter es mayor o igual a 'a'
    blt     notAlpha              // Si es menor a 'a', no es alfabético
    cmp     w0, #'z'              // Compara si el carácter es mayor o igual a 'z'
    bgt     notAlpha              // Si es mayor que 'z', no es alfabético
    mov     w0, #1                // Es letra, devolver 1
    ret
notAlpha:
    mov     w0, #0                // No es letra, devolver 0
    ret

main:
    // Prólogo
    stp     x29, x30, [sp, -48]!   // Reservar espacio para variables locales
    mov     x29, sp                // Establecer el puntero de marco

    // Imprimir la frase a analizar
    ldr     x0, =msg_frase         // Cargar la dirección de la cadena del mensaje
    ldr     x1, =cadena            // Cargar la dirección de la cadena a analizar
    bl      printf                 // Llamada a printf para imprimir la frase

    // Inicializar punteros
    ldr     x19, =cadena           // x19 = puntero al inicio de la cadena
    mov     x20, x19               // x20 = también apunta al inicio de la cadena
    
    // Encontrar el final de la cadena
    mov     x21, #0                // Inicializar el contador de longitud
findEnd:
    ldrb    w0, [x20, x21]        // Cargar el siguiente byte de la cadena
    cbz     w0, findEndDone        // Si el byte es 0 (fin de cadena), salir
    add     x21, x21, #1           // Incrementar el contador de longitud
    b       findEnd                // Repetir el proceso

findEndDone:
    sub     x21, x21, #1           // x21 = índice final de la cadena (longitud - 1)

checkLoop:
    cmp     x19, x21               // Compara puntero de inicio con puntero de final
    bge     isPalindrome           // Si los punteros se cruzan, es palíndromo

    // Saltar espacios y caracteres no alfabéticos desde el inicio
skipNonAlphaStart:
    ldrb    w0, [x19]              // Cargar el siguiente byte desde el inicio
    bl      isAlpha                // Verificar si es una letra
    cbnz    w0, skipNonAlphaStartDone // Si es letra, continuar
    add     x19, x19, #1           // Si no es letra, avanzar el puntero de inicio
    b       skipNonAlphaStart      // Repetir el proceso
skipNonAlphaStartDone:

    // Saltar espacios y caracteres no alfabéticos desde el final
skipNonAlphaEnd:
    ldrb    w0, [x21]              // Cargar el siguiente byte desde el final
    bl      isAlpha                // Verificar si es una letra
    cbnz    w0, skipNonAlphaEndDone // Si es letra, continuar
    sub     x21, x21, #1           // Si no es letra, retroceder el puntero final
    b       skipNonAlphaEnd        // Repetir el proceso
skipNonAlphaEndDone:

    // Comparar caracteres
    ldrb    w0, [x19]              // Cargar carácter desde el inicio
    bl      toLower                // Convertirlo a minúscula
    mov     w22, w0                // Guardar el carácter en w22
    ldrb    w0, [x21]              // Cargar carácter desde el final
    bl      toLower                // Convertirlo a minúscula
    cmp     w22, w0                // Comparar los dos caracteres
    bne     notPalindrome          // Si no son iguales, no es palíndromo

    add     x19, x19, #1           // Avanzar puntero de inicio
    sub     x21, x21, #1           // Retroceder puntero de final
    b       checkLoop              // Repetir el proceso

isPalindrome:
    ldr     x0, =msg_es            // Cargar mensaje "Es palíndromo"
    bl      printf                 // Llamada a printf
    b       done                   // Finalizar

notPalindrome:
    ldr     x0, =msg_no_es         // Cargar mensaje "No es palíndromo"
    bl      printf                 // Llamada a printf

done:
    // Epílogo y retorno
    mov     w0, #0                 // Código de retorno (0)
    ldp     x29, x30, [sp], 48     // Restaurar registros
    ret                            // Retornar al sistema operativo
