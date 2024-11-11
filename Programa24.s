/***********************************************************************
* Programa: Cálculo de Longitud de Cadena en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa solicita al usuario ingresar una cadena de texto
*              y luego calcula su longitud (número de caracteres). La longitud
*              se muestra como resultado en la salida estándar. El programa
*              hace uso de un bucle para contar los caracteres de la cadena
*              hasta llegar al carácter nulo que indica el fin de la cadena.
*              Se lee la cadena desde la entrada estándar utilizando `scanf`
*              y se muestra el resultado usando `printf`.
*
* Compilación:
*    as -o longitud_cadena.o longitud_cadena.s
*    gcc -o longitud_cadena longitud_cadena.o -no-pie
*
* Ejecución:
*    ./longitud_cadena
*
* Explicación del flujo:
* - prompt: Mensaje de solicitud de entrada para la cadena de texto.
* - result: Mensaje que muestra la longitud de la cadena.
* - buffer: Espacio de memoria utilizado para almacenar la cadena ingresada.
* - formato: Formato de lectura de la cadena, limitando la entrada a 99 caracteres.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     char buffer[100];
*     int length = 0;
* 
*     printf("📝 Ingresa una cadena de texto: ");
*     scanf("%99s", buffer);
* 
*     // Contar caracteres
*     while (buffer[length] != '\0') {
*         length++;
*     }
* 
*     printf("📏 La longitud de la cadena es: %d\n", length);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/JBBNvjeDsLvuwc7IFWtlblazZ
***********************************************************************/

.data
    prompt:     .asciz "📝 Ingresa una cadena de texto: "
    result:     .asciz "📏 La longitud de la cadena es: %d\n"
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

    // Preparar para contar caracteres
    adrp x0, buffer
    add x0, x0, :lo12:buffer
    mov x1, #0          // Contador de longitud

count_loop:
    ldrb w2, [x0]      // Cargar un byte
    cbz w2, show_result // Si es 0 (fin de cadena), terminar
    add x1, x1, #1     // Incrementar contador
    add x0, x0, #1     // Avanzar al siguiente carácter
    b count_loop

show_result:
    // Guardar el contador (x1) antes de llamar a printf
    mov x19, x1        // Guardar contador en x19 (registro preservado)
    
    // Mostrar resultado
    adrp x0, result
    add x0, x0, :lo12:result
    mov x1, x19        // Pasar el contador como segundo argumento
    bl printf

    // Epílogo y retorno
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
