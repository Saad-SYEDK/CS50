from cs50 import get_string


def main():
    s = get_string("Text: ")

    w = count_words(s)
    L = (count_letters(s) / w) * 100
    S = (count_sentences(s) / w) * 100

    ind = 0.0588 * L - 0.296 * S - 15.8
    grade = round(ind)

    if grade > 16:
        print("Grade 16+")
    elif grade < 1:
        print("Before Grade 1")
    else:
        print(f"Grade {grade}")


def count_letters(s):
    count = 0
    for i in s:
        if i.isalpha():
            count += 1
    return count


def count_words(s):
    count = 1
    for i in s:
        if i == " ":
            count += 1
    return count


def count_sentences(s):
    count = 0
    for i in s:
        if i == "." or i == "!" or i == "?":
            count += 1
    return count


if __name__ == "__main__":
    main()
