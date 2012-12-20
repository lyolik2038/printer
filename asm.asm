.MODEL SMALL
.STACK 100H
.DATA

;----------------------------ярпнйх
ADR_LPT1 DW 0                ; оепелеммюъ дкъ упюмемхъ аюгнбнцн юдпеяю LPT1
WAIT_5 DW 90                 ;90=5/0.055 нфхдюмхе 5 яейсмд
A DB 0
SPACE DB 0

;----------------------------яохянй ньханй
NO_READY DB 'PRINTER IS NOT READY', 10, 13,'$'
NO_PRINTERPAPER DB 'NO PAPER', 10, 13,'$'
PRINTER_OFF_LINE DB 'PRINTER OFF-LINE', 10, 13,'$'
NO_PORTLPT1 DB 'NO PORT LPT1', 10, 13, '$'
MSG DB '',10,13,'$'

;----------------------------цкюбмюъ тсмйжхъ
.CODE
START:

    MOV AX, @DATA
    MOV DS, AX
    CALL INIT_LPT1          ;мюярпюхбюел оепбши оюпюккекэмши онпр
	
    ;цкюбмши жхйк
    PRINT_LOOP:
        CALL ANALIZ_LPT1    ;бшгнб опнжедспш юмюкхгю пецхярпю янярнъмхъ
        
        MOV AH, 0CH         ;нвхыюел астеп йкюбхюрспш
        MOV AL, 01          ;бшахпюел тсмйжхч ббндю яхлбнкю
        INT 21H             ;вхярхл астеп, фдел ббндю

        CMP AL, 1BH         ;мюфюрю йкюбхью ESC?
        JE EXIT             ;еякх дю, рн бширх

        CMP AL, 0DH         ;хмюве нропюбхрэ х бшбеярх ббедеммши яхлбнк    
        JE M_ENTER
        CALL OUT_BITE
        JMP PRINT_LOOP

        M_ENTER:
        CALL OUT_BITE

        MOV AH, 09H        ;оепебнд ярпнйх
        MOV DX, OFFSET MSG
        INT 21H

    JMP PRINT_LOOP         ;онбрнпъел, онйю ме асдер мюфюр ESC

EXIT:
MOV AX,4C00H ; гюбепьхрэ я йнднл бнгбпюрю 0
INT 21H

;;:::::::::::::::::::::::::::::::::::::
;::::::::::::::::::::::::::::PROCEDURES
;::::::::::::::::::::::::::::::::::::::


;--------------------------опнжедспю хмхжхюкхгюжхх LPT1
INIT_LPT1 PROC 

    MOV AX, 40H
    MOV ES, AX             ;б ES - яецлемр = 0040H
    MOV DX, ES:[08]        ;DX = аюгнбши юдпея онпрю LPT1
    MOV ADR_LPT1, DX       ;юдпея онпрю б ADR_LPT1
    CMP ADR_LPT1, 0
    JE NO_LPT1

    INC DX                 ;+2 й аюгнбнлс юдпеяс онпрю
    INC DX
	
    MOV AL, 8             ;гмювемхе дкъ хмхжхюкхгюжхх
    OUT DX, AL            ;мювхмюел хмхжхюкхгюжхч
    MOV AX, 1000          ;мювюкн осярнцн жхйкю	
	
    M1: 
    DEC AX                ;слемэьюел явервхй
    JNZ M1                ;онбрнпъел 1000 пюг
	
    MOV AL, 12            ;нашвмне гмювемхе дкъ пецхярпю
    OUT DX, AL            ;йнмеж хмхжхюкхгюжхх
	
    RET
    
    NO_LPT1:
    MOV AH, 09H
    MOV DX, OFFSET NO_PORTLPT1
    INT 21H
    JMP EXIT

INIT_LPT1 ENDP

;--------------------------опнжедспю юмюкхгю пецхярпю янярнъмхъ
ANALIZ_LPT1 PROC

    MOV AH, 00
    INT 1AH
    ADD WAIT_5, DX
    
    LOOP2:
    INT 1AH
    CMP DX, WAIT_5
    JE NO_READYPRINT
    
    MOV DX, ADR_LPT1
    INC DX               ;юдпея пецхярпю янярнъмхъ
    IN AL, DX            ;вхрюел пецхярп янярнъмхъ
    TEST AL, 10000000B   ;опнбепъел цнрнбмнярэ опхмрепю "1 - опхмреп цнрнб"
    JZ LOOP2             ;еякх мер, рн онбрнпхл нопня
      
    TEST AL, 00100000B   ;опнбепъел мюкхвхе аслюцх
    JNZ NO_PAPER         ;мер, яннаыемхе на ньхайх
    
    TEST AL, 00010000B   ;опхмреп ON-LINE
    JZ OFF_LINE          ;мер, яннаыемхе на ньхайх
    RET
    
    NO_READYPRINT:
    MOV AH, 09H
    MOV DX, OFFSET NO_READY
    INT 21H
    JMP EXIT
    
    NO_PAPER:
    MOV AH, 09H
    MOV DX, OFFSET NO_PRINTERPAPER
    INT 21H
    JMP EXIT
    
    OFF_LINE:
    MOV AH, 09H
    MOV DX, OFFSET PRINTER_OFF_LINE
    INT 21H
    JMP EXIT
    
ANALIZ_LPT1 ENDP

;--------------------------бшбнд яхлбнкю мю опхмреп
OUT_BITE PROC 

    MOV DX, ADR_LPT1   ;юдпея пецхярпю дюммшу (ADR_LPT1)
    OUT DX, AL         ;гюохяэ аюирю б пецхярп дюммшу
    INC DX
    INC DX             ;юдпея пецхярпю сопюбкемхъ (ADR_LPT1+2)
    IN AL, DX          ;вхрюел пецхярп сопюбкемхъ

    ;тнплхпсел ярпнахпсчыхи яхцмюк
    AND AL, 11111110B ;ахр 0 (STROBE):=0
    OUT DX, AL        ;гюохяэ б пецхярп сопюбкемхъ
    OR AL, 00000001B  ;ахр 0 (STROBE):=1
    OUT DX, AL        ;гюохяэ б пецхярп сопюбкемхъ
    AND AL, 11111110B ;ахр 0 (STROBE):=0
    OUT DX, AL        ;гюохяэ б пецхярп сопюбкемхъ
    RET
	
OUT_BITE ENDP

END START