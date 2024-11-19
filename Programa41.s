/***********************************************************************
* Programa: Conversión de Decimal a Hexadecimal
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa solicita al usuario que ingrese un número 
*              decimal, lo valida y luego muestra su equivalente en 
*              formato hexadecimal. Si el usuario ingresa un valor no 
*              válido, el programa muestra un mensaje de error.
*
* Compilación:
*    as -o decimal_a_hex.o decimal_a_hex.s
*    gcc -o decimal_a_hex decimal_a_hex.o -no-pie
*
* Ejecución:
*    ./decimal_a_hex
*
* Explicación del flujo:
* - prompt: Mensaje que solicita al usuario ingresar un número decimal.
* - result_msg: Mensaje que indica que el número ingresado será convertido a hexadecimal.
* - format_input: Formato de entrada para `scanf` que lee un número decimal de tipo `long`.
* - format_hex: Formato utilizado por `printf` para mostrar el número en formato hexadecimal.
* - newline: Salto de línea utilizado para mejorar la presentación de mensajes.
* - error_msg: Mensaje mostrado si la entrada del usuario no es válida.
*
* Variables y registros clave:
* - x0: Registro utilizado para pasar el primer argumento a funciones como `printf` y `scanf`.
* - x1: Registro utilizado para pasar la dirección de la variable donde se almacena el número ingresado.
* - sp: Dirección de la pila utilizada para almacenar el número ingresado de manera temporal.
*
* Funciones:
* - main: Controla el flujo principal del programa, manejando la entrada del número, validación, conversión a hexadecimal, 
*         y manejo de errores.
* - error_input: Rama del programa que maneja los errores de entrada, mostrando un mensaje adecuado y retornando un código de error.
*
* Flujo del Programa:
* 1. Solicitar al usuario que ingrese un número decimal con el mensaje `prompt`.
* 2. Leer el número ingresado utilizando `scanf` y almacenarlo en la pila.
* 3. Verificar si la lectura fue exitosa:
*    - Si es exitosa, convertir el número a hexadecimal y mostrarlo con `printf`.
*    - Si no es exitosa, mostrar un mensaje de error y terminar el programa con un código de error.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long num;
* 
*     printf("Ingrese un numero decimal: ");
*     if (scanf("%ld", &num) != 1) {
*         printf("Error: Ingrese un numero valido\n");
*         return 1;
*     }
* 
*     printf("El numero en hexadecimal es: 0x%X\n", (unsigned int) num);
*     return 0;
* }
* Link de grabación asciinema con gdb:
* https://asciinema.org/a/h64GkZrJuVw3nUasA5CINHMUR
***********************************************************************/

.data
    prompt:         .string "Ingrese un numero decimal: "
    result_msg:     .string "El numero en hexadecimal es: "
    format_input:   .string "%ld"          // Formato para leer un long
    format_hex:     .string "0x%X\n"       // Formato para imprimir en hexadecimal
    newline:        .string "\n"
    error_msg:      .string "Error: Ingrese un numero valido\n"

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

    // Leer número decimal
    adr     x0, format_input        // Formato para scanf
    mov     x1, sp                  // Dirección donde guardar el número
    bl      scanf
    
    // Verificar si la lectura fue exitosa
    cmp     x0, #1
    b.ne    error_input

    // Imprimir mensaje de resultado
    adr     x0, result_msg
    bl      printf

    // Cargar el número ingresado
    ldr     x1, [sp]
    
    // Imprimir en hexadecimal
    adr     x0, format_hex
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
