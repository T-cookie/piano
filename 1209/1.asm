;魔法钢琴源代码
;组名：魔法师


;/////////宏程序////////////
;4个画图宏程序
;分别将字符的ASCII码（或对应变量偏移地址）、颜色码、起始x坐标（或对应变量偏移地址）、y坐标（或对应变量偏移地址）、每行长度（或对应变量偏移地址）压入栈中，调用SHOWS子程序
;主要用的宏程序为DRAW1
DRAW1 MACRO char,color,pos_x,pos_y,len  ;pos_x、pos_y、len为偏移地址，主要用于字母等较复杂图形的画图
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
		
DRAW2 MACRO char,color,pos_x,pos_y,len ;pos_y为偏移地址，主要用于起始x坐标、长度确定的背景、键盘黑键等的画图
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

DRAW3 MACRO char,color,pos_x,pos_y,len ;char、pos_x、pos_y为偏移地址，主要用于界面中字符串的输出
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

DRAW5 MACRO char,color,pos_x,pos_y,len  ;用于电机设定转速、即时转速的输出
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

;////////地址定义//////////   
INTR_IVADD     EQU   003CH          ;

IOY0           EQU   0E000H           ;片选IOY0对应的端口始地址
MY8255_A       EQU   IOY0+00H*4     ;8255的A口地址
MY8255_B       EQU   IOY0+01H*4     ;8255的B口地址
MY8255_C       EQU   IOY0+02H*4     ;8255的C口地址
MY8255_MODE    EQU   IOY0+03H*4     ;8255的控制寄存器地址

IOY1           EQU   0E040H         ;	片选IOY1对应的端口始地址
MY8254_COUNT0  EQU   IOY1+00H*4     ;8254的计数器0端口地址
MY8254_COUNT1  EQU   IOY1+01H*4     ;8254的计数器1端口地址
MY8254_COUNT2  EQU   IOY1+02H*4     ;8254的计数器2端口地址
MY8254_MODE    EQU   IOY1+03H*4     ;8254控制寄存器端口地址

PC8254_COUNT0  EQU   40H            ;PC机内8254定时器0端口地址
PC8254_MODE    EQU   43H            ;PC机内8254控制寄存器端口地址

;/////////////////////////栈定义、数据定义///////////////////////////////
STACKS SEGMENT STACK
      DW 256 DUP(?);申请栈空间
TOS   DW 0;栈空间标号
STACKS ENDS

DATA  SEGMENT
FOURKEYS DW 20H,30h,07H,12H,07H,20H,30h,1BH,12H,07H,20H,30h,2FH,12H,07H,20H,30h,43H,12H,07H    ;用于绘制模式一，界面下方的四个小方块的参数
		 DW 20H,30h,07H,13H,07H,20H,30h,1BH,13H,07H,20H,30h,2FH,13H,07H,20H,30h,43H,13H,07H,00H;共有8组参数（每个小方块竖直方向占有两行），传入SHOWS子函数绘制四个小方块

MAINMENU DW 0
CHOOSEMENU	DB  '         1.Easy',0Dh,0Ah             ;模式一中的难度选择菜单（提示语）
		 	DB  '         2.Middle',0Dh,0Ah
			DB  '         3.Hard',0Dh,0Ah
		 	DB  '         Please choose:',0Dh,0Ah,'$'

DIFFICULTY  DW  ?  ;用于存储难度等级的变量（控制方块下落速度的变量）  
SCORE DW 0         ;用于存储分数的变量
KEY_FREQ1  DW  175,196,221,248,262,294,330,350,393,441,495,525,589,661,700,786      ;C调从降4到升5这16个音的频率，下同	   	     	   
KEY_FREQ2  DW  196,221,248,278,294,330,371,393,441,495,556,589,661,742,786,882      ;D调
KEY_FREQ3  DW  221,248,278,312,330,371,416,441,495,556,624,661,742,833,882,990      ;E调
KEY_FREQ4  DW  234,262,294,330,350,393,441,467,525,589,661,700,786,882,935,1049     ;F调
KEY_FREQ5  DW  262,294,330,371,393,441,495,525,589,661,742,786,882,990,1049,1178    ;G调
KEY_FREQ6  DW  294,330,371,416,441,495,556,589,661,742,833,882,990,1112,1178,1322   ;A调
KEY_FREQ7  DW  330,371,416,467,495,556,624,661,742,833,935,990,1112,1248,1322,1484  ;B调
DTABLE DB   3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH;数码管0-9对应的键值表，7段数码管对应的段位值

;“每一笔”是按行画出的，以下所有的x坐标、y坐标和长度相对应，对应为“每一笔”的起始x坐标、y坐标、长度
;以下数据中，含pos_x的为起始x坐标，含pos_y的为起始y坐标，含len的为每行长度，不再一一标识
main_pos_y DW 0,1,2,3,4,5,6,7,8,9,10,11,12,13;主界面
keywh_pos_y DW 14,15,16,17,18,19,20,21,22,23,24;主界面键盘白键

keybl_pos_x DW 3,9,15,27,33,45,51,63,69,75;主界面键盘黑键
keybl_pos_y DW 14,15,16,17,18,19,20
keybl_len   DW 2,2,2,2,2,2,2
prompt db '--------welcome--------',0dh,0ah;模式2选择音调界面的提示语
    db 'press-1-tune c',0dh,0ah
    db 'press-2-tune d',0dh,0ah
    db 'press-3-tune e',0dh,0ah
    db 'press-4-tune f',0dh,0ah
    db 'press-5-tune g',0dh,0ah
    db 'press-6-tune a',0dh,0ah
    db 'press-7-tune b',0dh,0ah,'$'

string DB 'Press-1','rhythm','play'   ;主界面提示语
            DB	'Press-2','freely','play'
            DB 'Press-3','fun','play'
            DB 'ESC-exit'
            DB 'By','C.X.','S.H.N.','C.M.','S.H.'
            
string_pos_x DW 18,19,20,21,22,23,24,18,19,20,21,22,23,19,20,21,22  ;提示语的x坐标位置
                  DW 36,37,38,39,40,41,42,36,37,38,39,40,41,37,38,39,40
                  DW 54,55,56,57,58,59,60,55,56,57,55,56,57,58
                  DW 70,71,72,73,74,75,76,77
                  DW 3,4,8,9,10,11,15,16,17,18,19,20,24,25,26,27,31,32,33,34 ;提示语的y坐标位置
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
p_pos_x DW 12,12,12,12,18,18,12,12,12,12,12,12,12,12 ;主界面字母P
p_pos_y DW 1,2,3,4,3,4,5,6,7,8,9,10,11,12
p_len   DW 8,8,2,2,2,2,8,8,2,2,2,2,2,2

i_pos_x DW 24,24,27,27,27,27,27,27,27,27,24,24;主界面字母I
i_pos_y dw 1,2,3,4,5,6,7,8,9,10,11,12
i_len   dw 8,8,2,2,2,2,2,2,2,2,8,8

a_pos_x dw 39,38,37,36,41,36,42,36,42,36,36,36,42,36,42,36,42,36,42;主界面字母A
a_pos_y dw 1,2,3,4,4,5,5,6,6,7,8,9,9,10,10,11,11,12,12
a_len   dw 2,4,6,3,3,2,2,2,2,8,8,2,2,2,2,2,2,2,2

n_pos_x dw 48,54,48,54,48,54,48,54,48,54,48,54,48,51,48,52,48,52,48,53,48,53,48,54;主界面字母N
n_pos_y dw 1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12
n_len   dw 2,2,3,2,3,2,4,2,4,2,5,2,2,5,2,4,2,4,2,3,2,3,2,2

o_pos_x dw 60,60,60,66,60,66,60,66,60,66,60,66,60,66,60,66,60,66,60,60;主界面字母O
o_pos_y dw 1,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,12
o_len   dw 8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,8,8
;GAME2数据
main2_pos_y DW 0,1,2,3,4,5,6,7,8,9,10,11;主界面蓝色背景
keywh2_pos_y DW 12,13,14,15,16,17,18,19,20,21,22,23,24;主界面键盘白键

keyblc_pos_x dw 4,9,14,24,29,39,44,49,59,64,74;C调黑键
keybld_pos_x dw 4,9,19,24,34,39,44,54,59,69,74;D调黑键
keyble_pos_x dw 4,14,19,29,34,39,49,54,64,69,74;E调黑键
keyblf_pos_x dw 9,14,24,29,34,44,49,59,64,69;F调黑键
keyblg_pos_x dw 4,9,19,24,29,39,44,54,59,64,74;G调黑键
keybla_pos_x dw 4,14,19,24,34,39,49,54,59,69,74;A调黑键
keyblb_pos_x dw 9,14,19,29,34,44,49,54,64,69;B调黑键

keybl_pos_y2 dw 12,13,14,15,16,17,18,19;模式2黑键

t_pos_x dw 4,6,6,6,6;模式2界面字母T
t_pos_y dw 1,2,3,4,5
t_len dw 5,1,1,1,1

u_pos_x dw 10,13,10,13,10,13,10,13,10;模式2界面字母U
u_pos_y dw 1,1,2,2,3,3,4,4,5
u_len dw 1,1,1,1,1,1,1,1,4

n2_pos_x dw 15,18,15,18,15,15,17,15,18;模式2界面字母N
n2_pos_y dw 1,1,2,2,3,4,4,5,5
n2_len dw 1,1,2,1,4,1,2,1,1

e1_pos_x dw 20,20,20,20,20;模式2界面第一个字母E
e2_pos_x dw 27,27,27,27,27;模式2界面第二个字母E
e_pos_y dw 1,2,3,4,5
e_len dw 4,1,4,1,4

point_pos_x dw 25,25;模式2界面两个点
point_pos_y dw 2,4;
point_len dw 1,1;

a2_pos_x dw 28,27,30,27,27,30,27,30;模式2界面调号A
a2_pos_y dw 1,2,2,3,4,4,5,5;
a2_len dw 2,1,1,4,1,1,1,1;

b_pos_x dw 27,27,29,27,27,30,27;模式2界面调号B
b_pos_y dw 1,2,2,3,4,4,5;
b_len dw 3,1,1,4,1,1,4;

c_pos_x dw 27,27,27,27,27;模式2界面调号C
c_pos_y dw 1,2,3,4,5;
c_len dw 4,1,1,1,4;

d_pos_x dw 27,27,30,27,30,27,30,27;模式2界面调号D
d_pos_y dw 1,2,2,3,3,4,4,5;
d_len dw 3,1,1,1,1,1,1,3;

f_pos_x dw 27,27,27,27,27;模式2界面调号F
f_pos_y dw 1,2,3,4,5;
f_len dw 4,1,4,1,1;

g_pos_x dw 27,27,27,29,27,30,27;模式2界面调号G
g_pos_y dw 1,2,3,3,4,4,5;
g_len dw 4,1,1,2,1,1,4;

p2_pos_x dw 40,40,43,40,40,40;模式2界面字母P
p2_pos_y dw 1,2,2,3,4,5;
p2_len dw 4,1,1,4,1,1;

i2_pos_x dw 45,47,47,47,45;模式2界面字母I
i2_pos_y dw 1,2,3,4,5;
i2_len dw 5,1,1,1,5;

a3_pos_x dw 52,51,54,51,51,54,51,54;模式2界面字母A
a3_pos_y dw 1,2,2,3,4,4,5,5;
a3_len dw 2,1,1,4,1,1,1,1;

n3_pos_x dw 56,59,56,59,56,56,58,56,59;模式2界面字母N
n3_pos_y dw 1,1,2,2,3,4,4,5,5;
n3_len dw 1,1,2,1,4,1,2,1,1;

o2_pos_x dw 61,61,64,61,64,61,64,61;模式2界面字母O
o2_pos_y dw 1,2,2,3,3,4,4,5;
o2_len dw 4,1,1,1,1,1,1,4;

symbol_char db '4.5.6.7.1234567.1.2.3.4.5';模式2界面简谱音符标识字符
symbol_pos_x dw 1,1,6,6,11,11,16,16,21,26,31,36,41,46,51,56,56,61,61,66,66,71,71,76,76;
symbol_pos_y dw 10,11,10,11,10,11,10,11,10,10,10,10,10,10,10,9,10,9,10,9,10,9,10,9,10;

esc_char db 'ESC-exit';模式2界面退出标识字符
esc_pos_x dw 67,68,69,70,71,72,73,74;
esc_pos_y dw 3,3,3,3,3,3,3,3;

pos_y dw 20,21,22,23,24;琴键闪烁（变红）方块

;风扇界面数据
main3_pos_y DW 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24;风扇界面蓝色背景
fanr_pos_x dw 7,6,7,7,8,8;风扇界面红色扇叶绘画数据
fanr_pos_y dw 2,3,4,5,6,7
fanr_len dw 4,6,4,3,2,1

fanwh_pos_x dw 8,8;风扇界面白色中心点绘画数据
fanwh_pos_y dw 8,9
fanwh_len dw 2,2

fany_pos_x dw 14,12,10,11,13,15;风扇界面黄色扇叶绘画数据
fany_pos_y dw 6,7,8,9,10,11
fany_len dw 1,4,6,5,3,1

fanb_pos_x dw 9,8,8,7,6,7;风扇界面蓝色扇叶绘画数据
fanb_pos_y dw 10,11,12,13,14,15
fanb_len dw 1,2,3,4,6,4

fang_pos_x dw 3,2,2,2,2,3;风扇界面绿色扇叶绘画数据
fang_pos_y dw 6,7,8,9,10,11
fang_len dw 1,3,5,6,4,1

f03_pos_x dw 20,20,20,20,20,20;风扇界面字母F绘画数据
f03_pos_y dw 2,3,4,5,6,7
f03_len dw 4,1,4,1,1,1

a03_pos_x dw 27,26,26,29,26,26,29,26,29;风扇界面字母A（FAN)绘画数据
a03_pos_y dw 2,3,4,4,5,6,6,7,7
a03_len dw 2,4,1,1,4,1,1,1,1

n03_pos_x dw 32,35,32,35,32,35,32,34,32,34,32,35;风扇界面字母N绘画数据
n03_pos_y dw 2,2,3,3,4,4,5,5,6,6,7,7
n03_len dw 1,1,2,1,2,1,1,2,1,2,1,1

p03_pos_x dw 20,20,23,20,20,20,20;风扇界面字母P绘画数据
p03_pos_y dw 10,11,11,12,13,14,15
p03_len dw 4,1,1,4,1,1,1

l03_pos_x dw 26,26,26,26,26,26;风扇界面字母L绘画数据
l03_pos_y dw 10,11,12,13,14,15
l03_len dw 1,1,1,1,1,4

a04_pos_x dw 33,32,32,35,32,32,35,32,35;风扇界面字母A（PLAY)绘画数据
a04_pos_y dw 10,11,12,12,13,14,14,15,15

y03_pos_x dw 38,41,38,41,38,39,39,39;风扇界面字母Y绘画数据
y03_pos_y dw 10,10,11,11,12,13,14,15
y03_len dw 1,1,1,1,4,2,2,2

frame_pos_x dw 48,48,48,76,48,76,48,76,48,76,48,48;风扇界面显示边框绘画数据
frame_pos_y dw 4,5,6,6,7,7,8,8,9,9,10,11
frame_len dw 30,30,2,2,2,2,2,2,2,2,30,30

up_pos_x dw 57,56,55,54,57,57,57,57,57;风扇界面上箭头绘画数据
updown_pos_y dw 14,15,16,17,18,19,20,21,22
up_len dw 1,3,5,7,1,1,1,1,1

down_pos_x dw 72,72,72,72,72,69,70,71,72;风扇界面下箭头绘画数据
down_len dw 1,1,1,1,1,7,5,3,1

lan1_pos_x dw 60,60,60;风扇界面增指示块、减指示块绘画数据
lan1_pos_y dw 20,21,22
lan_len dw 3,3,3
lan2_pos_x dw 67,67,67
lan2_pos_y dw 14,15,16

;风扇输出标识语绘画数据
output_pos_x dw 51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72
output_pos_y dw 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
output_str db 'Assumed Fan Speed:</s>'
		db 'Current Fan Speed:</s>'

CS_BAK   DW  ?                    ;保存INTR原中断处理程序入口段地址的变量
IP_BAK   DW  ?                    ;保存INTR原中断处理程序入口偏移地址的变量
IM_BAK   DB  ?,?                    ;保存INTR原中断屏蔽字的变量
CS_BAK1  DW  ?                    ;保存定时器0中断处理程序入口段地址的变量
IP_BAK1  DW  ?                    ;保存定时器0中断处理程序入口偏移地址的变量
IM_BAK1  DB  ?,?                    ;保存定时器0中断屏蔽字的变量
	      
TS       DB 20                    ;采样周期
SPEC     DW 55                    ;转速给定值   55
IBAND    DW 0060H                 ;积分分离值   96
KPP      DW 1060H                 ;比例系数     4192
KII      DW 0010H                 ;积分系数     16
KDD      DW 0020H                 ;微分系数     32

YK       DW 0000H                 ;控制量
CK       DB 00H                   ;反馈量
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
;////////////////////////主程序///////////////////////////////
CODE SEGMENT
     ASSUME  CS:CODE,DS:DATA,SS:STACKS

START: MOV  AX,DATA
       MOV  DS,AX
       MOV  AX,0B800H;文本模式下的显存的段地址（即起始地址）
       MOV  ES,AX;本程序是通过直接往显存内写入内容，来达到显示的目的的
       MOV  AX,STACKS
       MOV  SS,AX
       MOV  SP, Offset TOS
       MOV  DX,MY8255_MODE;设置8255的模式         
       MOV  AL,81H;方式0，A口、B口均为输出，C口低四位输入，高4位输出
       OUT  DX,AL

;主界面绘画
    LEA BX,main_pos_y;获取偏移地址
    MOV CX,14;循环次数，在这里指要画多少笔
MAIN1_DRAW:
	DRAW2 20H,03EH,01h,BX,80;调用宏定义2,03EH为浅蓝色
	ADD BX,2;偏移地址增2，指向下一个数据
	LOOP MAIN1_DRAW;循环
	;以下程序段与上面的形式基本相似，不再重复注解
	LEA BX,p_pos_x
	LEA SI,p_pos_y
	LEA DI,p_len
	MOV CX,14
P_DRAW:;画主界面P字母，4E为红色
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP P_DRAW
	
	LEA BX,i_pos_x
	LEA SI,i_pos_y
	LEA DI,i_len
	MOV CX,12
I_DRAW:;画主界面I字母，6E为黄色
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP I_DRAW
	
	LEA BX,a_pos_x
	LEA SI,a_pos_y
	LEA DI,a_len
	MOV CX,19
A_DRAW:;画主界面A字母，2E为绿色
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP A_DRAW
	
	LEA BX,n_pos_x
	LEA SI,n_pos_y
	LEA DI,n_len
	MOV CX,24
N_DRAW:;画主界面N字母，1E为蓝色
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP N_DRAW

	LEA BX,o_pos_x
	LEA SI,o_pos_y
	LEA DI,o_len
	MOV CX,20
O_DRAW:;画主界面O字母，5E为粉色
	DRAW1 20H,05EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP O_DRAW
	
	LEA BX,keywh_pos_y
    MOV CX,11
KEYWH_DRAW:;画主界面键盘白键
	DRAW2 20H,07EH,01h,BX,80
	ADD BX,2
	LOOP KEYWH_DRAW


	;画主界面键盘黑键
	LEA BX,keybl_pos_x
	MOV SI,0;外层循环控制
KEYBL_DRAW:
    MOV CX,7;内层循环次数，即每个黑键要画的笔数
    LEA DI,keybl_pos_y
KEYBL_DRAW1:	
	DRAW2 20H,00EH,[BX][SI],DI,2
	ADD DI,2
	LOOP KEYBL_DRAW1;内层循环
	ADD SI,2
	CMP SI,20 ;一共画10个黑键，到了就退出
	JNE KEYBL_DRAW;外层循环
	
	LEA BX,string
	LEA DI,string_pos_x
	LEA SI,string_pos_y
	MOV CX,76
STRING_DRAW:;画主界面标识
	DRAW3 BX,7EH,DI,SI,1
	ADD BX,1
	ADD DI,2
	ADD SI,2
	LOOP STRING_DRAW
   
PLAY1:   
	;游戏模式选择
	MOV AH,08H  ;等待键盘输入
	INT 21H
	CMP AL,31H  ;按下1去模式1：节奏大师
	JE GO1
	CMP AL,32H  ;按下2去模式2：钢琴弹奏
	JE TRAN3
	CMP AL,33H  ;按下3去模式3：电机控制
	JE TRAN2
	CMP AL,20H  ;按下空格去退出块
	JE ENDMAIN
	JMP PLAY1
	
ENDMAIN:;退出程序块
	MOV DX,MY8254_MODE          ;重置8254工作方式
    	MOV AL,10H
   	OUT DX,AL
	MOV AX,4C00h		   ;退出游戏
    	INT 21h
	        
TRAN2: JMP DIANJI;去电机程序块（模式2）
TRAN3: JMP PLAY2;去钢琴演奏程序块（模式3）
;游戏1程序块    
GO1:
	MOV AH,00H ;清屏
	MOV AL,03H
	INT 10H
	MOV SCORE,00H ;分数置零
	MOV DX,OFFSET CHOOSEMENU 	
	MOV AH,09H  ;输出选择难度的标识语
	INT 21H
	MOV AH,01H  
	INT 16H
	MOV AH,08H  ;AL接收键盘按键
	INT 21H

	CMP AL,31H  ;按下1简单模式
	JE EASY
	CMP AL,32H  ;按下2普通模式
	JE MIDDLE
	CMP AL,33H  ;按下3困难模式
	JE DIFFICULT
	CMP AL,1BH  ;按下退出回到主界面
	JE TRAN1
	JMP GO1
EASY:	
	MOV DIFFICULTY,255  ;设置难度（下落相对时间），下同
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
	INT 10H						  ;清屏
    MOV SI,OFFSET FREQ_LIST0      ;装入频率表起始地址
    MOV DI,OFFSET TIME_LIST0	  ;装入时间表
loopmove:						  ;模式一主循环
	MOV DX,MY8254_MODE            ;初始化8254工作方式
	MOV AL,36H                    ;定时器0、方式3
	OUT DX,AL
	MOV DX,0FH                    ;输入时钟为1.0416667MHz，1.0416667M = 0FE502H  
	MOV AX,0E502H                
	DIV WORD PTR [SI]             ;取出频率值计算计数初值，0F4240H / 输出频率  
	MOV DX,MY8254_COUNT0
	OUT DX,AL                     ;装入计数初值
	MOV AL,AH
	OUT DX,AL					  ;输出（发声）
	CALL DELAY				      ;延时，控制每次发声时间的长短
	MOV DX,MY8254_MODE            ;退出时设置8254为方式2，OUT0置0
	MOV AL,10H					  ;即消音
	OUT DX,AL
	ADD SI,2
	INC DI
	CMP WORD PTR [SI],0           ;判断是否到曲末？
	JE  PLAY
	CALL SCOREDIS                 ;调用数码管显示分数的子程序
	PUSH SCORE					  ;给下面调用子程序传参数（用栈传参）
	CALL SHOWSSCORE				  ;调用屏幕左上角显示分数的子程序
	CALL MOVE				      ;调用模式一的主子程序（包括绘制小方块与小方块的下落以及按键判断、加分等）
	PUSH CX						  ;疑似实验室运行环境存在问题，保护现场
	MOV AH,01H
	INT 16H						  
	CMP AL,1BH
	POP CX
	JNE loopmove				  ;判断ESC按键是否按下，未按下则继续循环，按下则回主界面
	JMP START					  
TRAN1: JMP START

;游戏2程序块
PLAY2:
	MOV AH,00H            ;清屏
	MOV AL,03H
	INT 10H
	MOV AH,09H
	MOV DX,OFFSET prompt  ;输出标识语
	INT 21H
    MOV AH,0CH			  ;清理键盘缓冲区
	INT 21H
	MOV AH,08H            ;等待输入
	INT 21H

	CMP AL,31H              ;按下1为C调
	JE C_JUMP
	CMP AL,32H		        ;按下2为D调
	JE D_JUMP
	CMP AL,33H				;按下3为E调
	JE E_JUMP
	CMP AL,34H				;按下4为F调
	JE F_JUMP
	CMP AL,35H				;按下5为G调
	JE G_JUMP
	CMP AL,36H				;按下6为A调
	JE A_JUMP
	CMP AL,37H				;按下7为B调
	JE B_JUMP
	CMP AL,1BH				;按下退出键退出至主界面
    JE TRAN1 	
	JMP PLAY2
C_JUMP: JMP FAR PTR TUNE_C
D_JUMP: JMP FAR PTR TUNE_D
E_JUMP: JMP FAR PTR TUNE_E
F_JUMP: JMP FAR PTR TUNE_F
G_JUMP: JMP FAR PTR TUNE_G
A_JUMP: JMP FAR PTR TUNE_A
B_JUMP: JMP FAR PTR TUNE_B

TUNE_C:;画C调界面
	MOV AH,00H
	MOV AL,03H
	INT 10H  
	CALL DRAW_ME2;画公共部分

	LEA BX,c_pos_x
	LEA SI,c_pos_y
	LEA DI,c_len
	MOV CX,5
 C_DRAW:;画调号C，红色
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP C_DRAW

	;用两层循环控制，画调号C黑键
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

	LEA BX,KEY_FREQ1;将C调对应频率表取出，准备发声
	JMP GO2


TUNE_D:;画调号D界面
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;画公共部分

	LEA BX,d_pos_x
	LEA SI,d_pos_y
	LEA DI,d_len
	MOV CX,8
 D_DRAW:;画调号D，黄色
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP D_DRAW

	;用两层循环控制，画调号D黑键
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

	LEA BX,KEY_FREQ2;将D调频率表取出准备发声
	JMP GO2

TUNE_E:;画调号E界面
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;画公共部分

	LEA BX,e2_pos_x
	LEA SI,e_pos_y
	LEA DI,e_len
	MOV CX,5
 E1_DRAW:;画调号E，绿色
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP E1_DRAW

    ;双层循环画调号E黑键
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


	LEA BX,KEY_FREQ3;将E调频率表取出准备发声
	JMP GO2
	
	
	
TUNE_F:;画调号F界面
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;画公共部分

	LEA BX,f_pos_x
	LEA SI,f_pos_y
	LEA DI,f_len
	MOV CX,5
 F_DRAW:;画调号F，蓝色
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP F_DRAW

	;双层循环控制画F调黑键
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
	
	LEA BX,KEY_FREQ4;取出F调频率表准备发声
	JMP GO2
	

TUNE_G:;画调号G界面
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;画公共部分

	LEA BX,g_pos_x
	LEA SI,g_pos_y
	LEA DI,g_len
	MOV CX,7
 G_DRAW:;画调号G，粉色
	DRAW1 20H,05EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP G_DRAW

	;双层循环控制画调号G黑键
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
	LEA BX,KEY_FREQ5;取出调号G频率表准备发声
	JMP GO2

TUNE_A:;画调号A界面
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;画公共部分

	LEA BX,a2_pos_x
	LEA SI,a2_pos_y
	LEA DI,a2_len
	MOV CX,8
 AA_DRAW:;画调号A，白色
	DRAW1 20H,07EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP AA_DRAW

	;双层循环控制画调号A黑键
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
	LEA BX,KEY_FREQ6;取出调号A频率表准备发声
	JMP GO2

TUNE_B:;画调号B界面
	MOV AH,00H
	MOV AL,03H
	INT 10H
	CALL DRAW_ME2;画公共部分

	LEA BX,b_pos_x
	LEA SI,b_pos_y
	LEA DI,b_len
	MOV CX,7
 B_DRAW:;画调号B，黑色
	DRAW1 20H,00EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP B_DRAW

	;双层循环控制画调号B黑键
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

	LEA BX,KEY_FREQ7;取出调号B频率表准备发声
	JMP GO2 
TRANS4:JMP PLAY2	
GO2:   
      MOV AL,00H
      MOV AH,0CH
      INT 21H     ; 清理键盘缓冲区
      MOV AH,01H
      INT 16H     
      MOV AH,08H
      INT 21H     ;AL接收按键
      CMP AL,1BH
      JE TRANS4   ;如果按下退出，回到选调界面
      PUSH BX     ;将相应调号频率表偏移地址入栈
      MOV AH,00H
      PUSH AX     ;将按下的按键ASCII号入栈
      CALL RING   ;不是按下退出，则进入发声部分
      JMP GO2     ;不断循环，判断按键摁下并发声

;游戏3电机控制程序块
DIANJI:
	  MOV DX,MY8254_MODE          ;将外置8254输出端置0
	  MOV AL,10H
	  OUT DX,AL
	  
	  MOV AH,00H		    ;设置显示方式
	  MOV AL,03H
	  INT 10H
        
      	  CALL DRAW_MENU3	    ;绘制电机初始界面
	
	  STI			    ;打开终端屏蔽位
	  CALL ZHILIU		    ;直流控制子程序 
  	  CLI
  	  JMP START


;/////////////////////////子程序//////////////////////////  	  
ZHILIU PROC
       PUSH AX			;保护现场 
       PUSH BX
       PUSH CX
       PUSH DX
    
       MOV  AX,DATA
       MOV  DS,AX  
       
       MOV  AX,SPEC                  	;将给定值输出给专用界面显示
       MOV  DI,0D80H
       CALL SEND
       
       MOV  AX,SPEC                 
       CALL SHOWSPEED_ASSUMED
 
    
       CLI
       MOV  AX,0000H
       MOV  ES,AX
    
       MOV  DI,0020H                  
       MOV  AX,ES:[DI]               
       MOV  IP_BAK1,AX             ;保存定时器0中断处理程序入口偏移地址
       MOV  AX,OFFSET TIMERISR      
       MOV  ES:[DI],AX             ;设置实验定时中断处理程序入口偏移地址
       ADD  DI,2
       MOV  AX,ES:[DI]             
       MOV  CS_BAK1,AX             ;保存定时器0中断处理程序入口段地址
       MOV  AX,SEG TIMERISR
       MOV  ES:[DI],AX             ;设置实验定时中断处理程序入口段地址
    
       IN   AL,21H
       MOV  IM_BAK1,AL             ;保存INTR原中断屏蔽字
       AND  AL,0F7H
       OUT  21H,AL                 ;打开定时器0中断屏蔽位
    
       MOV  DI,INTR_IVADD          
       MOV  AX,ES:[DI]
       MOV  IP_BAK,AX              ;保存INTR原中断处理程序入口偏移地址
       MOV  AX,OFFSET MYISR
       MOV  ES:[DI],AX             ;设置当前中断处理程序入口偏移地址
       ADD  DI,2
       MOV  AX,ES:[DI]
       MOV  CS_BAK,AX              ;保存INTR原中断处理程序入口段地址
       MOV  AX,SEG MYISR
       MOV  ES:[DI],AX             ;设置当前中断处理程序入口段地址
      
       IN   AL,21H
       MOV  IM_BAK,AL              ;保存INTR原中断屏蔽字
       AND  AL,7FH
       OUT  21H,AL                  ;打开INTR的中断屏蔽位
                                    
       MOV  AL,81H                 ;初始化8255
       MOV  DX,MY8255_MODE         ;工作方式0，A口，B口，C口均输出
       OUT  DX,AL
       MOV  AL,00H
       MOV  DX,MY8255_C            ;C口高4位输出0，电机不转
       OUT  DX,AL
    
       MOV  DX,PC8254_MODE         ;初始化PC机定时器0，定时1ms
       MOV  AL,36H                 ;计数器0，方式3
       OUT  DX,AL
       MOV  DX,PC8254_COUNT0
       MOV  AL,8FH                 ;低8位
       OUT  DX,AL
       MOV  AL,04H
       OUT  DX,AL                  ;高8位,048FH=1168
    
       STI					;

SAMPLE:			;主采样程序
       MOV  AL,TS                     ;TS=20 TC=0
	   SUB  AL,TC
	   JNC  SAMPLE              ;没到采样周期则继续循环
	
	MOV  TC,00H                 ;采样周期到，将采样周期变量清0
	MOV  AL,ZVV
	MOV  AH,00H
	MOV  YK,AX                  ;得到反馈量YK 
	CALL PID                       ;调用PID子程序，得到控制量CK
	MOV  AL,CK                  ;把控制量转化成PWM输出
	SUB  AL,80H         
	JC   IS0                           ;AL<80H转ISO
	MOV  AAAA,AL
	JMP  COU
IS0:   
	MOV  AL,10H                 ;电机的启动值不能低于10H
    	MOV  AAAA,AL   
COU:   
	   MOV  AL,7FH
	   SUB  AL,AAAA
	   MOV  BBB,AL
	
	   MOV  AX,YK                  ;将反馈值YK送到屏幕显示
	   CALL SHOWSPEED_CURRENT
	
	   MOV  AX,YK                  ;将反馈值YK输出给专用界面显示
       	   MOV  DI,0D81H
       	   CALL SEND 
       
          	   MOV  AL,CK                  ;将控制量CK输出给专用界面显示
         	   MOV  DI,0D82H
       	   CALL SEND
                        

   	   CALL DALLY2
	   CALL CCSCAN			;扫描实验箱键盘，是否有键按下
                   JZ   RESET			;无按键则跳过读取按键
	   CALL KEYBOARD			;有按键则判断按键AL的值
	   CMP AL,10H			
	   JE  RESET
	   CMP AL,0CH			;AL为0CH，则加速
	   JE  INSPEED
	   CMP AL,0DH			;AL为0DH，则减速
	   JE  DESPEED
	   
RESET:
	   MOV  AH,1			;判断电脑键盘是否有按键按下
    	   INT  16H
   	   JZ   SAMPLE			;无按键则继续电机控制
       
  	   PUSH AX
    	   MOV  AH,0CH      		
    	   INT  21H
   	   POP  AX
    
       	   CMP  AL,1BH          		;按键为Esc则退出电机控制
    	   JZ   EXIT
    	   JMP  SAMPLE   
    
INSPEED:
    MOV AX,SPEC
    ADD AX,3			;电机给定转速+3
    MOV SPEC,AX

    MOV CX,60
    CALL LIGHT_UP_RED 
    CALL SHOWSPEED_ASSUMED	;改变屏幕显示值
    CALL delay
    CALL delay
    MOV CX,60
    CALL LIGHT_UP_BLACK 

	JMP RESET
DESPEED:
    MOV AX,SPEC			;电机给定转速-3
    SUB AX,3
    MOV SPEC,AX

    MOV CX,67
    CALL LIGHT_DOWN_RED
    CALL SHOWSPEED_ASSUMED	;改变屏幕显示值
    CALL delay
    CALL delay
    MOV CX,67
    CALL LIGHT_DOWN_BLACK

    JMP RESET
	 	
EXIT:  
    CLI
    MOV  AL,00H                 ;退出时停止电机运转
    MOV  DX,MY8255_C
    OUT  DX,AL
    
    MOV  DX,PC8254_MODE         ;恢复PC机定时器0状态
    MOV  AL,36H
    OUT  DX,AL
    MOV  DX,PC8254_COUNT0       ;计数器0，方式3，计算初值设为0
    MOV  AL,00H
    OUT  DX,AL
    MOV  AL,00H
    OUT  DX,AL 
    
    MOV  AX,0000H               ;恢复INTR原中断矢量
    MOV  ES,AX
    MOV  DI,INTR_IVADD  
    MOV  AX,IP_BAK              ;恢复INTR原中断处理程序入口偏移地址
    MOV  ES:[DI],AX
    ADD  DI,2
    MOV  AX,CS_BAK              ;恢复INTR原中断处理程序入口段地址
    MOV  ES:[DI],AX
              
    MOV  AL,IM_BAK              ;恢复INTR原中断屏蔽寄存器的屏蔽字
    OUT  21H,AL
        
    MOV  DI,0020H                
    MOV  AX,IP_BAK1             ;恢复定时器0中断处理程序入口偏移地址     
    MOV  ES:[DI],AX             
    ADD  DI,2
    MOV  AX,CS_BAK1             ;恢复定时器0中断处理程序入口段地址
    MOV  ES:[DI],AX
    
    MOV  AL,IM_BAK1
    OUT  21H,AL                 ;恢复屏蔽字
            
    STI
    
    POP DX
	POP CX		;返回现场
	POP BX
	POP AX
    RET    
ZHILIU ENDP
       
MYISR PROC                    ;系统总线INTR中断处理程序，电机每转一圈触发一次脉冲
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	MOV  AX,DATA
	MOV  DS,AX
	  
	MOV  AL,MARK  
	CMP  AL,01H                   ;当MARK=AL=01H时，跳到IN1计算转速
	JZ   IN1
	
	MOV  MARK,01H                 ;否则令MARK=01H，收到一次脉冲信号，MARK0置1，等下一次脉冲，计算转速。
	JMP  IN2

IN1:
	MOV  MARK,00H               ;计算转速
VV:    
	MOV  DX,0000H
	MOV  AX,03E8H
	MOV  CX,VADD
	CMP  CX,0000H               ;判断VADD是否等于0
	JZ   MM1     
	DIV  CX                     ;DXAX/VADD即1000/VADD=AX...DX
MM:    
	MOV  ZV,AL
    MOV  VADD,0000H     
MM1:   
	MOV  AL,ZV
    MOV  ZVV,AL

IN2:   
	MOV  AL,20H                 ;向PC机内部8259发送中断结束命令
	OUT  20H,AL
	POP  DX
	POP  CX
	POP  BX
	POP  AX
	IRET
MYISR ENDP

TIMERISR PROC                 ;PC机定时器0中断处理程序
	PUSH AX
	PUSH BX                     
	PUSH CX
	PUSH DX
	MOV  AX,DATA
	MOV  DS,AX
	
	INC  TC                     ;采样周期变量加1
	CALL KJ
	CLC
	      
NEXT2:  
	CLC                         ;清除标志位寄存器
	CMP  MARK,01H
	JC   TT1
	
	INC  VADD
	CMP  VADD,0700H             ;转速值溢出，赋极值
	JC   TT1
	
	MOV  VADD,0700H
	MOV  MARK,00H
TT1:   
	MOV  AL,20H                 ;中断结束，发EOI命令
	OUT  20H,AL
	POP  DX
	POP  CX
	POP  BX
	POP  AX
	IRET
TIMERISR ENDP

KJ PROC                       ;PWM子程序
	PUSH AX
	PUSH DX
	CMP  FPWM,01H               ;PWM为1，产生PWM的高电平
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
	MOV  AL, 10H                ;PB0=1 电机转动
	MOV  DX, MY8255_C
	OUT  DX,AL

TEST2: 
	CMP  FPWM,02H               ;PWM为2，产生PWM的低电平
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
	MOV  AL,00H                 ;PB0=0 电机停止
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
	MOV  AX,SPEC                ;PID子程序
	SUB  AX,YK                      ;求偏差EK
	MOV  R0,AX
	MOV  R1,AX 
	SUB  AX,EK_1
	MOV  R2,AX
	SUB  AX,AEK_1               ;求BEK
	MOV  BEK,AX
	MOV  R8,AX
	MOV  AX,R1                  ;求偏差变化量AEK
	MOV  EK_1,AX
	MOV  AX,R2
	MOV  AEK_1,AX
	TEST R1,8000H
	JZ   EK1                    ;若偏差EK为正数，则不需要求补码
	NEG  R1                     ;若偏差EK为负数，则求偏差EK的补码
EK1:   
	MOV  AX,R1                  ;判断偏差EK是否在积分分离值的范围内    实际速度小于目标速度
	SUB  AX,IBAND
	JC   II                     ;在积分分离值范围内，则跳转到II，计算积分项
	MOV  R3,00H                 ;若不在积分分离值范围内，则将积分项清0
	JMP  DDD                    ;计算微分项
II:    
	MOV  AL,TS                  ;计算积分项，结果放在R3变量中(R3=EK*TS/KII)
	MOV  AH,00H                 ;其中TS和KII均为正数，所以R3的正负由EK决定
	MOV  CX,R1
	MUL  CX
	MOV  CX,KII
	DIV  CX
	MOV  R3,AX
	TEST R0,8000H               ;判断积分项的正负
	JZ   DDD                    ;为正数，则跳转去计算微分项
	NEG  R3                     ;为负数，则将积分项的结果求补码
DDD:   
	TEST BEK,8000H              ;判断BEK的正负
	JZ   DDD1                   ;为正数，则BEK不变
	NEG  BEK                    ;为负数，则求BEK的补码
DDD1:  
	MOV  AX,BEK                 ;计算微分项(R4=KDD*BEK/8TS)
	MOV  CX,KDD
	MUL  CX
	PUSH AX
	PUSH DX
	MOV  AL,TS
	MOV  AH,00H                 ;将微分项缩小8倍，防止溢出
	MOV  CX,0008H
	MUL  CX
	MOV  CX,AX
	POP  DX
	POP  AX
	DIV  CX
	MOV  R4,AX
	TEST R8,8000H               ;判断微分项的正负
	JZ   DD1                    ;为正数，则结果不需要求补码
	NEG  R4                     ;为负数，则微分项结果R4求补码
DD1:   
	MOV  AX,R3                  ;积分项和微分项相加，结果放在R5变量中
	ADD  AX,R4
	MOV  R5,AX
	JO   L9                     ;判断溢出
L2:    
	MOV  AX,R5
	ADD  AX,R2
	MOV  R6,AX                  ;R6=R5+R2=积分项+微分项+AEK
	JO   L3 
L5:    
	MOV  AX,R6                  ;计算KPP*R6
	MOV  CX,KPP
	IMUL CX
	MOV  CX,1000H
	IDIV CX
	MOV  CX,AX
	RCL  AH,01H                 ;判断溢出，溢出赋极值 
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
	TEST R7,80H                 ;CK溢出处理程序
	JNZ  L17
	MOV  AL,7FH                 ;若为正溢出，则赋给正极值7FH
	JMP  L18
L17:   
	MOV  AL,80H                 ;若为负溢出，则赋给赋极值80H
    JMP  L18                
L9:    
	TEST R3,8000H
	JNZ  L1
	MOV  R5,7FFFH               ;若为正溢出，则赋给正极值7FFFH
	JMP  L2
L1:    
	MOV  R5,8000H               ;若为负溢出，则赋给负极值8000H
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
       PUSH BX                     ;完成变量输出到专用图形界面显示
       MOV BX,0D800H
       MOV ES,BX             
       MOV ES:[DI],AX 
       POP  BX      
       RET  
SEND ENDP

MOVE PROC NEAR;模式一主要的子函数（包括绘制小方块与小方块的下落以及按键判断、加分等）
    PUSH BP
    MOV BP, SP
	PUSH AX
	PUSH BX
	PUSH CX
GENERATE:
	CALL DRAWMAP;每执行一次，依次刷新下方的四个按键
	MOV AH,0CH
	MOV AL, 00h
 	INT 21h;清空键盘缓冲区
	MOV AL,0
	MOV BX,0
	CALL randByBX;产生0~3的随机数，并存入BX
	PUSH BX;存入下落的小方块的初始X坐标
	MOV CX,0
	PUSH CX;存入下落的小方块的初始Y坐标
DROP:
	PUSH BX;存入下落的小方块的当前的X坐标（给下面调用子函数传参数）
	PUSH CX;存入下落的小方块的当前的Y坐标（给下面调用子函数传参数）
	CALL NOTES;调用绘制小方块的子程序,绘制小方块
    MOV DL,BYTE PTR DIFFICULTY;取出相对延迟时间（难度），调用延时子程序 
    CALL delaymusic
	PUSH BX;存入下落的小方块的当前的X坐标（给下面调用子函数传参数）
	PUSH CX;存入下落的小方块的当前的Y坐标（给下面调用子函数传参数）
	CALL DELETENOTES;清除刚才显示的位置的字符
	INC CX;将纵坐标加1
	CMP CX,16;判断纵坐标Y是否到了下方四个小方块的位置
	JAE UPDATE;若到了，则跳入UPDATE，若未到，则继续向下执行
	PUSH CX;疑似实验室运行环境存在问题，保护现场
	MOV AX,0100H
	INT 16H;判断有无按键按下
	POP CX
	CALL KEYBOARD;扫描试验箱键盘
	CMP AL,10H
	JNE GENERATE;判断是否有提前按下按键，若按下则跳回GENERATE（即重新生成小方块），未按下则跳回drop（图形继续下落）
	JMP DROP
UPDATE:;
	CMP CX,21;判断纵坐标是否超过下方四个小方块的位置
	JAE BYOND2;若超过则跳到BYOND2（即忽视按键），未超过则继续执行
	CALL KEYBOARD
	CMP AL,10H
	JZ BYOND2;没有按键按下则跳到BYOND2，有按键按下则向下执行
	;PUSH CX;疑似实验室运行环境存在问题，保护现场
	;MOV AH,01H
	;INT 16H;判断是否有按键按下
	;POP CX
	;MOV AH, 00h;
 	;INT 16h
	;MOV AH,0bH
	;MOV AL,00H
	;INT 21H
	;MOV AH,08H
	;INT 21H
	;判断下落的图形的横坐标的位置，并跳到指定的位置
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
	CMP AL,0CH;判断按键是否为1
	JE WIN;若是，则跳到win
	JMP BYOND2;否则，跳到BYOND2，以下几个CHECK类似
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
WIN:;即成功按键
	ADD SCORE,2;加分
	CALL DRAWMAP;刷新下方四个小方块
	JMP BYOND1;然后跳到BYOND1，结束当前子程序的执行
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

SHOWSSCORE PROC NEAR;显示分数在电脑屏幕左上角	  
	PUSH BP
	MOV BP,SP
	SUB SP,2
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI	  
	MOV WORD Ptr [BP-2],00H;提前存放显示时间的横坐标
	MOV AX, [BP+4];取出提前压入的分数
	MOV CX, 0;用来记录SCORE为几位数
	MOV BX, 10;作除数
	OR AX, AX;判断是不是正数
	JNS SHOWSRep1
	;负数:
	NEG AX;若是负数，则求补码
	PUSH AX;重新压入栈  
	MOV DI,[BP-2]
	ADD DI,DI
	SUB DI,1
	ADD DI,0A0H
	MOV AH,'-'
	MOV AL,07H
	MOV ES:[DI],AX;显存中指定位置（左上角）直接写入‘-’
	ADD Byte Ptr [BP-2],1
	POP AX
	MOV CX,0
SHOWSRep1: 
	MOV DX, 0;存余数
	DIV BX;AX内的分数除以10,余数存在DX中
	ADD DX, '0';将数字转换成ASCII码
	PUSH DX;将每一位由低位到高位依次压入栈中
	INC CX;计算分数的位数
	OR AX, AX
	JNZ SHOWSRep1  
SHOWSRep2: ;将压入栈中的每一位数字，逐个写入显存，显示在屏幕上
	POP DX
	MOV [BP-4],DL
	MOV DI,[BP-2]
	ADD DI,DI
	SUB DI,1
	ADD DI,0A0H;上面几行直到该行均是在确定要显示的位置
	MOV AH,[BP-4]
	MOV AL,07H
	MOV ES:[DI],AX
	ADD Byte Ptr [BP-2],1;分数显示的位置向左移一位
	LOOP SHOWSRep2;每一位数字循环显示
	MOV DI,[BP-2]
	ADD DI,DI
	SUB DI,1
	ADD DI,0A0H
	MOV AH,20H
	MOV AL,07H
	MOV ES:[DI],AX;显示空格覆盖多余的0
	POP DI      
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET 2
SHOWSSCORE ENDP

DELETENOTES PROC NEAR;用黑色覆盖下落的方块（原理与NOTES子程序一致，仅将字符属性改为00H）
				;调用方法：调用前依次压入：显示起始的X坐标、显示起始的Y坐标
    PUSH BP
    MOV BP, SP
	PUSH AX
	PUSH BX
	PUSH CX
	MOV CX,4
delNOTES:;按调用方法依次压入指定值，调用SHOWS子程序，在对应的位置上绘制一模一样的黑色方块覆盖原有方块
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
	MOV [BP+4],BX;通过BX寄存器自增Y坐标，再将值赋回[BP+4]
	LOOP delNOTES;循环逐行绘制
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET 4
DELETENOTES ENDP

;功能：重复绘制指定的字符（可指定长度与字符属性）
SHOWS PROC NEAR
;调用前依次压入:
;需要显示的字符（ASCII码）、字符属性、显示起始的x坐标、显示起始的y坐标、显示的长度
      PUSH BP
      MOV BP, SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	MOV AL,[BP+6];取出压入的y坐标
	MOV BL,160
	MUL BL
	MOV DI,[BP+8];取出压入的x坐标
	ADD DI,DI;相当于将DI*2
	SUB DI,1
	ADD DI,AX 
	MOV CX,[BP+4];取出压入的长度
	MOV AH,[BP+12];取出压入的需要显示的字符
	MOV AL,[BP+10];取出压入的需要字符属性
DIS:
	MOV ES:[DI],AX;写入对应的显存当中
	ADD DI,2
	LOOP DIS;横坐标递增，循环显示同样属性的字符
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
	MOV SP,BP
      POP BP
	RET 10
SHOWS ENDP

NOTES PROC NEAR;绘制下落的方块
				;调用方法：调用前依次压入：显示起始的X坐标、显示起始的Y坐标
    PUSH BP
    MOV BP, SP
	PUSH AX
	PUSH BX
	PUSH CX
	MOV CX,4;设置下落方块的长度
DISNOTES:;按调用方法依次压入指定值，调用SHOWS子程序
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
	MOV BX,[BP+4];通过BX寄存器自增Y坐标，再将值赋回[BP+4]
	INC BX
	MOV [BP+4],BX
	LOOP DISNOTES;循环逐行绘制
	POP CX
	POP BX
	POP AX
	MOV SP,BP
	POP BP
	RET 4
NOTES ENDP

DRAWMAP PROC NEAR;绘制界面下方的四个按键
				;调用方法：直接调用
	PUSH SI
	PUSH AX
	LEA SI,FOURKEYS;取数据段用于绘制四个按键的数据的偏移地址
DISKEYS:
	MOV AX,[SI]
	PUSH AX;压入的需要显示的字符
	MOV AX,[SI+2]
	PUSH AX;压入的需要显示的字符属性
	MOV AX,[SI+4]
	PUSH AX;压入的X坐标
	MOV AX,[SI+6]
	PUSH AX;压入的Y坐标
	MOV AX,[SI+8]
	PUSH AX;压入的长度
	CALL SHOWS
	ADD SI,10;去数据段用于绘制四个按键的数据的偏移地址
	MOV AX,[SI]
	CMP AX,0;判断是否绘制完毕
	JNE DISKEYS;未绘制完则继续绘制，否则执行结束
	POP AX
	POP SI
DRAWMAP ENDP

;实验箱键盘读取子程序(第四行四个键为有效输入)
;功能：对实验箱按键进行扫描
;如无按键按下或无效按键按下返回值AL = 10H
;第四行按键按下由左往右依次返回AL = 0CH, 0DH, 0EH, 0FH     
KEYBOARD PROC
KEYSTART1:
       PUSH BX
       PUSH CX
       PUSH DX

KEYBEGIN1:
       MOV  DX,MY8255_MODE         ;初始化8255工作方式
       MOV  AL,81H                 ;方式0，A口、B口输出，C口低4位输入
       OUT  DX,AL
	   CALL CCSCAN                 ;扫描按键
	   JNZ  GETKEY1                ;有键按下则跳至GETKEY1
	   JMP  RETURN1                ;无按键按下则调用RETURN1返回

GETKEY11:
	   CALL CCSCAN                 ;再次扫描按键
	   JNZ  GETKEY2                ;有按键按下则跳至GETKEY2
	   JMP  KEYBEGIN               ;否则跳回开始继续循环

GETKEY21:
       MOV  CH,0FEH                ;从第一列开始扫描
	   MOV  CL,00H                 ;设置当前检测的是第几列，0表示第一列

COLUM1: 
       MOV  AL,CH                  ;选取一列，将X1~X4中某一个置零
       MOV  DX,MY8255_A 
	   OUT  DX,AL
       MOV  DX,MY8255_C            ;读Y1~Y4，用于判断是哪一行按键闭合
	   IN   AL,DX
    
       TEST AL,08H                 ;当前仅当按键为第四行且列数与检测列数相同时才能选通，此时AL = 07H
       JNZ  NEXT                   ;未选通则跳至NEXT，选通则顺序执行
       MOV  AL,0CH                 ;设置第4行第1列的对应的键值，进行初始化
       ADD  AL,CL                  ;将第1列的值加上当前选通的列数，确定按键值
	   PUSH AX
	   
KON1:   
       CALL CCSCAN                 ;扫描按键，用于判断按键是否弹起
	   JNZ  KON                    ;未弹起则继续循环等待弹起
	   JMP  RETURN2                ;调用RETURN2返回

NEXT1:  
       INC  CL                     ;当前检测的列数递增
	   MOV  AL,CH
	   TEST AL,08H                 ;检测是否扫描到第4列
	   JZ   RETURN1                ;是则说明是无效按键按下，调用RETURN1进行返回
	
       ROL  AL,1                   ;未检测到第4列则准备进行右移检测下一列
	   MOV  CH,AL
	   JMP  COLUM

RETURN11:                           ;如果没有按键按下或按下的按键为无效按键则RETURN1返回，返回值AL = 10H
       MOV AL,10H
       POP DX
       POP CX
       POP BX
       RET
       
RETURN21:                           ;如果有效按键按下则RETURN2返回,返回值AL按照按键从左到右分别为0CH,0DH,0EH,0FH
       POP AX
       POP DX
       POP CX
       POP BX
       RET
       
KEYBOARD ENDP


KEYBOARD16 PROC                      ;读取键盘子程序(16按键版)
KEYSTART:
       PUSH BX
       PUSH CX
       PUSH DX

KEYBEGIN:
       MOV  DX,MY8255_MODE         ;初始化8255工作方式
       MOV  AL,81H                 ;方式0,A口、B口输入,C口低4位输入
       OUT  DX,AL
	   CALL CCSCAN                 ;扫描按键
	   JNZ  GETKEY1                ;有键按下则跳置GETKEY1  
	   JMP  RETURN1                ;没有按键按下则调用RETURN1返回

GETKEY1:
	   CALL CCSCAN                 ;再次扫描按键
	   JNZ  GETKEY2                ;有键按下则跳置GETKEY2
	   JMP  KEYBEGIN               ;否则跳回开始继续循环

GETKEY2:
       MOV  CH,0FEH                ;从第一列开始扫描
	   MOV  CL,00H                 ;设置当前检测的是第几列，0表示第一列

COLUM: 
       MOV  AL,CH                  ;选取一列，将X1～X4中一个置0            
       MOV  DX,MY8255_A 
	   OUT  DX,AL
       MOV  DX,MY8255_C            ;读Y1～Y4，用于判断是哪一行按键闭合 
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
       TEST AL,08H                 ;当且仅当按键为第四行且列数与检测列数相同才能选通，此时AL=07H
       JNZ  NEXT                   ;未选通则跳至NEXT,选通则顺序执行
       MOV  AL,0CH                 ;设置第4行第1列的对应的键值 

KCODE:
       ADD  AL,CL                  ;将第1列的值加上当前列数，确定按键值
	   PUSH AX
	   
KON:   
       CALL CCSCAN                 ;扫描按键，判断按键是否弹起
	   JNZ  KON                    ;未弹起则继续循环等待弹起
	   JMP  RETURN2                ;调用RETURN2返回

NEXT:  
       INC  CL                     ;当前检测的列数递增                    
	   MOV  AL,CH
	   TEST AL,08H                 ;检测是否扫描到第4列
	   JZ   RETURN1                ;是则调用RETURN1返回
	
       ROL  AL,1                   ;没检测到第4列则准备检测下一列
	   MOV  CH,AL
	   JMP  COLUM

RETURN1:                           ;如果没有按键按下或者按下按键无效则RETURN1返回,返回值AL=10H
       MOV AL,10H
       POP DX
       POP CX
       POP BX
       RET
       
RETURN2:                           ;如果有效按键按下则RETURN2返回,返回值AL为00H-0EH
       POP AX
       POP DX
       POP CX
       POP BX
       RET
       
KEYBOARD16 ENDP      

  
CCSCAN PROC NEAR                   ;扫描是否有按键闭合子程序
       PUSH AX
       PUSH DX
       
       MOV  AL,00H                              
       MOV  DX,MY8255_A            ;将4列全选通，X1～X4置0
	   OUT  DX,AL
       MOV  DX,MY8255_C 
       IN   AL,DX                  ;读Y1～Y4
	   NOT  AL
       AND  AL,0FH                 ;取出Y1～Y4的反值，无按键按下时AL=00H，标志位ZF=1
       
       POP DX
       POP AX	   
       RET
CCSCAN ENDP


;扫描是否有按键闭合子程序
CCSCAN1 PROC NEAR
       PUSH AX
       PUSH DX
       
       MOV  AL,00H                              
       MOV  DX,MY8255_A            ;将4列全选通，X1~X4置零
	   OUT  DX,AL
       MOV  DX,MY8255_C 
       IN   AL,DX                  ;读Y1~Y4
	   NOT  AL
       AND  AL,0FH                 ;取出Y1~Y4的反值，无按键按下时AL = 00H，标志位ZF = 1
       
       POP DX
       POP AX	   
       RET
CCSCAN1 ENDP

;发声子程序
 RING PROC NEAR
	PUSH BP
	MOV BP,SP
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	PUSH SI
	MOV SI,[BP+6];取出对应调频率表偏移地址
	MOV BX,0
	MOV CX,[BP+4];取出按键的ASCII码
	;按键共有16个，QWERTYUIASDFGHJK，依次为降4到升5
	;根据按键调到对应的块
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
	MOV BX,0 ;对应音在频率表中的偏移量，下面的依次递增2，下同
	MOV DX,1 ;对应键的刷红位置的起始x坐标，下同
	JMP RINGING ;跳转到发声部分，下同
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
	CALL LIGHT_RED				;将对应的按键刷红
	PUSH DX						;将刷红的起始x坐标压入栈保护
	MOV DX,MY8254_MODE          ;初始化设置8254为方式3，OUT0输出
	MOV AL,36H
	OUT DX,AL
	ADD SI,BX					;取上面按键确定的偏移值，选到对应的频率
	MOV DX,0FH                  ;输入时钟为1.0416667MHz，1.0416667M = 0FE502H  
	MOV AX,0E502H                
	DIV WORD PTR [SI]           ;取出频率值计算计数初值，0F4240H / 输出频率  
	MOV DX,MY8254_COUNT0
	OUT DX,AL                   ;装入计数初值
	MOV AL,AH
	OUT DX,AL                
	CALL delay					;调用延时子程序，控制每次发声的时间长短
	CALL delay
	POP DX
	CALL LIGHT_WHITE			;将对应的按键恢复原状
	MOV DX,MY8254_MODE          ;退出时设置8254为方式0，OUT0置0，消声
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

;模式2中将对应按键刷白（恢复原状）子程序
LIGHT_WHITE PROC NEAR
      PUSH BP
      MOV BP,SP
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
	  PUSH DI
      PUSH SI

	;将对应的那一块覆盖上白色，即恢复原状
    LEA DI,pos_y
    MOV BX,DX;转存对应键的刷白位置的起始x坐标
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

;模式2中将对应按键刷红子程序
LIGHT_RED PROC NEAR
      PUSH BP
      MOV BP,SP
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
	PUSH DI
      PUSH SI

	;将对应的那一块覆盖上红色，即恢复原状
    LEA DI,pos_y
    MOV BX,DX;转存对应键的刷红位置的起始x坐标
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

;模式2中画每个调的键盘的公共部分的子程序
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
 DRAW_MAIN2:;画模式2蓝色背景
	DRAW2 20h,3eh,01h,BX,80
	ADD BX,2
	LOOP DRAW_MAIN2

	LEA BX,keywh2_pos_y
	MOV CX,13
 DRAW_KEYWH:;画模式2白色琴键
	DRAW2 20H,7EH,01H,BX,80
	ADD BX,2
	LOOP DRAW_KEYWH

	LEA BX,t_pos_x
	LEA SI,t_pos_y
	LEA DI,t_len
	MOV CX,5
 T_DRAW:;画模式2中字母T
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP T_DRAW

	LEA BX,u_pos_x
	LEA SI,u_pos_y
	LEA DI,u_len
	MOV CX,9
 U_DRAW:;画模式2中字母U
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP U_DRAW

	LEA BX,n2_pos_x
	LEA SI,n2_pos_y
	LEA DI,n2_len
	MOV CX,9
 NN_DRAW:;画模式2中字母N(TUNE)
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP NN_DRAW

	LEA BX,e1_pos_x
	LEA SI,e_pos_y
	LEA DI,e_len
	MOV CX,5
 E2_DRAW:;画模式2中字母E
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP E2_DRAW

	LEA BX,p2_pos_x
	LEA SI,p2_pos_y
	LEA DI,p2_len
	MOV CX,6
 P2_DRAW:;画模式2中字母P
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP P2_DRAW

	LEA BX,i2_pos_x
	LEA SI,i2_pos_y
	LEA DI,i2_len
	MOV CX,5
 I2_DRAW:;画模式2中字母I
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP I2_DRAW

	LEA BX,a3_pos_x
	LEA SI,a3_pos_y
	LEA DI,a3_len
	MOV CX,8
 A3_DRAW:;画模式2中字母A
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP A3_DRAW

	LEA BX,n3_pos_x
	LEA SI,n3_pos_y
	LEA DI,n3_len
	MOV CX,9
 N3_DRAW:;画模式2中字母N（PIANO)
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP N3_DRAW

	LEA BX,o2_pos_x
	LEA SI,o2_pos_y
	LEA DI,o2_len
	MOV CX,8
 O2_DRAW:;画模式2中字母O
	DRAW1 20H,05EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP O2_DRAW

	LEA BX,point_pos_x
	LEA SI,point_pos_y
	LEA DI,point_len
	MOV CX,2
 POINT_DRAW:;画模式2中两个点
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP POINT_DRAW

	LEA BX,symbol_char
	LEA DI,symbol_pos_x
	LEA SI,symbol_pos_y
	MOV CX,25
 SYMBOL_DRAW:;画模式2中的简谱音符标识
	DRAW3 BX,3EH,DI,SI,1
	ADD BX,1
	ADD DI,2
	ADD SI,2
	LOOP SYMBOL_DRAW
	
	LEA BX,esc_char
	LEA DI,esc_pos_x
	LEA SI,esc_pos_y
	MOV CX,8
 ESC_DRAW:;画模式2中的退出标识语
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

delay PROC NEAR;延时子程序
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

;分数数码管显示子程序
;功能：将分数转换成数码管键值并将其在数码管上显示出来
SCOREDIS PROC NEAR
       PUSH AX
       PUSH BX
       PUSH CX
       PUSH DX
       PUSH SI
       MOV  SI,3000H               ;建立缓冲区，存放要显示的键值
	   MOV  AL,00H                 ;先初始化键值为0
	   MOV  [SI],AL
	   MOV  [SI+1],AL
	   MOV  [SI+2],AL
	   MOV  [SI+3],AL
	   MOV  [SI+4],AL
	   MOV  [SI+5],AL
	   MOV  DX,MY8255_MODE         ;初始化8255工作方式
       MOV  AL,81H                 ;方式0，A、B口输出，C口低4位输入
	   OUT  DX,AL
	   
CLEAR:                             ;清除数码管显示
	   MOV  DX,MY8255_B            ;段位置0即可清除数码管显示
	   MOV  AL,00H
       OUT  DX,AL
	   
	   MOV  AX,SCORE               ;将分数作为被除数，10作为除数，辗转取余
	   MOV  BH,0AH
DIVSCORE:              
       DIV  BH                     ;分数除十求余数，AH为余数，AL为商
       MOV  [SI],AH                ;将余数分别存入缓冲区
       INC  SI
       CMP  AL,00H                 ;判断AL是否为0，为零则结束
       JE   DISPLAYS
       MOV  AH,00H                 ;商不为零，则将AH置零，继续除十取余
       JMP  DIVSCORE
       
DISPLAYS:
       MOV  CX,00FFH
TIME1:    MOV  AX,005FH            ;延时代码段，保证数码管能够显示一定时间
TIME2:    PUSH AX
              
	   MOV  SI,3000H                           
	   MOV  DL,0DFH
	   MOV  AL,DL
AGAIN: PUSH DX
       MOV  DX,MY8255_A 
       OUT  DX,AL                  ;设置L1~L6，选通一个数码管
       MOV  AL,[SI]                ;取出缓冲区中存放的键值
       MOV  BX,OFFSET DTABLE
	   AND  AX,00FFH
	   ADD  BX,AX                  
	   MOV  AL,[BX]                ;将键值作为偏移和键值基地址相加得到相应的键值
       MOV  DX,MY8255_B 
	   OUT  DX,AL                  ;写入数码管A~Dp
	   CALL DALLY5
	   INC  SI                     ;取下一个键值
       POP  DX
       MOV  AL,DL
	   TEST AL,01H                 ;判断是否显示完
       JZ   OUT0                   ;显示完，则返回
	   ROR  AL,1
	   MOV  DL,AL
	   JMP  AGAIN                  ;未显示完，选通下一个数码管并跳回继续
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


;画模式3主界面子程序
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
 DRAW_MAIN3:;画模式3蓝色背景
	DRAW2 20h,3eh,01h,BX,80
	ADD BX,2
	LOOP DRAW_MAIN3

	LEA BX,fanr_pos_x
	LEA SI,fanr_pos_y
	LEA DI,fanr_len
	MOV CX,6
 FANR_DRAW:;画模式3红色扇叶
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANR_DRAW

	LEA BX,fanwh_pos_x
	LEA SI,fanwh_pos_y
	LEA DI,fanwh_len
	MOV CX,2
 FANWH_DRAW:;画模式3风扇白色中心点
	DRAW1 20H,07EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANWH_DRAW

	LEA BX,fany_pos_x
	LEA SI,fany_pos_y
	LEA DI,fany_len
	MOV CX,6
 FANY_DRAW:;画模式3黄色扇叶
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANY_DRAW
  
	LEA BX,fanb_pos_x
	LEA SI,fanb_pos_y
	LEA DI,fanb_len
	MOV CX,6
 FANB_DRAW:;画模式3蓝色扇叶
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANB_DRAW

	LEA BX,fang_pos_x
	LEA SI,fang_pos_y
	LEA DI,fang_len
	MOV CX,6
 FANG_DRAW:;画模式3绿色扇叶
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FANG_DRAW

	LEA BX,f03_pos_x
	LEA SI,f03_pos_y
	LEA DI,f03_len
	MOV CX,6
 F03_DRAW:;画模式3字母F
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP F03_DRAW

	LEA BX,a03_pos_x
	LEA SI,a03_pos_y
	LEA DI,a03_len
	MOV CX,9
 A03_DRAW:;画模式3字母A
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP A03_DRAW

	LEA BX,n03_pos_x
	LEA SI,n03_pos_y
	LEA DI,n03_len
	MOV CX,12
 N03_DRAW:;画模式3字母N
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP N03_DRAW

	LEA BX,p03_pos_x
	LEA SI,p03_pos_y
	LEA DI,p03_len
	MOV CX,7
 P03_DRAW:;画模式3字母P
	DRAW1 20H,04EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP P03_DRAW

	LEA BX,l03_pos_x
	LEA SI,l03_pos_y
	LEA DI,l03_len
	MOV CX,6
 L03_DRAW:;画模式3字母L
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP L03_DRAW

	LEA BX,a04_pos_x
	LEA SI,a04_pos_y
	LEA DI,a03_len
	MOV CX,9
 A04_DRAW:;画模式3字母A
	DRAW1 20H,01EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP A04_DRAW

	LEA BX,y03_pos_x
	LEA SI,y03_pos_y
	LEA DI,y03_len
	MOV CX,8
 Y03_DRAW:;画模式3字母Y
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP Y03_DRAW

	LEA BX,frame_pos_x
	LEA SI,frame_pos_y
	LEA DI,frame_len
	MOV CX,12
 FRAME_DRAW:;画模式3显示区边框
	DRAW1 20H,05EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP FRAME_DRAW

	LEA BX,up_pos_x
	LEA SI,updown_pos_y
	LEA DI,up_len
	MOV CX,9
 UP_DRAW:;画模式3向上的箭头
	DRAW1 20H,06EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP UP_DRAW

	LEA BX,down_pos_x
	LEA SI,updown_pos_y
	LEA DI,down_len
	MOV CX,9
 DOWN_DRAW:;画模式3向下的箭头
	DRAW1 20H,02EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP DOWN_DRAW

	LEA BX,lan1_pos_x
	LEA SI,lan1_pos_y
	LEA DI,lan_len
	MOV CX,3
 LAN1_DRAW:;画模式3增指示灯
	DRAW1 20H,00EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP LAN1_DRAW

	LEA BX,lan2_pos_x
	LEA SI,lan2_pos_y
	LEA DI,lan_len
	MOV CX,3
 LAN2_DRAW:;画模式3减指示灯
	DRAW1 20H,00EH,BX,SI,DI
	ADD BX,2
	ADD SI,2
	ADD DI,2
	LOOP LAN2_DRAW
	
	LEA BX,output_str
	LEA DI,output_pos_x
	LEA SI,output_pos_y
	MOV CX,44
 ESC_DRAW1:;画模式3退出标识语
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

;显示设定转速的子程序
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

	MOV CX,AX;保护AX
	MOV  AX,0B800H;设置写入显存位置
	MOV  ES,AX
	MOV AX,CX;传回AX

	;将AX中存储的转速个位十位分开再转变为对应的ASCII码并画在对应的位置
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

;显示即时转速的子程序,注释与上面子程序基本一致，不再重复注释
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
	CALL delay;延缓在界面上显示的时间，防止刷新过快无法在界面上显示
				
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

;模式三界面中增指示灯刷红子程序，注释与LIGHT_RED和LIGHT_WHITE基本一致，不再重复注释
;都是将对应的部分刷红（相当于亮起）或者刷黑（恢复原状）
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

;模式三界面增指示灯刷黑子程序
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

;模式三减指示灯刷红子程序
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

;模式三减指示灯刷黑子程序
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

DALLY5 PROC NEAR                    ;延时子程序5
       PUSH CX
       MOV  CX,0fffH
DDD3:  MOV  AX,00FFH
DDD4:  DEC  AX
	   JNZ  DDD4
	   LOOP DDD3
	   POP  CX
	   RET
DALLY5 ENDP

DALLY PROC                        ;延时子程序1
D0:   MOV CX,0F00H
D1:   MOV AX,8FFFH
D2:   DEC AX
      JNZ D2
      LOOP D1
      DEC DL
      JNZ D0
      RET
DALLY ENDP

DALLY2 PROC NEAR         ;延时子程序2
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

DALLY3 PROC                        ;延时子程序3
D00:   MOV CX,00F0H
D01:   MOV AX,00F0H
D02:   DEC AX
       JNZ D02
       LOOP D01
       DEC DL
       JNZ D00
       RET
DALLY3 ENDP

delaymusic PROC NEAR              ;延时子程序，用于模式1中播放对应的音的延时
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

randByBX PROC NEAR;产生随机数存入BX（即未保护BX寄存器
		  PUSH AX
		  PUSH CX
		  PUSH DX
		  STI
		  MOV AH,0 
		  INT 1AH
		  MOV AL,DL;将取得的当前时间存入AL
		  MOV BL,4h
		  DIV BL;将当前时间除以4得到0~3的余数
		  MOV BL,AH;将得到的余数存入BL
		  MOV BH,00H
		  MOV AX,20
		  MUL BX
		  ADD AX,7;存入：余数*20+7
		  MOV BX,AX;将上述计算得到的值存入BX
		  POP DX
		  POP CX
     	  POP AX
     	  RET 
randByBX ENDP
CODE  ENDS
      END START      	