/***********************************************************************
* Programa: Cálculo de Potencias
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa calcula la potencia de un número utilizando
*              multiplicaciones sucesivas. Calcula `base^exponente` 
*              (en este caso, 2^5) y muestra el resultado en pantalla con `printf`.
*              Si el exponente es 0, el resultado se establece en 1.
*
* Compilación:
*    as -o potencia.o potencia.s
*    gcc -o potencia potencia.o -no-pie
*
* Ejecución:
*    ./potencia
*
* Explicación del flujo:
* - format: Cadena de formato para `printf` que muestra el resultado en el 
*           formato `base^exponente = resultado`.
* - x19: Almacena la base para el cálculo de la potencia.
* - x20: Contador del exponente decreciente durante el cálculo.
* - x21: Registro donde se almacena el resultado de `base^exponente`.
* - x22: Guarda el valor original del exponente para la impresión final.
*
* Funciones:
* - main: Controla el flujo principal, incluyendo la inicialización de valores, 
*         cálculo de la potencia mediante un bucle, y la impresión del resultado.
* - loop: Bucle que multiplica `resultado` por `base` tantas veces como 
*         indique el `exponente`, decrementándolo en cada iteración.
* - print_result: Imprime el resultado final utilizando `printf`.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int base = 2;
*     int exponente = 5;
*     int resultado = 1;
*     
*     for (int i = 0; i < exponente; i++) {
*         resultado *= base;
*     }
*     
*     printf("%d^%d = %d\n", base, exponente, resultado);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/AHxY2PbYUsb8xRe2bccUjajYo
* Link de grabación gdb:
* https://asciinema.org/a/5TmgizQ9HJATg1d6zsgnwocLz
***********************************************************************/

.section .rodata
format: .asciz "%d^%d = %d\n"

.text
.global main
.type main, %function

main:
    // Prólogo de la función
    stp     x29, x30, [sp, -16]!   // Guardar frame pointer y link register
    mov     x29, sp                 // Establecer frame pointer
    
    // Guardar registros callee-saved
    stp     x19, x20, [sp, -16]!
    stp     x21, x22, [sp, -16]!
    
    // Inicializar valores
    mov     x19, #2                 // base = 2
    mov     x20, #5                 // exponente = 5
    mov     x21, #1                 // resultado = 1
    mov     x22, x20               // guardar exponente original
    
    // Si el exponente es 0, saltar al final
    cbz     x20, print_result
    
loop:
    // Multiplicar resultado por base
    mul     x21, x21, x19          // resultado *= base
    
    // Decrementar contador y continuar si no es cero
    subs    x20, x20, #1           // exponente--
    b.ne    loop                   // si no es cero, continuar loop
    
print_result:
    // Cargar dirección del formato
    adrp    x0, format             // Cargar página de la dirección
    add     x0, x0, :lo12:format   // Añadir el offset dentro de la página
    mov     x1, x19                // base
    mov     x2, x22                // exponente original
    mov     x3, x21                // resultado
    bl      printf
    
    // Restaurar registros callee-saved
    ldp     x21, x22, [sp], 16
    ldp     x19, x20, [sp], 16
    
    // Epílogo de la función
    mov     w0, #0                 // Valor de retorno
    ldp     x29, x30, [sp], 16
    ret

.size main, .-main
