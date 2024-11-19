/***********************************************************************
* Programa: Manipulación de Bits
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa realiza operaciones de manipulación de bits 
*              sobre un número dado (inicialmente 10, es decir, 1010 en binario).
*              Realiza operaciones para establecer, borrar y alternar bits 
*              específicos utilizando instrucciones ORR, AND, MVN y EOR en ARM64.
*              El resultado de cada operación se muestra mediante mensajes.
*
* Compilación:
*    as -o manipulacion_bits.o manipulacion_bits.s
*    gcc -o manipulacion_bits manipulacion_bits.o -no-pie
*
* Ejecución:
*    ./manipulacion_bits
*
* Explicación del flujo:
* - msg1: Muestra el valor original del número en decimal (binario: 1010).
* - msg2: Muestra el valor después de establecer el bit 1 (segundo bit) usando OR.
* - msg3: Muestra el valor después de borrar el bit 1 (segundo bit) usando AND con máscara invertida.
* - msg4: Muestra el valor después de alternar el bit 3 (cuarto bit) usando XOR.
* - x19: Registro que almacena el valor original para las operaciones de bits.
* - x20: Registro que almacena el resultado después de establecer el bit 1.
* - x21: Registro que almacena el resultado después de borrar el bit 1.
* - x22: Registro que almacena el resultado después de alternar el bit 3.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int original = 10; // 1010 en binario
*     printf("Valor original en decimal (binario 1010): %d\n", original);
* 
*     // Establecer el bit 1
*     int set_bit = original | (1 << 1);  // OR con máscara 0010
*     printf("Después de establecer bit 1: %d\n", set_bit);
* 
*     // Borrar el bit 1
*     int clear_bit = original & ~(1 << 1);  // AND con máscara invertida 1101
*     printf("Después de borrar bit 1: %d\n", clear_bit);
* 
*     // Alternar el bit 3
*     int toggle_bit = original ^ (1 << 3);  // XOR con máscara 1000
*     printf("Después de alternar bit 3: %d\n", toggle_bit);
*     
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/SfD9OMqqAkHszVbDmxOnD1v0d
* Link de grabación gdb:
* https://asciinema.org/a/UVoevKZoEe9uYWj9KCwbjhHP6
***********************************************************************/

.global main
.text

main:
    // Guardamos el link register
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Inicializamos un número para manipular sus bits
    mov     x19, #10         // x19 = 10 (1010 en binario)

    // Imprimir valor original
    adr     x0, msg1
    mov     x1, x19
    bl      printf

    // ESTABLECER BIT (Usando OR)
    // Establecemos el bit 1 (segundo bit)
    // 1010 OR 0010 = 1010 (no cambia porque ya estaba en 1)
    mov     x20, x19        // Copiamos el valor original
    mov     x4, #2          // Creamos la máscara para el bit 1
    orr     x20, x20, x4    // Establecer bit 1
    
    // Imprimir resultado después de establecer bit
    adr     x0, msg2
    mov     x1, x20
    bl      printf

    // BORRAR BIT (Usando AND con máscara invertida)
    // Borramos el bit 1 (segundo bit)
    mov     x21, x19        // Copiamos el valor original
    mov     x4, #2          // Bit que queremos borrar
    mvn     x4, x4          // Invertimos la máscara
    and     x21, x21, x4    // Borrar bit 1
    
    // Imprimir resultado después de borrar bit
    adr     x0, msg3
    mov     x1, x21
    bl      printf

    // ALTERNAR BIT (Usando XOR)
    // Alternamos el bit 3 (cuarto bit)
    // 1010 XOR 1000 = 0010
    mov     x22, x19        // Copiamos el valor original
    mov     x4, #8          // Creamos la máscara para el bit 3
    eor     x22, x22, x4    // Alternar bit 3
    
    // Imprimir resultado después de alternar bit
    adr     x0, msg4
    mov     x1, x22
    bl      printf

    // Restauramos el stack y retornamos
    ldp     x29, x30, [sp], #16
    mov     w0, #0
    ret

.section .rodata
msg1:
    .string "Valor original en decimal (binario 1010): %d\n"
msg2:
    .string "Después de establecer bit 1: %d\n"
msg3:
    .string "Después de borrar bit 1: %d\n"
msg4:
    .string "Después de alternar bit 3: %d\n"
