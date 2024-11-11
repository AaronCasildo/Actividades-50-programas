/***********************************************************************
* Programa: Serie de Fibonacci en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Genera y muestra los primeros 8 números de la serie de Fibonacci.
*              El programa imprime cada número en la consola.
*
* Compilación:
*    as -o fibonacci.o fibonacci.s
*    gcc -o fibonacci fibonacci.o -no-pie
*
* Ejecución:
*    ./fibonacci
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long fib[8] = {0, 1}; 
*     for (int i = 2; i < 8; i++) {
*         fib[i] = fib[i-1] + fib[i-2];
*     }
*     
*     printf("Serie de Fibonacci:\n");
*     for (int i = 0; i < 8; i++) {
*         printf("%ld ", fib[i]);
*     }
*     printf("\n");
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/1GWjBgeo62dUNhyft2cwRNA1S
***********************************************************************/

.data
    msg_titulo:     .asciz "Serie de Fibonacci:\n"   // Título de la serie de Fibonacci
    msg_numero:     .asciz "%ld "                    // Formato para imprimir cada número
    msg_newline:    .asciz "\n"                      // Salto de línea
    cantidad:       .quad 8                          // Cantidad de números a generar

.text
.global main
main:
    // Prólogo
    stp     x29, x30, [sp, -48]!   // Reservamos espacio para variables locales
    mov     x29, sp                // Establecemos el puntero de marco

    // Imprimir título de la serie de Fibonacci
    ldr     x0, =msg_titulo        // Cargar dirección del título
    bl      printf                 // Llamada a printf para imprimir el título

    // Inicializar los primeros dos números de Fibonacci
    mov     x19, #0                // Primer número (F0)
    mov     x20, #1                // Segundo número (F1)
    
    // Imprimir el primer número (0)
    ldr     x0, =msg_numero        // Cargar formato para imprimir número
    mov     x1, x19                // Poner F0 en x1
    bl      printf                 // Llamada a printf para imprimir F0

    // Imprimir el segundo número (1)
    ldr     x0, =msg_numero        // Cargar formato para imprimir número
    mov     x1, x20                // Poner F1 en x1
    bl      printf                 // Llamada a printf para imprimir F1

    // Inicializar el contador para el bucle
    mov     x21, #2                // Empezamos desde el tercer número
    ldr     x22, =cantidad         // Cargar la dirección de la cantidad total (8)
    ldr     x22, [x22]             // Cargar el valor de cantidad (8)

fibonacci_loop:
    // Verificar si hemos alcanzado la cantidad deseada
    cmp     x21, x22               // Comparar contador con la cantidad total
    bge     done                   // Si el contador es mayor o igual, salimos

    // Calcular el siguiente número de Fibonacci (F[n] = F[n-1] + F[n-2])
    mov     x23, x20               // Guardar F[n-1] en un registro temporal
    add     x20, x19, x20          // F[n-1] = F[n-2] + F[n-1]
    mov     x19, x23               // F[n-2] = Valor temporal de F[n-1]

    // Imprimir el número actual de Fibonacci
    ldr     x0, =msg_numero        // Cargar formato para imprimir número
    mov     x1, x20                // Poner el nuevo número de Fibonacci en x1
    bl      printf                 // Llamada a printf para imprimir el número

    // Incrementar el contador
    add     x21, x21, #1           // Incrementar el contador de números generados
    b       fibonacci_loop         // Volver al inicio del bucle

done:
    // Imprimir salto de línea final
    ldr     x0, =msg_newline       // Cargar salto de línea
    bl      printf                 // Llamada a printf para imprimir el salto de línea

    // Epílogo y retorno
    mov     w0, #0                 // Código de retorno (0)
    ldp     x29, x30, [sp], 48     // Restaurar el puntero de marco y el registro de enlace
    ret                            // Retornar al sistema operativo
