#ifndef STD_LIB_ROTATE_HEADER
#define STD_LIB_ROTATE_HEADER

#include <ctype.h>
#include <limits.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
    ROTATE STD LIBRARY
    section[0]: stdio
    section[1]: string
    section[2]: stdlib
*/

/* std typedefs */

/*
    section[0]: stdio
*/

void print(const char *str);
// print and add a new line
void println(const char *str);

/*
    section[1]: string
*/

// convert to upper case
void to_upper_case(char *str);
// convert to lower case
void to_lower_case(char *str);
// [requires free][returns NULL too] add 2 strings into one string
char *concat_str(const char *str1, const char *str2);
// [requires free][returns NULL too] remove last char_count among of chars from a string
// returns a new string
char *remove_last_chars(const char *str, const size_t char_count);
// modified version of remove_last_chars without returning a new string
char *shorten_str(char *str, const size_t char_count);

/*
    section[2]: stdlib
*/

// free memory
void free_mem(void *ptr);

#endif /* end of STD_LIB_ROTATE_HEADER  */
