#include <stdio.h>

int gcd (int u, int v) { 
    if (v == 0) return u;
    else return gcd(v, u - u / v * v);
}

int gcdd(int u[]){
    return gcd(u[0], u[1]);
}

int main(){
    int x; int y; int temp;
    int a[2];
    x = 72; y = 18;
    if (x < y) {
        temp = x;
        x = y;
        y = temp;
    }
    int xy = (gcd(x, y) + gcd(a[0] = gcd(x, y), a[1] = y));
    int yx = gcdd(a);
    printf("%d %d\n", xy, yx);
    return 0;
}
