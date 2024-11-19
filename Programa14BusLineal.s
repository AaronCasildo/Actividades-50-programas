/***********************************************************************
* Programa: Buscar un Número en un Arreglo en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa busca un número específico en un arreglo de
*              enteros, imprime el arreglo, luego busca el número
*              especificado y muestra un mensaje indicando si fue encontrado
*              o no, junto con su posición en el arreglo.
* 
* Compilación:
*    as -o buscar_num.o buscar_num.s
*    gcc -o buscar_num buscar_num.o -no-pie
*
* Ejecución:
*    ./buscar_num
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long arreglo[] = {15, 7, 23, 9, 12, 3, 18, 45, 6, 11};
*     int longitud = 10;
*     long buscar = 18;
*     int encontrado = -1;
*     
*     printf("Arreglo: ");
*     for (int i = 0; i < longitud; i++) {
*         printf("%ld ", arreglo[i]);
*     }
*     
*     printf("\nBuscando el número: %ld\n", buscar);
*     for (int i = 0; i < longitud; i++) {
*         if (arreglo[i] == buscar) {
*             printf("Número encontrado en la posición: %d\n", i);
*             encontrado = 1;
*             break;
*         }
*     }
*     
*     if (encontrado == -1) {
*         printf("Número no encontrado en el arreglo\n");
*     }
*     
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/DTPLjSM4HqD593KSXpzmnCg5P
* Link de grabación gdb:
* https://asciinema.org/a/GC9vuobtxvM80ukgWAsIVH5dg
***********************************************************************/

.data
arreglo:    .quad   15, 7, 23, 9, 12, 3, 18, 45, 6, 11  // Arreglo de números
longitud:   .quad   10                                   // Longitud del arreglo
buscar:     .quad   18                                   // Número a buscar
msg_arr:    .asciz  "Arreglo: "
msg_num:    .asciz  "%ld "                              // Formato para imprimir números
msg_buscar: .asciz  "\nBuscando el número: %ld\n"       // Mensaje para número a buscar
msg_enc:    .asciz  "Número encontrado en la posición: %ld\n" // Mensaje cuando se encuentra
msg_no_enc: .asciz  "Número no encontrado en el arreglo\n"    // Mensaje cuando no se encuentra
newline:    .asciz  "\n"

.text
.global main

main:
    // Prólogo
    stp     x29, x30, [sp, -48]!   // Guarda el frame pointer y link register
    mov     x29, sp                 // Establece el frame pointer

    // Imprimir mensaje inicial
    ldr     x0, =msg_arr
    bl      printf

    // Inicializar variables
    ldr     x19, =arreglo           // x19 = dirección base del arreglo
    ldr     x20, =longitud          // Cargar dirección de longitud
    ldr     x20, [x20]              // x20 = longitud del arreglo
    mov     x21, #0                 // x21 = contador (i)
    
    // Imprimir todos los números del arreglo
print_loop:
    cmp     x21, x20
    bge     print_done              // Si i >= longitud, terminar impresión
    
    // Imprimir número actual
    ldr     x0, =msg_num
    ldr     x1, [x19, x21, lsl #3] // Cargar arreglo[i]
    bl      printf
    
    add     x21, x21, #1           // i++
    b       print_loop
    
print_done:
    // Imprimir el número que vamos a buscar
    ldr     x0, =msg_buscar
    ldr     x1, =buscar
    ldr     x1, [x1]               // Cargar número a buscar
    bl      printf

    // Inicializar búsqueda
    mov     x21, #0                // x21 = contador = 0
    ldr     x22, =buscar           // Cargar dirección del número a buscar
    ldr     x22, [x22]             // x22 = número a buscar

search_loop:
    cmp     x21, x20
    bge     not_found              // Si i >= longitud, número no encontrado
    
    // Cargar y comparar elemento actual
    ldr     x23, [x19, x21, lsl #3]  // x23 = arreglo[i]
    cmp     x23, x22
    beq     found                  // Si son iguales, número encontrado
    
    add     x21, x21, #1           // i++
    b       search_loop

found:
    // Imprimir mensaje de éxito con la posición
    ldr     x0, =msg_enc
    mov     x1, x21
    bl      printf
    b       done

not_found:
    // Imprimir mensaje de no encontrado
    ldr     x0, =msg_no_enc
    bl      printf

done:
    // Epílogo y retorno
    mov     w0, #0
    ldp     x29, x30, [sp], 48     // Restaura el frame pointer y link register
    ret                            // Retorna al sistema operativo
