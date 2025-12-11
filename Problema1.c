#include <stdio.h>

int main() {
    int peso, altura, imc;

    printf("Qual eh o seu peso (kg)? ");
    scanf("%d", &peso);

    printf("Qual eh a sua altura (em cm)? ");
    scanf("%d", &altura);

    imc = (peso * 10000) / (altura * altura);

    printf("\nSeu IMC eh: %d\n", imc);

    if (imc < 18) {
        printf("Classificacao: Abaixo do peso\n");
    } 
    else if (imc < 25) {
        printf("Classificacao: Normal\n");
    } 
    else {
        printf("Classificacao: Sobrepeso\n");
    }

    return 0;
}
