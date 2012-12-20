.MODEL SMALL
.STACK 100H
.DATA

;----------------------------������
ADR_LPT1 DW 0                ; ���������� ��� �������� �������� ������ LPT1
WAIT_5 DW 90                 ;90=5/0.055 �������� 5 ������
A DB 0
SPACE DB 0

;----------------------------������ ������
NO_READY DB 'PRINTER IS NOT READY', 10, 13,'$'
NO_PRINTERPAPER DB 'NO PAPER', 10, 13,'$'
PRINTER_OFF_LINE DB 'PRINTER OFF-LINE', 10, 13,'$'
NO_PORTLPT1 DB 'NO PORT LPT1', 10, 13, '$'
MSG DB '',10,13,'$'

;----------------------------������� �������
.CODE
START:

    MOV AX, @DATA
    MOV DS, AX
    CALL INIT_LPT1          ;����������� ������ ������������ ����
	
    ;������� ����
    PRINT_LOOP:
        CALL ANALIZ_LPT1    ;����� ��������� ������� �������� ���������
        
        MOV AH, 0CH         ;������� ����� ����������
        MOV AL, 01          ;�������� ������� ����� �������
        INT 21H             ;������ �����, ���� �����

        CMP AL, 1BH         ;������ ������� ESC?
        JE EXIT             ;���� ��, �� �����

        CMP AL, 0DH         ;����� ��������� � ������� ��������� ������    
        JE M_ENTER
        CALL OUT_BITE
        JMP PRINT_LOOP

        M_ENTER:
        CALL OUT_BITE

        MOV AH, 09H        ;������� ������
        MOV DX, OFFSET MSG
        INT 21H

    JMP PRINT_LOOP         ;���������, ���� �� ����� ����� ESC

EXIT:
MOV AX,4C00H ; ��������� � ����� �������� 0
INT 21H

;;:::::::::::::::::::::::::::::::::::::
;::::::::::::::::::::::::::::PROCEDURES
;::::::::::::::::::::::::::::::::::::::


;--------------------------��������� ������������� LPT1
INIT_LPT1 PROC 

    MOV AX, 40H
    MOV ES, AX             ;� ES - ������� = 0040H
    MOV DX, ES:[08]        ;DX = ������� ����� ����� LPT1
    MOV ADR_LPT1, DX       ;����� ����� � ADR_LPT1
    CMP ADR_LPT1, 0
    JE NO_LPT1

    INC DX                 ;+2 � �������� ������ �����
    INC DX
	
    MOV AL, 8             ;�������� ��� �������������
    OUT DX, AL            ;�������� �������������
    MOV AX, 1000          ;������ ������� �����	
	
    M1: 
    DEC AX                ;��������� �������
    JNZ M1                ;��������� 1000 ���
	
    MOV AL, 12            ;������� �������� ��� ��������
    OUT DX, AL            ;����� �������������
	
    RET
    
    NO_LPT1:
    MOV AH, 09H
    MOV DX, OFFSET NO_PORTLPT1
    INT 21H
    JMP EXIT

INIT_LPT1 ENDP

;--------------------------��������� ������� �������� ���������
ANALIZ_LPT1 PROC

    MOV AH, 00
    INT 1AH
    ADD WAIT_5, DX
    
    LOOP2:
    INT 1AH
    CMP DX, WAIT_5
    JE NO_READYPRINT
    
    MOV DX, ADR_LPT1
    INC DX               ;����� �������� ���������
    IN AL, DX            ;������ ������� ���������
    TEST AL, 10000000B   ;��������� ���������� �������� "1 - ������� �����"
    JZ LOOP2             ;���� ���, �� �������� �����
      
    TEST AL, 00100000B   ;��������� ������� ������
    JNZ NO_PAPER         ;���, ��������� �� ������
    
    TEST AL, 00010000B   ;������� ON-LINE
    JZ OFF_LINE          ;���, ��������� �� ������
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

;--------------------------����� ������� �� �������
OUT_BITE PROC 

    MOV DX, ADR_LPT1   ;����� �������� ������ (ADR_LPT1)
    OUT DX, AL         ;������ ����� � ������� ������
    INC DX
    INC DX             ;����� �������� ���������� (ADR_LPT1+2)
    IN AL, DX          ;������ ������� ����������

    ;��������� ������������ ������
    AND AL, 11111110B ;��� 0 (STROBE):=0
    OUT DX, AL        ;������ � ������� ����������
    OR AL, 00000001B  ;��� 0 (STROBE):=1
    OUT DX, AL        ;������ � ������� ����������
    AND AL, 11111110B ;��� 0 (STROBE):=0
    OUT DX, AL        ;������ � ������� ����������
    RET
	
OUT_BITE ENDP

END START