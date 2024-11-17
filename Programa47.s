/***********************************************************************
* Programa: Suma con Detección de Desbordamiento
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa solicita al usuario ingresar dos números 
*              enteros de 64 bits, calcula su suma y verifica si ocurre 
*              desbordamiento (overflow). Imprime el resultado de la suma 
*              y muestra un mensaje indicando si hubo o no desbordamiento.
*
* Compilación:
*    as -o suma_overflow.o suma_overflow.s
*    gcc -o suma_overflow suma_overflow.o -no-pie
*
* Ejecución:
*    ./suma_overflow
*
* Explicación del flujo:
* - prompt1: Mensaje que solicita el primer número al usuario.
* - prompt2: Mensaje que solicita el segundo número al usuario.
* - result: Mensaje que muestra el resultado de la suma.
* - overflow: Mensaje que indica que ocurrió desbordamiento.
* - no_overflow: Mensaje que indica que no hubo desbordamiento.
* - format: Cadena de formato para leer números enteros de 64 bits.
* - LONG_MAX: Constante que representa el valor máximo para un entero con signo de 64 bits.
* - LONG_MIN: Constante que representa el valor mínimo para un entero con signo de 64 bits.
*
* Variables y registros clave:
* - x19: Almacena el primer número ingresado por el usuario.
* - x20: Almacena el segundo número ingresado por el usuario.
* - x21: Almacena el límite superior (`LONG_MAX`).
* - x22: Almacena el límite inferior (`LONG_MIN`).
* - x23: Almacena el resultado de la suma.
*
* Funciones:
* - main: Controla el flujo principal del programa, incluyendo la lectura 
*         de números, cálculo de la suma, verificación de desbordamiento, 
*         y la impresión de resultados.
* - no_overflow_detected: Rama del flujo que se ejecuta cuando no hay desbordamiento.
* - overflow_detected: Rama del flujo que se ejecuta cuando ocurre desbordamiento.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #include <limits.h>
* 
* int main() {
*     long num1, num2, suma;
* 
*     printf("Ingresa el primer número: ");
*     scanf("%ld", &num1);
* 
*     printf("Ingresa el segundo número: ");
*     scanf("%ld", &num2);
* 
*     if (__builtin_add_overflow(num1, num2, &suma)) {
*         printf("La suma es: %ld\n", suma);
*         printf("¡Hubo desbordamiento!\n");
*     } else {
*         printf("La suma es: %ld\n", suma);
*         printf("No hubo desbordamiento\n");
*     }
* 
*     return 0;
* }
*
* Link de grabación de asciinema:
* https://asciinema.org/a/aacREvtPoeL5k91ZCrxBfSwsf
***********************************************************************/

.data
    prompt1:    .string "Ingresa el primer número: "
    prompt2:    .string "Ingresa el segundo número: "
    result:     .string "La suma es: %ld\n"
    overflow:   .string "¡Hubo desbordamiento!\n"
    no_overflow: .string "No hubo desbordamiento\n"
    format:     .string "%ld"
    
    // Constantes para límites de 64 bits
    LONG_MAX:   .quad 9223372036854775807
    LONG_MIN:   .quad -9223372036854775808
    
.text
.global main
main:
    // Preservar registros
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Reservar espacio para variables locales
    sub sp, sp, #32
    
    // Pedir primer número
    adr x0, prompt1
    bl printf
    
    // Leer primer número
    mov x1, sp
    adr x0, format
    bl scanf
    ldr x19, [sp]        // x19 = primer número
    
    // Pedir segundo número
    adr x0, prompt2
    bl printf
    
    // Leer segundo número
    mov x1, sp
    adr x0, format
    bl scanf
    ldr x20, [sp]        // x20 = segundo número
    
    // Cargar límites de 64 bits
    adr x0, LONG_MAX
    ldr x21, [x0]        // x21 = LONG_MAX
    adr x0, LONG_MIN
    ldr x22, [x0]        // x22 = LONG_MIN
    
    // Realizar la suma
    adds x23, x19, x20   // x23 = suma, actualiza flags
    
    // Verificar desbordamiento usando el flag de carry
    b.vs overflow_detected   // Branch if overflow set
    
no_overflow_detected:
    // Imprimir resultado
    adr x0, result
    mov x1, x23
    bl printf
    
    // Imprimir mensaje de no desbordamiento
    adr x0, no_overflow
    bl printf
    b end
    
overflow_detected:
    // Imprimir resultado
    adr x0, result
    mov x1, x23
    bl printf
    
    // Imprimir mensaje de desbordamiento
    adr x0, overflow
    bl printf
    
end:
    // Restaurar stack y registros
    add sp, sp, #32
    ldp x29, x30, [sp], #16
    ret
