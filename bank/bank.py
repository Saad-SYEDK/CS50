w = input("Greeting: ").strip().lower()
if w.startswith("hello"):
    print("$0")
elif w.startswith("h"):
    print("$20")
else:
    print("$100")