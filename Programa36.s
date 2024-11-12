/***********************************************************************
* Programa: Buscador del Segundo Número Mayor en un Arreglo
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa encuentra e imprime el segundo número mayor 
*              de un arreglo de enteros. Primero muestra los elementos del 
*              arreglo y luego realiza la búsqueda del segundo mayor usando
*              una comparación iterativa. Si el arreglo tiene menos de 2 
*              elementos, muestra un mensaje de error.
*
* Compilación:
*    as -o segundo_mayor.o segundo_mayor.s
*    gcc -o segundo_mayor segundo_mayor.o -no-pie
*
* Ejecución:
*    ./segundo_mayor
*
* Explicación del flujo:
* - msg_titulo: Muestra el título del programa.
* - msg_array: Mensaje inicial que indica que se imprimirá el arreglo.
* - msg_result: Muestra el segundo número más grande encontrado.
* - msg_error: Mensaje de error si el arreglo tiene menos de 2 elementos.
* - format_int: Formato para imprimir cada entero del arreglo.
* - array: Arreglo de enteros sobre el que se realizará la búsqueda.
* - array_size: Tamaño del arreglo.
* - x19: Registro que almacena la dirección base del arreglo.
* - x20: Registro que almacena el tamaño del arreglo.
* - w21: Contador para iterar sobre los elementos del arreglo.
* - w22: Almacena el primer (mayor) valor encontrado en el arreglo.
* - w23: Almacena el segundo valor más grande encontrado en el arreglo.
* - w24: Registro temporal para el valor actual en cada iteración del arreglo.
*
* Funciones:
* - print_loop: Imprime todos los elementos del arreglo en pantalla.
* - find_loop: Realiza la búsqueda del primer y segundo mayor en el arreglo.
* - check_second: Compara el valor actual con el segundo mayor para actualizar si corresponde.
* - error: Muestra un mensaje de error si el tamaño del arreglo es insuficiente.
* - show_result: Imprime el segundo mayor encontrado en el arreglo.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int array[] = {15, 8, 23, 42, 4, 16, 55, 37, 11, 22};
*     int size = 10;
*     
*     if (size < 2) {
*         printf("❌ Error: El arreglo debe tener al menos 2 elementos\n");
*         return 1;
*     }
* 
*     printf("📊 Arreglo actual: ");
*     for (int i = 0; i < size; i++) {
*         printf("%d ", array[i]);
*     }
*     printf("\n");
* 
*     int max1 = array[0];
*     int max2 = array[0];
*     for (int i = 1; i < size; i++) {
*         if (array[i] > max1) {
*             max2 = max1;
*             max1 = array[i];
*         } else if (array[i] > max2 && array[i] != max1) {
*             max2 = array[i];
*         }
*     }
* 
*     printf("✨ El segundo número más grande es: %d\n", max2);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/EABhF8H6o7tNN4ce7NmT4YI8E
***********************************************************************/


.data
    // Mensajes del programa
    msg_titulo:  .asciz "🔍 Buscador del Segundo Número Mayor\n"
    msg_array:   .asciz "📊 Arreglo actual: "
    msg_result:  .asciz "✨ El segundo número más grande es: %d\n"
    msg_error:   .asciz "❌ Error: El arreglo debe tener al menos 2 elementos\n"
    format_int:  .asciz "%d "    // Formato para imprimir enteros
    newline:     .asciz "\n"
    
    // Arreglo de ejemplo y su tamaño
    .align 4
    array:      .word  15, 8, 23, 42, 4, 16, 55, 37, 11, 22  // Ejemplo: 10 números
    array_size: .word  10
    
.text
.global main
.extern printf

main:
    // Prólogo
    stp x29, x30, [sp, -16]!
    mov x29, sp
    
    // Imprimir título
    adrp x0, msg_titulo
    add x0, x0, :lo12:msg_titulo
    bl printf
    
    // Cargar dirección y tamaño del array
    adrp x19, array
    add x19, x19, :lo12:array    // x19 = dirección base del array
    adrp x20, array_size
    add x20, x20, :lo12:array_size
    ldr w20, [x20]               // w20 = tamaño del array
    
    // Verificar que el array tenga al menos 2 elementos
    cmp w20, #2
    blt error
    
    // Mostrar arreglo actual
    adrp x0, msg_array
    add x0, x0, :lo12:msg_array
    bl printf
    
    // Imprimir elementos del array
    mov w21, #0                  // w21 = contador
print_loop:
    cmp w21, w20
    beq end_print
    
    adrp x0, format_int
    add x0, x0, :lo12:format_int
    ldr w1, [x19, w21, SXTW #2]  // Cargar elemento actual
    bl printf
    
    add w21, w21, #1
    b print_loop
    
end_print:
    // Nueva línea después de imprimir array
    adrp x0, newline
    add x0, x0, :lo12:newline
    bl printf
    
    // Inicializar variables para búsqueda
    ldr w22, [x19]              // w22 = primer máximo
    mov w23, w22                // w23 = segundo máximo
    mov w21, #1                 // w21 = índice para recorrer
    
find_loop:
    cmp w21, w20                // Comparar con tamaño del array
    beq show_result
    
    ldr w24, [x19, w21, SXTW #2]  // w24 = elemento actual
    
    // Comparar con máximo actual
    cmp w24, w22
    blt check_second            // Si es menor, ver si es segundo máximo
    
    // Actualizar máximos
    mov w23, w22               // Anterior máximo pasa a ser segundo
    mov w22, w24              // Nuevo máximo encontrado
    b next_iter
    
check_second:
    cmp w24, w23              // Comparar con segundo máximo
    ble next_iter            // Si es menor o igual, siguiente iteración
    mov w23, w24            // Actualizar segundo máximo
    
next_iter:
    add w21, w21, #1
    b find_loop
    
error:
    adrp x0, msg_error
    add x0, x0, :lo12:msg_error
    bl printf
    mov w0, #1
    b exit
    
show_result:
    adrp x0, msg_result
    add x0, x0, :lo12:msg_result
    mov w1, w23                // Pasar segundo máximo como argumento
    bl printf
    mov w0, #0
    
exit:
    // Epílogo
    ldp x29, x30, [sp], #16
    ret
