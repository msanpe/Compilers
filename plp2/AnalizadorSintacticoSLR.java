/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


import java.util.Stack;

/**
 *
 * @author Miguel
 */
class Accion { // nested class representing an action
    public static final char R = 'r';
    public static final char A = 'a';
    public static final char D = 'd';

    public char action;
    public int numero;

    public Accion(char accion, int estado) {
        this.action = accion;
        this.numero = estado;
    }

    public Accion() {
        action = 'A';
        numero = 0;
    }

    public void setAccion(char accion, int num) {
        this.action = accion;
        this.numero = num;
    }

}

public class AnalizadorSintacticoSLR {
    public static final int numEstados = 47;
    public static final int numTokens = 23;
    private AnalizadorLexico al;
    private Token token;
    private StringBuilder reglasAplicadas;
    private Stack<Integer> pila;
    private Accion[][] actions;
    private int[][] ir_A;

    public AnalizadorSintacticoSLR(AnalizadorLexico al) {
        this.al = al;
        reglasAplicadas = new StringBuilder();
        pila = new Stack<>();
        actions = new Accion[numEstados][numTokens];
        ir_A = new int[numEstados][numTokens];
        initMatrix();
    }

    public void analizar() {
        pila.push(0);
        Stack<Integer> solucion = new Stack<>();
        int estadoActual = 0;
        token = al.siguienteToken();

        while (true) {
            estadoActual = pila.peek();

            if (actions[estadoActual][token.tipo] == null) {
                errorSintaxis(estadoActual);
            } else if (actions[estadoActual][token.tipo].action == Accion.D) {
                pila.push(actions[estadoActual][token.tipo].numero);
                token = al.siguienteToken();
            } else if (actions[estadoActual][token.tipo].action == Accion.R) {
                int lng = LongParteDcha(actions[estadoActual][token.tipo].numero);
                int p = 0;

                for (int i = 1; i <= lng; ++i) {
                    pila.pop();
                }
                solucion.push(actions[estadoActual][token.tipo].numero);
                int A = ReglaParteIzq(actions[estadoActual][token.tipo].numero);
                p = pila.peek();

                pila.push(ir_A[p][A]);
            } else if (actions[estadoActual][token.tipo].action == Accion.A) {
                break;
            } else {
                errorSintaxis(estadoActual);
            }
        }

        while (!solucion.empty()) {
            System.out.print(solucion.pop() + " ");
        }
        System.out.println();
    }

    public int LongParteDcha(int regla) {
        switch (regla) {
            case 1:
                return 1;
            case 2:
                return 6;
            case 3:
                return 3;
            case 4:
                return 0;
            case 5:
                return 3;
            case 6:
                return 0;
            case 7:
                return 2;
            case 8:
                return 0;
            case 9:
                return 8;
            case 10:
                return 1;
            case 11:
                return 1;
            case 12:
                return 1;
            case 13:
                return 4;
            case 14:
                return 0;
            case 15:
                return 1;
            case 16:
                return 1;
            case 17:
                return 3;
            case 18:
                return 3;
            case 19:
                return 0;
            case 20:
                return 3;
            case 21:
                return 1;
            case 22:
                return 1;
            case 23:
                return 1;
            case 24:
                return 1;
            default:
                return 0;
        }
    }

    public int ReglaParteIzq(int regla) {
        switch (regla) {
            case 1:
                return 0;
            case 2:
                return 1;
            case 3:
                return 2;
            case 4:
                return 2;
            case 5:
                return 3;
            case 6:
                return 3;
            case 7:
                return 4;
            case 8:
                return 4;
            case 9:
                return 5;
            case 10:
                return 5;
            case 11:
                return 6;
            case 12:
                return 6;
            case 13:
                return 7;
            case 14:
                return 7;
            case 15:
                return 8;
            case 16:
                return 8;
            case 17:
                return 9;
            case 18:
                return 10;
            case 19:
                return 10;
            case 20:
                return 11;
            case 21:
                return 11;
            case 22:
                return 12;
            case 23:
                return 12;
            case 24:
                return 12;
            default:
                return 0;
        }
    }

    public final void errorSintaxis(int estadoActual) {
        if (token.tipo == Token.EOF) {
            System.err.print("Error sintactico: encontrado el final del fichero, esperaba ");
        } else {
            System.err.print("Error sintactico (" + token.fila + "," + token.columna + "): encontrado \'" + token.lexema + "\', esperaba ");
        }

        for (int i = 0; i < numTokens; ++i) {
            if (actions[estadoActual][i] != null) {
                Token aux = new Token();
                aux.tipo = i;
                System.err.print(" " + aux.toString());
            }
        }
        System.err.println();
        System.exit(-1);
    }

    private void initMatrix() {
        initActions();
        initIrA();
    }

    private void initActions() {
        actions[0][8] = new Accion('d', 3);
        actions[1][16] = new Accion('a', 0);
        actions[2][16] = new Accion('r', 1);
        actions[3][14] = new Accion('d', 4);
        actions[4][6] = new Accion('d', 5);
        actions[5][7] = new Accion('r', 4);
        actions[5][9] = new Accion('d', 7);
        actions[5][10] = new Accion('r', 4);
        actions[6][7] = new Accion('r', 6);
        actions[6][10] = new Accion('d', 16);
        actions[7][3] = new Accion('d', 8);
        actions[8][7] = new Accion('r', 8);
        actions[8][8] = new Accion('d', 3);
        actions[8][10] = new Accion('r', 8);
        actions[8][11] = new Accion('d', 13);
        actions[8][12] = new Accion('d', 14);
        actions[9][7] = new Accion('r', 3);
        actions[9][10] = new Accion('r', 3);
        actions[10][7] = new Accion('r', 8);
        actions[10][8] = new Accion('d', 3);
        actions[10][10] = new Accion('r', 8);
        actions[10][11] = new Accion('d', 13);
        actions[10][12] = new Accion('d', 14);
        actions[11][14] = new Accion('d', 21);
        actions[12][7] = new Accion('r', 10);
        actions[12][8] = new Accion('r', 10);
        actions[12][10] = new Accion('r', 10);
        actions[12][11] = new Accion('r', 10);
        actions[12][12] = new Accion('r', 10);
        actions[13][14] = new Accion('r', 16);
        actions[14][14] = new Accion('r', 15);
        actions[15][7] = new Accion('d', 17);
        actions[16][3] = new Accion('d', 18);
        actions[17][7] = new Accion('r', 2);
        actions[17][8] = new Accion('r', 2);
        actions[17][10] = new Accion('r', 2);
        actions[17][11] = new Accion('r', 2);
        actions[17][12] = new Accion('r', 2);
        actions[17][16] = new Accion('r', 2);
        actions[18][7] = new Accion('r', 8);
        actions[18][8] = new Accion('d', 3);
        actions[18][10] = new Accion('r', 8);
        actions[18][11] = new Accion('d', 13);
        actions[18][12] = new Accion('d', 14);
        actions[19][7] = new Accion('r', 5);
        actions[20][7] = new Accion('r', 7);
        actions[20][10] = new Accion('r', 7);
        actions[21][0] = new Accion('d', 22);
        actions[22][11] = new Accion('d', 13);
        actions[22][12] = new Accion('d', 14);
        actions[23][14] = new Accion('d', 24);
        actions[24][1] = new Accion('r', 14);
        actions[24][4] = new Accion('d', 26);
        actions[25][1] = new Accion('d', 30);
        actions[26][11] = new Accion('d', 13);
        actions[26][12] = new Accion('d', 14);
        actions[27][14] = new Accion('d', 28);
        actions[28][1] = new Accion('r', 14);
        actions[28][4] = new Accion('d', 26);
        actions[29][1] = new Accion('r', 13);
        actions[30][2] = new Accion('d', 32);
        actions[30][6] = new Accion('d', 34);
        actions[31][7] = new Accion('r', 9);
        actions[31][8] = new Accion('r', 9);
        actions[31][10] = new Accion('r', 9);
        actions[31][11] = new Accion('r', 9);
        actions[31][12] = new Accion('r', 9);
        actions[32][7] = new Accion('r', 11);
        actions[32][8] = new Accion('r', 11);
        actions[32][10] = new Accion('r', 11);
        actions[32][11] = new Accion('r', 11);
        actions[32][12] = new Accion('r', 11);
        actions[33][7] = new Accion('r', 12);
        actions[33][8] = new Accion('r', 12);
        actions[33][10] = new Accion('r', 12);
        actions[33][11] = new Accion('r', 12);
        actions[33][12] = new Accion('r', 12);
        actions[34][6] = new Accion('d', 34);
        actions[34][7] = new Accion('r', 19);
        actions[34][14] = new Accion('d', 36);
        actions[35][2] = new Accion('r', 21);
        actions[36][5] = new Accion('d', 42);
        actions[37][2] = new Accion('d', 39);
        actions[38][7] = new Accion('d', 41);
        actions[39][6] = new Accion('d', 34);
        actions[39][7] = new Accion('r', 19);
        actions[39][14] = new Accion('d', 36);
        actions[40][7] = new Accion('r', 18);
        actions[41][2] = new Accion('r', 17);
        actions[41][7] = new Accion('r', 17);
        actions[41][8] = new Accion('r', 17);
        actions[41][10] = new Accion('r', 17);
        actions[41][11] = new Accion('r', 17);
        actions[41][12] = new Accion('r', 17);
        actions[42][13] = new Accion('d', 45);
        actions[42][14] = new Accion('d', 46);
        actions[42][15] = new Accion('d', 44);
        actions[43][2] = new Accion('r', 20);
        actions[44][2] = new Accion('r', 22);
        actions[45][2] = new Accion('r', 23);
        actions[46][2] = new Accion('r', 24);
    }

    private void initIrA() {
        ir_A[0][0] = 1;
        ir_A[0][1] = 2;
        ir_A[5][2] = 6;
        ir_A[6][3] = 15;
        ir_A[8][1] = 12;
        ir_A[8][4] = 9;
        ir_A[8][5] = 10;
        ir_A[8][8] = 11;
        ir_A[10][1] = 12;
        ir_A[10][4] = 20;
        ir_A[10][5] = 10;
        ir_A[10][8] = 11;
        ir_A[18][1] = 12;
        ir_A[18][4] = 19;
        ir_A[18][5] = 10;
        ir_A[18][8] = 11;
        ir_A[22][8] = 23;
        ir_A[24][7] = 25;
        ir_A[26][8] = 27;
        ir_A[28][7] = 29;
        ir_A[30][6] = 31;
        ir_A[30][9] = 33;
        ir_A[34][9] = 35;
        ir_A[34][10] = 38;
        ir_A[34][11] = 37;
        ir_A[39][9] = 35;
        ir_A[39][10] = 40;
        ir_A[39][11] = 37;
        ir_A[42][12] = 43;
    }
}
