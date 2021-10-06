#include "std.h"

// ROTATE STD LIBRARY
// section[0]: stdio
// section[1]: string

//
// section[0] (stdio)
//
void print(const char *str)
{
    printf("%s", (str ? str : "NULL"));
}

void println(const char *str)
{
    puts((str ? str : "NULL"));
}

//
// section[1] (string)
//
char *string(char *str)
{
    size_t len = strlen(str);
    char *res = malloc(len + 1);
    memcpy(res, str, len);
    res[len] = '\0';
    return res;
}

void to_upper_case(char *str)
{
    if (str) // str != NULL
        for (size_t i = 0; str[i] != '\0'; i++)
            str[i] = toupper(str[i]);
}

void to_lower_case(char *str)
{
    if (str) // str != NULL
        for (size_t i = 0; str[i] != '\0'; i++)
            str[i] = tolower(str[i]);
}

char *concat_str(const char *str1, const char *str2)
{
    if (str1 && str2) // str1 and str2 != NULL
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
    return NULL;
}

char *remove_last_chars(const char *str, const size_t char_count)
{
    if (str) // str != NULL
    {
        size_t len = strlen(str);
        char *res = malloc(len + 1);
        if (!res) return NULL;
        memcpy(res, str, len - char_count);
        res[len - char_count] = '\0';
        return res;
    }
    return NULL;
}

char *shorten_str(char *str, const size_t char_count)
{
    if (str) // str != NULL
    {
        size_t len = strlen(str);
        size_t new_len = char_count > len ? 0 : len - char_count;
        str[new_len] = '\0';
        return str + new_len;
    }
    return NULL;
}
