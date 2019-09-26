# 第一次实验报告

## 一、实验设计

```c
%option noyywrap
%x comment    //设置comment状态，用于实现注释的识别及分析
%{
/*****************声明和选项设置  begin*****************/
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
int files_count = 0;    // 默认标识符
int lines;
int pos_start;
int pos_end;

enum cminus_token_type{
	ERROR = 258,
	ADD = 259,
	SUB = 260,
	MUL = 261,
	DIV = 262,
	LT = 263,
	LTE = 264,
	GT = 265,
	GTE = 266,
	EQ = 267,
	NEQ = 268,
	ASSIN = 269,
	SEMICOLON = 270,
	COMMA = 271,
	LPARENTHESE = 272,
	RPARENTHESE = 273,
	LBRACKET = 274,
	RBRACKET = 275,
	LBRACE = 276,
	RBRACE = 277,
	ELSE = 278,
	IF = 279,
	INT = 280,
	RETURN = 281,
	VOID = 282,
	WHILE = 283,
	IDENTIFIER = 284, 
	NUMBER = 285,
	LETTER = 286,
	ARRAY = 287,
	EOL = 288,
	COMMENT = 289,
	BLANK = 290
};
/*****************end*****************/

%}
/***正规定义***/
digit [0-9]
number {digit}+
letter [A-Za-z]
id {letter}+
array {id}\[{digit}+\]
delim [ \t]
blank {delim}+
%%

 /****请在此补全所有flex的模式与动作  start******/
"+"	{return (ADD);}
"-" {return (SUB);}
"*" {return (MUL);}
"/" {return (DIV);}
"<" {return (LT);}
"<=" {return (LTE);}
">" {return (GT);}
">=" {return (GTE);}
"==" {return (EQ);}
"!=" {return (NEQ);}
"=" {return (ASSIN);}
";" {return (SEMICOLON);}
"," {return (COMMA);}
"(" {return (LPARENTHESE);}
")" {return (RPARENTHESE);}
"[" {return (LBRACKET);}
"]" {return (RBRACKET);}
"{" {return (LBRACE);}
"}" {return (RBRACE);}
else {return ELSE;}
if {return IF;}
int {return INT;}
return {return RETURN;}
void {return VOID;}
while {return WHILE;}
{array} {return ARRAY;}
{id} {return IDENTIFIER;}
{number} {return NUMBER;}
\n {return EOL;}
{blank} {return BLANK;}
"/*" {pos_start += 2; BEGIN comment;}    //进入comment状态
<comment>"*/" {pos_start += 2; BEGIN 0;}    //如果遇到"*/"，就进入初始状态，退出comment状态
<comment>. {return COMMENT;}    //识别注释中除换行符的其他字符
<comment>\n {return EOL;}    //识别换行符

. {return ERROR;}


 /****  end******/
%%

/****************请按需求补全C代码 start*************/

/// \brief analysize a *.cminus file
///
///	\param input_file_name
/// \param output_file_name
/// \todo student should fill this function
void analyzer(char* input_file_name, char* output_file_name){
	char input_path[256] = "./testcase/";
	strcat(input_path, input_file_name);
	char output_path[256] = "./tokens/";
	strcat(output_path, output_file_name);
	if(!(yyin = fopen(input_path,"r"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	printf("[START]: Read from: %s\n", input_file_name);
	FILE *fp = fopen(output_path,"w+");
	int token;
	lines = 1;    //当分析一个新文件时，将行数重置
	pos_start = 1;    //当分析一个新文件时，将列数重置
	while(token = yylex()){
		switch(token){
			case ERROR:
				pos_end = pos_start + yyleng;    //计算列数
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				pos_start = pos_end;
				break;
			case COMMENT:
				pos_start += 1;
				break;
			case BLANK:
				pos_start += yyleng;
				break;
			case EOL:
				lines += 1;    //将行数加一，列数置为零
				pos_start = 1;
				break;
			default :
				pos_end = pos_start + yyleng;
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
				pos_start = pos_end;
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}

/// \brief get all file paths under 'testcase' directory
///
/// under 'testcase' directory, there could be many *.cminus files.
/// \todo student should fill this function
void getAllTestcase(char filename[][256]){
	DIR *dp = opendir("./testcase");    //打开目录
	int i = 0;    //标识第i个文件
	struct dirent *file;    //指向读取的文件
	while (file = readdir(dp)) {    //读取文件
		if (strstr(file->d_name, ".cminus")) {    //在指针指向的文件中寻找".cminus"子串
			strcpy(filename[i], file->d_name);    //若找到，将文件名复制到filenam[i]
			i++;
		}
	}
	files_count = i;    //文件数量
	closedir(dp);    //关闭目录
}

/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
///	process all *.cminus files under 'testcase' directory,
/// then create *.tokens files under 'tokens' directory
/// \todo student should fill this function
int main(int argc, char **argv){
	char filename[10][256];
	char output_file_name[256];
	char suffix[] = ".tokens";
	getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
		int j = 0;
		while (filename[i][j] != '.') {    //将.cminus前面的字符串复制到output_file_name中
			output_file_name[j] = filename[i][j];
			j++;
		}
		output_file_name[j] = 0;
		strcat(output_file_name, suffix);    //将".tokens"缀于文件名后
		analyzer(filename[i],output_file_name);
	}
	return 0;
}
/**************** end*************/

```

## 二、遇到的问题、分析及解决方案

1. 问题：无法正确识别注释。即有多个注释时，注释之间的代码也被视为注释。

   分析：flex的正则模式识别会匹配最长的串，即会匹配/* a \*/ c  /\* b */，而不会在a后面的结束符停下。

   解决方案：设定一个comment状态用于注释的识别。当看到"/*"时进入comment状态，对注释中的字符进行分析；当看到"\*/"时退出comment状态，继续识别代码。

2. 问题：无法正确识别行数。

   分析：当\n与空白符连接时，无法正确识别。

   解决方案：经过检查，我将blank写成{ |\n|\t}+。而flex会按可匹配的最长的串进行匹配，即如果\n与空白符连接，flex就会将其视为空白符，而不是换行符。

## 三、花费时间

1. 了解flex：2h
2. 理解实验：3h
3. 代码编写：3h
4. debug：2h
5. 设计样例：10min
6. 写报告：50min

总时间：11h