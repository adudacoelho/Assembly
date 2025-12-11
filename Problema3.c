#include <stdio.h>

int main() {
    int a1, an, n;
    int res;

    // imprime prompt e lê a1
    printf("Digite o primeiro termo (a1): ");
    scanf("%d", &a1);

    // imprime prompt e lê an
    printf("Digite o ultimo termo (an): ");
    scanf("%d", &an);

    // imprime prompt e lê n
    printf("Digite o numero de termos (n): ");
    scanf("%d", &n);

    // cálculo da soma da PA
    res = (a1 + an) * n / 2;

    // imprime resultado
    printf("Soma da PA = %d", res);

    return 0;
}
