#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

int count_letters(string s)
{
    int count = 0;
    for (int i = 0; i < strlen(s); i++)
    {
        if (isupper(s[i]) || islower(s[i]))
        {
            count++;
        }
    }

    return count;
}

int count_words(string s)
{
    // number of words = no of spaces + 1
    // adding 1 in advance
    int count = 1;

    for (int i = 0; i < strlen(s); i++)
    {
        if (s[i] == ' ')
        {
            count++;
        }
    }

    return count;
}

int count_sentences(string s)
{
    int count = 0;
    for (int i = 0; i < strlen(s); i++)
    {
        if (s[i] == '!' || s[i] == '?' || s[i] == '.')
        {
            count++;
        }
    }

    return count;
}

int main(void)
{
    float S, l, w, ind;
    string s = get_string("Text: ");
    w = count_words(s);
    l = (count_letters(s) / w) * 100;
    S = (count_sentences(s) / w) * 100;
    ind = 0.0588 * l - 0.296 * S - 15.8;

    int g = (int)round(ind);

    if (g <= 1)
    {
        printf("Before Grade 1\n");
    }
    else if (g >= 16)
    {
        printf("Grade 16+\n");
    }
    else
    {
        printf("Grade %i\n", (int)round(ind));
    }
}