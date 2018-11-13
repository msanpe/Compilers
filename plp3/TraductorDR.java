import java.util.ArrayList;

/**
 *
 * @author Miguel Sancho Peña
 */
class Simbolo {
    public static final int ENTERO = 1,
            REAL = 2;

    public static final int VARIABLE = 3,
            CLASE = 4,
            FUNCION = 5;

    public String nombre;
    public int tipo;   // var, class, func
    public int iOr;          // Int or Real

    public Simbolo(String nombre, int tipoSimbolo, int tipo) {
        this.nombre = nombre;
        this.tipo = tipoSimbolo;
        this.iOr = tipo;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getTipoSimbolo() {
        return tipo;
    }

    public void setTipoSimbolo(int tipoSimbolo) {
        this.tipo = tipoSimbolo;
    }

    public int getIOR() {
        return iOr;
    }

    public void setIOR(int tipo) {
        this.iOr = tipo;
    }

    public String iOrToString() {
        switch (iOr) {
            case 1:
                return "entero";
            case 2:
                return "real";
            default:
                return "";
        }
    }
}

class Ambito {
    public String tipo;
    public String nombre;
    public Ambito padre; // ambito superior
    public ArrayList<Simbolo> simbolos; // Símbolos del ámbito


    public Ambito(Ambito padre, String tipo, String nombre) {
        this.tipo = tipo;
        this.padre = padre;
        this.nombre = nombre;
        simbolos = new ArrayList<>();
    }

    // comprueba si el simbolo ya existe en el ambito, si no esta, lo añade
    public boolean add(Simbolo simbolo) {
        for (Simbolo ss : simbolos) {
            if (ss.nombre.equals(simbolo.nombre)) {
                return false; // si esta repetido no lo añadimos y controlamos el error                       
            }                 //desde fuera
        }

        simbolos.add(simbolo);
        return true;
    }

    // busca el simbolo en el ambito, devuelve null si no lo encuentra
    Simbolo buscar(String nombre) {
        for (Simbolo s : simbolos) {
            if (s.nombre.equals(nombre)) {
                return s;
            }
        }

        if (padre != null) {
            return padre.buscar(nombre);
        } else {
            return null;
        }
    }
}

class Expresion {
    int tipo;

    public Expresion() {}

    public int getTipo() {return tipo;}
}

class Attrh {
    int tipo;

    public Attrh() {}

    public int getTipo() {return tipo;}
}

public class TraductorDR {

    private final AnalizadorLexico lexico;
    private Token token;
    private Ambito amb;
    private final int ERRYADECL = 1, 
            ERRNODECL = 3, 
            ERRNOVAR = 4, 
            ERRTIPOS = 5;

    public TraductorDR(AnalizadorLexico al) {
        this.lexico = al;
        this.amb = null;
    }

    // Regla 1 (S)
    String S() {
        StringBuilder trad = new StringBuilder(); // Cadena que mostrará al final con el código objeto

        if (token == null) { // Comprobar si es el primer token
            token = lexico.siguienteToken();
        }

        // Regla 1
        if (token.tipo == Token.CLASS) { //Crear ámbito global  
            amb = new Ambito(amb, "", "");
            trad.append(C("", ""));
        } else {
            errorSintaxis(token, Token.CLASS);
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    // Regla 2 (C)
    private String C(String clase, String tipoAmbito) { // Regla 2
        StringBuilder trad = new StringBuilder();
        trad.append(tipoAmbito); trad.append("clase ");
        emparejar(Token.CLASS);
        trad.append(clase);
        String idLexema = token.lexema;
        trad.append(idLexema);

        amb = new Ambito(amb, "clase ", idLexema);

        emparejar(Token.ID);
        trad.append(" {\n");
        emparejar(Token.LLAVEI);
        String BVprefh = clase + idLexema + "::";
        trad.append(B(BVprefh, "publico "));
        trad.append(V(BVprefh, "privado "));
        emparejar(Token.LLAVED);

        trad.append("}\n\n");
        amb = amb.padre;
        ////// System.out.println(trad.toString());         

        return trad.toString();
    }

    // Regla 3 y 4 (B)
    private String B(String clase, String tipoAmbito) {
        StringBuilder trad = new StringBuilder();
        switch (token.tipo) {
            case Token.PUBLIC: // Regla 3
                emparejar(Token.PUBLIC);
                emparejar(Token.DOSP);
                trad.append(P(clase, tipoAmbito));
                break;
            case Token.PRIVATE: // siguientes -> Regla 4
            case Token.LLAVED:
                break;
            default:
                errorSintaxis(token, Token.LLAVED, Token.PUBLIC, Token.PRIVATE);
                break;
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    // Regla 5 y 6 (V)
    private String V(String clase, String tipoAmbito) {
        StringBuilder trad = new StringBuilder();
        if (token.tipo == Token.PRIVATE) { // R5
            emparejar(Token.PRIVATE);
            emparejar(Token.DOSP);
            trad.append(P(clase, tipoAmbito));
        } else if (token.tipo == Token.LLAVED) { // sig -> R6

        } else {
            errorSintaxis(token, Token.LLAVED, Token.PRIVATE);
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String P(String clase, String tipoAmbito) {
        StringBuilder trad = new StringBuilder();
        switch (token.tipo) {
            // R7
            case Token.INT:
            case Token.FLOAT:
            case Token.CLASS:
                trad.append(D(clase, tipoAmbito));
                trad.append(P(clase, tipoAmbito));
                break;
            // siguientes -> R8 
            case Token.PRIVATE:
            case Token.LLAVED:
                break;
            default:
                errorSintaxis(token, Token.INT, Token.FLOAT, Token.CLASS, Token.PRIVATE, Token.LLAVED);
                break;
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String D(String clase, String tipoAmbito) {
        StringBuilder trad = new StringBuilder();
        String idLexema;
        Simbolo simboloId1, simboloId2;
        int idTipo;

        if (token.tipo == Token.INT || token.tipo == Token.FLOAT) { // Regla 9
            if (token.tipo != Token.INT) {
                emparejar(Token.FLOAT);
                idTipo = Simbolo.REAL;

            } else {
                emparejar(Token.INT);
                idTipo = Simbolo.ENTERO;                
            }
            idLexema = clase + token.lexema;
            trad.append(tipoAmbito).append(" ").append(idLexema);

            amb = new Ambito(amb, "función ", idLexema);

            simboloId1 = new Simbolo(idLexema, Simbolo.FUNCION, idTipo);
            if (!amb.add(simboloId1))
                this.errorSemantico(this.ERRYADECL, token);

            emparejar(Token.ID);
            trad.append(" (");
            emparejar(Token.PARI);
            if (token.tipo == Token.INT || token.tipo == Token.FLOAT) {
                if (token.tipo != Token.INT) {
                    emparejar(Token.FLOAT);
                    idTipo = Simbolo.REAL;

                } else {
                    emparejar(Token.INT);
                    idTipo = Simbolo.ENTERO;                
                }
                idLexema = token.lexema;
                simboloId2 = new Simbolo(idLexema, Simbolo.VARIABLE, idTipo);
                if (!amb.add(simboloId2)) {
                    this.errorSemantico(this.ERRYADECL, token);
                }
                trad.append(idLexema).append(":").append(simboloId2.iOrToString());
                emparejar(Token.ID);
                trad.append(L(clase, tipoAmbito));

                trad.append(" -> ");
                trad.append(simboloId1.iOrToString());
                trad.append(")");
                emparejar(Token.PARD);
                trad.append(Cod(clase, tipoAmbito, simboloId1.getIOR()));
            }

            amb = amb.padre;
        } else if (token.tipo == Token.CLASS) { // R10
            trad.append(C(clase, tipoAmbito));

        } else {
            errorSintaxis(token, Token.INT, Token.FLOAT, Token.CLASS);
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Cod(String clase, String tipoAmbito, int tipoFuncion) {
        StringBuilder trad = new StringBuilder();
        if (token.tipo == Token.PYC) { // R11
            emparejar(Token.PYC);
            trad.append(";\n\n");
        } else if (token.tipo == Token.LLAVEI) { // R12
            trad.append("\n\n");
            trad.append(Bloque(clase, tipoAmbito, tipoFuncion));
        } else {
            errorSintaxis(token, Token.PYC, Token.LLAVEI);
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String L(String clase, String tipoAmbito) {
        StringBuilder trad = new StringBuilder();
        String idLexema;
        int idTipo;
        if (token.tipo == Token.COMA) {
           emparejar(Token.COMA);
           if (token.tipo == Token.INT || token.tipo == Token.FLOAT) {
            if (token.tipo != Token.INT) {
                emparejar(Token.FLOAT);
                idLexema = token.lexema;
                idTipo = Simbolo.REAL;
            } else {
                emparejar(Token.INT);
                idLexema = token.lexema;
                idTipo = Simbolo.ENTERO;                
            }
            Simbolo simbolo = new Simbolo(idLexema, Simbolo.FUNCION, idTipo);
            if (!amb.add(simbolo)) {
                this.errorSemantico(this.ERRYADECL, token);
            }
            trad.append(" x ").append(idLexema).append(":").append(simbolo.iOrToString());
            emparejar(Token.ID);
            trad.append(L(clase, tipoAmbito));
            }       
        } else if (token.tipo == Token.PARD) {

        } else {
            errorSintaxis(token, Token.COMA, Token.PARD);
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Tipo(String clase, String tipoAmbito) {
        StringBuilder trad = new StringBuilder();
        if (token.tipo == Token.INT) { // R15
            emparejar(Token.INT);
            trad.append("entero");
        } else if (token.tipo == Token.FLOAT) { // R16
            emparejar(Token.FLOAT);
            trad.append("float");
        } else {
            errorSintaxis(token, Token.INT, Token.FLOAT);
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Bloque(String clase, String tipoAmbito, int tipoFuncion) {
        StringBuilder trad = new StringBuilder();
        if (token.tipo == Token.LLAVEI) { // R17
            emparejar(Token.LLAVEI);
            trad.append("{\n");
            trad.append(SecInstr(clase, tipoAmbito, tipoFuncion));
            emparejar(Token.LLAVED);
            trad.append("}\n");
        } else {
            errorSintaxis(token, Token.LLAVEI);
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String SecInstr(String clase, String tipoAmbito, int tipoFuncion) {
        StringBuilder trad = new StringBuilder();
        switch (token.tipo) {
            case Token.INT: // R18
            case Token.FLOAT:
            case Token.ID:
            case Token.LLAVEI:
            case Token.RETURN:
                trad.append(Instr(clase, tipoAmbito, tipoFuncion));
                emparejar(Token.PYC);
                trad.append(SecInstr(clase, tipoAmbito, tipoFuncion));
                break;
            case Token.LLAVED: // R19
                break;
            default:
                errorSintaxis(token, Token.ID, Token.LLAVEI, Token.LLAVED, Token.INT, Token.FLOAT, Token.RETURN);
        }

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Instr(String clase, String tipoAmbito, int tipoFuncion) {
        StringBuilder trad = new StringBuilder();
        Simbolo simbolo, id;
        String idLexema = null;
        Token tkerror;
        String expr_trad;
        int idTipo = 0;
        Expresion expr;
        switch (token.tipo) {
            case Token.INT: // R20
                emparejar(Token.INT);
                idLexema = token.lexema;
                idTipo = Simbolo.ENTERO;
                simbolo = new Simbolo(idLexema, Simbolo.VARIABLE, idTipo);
                if (!amb.add(simbolo))
                    this.errorSemantico(this.ERRYADECL, token);

                emparejar(Token.ID);
                trad.append("var ").append(simbolo.nombre).append(": ").append(simbolo.iOrToString()).append(";\n");
                break;
            case Token.FLOAT:
                emparejar(Token.FLOAT);
                idLexema = token.lexema;
                idTipo = Simbolo.REAL;
                simbolo = new Simbolo(idLexema, Simbolo.VARIABLE, idTipo);
                if (!amb.add(simbolo))
                    this.errorSemantico(this.ERRYADECL, token);

                emparejar(Token.ID);
                trad.append("var ").append(simbolo.nombre).append(": ").append(simbolo.iOrToString()).append(";\n");
                break;
            case Token.ID: // R21
                try {
                    id = amb.buscar(token.lexema);
                    idLexema = id.getNombre();
                    idTipo = id.iOr;
                } catch (Exception e) {
                    this.errorSemantico(this.ERRNODECL, token);
                }

                emparejar(Token.ID);
                tkerror = token;
                emparejar(Token.ASIG);
                expr = new Expresion();
                expr_trad = Expr(clase, tipoAmbito, expr);
                if (((expr.tipo == Token.ENTERO || expr.tipo == Token.INT) && (idTipo == Simbolo.ENTERO)) || ((expr.tipo == Token.REAL || expr.tipo == Token.FLOAT) 
                                        && (idTipo == Simbolo.REAL))) {
                    trad.append(idLexema).append(" := ").append(expr_trad).append(";\n");
                } else if ((expr.tipo == Token.ENTERO || expr.tipo == Token.INT) && (idTipo == Simbolo.REAL)) {
                    trad.append(idLexema).append(" := " + "itor(").append(expr_trad).append(")" + ";\n");
                } else {
                    this.errorSemantico(this.ERRTIPOS, tkerror);
                }
                break;
            case Token.LLAVEI: // R22 
                amb = new Ambito(amb, "bloque ", "");
                trad.append(Bloque(clase, tipoAmbito, tipoFuncion));
                amb = amb.padre;
                break;
            case Token.RETURN: // Regla 23
                tkerror = token;
                emparejar(Token.RETURN);
                expr = new Expresion();
                trad.append("retorna ");
                expr_trad = Expr(clase, tipoAmbito, expr);
                if (((expr.tipo == Token.ENTERO || expr.tipo == Token.INT) && (tipoFuncion == Simbolo.ENTERO))
                                || ((expr.tipo == Token.REAL || expr.tipo == Token.FLOAT) && (tipoFuncion == Simbolo.REAL))) {
                    trad.append(expr_trad).append(";\n");
                } else if ((expr.tipo == Token.ENTERO || expr.tipo == Token.INT) && (tipoFuncion == Simbolo.REAL)) {
                    trad.append("itor(").append(expr_trad).append(")" + ";\n");
                } else {
                    this.errorSemantico(this.ERRTIPOS, tkerror);
                }
                break;
            case Token.LLAVED: // R19
                break;
            default:
                errorSintaxis(token, Token.ID, Token.LLAVEI, Token.LLAVED, Token.INT, Token.FLOAT, Token.RETURN);
        }
        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Expr(String clase, String tipoAmbito, Expresion expr) { // R24
        StringBuilder trad = new StringBuilder();
        String tradTerm = Term(clase, tipoAmbito, expr);
        int i = expr.tipo;
        String tradExpr_ = Expr_(clase, tipoAmbito, expr);
        int j = expr.tipo;
        if ((i == Token.ENTERO || i == Token.INT || i == Simbolo.ENTERO) && (j == Token.ENTERO || j == Token.INT || j == Simbolo.ENTERO)) {
            expr.tipo = Token.ENTERO;
            trad.append(tradTerm);
        } else if ((i == Token.ENTERO || i == Token.INT || i == Simbolo.ENTERO) && (j == Token.REAL || j == Token.FLOAT || j == Simbolo.REAL)) {
            expr.tipo = Token.REAL;
            trad.append("itor(").append(tradTerm).append(")");
        } else {
            expr.tipo = Token.REAL;
            trad.append(tradTerm);
        }
        trad.append(tradExpr_);
        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Expr_(String clase, String tipoAmbito, Expresion expr) {
        StringBuilder trad = new StringBuilder();
        if (token.tipo == Token.ADDOP) {
            String mulLexema = token.lexema;
            emparejar(Token.ADDOP);
            int tipoH = expr.tipo;
            String tradTerm = Term(clase, tipoAmbito, expr);
            String tradExpr_ = Expr_(clase, tipoAmbito, expr);
            int expT = expr.tipo;
            String etiquetaOperacion = getEtiqueta(mulLexema, tipoH, expT);

            trad.append(etiquetaOperacion).append(tradTerm).append(tradExpr_);
        } else if (token.tipo == Token.PYC || token.tipo == Token.PARD) {
                // no hace nada
        } else {
            errorSintaxis(token, Token.ADDOP, Token.PYC, Token.PARD);
        }
        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Term(String clase, String tipoAmbito, Expresion expr) { // Regla 27
        StringBuilder trad = new StringBuilder();

        String tradFactor = Factor(clase, tipoAmbito, expr);
        int expI = expr.tipo;
        String tradTerm_1 = Term_(clase, tipoAmbito, expr);
        int expJ = expr.tipo;

        if ((expI == Token.ENTERO || expI == Token.INT || expI == Simbolo.ENTERO) && (expJ == Token.REAL || expJ == Token.FLOAT || expJ == Simbolo.REAL)) {
            trad.append("itor(").append(tradFactor).append(")");
        } else {
            trad.append(tradFactor);
        }
        trad.append(tradTerm_1);

        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Term_(String clase, String tipoAmbito, Expresion expr) {
        StringBuilder trad = new StringBuilder();
        switch (token.tipo) {
            case Token.MULOP: // Regla 28
                String mulLexema = token.lexema;
                emparejar(Token.MULOP);
                int tipoH = expr.tipo;
                String tradFactor = Factor(clase, tipoAmbito, expr);
                String tradTerm_ = Term_(clase, tipoAmbito, expr);
                String etiquetaOperacion = getEtiqueta(mulLexema, tipoH, expr.tipo);

                trad.append(etiquetaOperacion).append(tradFactor).append(tradTerm_);
                break;
            case Token.ADDOP: // Regla 29
            case Token.PYC:
            case Token.PARD:
                break;
            default:
                errorSintaxis(token, Token.MULOP, Token.ADDOP, Token.PYC, Token.PARD);
        }
        ////// System.out.println(trad.toString());         ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    private String Factor(String clase, String tipoAmbito, Expresion expr) {
        StringBuilder trad = new StringBuilder();
        String idLexema;
        switch (token.tipo) {
            case Token.PARI: // Regla 33
                trad.append("(");
                emparejar(Token.PARI);
                trad.append(Expr(clase, tipoAmbito, expr));
                trad.append(")");
                emparejar(Token.PARD);
                break;
            case Token.ID: // Regla 32
                idLexema = token.lexema;
                Simbolo sim;
                try {
                    sim = amb.buscar(idLexema);
                    trad.append(sim.nombre);
                    expr.tipo = sim.iOr;
                } catch (Exception e) {
                    this.errorSemantico(ERRNOVAR, token);
                }
                emparejar(Token.ID);
                break;
            case Token.ENTERO: // Regla 31
                idLexema = token.lexema;
                expr.tipo = token.tipo;
                emparejar(Token.ENTERO);
                trad.append(idLexema);
                break;
            case Token.REAL: // Regla 30
                idLexema = token.lexema;
                expr.tipo = token.tipo;
                emparejar(Token.REAL);
                trad.append(idLexema);
                break;
            default:
                errorSintaxis(token, Token.MULOP, Token.ADDOP, Token.PYC, Token.PARD);
        }
        ////// System.out.println(trad.toString());         
        return trad.toString();
    }

    void comprobarFinFichero() {
        // Error, no se alcanzó fin de fichero
        if (token.tipo != Token.EOF) {
            errorSintaxis(token, Token.EOF);
            return;
        }
    }

    // Emparejar
    private void emparejar(int tokEsperado) {
        if (token.tipo == tokEsperado) {
            token = lexico.siguienteToken();
        } else {
            errorSintaxis(token, tokEsperado);
        }
    }

    private void errorSintaxis(Token tk, Integer... tokensEsperados) {
        if (tk.tipo != Token.EOF) {
            System.err.print("Error sintactico (" + tk.fila + ","
                    + tk.columna + "): encontrado '" + tk.lexema + "', esperaba ");
        } else {
            System.err.print("Error sintactico: encontrado fin de fichero, esperaba ");
        }

        for (int i : tokensEsperados) {
            Token aux = new Token();
            aux.tipo = i;
            System.err.print(" " + aux.toString());
        }
        System.exit(-1);
    }

    private void errorSemantico(int nerror, Token tok) {
        System.err.print("Error semantico (" + tok.fila + "," + tok.columna + "): '" + tok.lexema + "' ");
        switch (nerror) {
            case ERRYADECL:
                System.err.println("ya existe en este ambito");
                break;
            case ERRNODECL:
                System.err.println("no ha sido declarado");
                break;
            case ERRNOVAR:
                System.err.println("no es una variable");
                break;
            case ERRTIPOS:
                System.err.println("tipos incompatibles entero/real");
                break;
        }
        System.exit(-1);
    }

    private String getEtiqueta(String mulLexema, int i, int j) {
        if ((i == 16 || i == 14 || i == 1) && (j == 16 || j == 14 || j == 1)) {
            return " " + mulLexema + "i ";
        } else {
            return " " + mulLexema + "r ";
        }
    }

}
