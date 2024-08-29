#include <stdio.h>

int sum_array(int *arr, int size) {
    int result;

        asm(
            "mov %2, %%ecx\n\t"
            "mov $0, %%eax\n\t"
            "loop:\n\t"

            
            "cmp $4, %%ecx\n\t"
            "jl rem\n\t"

            "mov (%1), %%ebx\n\t"
            "add %%ebx, %%eax\n\t"
            "mov 4(%1), %%ebx\n\t"
            "add %%ebx, %%eax\n\t"
            "mov 8(%1), %%ebx\n\t"
            "add %%ebx, %%eax\n\t"
            "mov 12(%1), %%ebx\n\t"
            "add %%ebx, %%eax\n\t"

            "lea 16(%1), %1\n\t"
            "sub $4, %%ecx\n\t"
            
            "jmp loop\n\t"

            "rem:\n\t"

            "test %%ecx, %%ecx\n\t"
            "jz exit\n\t"

            "mov (%1), %%ebx\n\t"
            "add %%ebx, %%eax\n\t"
            "add $4, %1\n\t"
            "sub $1, %%ecx\n\t"
            "jg rem\n\t"

            "exit:\n\t"
            "mov %%eax, %0"


            : "=r" (result)
            : "r" (arr), "r" (size)
            : "eax", "ecx", "ebx", "memory"
        );


    return result;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64};
    int size = sizeof(arr) / sizeof(arr[0]);
    int result = sum_array(arr, size);

    printf("Result of multiplication: %d\n", result);
    return 0;
}