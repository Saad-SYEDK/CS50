import os

from cs50 import SQL
from flask import Flask, flash, jsonify, redirect, render_template, request, session

# Configure application
app = Flask(__name__)

# Ensure templates are auto-reloaded
app.config["TEMPLATES_AUTO_RELOAD"] = True

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///birthdays.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/", methods=["GET", "POST"])
def index():

    if request.method == "POST":
        # getting data from the form
        name = request.form.get("name")
        month = request.form.get("month")
        day = request.form.get("day")

        # validating the data

        # validate name
        if not name:
            return redirect("/")

        # validate month
        if not month:
            return redirect("/")

        #if month is not a numeric data type
        try:
            month =  int(month)
        except ValueError:
             return redirect("/")
        #if month is out of range
        if month < 1 or month > 12:
             return redirect("/")

        # validate day
        if not day:
            return redirect("/")

        #if day is not a numeric data type
        try:
            day =  int(day)
        except ValueError:
             return redirect("/")
        #if day is out of range
        if day < 1 or day > 31:
             return redirect("/")

        # inserting into the datbase
        db.execute("INSERT INTO birthdays (name, month, day) values (?, ?, ?)", name, month, day)
        return redirect("/")

    else:

        birthdays = db.execute("SELECT * FROM birthdays")
        return render_template("index.html", birthdays=birthdays)


