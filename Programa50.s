/***********************************************************************
* Programa: Creación y Escritura en Archivo
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa crea un archivo llamado `salida.txt`, solicita 
*              al usuario ingresar un mensaje, escribe dicho mensaje en el 
*              archivo, y cierra el archivo. Si ocurre algún error en el 
*              proceso de creación o escritura, se muestra un mensaje 
*              adecuado y se asegura el cierre del archivo.
*
* Compilación:
*    as -o escribir_archivo.o escribir_archivo.s
*    gcc -o escribir_archivo escribir_archivo.o -no-pie
*
* Ejecución:
*    ./escribir_archivo
*
* Explicación del flujo:
* - msg_creando: Mensaje que indica el inicio del proceso de creación del archivo.
* - msg_exito_crear: Mensaje que confirma la creación exitosa del archivo.
* - msg_error_crear: Mensaje que indica un error al intentar crear el archivo.
* - msg_pedir: Mensaje que solicita al usuario ingresar un texto para escribir en el archivo.
* - msg_exito_escribir: Mensaje que confirma que el mensaje fue escrito correctamente.
* - msg_error_escribir: Mensaje que indica un error al escribir en el archivo.
* - filename: Nombre del archivo a crear (`salida.txt`).
* - mode: Modo de apertura del archivo (`w` para escritura).
* - input: Buffer de 100 bytes para almacenar el mensaje ingresado por el usuario.
* - formato: Formato de lectura para `scanf` que lee hasta un salto de línea.
* - fileptr: Espacio reservado para almacenar el puntero al archivo abierto.
*
* Variables y registros clave:
* - x0: Registro utilizado para pasar el primer argumento a funciones como `fopen`, `fprintf`, y `printf`.
* - x1: Registro utilizado para pasar el segundo argumento, como el buffer de entrada o el modo de apertura del archivo.
* - fileptr: Dirección donde se almacena el puntero al archivo, utilizado para operaciones posteriores.
*
* Funciones:
* - main: Controla el flujo principal del programa, manejando la creación del archivo, lectura del mensaje del usuario, 
*         escritura en el archivo, y la gestión de errores.
* - error_crear: Muestra un mensaje de error y finaliza el programa si no se pudo crear el archivo.
* - error_escribir: Muestra un mensaje de error, asegura el cierre del archivo, y finaliza el programa si la escritura falla.
*
* Flujo del Programa:
* 1. Mostrar un mensaje indicando que se está creando el archivo.
* 2. Intentar abrir el archivo en modo escritura (`w`) con `fopen`.
* 3. Si la apertura es exitosa, solicitar al usuario que ingrese un mensaje.
* 4. Leer el mensaje con `scanf` y verificar si la lectura fue exitosa.
* 5. Escribir el mensaje en el archivo con `fprintf` y cerrar el archivo con `fclose`.
* 6. Mostrar mensajes de éxito o error según el caso.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     FILE *fileptr;
*     char input[100];
* 
*     printf("Creando Archivo\n");
*     fileptr = fopen("salida.txt", "w");
*     if (!fileptr) {
*         printf("Error en creación de archivo\n");
*         return 1;
*     }
*     printf("Archivo creado con éxito\n");
* 
*     printf("Introduce mensaje para escribir en el archivo: ");
*     if (scanf("%[^\n]", input) != 1) {
*         printf("Error en introducción de mensaje\n");
*         fclose(fileptr);
*         return 1;
*     }
* 
*     fprintf(fileptr, "%s", input);
*     fclose(fileptr);
*     printf("Mensaje introducido con éxito\n");
* 
*     return 0;
* }
*
* Link de grabación de asciinema:
* https://asciinema.org/a/IeICNGZpUDyYBtSO7VELdpcn3
* Link de grabación gdb:
* https://asciinema.org/a/BeSFkbUs3fvOyhpEp0ZrCV05i
***********************************************************************/

.data
    // Mensajes del sistema
    msg_creando: .asciz "Creando Archivo\n"
    msg_exito_crear: .asciz "Archivo creado con éxito\n"
    msg_error_crear: .asciz "Error en creación de archivo\n"
    msg_pedir: .asciz "Introduce mensaje para escribir en el archivo: "
    msg_exito_escribir: .asciz "Mensaje introducido con éxito\n"
    msg_error_escribir: .asciz "Error en introducción de mensaje\n"
    
    // Archivo y buffer
    filename: .asciz "salida.txt"
    mode: .asciz "w"
    input: .space 100
    formato: .asciz "%[^\n]"
    
    // Descriptor de archivo
    .align 8
    fileptr: .skip 8

.text
.global main
.extern fopen
.extern fprintf
.extern printf
.extern scanf
.extern fclose

main:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    
    // Mostrar "Creando Archivo"
    adrp x0, msg_creando
    add x0, x0, :lo12:msg_creando
    bl printf
    
    // Abrir archivo
    adrp x0, filename
    add x0, x0, :lo12:filename
    adrp x1, mode
    add x1, x1, :lo12:mode
    bl fopen
    
    // Guardar file pointer
    adrp x1, fileptr
    add x1, x1, :lo12:fileptr
    str x0, [x1]
    
    // Verificar si se abrió correctamente
    cmp x0, #0
    beq error_crear
    
    // Mostrar éxito en creación
    adrp x0, msg_exito_crear
    add x0, x0, :lo12:msg_exito_crear
    bl printf
    
    // Pedir mensaje al usuario
    adrp x0, msg_pedir
    add x0, x0, :lo12:msg_pedir
    bl printf
    
    // Leer mensaje del usuario
    adrp x0, formato
    add x0, x0, :lo12:formato
    adrp x1, input
    add x1, x1, :lo12:input
    bl scanf
    
    // Verificar lectura exitosa
    cmp x0, #1
    bne error_escribir
    
    // Escribir en archivo
    adrp x0, fileptr
    add x0, x0, :lo12:fileptr
    ldr x0, [x0]
    adrp x1, input
    add x1, x1, :lo12:input
    bl fprintf
    
    // Cerrar archivo
    adrp x0, fileptr
    add x0, x0, :lo12:fileptr
    ldr x0, [x0]
    bl fclose
    
    // Mostrar éxito en escritura
    adrp x0, msg_exito_escribir
    add x0, x0, :lo12:msg_exito_escribir
    bl printf
    
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

error_crear:
    // Mostrar error en creación
    adrp x0, msg_error_crear
    add x0, x0, :lo12:msg_error_crear
    bl printf
    mov w0, #1
    ldp x29, x30, [sp], #16
    ret

error_escribir:
    // Mostrar error en escritura
    adrp x0, msg_error_escribir
    add x0, x0, :lo12:msg_error_escribir
    bl printf
    // Cerrar archivo antes de salir
    adrp x0, fileptr
    add x0, x0, :lo12:fileptr
    ldr x0, [x0]
    bl fclose
    mov w0, #1
    ldp x29, x30, [sp], #16
    ret
