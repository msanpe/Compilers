/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


import java.io.EOFException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.LinkedList;
import java.util.Queue;

/**
 *
 * @author Miguel
 */
public class AnalizadorLexico {

    private RandomAccessFile fichero;
    private String lexema;
    private Queue<Character> buffer;
    public static final char EOF = '$';
    private int currentRow;
    private int currentColumn;
    private Token token;

    public AnalizadorLexico() {

    }

    public AnalizadorLexico(RandomAccessFile entrada) {
        fichero = entrada;
        buffer = new LinkedList<>();
        currentRow = 1;
        currentColumn = 1;
    }

    public Token siguienteToken() {
        token = new Token();
        lexema = "";
        token.fila = currentRow;
        token.columna = currentColumn;

        char input;
        int currentState = 1;
        int previousState = 1;

        while (currentState > 0) {
            if (currentState == 1) {
                token.fila = currentRow;
                token.columna = currentColumn;
            }

            if (currentState == 1 && !buffer.isEmpty()) {
                token.columna -= 1;
            }

            input = leerCaracter();

            previousState = currentState;
            currentState = delta(currentState, input);

            if (buffer.isEmpty() && input != '\n' && input != '\t' && input != ' ' && currentState != 3 && currentState != 4 && previousState != 4) {
                lexema += input;
            }

        }

        if (currentState == -14) { // se ha encontrado ID lo comprobamos
            switch (lexema) {
                case "class":
                    currentState = -8;
                    break;
                case "public":
                    currentState = -9;
                    break;
                case "private":
                    currentState = -10;
                    break;
                case "float":
                    currentState = -11;
                    break;
                case "int":
                    currentState = -12;
                    break;
                default:
                    break;
            }
        }

        token.lexema = lexema;
        token.tipo = currentState * -1;

        return token;
    }

    public char leerCaracter() {
        char currentChar;
        try {
            if (buffer.isEmpty()) {
                currentChar = (char) fichero.readByte();
                currentColumn++;

                if (currentChar == '\n') {
                    currentColumn = 1;
                    currentRow++;
                }
            } else {
                currentChar = buffer.poll();
            }

            return currentChar;

        } catch (EOFException e) {
            return EOF;
        } catch (IOException e) {
        }
        return ' ';
    }

    public void analizar() {

    }

    private int delta(int state, char c) {
        switch (state) {
            case 1:
                if (c == ' ' || c == '\t' || c == '\n') {
                    return 1;
                } else if (c == '(') {
                    return -0;
                } else if (c == ')') {
                    return -1;
                } else if (c == ',') {
                    return -4;
                } else if (c == '{') {
                    return -6;
                } else if (c == '}') {
                    return -7;
                } else if (c == ':') {
                    return -3;
                } else if (c == '=') {
                    return -5;
                } else if (c == ';') {
                    return -2;
                } else if (c == '/') {
                    return 2;
                } else if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) {
                    return 8;
                } else if (c >= '0' && c <= '9') {
                    return 5;
                } else if (c == EOF) {
                    return -16;
                } else {
                    System.err.println("Error lexico (" + (currentRow) + ","
                            + (currentColumn - 1 - (buffer.size()))
                            + "): caracter '" + c + "' incorrecto");
                    System.exit(-1);
                }
            case 2:
                switch (c) {
                    case '*':
                        lexema = lexema.substring(0, lexema.length() - 1); // quitar la barra
                        return 3;
                    case EOF:
                        System.err.println("Error lexico: fin de fichero inesperado");
                        System.exit(-1);
                    default:
                        System.err.println("Error lexico (" + (currentRow) + ","
                                + (currentColumn - 1 - (buffer.size()))
                                + "): caracter '" + c + "' incorrecto");
                        System.exit(-1);
                }
            case 3:
                switch (c) {
                    case '*':
                        return 4;
                    case EOF:
                        System.err.println("Error lexico: fin de fichero inesperado");
                        System.exit(-1);
                    default:
                        return 3;
                }
            case 4:
                switch (c) {
                    case '*':
                        return 4;
                    case '/':
                        return 1;
                    case EOF:
                        System.err.println("Error lexico: fin de fichero inesperado");
                        System.exit(-1);
                    default:
                        return 3;
                }
            case 5:
                if (c >= '0' && c <= '9') {
                    return 5;
                } else if (c == '.') {
                    return 6;
                } else {
                    buffer.add(c);
                    return -13;
                }
            case 6:
                if (c >= '0' && c <= '9') {
                    return 7;
                } else {
                    buffer.add('.');
                    buffer.add(c);
                    lexema = lexema.substring(0, lexema.length() - 1); // quitar el punto
                    return -13;
                }
            case 7:
                if (c >= '0' && c <= '9') {
                    return 7;
                } else {
                    buffer.add(c);
                    return -15;
                }
            case 8:
                if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
                    return 8;
                } else {
                    buffer.add(c);
                    return -14;
                }
        }

        return 0;
    }
}
