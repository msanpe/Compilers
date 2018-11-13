/*MIGUEL SANCHO PEÑA
/*------------------------------ plp4.l -------------------------------*/
D	[0-9]
L	[a-zA-Z]
LD	[0-9a-zA-Z]

%{

#include <string.h>
#include <string>
#include <iostream>

using namespace std;

#include "comun.h"
#include "plp5.tab.h"

int ncol = 1;
int nlin = 1;

int finfichero = 0;

int ret(int token);
// funcion que actualiza nint y ncol, y devuelve token

void msgErro(int nerror, int nlin,int ncol,const char *s);
// funcion para mostrar error

%}

%x COMENTARIO

%%
%{
/* codigo local */
%}

" "			{ncol++;}
[\t]		{ncol++;}
[\n]		{ncol=1; nlin++;}
"//"(.)*	{; /* comentario de una linea */}

"boolean"		{return ret(BOOLEAN);}
"int"			{return ret(INT);}
"double"		{return ret(DOUBLE);}
"main"			{return ret(MAINE);}
"System"		{return ret(SYSTEM);}
"out"			{return ret(OUT);}
"in"			{return ret(IN);}
"static"		{return ret(STATIC);}
"void"			{return ret(VOID);}
"Scanner"		{return ret(SCANNER);}
"nextInt"		{return ret(NEXTINT);}
"nextDouble"	{return ret(NEXTDOUBLE);}
"if"			{return ret(IF);}
"else"			{return ret(ELSE);}
"while"			{return ret(WHILE);}
"true"			{return ret(TRUE);}
"false"			{return ret(FALSE);}
"println"		{return ret(PRINTLN);}
"print"			{return ret(PRINT);}
"String"		{return ret(STRING);}
"class"			{return ret(CLASS);}
"import"		{return ret(IMPORT);}
"new"			{return ret(NEW);}
"public"		{return ret(PUBLIC);}


{L}({LD})*		{return ret(id);}
{D}+			{return ret(nentero);}
{D}+(\.){D}+	{return ret(nreal);}
","				{return ret(coma);}
";"				{return ret(pyc);}
"."				{return ret(punto);}
"("				{return ret(pari);}
")"				{return ret(pard);}
">"				{return ret(relop);}
">="			{return ret(relop);}
"+"				{return ret(addop);}
"-"				{return ret(addop);}
"*"				{return ret(mulop);}
"/"				{return ret(mulop);}
"="				{return ret(asig);}
"["				{return ret(cori);}
"=="			{return ret(relop);}
"!="			{return ret(relop);}
"<"				{return ret(relop);}
"<="			{return ret(relop);}
"]"				{return ret(cord);}
"{"				{return ret(llavei);}
"}"				{return ret(llaved);}
"&&"			{return ret(AND);}
"||"			{return ret(OR);}
"!"				{return ret(NOT);}
.				{msgError(ERRLEXICO,nlin,ncol,yytext);}

%%

int yywrap(void) {finfichero=1; return 1;}

int ret(int token){
	yylval.lexema = strdup(yytext);
	yylval.ncol = ncol;
	yylval.nlin = nlin;
	ncol += (strlen(yytext));
	return(token);
}
