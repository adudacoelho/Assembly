#include <stdio.h>
#include <stdlib.h>

int main(){
    int n;

    printf("DESCUBRA SE NUMERO EH PRIMO\n");

    printf("\nInsira um numero n>=2:");
    scanf("%d", &n);

    if (n < 2) {
        printf("\nNumero invalido. Por favor, insira um numero maior ou igual a 2.\n");
        return 1;
    }
    for (int i = 2; i <= n / 2; i++) {
        if (n % i == 0) {
            printf("\nO numero %d nao eh primo.\n", n);
            return 0;
        }
    }
    printf("\nO numero %d eh primo.\n", n);
    return 0;
}
