/***********************************************************************
* Programa: Implementación de una Pila en Ensamblador ARM64
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa implementa una estructura de pila en ensamblador 
*              ARM64, con operaciones de `push` y `pop`. La pila permite insertar 
*              y extraer valores enteros de 64 bits y verifica condiciones de 
*              desbordamiento y subdesbordamiento (pila llena o vacía). 
*              Los mensajes de error y confirmación se imprimen en cada operación.
*
* Compilación:
*    as -o pila_arm64.o pila_arm64.s
*    gcc -o pila_arm64 pila_arm64.o -no-pie
*
* Ejecución:
*    ./pila_arm64
*
* Explicación del flujo:
* - stack: Espacio en memoria para la pila, que puede almacenar hasta 50 elementos de 8 bytes.
* - stack_top: Índice del tope de la pila, inicializado en 0.
* - max_size: Tamaño máximo de la pila (50 elementos).
* - err_full: Mensaje de error cuando se intenta `push` en una pila llena.
*
* Variables y registros clave:
* - x19, x20, x21: Registros temporales utilizados para almacenar datos de la pila y manipular el buffer.
* - x0: Valor a insertar en la pila (`push`) o el valor extraído (`pop`).
* - stack_top: Contiene el índice actual del tope de la pila.
*
* Funciones:
* - main: Ejecuta pruebas básicas de inserción (`push`) y extracción (`pop`), con verificación de pila vacía.
* - int_to_string: Convierte un valor en `x0` a una cadena de texto almacenada en el buffer, para su impresión.
* - print_string: Imprime una cadena almacenada en `x1` con longitud especificada en `x2`.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #define MAX_SIZE 50
* 
* long stack[MAX_SIZE];
* int stack_top = 0;
* 
* void push(long value) {
*     if (stack_top >= MAX_SIZE) {
*         printf("Error: Pila llena\n");
*         return;
*     }
*     stack[stack_top++] = value;
*     printf("Insertando valor en la pila: %ld\n", value);
* }
* 
* long pop() {
*     if (stack_top == 0) {
*         printf("Error: Pila vacia\n");
*         return -1;
*     }
*     long value = stack[--stack_top];
*     printf("Extrayendo valor de la pila: %ld\n", value);
*     return value;
* }
* 
* int main() {
*     push(42);
*     push(73);
*     push(100);
*     pop();
*     pop();
*     pop();
*     pop(); // Intento de extraer de una pila vacía
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/1THGaVz6kmMKfzc2zMJwb28Jg
* Link de grabación gdb:
* https://asciinema.org/a/pAax9gpViO01UYmhX1Z5DFkvI
***********************************************************************/

.data
    stack:      .skip 400        // Espacio para 50 elementos de 8 bytes
    stack_top:  .quad 0          // Índice del tope de la pila
    max_size:   .quad 50         // Tamaño máximo de la pila
    err_full:   .string "Error: Pila llena\n"
    err_empty:  .string "Error: Pila vacia\n"
    msg_push:   .string "Insertando valor en la pila: "
    msg_pop:    .string "Extrayendo valor de la pila: "
    newline:    .string "\n"
    buffer:     .skip 20         // Buffer para convertir números a string

.text
.global main

// Función para convertir un número a string
// X0 contiene el número a convertir
// X1 contiene la dirección del buffer
// Retorna en X0 la dirección del primer dígito
int_to_string:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    add x1, x1, #19            // Comenzar desde el final del buffer
    mov x2, #0                 // Terminador nulo
    strb w2, [x1]
    mov x2, #10               // Divisor
    
1:  sub x1, x1, #1            // Mover el puntero hacia atrás
    udiv x3, x0, x2           // Dividir por 10
    msub x4, x3, x2, x0       // Obtener el residuo
    add x4, x4, #'0'          // Convertir a ASCII
    strb w4, [x1]             // Almacenar el dígito
    mov x0, x3                // Preparar para la siguiente iteración
    cbnz x0, 1b              // Si el cociente no es 0, continuar
    
    mov x0, x1                // Retornar la dirección del primer dígito
    ldp x29, x30, [sp], #16
    ret

// Función para imprimir una cadena
print_string:
    stp x29, x30, [sp, #-16]!   // Preservar registros
    mov x0, #1                   // fd = 1 (stdout)
    mov x8, #64                 // syscall write
    svc #0
    ldp x29, x30, [sp], #16    // Restaurar registros
    ret

// Función push (corregida)
push:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Preservar x0
    str x0, [sp, #-16]!
    
    // Imprimir mensaje push
    adr x1, msg_push
    mov x2, #0
1:  ldrb w3, [x1, x2]        // Leer cada byte de msg_push
    cbz w3, 2f               // Termina al encontrar el terminador nulo
    add x2, x2, #1           // Incrementa el contador de longitud
    b 1b
2:  bl print_string           // Imprimir la cadena completa con la longitud calculada en x2
    
    // Convertir e imprimir número
    ldr x0, [sp]
    adr x1, buffer
    bl int_to_string
    mov x1, x0
    mov x2, #0
1:  ldrb w3, [x1, x2]
    cbz w3, 2f
    add x2, x2, #1
    b 1b
2:  bl print_string
    
    // Nueva línea
    adr x1, newline
    mov x2, #1
    bl print_string
    
    // Recuperar x0 y hacer push
    ldr x0, [sp], #16
    
    adr x1, stack_top
    ldr x2, [x1]
    adr x3, max_size
    ldr x3, [x3]
    cmp x2, x3
    b.ge stack_full
    
    adr x3, stack
    str x0, [x3, x2, lsl #3]
    add x2, x2, #1
    str x2, [x1]
    
    ldp x29, x30, [sp], #16
    ret

// Función pop (corregida)
pop:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    adr x1, stack_top
    ldr x2, [x1]
    cmp x2, #0
    b.eq stack_empty
    
    sub x2, x2, #1
    str x2, [x1]
    adr x3, stack
    ldr x0, [x3, x2, lsl #3]
    
    // Preservar x0
    str x0, [sp, #-16]!
    
    // Imprimir mensaje pop
    adr x1, msg_pop
    mov x2, #0
1:  ldrb w3, [x1, x2]
    cbz w3, 2f
    add x2, x2, #1
    b 1b
2:  bl print_string           // Imprimir el mensaje de pop con longitud calculada
    
    // Convertir e imprimir número
    ldr x0, [sp]
    adr x1, buffer
    bl int_to_string
    mov x1, x0
    mov x2, #0
1:  ldrb w3, [x1, x2]
    cbz w3, 2f
    add x2, x2, #1
    b 1b
2:  bl print_string
    
    // Nueva línea
    adr x1, newline
    mov x2, #1
    bl print_string
    
    // Recuperar valor
    ldr x0, [sp], #16
    
    ldp x29, x30, [sp], #16
    ret

stack_full:
    adr x1, err_full
    mov x2, #17
    bl print_string
    mov x0, #-1
    ldp x29, x30, [sp], #16
    ret

stack_empty:
    adr x1, err_empty
    mov x2, #18
    bl print_string
    mov x0, #-1
    ldp x29, x30, [sp], #16
    ret

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Pruebas
    mov x0, #42
    bl push
    
    mov x0, #73
    bl push
    
    mov x0, #100
    bl push
    
    bl pop
    bl pop
    bl pop
    bl pop    // Intentar pop en pila vacía
    
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret
