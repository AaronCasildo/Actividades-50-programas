/***********************************************************************
* Programa: Medición de Tiempo de Ejecución
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa mide el tiempo de ejecución de una función
*              personalizada utilizando la llamada al sistema `clock_gettime`. 
*              Calcula la diferencia en nanosegundos entre el tiempo inicial 
*              y final, mostrando el resultado del cálculo y el tiempo 
*              transcurrido. Este programa es útil para evaluar el rendimiento 
*              de funciones en entornos de bajo nivel.
*
* Compilación:
*    as -o medir_tiempo.o medir_tiempo.s
*    gcc -o medir_tiempo medir_tiempo.o -no-pie -lrt
*
* Ejecución:
*    ./medir_tiempo
*
* Explicación del flujo:
* - msg_start: Mensaje que indica el inicio de la medición de tiempo.
* - msg_end: Mensaje que indica que la función ha completado su ejecución.
* - msg_time: Mensaje que muestra el tiempo transcurrido en nanosegundos.
* - msg_result: Mensaje que muestra el resultado del cálculo realizado por la función.
* - CLOCK_MONOTONIC: Constante utilizada para especificar el reloj monotónico con `clock_gettime`.
* - start_time, end_time: Estructuras de tipo `timespec` para almacenar los tiempos inicial y final.
* - billion: Constante utilizada para convertir segundos a nanosegundos.
*
* Variables y registros clave:
* - x0: Registro utilizado para pasar argumentos y recibir valores de retorno.
* - x19, x20: Registros temporales utilizados dentro de la función medida.
* - x2, x3: Registros utilizados para calcular la diferencia en nanosegundos.
*
* Funciones:
* - main: Controla el flujo principal del programa, midiendo el tiempo de ejecución 
*         de `test_function` y mostrando los resultados.
* - test_function: Función personalizada cuyo tiempo de ejecución es medido. 
*                  Realiza un bucle de operaciones básicas como multiplicación y división.
*
* Flujo del Programa:
* 1. Se muestra un mensaje indicando el inicio de la medición.
* 2. Se obtiene el tiempo inicial utilizando `clock_gettime`.
* 3. Se ejecuta la función `test_function` cuya duración será medida.
* 4. Se obtiene el tiempo final utilizando `clock_gettime`.
* 5. Se calcula la diferencia entre los tiempos inicial y final, en nanosegundos.
* 6. Se muestra el tiempo transcurrido y el resultado de la función.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #include <time.h>
* 
* void test_function() {
*     long result = 0;
*     for (long i = 1; i <= 1000000; i++) {
*         result += (i * i) / i;  // Operaciones simples
*     }
* }
* 
* int main() {
*     struct timespec start, end;
*     long nanoseconds;
*     
*     printf("\n⏱️  Iniciando medición de tiempo...\n");
*     clock_gettime(CLOCK_MONOTONIC, &start);
*     
*     test_function();
*     
*     clock_gettime(CLOCK_MONOTONIC, &end);
*     printf("\n✅ Función completada.\n");
*     
*     nanoseconds = (end.tv_sec - start.tv_sec) * 1000000000L +
*                   (end.tv_nsec - start.tv_nsec);
*     printf("⌚ Tiempo de ejecución: %ld nanosegundos\n", nanoseconds);
*     printf("📊 Resultado del cálculo: %ld\n", result);
*     
*     return 0;
* }
*
* Link de grabación de asciinema:
* https://asciinema.org/a/UTp2414NL2ONHJ6HhHq2VuNHp
* Link de grabación gdb:
* https://asciinema.org/a/F1RjTKewtYTUV9RcokbdF0jiG
***********************************************************************/

.data
    msg_start:  .asciz "\n⏱️  Iniciando medición de tiempo...\n"
    msg_end:    .asciz "\n✅ Función completada.\n"
    msg_time:   .asciz "⌚ Tiempo de ejecución: %ld nanosegundos\n"
    msg_time_ms:.asciz "⌚ Tiempo en milisegundos: %ld.%03ld\n"
    msg_result: .asciz "📊 Resultado del cálculo: %ld\n"
    // Constantes
    .equ CLOCK_MONOTONIC, 1
    
    // Valores para cálculos temporales
    billion: .quad 1000000000
    million: .quad 1000000
    thousand: .quad 1000
    
    // Estructura timespec para clock_gettime
    .align 8
    start_time: .space 16    // Estructura para tiempo inicial
    end_time:   .space 16    // Estructura para tiempo final

.text
.global main
.extern printf
.extern clock_gettime

// Función que queremos medir
test_function:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    
    mov x0, #0          // Inicializar contador
    mov x19, #1000      // Para construir 1000000
    mov x20, #1000
    mul x1, x19, x20    // x1 = 1000000
    
loop:
    add x0, x0, #1      // Incrementar contador
    mul x2, x0, x0      // Multiplicar por sí mismo
    udiv x2, x2, x0     // Dividir por el contador
    sub x1, x1, #1      // Decrementar iteraciones
    cbnz x1, loop       // Continuar si no hemos terminado
    
    ldp x29, x30, [sp], #16
    ret

main:
    stp x29, x30, [sp, -32]!
    mov x29, sp
    
    // Imprimir mensaje de inicio
    adrp x0, msg_start
    add x0, x0, :lo12:msg_start
    bl printf
    
    // Obtener tiempo inicial
    mov w0, #CLOCK_MONOTONIC
    adrp x1, start_time
    add x1, x1, :lo12:start_time
    bl clock_gettime
    
    // Ejecutar la función a medir
    bl test_function
    str x0, [sp, #16]   // Guardar resultado
    
    // Obtener tiempo final
    mov w0, #CLOCK_MONOTONIC
    adrp x1, end_time
    add x1, x1, :lo12:end_time
    bl clock_gettime
    
    // Imprimir mensaje de finalización
    adrp x0, msg_end
    add x0, x0, :lo12:msg_end
    bl printf
    
    // Calcular diferencia de tiempo
    adrp x0, end_time
    add x0, x0, :lo12:end_time
    ldr x2, [x0]        // Cargar segundos final
    ldr x3, [x0, #8]    // Cargar nanosegundos final
    
    adrp x0, start_time
    add x0, x0, :lo12:start_time
    ldr x4, [x0]        // Cargar segundos inicial
    ldr x5, [x0, #8]    // Cargar nanosegundos inicial
    
    // Calcular diferencia
    sub x2, x2, x4      // Diferencia en segundos
    sub x3, x3, x5      // Diferencia en nanosegundos
    
    // Convertir segundos a nanosegundos y sumar
    adrp x0, billion
    add x0, x0, :lo12:billion
    ldr x4, [x0]        // Cargar 1000000000
    mul x2, x2, x4      // Convertir segundos a nanosegundos
    add x3, x3, x2      // x3 contiene el total de nanosegundos
    
    // Imprimir tiempo en nanosegundos
    adrp x0, msg_time
    add x0, x0, :lo12:msg_time
    mov x1, x3
    bl printf
    
    // Calcular milisegundos
    mov x1, x3          // Copiar nanosegundos
    adrp x0, million
    add x0, x0, :lo12:million
    ldr x2, [x0]        // Cargar 1000000
    udiv x4, x1, x2     // Parte entera de milisegundos
    msub x5, x4, x2, x1 // Resto en nanosegundos
    
    adrp x0, thousand
    add x0, x0, :lo12:thousand
    ldr x2, [x0]        // Cargar 1000
    udiv x5, x5, x2     // Convertir resto a microsegundos
    
    // Imprimir tiempo en milisegundos
    adrp x0, msg_time_ms
    add x0, x0, :lo12:msg_time_ms
    mov x1, x4          // Milisegundos
    mov x2, x5          // Microsegundos
    bl printf
    
    // Mostrar resultado del cálculo
    adrp x0, msg_result
    add x0, x0, :lo12:msg_result
    ldr x1, [sp, #16]   // Cargar resultado guardado
    bl printf
    
    // Salir
    mov w0, #0
    ldp x29, x30, [sp], #32
    ret
