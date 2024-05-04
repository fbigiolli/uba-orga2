#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <unistd.h>
#define USE_ASM_IMPL 1

/* Payments */
typedef struct                  // 24 bytes
{
    uint8_t monto;              // offset 0
    uint8_t aprobado;           // offset 1
    char *pagador;              // offset 8
    char *cobrador;             // offset 16
} pago_t;

typedef struct                  // 24 bytes
{
    uint8_t cant_aprobados;     // offset 0
    uint8_t cant_rechazados;    // offset 1
    pago_t **aprobados;         // offset 8
    pago_t **rechazados;        // offset 16
} pagoSplitted_t;

/* List */

typedef struct s_listElem    // 24 Bytes
{
    pago_t *data;            // offset 0
    struct s_listElem *next; // offset 8
    struct s_listElem *prev; // offset 16
} listElem_t;

typedef struct s_list         // 16 bytes
{
    struct s_listElem *first; // offset 0
    struct s_listElem *last;  // offset 8
} list_t;

list_t *listNew();
void listAddLast(list_t *pList, pago_t *data);
void listDelete(list_t *pList);

uint8_t contar_pagos_aprobados(list_t *pList, char *usuario);
uint8_t contar_pagos_aprobados_asm(list_t *pList, char *usuario);

uint8_t contar_pagos_rechazados(list_t *pList, char *usuario);
uint8_t contar_pagos_rechazados_asm(list_t *pList, char *usuario);

pagoSplitted_t *split_pagos_usuario(list_t *pList, char *usuario);

pagoSplitted_t *split_pagos_usuario_asm(list_t *pList, char *usuario);
