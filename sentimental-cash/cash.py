from cs50 import get_float

while True:
    o = get_float("Change owed: ")
    if o > 0:
        break
o = o * 100
coins = 0

while (o >= 25) and (o != 0):
    o = o - 25
    coins += 1

while (o >= 10) and (o != 0):
    o = o - 10
    coins += 1

while (o >= 5) and (o != 0):
    o = o - 5
    coins += 1

while (o >= 1) and (o != 0):
    o = o - 1
    coins += 1

# if o % 25 == 0.0:
#     c = o/25
# elif o % 10 == 0.0:
#     c = o/10
# elif o % 5 == 0.0:
#     c = o/5
# else:
#     c = o/1

coins = int(coins)
print(coins)
