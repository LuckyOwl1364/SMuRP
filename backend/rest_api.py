from flask import request
import requests, array, json
from db_api import *

#imports app instance from database api
from db_api import app 

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

# getListenedTo calls the method get_listened_songs from the dp_api file
# getListenedTo takes in the parameters to get the user_id
#     and then calls and returns a JSON of all the songs a specific user has listened to
@app.route("/getListened")
def getListened():
    user_id = request.args.get('user_id')
    return get_listened_songs(user_id)
    

