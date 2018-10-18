import requests
from db_api import get_user_by_id

from __init__ import app

@app.route("/hello")
def hello():
    return "Hello World!"

@app.route("/test")
def last_fm():
    response = requests.get("http://ws.audioscrobbler.com/2.0/?method=user.getinfo&user=rj&api_key=8ed3258b37f9fb17b765bb7589e06c6f&format=json")

#   print(response.status_code)
    return response.text

@app.route("/database")
def user_info():
    return get_user_by_id(1)
