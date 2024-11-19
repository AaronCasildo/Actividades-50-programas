/***********************************************************************
* Programa: Conversión de ASCII a Entero en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa convierte una cadena de caracteres en formato
*              ASCII (que representa un número) en un valor entero. Utiliza
*              el ensamblador ARM64 para leer la entrada desde el teclado,
*              validar que los caracteres sean dígitos numéricos y realizar
*              la conversión. Si se detecta un carácter no válido, el programa
*              muestra un mensaje de error. El número resultante se guarda en
*              una variable de 64 bits.
*
* Compilación:
*    as -o convertir_ascii.o convertir_ascii.s
*    gcc -o convertir_ascii convertir_ascii.o -no-pie
*
* Ejecución:
*    ./convertir_ascii
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #include <stdlib.h>
* #include <string.h>
*
* int convert_ascii_to_int(char *input) {
*     int result = 0;
*     int i = 0;
*     while (input[i] != '\0') {
*         if (input[i] < '0' || input[i] > '9') {
*             printf("Error: Entrada inválida\n");
*             exit(1);
*         }
*         result = result * 10 + (input[i] - '0');
*         i++;
*     }
*     return result;
* }
*
* int main() {
*     char input[100];
*     printf("Ingrese un número: ");
*     fgets(input, sizeof(input), stdin);
*     input[strcspn(input, "\n")] = '\0';  // Eliminar salto de línea
*
*     int result = convert_ascii_to_int(input);
*     printf("El número ingresado es: %d\n", result);
*
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/Ry3X7x8TXtn6LNDnh8n0lJvJl
* Link de grabación gdb:
* https://asciinema.org/a/rIk0eUL9oZgUAgOf1RpWVBOB0
***********************************************************************/
.data
    // Mensajes para interactuar con el usuario
    prompt:     .asciz "🔢 Por favor, introduce un número decimal: "
    result:     .asciz "✅ Resultado de la conversión: %d\n"
    error_msg:  .asciz "❌ Error: Debes introducir solo números (0-9)\n"
    outro_msg:  .asciz "👋 ¡Gracias por usar el convertidor!\n"
    formato_scan: .asciz "%s"     // Formato para scanf
    
    // Reservamos espacio para la entrada del usuario
    .align 4                      // Alineamos a 4 bytes para optimizar acceso
    buffer: .skip 12              // Aumentamos buffer a 11 chars + null terminator
    
.text
.global main
.extern printf                    // Declaramos funciones externas de C
.extern scanf

main:
    // Guardamos registros en el stack (prólogo de función)
    stp x29, x30, [sp, -16]!     // Guarda frame pointer y link register
    mov x29, sp                   // Actualiza frame pointer
    
    // Mostramos mensaje inicial
    adrp x0, prompt              // Carga dirección base de prompt
    add x0, x0, :lo12:prompt     // Añade el offset de 12 bits
    bl printf                    // Llama a printf
    
    // Leemos la entrada del usuario
    adrp x0, formato_scan
    add x0, x0, :lo12:formato_scan
    adrp x1, buffer
    add x1, x1, :lo12:buffer
    bl scanf
    
    // Inicializamos variables
    mov x19, #0                  // x19 = acumulador del resultado
    adrp x20, buffer             // x20 = puntero al buffer
    add x20, x20, :lo12:buffer
    
proceso_loop:
    // Procesamos cada carácter
    ldrb w21, [x20]             // Carga un byte (carácter) en w21
    
    // Verifica fin de cadena
    cmp w21, #0                 // Compara con null terminator
    beq fin_conversion          // Si es 0, terminamos la conversión
    
    // Validación de dígitos (ASCII 48-57)
    cmp w21, #48               // Compara con '0'
    blt error                  // Si es menor, no es un dígito
    cmp w21, #57               // Compara con '9'
    bgt error                  // Si es mayor, no es un dígito
    
    // Convertimos ASCII a valor numérico
    sub w21, w21, #48          // Resta 48 para obtener valor real
    
    // Algoritmo de conversión: resultado = resultado * 10 + nuevo_digito
    mov x22, #10
    mul x19, x19, x22         // Multiplica por 10 el valor actual
    add x19, x19, x21         // Suma el nuevo dígito
    
    // Avanza al siguiente carácter
    add x20, x20, #1
    b proceso_loop
    
error:
    // Manejo de error
    adrp x0, error_msg
    add x0, x0, :lo12:error_msg
    bl printf
    mov w0, #1                // Código de error
    b salida
    
fin_conversion:
    // Muestra el resultado
    adrp x0, result
    add x0, x0, :lo12:result
    mov x1, x19               // Pasa el resultado como argumento
    bl printf
    
    // Muestra mensaje de despedida
    adrp x0, outro_msg
    add x0, x0, :lo12:outro_msg
    bl printf
    
    mov w0, #0               // Código de éxito
    
salida:
    // Restauramos registros y retornamos (epílogo)
    ldp x29, x30, [sp], #16
    ret
