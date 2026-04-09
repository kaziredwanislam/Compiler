%option noyywrap

%{
#include<stdio.h>
#include<string.h>
using namespace std;
#include "2005108.h"
#include "y.tab.h"
extern FILE* fp;
extern FILE* fp2;
extern FILE* fp3;
extern SymbolTable st;
    int wordCount=0;
    int lineCount=0;   
    int p=0;
    int errorcount=0;
    int warningcount=0;
    int required_tab=0;
    SymbolInfo *si;
    char stringContent[10000];
    char logstring[10000];
    char single_Line_Comment_string[11000];
    char multiple_ine_Comment_string[11000];
    int stringline=1;
    int tab_count=0;
    int space_count=0;
%}
%x String
%x Escape
%x comment
%x SINGLE_LINE_COMMENT
%x ESCAPE_SLC
%x newlinehandling
Letter [a-zA-Z]
digit [0-9]
Integer [0-9]+
Exponent [Ee][+-]?[0-9]+
ID [A-Za-z]+[_0-9A-Za-z]* 

%%

[\n] {
    lineCount++;
}

^[ \t]*[A-Za-z0-9]+ {
    int i;
    int spaces=0;
    int tabs=0;
    for (i=0;i<yyleng;i++) {
        if (yytext[i]==' ') {
            spaces++;
        } 
        else if (yytext[i]=='\t') {
            tabs++;
        }
    }
    
    if(space_count>=4)
    {
        tab_count+=space_count/4;
        space_count-=space_count/4;
    }
    //printf("Tabs: %d,Spaces: %d,Required Tabs: %d Line: %d\n", tabs, spaces,required_tab, lineCount + 1);
    if(required_tab==0&&(space_count>0||tabs>0))
    {
        warningcount++;
        //fprintf(fp2,"Line# %d: Warning,no tab requrired but got space.\n",lineCount+1);
    }
    else if(required_tab>0 && required_tab!=tabs)
    {
        warningcount++;
        //fprintf(fp2,"Line# %d: warning, %d of tabs needed but got %d tabs.\n",lineCount+1,required_tab,tabs);
    }
    yyless(0);
}


if {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"IF","if");
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="if";
    si->Type="IF";
    si->real_Type="IF";
    yylval.symbol=si;
    return IF;
    }
else {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"ELSE","else");
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="else";
    si->Type="ELSE";
    si->real_Type="Else";
    yylval.symbol=si;
    return ELSE;
    }
for {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"FOR","for");
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="for";
    si->Type="FOR";
    si->real_Type="FOR";
    yylval.symbol=si;
    return FOR;
    }
while {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"WHILE","while");
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="while";
    si->Type="WHILE";
    si->real_Type="WHILE";
    yylval.symbol=si;
    return WHILE;
    }
do {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"DO","do");
    }
break {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"BREAK","break");

    }

int {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"INT","int");
    si=new SymbolInfo();
    si->Type="INT";
    si->Name="int";
    si->real_Type="INT";
    si->terminal=true;
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    yylval.symbol=si;
    
    return INT;
    }

struct {
    wordCount++;
    si=new SymbolInfo();
    si->Type="STRUCT";
    si->Name="struct";
    si->real_Type="struct";
    si->terminal=true;
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    yylval.symbol=si;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"STRUCT","struct");
    return STRUCT;
}
char {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"CHAR","char");
    }
float {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"FLOAT","float");
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="float";
    si->Type="FLOAT";
    si->real_Type="FLOAT";
    yylval.symbol=si;
    return FLOAT;
    }
double {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"DOUBLE","double");
    }
void {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"VOID","void");
    si=new SymbolInfo();
    si->Type="VOID";
    si->Name="void";
    si->real_Type="VOID";
    si->terminal=true;
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    yylval.symbol=si;
    return VOID;
    }
return {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"RETURN","return");
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="return";
    si->Type="RETURN";
    si->real_Type="RETURN";
    yylval.symbol=si;
    return RETURN;
    }
switch {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"SWITCH","switch");
  
    }
case {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"CASE","case");
   
    }
default {
    wordCount++;
    fprintf(fp2,"Line#%d: Token <%s> Lexeme %s found\n",lineCount+1,"DEFAULT","default");
    }
continue {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"CONTINUE","continue");
    }

println {
    wordCount++;
    fprintf(fp2,"Line# %d: Token <%s> Lexeme %s found\n",lineCount+1,"PRINTLN","println");
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="println";
    si->Type="PRINTLN";
    si->real_Type="println";
    yylval.symbol=si;
    return PRINTLN;
}

{digit}*(\.{digit}+)(\.{digit}+)+(E[+-]{digit}*)? {
    errorcount++;
    fprintf(fp2,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",lineCount+1,yytext);
}

{digit}*(\.{digit}+)?(E[+-]?{digit}*\.{digit}*) {
    errorcount++;
    fprintf(fp2,"Error at line# %d: ILLFORMED_NUMBER %s\n",lineCount+1,yytext);
}

{digit}*(\.{digit}+)(E[+-]?{digit}+)? {
    fprintf(fp2,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",lineCount+1,yytext);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="CONST_FLOAT";
     si->real_Type="CONST_FLOAT";
    yylval.symbol=si;
    return CONST_FLOAT;
}

{digit}*(\.{digit}+)?(E[+-]?{digit}+) {
    fprintf(fp2,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",lineCount+1,yytext);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="CONST_FLOAT";
    si->real_Type="CONST_FLOAT";
    yylval.symbol=si;
    return CONST_FLOAT;
}

\'[0-9A-Za-z ]* {
    errorcount++;
    fprintf(fp2,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",lineCount+1,yytext);
}

{digit}+{Letter}+({digit}*{Letter}*) {
    errorcount++;
    fprintf(fp2,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",lineCount+1,yytext);
}

\'[0-9A-Za-z ]+[0-9A-Za-z ]+\' {
    errorcount++;
    fprintf(fp2,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n",lineCount+1,yytext);
}


{Integer} {
    fprintf(fp2,"Line# %d: Token <CONST_INT> Lexeme %s found\n",lineCount+1,yytext);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="CONST_INT";
    si->real_Type="CONST_INT";
    yylval.symbol=si;
    return CONST_INT;
}

"/*" {
    multiple_ine_Comment_string[0]='\0';
    strcat(multiple_ine_Comment_string,"/*");
    p=lineCount;
    BEGIN(comment);
}

<comment>[^*\n]* { 
    strcat(multiple_ine_Comment_string,yytext);
 }     
<comment>"*"+[^*/\n]* {
    strcat(multiple_ine_Comment_string,yytext);
}
<comment>\n {
    ++lineCount;
    strcat(multiple_ine_Comment_string,yytext);
}            
<comment>"*"+"/"  {
    strcat(multiple_ine_Comment_string,yytext);
    errorcount++;
    fprintf(fp2,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n", p+1, multiple_ine_Comment_string);
    multiple_ine_Comment_string[0]='\0';
    BEGIN(INITIAL);
}      
<comment><<EOF>> {
    errorcount++;
    fprintf(fp2,"Error at line# %d: UNFINISHED_COMMENT %s found\n",lineCount+1,multiple_ine_Comment_string);
    
    multiple_ine_Comment_string[0]='\0';
    return 0;
} 

"//" {
    single_Line_Comment_string[0]='\0';
    p=lineCount;
    strcat(single_Line_Comment_string,yytext);
    BEGIN(SINGLE_LINE_COMMENT);
}

<SINGLE_LINE_COMMENT>[^\\\n]* {
    strcat(single_Line_Comment_string, yytext);
}

<SINGLE_LINE_COMMENT>\\ {
    strcat(single_Line_Comment_string,yytext);
    p++;
    BEGIN(ESCAPE_SLC);
}

<ESCAPE_SLC>[\n] {
    strcat(single_Line_Comment_string,"\n");
    BEGIN(SINGLE_LINE_COMMENT);
}

<SINGLE_LINE_COMMENT>\n {
    fprintf(fp2, "Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n", lineCount + 1, single_Line_Comment_string);
    p++;
    lineCount=p;
    p=0;
    single_Line_Comment_string[0] = '\0'; // Reset comment buffer
    BEGIN(INITIAL);
}
\'\' {
    errorcount++;
    fprintf(fp2,"Error at line# %d: EMPTY_CONST_CHAR '' \n",lineCount+1);
}
\'\\\' {
    errorcount++;
    fprintf(fp2,"Error at line# %d: UNFINISHED_CONST_CHAR '\\\'\n",lineCount+1);
}

'\\'' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme ' found\n",lineCount+1);
    }
'\\\"' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme '%c' found\n",lineCount+1,yytext[1]);
    }
'\\n' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme '\n' found\n",lineCount+1);
    }   
'\\t' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme        found\n",lineCount+1);
    }  
'\\\\' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme '\\' found\n",lineCount+1);
    } 
'\\a' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme '\a' found\n",lineCount+1);
    }
'\\f' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme '\f' found\n",lineCount+1);
    } 
'\\r' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme '\r' found\n",lineCount+1);
    }
'\\b' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme '\b' found\n",lineCount+1);
    }
'\\v' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme '\v' found\n",lineCount+1);
    }  
\'[a-zA-Z]\' {
    fprintf(fp2,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",lineCount+1,yytext[1]);
    }



[*/%] {
    fprintf(fp2,"Line# %d: Token <MULOP> Lexeme %c found\n",lineCount+1,yytext[0]);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="MULOP";
    si->real_Type="MULOP";
    yylval.symbol=si;
    return MULOP;
    }
"++" {
    fprintf(fp2,"Line# %d: Token <INCOP> Lexeme ++ found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="++";
    si->Type="INCOP";
    si->real_Type="INCOP";
    yylval.symbol=si;
    return INCOP;
    }
"--" {
    fprintf(fp2,"Line# %d: Token <INCOP> Lexeme -- found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="--";
    si->Type="DECOP";
    si->real_Type="DECOP";
    yylval.symbol=si;
    return DECOP;
    }
"<=" {
    fprintf(fp2,"Line# %d: Token <RELOP> Lexeme <= found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="RELOP";
    si->real_Type="RELOP";
    yylval.symbol=si;
    return RELOP;
    }
">=" {
    fprintf(fp2,"Line# %d: Token <RELOP> Lexeme >= found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="MULOP";
    si->real_Type="MULOP";
    yylval.symbol=si;
    return RELOP;
    }
[<>] {
    fprintf(fp2,"Line# %d: Token <RELOP> Lexeme %c found\n",lineCount+1,yytext[0]);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="RELOP";
    si->real_Type="RELOP";
    yylval.symbol=si;
    return RELOP;
    }
"==" {
    fprintf(fp2,"Line# %d: Token <RELOP> Lexeme == found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="==";
    si->Type="RELOP";
    si->real_Type="RELOP";
    yylval.symbol=si;
    return RELOP;
    }
"!=" {
    fprintf(fp2,"Line# %d: Token <RELOP> Lexeme != found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="RELOP";
    si->real_Type="RELOP";
    yylval.symbol=si;
    return RELOP;
    }
[+-] {
    fprintf(fp2,"Line# %d: Token <ADDOP> Lexeme %c found\n",lineCount+1,yytext[0]);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=yytext;
    si->Type="ADDOP";
    si->real_Type="ADDOP";
    yylval.symbol=si;
    return ADDOP;
    }
"=" {
    fprintf(fp2,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",lineCount+1,yytext);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="=";
    si->Type="ASSIGNOP";
    si->real_Type="ASSIGNOP";
    yylval.symbol=si;
    return ASSIGNOP;
    }
"&&" {
    fprintf(fp2,"Line# %d: Token <LOGICOP> Lexeme && found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="&&";
    si->Type="LOGICOP";
    si->real_Type="LOGICOP";
    yylval.symbol=si;
    return LOGICOP;
    }
"||" {
    fprintf(fp2,"Line# %d: Token <LOGICOP> Lexeme || found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="||";
    si->Type="LOGICOP";
    si->real_Type="LOGICOP";
    yylval.symbol=si;
    return LOGICOP;
    }
[&|^] {
    fprintf(fp2,"Line# %d: Token <BITOP> Lexeme %c found\n",lineCount+1,yytext[0]);
    }
"<<" {
    fprintf(fp2,"Line# %d: Token <BITOP> Lexeme << found\n",lineCount+1);
    }
">>" {
    fprintf(fp2,"Line# %d: Token <BITOP> Lexeme >> found\n",lineCount+1);
    }
"!" {
    fprintf(fp2,"Line# %d: Token <NOT> Lexeme ! found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="!";
    si->Type="NOT";
    si->real_Type="NOT";
    yylval.symbol=si;
    return NOT;
    }
"(" {
    fprintf(fp2,"Line# %d: Token <LPAREN> Lexeme ( found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="(";
    si->Type="LPAREN";
    si->real_Type="LPAREN";
    yylval.symbol=si;
    return LPAREN;
    }
")" {
    fprintf(fp2,"Line# %d: Token <RPAREN> Lexeme ) found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=")";
    si->Type="RPAREN";
    si->real_Type="RPAREN";
    yylval.symbol=si;
    return RPAREN;
    }
"{" {
    st.Enter_Scope();
    required_tab++;
    fprintf(fp2,"Line# %d: Token <LCURL> Lexeme { found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="{";
    si->Type="LCURL";
    si->real_Type="LCURL";
    yylval.symbol=si;
    return LCURL;
    }
"}" {
   
    if(required_tab>0)required_tab--;
    fprintf(fp2,"Line# %d: Token <RCURL> Lexeme } found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name="}";
    si->Type="RCURL";
    si->real_Type="RCURL";
    yylval.symbol=si;
    return RCURL;
    }
"[" {
    fprintf(fp2,"Line# %d: Token <LSQUARE> Lexeme [ found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
      si->terminal=true;
    si->Name="[";
    si->Type="LSQUARE";
    si->real_Type="LSQUARE";
    yylval.symbol=si;
    return LTHIRD;
    }
"]" {
    fprintf(fp2,"Line# %d: Token <RSQUARE> Lexeme ] found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    
    si->terminal=true;
    si->Name="]";
    si->Type="RSQUARE";
    si->real_Type="RSQUARE";
    yylval.symbol=si;
    return RTHIRD;
    }
"," {
    fprintf(fp2,"Line# %d: Token <COMMA> Lexeme , found\n",lineCount+1);
    si=new SymbolInfo();
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    si->terminal=true;
    si->Name=",";
    si->terminal=true;
    si->Type="COMMA";
    si->real_Type="COMMA";
    yylval.symbol=si;
    return COMMA;
    }
";" {
    fprintf(fp2,"Line# %d: Token <SEMICOLON> Lexeme ; found\n",lineCount+1);
    si=new SymbolInfo();
    si->Type="SEMICOLON";
    si->real_Type="SEMICOLON";
    si->Name=";";
    si->startLine=lineCount+1;
    si->terminal=true;
    si->endLine=lineCount+1;
    yylval.symbol=si;
    return SEMICOLON;
    }

{ID} {
    std::string tokenText(yytext);
    fprintf(fp2,"Line# %d: Token <ID> Lexeme %s found\n",lineCount+1,yytext);
        
    si=new SymbolInfo();
    si->set_Name(tokenText);
    si->set_Type("ID");
    si->real_Type="ID";
    si->terminal=true;
    si->startLine=lineCount+1;
    si->endLine=lineCount+1;
    yylval.symbol=si;
    
    return ID;
}

\" {
    stringContent[0]='\0';
    logstring[0]='\0';
    stringline=1;
    p=lineCount;
    strcat(logstring,yytext);
    BEGIN(String);
}

<String>([^\"\n\\])* {
    strcat(stringContent,yytext);
    strcat(logstring,yytext);
}

<String>\\ {
    strcat(logstring,yytext);
    BEGIN(Escape);
}

<Escape>t {
    strcat(stringContent,"\t");
    strcat(logstring,yytext);
    BEGIN(String);
}

<Escape>n {
    lineCount++;
    strcat(stringContent,"\n");
    strcat(logstring,yytext);
    BEGIN(String);
}

<Escape>' {
    strcat(stringContent,"'");
    strcat(logstring,yytext);
    BEGIN(String);
}

<Escape>a {
    strcat(stringContent,"\a");
    strcat(logstring,yytext);
    BEGIN(String);
}
<Escape>r {
    strcat(stringContent,"\r");
    strcat(logstring,yytext);
    BEGIN(String);
}
<Escape>f {
    strcat(stringContent,"\f");
    strcat(logstring,yytext);
    BEGIN(String);
}
<Escape>b {
    strcat(stringContent,"\b");
    strcat(logstring,yytext);
    BEGIN(String);
}
<Escape>v {
    strcat(stringContent,"\v");
    strcat(stringContent,yytext);
}

<Escape>\\[^\n] {
    strcat(stringContent,yytext);
    strcat(logstring,yytext);
    BEGIN(String);
}

<Escape><<EOF>> {
    errorcount++;
    fprintf(fp2,"Error at line# %d: UNFINISHED_STRING %s\n",lineCount+1,logstring);
    

    return 0;
}

<Escape>\n {
    lineCount++;
    stringline++;
    strcat(stringContent,"\n");
    strcat(logstring,"\n");
    BEGIN(String);
}


<String>\n {
    errorcount++;
    fprintf(fp2,"Error at line# %d: UNFINISHED_STRING %s\n",lineCount+1,logstring);
    lineCount++;
    BEGIN(INITIAL);
}

<String><<EOF>> {
    errorcount++;
    fprintf(fp2,"Error at line#%d: UNFINISHED_STRING %s\n",lineCount+1,logstring);

    return 0;
}

<String>\" {
    BEGIN(INITIAL);
    strcat(logstring,yytext);
    
    if(stringline==1)
    {
        fprintf(fp2,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",p+1,logstring);
    }
    else 
    {
        fprintf(fp2,"Line# %d: Token <MULTIPLE LINE STRING> Lexeme %s found\n",p+1,logstring);
    }
    stringline=1;
    stringContent[0]='\0';
}

<<EOF>> {
    
    return 0;
}

[^a-zA-Z0-9_{}<>=!+\-*/%&|^;,()\[\]\"\.\'\t\r\n\f\v\\\' '] {
    errorcount++;
    fprintf(fp2, "Error at line# %d: UNRECOGNIZED_CHAR %s\n", lineCount + 1, yytext);

}

%%

