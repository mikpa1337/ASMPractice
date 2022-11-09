#define _CRT_SECURE_NO_WARNINGS // oh no

#include <iostream>
#include <cstdio>   // yes, i know, but i dont know whether printf is included with iostream or not (MSVC magic?). and shouldn't i be using std::printf? hmm..

// only for speedtesting
//#include <ctime>
//#define LEN 1001767
//#define REPS 100


// also, this file is mostly not C++ (or if it is, this is definitely the wrong way to write C++)

typedef unsigned char BYTE;

// TODO: Homebrew ASM functions
// Data types dont matter in ASM. Its all just data
extern "C" {
    uint32_t	asm_strlen(const char* str);							// IMPLEMENTED
    char*       asm_strchr(const char* str, int ch);					// IMPLEMENTED
    void*       asm_memcpy(void* dst, const void* src, uint32_t count);	// IMPLEMENTED
    void*       asm_memset(void* dst, int ch, uint32_t count);			// IMPLEMENTED
    int32_t		asm_strcmp(const char* arg, const char* arg2);			// IMPLEMENTED
    char*       asm_strset(char* str, int ch);							// IMPLEMENTED

    int			asm_testfunc(const char* ptr);                          // sandbox
    int32_t		asm_strcmp2(const char* arg, const char* arg2);			// IMPLEMENTED
    char*       asm_strncat(char* dest, const char* src, size_t count);	// IMPLEMENTED
}
// test struct (packed, not aligned)
#pragma pack(1)
typedef struct test_t {
    BYTE    randomData[32];     // 32
    int     someNumber;         // 4
    char*   somePointer;        // 4 or 8
}test_t;    // 44 bytes (x64) or 40 bytes (x86)



void printBits(int carry, unsigned long long p, int bitCount) {
    std::cout << "C: " << carry << " ";
    for (int j = bitCount - 1; j >= 0; j--) {
        std::cout << ((p >> j) & 1);
    }
    std::cout << std::endl;
}

// just need to demonstrate (show), that the data in struct is changed via memset/memcpy
void printStruct(test_t* data_t) {
    printf("-------------\n");
    printf("randomData: ");
    for (size_t i = 0; i < sizeof(data_t->randomData); i++) {
        printf("%x ", data_t->randomData[i]);
        /*if (i % 32 == 0) {
            printf("\n");
        }*/
    }
    printf("\nsomeNumber:   %d\n", data_t->someNumber);
    printf("somePointer:  %p\n", data_t->somePointer);
    printf("-------------\n");
}

void TestAllAsmFunctions() {
    test_t srcStruct = { 0 }; // C++ feature, initializing a struct to zero
    test_t dstStruct;

    char str1[] = "(1)This string will be edited";
    char str2[] = "(2)This string will be edited";


    // str functions
//    printf("asm_strlen: %d\n", asm_strlen("this is a very large string"));
    printf("asm_strlen: %d\n", asm_strlen("test"));
    printf("strlen:	    %d\n", (uint32_t)strlen("test"));    // oops

    printf("asm_strchr (correct):  e @ '%s'\n", asm_strchr("test", 'e'));
    printf("asm_strchr (wrong):    e @ '%s'\n", asm_strchr("test", 'z'));
    printf("strchr (correct):      e @ '%s'\n", strchr("test", 'e'));
    printf("strchr (wrong):        e @ '%s'\n", strchr("test", 'z'));


    printf("asm_strcmp (correct):   %d\n", asm_strcmp("test", "test"));
    printf("asm_strcmp (wrong):     %d\n", asm_strcmp("test", "we are not the same"));
    printf("strcmp (correct):       %d\n", strcmp("test", "test"));
    printf("strcmp (wrong):         %d\n", strcmp("test", "we are not the same"));

    // strset is not a standard function..
    // ..its also deprecated, have to use _strset
    printf("before asm_strset:      %s\n", str2);
    printf("before strset:          %s\n", str1);
    printf("asm_strset:             %s\n", asm_strset(str1, 'O'));
    printf("strset:                 %s\n", _strset(str2, 'X'));

    
    
    // mem functions (todo: refactor this later)
    printf("before fuckery\n");
    printStruct(&srcStruct);

    printf("asm_memset TO 0xEE\n");
    asm_memset(&srcStruct, 0xEE, sizeof(srcStruct));
    printStruct(&srcStruct);

    printf("asm_memcpy from dstStruct to srcStruct\n");
    asm_memcpy(&srcStruct, &dstStruct, sizeof(test_t));
    printStruct(&srcStruct);
    
    printf("memset to 0xDD\n");
    memset(&srcStruct, 0xDD, sizeof(test_t));
    printStruct(&srcStruct);
    
    printf("memcpy from dstStruct to srcStruct\n");
    memcpy(&srcStruct, &dstStruct, sizeof(test_t));
    printStruct(&srcStruct);

    printf("thanks and so long\n");
}
//void speedtesting(void);

int main() {
    // test zone
    //TestAllAsmFunctions();
    //const char *str = "Hello, i am a string";
    //const char *str2 = "wearenotthesame";
    /*
    printf("%d\n", asm_strlen("This is a string lol\n"));
    printf("%d\n", asm_testfunc("This is a string lol\n"));
    printf("%d\n", asm_strlen(str));
    printf("%d\n", asm_testfunc(str));
    printf("%d\n", asm_strlen(str2));
    printf("%d\n", asm_testfunc(str2));*/

    /*printf("asm_strcmp (correct): %d\n", asm_strcmp2("Hello", "Hello"));
    printf("asm_strcmp (wrong 1)  %d\n", asm_strcmp2("Hello", "Hcllo"));
    printf("asm_strcmp (wrong -1):%d\n", asm_strcmp2("test", "tset"));
    printf("strcmp (correct):     %d\n", strcmp("Hello", "Hello"));
    printf("strcmp (wrong 1):     %d\n", strcmp("Hello", "Hcllo"));
    printf("strcmp (wrong -1):    %d\n", strcmp("test", "tset"));*/

    char str[50] = "Hello ";
    char str2[50] = "World!";
    strncat(str, " Goodbye world!", 3);

    char str3[50] = "Hello ";
    char str4[50] = "World!";
    asm_strncat(str3, " Goodbye world!", 3);

    printf("Proper: %s\nASM: %s\n", str, str3);
    //speedtesting();
    return 0;
}

/*
void speedtesting(void) {
    char arr[LEN];
    int i = 0;
    clock_t start;
    char *cptr;
    
    memset(arr, '1', LEN-1);
    arr[LEN-5] = '2';
    start = clock();
    for (i = 0; i < REPS; i++) {
        cptr = strchr(arr, '2');
    }
    printf("strchr: %f seconds\n", (double)(clock() - start) / CLOCKS_PER_SEC);

    for (i = 0; i < REPS; i++) {
        cptr = asm_strchr(arr, '2');
    }
    printf("asm_strchr: %f seconds\n", (double)(clock() - start) / CLOCKS_PER_SEC);


    for (i = 0; i < REPS; i++) {
        memset(arr, 0xE, sizeof(arr));
    }
    printf("memset: %f seconds\n", (double)(clock() - start) / CLOCKS_PER_SEC);

    for (i = 0; i < REPS; i++) {
        asm_memset(arr, 0xA, sizeof(arr));
    }
    printf("asm_memset: %f seconds\n", (double)(clock() - start) / CLOCKS_PER_SEC);
}
*/