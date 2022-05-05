.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm

.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.set RCC_base,(0x40000000 + 0x00020000 + 0x00001000)
.set APB2ENR,0x18
.set GPIOC_CLK_ENABLE,0b10000

.set GPIOC_base,(0x40000000 +  0x00010000 + 0x00001000)
.set CRH,4
.set PIN_13,(1<<13)
.set CRH_PIN_13_POS,20
.set MODO_SALIDA_LENTA, 0b10
.set CFG_GP_PUSH_PULL, 0
.set CFG_MASK,0xF
.set ODR,0x0C
.set BSRR,0x10
.set BRR,0x11
defun setup
    push {LR}
activa_reloj_gpioa:
    ldr R2,=RCC_base
    ldr R0,[R2,#APB2ENR] // CARGA
    orrs R0,GPIOC_CLK_ENABLE // MODIFICACIÓN
    str R0,[R2,#APB2ENR] // ESCRITURA
config_pc13_salida:
    ldr R2,=GPIOC_base
    ldr R0,[R2,#CRH] // CARGA
    bics R0,#(CFG_MASK << CRH_PIN_13_POS) //MOD. (BORRADO)
    orrs R0,#((MODO_SALIDA_LENTA | CFG_GP_PUSH_PULL) << CRH_PIN_13_POS) // MOD. (ESTABLECIMIENTO)
    str R0,[R2,#CRH] // ESCRITURA
    bl TimerSysTick_init
    pop {PC}
endfun setup

defun loop
    push {LR}
    ldr R2,=GPIOC_base
    movs R1,#BSRR
    ldr R0,[R2,#ODR]
    ands R0,#PIN_13
    beq 0f
    adds R1,#4
0:
    movs R0,#PIN_13
    str R0,[R2,R1]
    movs R0,#500
    bl TimerSysTick_esperaMilisegundos
    pop {PC}
endfun loop