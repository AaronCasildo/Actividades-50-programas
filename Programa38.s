/***********************************************************************
* Programa: Implementación de una Cola en Ensamblador ARM64
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa implementa una estructura de cola en ensamblador
*              ARM64, con operaciones de `enqueue` (inserción) y `dequeue` 
*              (extracción). La cola permite agregar y extraer valores enteros 
*              de 64 bits, con verificación de condiciones de desbordamiento 
*              (cola llena) y subdesbordamiento (cola vacía). Mensajes de 
*              confirmación o error se muestran en cada operación.
*
* Compilación:
*    as -o cola_arm64.o cola_arm64.s
*    gcc -o cola_arm64 cola_arm64.o -no-pie
*
* Ejecución:
*    ./cola_arm64
*
* Variables y registros clave:
* - x19, x20, x21: Registros temporales utilizados para manipular datos de la cola y el buffer.
* - x0: Valor a insertar (`enqueue`) o valor extraído (`dequeue`) de la cola.
* - front: Contiene el índice del primer elemento en la cola.
* - rear: Contiene el índice del último elemento en la cola.
*
* Funciones:
* - main: Ejecuta pruebas básicas de inserción (`enqueue`) y extracción (`dequeue`) de elementos en la cola.
* - int_to_string: Convierte un valor en `x0` a cadena de texto en el buffer para su impresión.
* - print_string: Imprime una cadena en `x1` con longitud en `x2`.
* - enqueue: Inserta un valor en la cola, verificando si hay espacio disponible; muestra mensajes de confirmación o error.
* - dequeue: Extrae un valor de la cola, verificando que la cola no esté vacía; muestra mensajes de confirmación o error.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #define MAX_SIZE 50
* 
* long queue[MAX_SIZE];
* int front = 0, rear = 0;
* 
* void enqueue(long value) {
*     if (rear >= MAX_SIZE) {
*         printf("Error: Cola llena\n");
*         return;
*     }
*     queue[rear++] = value;
*     printf("Insertando valor en la cola: %ld\n", value);
* }
* 
* long dequeue() {
*     if (front == rear) {
*         printf("Error: Cola vacia\n");
*         return -1;
*     }
*     long value = queue[front++];
*     printf("Extrayendo valor de la cola: %ld\n", value);
*     return value;
* }
* 
* int main() {
*     printf("Creando cola...\n");
*     
*     enqueue(42);
*     enqueue(73);
*     enqueue(100);
*     
*     dequeue();
*     dequeue();
*     dequeue();
*     dequeue();    // Intento de extracción en cola vacía
*     
*     enqueue(55);  // Prueba de inserción después de vaciar la cola
*     dequeue();
*     
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/Zk3FEPQvklOTeXeXDX9oIKCsX
***********************************************************************/


.data
    queue:          .skip 400        // Espacio para 50 elementos de 8 bytes
    front:          .quad 0          // Índice del frente de la cola
    rear:           .quad 0          // Índice del final de la cola
    max_size:       .quad 50         // Tamaño máximo de la cola
    err_full:       .string "Error: Cola llena\n"
    err_empty:      .string "Error: Cola vacia\n"
    msg_enqueue:    .string "Insertando valor en la cola: "
    msg_dequeue:    .string "Extrayendo valor de la cola: "
    msg_create:     .string "Creando cola...\n"
    newline:        .string "\n"
    buffer:         .skip 20         // Buffer para convertir números a string

.text
.global main

// Función para convertir un número a string
// X0 contiene el número a convertir
// X1 contiene la dirección del buffer
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
    mov x0, #1                // fd = 1 (stdout)
    mov x8, #64               // syscall write
    svc #0
    ret

// Función enqueue (corregida)
enqueue:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Preservar x0
    str x0, [sp, #-16]!
    
    // Imprimir mensaje enqueue
    adr x1, msg_enqueue
    mov x2, #0
1:  ldrb w3, [x1, x2]        // Leer cada byte de msg_enqueue
    cbz w3, 2f               // Terminar al encontrar el terminador nulo
    add x2, x2, #1           // Incrementa el contador de longitud
    b 1b
2:  bl print_string           // Imprimir el mensaje con la longitud calculada en x2
    
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
    
    // Recuperar x0 y hacer enqueue
    ldr x0, [sp], #16
    
    // Verificar si la cola está llena
    adr x1, rear
    ldr x2, [x1]
    adr x3, max_size
    ldr x3, [x3]
    cmp x2, x3
    b.ge queue_full
    
    // Insertar elemento
    adr x3, queue
    str x0, [x3, x2, lsl #3]
    add x2, x2, #1
    str x2, [x1]
    
    ldp x29, x30, [sp], #16
    ret

// Función dequeue (corregida)
dequeue:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Verificar si la cola está vacía
    adr x1, front
    ldr x2, [x1]
    adr x3, rear
    ldr x3, [x3]
    cmp x2, x3
    b.ge queue_empty
    
    // Obtener elemento
    adr x3, queue
    ldr x0, [x3, x2, lsl #3]
    
    // Preservar x0
    str x0, [sp, #-16]!
    
    // Imprimir mensaje dequeue
    adr x1, msg_dequeue
    mov x2, #0
1:  ldrb w3, [x1, x2]
    cbz w3, 2f
    add x2, x2, #1
    b 1b
2:  bl print_string           // Imprimir el mensaje con la longitud calculada en x2
    
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
    
    // Recuperar valor y actualizar front
    ldr x0, [sp], #16
    adr x1, front
    ldr x2, [x1]
    add x2, x2, #1
    str x2, [x1]
    
    ldp x29, x30, [sp], #16
    ret

queue_full:
    adr x1, err_full
    mov x2, #17
    bl print_string
    mov x0, #-1
    ldp x29, x30, [sp], #16
    ret

queue_empty:
    adr x1, err_empty
    mov x2, #18
    bl print_string
    mov x0, #-1
    ldp x29, x30, [sp], #16
    ret

main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Imprimir mensaje de creación
    adr x1, msg_create
    mov x2, #15
    bl print_string
    
    // Pruebas de inserción
    mov x0, #42
    bl enqueue
    
    mov x0, #73
    bl enqueue
    
    mov x0, #100
    bl enqueue
    
    // Pruebas de extracción
    bl dequeue
    bl dequeue
    bl dequeue
    bl dequeue    // Intentar dequeue en cola vacía
    
    // Probar inserción después de vaciar
    mov x0, #55
    bl enqueue
    bl dequeue
    
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret
