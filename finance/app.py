import os

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from werkzeug.security import check_password_hash, generate_password_hash

from helpers import apology, login_required, lookup, usd

# Configure application
app = Flask(__name__)

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    user_holdings = db.execute("SELECT * FROM holdings WHERE user_id = ?", session['user_id'])
    user_table = db.execute("SELECT * FROM users WHERE id = ?", session['user_id'])
    sum_total_value = 0
    for holding in user_holdings:
        price = lookup(holding['share_symbol'])['price']
        holding['current_price'] = usd(price)
        holding['average_price'] = usd(holding['average_price'])
        holding['total_value'] = price * holding['quantity']
        sum_total_value += holding['total_value']
        sum_total_value = round(sum_total_value, 2)
        user_table[0]["cash"] = round(user_table[0]["cash"], 2)
    return render_template("index.html", user_holdings=user_holdings, user_table=user_table, sum=sum_total_value, usd=usd)


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""
    if request.method == "POST":
        symbol = request.form.get("symbol")
        if not symbol:
            return apology("Enter symbol")
        data = lookup(symbol)
        if data == None:
            return apology("Wrong Symbol")

        try:
            buy_quantity = float(request.form.get("shares"))
        except ValueError:
            return apology("Caught - value error")

        if buy_quantity % 1 != 0:
            return apology("Invalid Quantilty - fraction")
        if buy_quantity < 1:
            return apology("Invalid Quantity - less than 1")

        share_price = float(data["price"])
        total_price = share_price * buy_quantity
        user_data = db.execute("SELECT * FROM users WHERE id = ?", session["user_id"])
        available_balance = user_data[0]['cash']
        if total_price > available_balance:
            return apology("Insufficiant Funds")
        else:
            average_price = total_price / buy_quantity
            db.execute("INSERT INTO transactions (user_id, share_symbol, transaction_type, quantity, price_per_share) VALUES(?,?,?,?,?)",
                       session["user_id"], data["symbol"], 'BUY', buy_quantity, share_price)
            db.execute("INSERT INTO holdings(user_id, share_symbol, quantity, average_price) VALUES (?, ?, ?, ?) ON CONFLICT(user_id, share_symbol) DO UPDATE SET quantity = quantity + EXCLUDED.quantity, average_price = ((average_price * quantity) + (EXCLUDED.average_price * EXCLUDED.quantity)) / (quantity + EXCLUDED.quantity)",
                       session["user_id"], symbol, buy_quantity, average_price)
            db.execute("UPDATE users SET cash = cash - ? WHERE id = ?",
                       total_price, session['user_id'])
            return redirect("/")

    return render_template("buy.html")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    user_transactions = db.execute(
        "SELECT * FROM transactions WHERE user_id = ?", session['user_id'])
    return render_template("history.html", user_transactions=user_transactions, usd=usd)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":
        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute(
            "SELECT * FROM users WHERE username = ?", request.form.get("username")
        )

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(
            rows[0]["hash"], request.form.get("password")
        ):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/changePassword", methods=["GET", "POST"])
@login_required
def change_password():
    if request.method == "POST":
        if not request.form.get("current_password"):
            return apology("Enter current password")
        if not request.form.get("new_password"):
            return apology("Enter new password")
        if not request.form.get("new_password_repeat"):
            return apology("Re-enter password")
        if request.form.get("new_password") != request.form.get("new_password_repeat"):
            return apology("passwords do not match")

        user = db.execute("SELECT * FROM users WHERE id = ?", session['user_id'])
        if not check_password_hash(user[0]['hash'], request.form.get("current_password")):
            return apology("Incorrect Password")
        else:
            db.execute("UPDATE users SET hash = ? WHERE id = ?", generate_password_hash(
                request.form.get("new_password")), session['user_id'])
            return redirect("/")
    return render_template("changePassword.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():

    if request.method == "POST":
        symbol = request.form.get('symbol')
        if not symbol:
            return apology("Enter Symbol")
        data = lookup(symbol)
        if data == None:
            return apology("Wrong Symbol")
        price = usd(data['price'])
        return render_template("quoted.html", data=data, price=price)

    return render_template("quote.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        password_again = request.form.get("confirmation")

        if not username:
            return apology("Enter Username")
        if not password:
            return apology("Enter Password")
        if not password_again:
            return apology("Re-enter password")
        if password != password_again:
            return apology("Passwords do not match")

        try:
            db.execute("INSERT INTO users(username, hash) VALUES(?, ?)",
                       username, generate_password_hash(password))
        except ValueError:
            return apology("User Already Exists")
        return redirect("/")
    return render_template("register.html")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""
    user_holdings = db.execute("SELECT * FROM holdings WHERE user_id = ?", session['user_id'])
    if request.method == "POST":
        # Ensure user has selected any share
        user_selected_share = request.form.get("symbol")
        if not user_selected_share:
            return apology("Select Share")

        # Check if user has selected valid symbol
        flag = False
        for holding in user_holdings:
            if user_selected_share == holding['share_symbol']:
                flag = True
                selected_dict = holding
        if not flag:
            return apology("Select valid share")

        # Check if user has the quantity
        selected_quantity = int(request.form.get('shares'))
        available_quantity = selected_dict['quantity']
        if selected_quantity > available_quantity:
            return apology("You do not have enough quantity")
        remaining_shares = available_quantity - selected_quantity
        # All okay, update database -> 1)Insert tarnsaction, 2)update/remove holdings, 3)Add cash
        sell_price_per_share = lookup(selected_dict['share_symbol'])["price"]
        cash_to_add = sell_price_per_share * selected_quantity
        # Update holdings
        if remaining_shares > 0:
            db.execute("UPDATE holdings SET quantity = ? WHERE user_id = ? AND share_symbol = ?",
                       remaining_shares, session['user_id'], user_selected_share)
        else:
            db.execute("DELETE FROM holdings WHERE user_id = ? AND share_symbol = ?",
                       session['user_id'], user_selected_share)
        # Add transaction
        db.execute("INSERT INTO transactions(user_id, share_symbol, transaction_type, quantity, price_per_share) VALUES(?, ?, ?, ?, ?)",
                   session['user_id'], user_selected_share, "SELL", selected_quantity, sell_price_per_share)
        # add cash
        db.execute("UPDATE users SET cash = cash + ? WHERE id = ?", cash_to_add, session['user_id'])
        return redirect('/')

    return render_template("sell.html", user_holdings=user_holdings)
