/***********************************************************************
* Programa: Conversión de Binario a Decimal
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa convierte un número binario ingresado por el 
*              usuario a su representación en decimal. Primero valida que 
*              el número contenga solo dígitos binarios (1 y 0) y luego 
*              realiza la conversión mediante un desplazamiento y suma en 
*              cada iteración del bucle. Si el usuario ingresa caracteres 
*              no válidos, el programa muestra un mensaje de error.
*
* Compilación:
*    as -o binario_a_decimal.o binario_a_decimal.s
*    gcc -o binario_a_decimal binario_a_decimal.o -no-pie
*
* Ejecución:
*    ./binario_a_decimal
*
* Explicación del flujo:
* - prompt: Mensaje que solicita al usuario ingresar un número binario.
* - result: Mensaje que muestra el resultado de la conversión a decimal.
* - error_msg: Mensaje de error que aparece si se ingresan caracteres no válidos.
* - buffer: Almacena la entrada del usuario (máximo 100 caracteres).
* - formato: Formato para `scanf` para leer la cadena de caracteres binaria.
*
* Variables y registros clave:
* - x19: Registro que almacena el resultado decimal de la conversión.
* - x20: Dirección de inicio del buffer que contiene el número binario.
* - x21: Índice que recorre cada carácter en el buffer de entrada.
* - w22: Registro temporal que almacena cada carácter binario durante el proceso.
*
* Funciones:
* - main: Controla el flujo principal del programa, incluyendo la solicitud 
*         del número binario, validación de caracteres, conversión a decimal 
*         y la impresión del resultado.
* - validate_and_convert: Bucle que recorre el string ingresado, validando 
*                         cada carácter y realizando la conversión binario-decimal.
* - invalid_input: Muestra un mensaje de error si la entrada contiene caracteres 
*                  distintos de 1 y 0.
* - print_result: Imprime el resultado de la conversión si la validación es exitosa.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #include <string.h>
* 
* int main() {
*     char buffer[100];
*     long resultado = 0;
* 
*     // Solicitar número binario
*     printf("Ingresa un número binario: ");
*     scanf("%s", buffer);
*     
*     // Validar y convertir el número binario a decimal
*     for (int i = 0; i < strlen(buffer); i++) {
*         if (buffer[i] != '0' && buffer[i] != '1') {
*             printf("Error: Ingresa solo 1s y 0s\n");
*             return 1;
*         }
*         resultado = resultado * 2 + (buffer[i] - '0');
*     }
* 
*     // Imprimir resultado
*     printf("El número en decimal es: %ld\n", resultado);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/od5js49rWldRqxtXvvCVbKmH7
* Link de grabación gdb:
* https://asciinema.org/a/Q0DBU7D3Fxfyx1bUtJVhhWfhg
***********************************************************************/

.data
    prompt:     .string "Ingresa un número binario: "
    result:     .string "El número en decimal es: %ld\n"
    error_msg:  .string "Error: Ingresa solo 1s y 0s\n"
    buffer:     .skip 100      // Buffer para entrada del usuario
    formato:    .string "%s"   // Formato para scanf

.text
.global main

main:
    stp x29, x30, [sp, #-16]!  // Guardar frame pointer y link register
    mov x29, sp

    // Imprimir prompt
    adr x0, prompt
    bl printf

    // Leer número binario
    adr x0, formato
    adr x1, buffer
    bl scanf

    // Inicializar registros
    mov x19, #0                // x19 será nuestro resultado decimal
    adr x20, buffer            // x20 apunta al inicio del string
    mov x21, #0                // x21 será nuestro índice

validate_and_convert:
    // Cargar carácter actual
    ldrb w22, [x20, x21]      // Cargar byte en w22
    
    // Verificar si llegamos al final del string (\n o \0)
    cmp w22, #0
    b.eq print_result
    cmp w22, #10              // \n
    b.eq print_result

    // Verificar si es un dígito válido (0 o 1)
    cmp w22, #'0'
    b.lt invalid_input
    cmp w22, #'1'
    b.gt invalid_input

    // Convertir ASCII a valor numérico
    sub w22, w22, #'0'        // Convertir ASCII a valor

    // Multiplicar resultado actual por 2 y sumar nuevo dígito
    lsl x19, x19, #1          // Multiplicar por 2
    add x19, x19, x22         // Sumar nuevo dígito

    // Siguiente carácter
    add x21, x21, #1
    b validate_and_convert

invalid_input:
    // Imprimir mensaje de error
    adr x0, error_msg
    bl printf
    mov w0, #1                // Código de error
    b exit

print_result:
    // Verificar si se ingresó al menos un dígito
    cmp x21, #0
    b.eq invalid_input

    // Imprimir resultado
    adr x0, result
    mov x1, x19
    bl printf
    mov w0, #0                // Código de éxito

exit:
    ldp x29, x30, [sp], #16
    ret
