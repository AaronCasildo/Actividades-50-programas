/***********************************************************************
* Programa: Lectura y Visualización de Texto
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa solicita al usuario que ingrese un texto,
*              lo almacena en un buffer y luego lo muestra en pantalla. 
*              Si ocurre un error durante la lectura, se muestra un 
*              mensaje de error. El programa utiliza la función `scanf` 
*              para leer la entrada y `printf` para mostrar los mensajes.
*
* Compilación:
*    as -o leer_texto.o leer_texto.s
*    gcc -o leer_texto leer_texto.o -no-pie
*
* Ejecución:
*    ./leer_texto
*
* Explicación del flujo:
* - prompt: Mensaje que solicita al usuario ingresar un texto.
* - input: Buffer de 100 bytes para almacenar el texto ingresado.
* - formato: Formato de `scanf` para leer una línea completa hasta un salto de línea.
* - output: Mensaje que muestra el texto ingresado por el usuario.
* - error_msg: Mensaje que se muestra si ocurre un error durante la lectura.
*
* Variables y registros clave:
* - x0: Registro utilizado para pasar el primer argumento a `printf` o `scanf`.
* - x1: Registro utilizado para pasar el segundo argumento a `printf` o `scanf`.
* - input: Buffer donde se almacena el texto ingresado.
*
* Funciones:
* - main: Controla el flujo principal del programa, mostrando un mensaje de 
*         solicitud, leyendo el texto ingresado, verificando errores, y 
*         mostrando el texto ingresado o un mensaje de error según corresponda.
* - error_reading: Maneja la impresión del mensaje de error si `scanf` no logra leer correctamente.
*
* Flujo del Programa:
* 1. Se solicita al usuario que ingrese un texto con el mensaje de `prompt`.
* 2. Se lee la entrada del usuario con `scanf` y se almacena en `input`.
* 3. Si la lectura es exitosa, se muestra el texto ingresado.
* 4. Si ocurre un error, se muestra un mensaje indicando que hubo un problema.
* 
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     char input[100];
* 
*     printf("🖊️  Por favor, ingrese un texto: ");
*     if (scanf("%[^\n]", input) != 1) {
*         printf("❌ Error al leer la entrada\n");
*         return 1;
*     }
* 
*     printf("📝 Usted escribió: %s\n", input);
*     return 0;
* }
*
* Link de grabación de asciinema:
* https://asciinema.org/a/lZY69vpsKUDgTZhpKPwqH0OcN
* Link de grabación gdb:
* https://asciinema.org/a/5UrK4VDfrTeZTAwGkV247wqXn
***********************************************************************/

.data
    prompt: .asciz "🖊️  Por favor, ingrese un texto: "
    input: .space 100       // Buffer para almacenar la entrada (100 bytes)
    formato: .asciz "%[^\n]" // Formato para scanf que lee hasta encontrar un newline
    output: .asciz "📝 Usted escribió: %s\n"
    error_msg: .asciz "❌ Error al leer la entrada\n"

.text
.global main
.extern printf
.extern scanf
.extern gets
.extern puts

main:
    // Prólogo
    stp x29, x30, [sp, -16]!
    mov x29, sp
    
    // Mostrar prompt
    adrp x0, prompt
    add x0, x0, :lo12:prompt
    bl printf
    
    // Leer entrada usando scanf
    adrp x0, formato
    add x0, x0, :lo12:formato    // Primer argumento: formato
    adrp x1, input
    add x1, x1, :lo12:input      // Segundo argumento: buffer
    bl scanf
    
    // Verificar si scanf fue exitoso
    cmp x0, #1
    bne error_reading
    
    // Mostrar lo que se leyó
    adrp x0, output
    add x0, x0, :lo12:output
    adrp x1, input
    add x1, x1, :lo12:input
    bl printf
    
    // Epílogo y retorno exitoso
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    
error_reading:
    // Mostrar mensaje de error
    adrp x0, error_msg
    add x0, x0, :lo12:error_msg
    bl printf
    
    // Retornar con código de error
    mov w0, #1
    ldp x29, x30, [sp], #16
    ret
