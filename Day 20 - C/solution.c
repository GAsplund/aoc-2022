#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define BUFLEN 63
#define DECRYPT_KEY 811589153

inline long long positiveModulo(long long i, long long n) {
    return (i % n + n) % n;
}

inline int sign(int x) {
    return (x > 0) - (x < 0);
}

int linearSearch(int val, int* arr, int len) {
    int index = -1;
    for (int i = 0; i < len; i++) {
        if (arr[i] == val) {
            index = i;
            break;
        }
    }
    return index;
}

int linearSearchDict(long long val, int* ind, long long* dict, int len) {
    int index = -1;
    for (int i = 0; i < len; i++) {
        int index = ind[i];
        if (dict[index] == val) {
            return i;
        }
    }
    return index;
}

void moveVal(int from, int to, int* arr) {
    int direction = (from < to) ? 1 : -1;

    int element = arr[from];
    int currentIndex = from;
    while (currentIndex != to) {
        arr[currentIndex] = arr[currentIndex + direction];
        currentIndex += direction;
    }
    arr[to] = element;
}


void mix(int length, int* indices, long long* numbers) {
    int pos = 0;
    for (size_t i = 0; i < length; i++)
    {
        pos = linearSearch(i, indices, length);
        int newPos = positiveModulo(pos + numbers[i], length-1);
        moveVal(pos, newPos, indices);
    }
}

int main(void)
{
    FILE* filePointer;
    char buffer[BUFLEN];

    // Read puzzle input file
    filePointer = fopen("input.txt", "r");

    int pos = 0;
    while(fgets(buffer, BUFLEN, filePointer)) pos++;

    const int length = pos;
    long long* numbers = malloc(pos*sizeof(long long));
    int* indices = malloc(pos*sizeof(int));
    long long* numbersDec = malloc(pos*sizeof(long long));
    int* indicesDec = malloc(pos*sizeof(int));

    // Populate arrays
    pos = 0;
    rewind(filePointer);
    while(fgets(buffer, BUFLEN, filePointer))
    {
        numbers[pos] = atoll(buffer);
        indices[pos] = pos;
        numbersDec[pos] = atoll(buffer) * DECRYPT_KEY;
        indicesDec[pos] = pos;
        pos++;
    }
    fclose(filePointer);

    mix(length, indices, numbers);
    for (size_t i = 0; i < 10; i++)
    {
        mix(length, indicesDec, numbersDec);
    }

    int zeroPos = linearSearchDict(0, indices, numbers, length);
    int oneK = numbers[indices[(zeroPos + 1000) % length]];
    int twoK = numbers[indices[(zeroPos + 2000) % length]];
    int threeK = numbers[indices[(zeroPos + 3000) % length]];
    long long finalSum = oneK + twoK + threeK;
    printf("Solution 1: %lld\n", finalSum);

    long long zeroPosDec = linearSearchDict(0, indicesDec, numbersDec, length);
    long long oneKDec = numbersDec[indicesDec[(zeroPosDec + 1000) % length]];
    long long twoKDec = numbersDec[indicesDec[(zeroPosDec + 2000) % length]];
    long long threeKDec = numbersDec[indicesDec[(zeroPosDec + 3000) % length]];
    long long finalSumDec = oneKDec + twoKDec + threeKDec;
    printf("Solution 2: %lld\n", finalSumDec);

}
