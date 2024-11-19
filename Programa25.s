/***********************************************************************
* Programa: Contador de Vocales y Consonantes en una Cadena
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa solicita al usuario ingresar una cadena de texto
*              y luego cuenta cuántas vocales y cuántas consonantes contiene.
*              El programa realiza la distinción entre vocales y consonantes
*              al verificar cada carácter de la cadena. Se ignoran los caracteres
*              no alfabéticos y se muestra el número de vocales y consonantes encontradas.
*              El conteo se realiza de forma que las letras mayúsculas se convierten
*              a minúsculas antes de ser procesadas. El resultado final se presenta
*              mediante mensajes que indican el número de vocales y consonantes.
*
* Compilación:
*    as -o contar_vocales_consonantes.o contar_vocales_consonantes.s
*    gcc -o contar_vocales_consonantes contar_vocales_consonantes.o -no-pie
*
* Ejecución:
*    ./contar_vocales_consonantes
*
* Explicación del flujo:
* - prompt: Mensaje que solicita la entrada de una cadena de texto.
* - result1: Mensaje que muestra el número de vocales encontradas en la cadena.
* - result2: Mensaje que muestra el número de consonantes encontradas en la cadena.
* - buffer: Espacio de memoria utilizado para almacenar la cadena ingresada.
* - formato: Formato de lectura de la cadena, limitando la entrada a 99 caracteres.
* - El programa procesa cada letra de la cadena y clasifica las vocales y consonantes.
* - Las letras mayúsculas se convierten a minúsculas para facilitar el conteo.
* 
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     char buffer[100];
*     int vowels = 0, consonants = 0;
* 
*     printf("📝 Ingresa una cadena de texto: ");
*     scanf("%99s", buffer);
* 
*     // Contar vocales y consonantes
*     for (int i = 0; buffer[i] != '\0'; i++) {
*         char c = buffer[i];
*         if (c >= 'A' && c <= 'Z') {
*             c += 32; // Convertir a minúscula
*         }
*         if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u') {
*             vowels++;
*         } else if (c >= 'a' && c <= 'z') {
*             consonants++;
*         }
*     }
* 
*     printf("🔤 Vocales encontradas: %d\n", vowels);
*     printf("🔤 Consonantes encontradas: %d\n", consonants);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/EboF9YyKE6vQLFeBOwOhgo0wS
* Link de grabación gdb:
* https://asciinema.org/a/ECQSm5iVidxRW1esqsFAy7qvy
***********************************************************************/


.data
    prompt:     .asciz "📝 Ingresa una cadena de texto: "
    result1:    .asciz "🔤 Vocales encontradas: %d\n"
    result2:    .asciz "🔤 Consonantes encontradas: %d\n"
    buffer:     .skip 100    // Buffer para almacenar la cadena
    formato:    .asciz "%99s" // Formato para leer string (límite de 99 caracteres + null)

.text
.global main
.extern printf
.extern scanf

main:
    // Prólogo
    stp x29, x30, [sp, -16]!
    mov x29, sp

    // Mostrar prompt
    adrp x0, prompt
    add x0, x0, :lo12:prompt
    bl printf

    // Leer cadena
    adrp x0, formato
    add x0, x0, :lo12:formato
    adrp x1, buffer
    add x1, x1, :lo12:buffer
    bl scanf

    // Preparar para contar
    adrp x0, buffer
    add x0, x0, :lo12:buffer
    mov x1, #0          // Contador de vocales
    mov x2, #0          // Contador de consonantes

count_loop:
    ldrb w3, [x0]      // Cargar un byte
    cbz w3, show_result // Si es 0 (fin de cadena), terminar
    
    // Convertir a minúscula si es mayúscula
    cmp w3, #'A'
    blt not_letter
    cmp w3, #'Z'
    bgt check_lower
    add w3, w3, #32    // Convertir a minúscula
    
check_lower:
    // Verificar si es letra minúscula
    cmp w3, #'a'
    blt not_letter
    cmp w3, #'z'
    bgt not_letter
    
    // Verificar si es vocal
    cmp w3, #'a'
    beq is_vowel
    cmp w3, #'e'
    beq is_vowel
    cmp w3, #'i'
    beq is_vowel
    cmp w3, #'o'
    beq is_vowel
    cmp w3, #'u'
    beq is_vowel
    
    // Si llegamos aquí, es consonante
    add x2, x2, #1
    b continue

is_vowel:
    add x1, x1, #1
    b continue

not_letter:
    // No es letra, continuamos sin incrementar contadores

continue:
    add x0, x0, #1     // Avanzar al siguiente carácter
    b count_loop

show_result:
    // Guardar contadores
    mov x19, x1        // Guardar contador de vocales
    mov x20, x2        // Guardar contador de consonantes
    
    // Mostrar resultado de vocales
    adrp x0, result1
    add x0, x0, :lo12:result1
    mov x1, x19
    bl printf
    
    // Mostrar resultado de consonantes
    adrp x0, result2
    add x0, x0, :lo12:result2
    mov x1, x20
    bl printf

    // Epílogo y retorno
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
