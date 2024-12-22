import sys

class Jar:
    def __init__(self, capacity=12):
        self.cap = capacity
        self.n = 0

    def __str__(self):
        return  ("🍪" * self.n)

    def deposit(self, n):
        self.n += n
        if self.n > self.cap:
            raise ValueError


    def withdraw(self, n):
        self.n -= n
        if self.n < 0:
           raise ValueError



    @property
    def capacity(self):
        return

    @property
    def size(self):
        return self.n


def main():
    jar = Jar()
    print(str(jar))
    jar.deposit(20)
    print(str(jar))
    jar.withdraw(1)
    print(str(jar))
    jar.withdraw(2)

if __name__ == "__main__":
    main()