// Programa: conversion_celsius_fahrenheit.s
// Autor: [Tu Nombre]
// Descripción: Convierte una temperatura de Celsius a Fahrenheit y la imprime como un entero.
// Entrada: La temperatura en grados Celsius, ingresada por el usuario.
// Salida: La temperatura convertida en grados Fahrenheit.
//

//Link de grabación asciinema:
// Conversión en C/C++ (referencia):
// ```c
// #include <stdio.h>
// int main() {
//     float celsius, fahrenheit;
//     printf("Ingrese temperatura en Celsius: ");
//     scanf("%f", &celsius);
//     fahrenheit = celsius * 1.8 + 32;
//     printf("Temperatura en Fahrenheit: %.2f\n", fahrenheit);
//     return 0;
// }
// ```

        .section .data
mensaje_entrada:
        .asciz "Ingrese la temperatura en Celsius: "
mensaje_salida:
        .asciz "Temperatura en Fahrenheit: %d\n"  // Cambiamos a %d para entero
factor_conversion:
        .float 1.8               // Definimos el valor 1.8 en memoria
offset_conversion:
        .float 32.0              // Definimos el valor 32.0 en memoria

        .section .bss
        .lcomm celsius, 4         // Variable para guardar la entrada del usuario
        .lcomm fahrenheit, 4      // Variable para guardar la conversión

        .section .text
        .global _start

_start:
        // Mostrar mensaje de entrada
        mov     x0, 1              // 1 es el file descriptor para stdout
        ldr     x1, =mensaje_entrada // Cargar dirección del mensaje
        mov     x2, 32             // Tamaño del mensaje
        mov     x8, 64             // Syscall para write
        svc     0

        // Leer temperatura en Celsius
        mov     x0, 0              // 0 es el file descriptor para stdin
        ldr     x1, =celsius       // Dirección donde se guardará el input
        mov     x2, 4              // Leer 4 bytes (float)
        mov     x8, 63             // Syscall para read
        svc     0

        // Cargar valor de Celsius y realizar la conversión
        ldr     s0, [x1]           // Cargar Celsius en s0
        ldr     x2, =factor_conversion // Cargar dirección de factor de conversión (1.8) en x2
        ldr     s1, [x2]           // Cargar el valor 1.8 en s1
        fmul    s0, s0, s1         // Celsius * 1.8
        ldr     x2, =offset_conversion // Cargar dirección del offset de conversión (32.0) en x2
        ldr     s1, [x2]           // Cargar el valor 32.0 en s1
        fadd    s0, s0, s1         // Celsius * 1.8 + 32 = Fahrenheit

        // Convertir de punto flotante a entero para imprimir
        fcvtzs  w0, s0             // Convierte de float en s0 a int en w0

        // Preparar mensaje de salida con el valor de Fahrenheit
        mov     x0, 1              // stdout
        ldr     x1, =mensaje_salida // Dirección del mensaje de salida
        mov     x2, 26             // Tamaño del mensaje
        mov     x8, 64             // Syscall para write
        svc     0

        // Salida del programa
        mov     x8, 93             // Syscall para exit
        mov     x0, 0              // Estado de salida 0
        svc     0
