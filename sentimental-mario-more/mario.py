while True:
    n = input("Height: ")
    if (n < "9" and n > "0"):
        break

n = int(n)
for i in range(1, n + 1):
    for j in range(n - i):
        print(" ", end="")
    for j in range(i):
        print("#", end="")
    print("  ", end="")
    for j in range(i):
        print("#", end="")
    print()
