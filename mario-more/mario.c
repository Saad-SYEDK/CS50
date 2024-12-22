
#include <cs50.h>
#include <stdio.h>

int main(void)
{
    int n;
    do
    {
        n = get_int("Height: ");
    }
    while (n < 1 || n > 8);
    //for rows
    for (int i = 0; i < n; i++)
    {
        //for spaces before #
        for (int j = 0; j < n - (i + 1); j++)
        {
            printf(" ");
        }
        //for #
        for (int j = 0; j < 1 + i; j++)
        {
            printf("#");
        }
        //for 2 spaces
        printf("  ");
        //for # after 2 spaces
        for (int j = 0; j < i + 1; j++)
        {
            printf("#");
        }

        printf("\n");
    }
}
