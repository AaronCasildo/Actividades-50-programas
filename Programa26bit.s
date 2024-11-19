/***********************************************************************
* Programa: Operaciones a Nivel de Bits en ARM64 Assembly
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa realiza operaciones a nivel de bits (AND, OR, XOR)
*              entre dos números enteros ingresados por el usuario. El resultado
*              se muestra tanto en formato decimal como en binario. El programa
*              permite realizar varias operaciones de forma interactiva hasta 
*              que el usuario seleccione la opción para salir. 
*              Este código está diseñado para ejecutarse en una plataforma 
*              compatible con ARM64.
*
* Compilación:
*    as -o operaciones_bits.o operaciones_bits.s
*    gcc -o operaciones_bits operaciones_bits.o -no-pie
*
* Ejecución:
*    ./operaciones_bits
*
* Traducción a C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* 
* void imprimir_binario(long num) {
*     for (int i = 63; i >= 0; i--) {
*         printf("%d", (num >> i) & 1);
*     }
*     printf("\n");
* }
* 
* int main() {
*     int opcion;
*     long num1, num2, resultado;
*     
*     do {
*         printf("\nOperaciones a nivel de bits:\n");
*         printf("1. AND\n2. OR\n3. XOR\n4. Salir\nSeleccione una opción: ");
*         scanf("%d", &opcion);
*         
*         if (opcion == 4) break;
*         
*         printf("Ingrese el primer número: ");
*         scanf("%ld", &num1);
*         printf("Ingrese el segundo número: ");
*         scanf("%ld", &num2);
*         
*         switch (opcion) {
*             case 1:
*                 resultado = num1 & num2;
*                 break;
*             case 2:
*                 resultado = num1 | num2;
*                 break;
*             case 3:
*                 resultado = num1 ^ num2;
*                 break;
*             default:
*                 printf("Opción inválida\n");
*                 continue;
*         }
*         
*         printf("Resultado: %ld\n", resultado);
*         printf("En binario: ");
*         imprimir_binario(resultado);
*     } while (opcion != 4);
*     
*     return 0;
* }
*
* Link de grabación asciinema:
* https://asciinema.org/a/FfxDWHsLMEBpDfkIp3QQhjjsb
* Link de grabación gdb:
* https://asciinema.org/a/aS9C05ckckDcXbnR99YI0ZMjz
***********************************************************************/

.global main
.data
    // Mensajes del menú y entrada
    msg_menu: .string "\nOperaciones a nivel de bits:\n1. AND\n2. OR\n3. XOR\n4. Salir\nSeleccione una opción: "  // Mensaje de menú
    msg_num1: .string "Ingrese el primer número: "  // Mensaje para solicitar el primer número
    msg_num2: .string "Ingrese el segundo número: "  // Mensaje para solicitar el segundo número
    msg_resultado: .string "Resultado: %ld\n"  // Mensaje para mostrar el resultado en formato decimal
    msg_binario: .string "En binario: "  // Mensaje para indicar que se mostrará el resultado en binario
    msg_error: .string "Error: Entrada inválida. Intente nuevamente.\n"  // Mensaje de error en caso de entrada incorrecta
    msg_bit: .string "%d"  // Formato para imprimir un bit
    msg_newline: .string "\n"  // Salto de línea después de imprimir el resultado binario
    input_format: .string "%ld"  // Formato para leer un número entero

.text
main:
    // Prólogo
    stp     x29, x30, [sp, -48]!  // Guardar los registros x29 (frame pointer) y x30 (link register) en la pila
    mov     x29, sp  // Establecer el frame pointer

menu_loop:
    // Mostrar menú
    adr     x0, msg_menu  // Cargar la dirección del mensaje de menú
    bl      printf  // Llamar a printf para mostrar el menú

    // Leer opción
    sub     sp, sp, 16  // Reservar espacio en la pila para leer la opción
    mov     x1, sp  // Establecer el puntero a la dirección de la pila
    adr     x0, input_format  // Cargar el formato de entrada
    bl      scanf  // Llamar a scanf para leer la opción del usuario
    
    // Verificar entrada válida
    cmp     x0, #1  // Verificar que scanf haya leído correctamente un valor
    b.ne    input_error  // Si no es correcto, ir a manejo de error

    // Cargar opción
    ldr     x19, [sp]  // Cargar la opción seleccionada en x19
    
    // Verificar si es salir
    cmp     x19, #4  // Comprobar si la opción seleccionada es "Salir"
    b.eq    exit_program  // Si es "Salir", ir a la etiqueta exit_program
    
    // Verificar opción válida
    cmp     x19, #1  // Verificar si la opción está en el rango válido (1-3)
    b.lt    input_error  // Si es menor que 1, ir a manejo de error
    cmp     x19, #3  // Verificar si la opción es mayor que 3
    b.gt    input_error  // Si es mayor que 3, ir a manejo de error

    // Leer primer número
    adr     x0, msg_num1  // Cargar el mensaje para solicitar el primer número
    bl      printf  // Mostrar el mensaje
    mov     x1, sp  // Establecer el puntero de la pila para leer el número
    adr     x0, input_format  // Cargar el formato para leer un número entero
    bl      scanf  // Leer el primer número

    cmp     x0, #1  // Verificar si scanf leyó correctamente el primer número
    b.ne    input_error  // Si no, ir a manejo de error
    
    ldr     x20, [sp]  // Cargar el primer número en x20

    // Leer segundo número
    adr     x0, msg_num2  // Cargar el mensaje para solicitar el segundo número
    bl      printf  // Mostrar el mensaje
    mov     x1, sp  // Establecer el puntero de la pila para leer el número
    adr     x0, input_format  // Cargar el formato para leer un número entero
    bl      scanf  // Leer el segundo número

    cmp     x0, #1  // Verificar si scanf leyó correctamente el segundo número
    b.ne    input_error  // Si no, ir a manejo de error
    
    ldr     x21, [sp]  // Cargar el segundo número en x21

    // Realizar operación según la opción
    cmp     x19, #1  // Comprobar si la opción es "AND"
    b.eq    do_and  // Si es "AND", ir a la etiqueta do_and
    cmp     x19, #2  // Comprobar si la opción es "OR"
    b.eq    do_or  // Si es "OR", ir a la etiqueta do_or
    b       do_xor  // Si es "XOR", ir a la etiqueta do_xor

do_and:
    and     x22, x20, x21  // Realizar la operación AND y almacenar el resultado en x22
    b       print_result  // Ir a la etiqueta de impresión de resultados

do_or:
    orr     x22, x20, x21  // Realizar la operación OR y almacenar el resultado en x22
    b       print_result  // Ir a la etiqueta de impresión de resultados

do_xor:
    eor     x22, x20, x21  // Realizar la operación XOR y almacenar el resultado en x22

print_result:
    // Imprimir resultado en decimal
    adr     x0, msg_resultado  // Cargar el mensaje para mostrar el resultado en decimal
    mov     x1, x22  // Pasar el resultado de la operación a x1
    bl      printf  // Llamar a printf para imprimir el resultado

    // Imprimir mensaje para binario
    adr     x0, msg_binario  // Cargar el mensaje para indicar que se mostrará el resultado en binario
    bl      printf  // Mostrar el mensaje

    // Imprimir resultado en binario
    mov     x23, #63  // Establecer el contador para los 64 bits
    mov     x24, x22  // Copiar el resultado a x24 para manipularlo

print_binary:
    // Obtener bit más significativo
    lsr     x25, x24, x23  // Desplazar el valor en x24 hacia la derecha para obtener el bit más significativo
    and     x25, x25, #1  // Máscara para obtener solo el bit de interés
    
    // Imprimir bit
    adr     x0, msg_bit  // Cargar el formato para imprimir un bit
    mov     x1, x25  // Pasar el bit a x1
    bl      printf  // Llamar a printf para imprimir el bit
    
    // Continuar con siguiente bit
    sub     x23, x23, #1  // Decrementar el contador de bits
    cmp     x23, #-1  // Comprobar si ya se han mostrado todos los bits
    b.ne    print_binary  // Si no, continuar mostrando los bits

    // Nueva línea después del binario
    adr     x0, msg_newline  // Cargar el salto de línea
    bl      printf  // Imprimir el salto de línea

    // Limpiar buffer de entrada
    mov     x0, #0  // Establecer el valor de x0 a 0 para limpiar el buffer
    bl      getchar  // Llamar a getchar para limpiar el buffer de entrada

    b       menu_loop  // Volver al inicio del bucle del menú

input_error:
    // Mostrar mensaje de error
    adr     x0, msg_error  // Cargar el mensaje de error
    bl      printf  // Imprimir el mensaje de error
    
    // Limpiar buffer de entrada
    mov     x0, #0  // Establecer el valor de x0 a 0 para limpiar el buffer
    bl      getchar  // Llamar a getchar para limpiar el buffer de entrada
    
    b       menu_loop  // Volver al inicio del bucle del menú

exit_program:
    // Epílogo y retorno
    mov     w0, #0  // Establecer el valor de retorno a 0 (sin errores)
    ldp     x29, x30, [sp], 48  // Restaurar los registros x29 y x30 desde la pila
    ret  // Retornar de la función
