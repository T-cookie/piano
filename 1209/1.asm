;ħ������Դ����
;������ħ��ʦ


;/////////�����////////////
;4����ͼ�����
;�ֱ��ַ���ASCII�루���Ӧ����ƫ�Ƶ�ַ������ɫ�롢��ʼx���꣨���Ӧ����ƫ�Ƶ�ַ����y���꣨���Ӧ����ƫ�Ƶ�ַ����ÿ�г��ȣ����Ӧ����ƫ�Ƶ�ַ��ѹ��ջ�У�����SHOWS�ӳ���
;��Ҫ�õĺ����ΪDRAW1
DRAW1 MACRO char,color,pos_x,pos_y,len  ;pos_x��pos_y��lenΪƫ�Ƶ�ַ����Ҫ������ĸ�Ƚϸ���ͼ�εĻ�ͼ
	MOV AX,char
	PUSH AX
	MOV AX,color
	PUSH AX
	MOV AX,[pos_x] 
	PUSH AX
	MOV AX,[pos_y]
	PUSH AX
	MOV AX,[len]
	PUSH AX 
	CALL SHOWS
ENDM
		
DRAW2 MACRO char,color,pos_x,pos_y,len ;pos_yΪƫ�Ƶ�ַ����Ҫ������ʼx���ꡢ����ȷ���ı��������̺ڼ��ȵĻ�ͼ
	MOV AX,char
	PUSH AX
	MOV AX,color
	PUSH AX
	MOV AX,pos_x
	PUSH AX
	MOV AX,[pos_y]
	PUSH AX
	MOV AX,len
	PUSH AX 
	CALL SHOWS		
ENDM

DRAW3 MACRO char,color,pos_x,pos_y,len ;char��pos_x��pos_yΪƫ�Ƶ�ַ����Ҫ���ڽ������ַ��������
	MOV AL,[char]
	MOV AH,0
	PUSH AX
	MOV AX,color
	PUSH AX
	MOV AX,[pos_x]
	PUSH AX
	MOV AX,[pos_y]
	PUSH AX
	MOV AX,len
	PUSH AX 
	CALL SHOWS		
ENDM

DRAW5 MACRO char,color,pos_x,pos_y,len  ;���ڵ���趨ת�١���ʱת�ٵ����
	MOV AX,char
	PUSH AX
	MOV AX,color
	PUSH AX
	MOV AX,pos_x
	PUSH AX
	MOV AX,pos_y
	PUSH AX
	MOV AX,len
	PUSH AX 
	CALL SHOWS
ENDM

;////////��ַ����//////////   
INTR_IVADD     EQU   003CH          ;

IOY0           EQU   0E000H           ;ƬѡIOY0��Ӧ�Ķ˿�ʼ��ַ
MY8255_A       EQU   IOY0+00H*4     ;8255��A�ڵ�ַ
MY8255_B       EQU   IOY0+01H*4     ;8255��B�ڵ�ַ
MY8255_C       EQU   IOY0+02H*4     ;8255��C�ڵ�ַ
MY8255_MODE    EQU   IOY0+03H*4     ;8255�Ŀ��ƼĴ�����ַ

IOY1           EQU   0E040H         ;	ƬѡIOY1��Ӧ�Ķ˿�ʼ��ַ
MY8254_COUNT0  EQU   IOY1+00H*4     ;8254�ļ�����0�˿ڵ�ַ
MY8254_COUNT1  EQU   IOY1+01H*4     ;8254�ļ�����1�˿ڵ�ַ
MY8254_COUNT2  EQU   IOY1+02H*4     ;8254�ļ�����2�˿ڵ�ַ
MY8254_MODE    EQU   IOY1+03H*4     ;8254���ƼĴ����˿ڵ�ַ

PC8254_COUNT0  EQU   40H            ;PC����8254��ʱ��0�˿ڵ�ַ
PC8254_MODE    EQU   43H            ;PC����8254���ƼĴ����˿ڵ�ַ

;/////////////////////////ջ���塢���ݶ���///////////////////////////////
STACKS SEGMENT STACK
      DW 256 DUP(?);����ջ�ռ�
TOS   DW 0;ջ�ռ���
STACKS ENDS

DATA  SEGMENT
FOURKEYS DW 20H,30h,07H,12H,07H,20H,30h,1BH,12H,07H,20H,30h,2FH,12H,07H,20H,30h,43H,12H,07H    ;���ڻ���ģʽһ�������·����ĸ�С����Ĳ���
		 DW 20H,30h,07H,13H,07H,20H,30h,1BH,13H,07H,20H,30h,2FH,13H,07H,20H,30h,43H,13H,07H,00H;����8�������ÿ��С������ֱ����ռ�����У�������SHOWS�Ӻ��������ĸ�С����

MAINMENU DW 0
CHOOSEMENU	DB  '         1.Easy',0Dh,0Ah             ;ģʽһ�е��Ѷ�ѡ��˵�����ʾ�
		 	DB  '         2.Middle',0Dh,0Ah
			DB  '         3.Hard',0Dh,0Ah
		 	DB  '         Please choose:',0Dh,0Ah,'$'

DIFFICULTY  DW  ?  ;���ڴ洢�Ѷȵȼ��ı��������Ʒ��������ٶȵı�����  
SCORE DW 0         ;���ڴ洢�����ı���
KEY_FREQ1  DW  175,196,221,248,262,294,330,350,393,441,495,525,589,661,700,786      ;C���ӽ�4����5��16������Ƶ�ʣ���ͬ	   	     	   
KEY_FREQ2  DW  196,221,248,278,294,330,371,393,441,495,556,589,661,742,786,882      ;D��
KEY_FREQ3  DW  221,248,278,312,330,371,416,441,495,556,624,661,742,833,882,990      ;E��
KEY_FREQ4  DW  234,262,294,330,350,393,441,467,525,589,661,700,786,882,935,1049     ;F��
KEY_FREQ5  DW  262,294,330,371,393,441,495,525,589,661,742,786,882,990,1049,1178    ;G��
KEY_FREQ6  DW  294,330,371,416,441,495,556,589,661,742,833,882,990,1112,1178,1322   ;A��
KEY_FREQ7  DW  330,371,416,467,495,556,624,661,742,833,935,990,1112,1248,1322,1484  ;B��
DTABLE DB   3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH;�����0-9��Ӧ�ļ�ֵ����7������ܶ�Ӧ�Ķ�λֵ

;��ÿһ�ʡ��ǰ��л����ģ��������е�x���ꡢy����ͳ������Ӧ����ӦΪ��ÿһ�ʡ�����ʼx���ꡢy���ꡢ����
;���������У���pos_x��Ϊ��ʼx���꣬��pos_y��Ϊ��ʼy���꣬��len��Ϊÿ�г��ȣ�����һһ��ʶ
main_pos_y DW 0,1,2,3,4,5,6,7,8,9,10,11,12,13;������
keywh_pos_y DW 14,15,16,17,18,19,20,21,22,23,24;��������̰׼�

keybl_pos_x DW 3,9,15,27,33,45,51,63,69,75;��������̺ڼ�
keybl_pos_y DW 14,15,16,17,18,19,20
keybl_len   DW 2,2,2,2,2,2,2
prompt db '--------welcome--------',0dh,0ah;ģʽ2ѡ�������������ʾ��
    db 'press-1-tune c',0dh,0ah
    db 'press-2-tune d',0dh,0ah
    db 'press-3-tune e',0dh,0ah
    db 'press-4-tune f',0dh,0ah
    db 'press-5-tune g',0dh,0ah
    db 'press-6-tune a',0dh,0ah
    db 'press-7-tune b',0dh,0ah,'$'

string DB 'Press-1','rhythm','play'   ;��������ʾ��
            DB	'Press-2','freely','play'
            DB 'Press-3','fun','play'
            DB 'ESC-exit'
            DB 'By','C.X.','S.H.N.','C.M.','S.H.'
            
string_pos_x DW 18,19,20,21,22,23,24,18,19,20,21,22,23,19,20,21,22  ;��ʾ���x����λ��
                  DW 36,37,38,39,40,41,42,36,37,38,39,40,41,37,38,39,40
                  DW 54,55,56,57,58,59,60,55,56,57,55,56,57,58
                  DW 70,71,72,73,74,75,76,77
                  DW 3,4,8,9,10,11,15,16,17,18,19,20,24,25,26,27,31,32,33,34 ;��ʾ���y����λ��
string_pos_y DW 16,16,16,16,16,16,16,18,18,18,18,18,18,19,19,19,19
                  DW 16,16,16,16,16,16,16,18,18,18,18,18,18,19,19,19,19
                  DW 16,16,16,16,16,16,16,18,18,18,19,19,19,19
                  DW 23,23,23,23,23,23,23,23
                  DW 23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23

FREQ_LIST0  DW 589,786,882,882,990,990,990,990,990,990
           DW 990,882,882,882,882,882,17,882,882,786
           ;DW 786,786,786,786,786,786,786,589,589,589
          ; DW 17,589,786,882,882,990,990,990,990,990
      ;     DW 990,1178,1178,990,990,990,990,990,882,786
      ;     DW 882,990,990,990,990,17
       ;    DW 589,786,882,882,990,990,990,990,990,990
        ;   DW 990,882,882,882,882,882,882,882,882,786
         ;  DW 786,786,786,786,786,589,589,589,589,786
         ;  DW 882,882,990,990,990,990,990,990,1178,2
          ; DW 990,990,990,990,990,882,786,882,990,990
          ; DW 990,990,17,882,990,882,786,786,786,786
           ;DW 17,882,990,882,786,786,786,786,786,0
TIME_LIST0  DB 4,6,2,4,4,8,6,2,4,4
          DB 4,4,4,4,4,4,4,4,4,4                                                                                                                                                                   
 ;          DB 4,4,6,2,4,4,4,4,4,4
  ;         DB 4,4,6,2,4,4,4,4,4,4             
   ;        DB 4,4,4,4,6,2,6,2,4,4
    ;       DB 8,6,2,16,16,4
     ;      DB 4,6,2,4,4,4,4,4,4,4                     
      ;     DB 4,4,4,8,4,4,4,4,4,4                                                                                                                                                                   
       ;;    DB 4,4,4,4,4,4,4,8,4,6
          ; DB 2,4,4,4,4,4,4,4,4,4
         ;  DB 4,6,2,6,2,4,4,8,6,2
           ;DB 16,16,8,4,4,4,8,4,16,16
           ;DB 8,4,4,6,2,4,4,16,16
p_pos_x DW 12,12,12,12,18,18,12,12,12,12,12,12,12,12 ;��������ĸP
p_pos_y DW 1,2,3,4,3,4,5,6,7,8,9,10,11,12
p_len   DW 8,8,2,2,2,2,8,8,2,2,2,2,2,2

i_pos_x DW 24,24,27,27,27,27,27,27,27,27,24,24;��������ĸI
i_pos_y dw 1,2,3,4,5,6,7,8,9,10,11,12
i_len   dw 8,8,2,2,2,2,2,2,2,2,8,8

a_pos_x dw 39,38,37,36,41,36,42,36,42,36,36,36,42,36,42,36,42,36,42;��������ĸA
a_pos_y dw 1,2,3,4,4,5,5,6,6,7,8,9,9,10,10,11,11,12,12
a_len   dw 2,4,6,3,3,2,2,2,2,8,8,2,2,2,2,2,2,2,2

n_pos_x dw 48,54,48,54,48,54,48,54,48,54,48,54,48,51,48,52,48,52,48,53,48,53,48,54;��������ĸN
n_pos_y dw 1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12
n_len   dw 2,2,3,2,3,2,4,2,4,2,5,2,2,5,2,4,2,4,2,3,2,3,2,2

o_pos_x dw 60,60,60,66,60,66,60,66,60,66,60,66,60,66,60,66,60,66,60,60;��������ĸO
o_pos_y dw 1,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,12
o_len   dw 8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,8,8
;GAME2����
main2_pos_y DW 0,1,2,3,4,5,6,7,8,9,10,11;��������ɫ����
keywh2_pos_y DW 12,13,14,15,16,17,18,19,20,21,22,23,24;��������̰׼�

keyblc_pos_x dw 4,9,14,24,29,39,44,49,59,64,74;C���ڼ�
keybld_pos_x dw 4,9,19,24,34,39,44,54,59,69,74;D���ڼ�
keyble_pos_x dw 4,14,19,29,34,39,49,54,64,69,74;E���ڼ�
keyblf_pos_x dw 9,14,24,29,34,44,49,59,64,69;F���ڼ�
keyblg_pos_x dw 4,9,19,24,29,39,44,54,59,64,74;G���ڼ�
keybla_pos_x dw 4,14,19,24,34,39,49,54,59,69,74;A���ڼ�
keyblb_pos_x dw 9,14,19,29,34,44,49,54,64,69;B���ڼ�

keybl_pos_y2 dw 12,13,14,15,16,17,18,19;ģʽ2�ڼ�

t_pos_x dw 4,6,6,6,6;ģʽ2������ĸT
t_pos_y dw 1,2,3,4,5
t_len dw 5,1,1,1,1

u_pos_x dw 10,13,10,13,10,13,10,13,10;ģʽ2������ĸU
u_pos_y dw 1,1,2,2,3,3,4,4,5
u_len dw 1,1,1,1,1,1,1,1,4

n2_pos_x dw 15,18,15,18,15,15,17,15,18;ģʽ2������ĸN
n2_pos_y dw 1,1,2,2,3,4,4,5,5
n2_len dw 1,1,2,1,4,1,2,1,1

e1_pos_x dw 20,20,20,20,20;ģʽ2�����һ����ĸE
e2_pos_x dw 27,27,27,27,27;ģʽ2����ڶ�����ĸE
e_pos_y dw 1,2,3,4,5
e_len dw 4,1,4,1,4

point_pos_x dw 25,25;ģʽ2����������
point_pos_y dw 2,4;
point_len dw 1,1;

a2_pos_x dw 28,27,30,27,27,30,27,30;ģʽ2�������A
a2_pos_y dw 1,2,2,3,4,4,5,5;
a2_len dw 2,1,1,4,1,1,1,1;

b_pos_x dw 27,27,29,27,27,30,27;ģʽ2�������B
b_pos_y dw 1,2,2,3,4,4,5;
b_len dw 3,1,1,4,1,1,4;

c_pos_x dw 27,27,27,27,27;ģʽ2�������C
c_pos_y dw 1,2,3,4,5;
c_len dw 4,1,1,1,4;

d_pos_x dw 27,27,30,27,30,27,30,27;ģʽ2�������D
d_pos_y dw 1,2,2,3,3,4,4,5;
d_len dw 3,1,1,1,1,1,1,3;

f_pos_x dw 27,27,27,27,27;ģʽ2�������F
f_pos_y dw 1,2,3,4,5;
f_len dw 4,1,4,1,1;

g_pos_x dw 27,27,27,29,27,30,27;ģʽ2�������G
g_pos_y dw 1,2,3,3,4,4,5;
g_len dw 4,1,1,2,1,1,4;

p2_pos_x dw 40,40,43,40,40,40;ģʽ2������ĸP
p2_pos_y dw 1,2,2,3,4,5;
p2_len dw 4,1,1,4,1,1;

i2_pos_x dw 45,47,47,47,45;ģʽ2������ĸI
i2_pos_y dw 1,2,3,4,5;
i2_len dw 5,1,1,1,5;

a3_pos_x dw 52,51,54,51,51,54,51,54;ģʽ2������ĸA
a3_pos_y dw 1,2,2,3,4,4,5,5;
a3_len dw 2,1,1,4,1,1,1,1;

n3_pos_x dw 56,59,56,59,56,56,58,56,59;ģʽ2������ĸN
n3_pos_y dw 1,1,2,2,3,4,4,5,5;
n3_len dw 1,1,2,1,4,1,2,1,1;

o2_pos_x dw 61,61,64,61,64,61,64,61;ģʽ2������ĸO
o2_pos_y dw 1,2,2,3,3,4,4,5;
o2_len dw 4,1,1,1,1,1,1,4;

symbol_char db '4.5.6.7.1234567.1.2.3.4.5';ģʽ2�������������ʶ�ַ�
symbol_pos_x dw 1,1,6,6,11,11,16,16,21,26,31,36,41,46,51,56,56,61,61,66,66,71,71,76,76;
symbol_pos_y dw 10,11,10,11,10,11,10,11,10,10,10,10,10,10,10,9,10,9,10,9,10,9,10,9,10;

esc_char db 'ESC-exit';ģʽ2�����˳���ʶ�ַ�
esc_pos_x dw 67,68,69,70,71,72,73,74;
esc_pos_y dw 3,3,3,3,3,3,3,3;

pos_y dw 20,21,22,23,24;�ټ���˸����죩����

;���Ƚ�������
main3_pos_y DW 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24;���Ƚ�����ɫ����
fanr_pos_x dw 7,6,7,7,8,8;���Ƚ����ɫ��Ҷ�滭����
fanr_pos_y dw 2,3,4,5,6,7
fanr_len dw 4,6,4,3,2,1

fanwh_pos_x dw 8,8;���Ƚ����ɫ���ĵ�滭����
fanwh_pos_y dw 8,9
fanwh_len dw 2,2

fany_pos_x dw 14,12,10,11,13,15;���Ƚ����ɫ��Ҷ�滭����
fany_pos_y dw 6,7,8,9,10,11
fany_len dw 1,4,6,5,3,1

fanb_pos_x dw 9,8,8,7,6,7;���Ƚ�����ɫ��Ҷ�滭����
fanb_pos_y dw 10,11,12,13,14,15
fanb_len dw 1,2,3,4,6,4

fang_pos_x dw 3,2,2,2,2,3;���Ƚ�����ɫ��Ҷ�滭����
fang_pos_y dw 6,7,8,9,10,11
fang_len dw 1,3,5,6,4,1

f03_pos_x dw 20,20,20,20,20,20;���Ƚ�����ĸF�滭����
f03_pos_y dw 2,3,4,5,6,7
f03_len dw 4,1,4,1,1,1

a03_pos_x dw 27,26,26,29,26,26,29,26,29;���Ƚ�����ĸA��FAN)�滭����
a03_pos_y dw 2,3,4,4,5,6,6,7,7
a03_len dw 2,4,1,1,4,1,1,1,1

n03_pos_x dw 32,35,32,35,32,35,32,34,32,34,32,35;���Ƚ�����ĸN�滭����
n03_pos_y dw 2,2,3,3,4,4,5,5,6,6,7,7
n03_len dw 1,1,2,1,2,1,1,2,1,2,1,1

p03_pos_x dw 20,20,23,20,20,20,20;���Ƚ�����ĸP�滭����
p03_pos_y dw 10,11,11,12,13,14,15
p03_len dw 4,1,1,4,1,1,1

l03_pos_x dw 26,26,26,26,26,26;���Ƚ�����ĸL�滭����
l03_pos_y dw 10,11,12,13,14,15
l03_len dw 1,1,1,1,1,4

a04_pos_x dw 33,32,32,35,32,32,35,32,35;���Ƚ�����ĸA��PLAY)�滭����
a04_pos_y dw 10,11,12,12,13,14,14,15,15

y03_pos_x dw 38,41,38,41,38,39,39,39;���Ƚ�����ĸY�滭����
y03_pos_y dw 10,10,11,11,12,13,14,15
y03_len dw 1,1,1,1,4,2,2,2

frame_pos_x dw 48,48,48,76,48,76,48,76,48,76,48,48;���Ƚ�����ʾ�߿�滭����
frame_pos_y dw 4,5,6,6,7,7,8,8,9,9,10,11
frame_len dw 30,30,2,2,2,2,2,2,2,2,30,30

up_pos_x dw 57,56,55,54,57,57,57,57,57;���Ƚ����ϼ�ͷ�滭����
updown_pos_y dw 14,15,16,17,18,19,20,21,22
up_len dw 1,3,5,7,1,1,1,1,1

down_pos_x dw 72,72,72,72,72,69,70,71,72;���Ƚ����¼�ͷ�滭����
down_len dw 1,1,1,1,1,7,5,3,1

lan1_pos_x dw 60,60,60;���Ƚ�����ָʾ�顢��ָʾ��滭����
lan1_pos_y dw 20,21,22
lan_len dw 3,3,3
lan2_pos_x dw 67,67,67
lan2_pos_y dw 14,15,16

;���������ʶ��滭����
output_pos_x dw 51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72
output_pos_y dw 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
output_str db 'Assumed Fan Speed:</s>'
		db 'Current Fan Speed:</s>'

CS_BAK   DW  ?                    ;����INTRԭ�жϴ���������ڶε�ַ�ı���
IP_BAK   DW  ?                    ;����INTRԭ�жϴ����������ƫ�Ƶ�ַ�ı���
IM_BAK   DB  ?,?                    ;����INTRԭ�ж������ֵı���
CS_BAK1  DW  ?                    ;���涨ʱ��0�жϴ���������ڶε�ַ�ı���
IP_BAK1  DW  ?                    ;���涨ʱ��0�жϴ����������ƫ�Ƶ�ַ�ı���
IM_BAK1  DB  ?,?                    ;���涨ʱ��0�ж������ֵı���
	      
TS       DB 20                    ;��������
SPEC     DW 55                    ;ת�ٸ���ֵ   55
IBAND    DW 0060H                 ;���ַ���ֵ   96
KPP      DW 1060H                 ;����ϵ��     4192
KII      DW 0010H                 ;����ϵ��     16
KDD      DW 0020H                 ;΢��ϵ��     32

YK       DW 0000H                 ;������
CK       DB 00H                   ;������
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
KEYFLAG  DB 00H
     	   
DATA   ENDS
;////////////////////////������///////////////////////////////
CODE SEGMENT
     ASSUME  CS:CODE,DS:DATA,SS:STACKS

START: MOV  AX,DATA
       MOV  DS,AX
       MOV  AX,0B800H;�ı�ģʽ�µ��Դ�Ķε�ַ������ʼ��ַ��
       MOV  ES,AX;��������ͨ��ֱ�����Դ���д�����ݣ����ﵽ��ʾ��Ŀ�ĵ�
       MOV  AX,STACKS
       MOV  SS,AX
       MOV  SP, Offset TOS
       MOV  DX,MY8255_MODE;����8255��ģʽ         
       MOV  AL,81H;��ʽ0��A�ڡ�B�ھ�Ϊ�����C�ڵ���λ���룬��4λ���
       OUT  DX,AL

;������滭
    LEA BX,main_pos_y;��ȡƫ�Ƶ�ַ
    MOV CX,14;ѭ��������������ָҪ�����ٱ�
MAIN1_DRAW:
	DRAW2 20H,03EH,01h,BX,80;���ú궨��2,03EHΪǳ��ɫ
	ADD BX,2;ƫ�Ƶ�ַ��2��ָ����һ������
	LOOP MAIN1_DRAW;ѭ��
	;���³�������������ʽ�������ƣ������ظ�ע��
	LEA BX,p_pos_x
	LEA SI,p_pos_y
	LEA DI,p_len
	MOV CX,14
P_DRAW:;��������P��ĸ��4EΪ��ɫ
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP P_DRAW
	
	LEA BX,i_pos_x
	LEA SI,i_pos_y
	LEA DI,i_len
	MOV CX,12
I_DRAW:;��������I��ĸ��6EΪ��ɫ
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP I_DRAW
	
	LEA BX,a_pos_x
	LEA SI,a_pos_y
	LEA DI,a_len
	MOV CX,19
A_DRAW:;��������A��ĸ��2EΪ��ɫ
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP A_DRAW
	
	LEA BX,n_pos_x
	LEA SI,n_pos_y
	LEA DI,n_len
	MOV CX,24
N_DRAW:;��������N��ĸ��1EΪ��ɫ
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP N_DRAW

	LEA BX,o_pos_x
	LEA SI,o_pos_y
	LEA DI,o_len
	MOV CX,20
O_DRAW:;��������O��ĸ��5EΪ��ɫ
	DRAW1 20H,05EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP O_DRAW
	
	LEA BX,keywh_pos_y
    MOV CX,11
KEYWH_DRAW:;����������̰׼�
	DRAW2 20H,07EH,01h,BX,80
	ADD BX,2
	LOOP KEYWH_DRAW


	;����������̺ڼ�
	LEA BX,keybl_pos_x
	MOV SI,0;���ѭ������
KEYBL_DRAW:
    MOV CX,7;�ڲ�ѭ����������ÿ���ڼ�Ҫ���ı���
    LEA DI,keybl_pos_y
KEYBL_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBL_DRAW1;�ڲ�ѭ��
	ADD SI,2
	CMP SI,20 ;һ����10���ڼ������˾��˳�
	JNE KEYBL_DRAW;���ѭ��
	
	LEA BX,string
	LEA DI,string_pos_x
	LEA SI,string_pos_y
	MOV CX,76
STRING_DRAW:;���������ʶ
	DRAW3 BX,7EH,DI,SI,1
	ADD BX,1
	ADD DI,2
	ADD SI,2
	LOOP STRING_DRAW
   
PLAY1:   
	;��Ϸģʽѡ��
	MOV AH,08H  ;�ȴ���������
	INT 21H
	CMP AL,31H  ;����1ȥģʽ1�������ʦ
	JE GO1
	CMP AL,32H  ;����2ȥģʽ2�����ٵ���
	JE TRAN3
	CMP AL,33H  ;����3ȥģʽ3���������
	JE TRAN2
	CMP AL,20H  ;���¿ո�ȥ�˳���
	JE ENDMAIN
	JMP PLAY1
	
ENDMAIN:;�˳������
	MOV DX,MY8254_MODE          ;����8254������ʽ
    	MOV AL,10H
   	OUT DX,AL
	MOV AX,4C00h		   ;�˳���Ϸ
    	INT 21h
	        
TRAN2: JMP DIANJI;ȥ�������飨ģʽ2��
TRAN3: JMP PLAY2;ȥ�����������飨ģʽ3��
;��Ϸ1�����    
GO1:
	MOV AH,00H ;����
	MOV AL,03H
	INT 10H
	MOV SCORE,00H ;��������
	MOV DX,OFFSET CHOOSEMENU 	
	MOV AH,09H  ;���ѡ���Ѷȵı�ʶ��
	INT 21H
	MOV AH,01H  
	INT 16H
	MOV AH,08H  ;AL���ռ��̰���
	INT 21H

	CMP AL,31H  ;����1��ģʽ
	JE EASY
	CMP AL,32H  ;����2��ͨģʽ
	JE MIDDLE
	CMP AL,33H  ;����3����ģʽ
	JE DIFFICULT
	CMP AL,1BH  ;�����˳��ص�������
	JE TRAN1
	JMP GO1
EASY:	
	MOV DIFFICULTY,255  ;�����Ѷȣ��������ʱ�䣩����ͬ
	JMP PLAY
MIDDLE:	
	MOV DIFFICULTY,15
	JMP PLAY
DIFFICULT:	
	MOV DIFFICULTY,1
	JMP PLAY
PLAY:
	MOV AH,00H					  
	MOV AL,03H
	INT 10H						  ;����
    MOV SI,OFFSET FREQ_LIST0      ;װ��Ƶ�ʱ���ʼ��ַ
    MOV DI,OFFSET TIME_LIST0	  ;װ��ʱ���
loopmove:						  ;ģʽһ��ѭ��
	MOV DX,MY8254_MODE            ;��ʼ��8254������ʽ
	MOV AL,36H                    ;��ʱ��0����ʽ3
	OUT DX,AL
	MOV DX,0FH                    ;����ʱ��Ϊ1.0416667MHz��1.0416667M = 0FE502H  
	MOV AX,0E502H                
	DIV WORD PTR [SI]             ;ȡ��Ƶ��ֵ���������ֵ��0F4240H / ���Ƶ��  
	MOV DX,MY8254_COUNT0
	OUT DX,AL                     ;װ�������ֵ
	MOV AL,AH
	OUT DX,AL					  ;�����������
	CALL DELAY				      ;��ʱ������ÿ�η���ʱ��ĳ���
	MOV DX,MY8254_MODE            ;�˳�ʱ����8254Ϊ��ʽ2��OUT0��0
	MOV AL,10H					  ;������
	OUT DX,AL
	ADD SI,2
	INC DI
	CMP WORD PTR [SI],0           ;�ж��Ƿ���ĩ��
	JE  PLAY
	CALL SCOREDIS                 ;�����������ʾ�������ӳ���
	PUSH SCORE					  ;����������ӳ��򴫲�������ջ���Σ�
	CALL SHOWSSCORE				  ;������Ļ���Ͻ���ʾ�������ӳ���
	CALL MOVE				      ;����ģʽһ�����ӳ��򣨰�������С������С����������Լ������жϡ��ӷֵȣ�
	PUSH CX						  ;����ʵ�������л����������⣬�����ֳ�
	MOV AH,01H
	INT 16H						  
	CMP AL,1BH
	POP CX
	JNE loopmove				  ;�ж�ESC�����Ƿ��£�δ���������ѭ�����������������
	JMP START					  
TRAN1: JMP START

;��Ϸ2�����
PLAY2:
	MOV AH,00H            ;����
	MOV AL,03H
	INT 10H
	MOV AH,09H
	MOV DX,OFFSET prompt  ;�����ʶ��
	INT 21H
    MOV AH,0CH			  ;�������̻�����
	INT 21H
	MOV AH,08H            ;�ȴ�����
	INT 21H

	CMP AL,31H              ;����1ΪC��
	JE C_JUMP
	CMP AL,32H		        ;����2ΪD��
	JE D_JUMP
	CMP AL,33H				;����3ΪE��
	JE E_JUMP
	CMP AL,34H				;����4ΪF��
	JE F_JUMP
	CMP AL,35H				;����5ΪG��
	JE G_JUMP
	CMP AL,36H				;����6ΪA��
	JE A_JUMP
	CMP AL,37H				;����7ΪB��
	JE B_JUMP
	CMP AL,1BH				;�����˳����˳���������
    JE TRAN1 	
	JMP PLAY2
C_JUMP: JMP FAR PTR TUNE_C
D_JUMP: JMP FAR PTR TUNE_D
E_JUMP: JMP FAR PTR TUNE_E
F_JUMP: JMP FAR PTR TUNE_F
G_JUMP: JMP FAR PTR TUNE_G
A_JUMP: JMP FAR PTR TUNE_A
B_JUMP: JMP FAR PTR TUNE_B

TUNE_C:;��C������
	MOV AH,00H
	MOV AL,03H
	INT 10H  
	CALL DRAW_ME2;����������

	LEA BX,c_pos_x
	LEA SI,c_pos_y
	LEA DI,c_len
	MOV CX,5
 C_DRAW:;������C����ɫ
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP C_DRAW

	;������ѭ�����ƣ�������C�ڼ�
	LEA BX,keyblc_pos_x
	MOV SI,0
 KEYBLC_DRAW:
    MOV CX,8
    LEA DI,keybl_pos_y2
 KEYBLC_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBLC_DRAW1
	ADD SI,2
	CMP SI,22
	JNE KEYBLC_DRAW

	LEA BX,KEY_FREQ1;��C����ӦƵ�ʱ�ȡ����׼������
	JMP GO2


TUNE_D:;������D����
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;����������

	LEA BX,d_pos_x
	LEA SI,d_pos_y
	LEA DI,d_len
	MOV CX,8
 D_DRAW:;������D����ɫ
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP D_DRAW

	;������ѭ�����ƣ�������D�ڼ�
	LEA BX,keybld_pos_x
	MOV SI,0
 KEYBLD_DRAW:
    MOV CX,8
    LEA DI,keybl_pos_y2
 KEYBLD_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBLD_DRAW1
	ADD SI,2
	CMP SI,22
	JNE KEYBLD_DRAW

	LEA BX,KEY_FREQ2;��D��Ƶ�ʱ�ȡ��׼������
	JMP GO2

TUNE_E:;������E����
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;����������

	LEA BX,e2_pos_x
	LEA SI,e_pos_y
	LEA DI,e_len
	MOV CX,5
 E1_DRAW:;������E����ɫ
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP E1_DRAW

    ;˫��ѭ��������E�ڼ�
	LEA BX,keyble_pos_x
	MOV SI,0
 KEYBLE_DRAW:
    MOV CX,8
    LEA DI,keybl_pos_y2
 KEYBLE_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBLE_DRAW1
	ADD SI,2
	CMP SI,22
	JNE KEYBLE_DRAW


	LEA BX,KEY_FREQ3;��E��Ƶ�ʱ�ȡ��׼������
	JMP GO2
	
	
	
TUNE_F:;������F����
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;����������

	LEA BX,f_pos_x
	LEA SI,f_pos_y
	LEA DI,f_len
	MOV CX,5
 F_DRAW:;������F����ɫ
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP F_DRAW

	;˫��ѭ�����ƻ�F���ڼ�
	LEA BX,keyblf_pos_x
	MOV SI,0
 KEYBLF_DRAW:
    MOV CX,8
    LEA DI,keybl_pos_y2
 KEYBLF_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBLF_DRAW1
	ADD SI,2
	CMP SI,20
	JNE KEYBLF_DRAW
	
	LEA BX,KEY_FREQ4;ȡ��F��Ƶ�ʱ�׼������
	JMP GO2
	

TUNE_G:;������G����
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;����������

	LEA BX,g_pos_x
	LEA SI,g_pos_y
	LEA DI,g_len
	MOV CX,7
 G_DRAW:;������G����ɫ
	DRAW1 20H,05EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP G_DRAW

	;˫��ѭ�����ƻ�����G�ڼ�
	LEA BX,keyblg_pos_x
	MOV SI,0
 KEYBLG_DRAW:
    MOV CX,8
    LEA DI,keybl_pos_y2
 KEYBLG_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBLG_DRAW1
	ADD SI,2
	CMP SI,22
	JNE KEYBLG_DRAW
	LEA BX,KEY_FREQ5;ȡ������GƵ�ʱ�׼������
	JMP GO2

TUNE_A:;������A����
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;����������

	LEA BX,a2_pos_x
	LEA SI,a2_pos_y
	LEA DI,a2_len
	MOV CX,8
 AA_DRAW:;������A����ɫ
	DRAW1 20H,07EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP AA_DRAW

	;˫��ѭ�����ƻ�����A�ڼ�
	LEA BX,keybla_pos_x
	MOV SI,0
 KEYBLA_DRAW:
    MOV CX,8
    LEA DI,keybl_pos_y2
 KEYBLA_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBLA_DRAW1
	ADD SI,2
	CMP SI,22
	JNE KEYBLA_DRAW
	LEA BX,KEY_FREQ6;ȡ������AƵ�ʱ�׼������
	JMP GO2

TUNE_B:;������B����
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;����������

	LEA BX,b_pos_x
	LEA SI,b_pos_y
	LEA DI,b_len
	MOV CX,7
 B_DRAW:;������B����ɫ
	DRAW1 20H,00EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP B_DRAW

	;˫��ѭ�����ƻ�����B�ڼ�
	LEA BX,keyblb_pos_x
	MOV SI,0
 KEYBLB_DRAW:
    MOV CX,8
    LEA DI,keybl_pos_y2
 KEYBLB_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBLB_DRAW1
	ADD SI,2
	CMP SI,20
	JNE KEYBLB_DRAW

	LEA BX,KEY_FREQ7;ȡ������BƵ�ʱ�׼������
	JMP GO2 
TRANS4:JMP PLAY2	
GO2:   
      MOV AL,00H
      MOV AH,0CH
      INT 21H     ; �������̻�����
      MOV AH,01H
      INT 16H     
      MOV AH,08H
      INT 21H     ;AL���հ���
      CMP AL,1BH
      JE TRANS4   ;��������˳����ص�ѡ������
      PUSH BX     ;����Ӧ����Ƶ�ʱ�ƫ�Ƶ�ַ��ջ
      MOV AH,00H
      PUSH AX     ;�����µİ���ASCII����ջ
      CALL RING   ;���ǰ����˳�������뷢������
      JMP GO2     ;����ѭ�����жϰ������²�����

;��Ϸ3������Ƴ����
DIANJI:
	  MOV DX,MY8254_MODE          ;������8254�������0
	  MOV AL,10H
	  OUT DX,AL
	  
	  MOV AH,00H		    ;������ʾ��ʽ
	  MOV AL,03H
	  INT 10H
        
      	  CALL DRAW_MENU3	    ;���Ƶ����ʼ����
	
	  STI			    ;���ն�����λ
	  CALL ZHILIU		    ;ֱ�������ӳ��� 
  	  CLI
  	  JMP START


;/////////////////////////�ӳ���//////////////////////////  	  
ZHILIU PROC
       PUSH AX			;�����ֳ� 
       PUSH BX
       PUSH CX
       PUSH DX
    
       MOV  AX,DATA
       MOV  DS,AX  
       
       MOV  AX,SPEC                  	;������ֵ�����ר�ý�����ʾ
       MOV  DI,0D80H
       CALL SEND
       
       MOV  AX,SPEC                 
       CALL SHOWSPEED_ASSUMED
 
    
       CLI
       MOV  AX,0000H
       MOV  ES,AX
    
       MOV  DI,0020H                  
       MOV  AX,ES:[DI]               
       MOV  IP_BAK1,AX             ;���涨ʱ��0�жϴ����������ƫ�Ƶ�ַ
       MOV  AX,OFFSET TIMERISR      
       MOV  ES:[DI],AX             ;����ʵ�鶨ʱ�жϴ����������ƫ�Ƶ�ַ
       ADD  DI,2
       MOV  AX,ES:[DI]             
       MOV  CS_BAK1,AX             ;���涨ʱ��0�жϴ���������ڶε�ַ
       MOV  AX,SEG TIMERISR
       MOV  ES:[DI],AX             ;����ʵ�鶨ʱ�жϴ���������ڶε�ַ
    
       IN   AL,21H
       MOV  IM_BAK1,AL             ;����INTRԭ�ж�������
       AND  AL,0F7H
       OUT  21H,AL                 ;�򿪶�ʱ��0�ж�����λ
    
       MOV  DI,INTR_IVADD          
       MOV  AX,ES:[DI]
       MOV  IP_BAK,AX              ;����INTRԭ�жϴ����������ƫ�Ƶ�ַ
       MOV  AX,OFFSET MYISR
       MOV  ES:[DI],AX             ;���õ�ǰ�жϴ����������ƫ�Ƶ�ַ
       ADD  DI,2
       MOV  AX,ES:[DI]
       MOV  CS_BAK,AX              ;����INTRԭ�жϴ���������ڶε�ַ
       MOV  AX,SEG MYISR
       MOV  ES:[DI],AX             ;���õ�ǰ�жϴ���������ڶε�ַ
      
       IN   AL,21H
       MOV  IM_BAK,AL              ;����INTRԭ�ж�������
       AND  AL,7FH
       OUT  21H,AL                  ;��INTR���ж�����λ
                                    
       MOV  AL,81H                 ;��ʼ��8255
       MOV  DX,MY8255_MODE         ;������ʽ0��A�ڣ�B�ڣ�C�ھ����
       OUT  DX,AL
       MOV  AL,00H
       MOV  DX,MY8255_C            ;C�ڸ�4λ���0�������ת
       OUT  DX,AL
    
       MOV  DX,PC8254_MODE         ;��ʼ��PC����ʱ��0����ʱ1ms
       MOV  AL,36H                 ;������0����ʽ3
       OUT  DX,AL
       MOV  DX,PC8254_COUNT0
       MOV  AL,8FH                 ;��8λ
       OUT  DX,AL
       MOV  AL,04H
       OUT  DX,AL                  ;��8λ,048FH=1168
    
       STI					;

SAMPLE:			;����������
       MOV  AL,TS                     ;TS=20 TC=0
	   SUB  AL,TC
	   JNC  SAMPLE              ;û���������������ѭ��
	
	MOV  TC,00H                 ;�������ڵ������������ڱ�����0
	MOV  AL,ZVV
	MOV  AH,00H
	MOV  YK,AX                  ;�õ�������YK 
	CALL PID                       ;����PID�ӳ��򣬵õ�������CK
	MOV  AL,CK                  ;�ѿ�����ת����PWM���
	SUB  AL,80H         
	JC   IS0                           ;AL<80HתISO
	MOV  AAAA,AL
	JMP  COU
IS0:   
	MOV  AL,10H                 ;���������ֵ���ܵ���10H
    	MOV  AAAA,AL   
COU:   
	   MOV  AL,7FH
	   SUB  AL,AAAA
	   MOV  BBB,AL
	
	   MOV  AX,YK                  ;������ֵYK�͵���Ļ��ʾ
	   CALL SHOWSPEED_CURRENT
	
	   MOV  AX,YK                  ;������ֵYK�����ר�ý�����ʾ
       	   MOV  DI,0D81H
       	   CALL SEND 
       
          	   MOV  AL,CK                  ;��������CK�����ר�ý�����ʾ
         	   MOV  DI,0D82H
       	   CALL SEND
                        

   	   CALL DALLY2
	   CALL CCSCAN			;ɨ��ʵ������̣��Ƿ��м�����
                   JZ   RESET			;�ް�����������ȡ����
	   CALL KEYBOARD			;�а������жϰ���AL��ֵ
	   CMP AL,10H			
	   JE  RESET
	   CMP AL,0CH			;ALΪ0CH�������
	   JE  INSPEED
	   CMP AL,0DH			;ALΪ0DH�������
	   JE  DESPEED
	   
RESET:
	   MOV  AH,1			;�жϵ��Լ����Ƿ��а�������
    	   INT  16H
   	   JZ   SAMPLE			;�ް���������������
       
  	   PUSH AX
    	   MOV  AH,0CH      		
    	   INT  21H
   	   POP  AX
    
       	   CMP  AL,1BH          		;����ΪEsc���˳��������
    	   JZ   EXIT
    	   JMP  SAMPLE   
    
INSPEED:
    MOV AX,SPEC
    ADD AX,3			;�������ת��+3
    MOV SPEC,AX

    MOV CX,60
    CALL LIGHT_UP_RED 
    CALL SHOWSPEED_ASSUMED	;�ı���Ļ��ʾֵ
    CALL delay
    CALL delay
    MOV CX,60
    CALL LIGHT_UP_BLACK 

	JMP RESET
DESPEED:
    MOV AX,SPEC			;�������ת��-3
    SUB AX,3
    MOV SPEC,AX

    MOV CX,67
    CALL LIGHT_DOWN_RED
    CALL SHOWSPEED_ASSUMED	;�ı���Ļ��ʾֵ
    CALL delay
    CALL delay
    MOV CX,67
    CALL LIGHT_DOWN_BLACK

    JMP RESET
	 	
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
    MOV  AX,IP_BAK              ;�ָ�INTRԭ�жϴ����������ƫ�Ƶ�ַ
    MOV  ES:[DI],AX
    ADD  DI,2
    MOV  AX,CS_BAK              ;�ָ�INTRԭ�жϴ���������ڶε�ַ
    MOV  ES:[DI],AX
              
    MOV  AL,IM_BAK              ;�ָ�INTRԭ�ж����μĴ�����������
    OUT  21H,AL
        
    MOV  DI,0020H                
    MOV  AX,IP_BAK1             ;�ָ���ʱ��0�жϴ����������ƫ�Ƶ�ַ     
    MOV  ES:[DI],AX             
    ADD  DI,2
    MOV  AX,CS_BAK1             ;�ָ���ʱ��0�жϴ���������ڶε�ַ
    MOV  ES:[DI],AX
    
    MOV  AL,IM_BAK1
    OUT  21H,AL                 ;�ָ�������
            
    STI
    
    POP DX
	POP CX		;�����ֳ�
	POP BX
	POP AX
    RET    
ZHILIU ENDP
       
MYISR PROC                    ;ϵͳ����INTR�жϴ������򣬵��ÿתһȦ����һ������
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	MOV  AX,DATA
	MOV  DS,AX
	  
	MOV  AL,MARK  
	CMP  AL,01H                   ;��MARK=AL=01Hʱ������IN1����ת��
	JZ   IN1
	
	MOV  MARK,01H                 ;������MARK=01H���յ�һ�������źţ�MARK0��1������һ�����壬����ת�١�
	JMP  IN2

IN1:
	MOV  MARK,00H               ;����ת��
VV:    
	MOV  DX,0000H
	MOV  AX,03E8H
	MOV  CX,VADD
	CMP  CX,0000H               ;�ж�VADD�Ƿ����0
	JZ   MM1     
	DIV  CX                     ;DXAX/VADD��1000/VADD=AX...DX
MM:    
	MOV  ZV,AL
    MOV  VADD,0000H     
MM1:   
	MOV  AL,ZV
    MOV  ZVV,AL

IN2:   
	MOV  AL,20H                 ;��PC���ڲ�8259�����жϽ�������
	OUT  20H,AL
	POP  DX
	POP  CX
	POP  BX
	POP  AX
	IRET
MYISR ENDP

TIMERISR PROC                 ;PC����ʱ��0�жϴ�������
	PUSH AX
	PUSH BX                     
	PUSH CX
	PUSH DX
	MOV  AX,DATA
	MOV  DS,AX
	
	INC  TC                     ;�������ڱ�����1
	CALL KJ
	CLC
	      
NEXT2:  
	CLC                         ;�����־λ�Ĵ���
	CMP  MARK,01H
	JC   TT1
	
	INC  VADD
	CMP  VADD,0700H             ;ת��ֵ���������ֵ
	JC   TT1
	
	MOV  VADD,0700H
	MOV  MARK,00H
TT1:   
	MOV  AL,20H                 ;�жϽ�������EOI����
	OUT  20H,AL
	POP  DX
	POP  CX
	POP  BX
	POP  AX
	IRET
TIMERISR ENDP

KJ PROC                       ;PWM�ӳ���
	PUSH AX
	PUSH DX
	CMP  FPWM,01H               ;PWMΪ1������PWM�ĸߵ�ƽ
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
	MOV  AL, 10H                ;PB0=1 ���ת��
	MOV  DX, MY8255_C
	OUT  DX,AL

TEST2: 
	CMP  FPWM,02H               ;PWMΪ2������PWM�ĵ͵�ƽ
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
	MOV  AL,00H                 ;PB0=0 ���ֹͣ
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
	SUB  AX,YK                      ;��ƫ��EK
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
	MOV  AX,R1                  ;�ж�ƫ��EK�Ƿ��ڻ��ַ���ֵ�ķ�Χ��    ʵ���ٶ�С��Ŀ���ٶ�
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
	TEST R7,80H                 ;CK�����������
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
	
SEND PROC
       PUSH BX                     ;��ɱ��������ר��ͼ�ν�����ʾ
       MOV BX,0D800H
       MOV ES,BX             
       MOV ES:[DI],AX 
       POP  BX      
       RET  
SEND ENDP

MOVE PROC NEAR;ģʽһ��Ҫ���Ӻ�������������С������С����������Լ������жϡ��ӷֵȣ�
    PUSH BP
    MOV BP, SP
	PUSH AX
	PUSH BX
	PUSH CX
GENERATE:
	CALL DRAWMAP;ÿִ��һ�Σ�����ˢ���·����ĸ�����
	MOV AH,0CH
	MOV AL, 00h
 	INT 21h;��ռ��̻�����
	MOV AL,0
	MOV BX,0
	CALL randByBX;����0~3���������������BX
	PUSH BX;���������С����ĳ�ʼX����
	MOV CX,0
	PUSH CX;���������С����ĳ�ʼY����
DROP:
	PUSH BX;���������С����ĵ�ǰ��X���꣨����������Ӻ�����������
	PUSH CX;���������С����ĵ�ǰ��Y���꣨����������Ӻ�����������
	CALL NOTES;���û���С������ӳ���,����С����
    MOV DL,BYTE PTR DIFFICULTY;ȡ������ӳ�ʱ�䣨�Ѷȣ���������ʱ�ӳ��� 
    CALL delaymusic
	PUSH BX;���������С����ĵ�ǰ��X���꣨����������Ӻ�����������
	PUSH CX;���������С����ĵ�ǰ��Y���꣨����������Ӻ�����������
	CALL DELETENOTES;����ղ���ʾ��λ�õ��ַ�
	INC CX;���������1
	CMP CX,16;�ж�������Y�Ƿ����·��ĸ�С�����λ��
	JAE UPDATE;�����ˣ�������UPDATE����δ�������������ִ��
	PUSH CX;����ʵ�������л����������⣬�����ֳ�
	MOV AX,0100H
	INT 16H;�ж����ް�������
	POP CX
	CALL KEYBOARD;ɨ�����������
	CMP AL,10H
	JNE GENERATE;�ж��Ƿ�����ǰ���°�����������������GENERATE������������С���飩��δ����������drop��ͼ�μ������䣩
	JMP DROP
UPDATE:;
	CMP CX,21;�ж��������Ƿ񳬹��·��ĸ�С�����λ��
	JAE BYOND2;������������BYOND2�������Ӱ�������δ���������ִ��
	CALL KEYBOARD
	CMP AL,10H
	JZ BYOND2;û�а�������������BYOND2���а�������������ִ��
	;PUSH CX;����ʵ�������л����������⣬�����ֳ�
	;MOV AH,01H
	;INT 16H;�ж��Ƿ��а�������
	;POP CX
	;MOV AH, 00h;
 	;INT 16h
	;MOV AH,0bH
	;MOV AL,00H
	;INT 21H
	;MOV AH,08H
	;INT 21H
	;�ж������ͼ�εĺ������λ�ã�������ָ����λ��
	CMP BX,7
	JE CHECK1
	CMP BX,27
	JE CHECK2
	CMP BX,47
	JE CHECK3
	CMP BX,67
	JE CHECK4
	JMP BYOND1

CHECK1:
	CMP AL,0CH;�жϰ����Ƿ�Ϊ1
	JE WIN;���ǣ�������win
	JMP BYOND2;��������BYOND2�����¼���CHECK����
CHECK2:
	CMP AL,0DH
	JE WIN
	JMP BYOND2
CHECK3:
	CMP AL,0EH
	JE WIN
	JMP BYOND2
CHECK4:
	CMP AL,0FH
	JE WIN
	JMP BYOND2
WIN:;���ɹ�����
	ADD SCORE,2;�ӷ�
	CALL DRAWMAP;ˢ���·��ĸ�С����
	JMP BYOND1;Ȼ������BYOND1��������ǰ�ӳ����ִ��
BYOND2:
	CMP CX,24
	JAE BYOND1
	JMP DROP
BYOND1:
	POP CX	
	POP BX
	POP AX
	MOV SP,BP
    POP BP
	RET
MOVE ENDP

SHOWSSCORE PROC NEAR;��ʾ�����ڵ�����Ļ���Ͻ�	  
	PUSH BP
	MOV BP,SP
	SUB SP,2
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI	  
	MOV WORD Ptr [BP-2],00H;��ǰ�����ʾʱ��ĺ�����
	MOV AX, [BP+4];ȡ����ǰѹ��ķ���
	MOV CX, 0;������¼SCOREΪ��λ��
	MOV BX, 10;������
	OR AX, AX;�ж��ǲ�������
	JNS SHOWSRep1
	;����:
	NEG AX;���Ǹ�����������
	PUSH AX;����ѹ��ջ  
	MOV DI,[BP-2]
	ADD DI,DI
	SUB DI,1
	ADD DI,0A0H
	MOV AH,'-'
	MOV AL,07H
	MOV ES:[DI],AX;�Դ���ָ��λ�ã����Ͻǣ�ֱ��д�롮-��
	ADD Byte Ptr [BP-2],1
	POP AX
	MOV CX,0
SHOWSRep1: 
	MOV DX, 0;������
	DIV BX;AX�ڵķ�������10,��������DX��
	ADD DX, '0';������ת����ASCII��
	PUSH DX;��ÿһλ�ɵ�λ����λ����ѹ��ջ��
	INC CX;���������λ��
	OR AX, AX
	JNZ SHOWSRep1  
SHOWSRep2: ;��ѹ��ջ�е�ÿһλ���֣����д���Դ棬��ʾ����Ļ��
	POP DX
	MOV [BP-4],DL
	MOV DI,[BP-2]
	ADD DI,DI
	SUB DI,1
	ADD DI,0A0H;���漸��ֱ�����о�����ȷ��Ҫ��ʾ��λ��
	MOV AH,[BP-4]
	MOV AL,07H
	MOV ES:[DI],AX
	ADD Byte Ptr [BP-2],1;������ʾ��λ��������һλ
	LOOP SHOWSRep2;ÿһλ����ѭ����ʾ
	MOV DI,[BP-2]
	ADD DI,DI
	SUB DI,1
	ADD DI,0A0H
	MOV AH,20H
	MOV AL,07H
	MOV ES:[DI],AX;��ʾ�ո񸲸Ƕ����0
	POP DI      
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET 2
SHOWSSCORE ENDP

DELETENOTES PROC NEAR;�ú�ɫ��������ķ��飨ԭ����NOTES�ӳ���һ�£������ַ����Ը�Ϊ00H��
				;���÷���������ǰ����ѹ�룺��ʾ��ʼ��X���ꡢ��ʾ��ʼ��Y����
    PUSH BP
    MOV BP, SP
	PUSH AX
	PUSH BX
	PUSH CX
	MOV CX,4
delNOTES:;�����÷�������ѹ��ָ��ֵ������SHOWS�ӳ����ڶ�Ӧ��λ���ϻ���һģһ���ĺ�ɫ���鸲��ԭ�з���
	MOV AX,20H
	PUSH AX
	MOV AX,00H
	PUSH AX
	MOV AX,[BP+6]
	PUSH AX
	MOV AX,[BP+4]
	PUSH AX
	MOV AX,07H
	PUSH AX
	CALL SHOWS
	MOV BX,[BP+4]
	INC BX
	MOV [BP+4],BX;ͨ��BX�Ĵ�������Y���꣬�ٽ�ֵ����[BP+4]
	LOOP delNOTES;ѭ�����л���
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET 4
DELETENOTES ENDP

;���ܣ��ظ�����ָ�����ַ�����ָ���������ַ����ԣ�
SHOWS PROC NEAR
;����ǰ����ѹ��:
;��Ҫ��ʾ���ַ���ASCII�룩���ַ����ԡ���ʾ��ʼ��x���ꡢ��ʾ��ʼ��y���ꡢ��ʾ�ĳ���
      PUSH BP
      MOV BP, SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	MOV AL,[BP+6];ȡ��ѹ���y����
	MOV BL,160
	MUL BL
	MOV DI,[BP+8];ȡ��ѹ���x����
	ADD DI,DI;�൱�ڽ�DI*2
	SUB DI,1
	ADD DI,AX 
	MOV CX,[BP+4];ȡ��ѹ��ĳ���
	MOV AH,[BP+12];ȡ��ѹ�����Ҫ��ʾ���ַ�
	MOV AL,[BP+10];ȡ��ѹ�����Ҫ�ַ�����
DIS:
	MOV ES:[DI],AX;д���Ӧ���Դ浱��
	ADD DI,2
	LOOP DIS;�����������ѭ����ʾͬ�����Ե��ַ�
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
      POP BP
	RET 10
SHOWS ENDP

NOTES PROC NEAR;��������ķ���
				;���÷���������ǰ����ѹ�룺��ʾ��ʼ��X���ꡢ��ʾ��ʼ��Y����
    PUSH BP
    MOV BP, SP
	PUSH AX
	PUSH BX
	PUSH CX
	MOV CX,4;�������䷽��ĳ���
DISNOTES:;�����÷�������ѹ��ָ��ֵ������SHOWS�ӳ���
	MOV AX,20H
	PUSH AX
	MOV AX,70H
	PUSH AX
	MOV AX,[BP+6]
	PUSH AX
	MOV AX,[BP+4]
	PUSH AX
	MOV AX,07H
	PUSH AX
	CALL SHOWS
	MOV BX,[BP+4];ͨ��BX�Ĵ�������Y���꣬�ٽ�ֵ����[BP+4]
	INC BX
	MOV [BP+4],BX
	LOOP DISNOTES;ѭ�����л���
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET 4
NOTES ENDP

DRAWMAP PROC NEAR;���ƽ����·����ĸ�����
				;���÷�����ֱ�ӵ���
	PUSH SI
	PUSH AX
	LEA SI,FOURKEYS;ȡ���ݶ����ڻ����ĸ����������ݵ�ƫ�Ƶ�ַ
DISKEYS:
	MOV AX,[SI]
	PUSH AX;ѹ�����Ҫ��ʾ���ַ�
	MOV AX,[SI+2]
	PUSH AX;ѹ�����Ҫ��ʾ���ַ�����
	MOV AX,[SI+4]
	PUSH AX;ѹ���X����
	MOV AX,[SI+6]
	PUSH AX;ѹ���Y����
	MOV AX,[SI+8]
	PUSH AX;ѹ��ĳ���
	CALL SHOWS
	ADD SI,10;ȥ���ݶ����ڻ����ĸ����������ݵ�ƫ�Ƶ�ַ
	MOV AX,[SI]
	CMP AX,0;�ж��Ƿ�������
	JNE DISKEYS;δ��������������ƣ�����ִ�н���
	POP AX
	POP SI
DRAWMAP ENDP

;ʵ������̶�ȡ�ӳ���(�������ĸ���Ϊ��Ч����)
;���ܣ���ʵ���䰴������ɨ��
;���ް������»���Ч�������·���ֵAL = 10H
;�����а������������������η���AL = 0CH, 0DH, 0EH, 0FH     
KEYBOARD PROC
KEYSTART1:
       PUSH BX
       PUSH CX
       PUSH DX

KEYBEGIN1:
       MOV  DX,MY8255_MODE         ;��ʼ��8255������ʽ
       MOV  AL,81H                 ;��ʽ0��A�ڡ�B�������C�ڵ�4λ����
       OUT  DX,AL
	   CALL CCSCAN                 ;ɨ�谴��
	   JNZ  GETKEY1                ;�м�����������GETKEY1
	   JMP  RETURN1                ;�ް������������RETURN1����

GETKEY11:
	   CALL CCSCAN                 ;�ٴ�ɨ�谴��
	   JNZ  GETKEY2                ;�а�������������GETKEY2
	   JMP  KEYBEGIN               ;�������ؿ�ʼ����ѭ��

GETKEY21:
       MOV  CH,0FEH                ;�ӵ�һ�п�ʼɨ��
	   MOV  CL,00H                 ;���õ�ǰ�����ǵڼ��У�0��ʾ��һ��

COLUM1: 
       MOV  AL,CH                  ;ѡȡһ�У���X1~X4��ĳһ������
       MOV  DX,MY8255_A 
	   OUT  DX,AL
       MOV  DX,MY8255_C            ;��Y1~Y4�������ж�����һ�а����պ�
	   IN   AL,DX
    
       TEST AL,08H                 ;��ǰ��������Ϊ����������������������ͬʱ����ѡͨ����ʱAL = 07H
       JNZ  NEXT                   ;δѡͨ������NEXT��ѡͨ��˳��ִ��
       MOV  AL,0CH                 ;���õ�4�е�1�еĶ�Ӧ�ļ�ֵ�����г�ʼ��
       ADD  AL,CL                  ;����1�е�ֵ���ϵ�ǰѡͨ��������ȷ������ֵ
	   PUSH AX
	   
KON1:   
       CALL CCSCAN                 ;ɨ�谴���������жϰ����Ƿ���
	   JNZ  KON                    ;δ���������ѭ���ȴ�����
	   JMP  RETURN2                ;����RETURN2����

NEXT1:  
       INC  CL                     ;��ǰ������������
	   MOV  AL,CH
	   TEST AL,08H                 ;����Ƿ�ɨ�赽��4��
	   JZ   RETURN1                ;����˵������Ч�������£�����RETURN1���з���
	
       ROL  AL,1                   ;δ��⵽��4����׼���������Ƽ����һ��
	   MOV  CH,AL
	   JMP  COLUM

RETURN11:                           ;���û�а������»��µİ���Ϊ��Ч������RETURN1���أ�����ֵAL = 10H
       MOV AL,10H
       POP DX
       POP CX
       POP BX
       RET
       
RETURN21:                           ;�����Ч����������RETURN2����,����ֵAL���հ��������ҷֱ�Ϊ0CH,0DH,0EH,0FH
       POP AX
       POP DX
       POP CX
       POP BX
       RET
       
KEYBOARD ENDP


KEYBOARD16 PROC                      ;��ȡ�����ӳ���(16������)
KEYSTART:
       PUSH BX
       PUSH CX
       PUSH DX

KEYBEGIN:
       MOV  DX,MY8255_MODE         ;��ʼ��8255������ʽ
       MOV  AL,81H                 ;��ʽ0,A�ڡ�B������,C�ڵ�4λ����
       OUT  DX,AL
	   CALL CCSCAN                 ;ɨ�谴��
	   JNZ  GETKEY1                ;�м�����������GETKEY1  
	   JMP  RETURN1                ;û�а������������RETURN1����

GETKEY1:
	   CALL CCSCAN                 ;�ٴ�ɨ�谴��
	   JNZ  GETKEY2                ;�м�����������GETKEY2
	   JMP  KEYBEGIN               ;�������ؿ�ʼ����ѭ��

GETKEY2:
       MOV  CH,0FEH                ;�ӵ�һ�п�ʼɨ��
	   MOV  CL,00H                 ;���õ�ǰ�����ǵڼ��У�0��ʾ��һ��

COLUM: 
       MOV  AL,CH                  ;ѡȡһ�У���X1��X4��һ����0            
       MOV  DX,MY8255_A 
	   OUT  DX,AL
       MOV  DX,MY8255_C            ;��Y1��Y4�������ж�����һ�а����պ� 
	   IN   AL,DX

LINE1:
       TEST AL,01H
       JNZ  LINE2
       MOV  AL,00H
       JMP  KCODE
       
LINE2:
       TEST AL,02H
       JNZ  LINE3
       MOV  AL,04H
       JMP  KCODE
       
LINE3:
       TEST AL,04H
       JNZ  LINE4
       MOV  AL,08H
       JMP  KCODE
    
LINE4:
       TEST AL,08H                 ;���ҽ�������Ϊ����������������������ͬ����ѡͨ����ʱAL=07H
       JNZ  NEXT                   ;δѡͨ������NEXT,ѡͨ��˳��ִ��
       MOV  AL,0CH                 ;���õ�4�е�1�еĶ�Ӧ�ļ�ֵ 

KCODE:
       ADD  AL,CL                  ;����1�е�ֵ���ϵ�ǰ������ȷ������ֵ
	   PUSH AX
	   
KON:   
       CALL CCSCAN                 ;ɨ�谴�����жϰ����Ƿ���
	   JNZ  KON                    ;δ���������ѭ���ȴ�����
	   JMP  RETURN2                ;����RETURN2����

NEXT:  
       INC  CL                     ;��ǰ������������                    
	   MOV  AL,CH
	   TEST AL,08H                 ;����Ƿ�ɨ�赽��4��
	   JZ   RETURN1                ;�������RETURN1����
	
       ROL  AL,1                   ;û��⵽��4����׼�������һ��
	   MOV  CH,AL
	   JMP  COLUM

RETURN1:                           ;���û�а������»��߰��°�����Ч��RETURN1����,����ֵAL=10H
       MOV AL,10H
       POP DX
       POP CX
       POP BX
       RET
       
RETURN2:                           ;�����Ч����������RETURN2����,����ֵALΪ00H-0EH
       POP AX
       POP DX
       POP CX
       POP BX
       RET
       
KEYBOARD16 ENDP      

  
CCSCAN PROC NEAR                   ;ɨ���Ƿ��а����պ��ӳ���
       PUSH AX
       PUSH DX
       
       MOV  AL,00H                              
       MOV  DX,MY8255_A            ;��4��ȫѡͨ��X1��X4��0
	   OUT  DX,AL
       MOV  DX,MY8255_C 
       IN   AL,DX                  ;��Y1��Y4
	   NOT  AL
       AND  AL,0FH                 ;ȡ��Y1��Y4�ķ�ֵ���ް�������ʱAL=00H����־λZF=1
       
       POP DX
       POP AX	   
       RET
CCSCAN ENDP


;ɨ���Ƿ��а����պ��ӳ���
CCSCAN1 PROC NEAR
       PUSH AX
       PUSH DX
       
       MOV  AL,00H                              
       MOV  DX,MY8255_A            ;��4��ȫѡͨ��X1~X4����
	   OUT  DX,AL
       MOV  DX,MY8255_C 
       IN   AL,DX                  ;��Y1~Y4
	   NOT  AL
       AND  AL,0FH                 ;ȡ��Y1~Y4�ķ�ֵ���ް�������ʱAL = 00H����־λZF = 1
       
       POP DX
       POP AX	   
       RET
CCSCAN1 ENDP

;�����ӳ���
 RING PROC NEAR
	PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	PUSH SI
	MOV SI,[BP+6];ȡ����Ӧ��Ƶ�ʱ�ƫ�Ƶ�ַ
	MOV BX,0
	MOV CX,[BP+4];ȡ��������ASCII��
	;��������16����QWERTYUIASDFGHJK������Ϊ��4����5
	;���ݰ���������Ӧ�Ŀ�
	CMP CX,0071H
	JE TRANS7
	CMP CX,0077H
	JE TRANS8
	CMP CX,0065H
	JE TRANS9
	CMP CX,0072H
	JE TRANS10
	CMP CX,0074H
	JE TRANS11
	CMP CX,0079H
	JE TRANS12
	CMP CX,0075H
	JE TRANS13
	CMP CX,0069H
	JE TRANS14
	CMP CX,0061H
	JE TRANS15
	CMP CX,0073H
	JE TRANS16
	CMP CX,0064H
	JE TRANS17 
	CMP CX,0066H
	JE TRANS18 
	CMP CX,0067H
	JE TRANS19 
	CMP CX,0068H
	JE TRANS20 
	CMP CX,006AH
	JE TRANS21 
	CMP CX,006BH
	JE TRANS22 
	JMP endring
      
 TRANS7:JMP Q
 TRANS8:JMP W
 TRANS9:JMP E
 TRANS10:JMP R
 TRANS11:JMP T
 TRANS12:JMP Y
 TRANS13:JMP U
 TRANS14:JMP I
 TRANS15:JMP A
 TRANS16:JMP S
 TRANS17:JMP D
 TRANS18:JMP F
 TRANS19:JMP G
 TRANS20:JMP H
 TRANS21:JMP J
 TRANS22:JMP K
		
Q:
	MOV BX,0 ;��Ӧ����Ƶ�ʱ��е�ƫ��������������ε���2����ͬ
	MOV DX,1 ;��Ӧ����ˢ��λ�õ���ʼx���꣬��ͬ
	JMP RINGING ;��ת���������֣���ͬ
W:
	MOV BX,2
	MOV DX,5
	JMP RINGING
E:
	MOV BX,4
	MOV DX,10
	JMP RINGING
R:
	MOV BX,6
	MOV DX,15
	JMP RINGING
T:
	MOV BX,8
	MOV DX,20
	JMP RINGING
Y:
	MOV BX,10
	MOV DX,25
	JMP RINGING
U:
	MOV BX,12
	MOV DX,30
	JMP RINGING
I:
	MOV BX,14
	MOV DX,35
	JMP RINGING
A:
	MOV BX,16
	MOV DX,40
	JMP RINGING
S:
	MOV BX,18
	MOV DX,45
	JMP RINGING
D:
	MOV BX,20
	MOV DX,50
	JMP RINGING
F:
	MOV BX,22
	MOV DX,55
	JMP RINGING
G:
	MOV BX,24
	MOV DX,60
	JMP RINGING
H:
	MOV BX,26
	MOV DX,65
	JMP RINGING
J:
	MOV BX,28
	MOV DX,70
	JMP RINGING
K:
	MOV BX,30
	MOV DX,75
	JMP RINGING
RINGING:
	CALL LIGHT_RED				;����Ӧ�İ���ˢ��
	PUSH DX						;��ˢ�����ʼx����ѹ��ջ����
	MOV DX,MY8254_MODE          ;��ʼ������8254Ϊ��ʽ3��OUT0���
	MOV AL,36H
	OUT DX,AL
	ADD SI,BX					;ȡ���水��ȷ����ƫ��ֵ��ѡ����Ӧ��Ƶ��
	MOV DX,0FH                  ;����ʱ��Ϊ1.0416667MHz��1.0416667M = 0FE502H  
	MOV AX,0E502H                
	DIV WORD PTR [SI]           ;ȡ��Ƶ��ֵ���������ֵ��0F4240H / ���Ƶ��  
	MOV DX,MY8254_COUNT0
	OUT DX,AL                   ;װ�������ֵ
	MOV AL,AH
	OUT DX,AL                
	CALL delay					;������ʱ�ӳ��򣬿���ÿ�η�����ʱ�䳤��
	CALL delay
	POP DX
	CALL LIGHT_WHITE			;����Ӧ�İ����ָ�ԭ״
	MOV DX,MY8254_MODE          ;�˳�ʱ����8254Ϊ��ʽ0��OUT0��0������
	MOV AL,10H
	OUT DX,AL
endring:
	POP SI
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET 4
RING ENDP

;ģʽ2�н���Ӧ����ˢ�ף��ָ�ԭ״���ӳ���
LIGHT_WHITE PROC NEAR
      PUSH BP
      MOV BP,SP
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
	  PUSH DI
      PUSH SI

	;����Ӧ����һ�鸲���ϰ�ɫ�����ָ�ԭ״
    LEA DI,pos_y
    MOV BX,DX;ת���Ӧ����ˢ��λ�õ���ʼx����
    MOV CX,5
LIGHTWHITE_DRAW:
    DRAW2 20H,7EH,BX,DI,5
    ADD DI,2
    LOOP LIGHTWHITE_DRAW

      POP SI
	  POP DI
      POP DX
      POP CX
      POP BX
      POP AX
      MOV SP,BP
      POP BP
	  RET
LIGHT_WHITE ENDP

;ģʽ2�н���Ӧ����ˢ���ӳ���
LIGHT_RED PROC NEAR
      PUSH BP
      MOV BP,SP
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
	PUSH DI
      PUSH SI

	;����Ӧ����һ�鸲���Ϻ�ɫ�����ָ�ԭ״
    LEA DI,pos_y
    MOV BX,DX;ת���Ӧ����ˢ��λ�õ���ʼx����
    MOV CX,5
LIGHTRED_DRAW:
	DRAW2 20H,4EH,BX,DI,5
	ADD DI,2
	LOOP LIGHTRED_DRAW

	POP SI
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET
LIGHT_RED ENDP

;ģʽ2�л�ÿ�����ļ��̵Ĺ������ֵ��ӳ���
DRAW_ME2 PROC NEAR
	PUSH BP
    MOV BP,SP
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI
	
	MOV AX,0B800H
    MOV ES,AX
    
	LEA BX,main2_pos_y
	MOV CX,12
 DRAW_MAIN2:;��ģʽ2��ɫ����
	DRAW2 20h,3eh,01h,BX,80
	ADD BX,2
	LOOP DRAW_MAIN2

	LEA BX,keywh2_pos_y
	MOV CX,13
 DRAW_KEYWH:;��ģʽ2��ɫ�ټ�
	DRAW2 20H,7EH,01H,BX,80
	ADD BX,2
	LOOP DRAW_KEYWH

	LEA BX,t_pos_x
	LEA SI,t_pos_y
	LEA DI,t_len
	MOV CX,5
 T_DRAW:;��ģʽ2����ĸT
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP T_DRAW

	LEA BX,u_pos_x
	LEA SI,u_pos_y
	LEA DI,u_len
	MOV CX,9
 U_DRAW:;��ģʽ2����ĸU
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP U_DRAW

	LEA BX,n2_pos_x
	LEA SI,n2_pos_y
	LEA DI,n2_len
	MOV CX,9
 NN_DRAW:;��ģʽ2����ĸN(TUNE)
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP NN_DRAW

	LEA BX,e1_pos_x
	LEA SI,e_pos_y
	LEA DI,e_len
	MOV CX,5
 E2_DRAW:;��ģʽ2����ĸE
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP E2_DRAW

	LEA BX,p2_pos_x
	LEA SI,p2_pos_y
	LEA DI,p2_len
	MOV CX,6
 P2_DRAW:;��ģʽ2����ĸP
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP P2_DRAW

	LEA BX,i2_pos_x
	LEA SI,i2_pos_y
	LEA DI,i2_len
	MOV CX,5
 I2_DRAW:;��ģʽ2����ĸI
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP I2_DRAW

	LEA BX,a3_pos_x
	LEA SI,a3_pos_y
	LEA DI,a3_len
	MOV CX,8
 A3_DRAW:;��ģʽ2����ĸA
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP A3_DRAW

	LEA BX,n3_pos_x
	LEA SI,n3_pos_y
	LEA DI,n3_len
	MOV CX,9
 N3_DRAW:;��ģʽ2����ĸN��PIANO)
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP N3_DRAW

	LEA BX,o2_pos_x
	LEA SI,o2_pos_y
	LEA DI,o2_len
	MOV CX,8
 O2_DRAW:;��ģʽ2����ĸO
	DRAW1 20H,05EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP O2_DRAW

	LEA BX,point_pos_x
	LEA SI,point_pos_y
	LEA DI,point_len
	MOV CX,2
 POINT_DRAW:;��ģʽ2��������
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP POINT_DRAW

	LEA BX,symbol_char
	LEA DI,symbol_pos_x
	LEA SI,symbol_pos_y
	MOV CX,25
 SYMBOL_DRAW:;��ģʽ2�еļ���������ʶ
	DRAW3 BX,3EH,DI,SI,1
	ADD BX,1
	ADD DI,2
	ADD SI,2
	LOOP SYMBOL_DRAW
	
	LEA BX,esc_char
	LEA DI,esc_pos_x
	LEA SI,esc_pos_y
	MOV CX,8
 ESC_DRAW:;��ģʽ2�е��˳���ʶ��
	DRAW3 BX,3EH,DI,SI,1
	ADD BX,1
	ADD DI,2
	ADD SI,2
	LOOP ESC_DRAW

	POP SI
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET 10

DRAW_ME2 ENDP

delay PROC NEAR;��ʱ�ӳ���
      PUSH CX
	PUSH AX
	MOV AX, 0
      MOV CX, 0
delayLoop1:
	INC CX
      CMP CX, 0FFFFH
      JB delayLoop1
      INC AX
      CMP AX, 0f00H
      JB delayLoop1
      POP AX
      POP CX
      RET
delay ENDP

;�����������ʾ�ӳ���
;���ܣ�������ת��������ܼ�ֵ�����������������ʾ����
SCOREDIS PROC NEAR
       PUSH AX
       PUSH BX
       PUSH CX
       PUSH DX
       PUSH SI
       MOV  SI,3000H               ;���������������Ҫ��ʾ�ļ�ֵ
	   MOV  AL,00H                 ;�ȳ�ʼ����ֵΪ0
	   MOV  [SI],AL
	   MOV  [SI+1],AL
	   MOV  [SI+2],AL
	   MOV  [SI+3],AL
	   MOV  [SI+4],AL
	   MOV  [SI+5],AL
	   MOV  DX,MY8255_MODE         ;��ʼ��8255������ʽ
       MOV  AL,81H                 ;��ʽ0��A��B�������C�ڵ�4λ����
	   OUT  DX,AL
	   
CLEAR:                             ;����������ʾ
	   MOV  DX,MY8255_B            ;��λ��0��������������ʾ
	   MOV  AL,00H
       OUT  DX,AL
	   
	   MOV  AX,SCORE               ;��������Ϊ��������10��Ϊ������շתȡ��
	   MOV  BH,0AH
DIVSCORE:              
       DIV  BH                     ;������ʮ��������AHΪ������ALΪ��
       MOV  [SI],AH                ;�������ֱ���뻺����
       INC  SI
       CMP  AL,00H                 ;�ж�AL�Ƿ�Ϊ0��Ϊ�������
       JE   DISPLAYS
       MOV  AH,00H                 ;�̲�Ϊ�㣬��AH���㣬������ʮȡ��
       JMP  DIVSCORE
       
DISPLAYS:
       MOV  CX,00FFH
TIME1:    MOV  AX,005FH            ;��ʱ����Σ���֤������ܹ���ʾһ��ʱ��
TIME2:    PUSH AX
              
	   MOV  SI,3000H                           
	   MOV  DL,0DFH
	   MOV  AL,DL
AGAIN: PUSH DX
       MOV  DX,MY8255_A 
       OUT  DX,AL                  ;����L1~L6��ѡͨһ�������
       MOV  AL,[SI]                ;ȡ���������д�ŵļ�ֵ
       MOV  BX,OFFSET DTABLE
	   AND  AX,00FFH
	   ADD  BX,AX                  
	   MOV  AL,[BX]                ;����ֵ��Ϊƫ�ƺͼ�ֵ����ַ��ӵõ���Ӧ�ļ�ֵ
       MOV  DX,MY8255_B 
	   OUT  DX,AL                  ;д�������A~Dp
	   CALL DALLY5
	   INC  SI                     ;ȡ��һ����ֵ
       POP  DX
       MOV  AL,DL
	   TEST AL,01H                 ;�ж��Ƿ���ʾ��
       JZ   OUT0                   ;��ʾ�꣬�򷵻�
	   ROR  AL,1
	   MOV  DL,AL
	   JMP  AGAIN                  ;δ��ʾ�꣬ѡͨ��һ������ܲ����ؼ���
OUT0:  POP  AX
       DEC  AX
	   JNZ  TIME2

STOP:  
       POP  SI
       POP  DX
       POP  CX
       POP  BX
       POP  AX
       RET
SCOREDIS ENDP


;��ģʽ3�������ӳ���
DRAW_MENU3 PROC NEAR

    PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	PUSH SI

    LEA BX,main3_pos_y
	MOV CX,25
 DRAW_MAIN3:;��ģʽ3��ɫ����
	DRAW2 20h,3eh,01h,BX,80
	ADD BX,2
	LOOP DRAW_MAIN3

	LEA BX,fanr_pos_x
	LEA SI,fanr_pos_y
	LEA DI,fanr_len
	MOV CX,6
 FANR_DRAW:;��ģʽ3��ɫ��Ҷ
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANR_DRAW

	LEA BX,fanwh_pos_x
	LEA SI,fanwh_pos_y
	LEA DI,fanwh_len
	MOV CX,2
 FANWH_DRAW:;��ģʽ3���Ȱ�ɫ���ĵ�
	DRAW1 20H,07EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANWH_DRAW

	LEA BX,fany_pos_x
	LEA SI,fany_pos_y
	LEA DI,fany_len
	MOV CX,6
 FANY_DRAW:;��ģʽ3��ɫ��Ҷ
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANY_DRAW
  
	LEA BX,fanb_pos_x
	LEA SI,fanb_pos_y
	LEA DI,fanb_len
	MOV CX,6
 FANB_DRAW:;��ģʽ3��ɫ��Ҷ
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANB_DRAW

	LEA BX,fang_pos_x
	LEA SI,fang_pos_y
	LEA DI,fang_len
	MOV CX,6
 FANG_DRAW:;��ģʽ3��ɫ��Ҷ
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANG_DRAW

	LEA BX,f03_pos_x
	LEA SI,f03_pos_y
	LEA DI,f03_len
	MOV CX,6
 F03_DRAW:;��ģʽ3��ĸF
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP F03_DRAW

	LEA BX,a03_pos_x
	LEA SI,a03_pos_y
	LEA DI,a03_len
	MOV CX,9
 A03_DRAW:;��ģʽ3��ĸA
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP A03_DRAW

	LEA BX,n03_pos_x
	LEA SI,n03_pos_y
	LEA DI,n03_len
	MOV CX,12
 N03_DRAW:;��ģʽ3��ĸN
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP N03_DRAW

	LEA BX,p03_pos_x
	LEA SI,p03_pos_y
	LEA DI,p03_len
	MOV CX,7
 P03_DRAW:;��ģʽ3��ĸP
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP P03_DRAW

	LEA BX,l03_pos_x
	LEA SI,l03_pos_y
	LEA DI,l03_len
	MOV CX,6
 L03_DRAW:;��ģʽ3��ĸL
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP L03_DRAW

	LEA BX,a04_pos_x
	LEA SI,a04_pos_y
	LEA DI,a03_len
	MOV CX,9
 A04_DRAW:;��ģʽ3��ĸA
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP A04_DRAW

	LEA BX,y03_pos_x
	LEA SI,y03_pos_y
	LEA DI,y03_len
	MOV CX,8
 Y03_DRAW:;��ģʽ3��ĸY
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP Y03_DRAW

	LEA BX,frame_pos_x
	LEA SI,frame_pos_y
	LEA DI,frame_len
	MOV CX,12
 FRAME_DRAW:;��ģʽ3��ʾ���߿�
	DRAW1 20H,05EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FRAME_DRAW

	LEA BX,up_pos_x
	LEA SI,updown_pos_y
	LEA DI,up_len
	MOV CX,9
 UP_DRAW:;��ģʽ3���ϵļ�ͷ
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP UP_DRAW

	LEA BX,down_pos_x
	LEA SI,updown_pos_y
	LEA DI,down_len
	MOV CX,9
 DOWN_DRAW:;��ģʽ3���µļ�ͷ
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP DOWN_DRAW

	LEA BX,lan1_pos_x
	LEA SI,lan1_pos_y
	LEA DI,lan_len
	MOV CX,3
 LAN1_DRAW:;��ģʽ3��ָʾ��
	DRAW1 20H,00EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP LAN1_DRAW

	LEA BX,lan2_pos_x
	LEA SI,lan2_pos_y
	LEA DI,lan_len
	MOV CX,3
 LAN2_DRAW:;��ģʽ3��ָʾ��
	DRAW1 20H,00EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP LAN2_DRAW
	
	LEA BX,output_str
	LEA DI,output_pos_x
	LEA SI,output_pos_y
	MOV CX,44
 ESC_DRAW1:;��ģʽ3�˳���ʶ��
	DRAW3 BX,3EH,DI,SI,1
	ADD BX,1
	ADD DI,2
	ADD SI,2
	LOOP ESC_DRAW1

    POP SI
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
    RET 
DRAW_MENU3 ENDP

;��ʾ�趨ת�ٵ��ӳ���
SHOWSPEED_ASSUMED PROC NEAR              
	PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	PUSH DI
	PUSH SI

	MOV CX,AX;����AX
	MOV  AX,0B800H;����д���Դ�λ��
	MOV  ES,AX
	MOV AX,CX;����AX

	;��AX�д洢��ת�ٸ�λʮλ�ֿ���ת��Ϊ��Ӧ��ASCII�벢���ڶ�Ӧ��λ��
	MOV  DX,0                   
	MOV  BX,10                 
	DIV  BX       			              

	ADD  AL,30H                
	ADD  DL,30H

	DRAW5 AX,3EH,51,7,1
	DRAW5 DX,3EH,52,7,1
				
	POP SI
	POP DI
	POP ES
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET  
 SHOWSPEED_ASSUMED ENDP

;��ʾ��ʱת�ٵ��ӳ���,ע���������ӳ������һ�£������ظ�ע��
 SHOWSPEED_CURRENT PROC NEAR              

	PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	PUSH DI
	PUSH SI

	MOV CX,AX
	MOV  AX,0B800H
	MOV  ES,AX
	MOV AX,CX

	MOV  DX,0                   
	MOV  BX,10                 
	DIV  BX       			              

	ADD  AL,30H                
	ADD  DL,30H

	DRAW5 AX,3EH,51,9,1
	DRAW5 DX,3EH,52,9,1
	CALL delay;�ӻ��ڽ�������ʾ��ʱ�䣬��ֹˢ�¹����޷��ڽ�������ʾ
				
	POP SI
	POP DI
	POP ES
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET  
 SHOWSPEED_CURRENT ENDP

;ģʽ����������ָʾ��ˢ���ӳ���ע����LIGHT_RED��LIGHT_WHITE����һ�£������ظ�ע��
;���ǽ���Ӧ�Ĳ���ˢ�죨�൱�����𣩻���ˢ�ڣ��ָ�ԭ״��
LIGHT_UP_RED PROC NEAR
	PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	PUSH DI
	PUSH SI


	MOV  AX,0B800H
	MOV  ES,AX

	LEA DI,lan1_pos_y
	MOV BX,CX
	MOV CX,3
LIGHTRED_DRAW1:
    DRAW2 20H,4EH,BX,DI,3
	ADD DI,2
	LOOP LIGHTRED_DRAW1

	POP SI
	POP DI
	POP ES
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET
LIGHT_UP_RED ENDP

;ģʽ��������ָʾ��ˢ���ӳ���
LIGHT_UP_BLACK PROC NEAR
	PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	PUSH DI
	PUSH SI
	MOV  AX,0B800H
	MOV  ES,AX
	LEA DI,lan1_pos_y
	MOV BX,CX
	MOV CX,3
LIGHTBLACK_DRAW1:
	DRAW2 20H,0EH,BX,DI,3
	ADD DI,2
	LOOP LIGHTBLACK_DRAW1

	POP SI
	POP DI
	POP ES
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET
LIGHT_UP_BLACK ENDP

;ģʽ����ָʾ��ˢ���ӳ���
LIGHT_DOWN_RED PROC NEAR
	PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	PUSH DI
	PUSH SI

	MOV  AX,0B800H
	MOV  ES,AX

	LEA DI,lan2_pos_y
	MOV BX,CX
	MOV CX,3
LIGHTRED_DRAW2:
	DRAW2 20H,4EH,BX,DI,3
	ADD DI,2
	LOOP LIGHTRED_DRAW2

	POP SI
	POP DI
	POP ES
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET
LIGHT_DOWN_RED ENDP

;ģʽ����ָʾ��ˢ���ӳ���
LIGHT_DOWN_BLACK PROC NEAR
	PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH ES
	PUSH DI
	PUSH SI

	MOV  AX,0B800H
	MOV  ES,AX

	LEA DI,lan2_pos_y
	MOV BX,CX
	MOV CX,3
LIGHTBLACK_DRAW2:
	DRAW2 20H,0EH,BX,DI,3
	ADD DI,2
	LOOP LIGHTBLACK_DRAW2

	POP SI
	POP DI
	POP ES
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET
LIGHT_DOWN_BLACK ENDP

DALLY5 PROC NEAR                    ;��ʱ�ӳ���5
       PUSH CX
       MOV  CX,0fffH
DDD3:  MOV  AX,00FFH
DDD4:  DEC  AX
	   JNZ  DDD4
	   LOOP DDD3
	   POP  CX
	   RET
DALLY5 ENDP

DALLY PROC                        ;��ʱ�ӳ���1
D0:   MOV CX,0F00H
D1:   MOV AX,8FFFH
D2:   DEC AX
      JNZ D2
      LOOP D1
      DEC DL
      JNZ D0
      RET
DALLY ENDP

DALLY2 PROC NEAR         ;��ʱ�ӳ���2
       PUSH CX
       PUSH AX
       MOV  CX,05FFH
 D9:   MOV  AX,0FFFFH
 D10:  DEC  AX
	   JNZ  D10
	   LOOP D9
	   POP  AX
	   POP  CX
	   RET
DALLY2 ENDP   

DALLY3 PROC                        ;��ʱ�ӳ���3
D00:   MOV CX,00F0H
D01:   MOV AX,00F0H
D02:   DEC AX
       JNZ D02
       LOOP D01
       DEC DL
       JNZ D00
       RET
DALLY3 ENDP

delaymusic PROC NEAR              ;��ʱ�ӳ�������ģʽ1�в��Ŷ�Ӧ��������ʱ
          PUSH CX
		  PUSH AX
		  MOV AX, 0
          MOV CX, 0
delayLoop2:
		  INC CX
          CMP CX, 0FFFFH
          JB delayLoop2
		  INC AX
		  CMP AX, 0200H
		  JB delayLoop2
		  DEC DL
		  CMP DL,00H
		  JA delayLoop2
		  POP AX
          POP CX
          RET
delaymusic ENDP

randByBX PROC NEAR;�������������BX����δ����BX�Ĵ���
		  PUSH AX
		  PUSH CX
		  PUSH DX
		  STI
		  MOV AH,0 
		  INT 1AH
		  MOV AL,DL;��ȡ�õĵ�ǰʱ�����AL
		  MOV BL,4h
		  DIV BL;����ǰʱ�����4�õ�0~3������
		  MOV BL,AH;���õ�����������BL
		  MOV BH,00H
		  MOV AX,20
		  MUL BX
		  ADD AX,7;���룺����*20+7
		  MOV BX,AX;����������õ���ֵ����BX
		  POP DX
		  POP CX
     	  POP AX
     	  RET 
randByBX ENDP
CODE  ENDS
      END START      	