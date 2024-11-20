/***********************************************************************
* Programa: Verificador de Números Armstrong
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa verifica si un número ingresado por el usuario 
*              es un número **Armstrong**. Un número Armstrong (también llamado
*              número narcisista) es aquel cuya suma de sus dígitos, elevados
*              a la potencia del número de dígitos, es igual al número mismo.
*              El programa también explica el cálculo realizado en detalle.
*
* Compilación:
*    as -o armstrong.o armstrong.s
*    gcc -o armstrong armstrong.o -no-pie
*
* Ejecución:
*    ./armstrong
*
* Explicación del flujo:
* - prompt: Solicita al usuario ingresar un número para verificar.
* - is_armstrong: Mensaje que indica que el número es Armstrong.
* - not_armstrong: Mensaje que indica que el número no es Armstrong.
* - explain_fmt: Formato que inicia la explicación detallada del cálculo.
* - power_fmt: Formato para mostrar cada término del cálculo (dígito elevado a la potencia).
* - plus_fmt: Formato para agregar un signo "+" entre términos.
* - error_msg: Mensaje mostrado si la entrada no es válida.
*
* Variables y registros clave:
* - x19: Almacena el número ingresado por el usuario.
* - x20: Almacena la cantidad de dígitos del número.
* - x21: Almacena el número mientras se procesa en ciclos (se usa para dígitos).
* - x22: Almacena la suma de las potencias de los dígitos.
* - x23: Almacena una copia del número original para explicar el cálculo.
* - x24: Almacena la constante `10` para divisiones/mod operaciones.
* - x25, x26: Variables temporales para extraer y procesar dígitos.
* - x27: Almacena el resultado de cada potencia calculada.
* - x28: Contador para calcular potencias de cada dígito.
*
* Funciones:
* - main: Controla el flujo principal, incluyendo la lectura de la entrada,
*         validación, cálculo del número Armstrong, y la explicación del cálculo.
* - count_digits: Cuenta los dígitos del número ingresado.
* - calc_powers: Calcula la suma de las potencias de los dígitos.
* - explain_loop: Muestra la explicación detallada de cómo se llegó al resultado.
*
* Flujo del Programa:
* 1. Solicitar al usuario que ingrese un número entero (`prompt`).
* 2. Validar la entrada y contar la cantidad de dígitos en el número (`count_digits`).
* 3. Calcular la suma de las potencias de los dígitos del número (`calc_powers`).
* 4. Comparar la suma con el número original:
*    - Si son iguales, mostrar que es un número Armstrong (`is_armstrong`).
*    - Si no son iguales, indicar que no es un número Armstrong (`not_armstrong`).
* 5. Si el número es Armstrong, proporcionar una explicación detallada de cómo
*    se calcularon las potencias de los dígitos y su suma (`explain_loop`).
*
* Ejemplo:
* ----------------------------------------------------
* Entrada: 153
* Salida:
*   El numero 153 ES un numero Armstrong!
*   Explicacion: 153 = 1^3 + 5^3 + 3^3
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #include <math.h>
* 
* int main() {
*     long num, original, digit, sum = 0, count = 0;
* 
*     printf("Ingrese un numero para verificar si es Armstrong: ");
*     if (scanf("%ld", &num) != 1) {
*         printf("Error: Ingrese un numero valido\n");
*         return 1;
*     }
* 
*     original = num;
* 
*     // Contar dígitos
*     long temp = num;
*     while (temp > 0) {
*         temp /= 10;
*         count++;
*     }
* 
*     // Calcular suma de potencias
*     temp = num;
*     while (temp > 0) {
*         digit = temp % 10;
*         sum += pow(digit, count);
*         temp /= 10;
*     }
* 
*     // Verificar resultado
*     if (sum == original) {
*         printf("El numero %ld ES un numero Armstrong!\n", original);
*         printf("Explicacion: %ld = ", original);
*         temp = num;
*         while (temp > 0) {
*             digit = temp % 10;
*             printf("%ld^%ld", digit, count);
*             temp /= 10;
*             if (temp > 0) printf(" + ");
*         }
*         printf("\n");
*     } else {
*         printf("El numero %ld NO es un numero Armstrong.\n", original);
*     }
*     return 0;
* }
*
* Link de grabación asciinema con gdb:
* https://asciinema.org/a/KYcUJdNddaDAcSkLrcFOo35fJ
***********************************************************************/

.data
    prompt:         .string "Ingrese un numero para verificar si es Armstrong: "
    is_armstrong:   .string "El numero %ld ES un numero Armstrong!\n"
    not_armstrong:  .string "El numero %ld NO es un numero Armstrong.\n"
    explain_fmt:    .string "Explicacion: %ld = "
    plus_fmt:      .string " + "
    power_fmt:     .string "%ld^%ld"
    newline:       .string "\n"
    input_fmt:     .string "%ld"
    error_msg:     .string "Error: Ingrese un numero valido\n"

.text
.global main

main:
    // Prólogo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    
    // Reservar espacio para variables
    sub     sp, sp, #32
    
    // Mostrar prompt
    adr     x0, prompt
    bl      printf
    
    // Leer número
    adr     x0, input_fmt
    mov     x1, sp
    bl      scanf
    
    // Verificar lectura exitosa
    cmp     x0, #1
    b.ne    input_error
    
    // Cargar número en x19
    ldr     x19, [sp]
    
    // Contar dígitos (resultado en x20)
    mov     x20, #0          // Contador de dígitos
    mov     x21, x19         // Copia del número para contar
    mov     x24, #10         // Constante 10 para divisiones

count_digits:
    cbz     x21, count_done
    udiv    x21, x21, x24    // Dividir por 10 usando registro
    add     x20, x20, #1
    b       count_digits
count_done:

    // Calcular suma de potencias
    mov     x21, x19         // Copia del número para procesar
    mov     x22, #0          // Suma total
    mov     x23, x19         // Copia para mostrar explicación después

calc_powers:
    cbz     x21, calc_done
    
    // Obtener último dígito
    udiv    x25, x21, x24    // x25 = número / 10
    msub    x26, x25, x24, x21  // x26 = último dígito
    
    // Calcular potencia (dígito^n)
    mov     x27, #1          // Resultado de la potencia
    mov     x28, x20         // Contador para potencia
power_loop:
    cbz     x28, power_done
    mul     x27, x27, x26
    sub     x28, x28, #1
    b       power_loop
power_done:
    
    // Sumar al total
    add     x22, x22, x27
    
    // Siguiente dígito
    mov     x21, x25
    b       calc_powers
    
calc_done:
    // Verificar si es Armstrong
    cmp     x22, x19
    b.ne    print_not_armstrong
    
    // Es Armstrong - Imprimir resultado y explicación
    adr     x0, is_armstrong
    mov     x1, x19
    bl      printf
    
    // Imprimir explicación
    adr     x0, explain_fmt
    mov     x1, x19
    bl      printf
    
    // Mostrar cada dígito elevado a la potencia
    mov     x21, x23         // Restaurar número original
explain_loop:
    cbz     x21, explain_done
    
    // Obtener dígito
    udiv    x25, x21, x24
    msub    x26, x25, x24, x21  // x26 = dígito actual
    
    // Imprimir término
    adr     x0, power_fmt
    mov     x1, x26          // Dígito
    mov     x2, x20          // Potencia
    bl      printf
    
    // Si no es el último dígito, imprimir "+"
    cmp     x25, #0
    b.eq    explain_next
    adr     x0, plus_fmt
    bl      printf
    
explain_next:
    mov     x21, x25
    b       explain_loop
    
explain_done:
    adr     x0, newline
    bl      printf
    b       end_program

print_not_armstrong:
    adr     x0, not_armstrong
    mov     x1, x19
    bl      printf
    b       end_program

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
