/**
 *
 * @author Miguel
 */
public class Token {

    public int fila;
    public int columna;
    public String lexema;
    public int tipo;    // tipo es: ID, ENTERO, REAL ...
    public static final int PARI = 0,
            PARD = 1,
            MULOP = 2,
            ADDOP = 3,
            PYC = 4,
            DOSP = 5,
            COMA = 6,
            ASIG = 7,
            LLAVEI = 8,
            LLAVED = 9,
            CLASS = 10,
            PUBLIC = 11,
            PRIVATE = 12,
            FLOAT = 13,
            INT = 14,
            RETURN = 15,
            ENTERO = 16,
            ID = 17,
            REAL = 18,
            EOF = 19;

    @Override
    public String toString() {
        switch (tipo) {
            case PARI:
                return "(";
            case PARD:
                return ")";
            case MULOP:
                return "* /";
            case ADDOP:
                return "+ -";
            case PYC:
                return ";";
            case DOSP:
                return ":";
            case COMA:
                return ",";
            case ASIG:
                return "=";
            case LLAVEI:
                return "{";
            case LLAVED:
                return "}";
            case CLASS:
                return "'class'";
            case PUBLIC:
                return "'public'";
            case PRIVATE:
                return "'private'";
            case FLOAT:
                return "'float'";
            case INT:
                return "'int'";
            case RETURN:
                return "'return'";
            case ENTERO:
                return "num entero";
            case ID:
                return "identificador";
            case REAL:
                return "numero real";
            case EOF:
                return "final de fichero";
            default:
                break;
        }
        return "";
    }
}
