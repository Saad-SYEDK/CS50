#include <cs50.h>
#include <stdio.h>

int checkSum(long int s)
{
    long int a = s;
    int rem, sum = 0;
    while (a != 0)
    {
        a = a / 10;
        rem = (a % 10) * 2;
        a = a / 10;
        if (rem > 9)
        {
            while (rem != 0)
            {
                sum += rem % 10;
                rem = rem / 10;
            }
        }
        else
        {
            sum += rem;
        }
    }
    long int b = s;
    int rem2, sum2 = sum;
    while (b != 0)
    {
        rem2 = b % 10;
        b /= 10;
        b /= 10;

        sum2 += rem2;
    }

    if (sum2 % 10 == 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

int cardName(long int a)
{
    long int n = a;
    int count = 0;

    while (n != 0)
    {
        n /= 10;
        count++;
    }

    n = a;

    // for AMEX
    if (count == 15)
    {
        for (int i = 0; i < 13; i++)
        {
            n /= 10;
        }
        if (n == 34 || n == 37)
        {
            return 1;
        }
    }

    // for MASTER or VISA
    if (count == 16)
    {
        for (int i = 0; i < 14; i++)
        {
            n /= 10;
        }
        if (n == 51 || n == 52 || n == 53 || n == 54 || n == 55)
        {
            return 2;
        }
        else
        {
            n /= 10;
            if (n == 4)
            {
                return 3;
            }
        }
    }

    // for visa
    if (count == 13)
    {
        for (int i = 0; i < 12; i++)
        {
            n /= 10;
        }

        if (n == 4)
        {
            return 3;
        }
    }

    return 0;
}

int main(void)
{
    long int cNo;
    cNo = get_long("Number: ");

    int a = checkSum(cNo);
    int b = cardName(cNo);

    //checksum valid
    if (a == 1)
    {
        if (b == 1)
        {
            printf("AMEX\n");
        }
        else if (b == 2)
        {
            printf("MASTERCARD\n");
        }
        else if (b == 3)
        {
            printf("VISA\n");
        }
        else
        {
            printf("INVALID\n");
        }
    }
    else if (a == 0) //checksum invalid
    {
        printf("INVALID\n");
    }
}