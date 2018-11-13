/*------------------------------ plp4.l -------------------------------*/
/* definiciones*/

D    [0-9]
L    [a-zA-Z]
LD   [0-9a-zA-Z]

%{
#include <string.h> 
#include <string>
#include <iostream>

using namespace std;

#include "comun.h"
#include "plp4.tab.h"

int ncol = 1,
    nlin = 1;

int findefichero = 0;

int ret(int token);  
// función que actualiza 'nlin' y 'ncol' y devuelve el token

void msgError(int nerror, int nlin, int ncol, const char *s);
// función para producir mensajes de error

%}

%x COMENTARIO

%%
%{
/* expresiones regulares - acciones */
/* codigo local */
%}

" "                {ncol++;}
[\t]               {ncol++;}
[\n]               {nlin++;ncol=1;}
"/*"                    {ncol += strlen(yytext);BEGIN(COMENTARIO);}
<COMENTARIO>[^/*\n]+    {ncol += strlen(yytext);}
<COMENTARIO>\n          {nlin++;ncol=1;}
<COMENTARIO><<EOF>>     {msgError(ERRLEXEOF,-1,-1,"");}
<COMENTARIO>"*/"        {ncol+=strlen(yytext); BEGIN(INITIAL);}
<COMENTARIO>[*/]        {ncol += strlen(yytext);}

"class"         {return ret(tkclass);}
"public"        {return ret(tkpublic);}
"private"       {return ret(tkprivate);}
"float"         {return ret(tkfloat);}
"int"           {return ret(tkint);}
"return"        {return ret(tkreturn);}
        /* Las palabras reservadas deben aparecer antes de la regla que
          reconoce los identificadores, para evitar que sean reconocidas
          como identificadores en lugar de como palabras reservadas */            
{D}+            {return ret(entero);}
{L}({LD})*      {return ret(id);}
{D}+(\.){D}+    {return ret(real);}
"("				{return ret(pari);}
")"				{return ret(pard);}
"*"			{return ret(mulop);}
"+"			{return ret(addop);}
"/"     {return ret(mulop);}
"-"     {return ret(addop);}
";"				{return ret(pyc);}
":" 			{return ret(dosp);}
","				{return ret(coma);}
"="				{return ret(asig);}
"{"				{return ret(llavei);}
"}"				{return ret(llaved);}
.               {msgError(ERRLEXICO,nlin,ncol,yytext);}

%%
/* código */
int yywrap(void) {findefichero=1; return 1;} /* para no tener que linkar con la
                                libreria del lex */


int ret(int token)
{
   yylval.lexema=strdup(yytext);
   yylval.nlin=nlin;
   yylval.ncol=ncol;
   ncol+=(strlen(yytext));
   return(token);
}
