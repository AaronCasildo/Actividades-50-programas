/***********************************************************************
* Programa: Conversión de Número Entero a ASCII en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa convierte un número entero positivo ingresado
*              por el usuario a su representación en formato ASCII. El número
*              se lee desde la entrada estándar y, si es válido, se convierte
*              a su equivalente en caracteres ASCII. Si el número es negativo,
*              se muestra un mensaje de error. El programa también imprime el
*              número convertido en ASCII y un mensaje final de despedida.
*              El número se maneja como una cadena de caracteres en formato
*              ASCII, y se invierte para obtener la representación correcta.
*
* Compilación:
*    as -o convertir_entero_ascii.o convertir_entero_ascii.s
*    gcc -o convertir_entero_ascii convertir_entero_ascii.o -no-pie
*
* Ejecución:
*    ./convertir_entero_ascii
*
* Explicación de flujo:
* - prompt: Mensaje de solicitud de entrada para el número entero.
* - result: Mensaje de salida que muestra el número en formato ASCII.
* - error_msg: Mensaje que se muestra en caso de entrada inválida (número negativo).
* - outro_msg: Mensaje de despedida al finalizar el programa.
* - buffer: Espacio de memoria utilizado para almacenar el número en formato ASCII.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* void convert_to_ascii(int num) {
*     if (num < 0) {
*         printf("❌ Error: El número debe ser positivo\n");
*         return;
*     }
*     char buffer[32];
*     int i = 0;
*     while (num > 0) {
*         buffer[i++] = (num % 10) + '0';  // Convertir dígito a ASCII
*         num /= 10;
*     }
*     buffer[i] = '\0';  // Terminar cadena
* 
*     // Invertir la cadena
*     for (int j = 0; j < i / 2; j++) {
*         char temp = buffer[j];
*         buffer[j] = buffer[i - j - 1];
*         buffer[i - j - 1] = temp;
*     }
* 
*     printf("✅ El número en ASCII es: %s\n", buffer);
* }
* 
* int main() {
*     int num;
*     printf("🔢 Ingresa un número entero: ");
*     scanf("%d", &num);
*     convert_to_ascii(num);
*     printf("👋 ¡Gracias por usar el convertidor!\n");
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/blxds7ymNr3hqISHfqezyHxTx
* Link de grabación gdb:
* https://asciinema.org/a/Z0DqXdV0CqTWwXgwhsYW18893
***********************************************************************/

.data
    prompt:     .asciz "🔢 Ingresa un número entero: "
    result:     .asciz "✅ El número en ASCII es: %s\n"
    error_msg:  .asciz "❌ Error: El número debe ser positivo\n"
    outro_msg:  .asciz "👋 ¡Gracias por usar el convertidor!\n"
    formato_scan: .asciz "%d"
    
    .align 4
    buffer: .skip 32              // Aumentamos el tamaño del buffer para seguridad

.text
.global main
.extern printf
.extern scanf

main:
    // Prólogo
    stp x29, x30, [sp, -16]!
    mov x29, sp
    
    // Mensaje inicial
    adrp x0, prompt
    add x0, x0, :lo12:prompt
    bl printf
    
    // Reservar espacio y leer número
    sub sp, sp, #16
    mov x19, sp
    
    adrp x0, formato_scan
    add x0, x0, :lo12:formato_scan
    mov x1, x19
    bl scanf
    
    // Cargar y verificar número
    ldr w20, [x19]              // Cambiado a w20 para manejar 32 bits
    
    cmp w20, #0
    blt error
    
    // Preparar buffer
    adrp x21, buffer
    add x21, x21, :lo12:buffer
    mov x22, x21                // Guardar inicio del buffer
    
convert_loop:
    // Obtener último dígito
    mov w23, #10
    udiv w24, w20, w23          // Cociente
    msub w25, w24, w23, w20     // Residuo
    
    // Convertir a ASCII y guardar
    add w25, w25, #'0'          // Convertir a ASCII
    strb w25, [x21], #1         // Guardar y avanzar
    
    // Actualizar número y continuar si no es cero
    mov w20, w24
    cbnz w20, convert_loop
    
    // Terminar string
    mov w25, #0
    strb w25, [x21]
    
    // Invertir string
    sub x21, x21, #1            // Retroceder antes del null
    mov x23, x22                // x23 = inicio del buffer
reverse_loop:
    cmp x23, x21
    bge show_result
    ldrb w24, [x23]
    ldrb w25, [x21]
    strb w25, [x23], #1
    strb w24, [x21], #-1
    b reverse_loop

show_result:
    adrp x0, result
    add x0, x0, :lo12:result
    mov x1, x22
    bl printf
    
    adrp x0, outro_msg
    add x0, x0, :lo12:outro_msg
    bl printf
    
    mov w0, #0
    b exit

error:
    adrp x0, error_msg
    add x0, x0, :lo12:error_msg
    bl printf
    mov w0, #1

exit:
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret
