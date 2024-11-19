/***********************************************************************
* Programa: Suma de Elementos en un Arreglo
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa calcula la suma de los elementos de un arreglo
*              de enteros y muestra cada elemento junto con el índice correspondiente.
*              Al final, imprime la suma total de los elementos. 
*
* Compilación:
*    as -o suma_arreglo.o suma_arreglo.s
*    gcc -o suma_arreglo suma_arreglo.o -no-pie
*
* Ejecución:
*    ./suma_arreglo
*
* Explicación del flujo:
* - format_result: Cadena de formato para `printf` que muestra el resultado final de la suma.
* - format_array: Cadena de formato para `printf` que muestra cada elemento del arreglo y su índice.
* - array: Arreglo de enteros con los elementos a sumar.
* - array_size: Tamaño del arreglo, que indica cuántos elementos sumar.
* - x19: Almacena la suma total de los elementos.
* - x20: Contador para iterar sobre el arreglo (índice).
* - x21: Dirección base del arreglo.
* - x22: Tamaño del arreglo (número de elementos).
* - x23: Valor actual del elemento `array[i]`.
*
* Funciones:
* - main: Controla el flujo principal del programa, inicializa variables, 
*         carga elementos del arreglo, suma los elementos y muestra cada 
*         elemento y el resultado final.
* - loop: Bucle que recorre el arreglo, muestra cada elemento y acumula la suma total.
* - print_result: Imprime el resultado final de la suma total.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int array[] = {10, 20, 30, 40, 50};
*     int array_size = 5;
*     int suma = 0;
*     
*     for (int i = 0; i < array_size; i++) {
*         printf("Elemento[%d] = %d\n", i, array[i]);
*         suma += array[i];
*     }
*     
*     printf("La suma del arreglo es: %d\n", suma);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/IoZtfr9ZsDnhJaK6KIyKUViC1
* Link de grabación gdb:
* https://asciinema.org/a/8TDlhWhx6ZOBKUmTTwjKQ3iSj
***********************************************************************/


.section .rodata
format_result: .asciz "La suma del arreglo es: %d\n"
format_array: .asciz "Elemento[%d] = %d\n"

.section .data
array: .word 10, 20, 30, 40, 50    // Arreglo de 5 elementos
array_size: .word 5                 // Tamaño del arreglo

.text
.global main
.type main, %function

main:
    // Prólogo de la función
    stp     x29, x30, [sp, -16]!   // Guardar frame pointer y link register
    mov     x29, sp                 // Establecer frame pointer
    
    // Guardar registros callee-saved
    stp     x19, x20, [sp, -16]!   // x19 = suma total, x20 = contador
    
    // Inicializar valores
    mov     x19, #0                 // suma = 0
    mov     x20, #0                 // i = 0
    
    // Cargar dirección del arreglo y su tamaño
    adrp    x21, array             
    add     x21, x21, :lo12:array   // x21 = dirección base del arreglo
    adrp    x22, array_size
    add     x22, x22, :lo12:array_size
    ldr     w22, [x22]             // w22 = tamaño del arreglo

loop:
    // Verificar si hemos terminado
    cmp     x20, x22
    b.ge    print_result
    
    // Cargar elemento actual
    ldr     w23, [x21, x20, lsl #2]  // w23 = array[i]
    
    // Imprimir elemento actual
    adrp    x0, format_array
    add     x0, x0, :lo12:format_array
    mov     x1, x20                // índice
    mov     x2, x23                // valor
    bl      printf
    
    // Sumar al total
    add     x19, x19, x23          // suma += array[i]
    
    // Incrementar contador
    add     x20, x20, #1           // i++
    b       loop

print_result:
    // Imprimir resultado final
    adrp    x0, format_result
    add     x0, x0, :lo12:format_result
    mov     x1, x19                // suma total
    bl      printf
    
    // Restaurar registros
    ldp     x19, x20, [sp], 16
    
    // Epílogo de la función
    mov     w0, #0                 // Valor de retorno
    ldp     x29, x30, [sp], 16
    ret

.size main, .-main
