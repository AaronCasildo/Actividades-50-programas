/***********************************************************************
* Programa: Conversión de Temperatura en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Convierte una temperatura en Celsius a Fahrenheit usando
*              ARM64 Assembly en RaspbianOS. Solicita al usuario una
*              entrada en Celsius y muestra la salida en Fahrenheit.
* Compilación:
*    as -o temperatura.o temperatura.s
*    gcc -o temperatura temperatura.o -no-pie
*
* Ejecución:
*    ./temperatura
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     float celsius, fahrenheit;
*     printf("Ingresa la temperatura en Celsius: ");
*     scanf("%f", &celsius);
*     fahrenheit = (celsius * 9.0 / 5.0) + 32.0;
*     printf("Temperatura en Fahrenheit: %.2f\n", fahrenheit);
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/EgD2S9uGQSfFB98wcwaJD9LFh
***********************************************************************/

.data
    prompt:     .string "Ingresa la temperatura en Celsius: "
    scan_fmt:   .string "%f"                               // Formato para scanf
    print_fmt:  .string "Temperatura en Fahrenheit: %.2f\n" // Formato para printf
    celsius:    .single 0.0                                // Variable para entrada Celsius
    fahrenheit: .single 0.0                                // Variable para resultado Fahrenheit
    // Constantes para cálculo
    const_nine:      .single 9.0
    const_five:      .single 5.0
    const_thirtytwo: .single 32.0

.text
    .global main
    main:
    // Prólogo
    stp     x29, x30, [sp, #-16]!    // Guarda el frame pointer y link register
    mov     x29, sp                  // Establece el frame pointer

    // Mostrar prompt
    adr     x0, prompt
    bl      printf

    // Leer temperatura en Celsius
    adr     x0, scan_fmt             // Formato para scanf
    adr     x1, celsius              // Dirección de almacenamiento de entrada
    bl      scanf

    // Cargar valor ingresado y constantes
    adr     x0, celsius
    ldr     s0, [x0]                 // Carga temperatura Celsius
    
    adr     x0, const_nine
    ldr     s1, [x0]                 // Carga 9.0
    
    adr     x0, const_five
    ldr     s2, [x0]                 // Carga 5.0
    
    adr     x0, const_thirtytwo
    ldr     s3, [x0]                 // Carga 32.0

    // Realizar cálculo: (C * 9/5) + 32
    fmul    s0, s0, s1               // Multiplica Celsius por 9
    fdiv    s0, s0, s2               // Divide resultado por 5
    fadd    s0, s0, s3               // Suma 32 para obtener Fahrenheit

    // Guardar resultado en Fahrenheit
    adr     x0, fahrenheit
    str     s0, [x0]

    // Preparar argumentos para printf
    adr     x0, print_fmt            // Formato para imprimir resultado
    adr     x1, fahrenheit
    ldr     s1, [x1]                 // Carga resultado Fahrenheit
    fcvt    d0, s1                   // Convierte a double para printf
    
    // Imprimir resultado
    bl      printf

    // Epílogo y retorno
    mov     w0, #0                   // Código de retorno 0
    ldp     x29, x30, [sp], #16      // Restaura el frame pointer y link register
    ret
