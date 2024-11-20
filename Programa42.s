/***********************************************************************
* Programa: Conversión de Hexadecimal a Decimal
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa solicita al usuario que ingrese un número 
*              en formato hexadecimal (incluyendo el prefijo `0x`), lo valida 
*              y luego muestra su equivalente en formato decimal. Si el usuario 
*              ingresa un valor no válido, se muestra un mensaje de error.
*
* Compilación:
*    as -o hex_a_decimal.o hex_a_decimal.s
*    gcc -o hex_a_decimal hex_a_decimal.o -no-pie
*
* Ejecución:
*    ./hex_a_decimal
*
* Explicación del flujo:
* - prompt: Mensaje que solicita al usuario ingresar un número hexadecimal.
* - result_msg: Mensaje que indica el resultado convertido a formato decimal.
* - format_input: Formato utilizado por `scanf` para leer un número hexadecimal de tipo `long`.
* - error_msg: Mensaje mostrado si la entrada del usuario no es válida.
* - buffer: Espacio reservado para almacenar el número ingresado.
*
* Variables y registros clave:
* - x0: Registro utilizado para pasar el primer argumento a funciones como `printf` y `scanf`.
* - x1: Registro utilizado para pasar la dirección de la variable donde se almacena el número ingresado.
* - sp: Dirección de la pila utilizada para almacenar el número ingresado de manera temporal.
*
* Funciones:
* - main: Controla el flujo principal del programa, manejando la entrada del número hexadecimal, 
*         validación, conversión a decimal, y manejo de errores.
* - error_input: Rama del programa que maneja los errores de entrada, mostrando un mensaje adecuado y 
*                retornando un código de error.
*
* Flujo del Programa:
* 1. Solicitar al usuario que ingrese un número hexadecimal con el mensaje `prompt`.
* 2. Leer el número ingresado utilizando `scanf` y almacenarlo en la pila.
* 3. Verificar si la lectura fue exitosa:
*    - Si es exitosa, cargar el número desde la pila y mostrarlo en formato decimal con `printf`.
*    - Si no es exitosa, mostrar un mensaje de error y terminar el programa con un código de error.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long num;
* 
*     printf("Ingrese un numero hexadecimal (con 0x): ");
*     if (scanf("%lx", &num) != 1) {
*         printf("Error: Ingrese un numero hexadecimal valido\n");
*         return 1;
*     }
* 
*     printf("El numero en decimal es: %ld\n", num);
*     return 0;
* }
* Link de grabación asciinema con gdb:
* https://asciinema.org/a/Jma7Amg34OBR6080aMr5f0XnN
***********************************************************************/

.data
    prompt:         .string "Ingrese un numero hexadecimal (con 0x): "
    result_msg:     .string "El numero en decimal es: %ld\n"
    format_input:   .string "%lx"          // Formato para leer hexadecimal long
    error_msg:      .string "Error: Ingrese un numero hexadecimal valido\n"
    buffer:         .skip 20              // Buffer para almacenar la entrada
    newline:        .string "\n"

.text
.global main

// Función principal
main:
    // Prólogo
    stp     x29, x30, [sp, #-16]!   // Guardar frame pointer y link register
    mov     x29, sp                  // Actualizar frame pointer

    // Reservar espacio para variable local
    sub     sp, sp, #16             // 16 bytes para almacenar el número
    
    // Imprimir prompt
    adr     x0, prompt
    bl      printf

    // Leer número hexadecimal
    adr     x0, format_input        // Formato para scanf
    mov     x1, sp                  // Dirección donde guardar el número
    bl      scanf
    
    // Verificar si la lectura fue exitosa
    cmp     x0, #1
    b.ne    error_input

    // Cargar el número convertido
    ldr     x1, [sp]
    
    // Imprimir resultado en decimal
    adr     x0, result_msg
    bl      printf
    
    mov     w0, #0                  // Retornar 0
    b       end

error_input:
    // Manejar error de entrada
    adr     x0, error_msg
    bl      printf
    mov     w0, #1                  // Retornar 1 para indicar error

end:
    // Epílogo
    add     sp, sp, #16             // Liberar espacio local
    ldp     x29, x30, [sp], #16     // Restaurar frame pointer y link register
    ret
