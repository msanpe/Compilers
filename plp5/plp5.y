/*MIGUEL SANCHO PEÑA
/*------------------------------ plp5.y -------------------------------*/
%token IF 
%token ELSE 
%token WHILE 
%token TRUE 
%token FALSE
%token AND 
%token OR 
%token NOT
%token id 
%token nentero 
%token nreal
%token relop 
%token addop 
%token mulop
%token pari 
%token pard 
%token cori 
%token cord 
%token llavei 
%token llaved
%token asig 
%token coma 
%token pyc 
%token punto
%token PUBLIC 
%token CLASS 
%token IMPORT 
%token NEW 
%token STATIC
%token MAINE 
%token SYSTEM 
%token OUT 
%token IN 
%token PRINTLN 
%token PRINT 
%token SCANNER
%token INT 
%token DOUBLE 
%token BOOLEAN 
%token STRING 
%token VOID
%token NEXTINT 
%token NEXTDOUBLE


%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <sstream>
#include <vector>

using namespace std;

#include "comun.h"
// variables y funciones del A. Léxico
extern int nlin,ncol,finfichero;
extern int yylex();
extern char *yytext;
extern FILE *yyin;

// CONSTANTES

const int MAXVAR = 16000; // D MEM
const int MAXTMP = 384;

const int ENTERO = 0; // TIPOS
const int REAL	= 1;
const int BOOL	= 2;
const int SCA	= 3;
const int ARRAY	= 4;

int yyerror(char *s);
string getopal(const char *s,int tipo);

typedef struct { // aux
    char *lexema;
    int nlin,ncol;
    int tipo;
    int tipoBase;
    int dir;
    int dbase;
    int tam;
    string cod;
} S;

typedef struct { // estara contenido dentro del vec de la tabl tipos
    int tipo;
    int tam;
    int tipo_base;
} TIPO;

class TablaTipos {
public:
	vector<TIPO> tipos;

	TablaTipos(){ // base
		tipos.push_back(TIPO{ENTERO,1,ENTERO});
		tipos.push_back(TIPO{REAL,1,REAL});
		tipos.push_back(TIPO{BOOL,1,BOOL});
		tipos.push_back(TIPO{SCA,1,SCA});
	}

	int anyadir(const TIPO& t){ 
		tipos.push_back(t); 

		return tipos.size() - 1;
	}
	int tipoBase(int tipo){ 
		return tipos[tipo].tipo_base; 
	}
	int tam(int tipo){ 
		return tipos[tipo].tam; 
	}

private:
};

class TablaSimbolos {
public:
	TablaSimbolos *padre;
	vector<SIMBOLO> simbolos;
	int tsTemp;

	TablaSimbolos(TablaSimbolos* t,int tmp): simbolos(){
		padre = t;
		tsTemp = tmp;
	}

	~TablaSimbolos(){
		padre = NULL;
		tsTemp=0;
	}

	bool anyadir(const SIMBOLO& s){
		if(this->buscar(s) != NULL) // si ya estaba no lo añade
			return false;

		simbolos.push_back(s);
		
		return true;
	}

	const SIMBOLO* buscar(const SIMBOLO& s) const{ // busca un simbolo en la tabla
		for(unsigned i=0; i<simbolos.size(); ++i)
			if(strcmp(simbolos[i].lexema, s.lexema)==0)
				return &simbolos[i];
		
		if(padre!=NULL)
			return padre->buscar(s);
		else
			return NULL;
	}

	string iTOs() const{
		string str="";
		
		for(unsigned i=0; i < simbolos.size(); ++i){
			str.append(simbolos[i].lexema);
			str.append(", ");
		}
		str+="\n";
		return str;
	}
private:
};


bool esArray(int tipo) {
	if (tipo > 3)
		return true;
	else 
		return false;
}


const SIMBOLO *simb;
int posGlobal = 0;
int etiqGlobal = 0;
int tmpGlobal = MAXVAR;
bool scanner = false;



 // AUXILIARES
string operador = ""; 
string auxStr = ""; 
string auxStr1 = ""; 
int auxTmp = 0;
int auxCor = 0;
int auxCor1 = 0;
int auxcol = 0;
int tam = 0;

TablaSimbolos* tSimbolos = new TablaSimbolos(NULL,tmpGlobal);
TablaTipos tTipos;

string iTOs (int a) {
    ostringstream temp;
    temp<<a;
    return temp.str();
}

int tempNumber(){
	if(tmpGlobal >= MAXVAR+MAXTMP) msgError(ERR_MAXTMP,nlin,ncol,"");
	tmpGlobal++;
	return tmpGlobal-1;
}

string netiq(){
	etiqGlobal++;
	return "L" + iTOs(etiqGlobal);
}

%}

%%
// REGLAS

S : Import Class
	{$$.cod = $2.cod;
	int tk = yylex();
	if(tk != 0) 
		yyerror("");
	$$.cod = $2.cod;
	cout << $$.cod << endl
		<< "halt" << endl;}
  ;

Import : Import IMPORT SecImp pyc {$$.cod = "";} | {$$.cod = "";};

SecImp : SecImp punto id {$$.cod = "";}

	   | SecImp punto SCANNER
	     {scanner=true;
		 $$.cod = "";}

	   | id {$$.cod="";}
	   ;

Class : PUBLIC CLASS id
	    {if(!tSimbolos->anyadir($3)) msgError(ERRYADECL,$3.nlin,$3.ncol,$3.lexema);}
	  llavei Main llaved
	    {$$.cod = $6.cod;}
	  ;

Main : PUBLIC STATIC VOID MAINE pari STRING cori cord id pard Bloque
	   {$$.cod = $11.cod;}
	 ;

Tipo : INT {$$.tipo = ENTERO;} | DOUBLE {$$.tipo = REAL;} | BOOLEAN {$$.tipo = BOOL;};

Bloque : {tSimbolos=new TablaSimbolos(tSimbolos,tmpGlobal);}
	   llavei BDecl SeqInstr llaved
		 {$$.cod=$4.cod;
		 tmpGlobal = tSimbolos->tsTemp;
		 tSimbolos=tSimbolos->padre;}
	   ;

BDecl : BDecl DVar {$$.cod = "";} | {$$.cod = "";};

DVar : Tipo {$$.tipo=$1.tipo;} LIdent pyc {$$.cod="";}

	 | Tipo {auxCor=0;} DimSN id asig NEW Tipo
	   {auxCor1=0; tam=0;
	   if($1.tipo != $7.tipo) msgError(ERR_TIPOSDECLARRAY,$4.nlin,$4.ncol,$4.lexema);
	   $$.tipo=$1.tipo;}
	 Dimensiones
	   {if(auxCor!=auxCor1) msgError(ERR_DIMSDECLARRAY,$4.nlin,$4.ncol,$4.lexema);
	   $4.tipo = $9.tipo;
	   $4.tam = $9.tam;
	   $4.dir = posGlobal;
	   if(!tSimbolos->anyadir($4)) msgError(ERRYADECL,$4.nlin,$4.ncol,$4.lexema);
	   if(posGlobal+tam >= MAXVAR) msgError(ERR_NOCABE,$4.nlin,$4.ncol,$4.lexema);
	   posGlobal+=tam;}
	 pyc {$$.cod="";}

	 | SCANNER id
	   {$2.tipo=SCA;
	   $2.tam=1;
	   $2.dir=posGlobal;
	   if(!tSimbolos->anyadir($2)) msgError(ERRYADECL,$2.nlin,$2.ncol,$2.lexema);
	   if(posGlobal+1 >= MAXVAR) msgError(ERR_NOCABE,$2.nlin,$2.ncol,$2.lexema);
	   posGlobal++;}
	 asig NEW SCANNER pari SYSTEM punto IN pard pyc
	   {$$.cod = "";}
	 ;

DimSN : DimSN cori cord {$$.cod=""; auxCor++;} | cori cord {$$.cod=""; auxCor++;};

Dimensiones : cori nentero cord {$$.tipo=$0.tipo;} Dimensiones
			  {auxCor1++; $$.tam = atoi($2.lexema); tam*=$$.tam;
			  $$.tipo = tTipos.anyadir(TIPO{ARRAY,$$.tam,$5.tipo});}

			| cori nentero cord
			  {auxCor1++; $$.tam = atoi($2.lexema); tam+=$$.tam;
			  $$.tipo = tTipos.anyadir(TIPO{ARRAY,$$.tam,$0.tipo});}
			;

LIdent : LIdent coma {$$.tipo=$0.tipo;} Variable | {$$.tipo=$0.tipo;} Variable;

Variable : id
		 {$$.cod="";
		 $1.tipo=$0.tipo;
		 $1.tam=1;
		 $1.dir=posGlobal;
		 if(!tSimbolos->anyadir($1))
            msgError(ERRYADECL,$1.nlin,$1.ncol,$1.lexema);
		 if(posGlobal+$1.tam >= MAXVAR)
            msgError(ERR_NOCABE,$1.nlin,$1.ncol,$1.lexema);
		 posGlobal+=$1.tam;}
		 ;

SeqInstr : SeqInstr Instr {$$.cod = $1.cod + $2.cod;} | {$$.cod="";};

Instr : pyc {$$.cod="";}
	  | Bloque {$$.cod = $1.cod;}

	  | Ref asig {auxcol=ncol;} Expr pyc
		{$$.cod = $1.cod + $4.cod + "; Instr -> asig\n";
		if($1.tipo == REAL && $4.tipo == ENTERO)
			$$.cod += "mov " + iTOs($4.dir) + " A\n"+
					"itor\n" +
					"mov A " + iTOs($4.dir) + "\n";
		else if($1.tipo != $4.tipo)
			msgError(ERR_TIPOSASIG,$2.nlin,$2.ncol,$2.lexema);
            
		$$.cod += "mov " + iTOs($1.dir) + " A\n"+
				"muli #" + iTOs(tTipos.tam($1.tipo)) + "\n" +
				"addi #" + iTOs($1.dbase) + "\n" +
				"mov " + iTOs($4.dir) + " @A\n";
		}

	  | SYSTEM punto OUT punto PRINTLN pari Expr pard pyc
	    {$$.cod = $7.cod + "; Instr -> println\n";
		if($7.tipo==ENTERO || $7.tipo==BOOL)
			$$.cod += "wri ";
		else if($7.tipo == REAL)
			$$.cod += "wrr ";
		$$.cod += iTOs($7.dir) + "\n" + "wrl\n";}

	  | SYSTEM punto OUT punto PRINT pari Expr pard pyc
	    {$$.cod = $7.cod + "; Instr -> print\n";
		if($7.tipo==ENTERO || $7.tipo==BOOL) $$.cod += "wri ";
		else if($7.tipo == REAL) $$.cod += "wrr ";
		$$.cod += iTOs($7.dir) + "\n";}

	  | IF pari Expr pard Instr
		{if($3.tipo != BOOL)
            msgError(ERR_TIPOSIFW,$1.nlin,$1.ncol,$1.lexema);
		auxStr = netiq();
		$$.cod = "\t\t;Instr -> if\n" + $3.cod +
				"mov " + iTOs($3.dir) + " A\n" +
				"jz " + auxStr + "\n" +
				$5.cod + auxStr + " ";
		}

	  | IF pari Expr pard Instr ELSE Instr
		{if($3.tipo != BOOL)
            msgError(ERR_TIPOSIFW,$1.nlin,$1.ncol,$1.lexema);
		auxStr = netiq();
		auxStr1 = netiq();
		$$.cod = "\t;Instr -> if\n" +$3.cod +
				"mov " + iTOs($3.dir) + " A\n" +
				"jz " + auxStr + "\n" +
				$5.cod +"jmp " + auxStr1 + "\n" +
				auxStr + " " + $7.cod +
				auxStr1 + " ";
		}

	  | WHILE pari Expr pard Instr {
          if($3.tipo != BOOL)
            msgError(ERR_TIPOSIFW,$1.nlin,$1.ncol,$1.lexema);
		auxStr = netiq();
		auxStr1 = netiq();
		$$.cod = auxStr + " " + $3.cod + "\t;Instr->while\n"+
				"mov " + iTOs($3.dir) + " A\n" +
				"jz " + auxStr1 + "\n" +
				$5.cod +
				"jmp " + auxStr + "\n" +
				auxStr1 + " ";
      };

Expr : Expr OR EConj {
        if($1.tipo!=BOOL && $3.tipo!=BOOL)
           msgError(ERR_OPNOBOOL,$2.nlin,$2.ncol,$2.lexema);
	   auxTmp=tempNumber(); $$.dir=auxTmp;
	   $$.tipo=BOOL;
	   $$.cod += $1.cod + $3.cod +
			"mov " + iTOs($1.dir) + " A\t;Expr\n" +
			"ori " + iTOs($3.dir) + "\n" +
			"mov A " + iTOs(auxTmp) + "\n";}

	 | EConj
	   {$$.cod=$1.cod; $$.dir=$1.dir; $$.tipo=$1.tipo;}
	 ;

EConj : EConj AND ERel
	  {if($1.tipo!=BOOL && $3.tipo!=BOOL)
          msgError(ERR_OPNOBOOL,$2.nlin,$2.ncol,$2.lexema);
	  auxTmp=tempNumber(); $$.dir=auxTmp;
	  $$.tipo=BOOL;
	  $$.cod += $1.cod + $3.cod +
	  		"mov " + iTOs($1.dir) + " A\t;Econj\n" +
			"andi " + iTOs($3.dir) + "\n" +
			"mov A " + iTOs(auxTmp) + "\n";}

	  | ERel
		{$$.cod=$1.cod; $$.dir=$1.dir; $$.tipo=$1.tipo;};

ERel : Esimple relop Esimple
	   {if(($1.tipo>REAL || $3.tipo>REAL) && !($1.tipo==BOOL && $3.tipo==BOOL))
			msgError(ERR_TIPOS,$2.nlin,$2.ncol,"");
	   auxTmp=tempNumber(); $$.dir=auxTmp;
	   $$.cod = $1.cod + $3.cod + "\t;ERel\n";
	   $$.tipo = BOOL;

	   if(($1.tipo==ENTERO && $3.tipo==ENTERO) || ($1.tipo==BOOL && $3.tipo==BOOL)){
		  $$.cod += "mov " + iTOs($1.dir) + " A\n" +
			getopal($2.lexema,ENTERO) + " " + iTOs($3.dir) + "\n";
	   }else if($1.tipo==ENTERO && $3.tipo==REAL){
		  $$.cod += "mov " + iTOs($1.dir) + " A\n" +
			"itor\n" +
			getopal($2.lexema,REAL) + " " + iTOs($3.dir) + "\n";
	   }else if($1.tipo==REAL && $3.tipo==ENTERO){
		  $$.cod += "mov " + iTOs($3.dir) + " A\n" +
			"itor\n" +
			"mov A " + iTOs($3.dir) + "\n" +
			"mov " + iTOs($1.dir) + " A\n" +
			getopal($2.lexema,REAL) + " " + iTOs($1.dir) + "\n";
	   }else{
		  $$.cod += "mov " + iTOs($1.dir) + " A\n" +
			getopal($2.lexema,REAL) + " " + iTOs($3.dir) + "\n";
	   }
	   $$.cod += "mov A " + iTOs(auxTmp) + "\n";
	   }

	 | Esimple
	   {$$.cod=$1.cod; $$.dir=$1.dir; $$.tipo=$1.tipo;}
	 ;

Esimple : Esimple addop Term
	    {if($1.tipo>REAL || $3.tipo>REAL) msgError(ERR_NUM,$2.nlin,$2.ncol,"");
	    auxTmp=tempNumber(); $$.dir=auxTmp;
	    $$.cod = $1.cod + $3.cod + "\t;Esimple \n";

	    if($1.tipo==ENTERO && $3.tipo==ENTERO){
	       $$.tipo=ENTERO;
	       $$.cod += "mov " + iTOs($1.dir) + " A\n" +
	     	getopal($2.lexema,ENTERO) + " " + iTOs($3.dir) + "\n";
	    }else if($1.tipo==ENTERO && $3.tipo==REAL){
	       $$.tipo=REAL;
	       $$.cod += "mov " + iTOs($1.dir) + " A\n" +
	     	"itor\n" +
	     	getopal($2.lexema,REAL) + " " + iTOs($3.dir) + "\n";
	    }else if($1.tipo==REAL && $3.tipo==ENTERO){
	       $$.tipo=REAL;
	       $$.cod += "mov " + iTOs($3.dir) + " A\n" +
	     	"itor\n" +
			"mov A " + iTOs($3.dir) + "\n" +
			"mov " + iTOs($1.dir) + " A\n" +
			getopal($2.lexema,REAL) + " " + iTOs($3.dir) + "\n";
	    }else{
	       $$.tipo=REAL;
	       $$.cod += "mov " + iTOs($1.dir) + " A\n" +
	     	getopal($2.lexema,REAL) + " " + iTOs($3.dir) + "\n";
	    }
	    $$.cod += "mov A " + iTOs(auxTmp) + "\n";
	    }

		| Term
		  {$$.cod=$1.cod; $$.dir=$1.dir; $$.tipo=$1.tipo;}
		;

Term : Term mulop Factor
	   {if($1.tipo>REAL || $3.tipo>REAL) msgError(ERR_NUM,$2.nlin,$2.ncol,"");
	   auxTmp=tempNumber(); $$.dir=auxTmp;
	   $$.cod = $1.cod + $3.cod + "\t;Term\n";

	   if ($1.tipo==ENTERO && $3.tipo==ENTERO){
		  $$.tipo=ENTERO;
		  $$.cod += "mov " + iTOs($1.dir) + " A\n" +
			getopal($2.lexema,ENTERO) + " " + iTOs($3.dir) + "\n";
	   } else if($1.tipo==ENTERO && $3.tipo==REAL){
		  $$.tipo=REAL;
		  $$.cod += "mov " + iTOs($1.dir) + " A\n" +
			"itor\n" +
			getopal($2.lexema,REAL) + " " + iTOs($3.dir) + "\n";
	   } else if($1.tipo==REAL && $3.tipo==ENTERO){
		  $$.tipo=REAL;
		  $$.cod += "mov " + iTOs($3.dir) + " A\n" +
			"itor\n" +
			"mov A " + iTOs($3.dir) + "\n" +
			"mov " + iTOs($1.dir) + " A\n" +
			getopal($2.lexema,REAL) + " " + iTOs($3.dir) + "\n";
	   } else{
		  $$.tipo=REAL;
		  $$.cod += "mov " + iTOs($1.dir) + " A\n" +
			getopal($2.lexema,REAL) + " " + iTOs($3.dir) + "\n";
	   }
	   $$.cod += "mov A " + iTOs(auxTmp) + "\n";
	   }

	 | Factor
	   {$$.cod=$1.cod; $$.dir=$1.dir; $$.tipo=$1.tipo;}
	 ;

Factor : Ref {
			if (esArray($1.tipo)) 
				msgError(ERRFALTAN,$1.nlin,$1.ncol,"");
	   		$$.tipo = $1.tipo;
	   		auxTmp=tempNumber(); $$.dir=auxTmp;
	   		$$.cod = $1.cod + "mov " + iTOs($1.dir) + " A\t;Factor->ref\n" +
				"muli #" + iTOs(tTipos.tam($1.tipo)) + "\n" +
				"addi #" + iTOs($1.dbase) + "\n" +
				"mov @A " + iTOs(auxTmp) + "\n";
	   }
	   | id {
	   		simb = tSimbolos->buscar($1);
	   		if(simb == NULL) msgError(ERRNODECL,$1.nlin,$1.ncol,$1.lexema);
	   		if(simb->tipo != SCA) msgError(ERR_NOSC,$1.nlin,$1.ncol,$1.lexema);
	   }
	   	 punto FactorScanner { 
	   	 	$$.tipo = $4.tipo; $$.dir = $4.dir; $$.cod = $4.cod; 
	   }
	   | nentero {
	   		auxTmp = tempNumber(); $$.dir=auxTmp;
	     	$$.cod = "mov #" + string($1.lexema) + " " + iTOs(auxTmp) + "\t;Factor-> nentero\n"; $$.tipo=ENTERO;
	   }
	   | nreal {
	   		auxTmp = tempNumber(); $$.dir=auxTmp;
	     	$$.cod = "mov $" + string($1.lexema) + " " + iTOs(auxTmp) + "\t;Factor -> nreal\n"; $$.tipo=REAL;
	   }
	   | TRUE {
	   		auxTmp = tempNumber(); $$.dir=auxTmp;
	     	$$.cod = "mov A #1" + string($1.lexema); $$.tipo=BOOL;
	   }
	   | FALSE {
	   	 auxTmp = tempNumber(); $$.dir=auxTmp;
		 $$.cod = "mov A #0" + string($1.lexema); $$.tipo=BOOL;
	   }
	   | pari Expr pard {
	   		$$.tipo = $2.tipo;
		 	$$.dir = $2.dir;
		 	$$.cod = "\t;Factor-> ( Expr )\n" + $2.cod;
	   }
	   | NOT Factor {
	   		if ($2.tipo>REAL) 
	   			msgError(ERR_NUM,$2.nlin,$2.ncol,"");
		 	auxTmp = tempNumber(); $$.dir = auxTmp;
		 	$$.tipo = BOOL;
		 	$$.cod = "mov " + iTOs($2.dir) + " A\t;Factor -> not Factor\n";
		 	if ($2.tipo == REAL) 
		 		$$.cod += "notr\n";
		 	else 
		 		$$.cod += "noti\n";
		 $$.cod += "mov A " + iTOs(auxTmp) + "\n";
	   }
	   | pari Tipo pard Factor {
	   		auxTmp = tempNumber(); $$.dir = auxTmp;
	     	$$.tipo = $2.tipo;
	     	$$.cod = $4.cod + "mov " + iTOs($4.dir) + " A\t;Factor -> (tipo) expr\n";
	
	     	if(($4.tipo==BOOL || $4.tipo==ENTERO) && $2.tipo==REAL)
		 		$$.cod += "itor\n";
	     	else if($4.tipo==REAL && ($2.tipo==ENTERO || $2.tipo==BOOL))
		 		$$.cod += "rtoi\n";
	
	     	$$.cod += "mov A " + iTOs(auxTmp) + "\n";
	   }
	   ;

FactorScanner : NEXTINT pari pard
				{$$.tipo = ENTERO;
				auxTmp=tempNumber(); $$.dir=auxTmp;
				$$.cod = "rdi " + iTOs(auxTmp) + "\n";}

			  | NEXTDOUBLE pari pard
				{$$.tipo = REAL;
				auxTmp=tempNumber(); $$.dir=auxTmp;
				$$.cod = "rdr " + iTOs(auxTmp) + "\n";}

Ref : id {
		simb = tSimbolos->buscar($1);
	  	if(simb == NULL) msgError(ERRNODECL,$1.nlin,$1.ncol,$1.lexema);
	  	if(simb->tipo==SCA) msgError(ERR_SCVAR,$1.nlin,$1.ncol,$1.lexema);
	  	$$.tipo = simb->tipo;
	  	auxTmp=tempNumber(); $$.dir=auxTmp;
	  	$$.dbase = simb->dir;
	  	$$.cod = "mov #0 " + iTOs(auxTmp) + "\t;Ref -> id "+simb->lexema+"\n";
	}

	| Ref cori {
		if(!esArray($1.tipo)) 
			msgError(ERRSOBRAN,$2.nlin,$2.ncol,"");
	}
	  Esimple cord {
		if($4.tipo != ENTERO) 
			msgError(ERR_EXP_ENT,$5.nlin,$5.ncol,"");
  		$$.tipo = tTipos.tipoBase($1.tipo);
  		$$.dbase = $1.dbase;
  		$$.nlin=$5.nlin; $$.ncol=$5.ncol;
  		auxTmp = tempNumber(); $$.dir=auxTmp;
  		$$.cod = $1.cod + $4.cod +
		"mov " + iTOs($1.dir) + " A\t; Ref -> ref [ Esimple ]\n" +
		"muli #" + iTOs(tTipos.tam($1.tipo)) + "\n" +
		"addi " + iTOs($4.dir) + "\n" +
		"mov A " + iTOs(auxTmp) + "\n";
	}
	;

%%

void toLower(string& str) {
    for(int i = 0; i < str.size(); i++) {
        str[i] = tolower(str[i]);
    }
}

/*
bool rellenarMemoria(int memoriaNecesaria) {
    int memoriaAux = numMemoria + memoriaNecesaria;
    if(memoriaAux > MAXMEM)
    return false;
    numMemoria = memoriaAux;
    return true;
}

int nTmp() {
    if(numMemoria > MAXMEM)
    //LANZAR ERROR FALTA MEMORIA.
    msgError(ERR_MAXTMP,1,2,"FALTA MEM");
    numMemoria++;
    return numMemoria;
}*/



string getopal(const char *s,int tipo){
	string op="";
    
	if(!strcmp(s,"+"))
        op += "add";
	else if(!strcmp(s,"-"))
        op += "sub";
    else if(!strcmp(s,">="))
        op += "geq";
    else if(!strcmp(s,"<"))
        op += "lss";
    else if(!strcmp(s,"<="))
        op += "leq";
	else if(!strcmp(s,"*"))
        op += "mul";
	else if(!strcmp(s,"/"))
        op += "div";
	else if(!strcmp(s,"=="))
        op += "eql";
	else if(!strcmp(s,"!="))
        op += "neq";
	else if(!strcmp(s,">"))
        op += "gtr";
	else
        fprintf(stderr,"Eror interno (%d,%d): llamada no controlada getopal '%s'\n",nlin,ncol,s);

	if(tipo==ENTERO)
		op+='i';
	else if(tipo==REAL)
		op+='r';
	else fprintf(stderr,"Eror interno (%d,%d): tipo no controlado getopal '%d'\n",nlin,ncol,tipo);

	return op;
}


void msgError(int nerror,int nlin,int ncol,const char *s)
{
     switch (nerror) {
         case ERRLEXICO: fprintf(stderr,"Error lexico (%d,%d): caracter '%s' incorrecto\n",nlin,ncol,s);
            break;
         case ERRSINT: fprintf(stderr,"Error sintactico (%d,%d): en '%s'\n",nlin,ncol,s);
            break;
         case ERREOF: fprintf(stderr,"Error sintactico: fin de fichero inesperado\n");
            break;
         case ERRLEXEOF: fprintf(stderr,"Error lexico: fin de fichero inesperado\n");
            break;
         default:
            fprintf(stderr,"Error semantico (%d,%d): ", nlin,ncol);
            switch(nerror) {
             case ERRYADECL: fprintf(stderr,"simbolo '%s' ya declarado\n",s);
               break;
             case ERRNODECL: fprintf(stderr,"identificador '%s' no declarado\n",s);
               break;
             case ERR_NOSC: fprintf(stderr,"identificador '%s' no es un Scanner\n",s);
               break;
             case ERR_SCVAR: fprintf(stderr,"identificador '%s' es de tipo Scanner\n",s);
               break;
             case ERR_TIPOSDECLARRAY: fprintf(stderr,"los tipos deben ser iguales en la declaracion del array '%s'\n",s);
               break;
             case ERR_DIMSDECLARRAY: fprintf(stderr,"las dimensiones deben ser iguales en la declaracion del array '%s'\n",s);
               break;
             case ERRDIM: fprintf(stderr,"la dimension debe ser mayor que cero\n");
               break;
             case ERR_TIPOSASIG: fprintf(stderr,"tipos incompatibles en asignacion\n");
               break;
             case ERR_TIPOS: fprintf(stderr,"tipos incompatibles en '%s'\n",s);
               break;
             case ERR_TIPOSIFW: fprintf(stderr,"la expresion de if/while debe ser booleana\n");
               break;
             case ERR_OPNOBOOL: fprintf(stderr,"los operandos deben ser booleanos\n");
               break;
             case ERR_NUM: fprintf(stderr,"los operandos deben ser numericos\n");
               break;
             case ERRFALTAN: fprintf(stderr,"faltan indices\n");
               break;
             case ERRSOBRAN: fprintf(stderr,"sobran indices\n");
               break;
             case ERR_EXP_ENT: fprintf(stderr,"la expresion entre corchetes debe ser de tipo entero\n");
               break;

             case ERR_NOCABE:fprintf(stderr,"la variable '%s' ya no cabe en memoria\n",s);
               break;
             case ERR_MAXVAR:fprintf(stderr,"en la variable '%s', hay demasiadas variables declaradas\n",s);
               break;
             case ERR_MAXTIPOS:fprintf(stderr,"hay demasiados tipos definidos\n");
               break;
             case ERR_MAXTMP:fprintf(stderr,"no hay espacio para variables temporales\n");
               break;
            }
        }
     exit(1);
}

int yyerror(char *s) {
    extern int finfichero;
    
    if (finfichero)
       msgError(ERREOF,-1,-1,"");
    else
       msgError(ERRSINT,nlin,ncol-strlen(yytext),yytext);
}

int main(int argc,char *argv[]) {
	FILE *fent;
	if (argc==2) {
		fent = fopen(argv[1],"rt");
		if (fent) {
			yyin = fent;
			yyparse();
			fclose(fent);
		}
		else fprintf(stderr,"No puedo abrir el fichero\n");
		}
	else fprintf(stderr,"Uso: ejemplo <nombre de fichero>\n");
}
