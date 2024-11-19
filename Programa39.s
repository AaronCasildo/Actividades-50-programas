/***********************************************************************
* Programa: Conversión de Decimal a Binario
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa convierte un número ingresado en decimal 
*              a su representación binaria. Primero solicita al usuario 
*              un número decimal, luego realiza la conversión bit a bit y 
*              finalmente imprime el número en formato binario.
*
* Compilación:
*    as -o decimal_a_binario.o decimal_a_binario.s
*    gcc -o decimal_a_binario decimal_a_binario.o -no-pie
*
* Ejecución:
*    ./decimal_a_binario
*
* Explicación del flujo:
* - prompt: Muestra un mensaje solicitando al usuario un número decimal.
* - result: Mensaje que indica el inicio del resultado en binario.
* - newline: Caracter de nueva línea al final de la salida binaria.
* - buffer: Espacio reservado en memoria para almacenar el número ingresado.
* - binario: Buffer que almacena el resultado en binario, con capacidad para 
*            32 bits más el terminador null.
* - formato: Formato utilizado para leer el número en scanf.
*
* Variables y registros clave:
* - x19: Registro que contiene el número decimal ingresado por el usuario.
* - x20: Índice para la posición en el buffer de salida binaria.
* - x21: Dirección del buffer `binario`, donde se guarda el número binario.
* - x22: Registro temporal para almacenar cada bit convertido a ASCII.
*
* Funciones:
* - main: Controla el flujo principal del programa, incluyendo la solicitud 
*         del número, la conversión a binario y la impresión del resultado.
* - convert_loop: Bucle que realiza la conversión bit a bit del número en 
*                 x19 a su representación en binario, almacenando cada bit 
*                 en el buffer `binario` de derecha a izquierda.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long numero;
*     char binario[33];
*     int indice = 31;
* 
*     // Solicitar número
*     printf("Ingresa un número decimal: ");
*     scanf("%ld", &numero);
*     
*     // Inicializar terminador null al final del buffer binario
*     binario[32] = '\0';
* 
*     // Convertir el número a binario
*     for (int i = indice; i >= 0; i--) {
*         binario[i] = (numero & 1) ? '1' : '0';
*         numero >>= 1;
*     }
* 
*     // Imprimir el número en binario
*     printf("El número en binario es: %s\n", binario);
* 
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/CU5KdAi71Z20lA4jisT5xMez5
* Link de grabación gdb:
* https://asciinema.org/a/bAP0uoMdmh9k6zhw5VrQCy96e
***********************************************************************/


.data
    prompt:     .string "Ingresa un número decimal: "
    result:     .string "El número en binario es: "
    newline:    .string "\n"
    buffer:     .skip 12        // Buffer para entrada del usuario
    binario:    .skip 33        // Buffer para resultado binario (32 bits + null)
    formato:    .string "%ld"   // Formato para scanf

.text
.global main

main:
    stp x29, x30, [sp, #-16]!  // Guardar frame pointer y link register
    mov x29, sp

    // Imprimir prompt
    adr x0, prompt
    bl printf

    // Leer número decimal
    sub sp, sp, #16            // Reservar espacio en stack
    mov x2, sp                 // Dirección donde guardar el número
    adr x0, formato
    mov x1, x2
    bl scanf

    // Cargar número ingresado
    ldr x19, [sp]              // x19 contendrá nuestro número
    add sp, sp, #16            // Restaurar stack

    // Imprimir mensaje de resultado
    adr x0, result
    bl printf

    // Preparar conversión a binario
    mov x20, #31               // Índice para el string (31 posiciones + null)
    adr x21, binario           // Dirección del buffer resultado
    mov x22, #0                // Para el terminador null
    strb w22, [x21, x20]       // Colocar terminador null al final
    sub x20, x20, #1           // Decrementar índice

convert_loop:
    and x22, x19, #1          // Obtener el bit menos significativo
    add w22, w22, #'0'        // Convertir a ASCII
    strb w22, [x21, x20]      // Guardar el dígito
    lsr x19, x19, #1          // Desplazar a la derecha
    sub x20, x20, #1          // Mover índice
    cmp x20, #-1              // Verificar si terminamos
    b.ge convert_loop         // Si no, continuar

    // Imprimir resultado
    add x21, x21, #0          // Ajustar dirección al inicio
    mov x0, x21
    bl printf

    // Imprimir nueva línea
    adr x0, newline
    bl printf

    // Retornar
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
