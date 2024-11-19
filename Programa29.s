/***********************************************************************
* Programa: Conteo de Bits y Representación Binaria
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa cuenta la cantidad de bits activados (en 1) 
*              en un número dado y muestra su representación binaria. 
*              Primero recorre cada bit para contar los activados y luego 
*              imprime el número en binario, desde el bit más significativo.
*
* Compilación:
*    as -o conteo_bits.o conteo_bits.s
*    gcc -o conteo_bits conteo_bits.o -no-pie
*
* Ejecución:
*    ./conteo_bits
*
* Explicación del flujo:
* - msg1: Mensaje que muestra el número original en decimal.
* - msg2: Mensaje que muestra la cantidad de bits activados (en 1).
* - msg3: Mensaje inicial para la representación binaria ("Representación binaria: 0b").
* - one: Mensaje para representar el bit 1.
* - zero: Mensaje para representar el bit 0.
* - newline: Caracter de nueva línea al final de la representación binaria.
* - x19: Registro que almacena el número original a procesar.
* - x20: Registro que contiene el valor temporal del número para manipular en el conteo y luego en la representación binaria.
* - x21: Registro que almacena el contador de bits activados (cantidad de bits en 1).
* - x22: Contador de bits para la representación binaria (inicialmente 32 bits).
* - x23, x24: Registros auxiliares utilizados en la representación binaria.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int number = 42; // 101010 en binario
*     int bit_count = 0;
*     int temp = number;
* 
*     // Conteo de bits en 1
*     while (temp != 0) {
*         if (temp & 1) {
*             bit_count++;
*         }
*         temp >>= 1;
*     }
* 
*     printf("Número decimal: %d\n", number);
*     printf("Cantidad de bits activados: %d\n", bit_count);
* 
*     // Representación binaria
*     printf("Representación binaria: 0b");
*     for (int i = 31; i >= 0; i--) {
*         printf("%d", (number >> i) & 1);
*     }
*     printf("\n");
* 
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/ndK4d5WAeo4rVmIP0qWyG3J4M
* Link de grabación gdb:
* https://asciinema.org/a/ug82jV6S3uekghBjEKhLy0WeQ
***********************************************************************/

.global main
.text

main:
    // Guardamos el link register
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Inicializamos el número para contar sus bits
    mov     x19, #42        // 42 en decimal = 101010 en binario
    mov     x20, x19        // Copia para manipular
    mov     x21, #0         // Contador de bits

loop_count:
    // Comprobamos si hemos procesado todos los bits
    cmp     x20, #0
    beq     end_count

    // Verificamos el bit menos significativo
    // usando AND con 1 (0001)
    and     x22, x20, #1
    
    // Si el resultado es 1, incrementamos el contador
    cmp     x22, #1
    bne     skip_increment
    add     x21, x21, #1

skip_increment:
    // Desplazamos a la derecha para verificar el siguiente bit
    lsr     x20, x20, #1
    b       loop_count

end_count:
    // Imprimir el número original
    adr     x0, msg1
    mov     x1, x19
    bl      printf

    // Imprimir el conteo de bits
    adr     x0, msg2
    mov     x1, x21
    bl      printf

    // Imprimir representación binaria
    mov     x20, x19        // Restauramos el número original
    mov     x22, #32        // Contador para 32 bits

    // Imprimimos el inicio del formato binario
    adr     x0, msg3
    bl      printf

print_binary:
    cbz     x22, end_print  // Si el contador llega a 0, terminamos

    // Obtener el bit más significativo
    mov     x23, #1
    lsl     x23, x23, #31   // Crear máscara para el bit más significativo
    and     x24, x20, x23   // Extraer el bit
    
    // Imprimir 1 o 0
    cmp     x24, #0
    beq     print_zero

print_one:
    adr     x0, one
    bl      printf
    b       continue_print

print_zero:
    adr     x0, zero
    bl      printf

continue_print:
    lsl     x20, x20, #1    // Desplazar a la izquierda
    sub     x22, x22, #1    // Decrementar contador
    b       print_binary

end_print:
    // Nueva línea al final
    adr     x0, newline
    bl      printf

    // Restauramos el stack y retornamos
    ldp     x29, x30, [sp], #16
    mov     w0, #0
    ret

.section .rodata
msg1:
    .string "Número decimal: %d\n"
msg2:
    .string "Cantidad de bits activados: %d\n"
msg3:
    .string "Representación binaria: 0b"
one:
    .string "1"
zero:
    .string "0"
newline:
    .string "\n"
