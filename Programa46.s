/***********************************************************************
* Programa: Encuentra el Sufijo Común Más Largo
* Autor: Aaron Casildo Rubalcava
* Descripción: Este programa solicita al usuario que ingrese tres cadenas 
*              y determina el sufijo común más largo entre ellas. Si no hay 
*              un sufijo común, el programa informa que no existe. Además, 
*              realiza operaciones de comparación de caracteres desde el final 
*              de las cadenas y revierte el sufijo antes de mostrarlo.
*
* Compilación:
*    as -o sufijo_comun.o sufijo_comun.s
*    gcc -o sufijo_comun sufijo_comun.o -no-pie
*
* Ejecución:
*    ./sufijo_comun
*
* Explicación del flujo:
* - prompt_count: Mensaje inicial para solicitar al usuario que ingrese tres cadenas.
* - prompt_str: Mensaje que solicita al usuario ingresar cada cadena individualmente.
* - result_msg: Mensaje que muestra el sufijo común más largo.
* - no_prefix: Mensaje que se muestra si no hay sufijo común.
* - suffix: Buffer donde se almacena el sufijo común encontrado.
* - str1, str2, str3: Buffers para almacenar las cadenas ingresadas por el usuario.
* - strlen: Función que calcula la longitud de una cadena.
*
*
* Traducción en C (para referencia):
* ----------------------------------------------------
* #include <stdio.h>
* #include <string.h>
* 
* int main() {
*     char str1[100], str2[100], str3[100];
*     char suffix[100];
*     int len1, len2, len3, i = 0;
* 
*     printf("Ingresa 3 cadenas\n");
*     printf("Ingresa la cadena 1: ");
*     scanf("%99s", str1);
*     printf("Ingresa la cadena 2: ");
*     scanf("%99s", str2);
*     printf("Ingresa la cadena 3: ");
*     scanf("%99s", str3);
* 
*     len1 = strlen(str1);
*     len2 = strlen(str2);
*     len3 = strlen(str3);
* 
*     while (i < len1 && i < len2 && i < len3) {
*         if (str1[len1 - i - 1] != str2[len2 - i - 1] ||
*             str1[len1 - i - 1] != str3[len3 - i - 1]) {
*             break;
*         }
*         suffix[i] = str1[len1 - i - 1];
*         i++;
*     }
* 
*     if (i == 0) {
*         printf("No hay sufijo común\n");
*         return 0;
*     }
* 
*     suffix[i] = '\0';  // Agregar terminador null
*     
*     // Invertir el sufijo para mostrarlo
*     for (int j = 0, k = i - 1; j < k; j++, k--) {
*         char temp = suffix[j];
*         suffix[j] = suffix[k];
*         suffix[k] = temp;
*     }
* 
*     printf("El sufijo común más largo es: %s\n", suffix);
*     return 0;
* }
*
* Link de grabación de asciinema:
* https://asciinema.org/a/oNDHTWZFqMFf8nezfS1ey9Wu1
***********************************************************************/

.data
    // Mensajes del programa
    prompt_count: .string "Ingresa 3 cadenas\n"
    prompt_str:   .string "Ingresa la cadena %d: "
    result_msg:   .string "El sufijo común más largo es: "
    no_prefix:    .string "No hay sufijo común\n"
    newline:      .string "\n"
    format_str:   .string "%s"
    read_str:     .string " %99s"
    
    // Buffers para almacenar las cadenas
    str1:         .skip 100
    str2:         .skip 100
    str3:         .skip 100
    
    // Variables
    suffix:       .skip 100

.text
.global main

strlen:
    mov x2, #0                // Contador
1:
    ldrb w1, [x0, x2]        // Cargar byte
    cbz w1, 2f               // Si es 0, terminar
    add x2, x2, #1           // Incrementar contador
    b 1b                     // Siguiente byte
2:
    mov x0, x2               // Retornar longitud
    ret

main:
    // Preservar registros
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Mostrar mensaje inicial
    adr x0, prompt_count
    bl printf

    // Leer las 3 cadenas
    mov x20, #0              // Contador de cadenas
read_strings:
    // Imprimir prompt
    adr x0, prompt_str
    add x1, x20, #1
    bl printf

    // Leer cadena
    adr x21, str1
    cmp x20, #1
    b.eq use_str2
    cmp x20, #2
    b.eq use_str3
    b continue_read
use_str2:
    adr x21, str2
    b continue_read
use_str3:
    adr x21, str3
continue_read:
    adr x0, read_str
    mov x1, x21
    bl scanf
    
    // Limpiar buffer
    bl getchar

    add x20, x20, #1
    cmp x20, #3             
    b.lt read_strings

    // Obtener longitudes de las cadenas
    adr x0, str1
    bl strlen
    mov x21, x0             // x21 = longitud str1
    
    adr x0, str2
    bl strlen
    mov x22, x0             // x22 = longitud str2
    
    adr x0, str3
    bl strlen
    mov x23, x0             // x23 = longitud str3

find_suffix:
    mov x20, #0              // Contador de caracteres coincidentes
check_char:
    // Comparar caracteres desde el final
    adr x0, str1
    sub x1, x21, x20
    sub x1, x1, #1
    ldrb w24, [x0, x1]     // Cargar carácter de str1
    
    adr x0, str2
    sub x1, x22, x20
    sub x1, x1, #1
    ldrb w25, [x0, x1]     // Cargar carácter de str2

    cmp w24, w25
    b.ne print_result      // Si son diferentes, terminar
    
    adr x0, str3
    sub x1, x23, x20
    sub x1, x1, #1
    ldrb w25, [x0, x1]     // Cargar carácter de str3

    cmp w24, w25
    b.ne print_result      // Si son diferentes, terminar

    // Guardar carácter en el sufijo (desde el final)
    adr x0, suffix
    strb w24, [x0, x20]    
    
    add x20, x20, #1       // Incrementar contador
    
    // Verificar si hemos llegado al inicio de alguna cadena
    cmp x20, x21
    b.ge print_result
    cmp x20, x22
    b.ge print_result
    cmp x20, x23
    b.ge print_result
    
    b check_char

print_result:
    // Verificar si hay sufijo
    cmp x20, #0
    b.eq no_common_suffix

    // Imprimir mensaje de resultado
    adr x0, result_msg
    bl printf

    // Revertir el sufijo (ya que lo guardamos al revés)
    adr x0, suffix
    mov x1, #0              // índice inicio
    sub x2, x20, #1         // índice final
reverse_loop:
    cmp x1, x2
    b.ge end_reverse
    ldrb w3, [x0, x1]      // temp = str[i]
    ldrb w4, [x0, x2]      // temp2 = str[j]
    strb w4, [x0, x1]      // str[i] = temp2
    strb w3, [x0, x2]      // str[j] = temp
    add x1, x1, #1
    sub x2, x2, #1
    b reverse_loop
end_reverse:    

    // Agregar null terminator
    adr x0, suffix
    strb wzr, [x0, x20]

    // Imprimir sufijo
    adr x0, suffix
    bl printf

    // Imprimir nueva línea
    adr x0, newline
    bl printf
    b exit

no_common_suffix:
    adr x0, no_prefix
    bl printf

exit:
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
