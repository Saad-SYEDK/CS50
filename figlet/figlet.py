from pyfiglet import Figlet
import sys

figlet = Figlet()
figlet.getFonts()

if len(sys.argv) == 1 or 3:
    if len(sys.argv) == 3:
        if sys.argv[1] == ("-f" or "--font"):
            f = sys.argv[2]
            figlet.setFont(font=f)
        else:
            sys.exit(1)
else:
    sys.exit(1)

s = input("Input: ")


print(figlet.renderText(s))
