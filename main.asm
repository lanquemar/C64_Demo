*=$1000


;
; CONSTANTS
;

SCREEN_BORDER_COLOR             = $D020
CONTROL_REGISTER_1              = $D011
CONTROL_REGISTER_2              = $D016
MEMORY_SETUP_REGISTER           = $D018

SCREEN_COLOR_MEMORY_BEGIN       = $08
SCREEN_COLOR_MEMORY_END         = $0C

SCREEN_PIXELS_MEMORY_BEGIN      = $20
SCREEN_PIXELS_MEMORY_END        = $40

COLOR_BLACK                     = $0
COLOR_BLUE                      = $6

;
; INITIALISATION
;

; Set border color to black
        lda     #COLOR_BLACK
        sta     SCREEN_BORDER_COLOR

; Setup Standard Bitmap Mode
        lda     CONTROL_REGISTER_1
        and     #%10111111 ; Clear bit 6 ECM
        ora     #%00100000 ; Set bit 5 BMM
        sta     CONTROL_REGISTER_1

        lda     CONTROL_REGISTER_2 ; Control Register 2
        and     #%11101111 ; Clear bit 4 MCM
        sta     CONTROL_REGISTER_2

; Change bitmap memory location
        lda     #%00101000 ; Set Screen Block to 7; Bitmap Block to 1
        sta     MEMORY_SETUP_REGISTER


;
; PROGRAM
;

; Turn off pixels of all screen
        ldx     #SCREEN_PIXELS_MEMORY_BEGIN

clear_screen_pixels
        stx     proc_write_256_bytes__loop+2

        ; Push registers on stack
        pha
        txa
        pha

        ; Call procedure
        lda     #$0
        jsr     proc_write_256_bytes

        ; Pull registers from stack
        pla
        tax
        pla

        inx
        cpx     #SCREEN_PIXELS_MEMORY_END
        bne     clear_screen_pixels

; Setup pixel colors of all screen
        ldx     #SCREEN_COLOR_MEMORY_BEGIN

clean_screen_colors
        stx     proc_write_256_bytes__loop+2

        ; Push registers on stack
        pha
        txa
        pha

        ; Call procedure
        lda     #COLOR_BLUE
        jsr     proc_write_256_bytes

        ; Pull registers from stack
        pla
        tax
        pla

        inx
        cpx     #SCREEN_COLOR_MEMORY_END
        bne     clean_screen_colors


;
; DEINITIALISATION
;

; Exit
        rts ; returns to calling procedure


;
; PROCEDURES
;

; Write value REG(A) to the 256 bytes located at
; address (proc_write_256_bytes__loop + 2)
proc_write_256_bytes
        ldx     #0
proc_write_256_bytes__loop
        sta     $0100,X ; dummy value: prevent assembler to optimize instruction
        inx
        cpx     #$00
        bne     proc_write_256_bytes__loop
        rts