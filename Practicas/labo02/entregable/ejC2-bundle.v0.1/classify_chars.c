
#include <iostream>
#include <vector>

using namespace std;

int sumaElementos(vector<int>& s) {
int suma = 0;
for(int i = 0; i < s.size(); i++) {
suma += s[i];
}
return suma;
}

/*

2 -200
500 700

      -1200  -1100 -1000  -900  -800  -700  -600  -500  -400  -300 -200  -100  0  100  200  300  400  500  600  700  800  900  1000  1100  1200

0                            F                        T                                                 T
--------------------------------------------------------------------------------------------------------------------------------------------------------
1        T                                                            T                  T                                                    T
---------------------------------------------------------------------------------------------------------------------------------------------------------

4
5 7 7 1

      -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16  17  18  19  20

0                                                              T                            T
---------------------------------------------------------------------------------------------------------------------------------------------------------
1                                      T                                T           T                               T
---------------------------------------------------------------------------------------------------------------------------------------------------------
2          T                                      T             T                           T           T                                      T
--------------------------------------------------------------------------------------------------------------------------------------------------------
3     T       T                                T     T      T      T                     T     T      T    T                                T        T
--------------------------------------------------------------------------------------------------------------------------------------------------------
*/

void reconstruir(vector<int>& libro, vector<char>& signos, vector<vector<bool>>& m, int index, int balanceFinal) {

int offset =  m[0].size()/2 ;

for (int i = libro.size() - 1; i > 0; i--)
{
bool valorResta = m[i - 1][balanceFinal - libro[i] + offset];
bool valorSuma = m[i - 1][balanceFinal + libro[i]  + offset];
if (valorResta && valorSuma)
{
signos[i] = '?';
balanceFinal-=libro[i];
}

if (valorResta)
{
signos[i] = '+';
balanceFinal-=libro[i];
}

else
{
signos[i] = '-';
balanceFinal+=libro[i];
}
}

if(libro[0] > 0) {
signos[0] = '+';
} else
signos[0] = '-';
}

void afip(vector<int>& libro, vector<char>& signos, vector<vector<bool>>& m, int index, int balanceFinal) {

int offset =  m[0].size()/2;

m[0][offset + libro[0]] = true;
m[0][offset - libro[0]] = true;

for (int i = 1; i < libro.size(); i++)
{
for (int j = 0; j < m[0].size() ; j++)
{
bool valorIzquierda = false;
bool valorDerecha = false;
if (j - libro[i] >= 0)
{
valorIzquierda = m[i - 1][j - libro[i]];
}

if (j + libro[i] < offset * 2)
{
valorDerecha = m[i - 1][j + libro[i]];
}

m[i][j] = m[i][j] || valorDerecha || valorIzquierda ;
}
}

for(int i = 0; i < m.size(); i++) {
for(int j = 0; j < m[0].size(); j++) {
cout << m[i][j] << " ";
}
cout << endl;
}

reconstruir(libro, signos, m, index, balanceFinal);
}





int main() {

    int test_cases_number;
    int n;
    int balanceFinal;

    cin >> test_cases_number;

    for(int i = 0; i < test_cases_number; i++) {
        cin >> n;
        cin >> balanceFinal;
        balanceFinal = balanceFinal / 100;

        vector<int> libro(n);
        vector<char> signos(n);

        for (int i = 0; i < n; i++) {
            cin >> libro[i];
            libro[i] = libro[i] / 100;
        }

        int sizeMatriz = sumaElementos(libro);

        vector<vector<bool>> m(n, vector<bool>(2 * sizeMatriz + 1, false));

        afip(libro, signos, m, 0, balanceFinal);


        cout << endl;
        for (int i = 0; i < n; i++) {
            cout << signos[i];
        }


        cout << endl;
    }
    return 0;
}