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
# getListenedTo takes in the parameters user_id to get the user_id
#    and then calls and returns a JSON of all the songs a specific user has listened to
@app.route("/getListened")
def getListened():
    user_id = request.args.get('user_id')
    return get_listened_songs(user_id)


# addListenedTo calls the method add_listened_to from the dp_api file
# addListenedTo takes in the parameters user_id and song_id
#    and then creates a listened to relationship in the database
#    where user listened to song
@app.route("/addListenedTo")
def addListenedTo():
    user_id = request.args.get('user_id')
    song_id = request.args.get('song_id')
    return add_listened_to(user_id, song_id)

@app.route("/getfollowers")
def getFollowers():
    user_id = request.args.get('user_id')
    return get_followers(user_id)

@app.route("/getfollowing")
def getfollowing():
    user_id = request.args.get('user_id')
    return get_following(user_id)

# follows calls the method add_follows from the db_api file
# follows takes in two parameters: user_id1 and user_id2
# and then creates a relationship in the database where
# user_id1 follows user_id2
@app.route("/follows")
def follows():
    user_id1 = request.args.get('user_id1')
    user_id2 = request.args.get('user_id2')
    return add_follows(user_id1, user_id2)

#unfollows calls the method delete_follows from db_api
#deletes a relationship in the database where
#user_id1 unfollows user_id2
@app.route("/unfollows")
def unfollows():
    user_id1 = request.args.get('user_id1')
	user_id2 = requests.args.get('user_id2')
	return delete_follows(user_id1, user_id2)

# login method logs in a user by checking the database if the user exists
# and if the password is correct
# takes in the parameters username and password
@app.route("/loginuser")
def loginuser():
    username = request.args.get('username')
    password = request.args.get('password')
    output = login(username, password)
    if output[0] is "True":
        #create session so user is logged in
        session['logged_in'] = True
    else:
        flash('wrong password!')

# logs a user out by ending the session for CURRENT user
@app.route("/logout")
def logout():
    session['logged_in'] = False

# returns a list of liked songs for the specified user
@app.route("/likedsongs")
def getLikedSongs():
    user_id = request.args.get('user_id')
    return get_likes(user_id)

# returns a list of disliked songs for the specified user    
@app.route("/dislikedsongs") 
def getDislikedSongs():
    user_id = request.args.get('user_id')
    return get_dislikes(user_id)
        
    

    
