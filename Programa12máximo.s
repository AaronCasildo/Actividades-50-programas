/***********************************************************************
* Programa: Búsqueda del Valor Máximo en un Arreglo en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa recibe un arreglo de números enteros, 
*              imprime los elementos del arreglo y luego determina 
*              cuál es el valor máximo en el arreglo. Finalmente, 
*              imprime el valor máximo encontrado.
*              Implementado en ARM64 Assembly para RaspbianOS.
* 
* Compilación:
*    as -o max_val.o max_val.s
*    gcc -o max_val max_val.o -no-pie
*
* Ejecución:
*    ./max_val
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long arreglo[] = {15, 7, 23, 9, 12, 3, 18, 45, 6, 11};
*     int longitud = 10;
*     long max = arreglo[0];
*     for (int i = 0; i < longitud; i++) {
*         printf("%ld ", arreglo[i]);
*         if (arreglo[i] > max) {
*             max = arreglo[i];
*         }
*     }
*     printf("\nEl máximo es: %ld\n", max);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/HjNIauNGBT0aR0nEj5N6ftQDw
* Link de grabación gdb:
* https://asciinema.org/a/DY1PTl4237vvGjrpbP0KPVTqJ
***********************************************************************/

.data
    arreglo:    .quad   15, 7, 23, 9, 12, 3, 18, 45, 6, 11  // Arreglo de números
    longitud:   .quad   10                                   // Longitud del arreglo
    msg_arr:    .asciz  "Arreglo: "
    msg_num:    .asciz  "%ld "                              // Formato para imprimir números
    msg_max:    .asciz  "\nEl máximo es: %ld\n"            // Mensaje para el máximo
    newline:    .asciz  "\n"

.text
.global main

main:
    // Prólogo
    stp     x29, x30, [sp, -48]!       // Guarda el frame pointer y link register
    mov     x29, sp                    // Establece el frame pointer

    // Imprimir mensaje inicial
    ldr     x0, =msg_arr               // Carga el mensaje de "Arreglo: "
    bl      printf                     // Imprime el mensaje

    // Inicializar variables
    ldr     x19, =arreglo              // x19 = dirección base del arreglo
    ldr     x20, =longitud             // Cargar dirección de longitud
    ldr     x20, [x20]                 // x20 = longitud del arreglo
    mov     x21, #0                    // x21 = contador (i)
    
    // Imprimir todos los números del arreglo
print_loop:
    cmp     x21, x20                   // Compara i con la longitud
    bge     print_done                 // Si i >= longitud, terminar impresión
    
    // Imprimir número actual
    ldr     x0, =msg_num               // Carga el formato de número
    ldr     x1, [x19, x21, lsl #3]     // Carga arreglo[i] (considerando 8 bytes por número)
    bl      printf                     // Imprime el número actual
    
    add     x21, x21, #1               // Incrementar contador (i++)
    b       print_loop                 // Continuar el bucle

print_done:
    // Inicializar máximo con el primer elemento
    ldr     x22, [x19]                 // x22 = máximo = arreglo[0]
    mov     x21, #1                    // x21 = contador = 1 (empezamos desde el segundo elemento)

find_max_loop:
    cmp     x21, x20                   // Compara i con la longitud
    bge     find_max_done              // Si i >= longitud, terminar búsqueda
    
    // Cargar elemento actual
    ldr     x23, [x19, x21, lsl #3]     // Carga arreglo[i]
    
    // Comparar con el máximo actual
    cmp     x23, x22                   // Compara arreglo[i] con el máximo
    ble     not_larger                 // Si arreglo[i] <= máximo, continuar
    mov     x22, x23                   // Si arreglo[i] > máximo, actualizar máximo
    
not_larger:
    add     x21, x21, #1               // Incrementar contador (i++)
    b       find_max_loop              // Continuar el bucle

find_max_done:
    // Imprimir el máximo
    ldr     x0, =msg_max               // Carga el mensaje de máximo
    mov     x1, x22                    // Pasa el máximo como argumento
    bl      printf                     // Imprime el máximo

    // Epílogo y retorno
    mov     w0, #0                     // Código de retorno 0
    ldp     x29, x30, [sp], 48         // Restaura el frame pointer y link register
    ret                                // Retorna al sistema operativo
