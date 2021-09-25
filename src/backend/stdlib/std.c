#include "std.h"

//             $$\           $$\ $$\ $$\ $$\
//             $$ |          $$ |$$ |\__|$$ |
//  $$$$$$$\ $$$$$$\    $$$$$$$ |$$ |$$\ $$$$$$$\
// $$  _____|\_$$  _|  $$  __$$ |$$ |$$ |$$  __$$\
// \$$$$$$\    $$ |    $$ /  $$ |$$ |$$ |$$ |  $$ |
//  \____$$\   $$ |$$\ $$ |  $$ |$$ |$$ |$$ |  $$ |
// $$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |$$$$$$$  |
// \_______/    \____/  \_______|\__|\__|\_______/
/*
    ROTATE STD LIBRARY
    section[0]: stdio
    section[1]: string
*/

/*
    section[0] (stdio)
*/
// print without newline
void print(const char *str)
{
    printf("%s", str);
}

// print with newline
void println(const char *str)
{
    puts(str);
}

/*
    section[1] (string)
*/

// convert string to upper case [O(n)]
char *to_upper_case(char *str)
{
    for (size_t i = 0; str[i] != '\0'; i++)
    {
        str[i] = toupper(str[i]);
    }
    return str;
}

// convert to lower case [O(n)]
char *to_lower_case(char *str)
{
    for (size_t i = 0; str[i] != '\0'; i++)
    {
        str[i] = tolower(str[i]);
    }
    return str;
}

// [requires free][returns NULL too] add 2 strings into one string
char *concat_str(const char *str1, const char *str2)
{
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    char *res = malloc(len1 + len2 + 1);
    if (!res) return NULL;
    memcpy(res, str1, len1);
    memcpy(res + len1, str2, len2);
    res[len1 + len2] = '\0';
    return res;
}

// [requires free][returns NULL too] remove last char_count among of chars from a string
// returns a new string
char *remove_last_chars(const char *str, const size_t char_count)
{
    size_t len = strlen(str);
    char *res = malloc(len + 1);
    if (!res) return NULL;
    memcpy(res, str, len - char_count);
    res[len - char_count] = '\0';
    return res;
}

// modified version of remove_last_chars without
// returning a new string
char *shorten_str(char *str, const size_t char_count)
{
    size_t len = strlen(str);
    size_t new_len = char_count > len ? 0 : len - char_count;
    str[new_len] = '\0';
    return str + new_len;
}
