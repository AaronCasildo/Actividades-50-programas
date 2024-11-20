/***********************************************************************
* Programa: Generador de Números Aleatorios (LCG)
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa genera una secuencia de números aleatorios 
*              utilizando el algoritmo **Linear Congruential Generator (LCG)**.
*              El usuario ingresa una semilla inicial y la cantidad de números
*              a generar. Los números generados están en el rango 1-100.
*              En caso de error en la entrada, se muestra un mensaje adecuado.
*
* Compilación:
*    as -o generador_lcg.o generador_lcg.s
*    gcc -o generador_lcg generador_lcg.o -no-pie
*
* Ejecución:
*    ./generador_lcg
*
* Explicación del flujo:
* - prompt_seed: Solicita al usuario ingresar una semilla inicial.
* - prompt_count: Solicita al usuario la cantidad de números a generar.
* - result_fmt: Formato para mostrar cada número aleatorio con su índice.
* - error_msg: Mensaje mostrado en caso de entrada inválida.
* - multiplier, increment, modulus: Constantes del generador LCG.
* - range_mod: Constante utilizada para ajustar los números generados al rango 1-100.
*
* Variables y registros clave:
* - x19: Almacena el valor actual de la semilla durante la generación.
* - x20: Almacena la cantidad de números a generar.
* - x21: Contador para los números generados.
* - x22: Constante `a` (multiplicador) del generador LCG.
* - x23: Constante `c` (incremento) del generador LCG.
* - x24: Constante `m` (módulo) del generador LCG.
* - x25: Constante `100` para ajustar los números al rango 1-100.
* - x28: Número generado en el rango 1-100.
*
* Funciones:
* - main: Controla el flujo principal del programa, incluyendo la lectura de entradas, 
*         configuración del generador LCG, generación de números, y manejo de errores.
* - generate_loop: Genera números aleatorios utilizando la fórmula del LCG y los ajusta al rango deseado.
* - input_error: Maneja los errores de entrada mostrando un mensaje y saliendo del programa.
*
* Flujo del Programa:
* 1. Solicitar al usuario que ingrese una semilla inicial (`prompt_seed`).
* 2. Solicitar al usuario que indique cuántos números desea generar (`prompt_count`).
* 3. Validar las entradas y configurar las constantes del generador LCG.
* 4. Generar números aleatorios usando la fórmula del LCG:
*    - \( X_{n+1} = (a \cdot X_n + c) \mod m \)
*    - Ajustar cada número al rango \( [1, 100] \).
* 5. Mostrar cada número generado junto con su índice en la secuencia (`result_fmt`).
* 6. Manejar errores de entrada con un mensaje adecuado (`error_msg`).
*
* Fórmula del Generador LCG:
* ----------------------------------------------------
* - Fórmula: \( X_{n+1} = (a \cdot X_n + c) \mod m \)
* - Parámetros:
*   - \( a = 1103515245 \) (Multiplicador)
*   - \( c = 12345 \) (Incremento)
*   - \( m = 2^{31} \) (Módulo, 2147483648)
* - Ajuste al rango 1-100:
*   - \( X_{\text{ajustado}} = (X \mod 100) + 1 \)
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     long semilla, cantidad, xn, num;
*     const long a = 1103515245, c = 12345, m = 2147483648;
* 
*     printf("Ingrese una semilla (numero entero): ");
*     if (scanf("%ld", &semilla) != 1) {
*         printf("Error: Ingrese un numero valido\n");
*         return 1;
*     }
* 
*     printf("Cuantos numeros desea generar? ");
*     if (scanf("%ld", &cantidad) != 1) {
*         printf("Error: Ingrese un numero valido\n");
*         return 1;
*     }
* 
*     xn = semilla;
*     for (long i = 1; i <= cantidad; i++) {
*         xn = (a * xn + c) % m;
*         num = (xn % 100) + 1; // Ajustar al rango 1-100
*         printf("Numero aleatorio %ld: %ld (en rango 1-100)\n", i, num);
*     }
*     return 0;
* }
*
* Link de grabación asciinema con gdb:
* https://asciinema.org/a/OJHwARqnvoTSp6yhJEnbjUtdM
***********************************************************************/

.data
    prompt_seed:    .string "Ingrese una semilla (numero entero): "
    prompt_count:   .string "Cuantos numeros desea generar? "
    result_fmt:     .string "Numero aleatorio %d: %d (en rango 1-100)\n"
    input_fmt:      .string "%ld"
    error_msg:      .string "Error: Ingrese un numero valido\n"
    newline:        .string "\n"

    // Constantes para el generador LCG
    .align 8
    multiplier:     .dword 1103515245    // a
    increment:      .dword 12345         // c
    modulus:        .dword 2147483648    // m (2^31)
    range_mod:      .dword 100           // Para obtener números entre 1-100

.text
.global main

// Función principal
main:
    // Prólogo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    
    // Reservar espacio para variables locales
    sub     sp, sp, #32     // Espacio para semilla y contador
    
    // Solicitar semilla
    adr     x0, prompt_seed
    bl      printf
    
    // Leer semilla
    adr     x0, input_fmt
    mov     x1, sp          // Guardar semilla en [sp]
    bl      scanf
    
    // Verificar lectura exitosa
    cmp     x0, #1
    b.ne    input_error
    
    // Solicitar cantidad de números
    adr     x0, prompt_count
    bl      printf
    
    // Leer cantidad
    adr     x0, input_fmt
    add     x1, sp, #8      // Guardar contador en [sp + 8]
    bl      scanf
    
    // Verificar lectura exitosa
    cmp     x0, #1
    b.ne    input_error
    
    // Inicializar registros para el generador
    ldr     x19, [sp]           // Semilla actual
    ldr     x20, [sp, #8]       // Contador
    mov     x21, #1             // Contador de números generados
    
    // Cargar constantes
    adr     x22, multiplier
    ldr     x22, [x22]          // a
    adr     x23, increment
    ldr     x23, [x23]          // c
    adr     x24, modulus
    ldr     x24, [x24]          // m
    adr     x25, range_mod
    ldr     x25, [x25]          // 100 para rango 1-100

generate_loop:
    // Verificar si hemos generado todos los números
    cmp     x21, x20
    b.gt    end_program
    
    // Generar siguiente número usando LCG
    // Xn+1 = (a * Xn + c) mod m
    mul     x26, x22, x19       // a * Xn
    add     x26, x26, x23       // + c
    udiv    x27, x26, x24       // División para obtener módulo
    msub    x19, x27, x24, x26  // Xn+1 = resultado mod m
    
    // Convertir a rango 1-100
    udiv    x27, x19, x25       // División por 100
    msub    x28, x27, x25, x19  // Obtener módulo
    add     x28, x28, #1        // +1 para rango 1-100
    
    // Imprimir número generado
    adr     x0, result_fmt
    mov     x1, x21             // Número de secuencia
    mov     x2, x28             // Número generado
    bl      printf
    
    // Incrementar contador
    add     x21, x21, #1
    b       generate_loop

input_error:
    adr     x0, error_msg
    bl      printf
    mov     w0, #1
    b       cleanup

end_program:
    mov     w0, #0

cleanup:
    // Epílogo
    add     sp, sp, #32
    ldp     x29, x30, [sp], #16
    ret
