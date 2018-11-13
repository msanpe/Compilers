/*----------------------- comun.h -----------------------------*/

#include <vector>
#include <iostream>

using namespace std;
/* fichero con definciones comunes para los ficheros .l y .y */
#define ERRLEXICO    1
#define ERRSINT      2
#define ERREOF       3
#define ERRLEXEOF    4


#define ERRYADECL    5
#define ERRNODECL    6
#define ERRNOVAR     7
#define ERRTIPOS     8
/*
struct Expresion {
    int tipo;
};

typedef struct Expresion Expresion, *e;
*/
void msgError(int nerror,int nlin,int ncol,const char *s);

typedef struct {
   char *lexema;
   int nlin,ncol;
   int tipo;
   string trad;
   string prefijo;
   string tipoAmbito;
   bool bloqueBool;
} MITIPO;

#define YYSTYPE MITIPO


struct Simbolo {
    string nombre;
    int tipoSimbolo;
    int tipo;
    int nulo;
};
struct ListaSimbolos {

};
struct TablaSimbolo {
    string tipo;
    string nombre;
    string nombrePadre;
    std::vector<Simbolo> simbolos;
    TablaSimbolo *padre;
    TablaSimbolo (TablaSimbolo *p):padre(p){};
};
