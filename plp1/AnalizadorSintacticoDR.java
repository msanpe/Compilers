import java.util.Arrays;

/**
 *
 * @author Miguel
 */
public class AnalizadorSintacticoDR {

    Token siguienteToken;
    AnalizadorLexico lexico;
    StringBuilder reglasAplicadas;

    public AnalizadorSintacticoDR() {
        reglasAplicadas = new StringBuilder();
    }

    public AnalizadorSintacticoDR(AnalizadorLexico lexico) {
        this.lexico = lexico;
        reglasAplicadas = new StringBuilder();
    }

    private void addRule(int rule) {
        String newRule = " " + rule;
        reglasAplicadas.append(newRule);
    }

    public void S() {
        siguienteToken = lexico.siguienteToken();

        if (siguienteToken.tipo == Token.CLASS) {
            addRule(1);
            C();
        } else {
            errorSintaxis(Token.CLASS);
        }
    }

    public void C() {
        if (siguienteToken.tipo == Token.CLASS) {
            addRule(2);
            emparejar(Token.CLASS);
            emparejar(Token.ID);
            emparejar(Token.LLAVEI);
            B();
            V();
            emparejar(Token.LLAVED);
        } else {
            errorSintaxis(Token.CLASS);
        }
    }

    public void B() {
        if (siguienteToken.tipo == Token.PUBLIC) {
            addRule(3);
            emparejar(Token.PUBLIC);
            emparejar(Token.DOSP);
            P();
        } else if (siguienteToken.tipo != Token.PRIVATE && siguienteToken.tipo != Token.LLAVED) {
            errorSintaxis(Token.LLAVED, Token.PUBLIC, Token.PRIVATE);
        } else {
            addRule(4);
        }
    }

    public void V() {
        if (siguienteToken.tipo == Token.PRIVATE) {
            addRule(5);
            emparejar(Token.PRIVATE);
            emparejar(Token.DOSP);
            P();
        } else if (siguienteToken.tipo == Token.LLAVED) {
            addRule(6);
        } else {
            errorSintaxis(Token.LLAVED, Token.PRIVATE);
        }
    }

    public void P() {
        if (siguienteToken.tipo == Token.CLASS || siguienteToken.tipo == Token.FLOAT || siguienteToken.tipo == Token.INT) {
            addRule(7);
            D();
            P();
        } else if (siguienteToken.tipo == Token.PRIVATE || siguienteToken.tipo == Token.LLAVED) {
            addRule(8);
        } else {
            errorSintaxis(Token.CLASS, Token.LLAVED, Token.PRIVATE, Token.INT, Token.FLOAT);
        }
    }

    public void D() {
        if (siguienteToken.tipo == Token.INT || siguienteToken.tipo == Token.FLOAT) {
            addRule(9);
            Tipo();
            emparejar(Token.ID);
            emparejar(Token.PARI);
            Tipo();
            emparejar(Token.ID);
            L();
            emparejar(Token.PARD);
            Cod();
        } else if (siguienteToken.tipo == Token.CLASS) {
            addRule(10);
            C();
        } else {
            errorSintaxis(Token.CLASS, Token.INT, Token.FLOAT);
        }
    }

    public void Cod() {
        if (siguienteToken.tipo == Token.PYC) {
            addRule(11);
            emparejar(Token.PYC);
        } else if (siguienteToken.tipo == Token.LLAVEI) {
            addRule(12);
            Bloque();
        }else {
            errorSintaxis(Token.LLAVEI, Token.PYC);
        }
    }

    public void L() {
        if (siguienteToken.tipo == Token.COMA) {
            addRule(13);
            emparejar(Token.COMA);
            Tipo();
            emparejar(Token.ID);
            L();
        } else if (siguienteToken.tipo == Token.PARD) {
            addRule(14);
        } else {
            errorSintaxis(Token.PARD, Token.COMA);
        }
    }

    public void Tipo() {
        if (siguienteToken.tipo == Token.INT) {
            addRule(15);
            emparejar(Token.INT);
        } else if (siguienteToken.tipo == Token.FLOAT) {
            addRule(16);
            emparejar(Token.FLOAT);
        } else {
            errorSintaxis(Token.INT, Token.FLOAT);
        }
    }

    public void Bloque() {
        if (siguienteToken.tipo == Token.LLAVEI) {
            addRule(17);
            emparejar(Token.LLAVEI);
            SecInstr();
            emparejar(Token.LLAVED);
        } else {
            errorSintaxis(Token.LLAVEI);
        }
    }

    public void SecInstr() {
        if (siguienteToken.tipo == Token.RETURN || siguienteToken.tipo == Token.ID
                || siguienteToken.tipo == Token.FLOAT || siguienteToken.tipo == Token.INT
                    || siguienteToken.tipo == Token.LLAVEI) {
            addRule(18);
            Instr();
            emparejar(Token.PYC);
            SecInstr();
        } else if (siguienteToken.tipo == Token.LLAVED) {
            addRule(19);
        } else {
            errorSintaxis(Token.ID, Token.LLAVEI, Token.LLAVED, Token.INT, Token.FLOAT, Token.RETURN);
        }
    }

    public void Instr() {
        if (siguienteToken.tipo == Token.FLOAT || siguienteToken.tipo == Token.INT) {
            addRule(20);
            Tipo();
            emparejar(Token.ID);
        } else if (siguienteToken.tipo == Token.ID) {
            addRule(21);
            emparejar(Token.ID);
            emparejar(Token.ASIG);
            Expr();
        } else if (siguienteToken.tipo == Token.LLAVEI) {
            addRule(22);
            Bloque();
        } else if (siguienteToken.tipo == Token.RETURN) {
            addRule(23);
            emparejar(Token.RETURN);
            Expr();
        } else {
            errorSintaxis(Token.ID, Token.LLAVEI, Token.INT, Token.FLOAT, Token.RETURN);
        }
    }

    public void Expr() {
        if (siguienteToken.tipo == Token.PARI || siguienteToken.tipo == Token.ID
                || siguienteToken.tipo == Token.ENTERO || siguienteToken.tipo == Token.REAL) {
            addRule(24);
            Term();
            ExprPrima();
        } else {
            errorSintaxis(Token.ID, Token.PARI, Token.REAL, Token.ENTERO);
        }
    }

    public void ExprPrima() {
        if (siguienteToken.tipo == Token.ADDOP) {
            addRule(25);
            emparejar(Token.ADDOP);
            Term();
            ExprPrima();
        } else if (siguienteToken.tipo == Token.PARD || siguienteToken.tipo == Token.PYC) {
            addRule(26);
        } else {
            errorSintaxis(Token.PARD, Token.PYC ,Token.ADDOP);
        }
    }

    public void Term() {
        if (siguienteToken.tipo == Token.PARI || siguienteToken.tipo == Token.ID
                || siguienteToken.tipo == Token.ENTERO || siguienteToken.tipo == Token.REAL) {
            addRule(27);
            Factor();
            TermPrima();
        } else {
            errorSintaxis(Token.ID, Token.PARI, Token.REAL, Token.ENTERO);
        }
    }

    public void TermPrima() {
        if (siguienteToken.tipo == Token.MULOP) {
            addRule(28);
            emparejar(Token.MULOP);
            Factor();
            TermPrima();
        } else if (siguienteToken.tipo == Token.ADDOP || siguienteToken.tipo == Token.PYC || siguienteToken.tipo == Token.PARD) {
            addRule(29);
        } else {
            errorSintaxis(Token.PARD, Token.PYC, Token.ADDOP, Token.MULOP);
        }
    }

    public void Factor() {
        if (siguienteToken.tipo == Token.REAL) {
            addRule(30);
            emparejar(Token.REAL);
        } else if (siguienteToken.tipo == Token.ENTERO) {
            addRule(31);
            emparejar(Token.ENTERO);
        } else if (siguienteToken.tipo == Token.ID) {
            addRule(32);
            emparejar(Token.ID);
        } else if (siguienteToken.tipo == Token.PARI) {
            addRule(33);
            emparejar(Token.PARI);
            Expr();
            emparejar(Token.PARD);
        } else {
            errorSintaxis(Token.ID, Token.PARI, Token.REAL, Token.ENTERO);
        }
    }

    public void errorSintaxis(int... tokEsperados) {
        if (siguienteToken.tipo == Token.EOF) {
            System.err.print("Error sintactico: encontrado fin de fichero, esperaba ");
        } else {
            System.err.print("Error sintactico (" + siguienteToken.fila + "," + siguienteToken.columna + "): encontrado \'" + siguienteToken.lexema + "\', esperaba ");
        }
        for (int i : tokEsperados) {
            Token aux = new Token();
            aux.tipo = i;
            System.err.print(" " + aux.toString());
        }
        System.err.println();

        System.exit(-1);
    }

    public final void comprobarFinFichero() {
        if (siguienteToken.tipo != Token.EOF) {
            errorFinalFichero(Token.EOF);

        }
        System.out.println(reglasAplicadas);
    }

    public final void errorFinalFichero(int... tokensEsperados) {
        errorSintaxis(tokensEsperados);
        System.exit(-1);
    }

    public final void emparejar(int tokEsperado) {
        if (siguienteToken.tipo == tokEsperado) {
            siguienteToken = lexico.siguienteToken();
        } else {
            errorSintaxis(tokEsperado);
        }
    }
}
