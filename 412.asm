;######################## 宏函数 #################################
CLEAR MACRO A,B,C,D,COL ;清屏函数,A,B为左上角坐标，C,D为右下角,颜色为COL
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
   MOV AH,6             ;INT 10H的6号调用 
   MOV AL,0             ;AL = 0时为清屏
   MOV CH,A             ;CH,CL为左上角左边，DH.DL为右下角坐标
   MOV CL,B             
   MOV DH,C             
   MOV DL,D 
   MOV BH,COL           ;BH为颜色属性，各位表示如下
   INT 10H              ;高亮，背景红，背景绿，背景蓝，高亮，前景红，前景绿，前景蓝 
   POP DX
   POP CX
   POP BX
   POP AX
ENDM

DISPMSG MACRO MESSAGE   ;在当前光标位置显示字符串函数
   PUSH DX
   PUSH AX
   LEA DX,MESSAGE       ;DX存放要显示字符串偏移地址
   MOV AH,9           
   INT 21H 
   POP AX
   POP DX
ENDM

GETCHAR MACRO           ;获取当前光标位置字符属性
   PUSH BX
   MOV AH,08H           ;AL = 字符码，AH = 字符属性
   MOV BH,0
   INT 10H
   POP BX
ENDM

CURS MACRO A,B          ;置光标位置,坐标为(A.B) 
   PUSH AX
   PUSH BX
   PUSH DX
   MOV AH,2             ;INT 10H的2号调用
   MOV BH,0
   MOV DH,A
   MOV DL,B           
   INT 10H              
   POP DX
   POP BX
   POP AX  
ENDM

COLCHAR MACRO C,CHAR    ;在当前光标位置输出彩色字符,C为颜色、CHAR为字符
   PUSH AX
   PUSH BX
   PUSH CX
   MOV BH,0             ;BH = 显示页
   MOV BL,C             ;BL = 颜色属性
   MOV CX,1             ;CX = 字符重复次数
   MOV AL,CHAR          ;AL = 字符
   MOV AH,09H           ;INT 10H的9号调用
   INT 10H              
   POP CX
   POP BX
   POP AX
ENDM

SCROLL MACRO B,D,COL    ;左右放下落界面向下滚屏一行，B,D=0,39为左方,40,79为右方，COL为背景色
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX

   MOV AH,07H           ;INT 10H 07号功能向下滚屏   
   MOV AL,01H           ;AL = 1表示第一行开始向下滚动一行
   MOV BH,COL           ;CH,CL为左上角左边，DH.DL为右下角坐标
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

CLEARBUFF MACRO         ;清空缓冲区
   PUSH AX
   MOV AH,0CH        
   MOV AL,0
   INT 21H
   POP AX 
ENDM

;################################################################
;查看端口资源分配情况，记录实验系统I/O端口始地址
   INTR_IVADD       EQU   003CH         ;INTR对应的中断矢量地址
   IOY0             EQU   0E000H        ;片选IOY0对应的端口始地址
   MY8255_A         EQU   IOY0+00H*4    ;8255的A口地址，对应键盘的扫描列或数码管的选通输入端
   MY8255_B         EQU   IOY0+01H*4    ;8255的B口地址，对应数码管的写入端
   MY8255_C         EQU   IOY0+02H*4    ;8255的C口地址，对应键盘的扫描行
   MY8255_MODE      EQU   IOY0+03H*4    ;8255的控制寄存器地址
   
   IOY1             EQU   0E040H        ;片选IOY1对应的端口始地址
   MY8254_COUNT0    EQU   IOY1+00H*4    ;8254计数器0端口地址
   MY8254_COUNT1    EQU   IOY1+01H*4    ;8254计数器1端口地址
   MY8254_COUNT2    EQU   IOY1+02H*4    ;8254计数器2端口地址
   MY8254_MODE      EQU   IOY1+03H*4    ;8254控制寄存器端口地址

   PC8254_COUNT0    EQU   40H           ;PC机内8254定时器0端口地址
   PC8254_MODE      EQU   43H           ;PC机内8254控制寄存器端口地址
   IOY2             EQU   0E080H
;################################################################

STACK1  SEGMENT STACK
   DW  256 DUP(?)   
STACK1  ENDS

DATA    SEGMENT
   MSG0    DB 'SCORE: $'
   MSG1    DB ' =========================================','$' ;开始界面
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
   NOWRAND256  DB  0       ;存放当前0-255随机数
   NOWRAND40   DB  0       ;存放当前0-39随机数
   MODE        DB  1       ;当前游戏模式，单人1or双人2
   DEGREE      DW  0       ;当前难度等级
   TURNSCOR    DB  8       ;每得多少分进入下一难度等级
   SPEED       DB  30,24,19,15,12   ;下落速度，越小越快，分别是难度1,2,3,4,5
   Llocation   DB  19      ;存放左方当前0位置
   Rlocation   DB  59      ;存放右方当前位置
   LSCORE      DB  0       ;存放左方当前分数
   RSCORE      DB  0       ;存放右方当前分数
   LNEEDSCOR   DB  5       ;左方需要再得多少才能进入下一个难度等级
   RNEEDSCOR   DB  5       ;右方方需要再得多少才能进入下一个难度等级
   DELICACY    DB  10      ;键盘灵敏度
   DTABLE      DB  3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH     ;键值表，0～F对应的7段数码管的段位值
   SCORE_TABLE DB  00H,00H,00H,00H,00H,00H                     ;分数表
   FREQ_LIST   DW  661,21000,661,21000,661,22000,661,21000,661,700,21000,700,21000,700,21000,700,21000,700,589,21000,589,21000,589,21000,589,495,21000,495,21000,495,21000,495,21000    
               DW  661,21000,661,21000,661,22000,661,21000,661,700,21000,700,21000,700,21000,700,21000,700,589,21000,589,21000,589,21000,589,495,21000,495,21000,495,21000,495,21000 
               DW  661,882,990,1178,700,882,900,1178,786,882,1178,1049,990,21000        
               DW  661,882,990,1178,700,882,900,1178,786,882,1178,1049,990,0  				;开始界面BGM频率表

   TIME_LIST   DB  7,1,7,1,8,4,3,1,4,3,1,7,1,7,1,3,1,4,7,1,7,1,8,4,4,3,1,3,1,7,1,12,2   
               DB  7,1,7,1,8,4,3,1,4,3,1,7,1,7,1,3,1,4,7,1,7,1,8,4,4,3,1,3,1,7,1,12,2		
               DB  8,8,8,8,8,8,8,8,8,8,8,8,20,4
               DB  8,8,8,8,8,8,8,8,8,8,8,8,20		;开始界面BGM时间表
   EIGHT       DB  08H 
   FREQIDX     DW  0                ;当前播放频率
   FREQTYPE    DB  0                ;音效类型，0为1分，1为3分
   FREQ2       DW  23000,294,350    ;1分音效频率表
   FREQ1       DW  661,589,525      ;3分音效频率表
   LIGHT       DW  0FF80H  
   WINSCORE    DB  40
   ROW         DB  19

   CS_BAK   DW  ?                ;保存INTR原中断处理程序入口段地址的变量
   IP_BAK   DW  ?                ;保存INTR原中断处理程序入口偏移地址的变量
   IM_BAK   DB  ?,?              ;保存INTR原中断屏蔽字的变量
   CS_BAK1  DW  ?                ;保存定时器0中断处理程序入口段地址的变量
   IP_BAK1  DW  ?                ;保存定时器0中断处理程序入口偏移地址的变量
   IM_BAK1  DB  ?,?              ;保存定时器0中断屏蔽字的变量
         
   TS       DB 20                  ;采样周期
   SPEC     DW 55                  ;转速给定值   55
   IBAND    DW 0060H               ;积分分离值   96
   KPP      DW 1060H               ;比例系数     4192
   KII      DW 0010H               ;积分系数     16
   KDD      DW 0020H               ;微分系数     32
   
   YK       DW 0000H               ;反馈量
   CK       DB 00H                 ;控制量
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

;########################### 主程序 ##############################

CODE    SEGMENT
   ASSUME  CS:CODE,DS:DATA,SS:STACK1
START:
   MOV AX,DATA
   MOV DS,AX
   
   MOV DX,IOY2              ;最开始流水灯全灭
   MOV AL,00H
   OUT DX,AL
   
   MOV  DX,MY8255_MODE      ;初始化8255工作方式 
   MOV  AL,81H              ;方式0，A口、B口输出，C口低4位输入,高4位输出  
   OUT  DX,AL

   CLEAR 0,0,100,100,03EH   ;清屏青底黄字
   ;画开始界面的PICK
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

   CURS 17,21          ;输出选择模式提示信息框
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

   CURS 19,31              ;光标位于菜单第一行
   COLCHAR 03CH,10H
   MOV ROW,19               

   MOV DX,MY8254_MODE      ;初始化8254工作方式
   MOV AL,0B6H             ;定时器2、方式3
   OUT DX,AL
   CLEARBUFF
   
BEGIN2:                        ;播放开始界面背景音乐
   MOV SI,OFFSET FREQ_LIST     ;装入频率表起始地址
   MOV DI,OFFSET TIME_LIST     ;装入时间表起始地址
   
PLAY2: 
   MOV DX,0FH             ;输入时钟为1.0416667MHz，1.0416667M = 0FE502H  
   MOV AX,0E502H                
   DIV WORD PTR [SI]      ;取出频率值计算计数初值，0F4240H / 输出频率  
   MOV DX,MY8254_COUNT2
   OUT DX,AL              ;装入计数初值
   MOV AL,AH
   OUT DX,AL
   
   MOV DL,[DI]            ;取出演奏相对时间，调用延时子程序 
   CALL DALLY3
   
   ADD SI,2
   INC DI
   CMP WORD PTR [SI],0         ;判断是否到曲末？
   JE  BEGIN2
   
   MOV AH,1        ;INT 16H 01H 读键盘状态 
   INT 16H         ;如果没有键按下，ZF=1，跳回PLAY2
   JZ  PLAY2       
   
   MOV AH,0        ;如果有键按下，调用INT 16H 00H 读取按下的是哪个键
   INT 16H         ;出口参数：AH 键盘扫描码，00H号功能一次只能读取一个键
   CLEARBUFF       ;为了避免有多个字符没读取于此清一下清除缓冲区
   CMP AH,48H      ;因为我们要检测上下方向键，没有ASCII码，只有键盘扫描码
   JE UP           ;虽然理论上01H号功能能读取扫描码，但在实际实验中读取失败
   CMP AH,50H      ;并且01H号功能读取其他字符ASCII码也出现了一系列问题
   JE DOWN         ;而00H号功能没问题,但00H号功能当没有按键时会停止等待按键
   CMP AH,1CH      ;音乐是以循环为主体，这样会阻止音乐的播放
   JE ENTER0       ;所以我们先用01H号功能判断是否有按键按下
                   ;如果有再用00H号功能读取键盘扫描码判断哪个键被按下
TOPLAY2:    
   JMP PLAY2
UP:                ;上移右三角  
   MOV DL,ROW      
   CMP DL,19       ;如果当前行位于最顶行不进行移动
   JE PLAY2 
   CURS DL,31          
   COLCHAR 03CH,20H    ;先用空格覆盖当前行（清除）右三角
   DEC DL
   MOV ROW,DL
   CURS DL,31
   COLCHAR 03CH,10H    ;再在上一行画一个右三角
   JMP PLAY2
ENTER0:                ;由于跳转距离过长，设置一个跳转中转站
   JMP ENTER1    
DOWN: 
   MOV DL,ROW          ;如果当前行位于最底行不进行移动
   CMP DL,22
   JE TOPLAY2 
   CURS DL,31          ;清除右三角
   COLCHAR 03CH,20H
   INC DL
   MOV ROW,DL
   CURS DL,31
   COLCHAR 03CH,10H    ;在下一行画一个右三角
   JMP PLAY2 
ENTER1:
   MOV DX,MY8254_MODE  ;进入游戏停止播放背景音乐
   MOV AL,0B0H         ;设置8254为方式2，OUT0置0
   OUT DX,AL

   MOV DL,ROW          ;根据当前行位置判断进入哪一个模式
   CMP DL,19
   JZ SINGLEMODE
   CMP DL,20
   JZ DOUBLEMODE
   CMP DL,21
   JZ FAN   
   JMP QUIT

 SINGLEMODE:            ;单人模式
   MOV MODE,1
   JMP START1
 DOUBLEMODE:            ;双人模式
   MOV MODE,2
   JMP START1
 FAN:                   ;风扇调速模式
   STI
   CLEAR 0,0,79,79,0EH
   CURS 28,15
   DISPMSG MSG13
   MOV  AX,SPEC         ;将给定值输出给专用界面显示
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

START1:                     ;游戏开始
   CLEAR 0,0,49,39,0EH      ;清屏左方游戏界面黑底
   CLEAR 0,40,49,79,5EH     ;清屏右方游戏界面紫底
   CLEAR 0,0,0,79,04EH      ;清屏显示分数界面银底蓝字
   MOV DEGREE,0             ;初始化各种游戏信息       
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

   MOV AL,MODE              ;不同模式显示分数的位置等情况不同
   CMP AL,1                 ;根据当前模式跳转
   JE SINGLEMODE1
   JMP DOUBLEMODE1
SINGLEMODE1:                ;单人模式
   CURS 20,49
   DISPMSG MSG0             ;显示单人模式分数字符串
   MOV BL,Llocation
   CALL DRAW_LHAT           ;单人模式只需要画一个接币笑脸
   CURS 20,56
   MOV AL,LSCORE
   CALL SHOWLSCORE          ;单人模式只需要显示一个分数
   CURS 23,49
   DISPMSG MSG8             ;提示信息字符串
   JMP NEXT1
TOSTART2:
   JMP START
DOUBLEMODE1:                ;双人模式
   CURS 0,15
   DISPMSG MSG0             ;显示双人模式分数字符串
   CURS 0,55
   DISPMSG MSG0            
   MOV BL,Llocation         ;双人模式需要画两个接币笑脸
   CALL DRAW_LHAT
   MOV BL,Rlocation
   CALL DRAW_RHAT
   MOV AL,LSCORE
   CURS 0,21
   CALL SHOWLSCORE          ;双人模式只需要显示两个分数
   MOV AL,RSCORE
   CURS 0,61
   CALL SHOWRSCORE      
   CALL COUNTDOWN           ;双人模式游戏开始时需要倒计时
   MOV AX,LIGHT
   MOV DX,IOY2
   OUT DX,AX
NEXT1:
   MOV AH,0             ;取当前系统时间作为随机数种子
   INT 1AH              ;时间中断,入口:AH=00读系统时间;AH=01置系统时间
   MOV AX,DX            ;返回值:CX=系统时钟计数高位字,DX=系统时钟计数低位字
   MOV BL,255           ;获取值表示多少个1/18.20648秒
   DIV BL
   MOV NOWRAND256,AH    ;生成第一个0~255随机数
   CALL NEXT_RAND       ;生成第一个0~39随机数
   

   MOV CX,5             ;这里希望最开始生成的道具不是3分的
   JMP LOOP1            ;所以直接跳转到第一层循环
LOOP0:                  ;每过5次生成一个3分的道具
   MOV CX,6             ;每循环5次LOOP1才会执行一次LOOP0
   MOV AL,NOWRAND40
   CURS 1,AL
   COLCHAR 0BH,08H      ;取当前随机数画左边第一行准备下落的3分道具

   MOV AH,MODE          ;根据当前模式判断是否需要画右边准备下落的3分道具
   CMP AH,1
   JE NEXTL2            ;如果画了3分道具直接跳过画1分道具
   ADD AL,40
   CURS 1,AL
   COLCHAR 5BH,08H
   JMP NEXTL2               
LOOP1:                      
   MOV AL,NOWRAND40     ;取当前随机数画左边第一行准备下落的1分道具
   CURS 1,AL
   COLCHAR 0EH,03H

   MOV AH,MODE          ;根据当前模式判断是否需要画右边准备下落的1分道具
   CMP AH,1
   JE NEXTL2
   ADD AL,40
   CURS 1,AL
   COLCHAR 5EH,03H
NEXTL2:
   MOV BX,10            ;相邻2个爱心，隔10行下落
   CALL NEXT_RAND       ;获取下一个随机数
LOOP2:                  ;每循环10次LOOP2（包含滚屏一行）才会生成下一个道具
   MOV AH,MODE          ;根据当前模式判断是双方滚屏还是一方滚屏
   CMP AH,1             ;以及分数要显示的位置
   JE NEXTL3
                        ;双人模式
   CALL DETECTUPL       ;检测左方接币笑脸上方是否有道具从而判断加分
   MOV AL,LSCORE
   CURS 0,21
   CALL SHOWLSCORE      ;显示左方分数
   SCROLL 0,39,00H      ;左方滚屏下降

   CALL DETECTUPR       ;检测右方接币笑脸上方是否有道具从而判断加分
   MOV AL,RSCORE
   CURS 0,61
   CALL SHOWRSCORE      ;显示右方分数
   SCROLL 40,79,5FH     ;右方滚屏下降
   JMP NEXTL31
NEXTL3:                 ;单人模式操作的只有左方
   CALL DETECTUPL
   MOV AL,LSCORE
   CURS 20,56
   CALL SHOWLSCORE
   SCROLL 0,39,00H 
   JMP NEXTL32
NEXTL31: 
   MOV AH,WINSCORE      
   MOV AL,LSCORE        ;谁先到40分谁先赢
   CMP AL,AH
   JGE LWIN
   MOV AL,RSCORE
   CMP AL,AH
   JGE TORWIN1

NEXTL32:
   CALL DEGREEUP        ;判断难度是否要增加
   PUSH BX           
   MOV SI,DEGREE        
   MOV BL,SPEED[SI]     ;速度表取当前难度的索引值就是当前速度
   JMP LOOP3
TORWIN1:                ;三个跳转中转站
   JMP RWIN
LOOP20:                 
   JMP LOOP2
LOOP10:
   JMP LOOP1
LOOP3:
   MOV AL,DELICACY   ;DELICACY键盘灵敏度表示循环多少次LOOP3才扫描一次键盘
   DEC AL
   MOV DELICACY,AL
   JNZ B1 
                  ;同样利用键盘延时的时间作为接道具音效每个频率的延时时间
   CALL MUSIC     ;在MUSIC子程序内开启音效，然后到一个键盘延时后取消声音输出
NOTMUSIC:
   MOV DELICACY,10
   CALL CCSCAN       ;扫描实验箱键盘，是否有键按下
   JZ  PCKEY
   CALL CCMOVE       ;有键按下进入子程序判断是哪个按键进而做出相应移动操作
PCKEY:   
   MOV AH,1          ;判断电脑键盘是否有键按下
   INT 16H           ;我们加上电脑键盘主要是为了在平时测试游戏效果
   JZ  B1 
   CLEARBUFF         ;清除缓冲区
   CALL MOVE         ;根据键盘输入的键移动框
B1:
    CALL DALLY       ;游戏主体最内层循环的延时函数
    DEC BL
    JNZ LOOP3
    POP BX
    DEC BX
    JNZ LOOP20       ;没有直接跳转LOOP2和LOOP1是因为跳转距离过长
    DEC CX
    JNZ LOOP10
    JMP LOOP0
   
LWIN:                   ;左方玩家获胜输出相应字符串
   CLEAR 1,0,47,39,0EH
   CLEAR 1,40,47,79,5EH
   CURS 20,15
   DISPMSG MSG10
   CURS 20,55
   DISPMSG MSG11
   JMP WAITSPACE        
RWIN:                   ;右方玩家获胜输出相应字符串
   CLEAR 1,0,47,39,0EH
   CLEAR 1,40,47,79,5EH
   CURS 20,15
   DISPMSG MSG11
   CURS 20,55
   DISPMSG MSG10
   JMP WAITSPACE        
WAITSPACE:
   CALL WINLIGHT       ;流水灯闪烁并且等待空格返回主菜单
   
TOSTART1:              ;跳转中转站
   JMP TOSTART2
   
QUIT:                  ;结束程序返回操作系统
   MOV AH,4CH
   INT 21H

;#################################################################

;########################## 子函数 ################################

MOVE PROC              ;(用于平时测试)检测电脑键盘按下的按键是哪个并进行移动
   PUSH BX
   PUSH CX
   MOV BL,Llocation
   MOV BH,Rlocation
   CMP AL,' '          ;有键按下，判断是否为0（下一步）
   JE  TOSTART1
   CMP AL,'d'          ;有键按下，判断是否为6（右移）
   JE  RMOVEL
   CMP AL,'a'          ;有键按下，判断是否为4（左移）
   JE  LMOVEL

   MOV CL,MODE
   CMP CL,1
   JE RETURN20
   CMP AL,'l'          ;有键按下，判断是否为6（右移）
   JE  RMOVER
   CMP AL,'j'          ;有键按下，判断是否为4（左移）
   JE  LMOVER
   JMP RETURN2         ;无视其他按键
 RMOVEL:               ;左方笑脸向右移动
   CMP BL,38
   JE  RETURN20
   INC BL
   CLEAR 48,0,49,39,0FH    ;清屏左方笑脸的位置     
   CALL DRAW_LHAT          ;在新的位置画上笑脸
 RETURN20:                 ;跳转中转站
   JMP RETURN2
 LMOVEL:                   ;左方笑脸向左移动
   CMP BL,1
   JE  RETURN2
   DEC BL
   CLEAR 48,0,49,39,0FH    ;清屏左方笑脸的位置      
   CALL DRAW_LHAT          ;在新的位置画上笑脸
   JMP RETURN2
 RMOVER:                   ;右方笑脸向右移动
   CMP BH,78
   JE  RETURN2
   INC BH
   CLEAR 48,40,49,79,5FH   ;清屏右方笑脸的位置v
   PUSH BX                     
   MOV BL,BH           
   CALL DRAW_RHAT          ;在新的位置画上笑脸
   POP BX
   JMP RETURN2
 LMOVER:                   ;右方笑脸向左移动
   CMP BH,41
   JE  RETURN2
   DEC BH
   CLEAR 48,40,49,79,5FH   ;清屏右方笑脸的位置     
   PUSH BX                     
   MOV BL,BH           
   CALL DRAW_RHAT          ;在新的位置画上笑脸
   POP BX
   JMP RETURN2
 RETURN2:                  ;把更新的位置存放在相应变量
   MOV Llocation,BL
   MOV Rlocation,BH
   POP CX
   POP BX
   RET
MOVE ENDP   

CCMOVE PROC             ;扫描按键 
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX

   MOV  BL,Llocation
   MOV  BH,Rlocation
   MOV  CH,0FEH         ;设置初始扫描列为第一列
   MOV  CL,00H          ;设置当前检测的是第几列,0表示第一列
 COLUM: 
   MOV  AL,CH           ;选取一列，将X1～X4中一个置0            
   MOV  DX,MY8255_A 
   OUT  DX,AL
   MOV  DX,MY8255_C     ;读Y1～Y4，用于判断是哪一行按键闭合 
   IN   AL,DX

   CMP  AL,07H          ;是否为第4行
   JNE  RNEXT           ;不是则继续判断
   CMP  CL,00H
   JE   CCLMOVEL
   CMP  CL,01H
   JE   CCLMOVER
 RNEXT:   
   CMP  AL,0BH          ;是否为第3行
   JNE  CCNEXT          ;不是则继续判断
   CMP  CL,02H
   JE  CCRMOVEL
   CMP  CL,03H
   JE  CCRMOVER
   JMP  CCNEXT          ;无视其他按键
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
   INC  CL              ;当前检测的列数递增   
   CMP  CL,04H          ;检测是否扫描到第4列
   JE   KERR            ;是则对笑脸位置进行更新
   ROL  CH,1            ;没检测到第4列则准备检测下一列
   JMP  COLUM  
 
 KERR:                  ;一下对笑脸位置进行更新为MOVE子程序中的相同
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
   CLEAR 48,0,49,39,0FH        ;清屏左方笑脸的位置      
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
   CLEAR 48,40,49,79,5FH       ;清屏右方笑脸的位置   
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

CCSCAN PROC NEAR        ;扫描实验箱键盘是否有键按下子程序
   PUSH AX
   PUSH DX

   MOV  AL,00H                              
   MOV  DX,MY8255_A     ;将4列全选通，X1～X4置0
   OUT  DX,AL
   MOV  DX,MY8255_C 
   IN   AL,DX           ;读Y1～Y4
   NOT  AL              ;取出Y1～Y4的反值
   AND  AL,0FH          ;置flags，若AL=00H,则AND操作后ZF=1，说明无键按下

   POP DX
   POP AX
   RET
CCSCAN ENDP

MUSIC PROC              ;播放接道具音效当前频率
   PUSH AX
   PUSH BX
   PUSH DX
   
   MOV DX,MY8254_MODE   ;置8254为方式2，OUT0置0取消声音输出
   MOV AL,90H          
   OUT DX,AL

   MOV AX,FREQIDX     ;FREQIDX表示当前音效输出频率的索引值，为0表示没有音效
   CMP AX,0     
   JZ  RETURNM        ;FREQIDX不为0表示没有音效要输出

   MOV DX,MY8254_MODE   ;初始化8254工作方式
   MOV AL,0B6H          ;定时器2、方式3
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
   MOV DX,0FH           ;输入时钟为1.0416667MHz，1.0416667M = 0FE502H  
   MOV AX,0E502H   
   DIV WORD PTR [SI]    ;取出频率值计算计数初值，0F4240H / 输出频率  
   MOV DX,MY8254_COUNT2
   OUT DX,AL            ;装入计数初值
   MOV AL,AH
   OUT DX,AL
 RETURNM:
   POP DX
   POP BX
   POP AX
   RET
MUSIC ENDP

DEGREEUP PROC           ;判断游戏难度是否需要增加
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
   MOV AL,LNEEDSCOR     ;更新双方进入下一阶段所需分数
   ADD AL,BH
   MOV LNEEDSCOR,AL
   MOV BL,RNEEDSCOR
   ADD BL,BH
   MOV RNEEDSCOR,BL

   MOV AL,MODE
   CMP AL,1
   JE  UP1
   MOV AX,LIGHT         ;灯光多亮一盏
   ROR AX,1
   MOV LIGHT,AX
   MOV DX,IOY2
   OUT DX,AL
 UP1:   
   MOV AX,DEGREE        ;游戏难度+1
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

NEXT_RAND PROC          ;LCG算法生成随机数
   PUSH AX
   PUSH BX
   PUSH DX

   MOV AL,NOWRAND256  ;取出当前0~255随机数
   MOV BL,17          ;获取下一个随机数,r(i+1) = mod( 17 *r(i)+ 139, 256)
   MUL BL             ;17 * r(i) 存入 AX
   ADD AX,139         ;17 *r(i)+ 139 存入 AX
   MOV DX,0        
   MOV BX,256
   DIV BX             ;(DX:AX)/256余数存入DX(DL)
   MOV NOWRAND256,DL  ;存入下一个0~255随机数
   CMP DL,239         ;为了均匀分布，大于等于239的数将再进行一次计算
   JB  TO80
   CALL NEXT_RAND     ;这样变成了递归函数
   JMP RETURN1
 TO80:
   MOV AX,DX
   MOV BL,40
   DIV BL              
   MOV NOWRAND40,AH   ;存入下一个0~40随机数

 RETURN1:
   POP DX
   POP BX
   POP AX
   RET
NEXT_RAND ENDP

DETECTUPL PROC        ;检测左方笑脸上方是否有物体并加分
   PUSH BX
   PUSH AX

   MOV BL,Llocation
   DEC BL
   CURS 47,BL
   GETCHAR              ;获取笑脸左上方字符
   CMP AL,03H
   JE ADDSCORE
   CMP AL,08H
   JE ADDSCORE3

   INC BL   
   CURS 47,BL
   GETCHAR              ;获取笑脸正上方字符
   CMP AL,03H
   JE ADDSCORE
   CMP AL,08H
   JE ADDSCORE3

   INC BL
   CURS 47,BL
   GETCHAR              ;获取笑脸左上方字符
   CMP AL,03H
   JE ADDSCORE
   CMP AL,08H
   JE ADDSCORE3
   JMP RETURN3
 ADDSCORE:              ;加1分
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
 ADDSCORE3:             ;加3分
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

DETECTUPR PROC          ;检测右方笑脸上方是否有物体并加分
   PUSH BX              ;内容与DETECTUPL类似
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

DRAW_LHAT PROC          ;画左方笑脸，需预先将位置移入BL
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

DRAW_RHAT PROC          ;画右方笑脸，需预先将位置移入BL
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

SHOWLSCORE PROC     ;在当前光标位置显示左方分数，分数存入AL中,显示位置存入BH
   PUSH DX
   PUSH CX
   PUSH BX
   PUSH AX

   MOV AH,0
   MOV BL,100
   DIV BL              ;分数/100，商存入AL，余数存入AH 
   MOV BH,AL           ;BH存百位
   MOV AL,AH           
   MOV AH,0
   MOV BL,10           
   DIV BL              ;余下两位数/10，商存入AL(十位)，余数存入AH(个位)
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
   MOV [SI],BH          ;玩家1分数百位
   ADD SI,1
   MOV [SI],CL          ;玩家1分数十位
   ADD SI,1
   MOV [SI],CH          ;玩家1分数个位

   POP AX
   POP BX
   POP CX
   POP DX
   RET
SHOWLSCORE ENDP
                        
SHOWRSCORE PROC     ;在当前光标位置显示右方分数，分数存入AL中,显示位置存入BH
   PUSH DX
   PUSH CX
   PUSH BX
   PUSH AX

   MOV AH,0
   MOV BL,100
   DIV BL              ;分数/100，商存入AL，余数存入AH 
   MOV BH,AL           ;BH存百位
   MOV AL,AH           
   MOV AH,0
   MOV BL,10           
   DIV BL              ;余下两位数/10，商存入AL(十位)，余数存入AH(个位)
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
   MOV [SI],BH         ;玩家2分数百位
   ADD SI,1
   MOV [SI],CL         ;玩家2分数十位
   ADD SI,1
   MOV [SI],CH         ;玩家2分数个位

   POP AX
   POP BX
   POP CX
   POP DX
   RET
SHOWRSCORE ENDP

DIS PROC NEAR          ;数码管显示分数子程序
   PUSH AX 
   PUSH BX
   PUSH CX
   PUSH SI
   PUSH DX 
   MOV  SI,OFFSET SCORE_TABLE 
   
   MOV  DX,MY8255_A            ;数码管所有部分都熄灭，整个数码管熄灭   
   MOV  AL,0FFH
   OUT  DX,AL  
   
   MOV  AL,[SI]              ;取出缓冲区0中存放键值 
   MOV  BX,OFFSET DTABLE                 
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;将键值作为偏移和键值基地址相加得到相应的键值 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;写入数码管A～Dp          
   MOV  DL,0FEH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;选通一个数码管 
   MOV  DX,MY8255_A          ;数码管所有部分都熄灭，整个数码管熄灭   
   MOV  AL,0FFH
   OUT  DX,AL
   
   MOV  AL,[SI+1]            ;取出缓冲区1中存放键值                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;将键值作为偏移和键值基地址相加得到相应的键值 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;写入数码管A～Dp        
   MOV  DL,0FDH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;选通一个数码管 
   MOV  DX,MY8255_A          ;数码管所有部分都熄灭，整个数码管熄灭   
   MOV  AL,0FFH
   OUT  DX,AL

   MOV  AL,[SI+2]            ;取出缓冲区2中存放键值                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;将键值作为偏移和键值基地址相加得到相应的键值 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;写入数码管A～Dp       
   MOV  DL,0FBH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;选通一个数码管 
   MOV  DX,MY8255_A          ;数码管所有部分都熄灭，整个数码管熄灭   
   MOV  AL,0FFH
   OUT  DX,AL

   MOV  AL,[SI+3]            ;取出缓冲区3中存放键值                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;将键值作为偏移和键值基地址相加得到相应的键值 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;写入数码管A～Dp       
   MOV  DL,0F7H
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;选通一个数码管 
   MOV  DX,MY8255_A          ;数码管所有部分都熄灭，整个数码管熄灭   
   MOV  AL,0FFH
   OUT  DX,AL
   
   MOV  AL,[SI+4]            ;取出缓冲区4中存放键值                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;将键值作为偏移和键值基地址相加得到相应的键值 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;写入数码管A～Dp             
   MOV  DL,0EFH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;选通一个数码管 
   MOV  DX,MY8255_A          ;数码管所有部分都熄灭，整个数码管熄灭   
   MOV  AL,0FFH
   OUT  DX,AL

   MOV  AL,[SI+5]            ;取出缓冲区5中存放键值                  
   MOV  BX,OFFSET DTABLE
   AND  AX,00FFH
   ADD  BX,AX                  
   MOV  AL,[BX]              ;将键值作为偏移和键值基地址相加得到相应的键值 
   MOV  DX,MY8255_B 
   OUT  DX,AL                ;写入数码管A～Dp           
   MOV  DL,0DFH
   MOV  AL,DL
   MOV  DX,MY8255_A 
   OUT  DX,AL                ;选通一个数码管 
   MOV  DX,MY8255_A          ;数码管所有部分都熄灭，整个数码管熄灭   
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

COUNTDOWN PROC          ;双人对战倒计时开始
   PUSH CX
   PUSH DX
   PUSH AX

   CURS 0,39            ;倒计时3
   COLCHAR 04EH,33H
   CALL SECOND
   
   CURS 0,39
   COLCHAR 04EH,32H     ;倒计时2
   CALL SECOND

   CURS 0,39
   COLCHAR 04EH,31H     ;倒计时1
   CALL SECOND

   CURS 0,37
   DISPMSG MSG9

   POP AX
   POP DX
   POP CX
   RET
COUNTDOWN ENDP 

WINLIGHT PROC           ;双人模式游戏胜利流水灯闪烁并等待空格按下
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

WAITKEY PROC            ;等待按键
   PUSH AX
 INWAIT:
   MOV AH,1            
   INT 16H
   JZ  INWAIT
   MOV AH,0CH          ;清空缓冲区
   MOV AL,0
   INT 21H

   POP AX
   RET
WAITKEY ENDP

DALLY PROC NEAR         ;游戏最内层循环延时
   PUSH CX
   MOV  CX,002FH
 D1:    
   MOV  AX,00FFH
   CALL DIS             ;显示数码管
 D2:    
   DEC  AX
   JNZ  D2
   LOOP D1
   POP  CX
   RET
DALLY ENDP

DALLY2 PROC NEAR        ;直流电机延时
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

SECOND PROC NEAR        ;倒计时延时一秒
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

DALLY1 PROC             ;流水灯延时
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

DALLY3 PROC             ;开始界面BGM延时
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

SHOWSPEED PROC          ;显示直流电机速度
   PUSH DX
   PUSH CX
   PUSH BX
   
   MOV  DX,0                   
   MOV  BX,10           ;计算AX/10
   DIV  BX
   MOV  BL,DL
   MOV  DL,AL                     
   
   ADD  DL,30H          ;商+30H，即为十位数ASCII码
   MOV  AH,2
   INT  21H
   
   MOV  DL,BL
   ADD  DL,30H          ;余+30H，即为个位数ASCII码
   MOV  AH,2
   INT  21H

   POP BX
   POP CX
   POP DX
   RET
SHOWSPEED ENDP

KJ PROC                 ;PWM子程序
   PUSH AX
   PUSH DX
   CMP  FPWM,01H        ;PWM为1，产生PWM的高电平
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
   MOV  AL, 10H         ;PB0=1 电机转动
   MOV  DX, MY8255_C
   OUT  DX,AL

 TEST2: 
   CMP  FPWM,02H        ;PWM为2，产生PWM的低电平
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
   MOV  AL,00H          ;PB0=0 电机停止
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
   SUB  AX,YK                  ;求偏差EK
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
   MOV  AX,R1       ;判断偏差EK是否在积分分离值的范围内实际速度小于目标速度
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

SEND PROC               ;完成变量输出到专用图形界面显示
   PUSH BX                     
   MOV BX,0D800H
   MOV ES,BX             
   MOV ES:[DI],AX 
   POP  BX      
   RET  
SEND ENDP

UPDOWN PROC             ;通过电脑键盘U/D键调整电机转速
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

UPDOWN2 PROC            ;通过实验箱键盘U/D键调整电机转速
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
   MOV  CH,0FEH         ;设置初始扫描列为第一列
   MOV  CL,00H          ;设置当前检测的是第几列,0表示第一列
 COLUM2: 
   MOV  AL,CH           ;选取一列，将X1～X4中一个置0            
   MOV  DX,MY8255_A 
   OUT  DX,AL
   MOV  DX,MY8255_C     ;读Y1～Y4，用于判断是哪一行按键闭合 
   IN   AL,DX

   CMP  AL,07H          ;是否为第4行
   JNE  CCNEXT2         ;不是则继续判断
   CMP  CL,00H
   JE   CCDOWN
   CMP  CL,01H
   JE  CCUP
   JMP  CCNEXT2         ;无视其他按键
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
   INC  CL              ;当前检测的列数递增   
   CMP  CL,02H          ;检测是否扫描到第4列
   JE   RETURN7         ;是则跳回到开始处
   ROL  CH,1            ;没检测到第4列则准备检测下一列
   JMP  COLUM2
 RETURN7:   
   POP  DX
   POP  CX
   POP  BX
   POP  AX
   RET
UPDOWN2 ENDP

ZHILIU PROC             ;直流电机
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
   MOV  IP_BAK1,AX           ;保存定时器0中断处理程序入口偏移地址
   MOV  AX,OFFSET TIMERISR      
   MOV  ES:[DI],AX           ;设置实验定时中断处理程序入口偏移地址
   ADD  DI,2
   MOV  AX,ES:[DI]             
   MOV  CS_BAK1,AX           ;保存定时器0中断处理程序入口段地址
   MOV  AX,SEG TIMERISR
   MOV  ES:[DI],AX           ;设置实验定时中断处理程序入口段地址
   
   IN   AL,21H
   MOV  IM_BAK1,AL           ;保存INTR原中断屏蔽字
   AND  AL,0F7H
   OUT  21H,AL               ;打开定时器0中断屏蔽位
   
   MOV  DI,INTR_IVADD          
   MOV  AX,ES:[DI]
   MOV  IP_BAK,AX            ;保存INTR原中断处理程序入口偏移地址
   MOV  AX,OFFSET MYISR
   MOV  ES:[DI],AX           ;设置当前中断处理程序入口偏移地址
   ADD  DI,2
   MOV  AX,ES:[DI]
   MOV  CS_BAK,AX            ;保存INTR原中断处理程序入口段地址
   MOV  AX,SEG MYISR
   MOV  ES:[DI],AX           ;设置当前中断处理程序入口段地址
   
   IN   AL,21H
   MOV  IM_BAK,AL            ;保存INTR原中断屏蔽字
   AND  AL,7FH
   OUT  21H,AL               ;打开INTR的中断屏蔽位
                                 
   MOV  AL,81H               ;初始化8255
   MOV  DX,MY8255_MODE       ;工作方式0，A口，B口，C口均输出
   OUT  DX,AL
   MOV  AL,00H
   MOV  DX,MY8255_C          ;C口高4位输出0，电机不转
   OUT  DX,AL
   
   MOV  DX,PC8254_MODE       ;初始化PC机定时器0，定时1ms
   MOV  AL,36H               ;计数器0，方式3
   OUT  DX,AL
   MOV  DX,PC8254_COUNT0
   MOV  AL,8FH               ;低8位
   OUT  DX,AL
   MOV  AL,04H
   OUT  DX,AL                ;高8位,048FH=1168
    
    STI
    
 WAIT0:
   MOV  AL,TS           ;判断采样周期到否？   TS=20 TC=0
   SUB  AL,TC
   JNC  WAIT0           ;没到则跳过往下执行  TC>TS时采样一次
   
   MOV  TC,00H          ;采样周期到，将采样周期变量清0
   MOV  AL,ZVV
   MOV  AH,00H
   MOV  YK,AX           ;得到反馈量YK 
   CALL PID             ;调用PID子程序，得到控制量CK
   MOV  AL,CK           ;把控制量转化成PWM输出
   SUB  AL,80H         
   JC   IS0             ;AL<80H转ISO
   MOV  AAAA,AL
   JMP  COU
 IS0:   
   MOV  AL,10H          ;电机的启动值不能低于10H
   MOV  AAAA,AL   
 COU:   
   MOV  AL,7FH
   SUB  AL,AAAA
   MOV  BBB,AL
   
   CURS 31,18
   MOV  AX,YK           ;将反馈值YK送到屏幕显示
   CALL SHOWSPEED
   
   MOV  AX,SPEC         ;将给定值输出给专用界面显示
   MOV  DI,0D80H
   CALL SEND
   
   MOV  AX,YK           ;将反馈值YK输出给专用界面显示
   MOV  DI,0D81H
   CALL SEND 
      
   MOV  AL,CK           ;将控制量CK输出给专用界面显示
   MOV  DI,0D82H
   CALL SEND

   CALL DALLY2 
   CALL CCSCAN          ;扫描实验箱键盘，是否有键按下
   JZ  NEXT3
   CALL UPDOWN2
 NEXT3:    
   MOV  AH,1
   INT  16H
   JZ   WAIT0 
      
   PUSH AX
   MOV  AH,0CH         ;清空缓冲区
   MOV  AL,0
   INT  21H
   POP  AX
   
   CMP  AL,20H         ;按下空格退出
   JZ   EXIT
   CALL UPDOWN
   JMP  WAIT0   
    
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
   POP CX
   POP BX
   POP AX
   RET    
ZHILIU ENDP

;#################################################################

;########################## 中断处理程序 ################################
MYISR PROC              ;系统总线INTR中断处理程序，电机每转一圈触发一次脉冲
   PUSH AX
   PUSH BX
   PUSH CX
   PUSH DX
   MOV  AX,DATA
   MOV  DS,AX
     
   MOV  AL,MARK  
   CMP  AL,01H          ;当MARK=AL=01H时，跳到IN1计算转速
   JZ   IN1
   
   MOV  MARK,01H        ;否则令MARK=01H，收到一次脉冲信号，MARK0置1，等下一次脉冲，计算转速。
   JMP  IN2

 IN1:
   MOV  MARK,00H        ;计算转速
 VV:    
   MOV  DX,0000H
   MOV  AX,03E8H
   MOV  CX,VADD
   CMP  CX,0000H        ;判断VADD是否等于0
   JZ   MM1     
   DIV  CX              ;DXAX/VADD即1000/VADD=AX...DX
 MM:    
   MOV  ZV,AL
    MOV  VADD,0000H     
 MM1:   
   MOV  AL,ZV
    MOV  ZVV,AL

 IN2:   
   MOV  AL,20H          ;向PC机内部8259发送中断结束命令
   OUT  20H,AL
   POP  DX
   POP  CX
   POP  BX
   POP  AX
   IRET
MYISR ENDP

TIMERISR PROC           ;PC机定时器0中断处理程序
   PUSH AX
   PUSH BX                     
   PUSH CX
   PUSH DX
   MOV  AX,DATA
   MOV  DS,AX
   
   INC  TC              ;采样周期变量加1
   CALL KJ
   CLC
         
 NEXT2:  
   CLC                  ;清除标志位寄存器
   CMP  MARK,01H
   JC   TT1
   
   INC  VADD
   CMP  VADD,0700H      ;转速值溢出，赋极值
   JC   TT1
   
   MOV  VADD,0700H
   MOV  MARK,00H
 TT1:   
   MOV  AL,20H          ;中断结束，发EOI命令
   OUT  20H,AL
   POP  DX
   POP  CX
   POP  BX
   POP  AX
   IRET
TIMERISR ENDP

CODE    ENDS
    END     START   

