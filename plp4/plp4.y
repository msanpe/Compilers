/*------------------------------ ejemplo.y -------------------------------*/
// definiciones de tokens, código auxiliar
%token tkclass id
%token llavei llaved
%token tkpublic tkprivate dosp
%token pari pard
%token pyc coma
%token tkint tkfloat
%token asig tkreturn
%token addop mulop
%token real entero


%{

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <sstream>
#include <list>

#include "comun.h"

// variables y funciones del A. Léxico
extern int ncol, nlin, findefichero;

extern int yylex();
extern char *yytext;
extern FILE *yyin;

int yyerror(const char *s);

const int ENTERO=1;
const int REAL=2;
const int VARIABLE=3;
const int CLASE=4;
const int FUNCION=5;

std::string operador, s1, s2;  // string auxiliares
int contador = 10;
int tipo;
int longitud = 0;

TablaSimbolo *tablaActual = new TablaSimbolo(NULL);

bool anyadir(TablaSimbolo *ta, Simbolo s);
Simbolo buscar(TablaSimbolo *ta, const std::string& nombre);
TablaSimbolo* crearTabla(TablaSimbolo *padre, std::string nombre);
void imprimirSimbolos(TablaSimbolo *ta);
void imprimirSimbolo(Simbolo s);




%}

%% // separador
// reglas - acciones


S :
{
tablaActual->nombrePadre = "";

    // cout << "crb Inicio **********" << endl;
      // cout << "crb entro en S" << endl;
      $$.prefijo = $0.prefijo;
       $$.tipoAmbito = "";
}

C    { /* comprobar que después del programa no hay ningún token más */
                           int tk = yylex();
                           if (tk != 0) yyerror("");

      // cout << "crb entro en S2" << endl;
         //$$.trad = $2.trad;
         cout << $2.trad << endl;

        }
     ;


C :    tkclass id
{

      // cout << "crb entro en C" << endl;

      Simbolo sim;
      sim.nulo = 0;
      sim.nombre = $2.lexema;
      sim.tipoSimbolo = CLASE;
      sim.tipo = $2.tipo;
      if(!anyadir( tablaActual, sim )){
          msgError(ERRYADECL, nlin, ncol-strlen(yytext), yytext);
      }
      // imprimirSimbolos(tablaActual);

      tablaActual = crearTabla(tablaActual, tablaActual->nombrePadre + "::");
        //tablaActual->padre = tablaActual;
        //tablaActual->nombrePadre = tablaActual->padre->nombrePadre + "::";


    //tablaActual->tipo = "clase";
    //tablaActual->nombre = $2.lexema;
}
llavei
{$$.prefijo = $0.prefijo + std::string($2.lexema)+"::";}
B
{$$.prefijo = $0.prefijo + std::string($2.lexema)+"::";}
V llaved {
      // cout << "crb entro en C llavei" << endl;
      s1 = $0.tipoAmbito + std::string("clase ") + $0.prefijo + $2.lexema + std::string(" {\n") + $6.trad + $8.trad + std::string("}\n\n");
      // cout << "crb entro en C" << endl;
      $$.trad = s1;
      // cout << "crb entro. Destruyo el ámbito anterior" << endl;
        // imprimirSimbolos(tablaActual);
      tablaActual = tablaActual->padre;
      // imprimirSimbolos(tablaActual);
}
     ;

B :    tkpublic dosp
{$$.prefijo = $0.prefijo;
 $$.tipoAmbito = "publico ";}
P { // cout << "crb entro en B" << endl;

$$.trad = $4.trad; }
       | { $$.trad = ""; }
       ;
V :    tkprivate dosp
{$$.prefijo = $0.prefijo;
 $$.tipoAmbito = "privado ";}
P { // cout << "crb entro en V" << endl;
$$.trad = $4.trad;}
       | { $$.trad = ""; }
       ;

P :
{$$.prefijo = $0.prefijo;
 $$.tipoAmbito = $0.tipoAmbito;}
D
{$$.prefijo = $0.prefijo;
 $$.tipoAmbito = $0.tipoAmbito;}
P { // cout << "crb entro en P" << endl;
$$.trad = $2.trad + $4.trad; }
       | { $$.trad = ""; }
       ;

D :     Tipo id
{
      Simbolo sim;
      sim.nulo = 0;
      sim.nombre = $2.lexema;
      sim.tipoSimbolo = FUNCION;
      sim.tipo = $1.tipo;
      // cout << "crb nuevo simbolo 1: "<< endl;
      // imprimirSimbolo(sim);
            // cout << "crb voy a guardar el simbolo" << endl;
      if(!anyadir( tablaActual, sim )){
          msgError(ERRYADECL, nlin, ncol-strlen(yytext), yytext);
      }
// imprimirSimbolos(tablaActual);
            // cout << "crb guardado el simbolo" << endl;
            // cout << "crb abro un nuevo ámbito" << endl;
    tablaActual = crearTabla(tablaActual, tablaActual->nombrePadre + "::");

}
pari Tipo id L pard

{
      // cout << "crb entro en D" << endl;
      Simbolo sim;
      sim.nulo = 0;

            sim.nombre = $6.lexema;
            sim.tipoSimbolo = VARIABLE;
            sim.tipo = $5.tipo;
            // cout << "crb nuevo simbolo 2: "<< endl;
            // imprimirSimbolo(sim);
            // cout << "crb voy a guardar el simbolo" << endl;
            if(!anyadir( tablaActual, sim )){
                msgError(ERRYADECL, nlin, ncol-strlen(yytext), yytext);
            }

            // cout << "crb guardado el simbolo" << endl;
            // cout << "crb voy a cod " << $1.lexema << " " << $1.tipo << endl;


    $$.tipo = $1.tipo;
    $$.bloqueBool = false;
}

Cod
            {
            s2 = $6.lexema + std::string(":") + $5.trad + $7.trad;
            $$.trad = $0.tipoAmbito + $0.prefijo + $2.lexema + std::string(" (") + s2 + std::string(" -> ") + $1.trad + std::string(")") + $10.trad;

            tablaActual = tablaActual->padre;
                        }
       | C { $$.trad = $1.trad; }
       ;

Cod :    pyc { 
      // cout << "crb entro en Cod" << endl;
      $$.trad = ";"  + std::string("\n"); }
       |
{
    $$.tipo = $0.tipo;
}
Bloque {

       // cout << " crb Cod:Bloque ha ido bien" << endl;


       $$.trad = $2.trad; }
       ;

L : coma Tipo id L { 
      // cout << "crb entro en L ******************************" << endl;
      Simbolo sim;
      sim.nulo = 0;
      sim.nombre = $3.lexema;
      sim.tipoSimbolo = VARIABLE;
      sim.tipo = $2.tipo;
      // cout << "crb nuevo simbolo 3: "<< endl;
      // imprimirSimbolo(sim);


      if(!anyadir( tablaActual, sim )){
          msgError(ERRYADECL, nlin, ncol-strlen(yytext), yytext);
      }
      s2 = $3.lexema + std::string(":") + $2.trad + $4.trad;
      $$.trad = " x " + s2;

      }
       | {
       // cout << "crb entro en L vacio ******************************" << endl;
       $$.trad = ""; }
       ;
Tipo :    tkint { 
      // cout << "crb entro en Tipo entero" << endl;
      $$.trad = "entero";
      $$.tipo = ENTERO; }
       |  tkfloat {

      // cout << "crb entro en Tipo float" << endl;
      $$.trad = "real";
       $$.tipo = REAL; }
       ;

Bloque : llavei
{ // cout << "crb tabla antes de bloque " << "tipo "<< $0.tipo << endl;
    if($0.bloqueBool){
                 // cout << "crb tabla antes de bloque " << "tipo "<< $0.tipo << endl;
                 // imprimirSimbolos(tablaActual);
                 tablaActual = crearTabla(tablaActual, tablaActual->nombrePadre + "::");
                    // imprimirSimbolos(tablaActual->padre);
                    }


    $$.tipo = $0.tipo;

                    }
SecInstr
 {
 if($0.bloqueBool){
 // cout << "crb tabla del bloque" << endl;
                              // imprimirSimbolos(tablaActual);

                                           // destruyo el ámbito
                                           tablaActual = tablaActual->padre;
 }
 }
 llaved {

                $$.trad = "\n{\n" + $3.trad + "}\n\n"; }
       ;

SecInstr :
{
    $$.tipo = $0.tipo;
}
Instr pyc

{
    $$.tipo = $0.tipo;
}

SecInstr {

                        // cout << "crb entro en SecInstr" << endl;
                        $$.trad = $2.trad + std::string("\n") + $5.trad;}
       |             { $$.trad = ""; }
       ;

Instr : Tipo id { // cout << "crb entro en Instr TIPO" << endl;
                    Simbolo sim;
                  sim.nulo = 0;
                  sim.nombre = $2.lexema;
                  sim.tipoSimbolo = VARIABLE;
                  sim.tipo = $1.tipo;
                  // cout << "crb en Instr " << endl;
                  // imprimirSimbolos(tablaActual);
                  // imprimirSimbolo(sim);
                  if(!anyadir( tablaActual, sim )){
                      msgError(ERRYADECL, nlin, ncol-strlen(yytext), yytext);
                  }
                  $$.trad = "var " + sim.nombre + ":" + $1.trad + ";\n";
                }

       | id { Simbolo sim;
                sim.nulo = 0;
                sim = buscar( tablaActual, $1.lexema );
                tipo = sim.tipo;
                // imprimirSimbolo(sim);
                // cout << "crb asig ------------------- " << sim.tipo << endl;
                if (sim.nulo == -1)
                    msgError(ERRNODECL, nlin, ncol-strlen(yytext), yytext);
                if (sim.tipoSimbolo != VARIABLE)
                    msgError(ERRNOVAR, nlin, ncol-strlen(yytext), yytext);

        }

       asig {longitud = ncol-1;} Expr {
                // cout << "crb asig ------------------- " << tipo << endl;

                if(tipo == ENTERO && $5.tipo == REAL)
                     msgError(ERRTIPOS, nlin, longitud, "=");
                if(tipo == REAL && $5.tipo == ENTERO)
                     $$.trad = $1.lexema + std::string(" :") + $3.lexema + std::string(" ") + std::string("itor(") + $5.trad + std::string(");");
                else
                     $$.trad = $1.lexema + std::string(" :") + $3.lexema + std::string(" ") + $5.trad + std::string(";");
                // cout << "crb trad: " << $$.trad << endl;

         }
       | {
         // cout << "crb a true -----------------------------" << nlin << endl;
         // imprimirSimbolos(tablaActual);
         $$.tipo = $0.tipo;
         $$.bloqueBool = true;
         }
        Bloque {
                    // cout << "crb entro en I0nstr Bloque" << endl;
                    $$.trad = $2.trad;
                }
       | {
       longitud = ncol - 6;
       // cout << "crb ncol: " << longitud << endl;
       }

       tkreturn Expr {
                if($0.tipo == ENTERO && $3.tipo == REAL)
                     msgError(ERRTIPOS, nlin, longitud, "return");
                if($0.tipo == REAL && $3.tipo == ENTERO)
                     $$.trad = "retorna itor(" + $3.trad + ");";
                else
                     $$.trad = "retorna " + $3.trad + ";";

       // cout << "crb entro en return y el tipo es " << $0.tipo << endl;


                       }
       ;
Expr :    Expr addop Term { if($1.tipo == ENTERO && $3.tipo == ENTERO){
                              $$.trad = $1.trad + " " + $2.lexema + "i " + $3.trad;
                              $$.tipo = ENTERO;}
                            else if($1.tipo == ENTERO && $3.tipo == REAL){
                              $$.trad = "itor(" + $1.trad + ") " + $2.lexema + "r " + $3.trad;
                              $$.tipo = REAL;}
                            else if($1.tipo == REAL && $3.tipo == ENTERO){
                              $$.trad = $1.trad + " " + $2.lexema + "r itor(" + $3.trad + ")";
                              $$.tipo = REAL;}
                            else{
                              $$.trad = $1.trad + " " + $2.lexema + "r " + $3.trad;
                              $$.tipo = REAL;}
                          }
       | Term { // cout << "crb entro en Expr = Term" << endl;
                $$.tipo = $1.tipo;
                $$.trad = $1.trad;
              }
       ;
Term : Term mulop Factor {if($1.tipo == ENTERO && $3.tipo == ENTERO){
                                $$.trad = $1.trad + " " + $2.lexema + "i " + $3.trad;
                                $$.tipo = ENTERO;}
                          else if($1.tipo == ENTERO && $3.tipo == REAL){
                            $$.trad = "itor(" + $1.trad + ") " + $2.lexema + "r " + $3.trad;
                            $$.tipo = REAL;}
                          else if($1.tipo == REAL && $3.tipo == ENTERO){
                            $$.trad = $1.trad + " " + $2.lexema + "r itor(" + $3.trad + ")";
                            $$.tipo = REAL;}
                          else{
                            $$.trad = $1.trad + " " + $2.lexema + "r " + $3.trad;
                            $$.tipo = REAL;}
                        }
       | Factor { // cout << "crb entro en Term = Factor" << endl;
                    $$.tipo = $1.tipo;
                  $$.trad = $1.trad;
                }
       ;

Factor : real { $$.tipo = REAL;
                $$.trad = $1.lexema;
                // cout << "crb* " << $1.lexema << endl;
              }
       | entero { $$.tipo = ENTERO;
                  $$.trad = $1.lexema;
                  // cout << "crb* " << $1.lexema << endl;
                }
       | id { Simbolo sim;
              sim.nulo = -1;
              // imprimirSimbolos(tablaActual);
              // cout << "crb buscando simbolo " << $1.lexema <<endl;
              sim = buscar( tablaActual, $1.lexema );
              // imprimirSimbolo(sim);
              if (sim.nulo == -1)
                    msgError(ERRNODECL, nlin, ncol-strlen(yytext), yytext);
              if (sim.tipoSimbolo != VARIABLE)
                    msgError(ERRNOVAR, nlin, ncol-strlen(yytext), yytext);
              $$.tipo = sim.tipo;
              $$.trad = sim.nombre;
                // cout << "crb Factor: id* " << $1.lexema << " " << $1.tipo << endl;
            }
       | pari Expr pard { $$.tipo = $2.tipo;
                          $$.trad = "(" + $2.trad + ")";
                // cout << "crb* " << "(" + $2.trad + ")" << endl;
                        }
       ;

%%
// código

bool anyadir(TablaSimbolo *ta, Simbolo s){

// cout << "crb añadiendo* VARIABLE-CLASE-FUNCION: " << s.nombre << "  " << endl;

    for(std::size_t i=0; i<ta->simbolos.size(); ++i){
        if(ta->simbolos[i].nombre == s.nombre) {
            return false;
        }
    }
    // cout << "crb añadido* VARIABLE-CLASE-FUNCION: " << s.nombre << "  " << endl;
    ta->simbolos.push_back(s);
    return true;
}


Simbolo buscar(TablaSimbolo *ta, const std::string& nombre){
    Simbolo simb;
    simb.nulo = -1;
// cout << "crb buscando* VARIABLE: " << nombre << "  " << ta->padre << endl;
    //for(std::list<Simbolo>::const_iterator iterator = ta->simbolos.begin(), end = ta->simbolos.end(); iterator != end ; ++iterator) {

    for(std::size_t i=0; i<ta->simbolos.size(); ++i){
        if(ta->simbolos[i].nombre == nombre) {


            Simbolo simb3;
            simb3.nulo = 0;
            simb3.nombre = ta->simbolos[i].nombre;
            simb3.tipoSimbolo = ta->simbolos[i].tipoSimbolo;
            simb3.tipo = ta->simbolos[i].tipo;
            return simb3;
        }
    }

// cout << "crb buscando* " << ta->padre << endl;
--contador;

    if((ta->padre != NULL || ta->nombrePadre != "") && contador > 0)
        return buscar(ta->padre, nombre);
    else
        return simb;
}

TablaSimbolo* crearTabla(TablaSimbolo* padre, std::string nombre){
    TablaSimbolo* tablaHijo = new TablaSimbolo(padre);
    tablaHijo->nombrePadre = nombre;
    tablaHijo->padre = padre;
    return tablaHijo;
}

void msgError(int nerror,int nlin,int ncol,const char *s)
{
     switch (nerror) {
         case ERRLEXICO: fprintf(stderr,"Error lexico (%d,%d): caracter '%s' incorrecto\n", nlin, ncol, s);
            break;
         case ERRSINT: fprintf(stderr,"Error sintactico (%d,%d): en '%s'\n", nlin, ncol, s);
            break;
         case ERREOF: fprintf(stderr,"Error sintactico: fin de fichero inesperado\n");
            break;
         case ERRLEXEOF: fprintf(stderr,"Error lexico: fin de fichero inesperado\n");
            break;
         case ERRYADECL: fprintf(stderr,"Error semantico (%d,%d): '%s' ya existe en este ambito\n",nlin,ncol,s);
            break;
         case ERRNODECL: fprintf(stderr,"Error semantico (%d,%d): '%s' no ha sido declarado\n",nlin,ncol,s);
            break;
         case ERRNOVAR: fprintf(stderr,"Error semantico (%d,%d): '%s' no es una variable\n",nlin,ncol,s);
            break;
         case ERRTIPOS: fprintf(stderr,"Error semantico (%d,%d): '%s' tipos incompatibles entero/real\n",nlin,ncol,s);
            break;
     }
        
     exit(1);
}


int yyerror(const char *s)
{
    if (findefichero) 
    {
       msgError(ERREOF, 0, 0,"");
    }
    else
    {  
       msgError(ERRSINT, nlin, ncol-strlen(yytext), yytext);
    }
}

int main(int argc,char *argv[])
{
    FILE *fent;

    if (argc==2)
    {
        fent = fopen(argv[1],"rt");
        if (fent)
        {
            yyin = fent;
            yyparse();
            fclose(fent);
        }
        else
            fprintf(stderr,"No puedo abrir el fichero\n");
    }
    else
        fprintf(stderr,"Uso: plp4 <nombre de fichero>\n");
}

void imprimirSimbolos(TablaSimbolo *ta){
    cout << "*******Tabla hasta ahora*******" << endl;

        //for(std::list<Simbolo>::const_iterator iterator = ta->simbolos.begin(), end = ta->simbolos.end(); iterator != end; ++iterator) {
           for(std::size_t i=0; i<ta->simbolos.size(); ++i){

            cout << "Nombre: " << ta->simbolos[i].nombre <<
                    " tipo: " << ta->simbolos[i].tipo <<
                    " tipoSimbolo: " << ta->simbolos[i].tipoSimbolo << endl;

        }
    cout << "*********Fin tabla*********" << endl;
}
void imprimirSimbolo(Simbolo s){
cout << "Nombre: " << s.nombre <<
                    " tipo: " << s.tipo <<
                    " tipoSimbolo: " << s.tipoSimbolo << endl;
}