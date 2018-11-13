

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
            PYC = 2,
            DOSP = 3,
            COMA = 4,
            ASIG = 5,
            LLAVEI = 6,
            LLAVED = 7,
            CLASS = 8,
            PUBLIC = 9,
            PRIVATE = 10,
            FLOAT = 11,
            INT = 12,
            ENTERO = 13,
            ID = 14,
            REAL = 15,
            EOF = 16;

    @Override
    public String toString() {
        switch (tipo) {
            case PARI:
                return "(";
            case PARD:
                return ")";
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
