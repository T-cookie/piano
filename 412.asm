;######################## �꺯�� #################################
CLEAR MACRO A,B,C,D,COL ;��������,A,BΪ���Ͻ����꣬C,DΪ���½�,��ɫΪCOL
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
   MOV AH,6             ;INT 10H��6�ŵ��� 
   MOV AL,0             ;AL = 0ʱΪ����
   MOV CH,A             ;CH,CLΪ���Ͻ���ߣ�DH.DLΪ���½�����
   MOV CL,B             
   MOV DH,C             
   MOV DL,D 
   MOV BH,COL           ;BHΪ��ɫ���ԣ���λ��ʾ����
   INT 10H              ;�����������죬�����̣���������������ǰ���죬ǰ���̣�ǰ���� 
   POP DX
   POP CX
   POP BX
   POP AX
ENDM

DISPMSG MACRO MESSAGE   ;�ڵ�ǰ���λ����ʾ�ַ�������
   PUSH DX
   PUSH AX
   LEA DX,MESSAGE       ;DX���Ҫ��ʾ�ַ���ƫ�Ƶ�ַ
   MOV AH,9           
   INT 21H 
   POP AX
   POP DX
ENDM

GETCHAR MACRO           ;��ȡ��ǰ���λ���ַ�����
   PUSH BX
   MOV AH,08H           ;AL = �ַ��룬AH = �ַ�����
   MOV BH,0
   INT 10H
   POP BX
ENDM

CURS MACRO A,B          ;�ù��λ��,����Ϊ(A.B) 
   PUSH AX
   PUSH BX
   PUSH DX
   MOV AH,2             ;INT 10H��2�ŵ���
   MOV BH,0
   MOV DH,A
   MOV DL,B           
   INT 10H              
   POP DX
   POP BX
   POP AX  
ENDM

COLCHAR MACRO C,CHAR    ;�ڵ�ǰ���λ�������ɫ�ַ�,CΪ��ɫ��CHARΪ�ַ�
   PUSH AX
   PUSH BX
   PUSH CX
   MOV BH,0             ;BH = ��ʾҳ
   MOV BL,C             ;BL = ��ɫ����
   MOV CX,1             ;CX = �ַ��ظ�����
   MOV AL,CHAR          ;AL = �ַ�
   MOV AH,09H           ;INT 10H��9�ŵ���
   INT 10H              
   POP CX
   POP BX
   POP AX
ENDM

SCROLL MACRO B,D,COL    ;���ҷ�����������¹���һ�У�B,D=0,39Ϊ��,40,79Ϊ�ҷ���COLΪ����ɫ
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX

   MOV AH,07H           ;INT 10H 07�Ź������¹���   
   MOV AL,01H           ;AL = 1��ʾ��һ�п�ʼ���¹���һ��
   MOV BH,COL           ;CH,CLΪ���Ͻ���ߣ�DH.DLΪ���½�����
   MOV CH,1            
   MOV CL,B
   MOV DH,47
   MOV DL,D
   INT 10H

   POP DX
   POP CX
   POP BX
   POP AX
ENDM

CLEARBUFF MACRO         ;��ջ�����
   PUSH AX
   MOV AH,0CH        
   MOV AL,0
   INT 21H
   POP AX 
ENDM

;################################################################
;�鿴�˿���Դ�����������¼ʵ��ϵͳI/O�˿�ʼ��ַ
   INTR_IVADD       EQU   003CH         ;INTR��Ӧ���ж�ʸ����ַ
   IOY0             EQU   0E000H        ;ƬѡIOY0��Ӧ�Ķ˿�ʼ��ַ
   MY8255_A         EQU   IOY0+00H*4    ;8255��A�ڵ�ַ����Ӧ���̵�ɨ���л�����ܵ�ѡͨ�����
   MY8255_B         EQU   IOY0+01H*4    ;8255��B�ڵ�ַ����Ӧ����ܵ�д���
   MY8255_C         EQU   IOY0+02H*4    ;8255��C�ڵ�ַ����Ӧ���̵�ɨ����
   MY8255_MODE      EQU   IOY0+03H*4    ;8255�Ŀ��ƼĴ�����ַ
   
   IOY1             EQU   0E040H        ;ƬѡIOY1��Ӧ�Ķ˿�ʼ��ַ
   MY8254_COUNT0    EQU   IOY1+00H*4    ;8254������0�˿ڵ�ַ
   MY8254_COUNT1    EQU   IOY1+01H*4    ;8254������1�˿ڵ�ַ
   MY8254_COUNT2    EQU   IOY1+02H*4    ;8254������2�˿ڵ�ַ
   MY8254_MODE      EQU   IOY1+03H*4    ;8254���ƼĴ����˿ڵ�ַ

   PC8254_COUNT0    EQU   40H           ;PC����8254��ʱ��0�˿ڵ�ַ
   PC8254_MODE      EQU   43H           ;PC����8254���ƼĴ����˿ڵ�ַ
   IOY2             EQU   0E080H
;################################################################

STACK1  SEGMENT STACK
   DW  256 DUP(?)   
STACK1  ENDS

DATA    SEGMENT
   MSG0    DB 'SCORE: $'
   MSG1    DB ' =========================================','$' ;��ʼ����
   MSG2    DB ' ====                                  ===','$'    
   MSG3    DB ' ====       Single Training Mode       ===','$'
   MSG4    DB ' ====       Double  Battle  Mode       ===','$'
   MSG12   DB ' ====                Fan               ===','$'  
   MSG5    DB ' ====                Quit              ===','$'
   MSG6    DB ' ====                                  ===','$'
   MSG7    DB ' =========================================','$'
   MSG8    DB 'Press space back to menu','$'
   MSG9    DB 'BATTLE','$'
   MSG10   DB 'YOU WIN!!!','$'
   MSG11   DB 'YOU LOSS...','$'
   MSG13   DB 'Assumed Fan Speed:(/s)','$'
   MSG14   DB 'Current Fan Speed:(/s)','$'
   NOWRAND256  DB  0       ;��ŵ�ǰ0-255�����
   NOWRAND40   DB  0       ;��ŵ�ǰ0-39�����
   MODE        DB  1       ;��ǰ��Ϸģʽ������1or˫��2
   DEGREE      DW  0       ;��ǰ�Ѷȵȼ�
   TURNSCOR    DB  8       ;ÿ�ö��ٷֽ�����һ�Ѷȵȼ�
   SPEED       DB  30,24,19,15,12   ;�����ٶȣ�ԽСԽ�죬�ֱ����Ѷ�1,2,3,4,5
   Llocation   DB  19      ;����󷽵�ǰ0λ��
   Rlocation   DB  59      ;����ҷ���ǰλ��
   LSCORE      DB  0       ;����󷽵�ǰ����
   RSCORE      DB  0       ;����ҷ���ǰ����
   LNEEDSCOR   DB  5       ;����Ҫ�ٵö��ٲ��ܽ�����һ���Ѷȵȼ�
   RNEEDSCOR   DB  5       ;�ҷ�����Ҫ�ٵö��ٲ��ܽ�����һ���Ѷȵȼ�
   DELICACY    DB  10      ;����������
   DTABLE      DB  3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH     ;��ֵ��0��F��Ӧ��7������ܵĶ�λֵ
   SCORE_TABLE DB  00H,00H,00H,00H,00H,00H                     ;������
   FREQ_LIST   DW  661,21000,661,21000,661,22000,661,21000,661,700,21000,700,21000,700,21000,700,21000,700,589,21000,589,21000,589,21000,589,495,21000,495,21000,495,21000,495,21000    
               DW  661,21000,661,21000,661,22000,661,21000,661,700,21000,700,21000,700,21000,700,21000,700,589,21000,589,21000,589,21000,589,495,21000,495,21000,495,21000,495,21000 
               DW  661,882,990,1178,700,882,900,1178,786,882,1178,1049,990,21000        
               DW  661,882,990,1178,700,882,900,1178,786,882,1178,1049,990,0  				;��ʼ����BGMƵ�ʱ�

   TIME_LIST   DB  7,1,7,1,8,4,3,1,4,3,1,7,1,7,1,3,1,4,7,1,7,1,8,4,4,3,1,3,1,7,1,12,2   
               DB  7,1,7,1,8,4,3,1,4,3,1,7,1,7,1,3,1,4,7,1,7,1,8,4,4,3,1,3,1,7,1,12,2		
               DB  8,8,8,8,8,8,8,8,8,8,8,8,20,4
               DB  8,8,8,8,8,8,8,8,8,8,8,8,20		;��ʼ����BGMʱ���
   EIGHT       DB  08H 
   FREQIDX     DW  0                ;��ǰ����Ƶ��
   FREQTYPE    DB  0                ;��Ч���ͣ�0Ϊ1�֣�1Ϊ3��
   FREQ2       DW  23000,294,350    ;1����ЧƵ�ʱ�
   FREQ1       DW  661,589,525      ;3����ЧƵ�ʱ�
   LIGHT       DW  0FF80H  
   WINSCORE    DB  40
   ROW         DB  19

   CS_BAK   DW  ?                ;����INTRԭ�жϴ��������ڶε�ַ�ı���
   IP_BAK   DW  ?                ;����INTRԭ�жϴ���������ƫ�Ƶ�ַ�ı���
   IM_BAK   DB  ?,?              ;����INTRԭ�ж������ֵı���
   CS_BAK1  DW  ?                ;���涨ʱ��0�жϴ��������ڶε�ַ�ı���
   IP_BAK1  DW  ?                ;���涨ʱ��0�жϴ���������ƫ�Ƶ�ַ�ı���
   IM_BAK1  DB  ?,?              ;���涨ʱ��0�ж������ֵı���
         
   TS       DB 20                  ;��������
   SPEC     DW 55                  ;ת�ٸ���ֵ   55
   IBAND    DW 0060H               ;���ַ���ֵ   96
   KPP      DW 1060H               ;����ϵ��     4192
   KII      DW 0010H               ;����ϵ��     16
   KDD      DW 0020H               ;΢��ϵ��     32
   
   YK       DW 0000H               ;������
   CK       DB 00H                 ;������
   VADD     DW 0000H
   ZV       DB 00H
   ZVV      DB 00H
   TC       DB 00H
   FPWM     DB 01H
   CK_1     DB 00H
   EK_1     DW 0000H
   AEK_1    DW 0000H
   BEK      DW 0000H
   AAAA     DB 7FH
   VAA      DB 7FH
   BBB      DB 00H
   VBB      DB 00H
   MARK     DB 00H
   R0       DW 0000H
   R1       DW 0000H
   R2       DW 0000H
   R3       DW 0000H
   R4       DW 0000H
   R5       DW 0000H
   R6       DW 0000H
   R7       DB 00H
   R8       DW 0000H   
   
DATA    ENDS

;########################### ������ ##############################

CODE    SEGMENT
   ASSUME  CS:CODE,DS:DATA,SS:STACK1
START:
   MOV AX,DATA
   MOV DS,AX
   
   MOV DX,IOY2              ;�ʼ��ˮ��ȫ��
   MOV AL,00H
   OUT DX,AL
   
   MOV  DX,MY8255_MODE      ;��ʼ��8255������ʽ 
   MOV  AL,81H              ;��ʽ0��A�ڡ�B�������C�ڵ�4λ����,��4λ���  
   OUT  DX,AL

   CLEAR 0,0,100,100,03EH   ;������׻���
   ;����ʼ�����PICK
   CLEAR 3,18,16,19,05EH    ;P    
   CLEAR 3,20,4,24,05EH         
   CLEAR 9,20,10,24,05EH           
   CLEAR 5,24,8,25,05EH 
   CLEAR 3,30,4,35,05EH     ;I
   CLEAR 5,32,14,33,05EH          
   CLEAR 15,30,16,35,05EH              
   CLEAR 5,40,14,41,05EH    ;C
   CLEAR 3,42,4,46,05EH        
   CLEAR 15,42,16,46,05EH        
   CLEAR 5,47,7,48,05EH
   CLEAR 12,47,14,48,05EH
   CLEAR 3,53,16,54,05EH    ;K
   CLEAR 9,55,10,56,05EH
   CLEAR 7,57,8,58,05EH
   CLEAR 5,59,6,60,05EH
   CLEAR 3,60,4,61,05EH
   CLEAR 11,57,12,58,05EH
   CLEAR 13,59,14,60,05EH
   CLEAR 15,60,16,61,05EH

   CURS 17,21          ;���ѡ��ģʽ��ʾ��Ϣ��
   DISPMSG MSG1
   CURS 18,21
   DISPMSG MSG2
   CURS 19,21
   DISPMSG MSG3
   CURS 20,21
   DISPMSG MSG4
   CURS 21,21
   DISPMSG MSG12
   CURS 22,21
   DISPMSG MSG5
   CURS 23,21
   DISPMSG MSG6
   CURS 24,21
   DISPMSG MSG7

   CURS 19,31              ;���λ�ڲ˵���һ��
   COLCHAR 03CH,10H
   MOV ROW,19               

   MOV DX,MY8254_MODE      ;��ʼ��8254������ʽ
   MOV AL,0B6H             ;��ʱ��2����ʽ3
   OUT DX,AL
   CLEARBUFF
   
BEGIN2:                        ;���ſ�ʼ���汳������
   MOV SI,OFFSET FREQ_LIST     ;װ��Ƶ�ʱ���ʼ��ַ
   MOV DI,OFFSET TIME_LIST     ;װ��ʱ�����ʼ��ַ
   
PLAY2: 
   MOV DX,0FH             ;����ʱ��Ϊ1.0416667MHz��1.0416667M = 0FE502H  
   MOV AX,0E502H                
   DIV WORD PTR [SI]      ;ȡ��Ƶ��ֵ���������ֵ��0F4240H / ���Ƶ��  
   MOV DX,MY8254_COUNT2
   OUT DX,AL              ;װ�������ֵ
   MOV AL,AH
   OUT DX,AL
   
   MOV DL,[DI]            ;ȡ���������ʱ�䣬������ʱ�ӳ��� 
   CALL DALLY3
   
   ADD SI,2
   INC DI
   CMP WORD PTR [SI],0         ;�ж��Ƿ���ĩ��
   JE  BEGIN2
   
   MOV AH,1        ;INT 16H 01H ������״̬ 
   INT 16H         ;���û�м����£�ZF=1������PLAY2
   JZ  PLAY2       
   
   MOV AH,0        ;����м����£�����INT 16H 00H ��ȡ���µ����ĸ���
   INT 16H         ;���ڲ�����AH ����ɨ���룬00H�Ź���һ��ֻ�ܶ�ȡһ����
   CLEARBUFF       ;Ϊ�˱����ж���ַ�û��ȡ�ڴ���һ�����������
   CMP AH,48H      ;��Ϊ����Ҫ������·������û��ASCII�룬ֻ�м���ɨ����
   JE UP           ;��Ȼ������01H�Ź����ܶ�ȡɨ���룬����ʵ��ʵ���ж�ȡʧ��
   CMP AH,50H      ;����01H�Ź��ܶ�ȡ�����ַ�ASCII��Ҳ������һϵ������
   JE DOWN         ;��00H�Ź���û����,��00H�Ź��ܵ�û�а���ʱ��ֹͣ�ȴ�����
   CMP AH,1CH      ;��������ѭ��Ϊ���壬��������ֹ���ֵĲ���
   JE ENTER0       ;������������01H�Ź����ж��Ƿ��а�������
                   ;���������00H�Ź��ܶ�ȡ����ɨ�����ж��ĸ���������
TOPLAY2:    
   JMP PLAY2
UP:                ;����������  
   MOV DL,ROW      
   CMP DL,19       ;�����ǰ��λ����в������ƶ�
   JE PLAY2 
   CURS DL,31          
   COLCHAR 03CH,20H    ;���ÿո񸲸ǵ�ǰ�У������������
   DEC DL
   MOV ROW,DL
   CURS DL,31
   COLCHAR 03CH,10H    ;������һ�л�һ��������
   JMP PLAY2
ENTER0:                ;������ת�������������һ����ת��תվ
   JMP ENTER1    
DOWN: 
   MOV DL,ROW          ;�����ǰ��λ������в������ƶ�
   CMP DL,22
   JE TOPLAY2 
   CURS DL,31          ;���������
   COLCHAR 03CH,20H
   INC DL
   MOV ROW,DL
   CURS DL,31
   COLCHAR 03CH,10H    ;����һ�л�һ��������
   JMP PLAY2 
ENTER1:
   MOV DX,MY8254_MODE  ;������Ϸֹͣ���ű�������
   MOV AL,0B0H         ;����8254Ϊ��ʽ2��OUT0��0
   OUT DX,AL

   MOV DL,ROW          ;���ݵ�ǰ��λ���жϽ�����һ��ģʽ
   CMP DL,19
   JZ SINGLEMODE
   CMP DL,20
   JZ DOUBLEMODE
   CMP DL,21
   JZ FAN   
   JMP QUIT

 SINGLEMODE:            ;����ģʽ
   MOV MODE,1
   JMP START1
 DOUBLEMODE:            ;˫��ģʽ
   MOV MODE,2
   JMP START1
 FAN:                   ;���ȵ���ģʽ
   STI
   CLEAR 0,0,79,79,0EH
   CURS 28,15
   DISPMSG MSG13
   MOV  AX,SPEC         ;������ֵ�����ר�ý�����ʾ
   MOV  DI,0D80H
   CALL SEND
   MOV  AX,SPEC
   CURS 29,18
   CALL SHOWSPEED
   CURS 30,15
   DISPMSG MSG14
   CURS 32,15
   DISPMSG MSG8
   CALL ZHILIU   
   CLI
   JMP  START

START1:                     ;��Ϸ��ʼ
   CLEAR 0,0,49,39,0EH      ;��������Ϸ����ڵ�
   CLEAR 0,40,49,79,5EH     ;�����ҷ���Ϸ�����ϵ�
   CLEAR 0,0,0,79,04EH      ;������ʾ����������������
   MOV DEGREE,0             ;��ʼ��������Ϸ��Ϣ       
   MOV Llocation,19
   MOV Rlocation,59
   MOV LSCORE,0
   MOV RSCORE,0
   MOV AL,TURNSCOR
   MOV LNEEDSCOR,AL
   MOV RNEEDSCOR,AL
   MOV DELICACY,10
   MOV FREQIDX,0
   MOV LIGHT,0FF80H

   MOV AL,MODE              ;��ͬģʽ��ʾ������λ�õ������ͬ
   CMP AL,1                 ;���ݵ�ǰģʽ��ת
   JE SINGLEMODE1
   JMP DOUBLEMODE1
SINGLEMODE1:                ;����ģʽ
   CURS 20,49
   DISPMSG MSG0             ;��ʾ����ģʽ�����ַ���
   MOV BL,Llocation
   CALL DRAW_LHAT           ;����ģʽֻ��Ҫ��һ���ӱ�Ц��
   CURS 20,56
   MOV AL,LSCORE
   CALL SHOWLSCORE          ;����ģʽֻ��Ҫ��ʾһ������
   CURS 23,49
   DISPMSG MSG8             ;��ʾ��Ϣ�ַ���
   JMP NEXT1
TOSTART2:
   JMP START
DOUBLEMODE1:                ;˫��ģʽ
   CURS 0,15
   DISPMSG MSG0             ;��ʾ˫��ģʽ�����ַ���
   CURS 0,55
   DISPMSG MSG0            
   MOV BL,Llocation         ;˫��ģʽ��Ҫ�������ӱ�Ц��
   CALL DRAW_LHAT
   MOV BL,Rlocation
   CALL DRAW_RHAT
   MOV AL,LSCORE
   CURS 0,21
   CALL SHOWLSCORE          ;˫��ģʽֻ��Ҫ��ʾ��������
   MOV AL,RSCORE
   CURS 0,61
   CALL SHOWRSCORE      
   CALL COUNTDOWN           ;˫��ģʽ��Ϸ��ʼʱ��Ҫ����ʱ
   MOV AX,LIGHT
   MOV DX,IOY2
   OUT DX,AX
NEXT1:
   MOV AH,0             ;ȡ��ǰϵͳʱ����Ϊ���������
   INT 1AH              ;ʱ���ж�,���:AH=00��ϵͳʱ��;AH=01��ϵͳʱ��
   MOV AX,DX            ;����ֵ:CX=ϵͳʱ�Ӽ�����λ��,DX=ϵͳʱ�Ӽ�����λ��
   MOV BL,255           ;��ȡֵ��ʾ���ٸ�1/18.20648��
   DIV BL
   MOV NOWRAND256,AH    ;���ɵ�һ��0~255�����
   CALL NEXT_RAND       ;���ɵ�һ��0~39�����
   

   MOV CX,5             ;����ϣ���ʼ���ɵĵ��߲���3�ֵ�
   JMP LOOP1            ;����ֱ����ת����һ��ѭ��
LOOP0:                  ;ÿ��5������һ��3�ֵĵ���
   MOV CX,6             ;ÿѭ��5��LOOP1�Ż�ִ��һ��LOOP0
   MOV AL,NOWRAND40
   CURS 1,AL
   COLCHAR 0BH,08H      ;ȡ��ǰ���������ߵ�һ��׼�������3�ֵ���

   MOV AH,MODE          ;���ݵ�ǰģʽ�ж��Ƿ���Ҫ���ұ�׼�������3�ֵ���
   CMP AH,1
   JE NEXTL2            ;�������3�ֵ���ֱ��������1�ֵ���
   ADD AL,40
   CURS 1,AL
   COLCHAR 5BH,08H
   JMP NEXTL2               
LOOP1:                      
   MOV AL,NOWRAND40     ;ȡ��ǰ���������ߵ�һ��׼�������1�ֵ���
   CURS 1,AL
   COLCHAR 0EH,03H

   MOV AH,MODE          ;���ݵ�ǰģʽ�ж��Ƿ���Ҫ���ұ�׼�������1�ֵ���
   CMP AH,1
   JE NEXTL2
   ADD AL,40
   CURS 1,AL
   COLCHAR 5EH,03H
NEXTL2:
   MOV BX,10            ;����2�����ģ���10������
   CALL NEXT_RAND       ;��ȡ��һ�������
LOOP2:                  ;ÿѭ��10��LOOP2����������һ�У��Ż�������һ������
   MOV AH,MODE          ;���ݵ�ǰģʽ�ж���˫����������һ������
   CMP AH,1             ;�Լ�����Ҫ��ʾ��λ��
   JE NEXTL3
                        ;˫��ģʽ
   CALL DETECTUPL       ;����󷽽ӱ�Ц���Ϸ��Ƿ��е��ߴӶ��жϼӷ�
   MOV AL,LSCORE
   CURS 0,21
   CALL SHOWLSCORE      ;��ʾ�󷽷���
   SCROLL 0,39,00H      ;�󷽹����½�

   CALL DETECTUPR       ;����ҷ��ӱ�Ц���Ϸ��Ƿ��е��ߴӶ��жϼӷ�
   MOV AL,RSCORE
   CURS 0,61
   CALL SHOWRSCORE      ;��ʾ�ҷ�����
   SCROLL 40,79,5FH     ;�ҷ������½�
   JMP NEXTL31
NEXTL3:                 ;����ģʽ������ֻ����
   CALL DETECTUPL
   MOV AL,LSCORE
   CURS 20,56
   CALL SHOWLSCORE
   SCROLL 0,39,00H 
   JMP NEXTL32
NEXTL31: 
   MOV AH,WINSCORE      
   MOV AL,LSCORE        ;˭�ȵ�40��˭��Ӯ
   CMP AL,AH
   JGE LWIN
   MOV AL,RSCORE
   CMP AL,AH
   JGE TORWIN1

NEXTL32:
   CALL DEGREEUP        ;�ж��Ѷ��Ƿ�Ҫ����
   PUSH BX           
   MOV SI,DEGREE        
   MOV BL,SPEED[SI]     ;�ٶȱ�ȡ��ǰ�Ѷȵ�����ֵ���ǵ�ǰ�ٶ�
   JMP LOOP3
TORWIN1:                ;������ת��תվ
   JMP RWIN
LOOP20:                 
   JMP LOOP2
LOOP10:
   JMP LOOP1
LOOP3:
   MOV AL,DELICACY   ;DELICACY���������ȱ�ʾѭ�����ٴ�LOOP3��ɨ��һ�μ���
   DEC AL
   MOV DELICACY,AL
   JNZ B1 
                  ;ͬ�����ü�����ʱ��ʱ����Ϊ�ӵ�����Чÿ��Ƶ�ʵ���ʱʱ��
   CALL MUSIC     ;��MUSIC�ӳ����ڿ�����Ч��Ȼ��һ��������ʱ��ȡ���������
NOTMUSIC:
   MOV DELICACY,10
   CALL CCSCAN       ;ɨ��ʵ������̣��Ƿ��м�����
   JZ  PCKEY
   CALL CCMOVE       ;�м����½����ӳ����ж����ĸ���������������Ӧ�ƶ�����
PCKEY:   
   MOV AH,1          ;�жϵ��Լ����Ƿ��м�����
   INT 16H           ;���Ǽ��ϵ��Լ�����Ҫ��Ϊ����ƽʱ������ϷЧ��
   JZ  B1 
   CLEARBUFF         ;���������
   CALL MOVE         ;���ݼ�������ļ��ƶ���
B1:
    CALL DALLY       ;��Ϸ�������ڲ�ѭ������ʱ����
    DEC BL
    JNZ LOOP3
    POP BX
    DEC BX
    JNZ LOOP20       ;û��ֱ����תLOOP2��LOOP1����Ϊ��ת�������
    DEC CX
    JNZ LOOP10
    JMP LOOP0
   
LWIN:                   ;����һ�ʤ�����Ӧ�ַ���
   CLEAR 1,0,47,39,0EH
   CLEAR 1,40,47,79,5EH
   CURS 20,15
   DISPMSG MSG10
   CURS 20,55
   DISPMSG MSG11
   JMP WAITSPACE        
RWIN:                   ;�ҷ���һ�ʤ�����Ӧ�ַ���
   CLEAR 1,0,47,39,0EH
   CLEAR 1,40,47,79,5EH
   CURS 20,15
   DISPMSG MSG11
   CURS 20,55
   DISPMSG MSG10
   JMP WAITSPACE        
WAITSPACE:
   CALL WINLIGHT       ;��ˮ����˸���ҵȴ��ո񷵻����˵�
   
TOSTART1:              ;��ת��תվ
   JMP TOSTART2
   
QUIT:                  ;�������򷵻ز���ϵͳ
   MOV AH,4CH
   INT 21H

;#################################################################

;########################## �Ӻ��� ################################

MOVE PROC              ;(����ƽʱ����)�����Լ��̰��µİ������ĸ��������ƶ�
   PUSH BX
   PUSH CX
   MOV BL,Llocation
   MOV BH,Rlocation
   CMP AL,' '          ;�м����£��ж��Ƿ�Ϊ0����һ����
   JE  TOSTART1
   CMP AL,'d'          ;�м����£��ж��Ƿ�Ϊ6�����ƣ�
   JE  RMOVEL
   CMP AL,'a'          ;�м����£��ж��Ƿ�Ϊ4�����ƣ�
   JE  LMOVEL

   MOV CL,MODE
   CMP CL,1
   JE RETURN20
   CMP AL,'l'          ;�м����£��ж��Ƿ�Ϊ6�����ƣ�
   JE  RMOVER
   CMP AL,'j'          ;�м����£��ж��Ƿ�Ϊ4�����ƣ�
   JE  LMOVER
   JMP RETURN2         ;������������
 RMOVEL:               ;��Ц�������ƶ�
   CMP BL,38
   JE  RETURN20
   INC BL
   CLEAR 48,0,49,39,0FH    ;������Ц����λ��     
   CALL DRAW_LHAT          ;���µ�λ�û���Ц��
 RETURN20:                 ;��ת��תվ
   JMP RETURN2
 LMOVEL:                   ;��Ц�������ƶ�
   CMP BL,1
   JE  RETURN2
   DEC BL
   CLEAR 48,0,49,39,0FH    ;������Ц����λ��      
   CALL DRAW_LHAT          ;���µ�λ�û���Ц��
   JMP RETURN2
 RMOVER:                   ;�ҷ�Ц�������ƶ�
   CMP BH,78
   JE  RETURN2
   INC BH
   CLEAR 48,40,49,79,5FH   ;�����ҷ�Ц����λ��v
   PUSH BX                     
   MOV BL,BH           
   CALL DRAW_RHAT          ;���µ�λ�û���Ц��
   POP BX
   JMP RETURN2
 LMOVER:                   ;�ҷ�Ц�������ƶ�
   CMP BH,41
   JE  RETURN2
   DEC BH
   CLEAR 48,40,49,79,5FH   ;�����ҷ�Ц����λ��     
   PUSH BX                     
   MOV BL,BH           
   CALL DRAW_RHAT          ;���µ�λ�û���Ц��
   POP BX
   JMP RETURN2
 RETURN2:                  ;�Ѹ��µ�λ�ô������Ӧ����
   MOV Llocation,BL
   MOV Rlocation,BH
   POP CX
   POP BX
   RET
MOVE ENDP   

CCMOVE PROC             ;ɨ�谴�� 
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX

   MOV  BL,Llocation
   MOV  BH,Rlocation
   MOV  CH,0FEH         ;���ó�ʼɨ����Ϊ��һ��
   MOV  CL,00H          ;���õ�ǰ�����ǵڼ���,0��ʾ��һ��
 COLUM: 
   MOV  AL,CH           ;ѡȡһ�У���X1��X4��һ����0            
   MOV  DX,MY8255_A 
   OUT  DX,AL
   MOV  DX,MY8255_C     ;��Y1��Y4�������ж�����һ�а����պ� 
   IN   AL,DX

   CMP  AL,07H          ;�Ƿ�Ϊ��4��
   JNE  RNEXT           ;����������ж�
   CMP  CL,00H
   JE   CCLMOVEL
   CMP  CL,01H
   JE   CCLMOVER
 RNEXT:   
   CMP  AL,0BH          ;�Ƿ�Ϊ��3��
   JNE  CCNEXT          ;����������ж�
   CMP  CL,02H
   JE  CCRMOVEL
   CMP  CL,03H
   JE  CCRMOVER
   JMP  CCNEXT          ;������������
 CCLMOVEL:
   DEC BL
   JMP CCNEXT
 CCLMOVER:
   INC BL
   JMP CCNEXT
 CCRMOVEL:
   DEC BH
   JMP CCNEXT
 CCRMOVER:
   INC BH
 CCNEXT:  
   INC  CL              ;��ǰ������������   
   CMP  CL,04H          ;����Ƿ�ɨ�赽��4��
   JE   KERR            ;�����Ц��λ�ý��и���
   ROL  CH,1            ;û��⵽��4����׼�������һ��
   JMP  COLUM  
 
 KERR:                  ;һ�¶�Ц��λ�ý��и���ΪMOVE�ӳ����е���ͬ
   CMP BL,1
   JB  CCLML
   CMP BL,38
   JA  CCLMR
   JMP CCDRAWL
 CCLML:
   MOV BL,1
   JMP CCDRAWL
 CCLMR:
   MOV BL,38
   JMP CCDRAWL
 CCDRAWL: 
   CLEAR 48,0,49,39,0FH        ;������Ц����λ��      
   MOV  Llocation,BL      
   CALL DRAW_LHAT
   MOV AL,MODE
   CMP AL,1
   JE  RETURN5
   CMP BH,41
   JB  CCRML
   CMP BH,78
   JA  CCRMR
   JMP CCDRAWR
 CCRML:
   MOV BH,41
   JMP CCDRAWR
 CCRMR:
   MOV BH,78
   JMP CCDRAWR
 CCDRAWR: 
   CLEAR 48,40,49,79,5FH       ;�����ҷ�Ц����λ��   
   MOV  BL,BH        
   CALL DRAW_RHAT
   MOV  Rlocation,BH
 RETURN5:
   POP DX
   POP CX
   POP BX
   POP AX
   RET
CCMOVE ENDP

CCSCAN PROC NEAR        ;ɨ��ʵ��������Ƿ��м������ӳ���
   PUSH AX
   PUSH DX

   MOV  AL,00H                              
   MOV  DX,MY8255_A     ;��4��ȫѡͨ��X1��X4��0
   OUT  DX,AL
   MOV  DX,MY8255_C 
   IN   AL,DX           ;��Y1��Y4
   NOT  AL              ;ȡ��Y1��Y4�ķ�ֵ
   AND  AL,0FH          ;��flags����AL=00H,��AND������ZF=1��˵���޼�����

   POP DX
   POP AX
   RET
CCSCAN ENDP

MUSIC PROC              ;���Žӵ�����Ч��ǰƵ��
   PUSH AX
   PUSH BX
   PUSH DX
   
   MOV DX,MY8254_MODE   ;��8254Ϊ��ʽ2��OUT0��0ȡ���������
   MOV AL,90H          
   OUT DX,AL

   MOV AX,FREQIDX     ;FREQIDX��ʾ��ǰ��Ч���Ƶ�ʵ�����ֵ��Ϊ0��ʾû����Ч
   CMP AX,0     
   JZ  RETURNM        ;FREQIDX��Ϊ0��ʾû����ЧҪ���

   MOV DX,MY8254_MODE   ;��ʼ��8254������ʽ
   MOV AL,0B6H          ;��ʱ��2����ʽ3
   OUT DX,AL
   
   MOV BX,FREQIDX
   SUB BX,2
   MOV FREQIDX,BX
   
   MOV AL,FREQTYPE
   CMP AL,0
   JE  TYPE1
   
   MOV SI,OFFSET FREQ1
   JMP PLAYMM             
 TYPE1:
   MOV SI,OFFSET FREQ2
 PLAYMM: 
   ADD SI,BX  
   MOV DX,0FH           ;����ʱ��Ϊ1.0416667MHz��1.0416667M = 0FE502H  
   MOV AX,0E502H   
   DIV WORD PTR [SI]    ;ȡ��Ƶ��ֵ���������ֵ��0F4240H / ���Ƶ��  
   MOV DX,MY8254_COUNT2
   OUT DX,AL            ;װ�������ֵ
   MOV AL,AH
   OUT DX,AL
 RETURNM:
   POP DX
   POP BX
   POP AX
   RET
MUSIC ENDP

DEGREEUP PROC           ;�ж���Ϸ�Ѷ��Ƿ���Ҫ����
   PUSH AX
   PUSH BX

   MOV AL,LNEEDSCOR    
   CMP AL,0
   JLE DEGREEUP1
   MOV BL,RNEEDSCOR
   CMP BL,0
   JG RETURN4

 DEGREEUP1:
   MOV BH,TURNSCOR
   MOV AL,LNEEDSCOR     ;����˫��������һ�׶��������
   ADD AL,BH
   MOV LNEEDSCOR,AL
   MOV BL,RNEEDSCOR
   ADD BL,BH
   MOV RNEEDSCOR,BL

   MOV AL,MODE
   CMP AL,1
   JE  UP1
   MOV AX,LIGHT         ;�ƹ����һյ
   ROR AX,1
   MOV LIGHT,AX
   MOV DX,IOY2
   OUT DX,AL
 UP1:   
   MOV AX,DEGREE        ;��Ϸ�Ѷ�+1
   CMP AX,4
   JE  BACK0
   INC AX
   MOV DEGREE,AX
   JMP RETURN4
 BACK0:
   MOV AX,0
   MOV DEGREE,AX
 RETURN4:
   POP BX
   POP AX
   RET
DEGREEUP ENDP

NEXT_RAND PROC          ;LCG�㷨���������
   PUSH AX
   PUSH BX
   PUSH DX

   MOV AL,NOWRAND256  ;ȡ����ǰ0~255�����
   MOV BL,17          ;��ȡ��һ�������,r(i+1) = mod( 17 *r(i)+ 139, 256)
   MUL BL             ;17 * r(i) ���� AX
   ADD AX,139         ;17 *r(i)+ 139 ���� AX
   MOV DX,0        
   MOV BX,256
   DIV BX             ;(DX:AX)/256��������DX(DL)
   MOV NOWRAND256,DL  ;������һ��0~255�����
   CMP DL,239         ;Ϊ�˾��ȷֲ������ڵ���239�������ٽ���һ�μ���
   JB  TO80
   CALL NEXT_RAND     ;��������˵ݹ麯��
   JMP RETURN1
 TO80:
   MOV AX,DX
   MOV BL,40
   DIV BL              
   MOV NOWRAND40,AH   ;������һ��0~40�����

 RETURN1:
   POP DX
   POP BX
   POP AX
   RET
NEXT_RAND ENDP

DETECTUPL PROC        ;�����Ц���Ϸ��Ƿ������岢�ӷ�
   PUSH BX
   PUSH AX

   MOV BL,Llocation
   DEC BL
   CURS 47,BL
   GETCHAR              ;��ȡЦ�����Ϸ��ַ�
   CMP AL,03H
   JE ADDSCORE
   CMP AL,08H
   JE ADDSCORE3

   INC BL   
   CURS 47,BL
   GETCHAR              ;��ȡЦ�����Ϸ��ַ�
   CMP AL,03H
   JE ADDSCORE
   CMP AL,08H
   JE ADDSCORE3

   INC BL
   CURS 47,BL
   GETCHAR              ;��ȡЦ�����Ϸ��ַ�
   CMP AL,03H
   JE ADDSCORE
   CMP AL,08H
   JE ADDSCORE3
   JMP RETURN3
 ADDSCORE:              ;��1��
   MOV AL,LSCORE
   INC AL
   MOV LSCORE,AL
   MOV AL,LNEEDSCOR
   DEC AL
   MOV LNEEDSCOR,AL
   MOV AX,6
   MOV FREQIDX,AX
   MOV AL,0
   MOV FREQTYPE,AL
   JMP RETURN3
 ADDSCORE3:             ;��3��
   MOV AL,LSCORE
   ADD AL,3
   MOV LSCORE,AL
   MOV AL,LNEEDSCOR
   SUB AL,3
   MOV LNEEDSCOR,AL
   MOV AX,6
   MOV FREQIDX,AX
   MOV AL,1
   MOV FREQTYPE,AL
 RETURN3:   
   POP AX
   POP BX
   RET
DETECTUPL ENDP

DETECTUPR PROC          ;����ҷ�Ц���Ϸ��Ƿ������岢�ӷ�
   PUSH BX              ;������DETECTUPL����
   PUSH AX

   MOV BL,Rlocation     
   DEC BL
   CURS 47,BL
   GETCHAR             
   CMP AL,03H
   JE ADDSCORER
   CMP AL,08H
   JE ADDSCORE3R

   INC BL   
   CURS 47,BL
   GETCHAR          
   CMP AL,03H
   JE ADDSCORER
   CMP AL,08H
   JE ADDSCORE3R

   INC BL
   CURS 47,BL
   GETCHAR          
   CMP AL,03H
   JE ADDSCORER
   CMP AL,08H
   JE ADDSCORE3R
   JMP RETURN3R
 ADDSCORER:
   MOV AL,RSCORE
   INC AL
   MOV RSCORE,AL
   MOV AL,RNEEDSCOR
   DEC AL
   MOV RNEEDSCOR,AL
   MOV AX,6
   MOV FREQIDX,AX
   MOV AL,0
   MOV FREQTYPE,AL
   JMP RETURN3R
 ADDSCORE3R:
   MOV AL,RSCORE
   ADD AL,3
   MOV RSCORE,AL
   MOV AL,RNEEDSCOR
   SUB AL,3
   MOV RNEEDSCOR,AL
   MOV AX,6
   MOV FREQIDX,AX
   MOV AL,1
   MOV FREQTYPE,AL
 RETURN3R:   
   POP AX
   POP BX
   RET
DETECTUPR ENDP

DRAW_LHAT PROC          ;����Ц������Ԥ�Ƚ�λ������BL
   DEC BL
   CURS 49,BL
   COLCHAR 0DH,03H
   CURS 48,BL
   COLCHAR 0EH,4FH
   INC BL
   CURS 49,BL
   COLCHAR 0BH,56H
   INC BL
   CURS 49,BL
   COLCHAR 0DH,03H
   CURS 48,BL
   COLCHAR 0EH,4FH
   DEC BL
   CURS 48,BL
   RET
DRAW_LHAT ENDP

DRAW_RHAT PROC          ;���ҷ�Ц������Ԥ�Ƚ�λ������BL
   DEC BL
   CURS 49,BL
   COLCHAR 5FH,03H
   CURS 48,BL
   COLCHAR 5EH,4FH
   INC BL
   CURS 49,BL
   COLCHAR 5BH,56H
   INC BL
   CURS 49,BL
   COLCHAR 5FH,03H
   CURS 48,BL
   COLCHAR 5EH,4FH
   DEC BL
   CURS 48,BL
   RET
DRAW_RHAT ENDP

SHOWLSCORE PROC     ;�ڵ�ǰ���λ����ʾ�󷽷�������������AL��,��ʾλ�ô���BH
   PUSH DX
   PUSH CX
   PUSH BX
   PUSH AX

   MOV AH,0
   MOV BL,100
   DIV BL              ;����/100���̴���AL����������AH 
   MOV BH,AL           ;BH���λ
   MOV AL,AH           
   MOV AH,0
   MOV BL,10           
   DIV BL              ;������λ��/10���̴���AL(ʮλ)����������AH(��λ)
   MOV CL,AL
   MOV CH,AH

   MOV AH,02H
   CMP BH,0
   JA  HUNDREDS
   CMP CL,0
   JA  TENS
   JMP SINGLES
 HUNDREDS:
   MOV DL,BH
   ADD DL,30H
   INT 21H
 TENS:
   MOV DL,CL
   ADD DL,30H
   INT 21H
 SINGLES:
   MOV DL,CH
   ADD DL,30H
   INT 21H
    
   LEA SI,SCORE_TABLE
   MOV [SI],BH          ;���1������λ
   ADD SI,1
   MOV [SI],CL          ;���1����ʮλ
   ADD SI,1
   MOV [SI],CH          ;���1������λ

   POP AX
   POP BX
   POP CX
   POP DX
   RET
SHOWLSCORE ENDP
                        
SHOWRSCORE PROC     ;�ڵ�ǰ���λ����ʾ�ҷ���������������AL��,��ʾλ�ô���BH
   PUSH DX
   PUSH CX
   PUSH BX
   PUSH AX

   MOV AH,0
   MOV BL,100
   DIV BL              ;����/100���̴���AL����������AH 
   MOV BH,AL           ;BH���λ
   MOV AL,AH           
   MOV AH,0
   MOV BL,10           
   DIV BL              ;������λ��/10���̴���AL(ʮλ)����������AH(��λ)
   MOV CL,AL
   MOV CH,AH

   MOV AH,02H
   CMP BH,0
   JA  HUNDREDSR
   CMP CL,0
   JA  TENSR
   JMP SINGLESR
 HUNDREDSR:
   MOV DL,BH
   ADD DL,30H
   INT 21H
 TENSR:
   MOV DL,CL
   ADD DL,30H
   INT 21H
 SINGLESR:
   MOV DL,CH
   ADD DL,30H
   INT 21H

   LEA SI,SCORE_TABLE
   ADD SI,3
   MOV [SI],BH         ;���2������λ
   ADD SI,1
   MOV [SI],CL         ;���2����ʮλ
   ADD SI,1
   MOV [SI],CH         ;���2������λ

   POP AX
   POP BX
   POP CX
   POP DX
   RET
SHOWRSCORE ENDP

DIS PROC NEAR          ;�������ʾ�����ӳ���
   PUSH AX 
   PUSH BX
   PUSH CX
   PUSH SI
   PUSH DX 
   MOV  SI,OFFSET SCORE_TABLE 
   
   MOV  DX,MY8255_A            ;��������в��ֶ�Ϩ�����������Ϩ��   
   MOV  AL,0FFH
   OUT  DX,AL  
   
   MOV  AL,[SI]              ;ȡ��������0�д�ż�ֵ 
   MOV  BX,OFFSET DTABLE                 
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;����ֵ��Ϊƫ�ƺͼ�ֵ����ַ��ӵõ���Ӧ�ļ�ֵ 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;д�������A��Dp          
   MOV  DL,0FEH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;ѡͨһ������� 
   MOV  DX,MY8255_A          ;��������в��ֶ�Ϩ�����������Ϩ��   
   MOV  AL,0FFH
   OUT  DX,AL
   
   MOV  AL,[SI+1]            ;ȡ��������1�д�ż�ֵ                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;����ֵ��Ϊƫ�ƺͼ�ֵ����ַ��ӵõ���Ӧ�ļ�ֵ 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;д�������A��Dp        
   MOV  DL,0FDH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;ѡͨһ������� 
   MOV  DX,MY8255_A          ;��������в��ֶ�Ϩ�����������Ϩ��   
   MOV  AL,0FFH
   OUT  DX,AL

   MOV  AL,[SI+2]            ;ȡ��������2�д�ż�ֵ                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;����ֵ��Ϊƫ�ƺͼ�ֵ����ַ��ӵõ���Ӧ�ļ�ֵ 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;д�������A��Dp       
   MOV  DL,0FBH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;ѡͨһ������� 
   MOV  DX,MY8255_A          ;��������в��ֶ�Ϩ�����������Ϩ��   
   MOV  AL,0FFH
   OUT  DX,AL

   MOV  AL,[SI+3]            ;ȡ��������3�д�ż�ֵ                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;����ֵ��Ϊƫ�ƺͼ�ֵ����ַ��ӵõ���Ӧ�ļ�ֵ 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;д�������A��Dp       
   MOV  DL,0F7H
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;ѡͨһ������� 
   MOV  DX,MY8255_A          ;��������в��ֶ�Ϩ�����������Ϩ��   
   MOV  AL,0FFH
   OUT  DX,AL
   
   MOV  AL,[SI+4]            ;ȡ��������4�д�ż�ֵ                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;����ֵ��Ϊƫ�ƺͼ�ֵ����ַ��ӵõ���Ӧ�ļ�ֵ 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;д�������A��Dp             
   MOV  DL,0EFH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;ѡͨһ������� 
   MOV  DX,MY8255_A          ;��������в��ֶ�Ϩ�����������Ϩ��   
   MOV  AL,0FFH
   OUT  DX,AL

   MOV  AL,[SI+5]            ;ȡ��������5�д�ż�ֵ                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;����ֵ��Ϊƫ�ƺͼ�ֵ����ַ��ӵõ���Ӧ�ļ�ֵ 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;д�������A��Dp           
   MOV  DL,0DFH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;ѡͨһ������� 
   MOV  DX,MY8255_A          ;��������в��ֶ�Ϩ�����������Ϩ��   
   MOV  AL,0FFH
   OUT  DX,AL
    
 OUT1: 
   POP  DX
   POP  SI
   POP  CX
   POP  BX
   POP  AX
   RET                    
DIS ENDP

COUNTDOWN PROC          ;˫�˶�ս����ʱ��ʼ
   PUSH CX
   PUSH DX
   PUSH AX

   CURS 0,39            ;����ʱ3
   COLCHAR 04EH,33H
   CALL SECOND
   
   CURS 0,39
   COLCHAR 04EH,32H     ;����ʱ2
   CALL SECOND

   CURS 0,39
   COLCHAR 04EH,31H     ;����ʱ1
   CALL SECOND

   CURS 0,37
   DISPMSG MSG9

   POP AX
   POP DX
   POP CX
   RET
COUNTDOWN ENDP 

WINLIGHT PROC           ;˫��ģʽ��Ϸʤ����ˮ����˸���ȴ��ո���
   PUSH AX
   PUSH DX
   
   CURS 24,28
   DISPMSG MSG8
 WAIT2:
   MOV AL,0FFH
   MOV DX,IOY2
   OUT DX,AL
   CALL DALLY1
   
   MOV AL,00H
   MOV DX,IOY2
   OUT DX,AL
   CALL DALLY1
   
   MOV AH,1           
   INT 16H
   CMP AL,' '
   
   JNE WAIT2
   
   POP DX
   POP AX
   RET
WINLIGHT ENDP

WAITKEY PROC            ;�ȴ�����
   PUSH AX
 INWAIT:
   MOV AH,1            
   INT 16H
   JZ  INWAIT
   MOV AH,0CH          ;��ջ�����
   MOV AL,0
   INT 21H

   POP AX
   RET
WAITKEY ENDP

DALLY PROC NEAR         ;��Ϸ���ڲ�ѭ����ʱ
   PUSH CX
   MOV  CX,002FH
 D1:    
   MOV  AX,00FFH
   CALL DIS             ;��ʾ�����
 D2:    
   DEC  AX
   JNZ  D2
   LOOP D1
   POP  CX
   RET
DALLY ENDP

DALLY2 PROC NEAR        ;ֱ�������ʱ
   PUSH CX
   PUSH AX
   MOV  CX,05FFH
 D9:   
   MOV  AX,0FFFFH
 D10:    
   DEC  AX
   JNZ  D10
   LOOP D9
   POP  AX
   POP  CX
   RET
DALLY2 ENDP

SECOND PROC NEAR        ;����ʱ��ʱһ��
   PUSH CX
   MOV  CX,05FFFH
 D3:   
   MOV  AX,0FFFFH
 D4:   
   DEC  AX
   JNZ  D4
   LOOP D3
   POP  CX
   RET
SECOND ENDP

DALLY1 PROC             ;��ˮ����ʱ
 D5:   
   MOV CX,200H
 D6:   
   MOV AX,00FFFH
 D7:   
   DEC AX
   JNZ D7
   LOOP D6
   DEC DL
   JNZ D5
   RET
DALLY1 ENDP 

DALLY3 PROC             ;��ʼ����BGM��ʱ
 D00:   
   MOV CX,05F0H
   SHR CX,1
 D01:   
   MOV AX,0FFFFH
 D02:   
   DEC AX
   JNZ D02
   LOOP D01
   DEC DL
   JNZ D00
   RET
DALLY3 ENDP

SHOWSPEED PROC          ;��ʾֱ������ٶ�
   PUSH DX
   PUSH CX
   PUSH BX
   
   MOV  DX,0                   
   MOV  BX,10           ;����AX/10
   DIV  BX
   MOV  BL,DL
   MOV  DL,AL                     
   
   ADD  DL,30H          ;��+30H����Ϊʮλ��ASCII��
   MOV  AH,2
   INT  21H
   
   MOV  DL,BL
   ADD  DL,30H          ;��+30H����Ϊ��λ��ASCII��
   MOV  AH,2
   INT  21H

   POP BX
   POP CX
   POP DX
   RET
SHOWSPEED ENDP

KJ PROC                 ;PWM�ӳ���
   PUSH AX
   PUSH DX
   CMP  FPWM,01H        ;PWMΪ1������PWM�ĸߵ�ƽ
   JNZ  TEST2
   CMP  VAA,00H
   JNZ  ANOT0
   
   MOV  FPWM,02H
   MOV  AL,BBB
   CLC
   RCR  AL,01H
   MOV  VBB,AL
   JMP  TEST2
 ANOT0: 
   DEC  VAA
   MOV  AL, 10H         ;PB0=1 ���ת��
   MOV  DX, MY8255_C
   OUT  DX,AL

 TEST2: 
   CMP  FPWM,02H        ;PWMΪ2������PWM�ĵ͵�ƽ
   JNZ  OUTT
   CMP  VBB,00H
   JNZ  BNOT0
   
   MOV  FPWM,01H
   MOV  AL,AAAA
   CLC
   RCR  AL,01H
   MOV  VAA,AL
   JMP  OUTT

 BNOT0: 
   DEC  VBB
   MOV  AL,00H          ;PB0=0 ���ֹͣ
   MOV  DX,MY8255_C
   OUT  DX,AL 

 OUTT:
   POP  DX  
   POP  AX
   RET
KJ ENDP

PID:
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX 
   MOV  AX,SPEC                ;PID�ӳ���
   SUB  AX,YK                  ;��ƫ��EK
   MOV  R0,AX
   MOV  R1,AX 
   SUB  AX,EK_1
   MOV  R2,AX
   SUB  AX,AEK_1               ;��BEK
   MOV  BEK,AX
   MOV  R8,AX
   MOV  AX,R1                  ;��ƫ��仯��AEK
   MOV  EK_1,AX
   MOV  AX,R2
   MOV  AEK_1,AX
   TEST R1,8000H
   JZ   EK1                    ;��ƫ��EKΪ����������Ҫ����
   NEG  R1                     ;��ƫ��EKΪ����������ƫ��EK�Ĳ���
 EK1:   
   MOV  AX,R1       ;�ж�ƫ��EK�Ƿ��ڻ��ַ���ֵ�ķ�Χ��ʵ���ٶ�С��Ŀ���ٶ�
   SUB  AX,IBAND
   JC   II                     ;�ڻ��ַ���ֵ��Χ�ڣ�����ת��II�����������
   MOV  R3,00H                 ;�����ڻ��ַ���ֵ��Χ�ڣ��򽫻�������0
   JMP  DDD                    ;����΢����
 II:    
   MOV  AL,TS                  ;���������������R3������(R3=EK*TS/KII)
   MOV  AH,00H                 ;����TS��KII��Ϊ����������R3��������EK����
   MOV  CX,R1
   MUL  CX
   MOV  CX,KII
   DIV  CX
   MOV  R3,AX
   TEST R0,8000H               ;�жϻ����������
   JZ   DDD                    ;Ϊ����������תȥ����΢����
   NEG  R3                     ;Ϊ�������򽫻�����Ľ������
 DDD:   
   TEST BEK,8000H              ;�ж�BEK������
   JZ   DDD1                   ;Ϊ��������BEK����
   NEG  BEK                    ;Ϊ����������BEK�Ĳ���
 DDD1:  
   MOV  AX,BEK                 ;����΢����(R4=KDD*BEK/8TS)
   MOV  CX,KDD
   MUL  CX
   PUSH AX
   PUSH DX
   MOV  AL,TS
   MOV  AH,00H                 ;��΢������С8������ֹ���
   MOV  CX,0008H
   MUL  CX
   MOV  CX,AX
   POP  DX
   POP  AX
   DIV  CX
   MOV  R4,AX
   TEST R8,8000H               ;�ж�΢���������
   JZ   DD1                    ;Ϊ��������������Ҫ����
   NEG  R4                     ;Ϊ��������΢������R4����
 DD1:   
   MOV  AX,R3                  ;�������΢������ӣ��������R5������
   ADD  AX,R4
   MOV  R5,AX
   JO   L9                     ;�ж����
 L2:    
   MOV  AX,R5
   ADD  AX,R2
   MOV  R6,AX                  ;R6=R5+R2=������+΢����+AEK
   JO   L3 
 L5:    
   MOV  AX,R6                  ;����KPP*R6
   MOV  CX,KPP
   IMUL CX
   MOV  CX,1000H
   IDIV CX
   MOV  CX,AX
   RCL  AH,01H                 ;�ж�������������ֵ 
   PUSHF                   
   RCR  AL,01H
   POPF
   JC   LLL1
   CMP  CH,00H
   JZ   LLL2
   MOV  AL,7FH
   JMP  LLL2
 LLL1:  
   CMP  CH,0FFH
   JZ   LLL2
   MOV  AL,80H
 LLL2:  
   MOV  R7,AL                  ;CK=CK_1+CK
   ADD  AL,CK_1             
   JO   L8
 L18:   
   MOV  CK_1,AL
   ADD  AL,80H
   MOV  CK,AL
   POP  DX
   POP  CX
   POP  BX
   POP  AX
   RET        
 L8:    
   TEST R7,80H                 ;CK����������
   JNZ  L17
   MOV  AL,7FH                 ;��Ϊ��������򸳸�����ֵ7FH
   JMP  L18
 L17:   
   MOV  AL,80H                 ;��Ϊ��������򸳸�����ֵ80H
   JMP  L18                
 L9:    
   TEST R3,8000H
   JNZ  L1
   MOV  R5,7FFFH               ;��Ϊ��������򸳸�����ֵ7FFFH
   JMP  L2
 L1:    
   MOV  R5,8000H               ;��Ϊ��������򸳸�����ֵ8000H
   JMP  L2                  
 L3:    
   TEST R2,8000H
   JNZ  L4
   MOV  R6,7FFFH
   JMP  L5
 L4:    
   MOV  R6,8000H
   JMP  L5

SEND PROC               ;��ɱ��������ר��ͼ�ν�����ʾ
   PUSH BX                     
   MOV BX,0D800H
   MOV ES,BX             
   MOV ES:[DI],AX 
   POP  BX      
   RET  
SEND ENDP

UPDOWN PROC             ;ͨ�����Լ���U/D���������ת��
   PUSH BX                                                                                   
   PUSH CX
   PUSH DX
    
   CMP AL,'u'                                                                      
   JE  UPSPEED
   CMP AL,'d'
   JE  DOWNSPEED
   JMP RETURN6
 UPSPEED:
   MOV BX,SPEC
   ADD BX,1
   MOV SPEC,BX
   MOV AX,BX
   CURS 29,18
   CALL SHOWSPEED
   JMP RETURN6
 DOWNSPEED:
   MOV BX,SPEC
   SUB BX,1
   MOV SPEC,BX
   MOV AX,BX
   CURS 29,18
   CALL SHOWSPEED    
    
 RETURN6:    
   POP DX
   POP CX
   POP BX
   RET
UPDOWN ENDP

UPDOWN2 PROC            ;ͨ��ʵ�������U/D���������ת��
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
   MOV  CH,0FEH         ;���ó�ʼɨ����Ϊ��һ��
   MOV  CL,00H          ;���õ�ǰ�����ǵڼ���,0��ʾ��һ��
 COLUM2: 
   MOV  AL,CH           ;ѡȡһ�У���X1��X4��һ����0            
   MOV  DX,MY8255_A 
   OUT  DX,AL
   MOV  DX,MY8255_C     ;��Y1��Y4�������ж�����һ�а����պ� 
   IN   AL,DX

   CMP  AL,07H          ;�Ƿ�Ϊ��4��
   JNE  CCNEXT2         ;����������ж�
   CMP  CL,00H
   JE   CCDOWN
   CMP  CL,01H
   JE  CCUP
   JMP  CCNEXT2         ;������������
 CCDOWN:
   MOV BX,SPEC
   SUB BX,1
   MOV SPEC,BX
   MOV AX,BX
   CURS 29,18
   CALL SHOWSPEED
   JMP CCNEXT2
 CCUP:
   MOV BX,SPEC
   ADD BX,1
   MOV SPEC,BX
   MOV AX,BX
   CURS 29,18
   CALL SHOWSPEED
   JMP CCNEXT2
 CCNEXT2:  
   INC  CL              ;��ǰ������������   
   CMP  CL,02H          ;����Ƿ�ɨ�赽��4��
   JE   RETURN7         ;�������ص���ʼ��
   ROL  CH,1            ;û��⵽��4����׼�������һ��
   JMP  COLUM2
 RETURN7:   
   POP  DX
   POP  CX
   POP  BX
   POP  AX
   RET
UPDOWN2 ENDP

ZHILIU PROC             ;ֱ�����
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
    
   MOV  AX,DATA
   MOV  DS,AX
   
   CLI
   MOV  AX,0000H
   MOV  ES,AX
   
   MOV  DI,0020H                  
   MOV  AX,ES:[DI]               
   MOV  IP_BAK1,AX           ;���涨ʱ��0�жϴ���������ƫ�Ƶ�ַ
   MOV  AX,OFFSET TIMERISR      
   MOV  ES:[DI],AX           ;����ʵ�鶨ʱ�жϴ���������ƫ�Ƶ�ַ
   ADD  DI,2
   MOV  AX,ES:[DI]             
   MOV  CS_BAK1,AX           ;���涨ʱ��0�жϴ��������ڶε�ַ
   MOV  AX,SEG TIMERISR
   MOV  ES:[DI],AX           ;����ʵ�鶨ʱ�жϴ��������ڶε�ַ
   
   IN   AL,21H
   MOV  IM_BAK1,AL           ;����INTRԭ�ж�������
   AND  AL,0F7H
   OUT  21H,AL               ;�򿪶�ʱ��0�ж�����λ
   
   MOV  DI,INTR_IVADD          
   MOV  AX,ES:[DI]
   MOV  IP_BAK,AX            ;����INTRԭ�жϴ���������ƫ�Ƶ�ַ
   MOV  AX,OFFSET MYISR
   MOV  ES:[DI],AX           ;���õ�ǰ�жϴ���������ƫ�Ƶ�ַ
   ADD  DI,2
   MOV  AX,ES:[DI]
   MOV  CS_BAK,AX            ;����INTRԭ�жϴ��������ڶε�ַ
   MOV  AX,SEG MYISR
   MOV  ES:[DI],AX           ;���õ�ǰ�жϴ��������ڶε�ַ
   
   IN   AL,21H
   MOV  IM_BAK,AL            ;����INTRԭ�ж�������
   AND  AL,7FH
   OUT  21H,AL               ;��INTR���ж�����λ
                                 
   MOV  AL,81H               ;��ʼ��8255
   MOV  DX,MY8255_MODE       ;������ʽ0��A�ڣ�B�ڣ�C�ھ����
   OUT  DX,AL
   MOV  AL,00H
   MOV  DX,MY8255_C          ;C�ڸ�4λ���0�������ת
   OUT  DX,AL
   
   MOV  DX,PC8254_MODE       ;��ʼ��PC����ʱ��0����ʱ1ms
   MOV  AL,36H               ;������0����ʽ3
   OUT  DX,AL
   MOV  DX,PC8254_COUNT0
   MOV  AL,8FH               ;��8λ
   OUT  DX,AL
   MOV  AL,04H
   OUT  DX,AL                ;��8λ,048FH=1168
    
    STI
    
 WAIT0:
   MOV  AL,TS           ;�жϲ������ڵ���   TS=20 TC=0
   SUB  AL,TC
   JNC  WAIT0           ;û������������ִ��  TC>TSʱ����һ��
   
   MOV  TC,00H          ;�������ڵ������������ڱ�����0
   MOV  AL,ZVV
   MOV  AH,00H
   MOV  YK,AX           ;�õ�������YK 
   CALL PID             ;����PID�ӳ��򣬵õ�������CK
   MOV  AL,CK           ;�ѿ�����ת����PWM���
   SUB  AL,80H         
   JC   IS0             ;AL<80HתISO
   MOV  AAAA,AL
   JMP  COU
 IS0:   
   MOV  AL,10H          ;���������ֵ���ܵ���10H
   MOV  AAAA,AL   
 COU:   
   MOV  AL,7FH
   SUB  AL,AAAA
   MOV  BBB,AL
   
   CURS 31,18
   MOV  AX,YK           ;������ֵYK�͵���Ļ��ʾ
   CALL SHOWSPEED
   
   MOV  AX,SPEC         ;������ֵ�����ר�ý�����ʾ
   MOV  DI,0D80H
   CALL SEND
   
   MOV  AX,YK           ;������ֵYK�����ר�ý�����ʾ
   MOV  DI,0D81H
   CALL SEND 
      
   MOV  AL,CK           ;��������CK�����ר�ý�����ʾ
   MOV  DI,0D82H
   CALL SEND

   CALL DALLY2 
   CALL CCSCAN          ;ɨ��ʵ������̣��Ƿ��м�����
   JZ  NEXT3
   CALL UPDOWN2
 NEXT3:    
   MOV  AH,1
   INT  16H
   JZ   WAIT0 
      
   PUSH AX
   MOV  AH,0CH         ;��ջ�����
   MOV  AL,0
   INT  21H
   POP  AX
   
   CMP  AL,20H         ;���¿ո��˳�
   JZ   EXIT
   CALL UPDOWN
   JMP  WAIT0   
    
 EXIT:  
   CLI
   MOV  AL,00H                 ;�˳�ʱֹͣ�����ת
   MOV  DX,MY8255_C
   OUT  DX,AL
   
   MOV  DX,PC8254_MODE         ;�ָ�PC����ʱ��0״̬
   MOV  AL,36H
   OUT  DX,AL
   MOV  DX,PC8254_COUNT0       ;������0����ʽ3�������ֵ��Ϊ0
   MOV  AL,00H
   OUT  DX,AL
   MOV  AL,00H
   OUT  DX,AL 
   
   MOV  AX,0000H               ;�ָ�INTRԭ�ж�ʸ��
   MOV  ES,AX
   MOV  DI,INTR_IVADD  
   MOV  AX,IP_BAK              ;�ָ�INTRԭ�жϴ���������ƫ�Ƶ�ַ
   MOV  ES:[DI],AX
   ADD  DI,2
   MOV  AX,CS_BAK              ;�ָ�INTRԭ�жϴ��������ڶε�ַ
   MOV  ES:[DI],AX
            
   MOV  AL,IM_BAK              ;�ָ�INTRԭ�ж����μĴ�����������
   OUT  21H,AL
      
   MOV  DI,0020H                
   MOV  AX,IP_BAK1             ;�ָ���ʱ��0�жϴ���������ƫ�Ƶ�ַ     
   MOV  ES:[DI],AX             
   ADD  DI,2
   MOV  AX,CS_BAK1             ;�ָ���ʱ��0�жϴ��������ڶε�ַ
   MOV  ES:[DI],AX
   
   MOV  AL,IM_BAK1
   OUT  21H,AL                 ;�ָ�������
            
   STI
    
   POP DX
   POP CX
   POP BX
   POP AX
   RET    
ZHILIU ENDP

;#################################################################

;########################## �жϴ������ ################################
MYISR PROC              ;ϵͳ����INTR�жϴ�����򣬵��ÿתһȦ����һ������
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
   MOV  AX,DATA
   MOV  DS,AX
     
   MOV  AL,MARK  
   CMP  AL,01H          ;��MARK=AL=01Hʱ������IN1����ת��
   JZ   IN1
   
   MOV  MARK,01H        ;������MARK=01H���յ�һ�������źţ�MARK0��1������һ�����壬����ת�١�
   JMP  IN2

 IN1:
   MOV  MARK,00H        ;����ת��
 VV:    
   MOV  DX,0000H
   MOV  AX,03E8H
   MOV  CX,VADD
   CMP  CX,0000H        ;�ж�VADD�Ƿ����0
   JZ   MM1     
   DIV  CX              ;DXAX/VADD��1000/VADD=AX...DX
 MM:    
   MOV  ZV,AL
    MOV  VADD,0000H     
 MM1:   
   MOV  AL,ZV
    MOV  ZVV,AL

 IN2:   
   MOV  AL,20H          ;��PC���ڲ�8259�����жϽ�������
   OUT  20H,AL
   POP  DX
   POP  CX
   POP  BX
   POP  AX
   IRET
MYISR ENDP

TIMERISR PROC           ;PC����ʱ��0�жϴ������
   PUSH AX
   PUSH BX                     
   PUSH CX
   PUSH DX
   MOV  AX,DATA
   MOV  DS,AX
   
   INC  TC              ;�������ڱ�����1
   CALL KJ
   CLC
         
 NEXT2:  
   CLC                  ;�����־λ�Ĵ���
   CMP  MARK,01H
   JC   TT1
   
   INC  VADD
   CMP  VADD,0700H      ;ת��ֵ���������ֵ
   JC   TT1
   
   MOV  VADD,0700H
   MOV  MARK,00H
 TT1:   
   MOV  AL,20H          ;�жϽ�������EOI����
   OUT  20H,AL
   POP  DX
   POP  CX
   POP  BX
   POP  AX
   IRET
TIMERISR ENDP

CODE    ENDS
    END     START   

