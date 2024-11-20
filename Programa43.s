/***********************************************************************
* Programa: Calculadora Simple
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa implementa una calculadora básica que permite 
*              al usuario realizar operaciones de suma, resta, multiplicación, 
*              y división entre dos números. El programa valida las entradas 
*              y maneja errores como la división por cero o la selección de 
*              opciones inválidas. También incluye un mecanismo de bucle para 
*              que el usuario pueda realizar múltiples operaciones hasta que 
*              decida salir.
*
* Compilación:
*    as -o calculadora.o calculadora.s
*    gcc -o calculadora calculadora.o -no-pie
*
* Ejecución:
*    ./calculadora
*
* Explicación del flujo:
* - menu: Título principal del programa.
* - menu_ops: Opciones del menú para seleccionar la operación deseada.
* - prompt_num1: Mensaje que solicita el primer número al usuario.
* - prompt_num2: Mensaje que solicita el segundo número al usuario.
* - result_msg: Mensaje que muestra el resultado de las operaciones básicas.
* - div_result: Mensaje que muestra el cociente y residuo en operaciones de división.
* - div_zero: Mensaje de error para manejo de divisiones por cero.
* - invalid_op: Mensaje de error cuando se elige una opción no válida.
* - format_input: Formato para `scanf` que permite leer números enteros de 64 bits.
*
* Variables y registros clave:
* - x19: Almacena la opción seleccionada del menú.
* - x20: Almacena el primer número ingresado.
* - x21: Almacena el segundo número ingresado.
* - x22: Almacena el resultado de la operación.
* - x23: Almacena el residuo en caso de una operación de división.
* - sp: Espacio reservado en la pila para almacenar la opción y los números.
*
* Funciones:
* - main: Controla el flujo principal del programa, manejando el menú, la selección 
*         de operaciones, y la interacción con el usuario.
* - do_suma: Realiza la operación de suma y muestra el resultado.
* - do_resta: Realiza la operación de resta y muestra el resultado.
* - do_multiplicacion: Realiza la operación de multiplicación y muestra el resultado.
* - do_division: Realiza la operación de división, manejando el caso de división por cero.
* - invalid_option: Muestra un mensaje de error cuando el usuario elige una opción inválida.
*
* Flujo del Programa:
* 1. Mostrar el menú de operaciones y solicitar al usuario que elija una opción.
* 2. Leer y validar la opción seleccionada:
*    - Si la opción es válida, solicitar dos números y realizar la operación correspondiente.
*    - Si la opción es inválida, mostrar un mensaje de error.
*    - Si el usuario selecciona "Salir", terminar el programa.
* 3. En caso de división, manejar errores de división por cero.
* 4. Repetir el proceso hasta que el usuario decida salir.
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* int main() {
*     int opcion;
*     long num1, num2, resultado, residuo;
* 
*     do {
*         printf("\n=== Calculadora Simple ===\n");
*         printf("1. Suma\n2. Resta\n3. Multiplicacion\n4. Division\n5. Salir\nElija una opcion: ");
*         scanf("%d", &opcion);
* 
*         if (opcion == 5) break;
*         if (opcion < 1 || opcion > 4) {
*             printf("Opcion invalida!\n");
*             continue;
*         }
* 
*         printf("Ingrese primer numero: ");
*         scanf("%ld", &num1);
*         printf("Ingrese segundo numero: ");
*         scanf("%ld", &num2);
* 
*         switch (opcion) {
*             case 1:
*                 resultado = num1 + num2;
*                 printf("Resultado: %ld\n", resultado);
*                 break;
*             case 2:
*                 resultado = num1 - num2;
*                 printf("Resultado: %ld\n", resultado);
*                 break;
*             case 3:
*                 resultado = num1 * num2;
*                 printf("Resultado: %ld\n", resultado);
*                 break;
*             case 4:
*                 if (num2 == 0) {
*                     printf("Error: Division por cero!\n");
*                 } else {
*                     resultado = num1 / num2;
*                     residuo = num1 % num2;
*                     printf("Resultado: %ld (Cociente), %ld (Residuo)\n", resultado, residuo);
*                 }
*                 break;
*         }
*     } while (1);
* 
*     return 0;
* }
* Link de grabación asciinema con gdb:
* https://asciinema.org/a/rN1kD3L2XyH2dEZ07skPprhaO
***********************************************************************/

.data
    menu:           .string "\n=== Calculadora Simple ===\n"
    menu_ops:       .string "1. Suma\n2. Resta\n3. Multiplicacion\n4. Division\n5. Salir\nElija una opcion: "
    prompt_num1:    .string "Ingrese primer numero: "
    prompt_num2:    .string "Ingrese segundo numero: "
    result_msg:     .string "Resultado: %ld\n"
    div_result:     .string "Resultado: %ld (Cociente), %ld (Residuo)\n"
    div_zero:       .string "Error: Division por cero!\n"
    format_input:   .string "%ld"
    invalid_op:     .string "Opcion invalida!\n"

.text
.global main

main:
    // Prólogo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    
    // Espacio para variables locales (opción y números)
    sub     sp, sp, #32

menu_loop:
    // Mostrar menú
    adr     x0, menu
    bl      printf
    adr     x0, menu_ops
    bl      printf
    
    // Leer opción
    adr     x0, format_input
    mov     x1, sp          // Guardar opción en [sp]
    bl      scanf
    
    // Cargar opción
    ldr     x19, [sp]
    
    // Verificar si es salir (opción 5)
    cmp     x19, #5
    b.eq    end_program
    
    // Verificar opción válida (1-4)
    cmp     x19, #1
    b.lt    invalid_option
    cmp     x19, #4
    b.gt    invalid_option
    
    // Leer primer número
    adr     x0, prompt_num1
    bl      printf
    adr     x0, format_input
    add     x1, sp, #8      // Guardar num1 en [sp + 8]
    bl      scanf
    
    // Leer segundo número
    adr     x0, prompt_num2
    bl      printf
    adr     x0, format_input
    add     x1, sp, #16     // Guardar num2 en [sp + 16]
    bl      scanf
    
    // Cargar números en registros
    ldr     x20, [sp, #8]   // num1
    ldr     x21, [sp, #16]  // num2
    
    // Saltar a la operación correspondiente
    cmp     x19, #1
    b.eq    do_suma
    cmp     x19, #2
    b.eq    do_resta
    cmp     x19, #3
    b.eq    do_multiplicacion
    b       do_division

do_suma:
    add     x22, x20, x21
    adr     x0, result_msg
    mov     x1, x22
    bl      printf
    b       menu_loop

do_resta:
    sub     x22, x20, x21
    adr     x0, result_msg
    mov     x1, x22
    bl      printf
    b       menu_loop

do_multiplicacion:
    mul     x22, x20, x21
    adr     x0, result_msg
    mov     x1, x22
    bl      printf
    b       menu_loop

do_division:
    // Verificar división por cero
    cmp     x21, #0
    b.eq    division_zero
    
    // Realizar división
    sdiv    x22, x20, x21   // Cociente
    msub    x23, x22, x21, x20  // Residuo = num1 - (cociente * num2)
    
    // Mostrar resultado
    adr     x0, div_result
    mov     x1, x22
    mov     x2, x23
    bl      printf
    b       menu_loop

division_zero:
    adr     x0, div_zero
    bl      printf
    b       menu_loop

invalid_option:
    adr     x0, invalid_op
    bl      printf
    b       menu_loop

end_program:
    // Epílogo
    mov     w0, #0
    add     sp, sp, #32
    ldp     x29, x30, [sp], #16
    ret
