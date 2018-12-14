from flask import request, session, escape
import requests, array, json, datetime
from db_api import *
from proto import *
from cryptography.fernet import Fernet

# Set the secret key to some random bytes. Keep this really secret!
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'
app.config.update(
    SESSION_COOKIE_PATH = '/'
)

#getting private key
file = open('key.pem','r')
read_data = file.read()
key = read_data
f = Fernet(key)

# endpoint to test connectivity to the server and to the database
@app.route("/database")
def user_info():
    return get_user_by_id(1)

# getListenedTo calls the method get_listened_songs from the dp_api file
# getListenedTo takes in the parameters user_id to get the user_id
#    and then calls and returns a JSON of all the songs a specific user has listened to
# parameter: user_id
@app.route("/getListened")
def getListened():
    user_id = request.args.get('user_id')
    return get_listened_songs(user_id)


# addListenedTo calls the method add_listened_to from the dp_api file
# addListenedTo takes in the parameters user_id and song_id
#    and then creates a listened to relationship in the database
#    where user listened to song
# parameter: user_id, song_id
@app.route("/addListenedTo")
def addListenedTo():
    user_id = request.args.get('user_id')
    song_id = request.args.get('song_id')
    last_listened_to = datetime.datetime.strptime('10 Dec 2018, 19:38', '%d %b %Y, %H:%M')
    return add_listened_to(user_id, song_id, last_listened_to)

# getFollowers calls the method get_followers from the db_api file
# getFollowers takes in the user_id we are requesting and will return a list
# of all users that this specfic user is being followed by
# parameter: user_id
@app.route("/getfollowers")
def getFollowers():
    user_id = request.args.get('user_id')
    return get_followers(user_id)

# getfollowing calls the method get_following from the db_api file
# takes in the user_id we are requesting and returns a list of all users
# this specific user_id is following
# parameter: user_id
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
    #current_user = session.items()
    #print(current_user,' is current logged in user')
    # check that current user is equal to user_id1
    user_id1 = request.args.get('user_id1')
    user_id2 = request.args.get('user_id2')
    session_key = request.args.get('session_key')
    session_bytes = session_key.encode()
    session_string = f.decrypt(session_bytes).decode()
    session_key = session_string.split("__")[0]
    print('User ID 1: ' + user_id1 + ' User ID 2: ' + user_id2 + ' Session Key: ' + session_key)
    #user = db.session.query(User).get(user_id1)
    #user_id1_username = user.username
    #print(user_id1_username)
    #print('Session: ' + str(current_user))
#    if session_key.lower() in session:

    # Session key shows WHO WE ARE TALKING TO, so use session key to find user in database
    user = db.session.query(User).filter_by(username=session_key).first()
    print('The user_id when we query the database using the session key: ' + str(user.user_id))
    print('SUCCESS: ' + str(user.user_id) + ' follows ' + user_id2)
    output = {'output': add_follows(user.user_id, user_id2), 'session_key': session_key}
    return json.dumps(output)

#unfollows calls the method delete_follows from db_api
#deletes a relationship in the database where
#user_id1 unfollows user_id2
@app.route("/unfollows")
def unfollows():
    #current_user = session.items()
    #print(current_user,' is current logged in user')
    # check that current user is equal to user_id1
    user_id1 = request.args.get('user_id1')
    user_id2 = request.args.get('user_id2')
    session_key = request.args.get('session_key')
    session_bytes = session_key.encode()
    session_string = f.decrypt(session_bytes).decode()
    session_key = session_string.split("__")[0]
    print('User ID 1: ' + user_id1 + ' User ID 2: ' + user_id2 + ' Session Key: ' + session_key)
    #user = db.session.query(User).get(user_id1)
    #user_id1_username = user.username
    #print(user_id1_username)
    #print(current_user)
    #print(session_key + ' is session key')
    #print('Session: ' + str(session.items()))
    #if session_key.lower() in session:

    # Session key shows WHO WE ARE TALKING TO, so use session key to find user in database
    user = db.session.query(User).filter_by(username=session_key).first()
    print('The user_id when we query the database using the session key: ' + str(user.user_id))

    print('SUCCESS: ' + str(user.user_id) + ' unfollowed ' + user_id2)
    output = {'output': delete_follows(user.user_id, user_id2), 'session_key': session_key}
    return json.dumps(output)
    #return delete_follows(user_id1, user_id2)
    #else:
    #    print('FAILURE')
    #    return "Error: Login failure. Please login to complete task. User is []"

#   if current_user is []:
#       #no one is logged in user
#       print('in first check: ')
#       print(current_user)
#       return "Error: Login failure. Please login to complete task. User is []"
#   else:
#       #session.items() is not empty
#       curr_user_split = str(current_user).split(',')
#       print('in else current user split:')
#       print(curr_user_split)
#       curr_user_split_username = curr_user_split[1]
#       if user_id1_username.lower() in curr_user_split[1]:
#           return delete_follows(user_id1, user_id2)
#       else:
#           return "Error: Login failure. Please login to complete task."

# login method logs in a user by checking the database if the user exists
# and if the password is correct
# takes in the parameters username and password
@app.route('/loginuser')
def loginuser():
    username = request.args.get('username')
    password = request.args.get('password')
    print('Username: ' + username + ' Password: ' + password)
    output = login(username, password)
    if output[0] is True:
        print(output)
        loaded_json = json.loads(output[2])
        print('user_id ', loaded_json['user_id'])

        # updates songs from last_fm that a user has listened to (whatever songs they have "l
oved" on last_fm)
        # takes from the file populate_db.py method adding_info()
        # user is their lastfm username
        parameter = {'method': 'user.getrecenttracks', 'user': loaded_json['lastfm_name'], 'a
pi_key': '8ed3258b37f9fb17b765bb7589e06c6f','format': 'json' }
        response = requests.get('http://ws.audioscrobbler.com/2.0/?', params=parameter)
        data = response.json()
        for i in range(len(data['recenttracks']['track'])):
            song_name = data['recenttracks']['track'][i]['name']
            song_url_raw = data['recenttracks']['track'][i]['url']
            song_url = song_url_raw[:400] if len(song_url_raw) > 400 else song_url_raw
            # add_song checks database if song already exists
            song_id = add_song(song_name, song_url)
            artist_name = data['recenttracks']['track'][i]['artist']['#text']
            artist_url = data['recenttracks']['track'][i]['url']
            artist_id = add_artist(artist_name, artist_url)
            add_song_by(song_id, artist_id)
            time_last_listened = str(data['recenttracks']['track'][i]['date']['#text'])
            last_listened_to = datetime.datetime.strptime(time_last_listened, '%d %b %Y, %H:%
M')
            # currently the time is in UTC but we update time by - 5 to change to EST time zo
ne
            last_listened_to = last_listened_to + datetime.timedelta(hours=-5)
            add_listened_to(loaded_json['user_id'], song_id, last_listened_to)
        real_output = json.loads(output[2])
        # make a session key that is given to client side
        #encrypts session key and appends with current date and time to make it unique
        now = str(datetime.datetime.now())
        session_string = username + "__" + now
        b_session = session_string.encode()
        encrypted_data = f.encrypt(b_session)
        real_output['session_key'] = encrypted_data
        return json.dumps(real_output)
    else:
        print('FAIL: wrong password')
        return json.dumps({"Failure": 'wrong password!'})

# logout logs a user out by ending the session for CURRENT user
# parameters: username
@app.route("/logout")
def logout():
    username = request.args.get('username')
    session_key = request.args.get('session_key')
    session_bytes = session_key.encode()
    session_string = f.decrypt(session_bytes).decode()
    session_key = session_string.split("__")[0]
    print('Username: ' + username + ' Session key: '  + session_key)

    output = username + ' logged out.'
    print(output)
    return output

#getfeed method gets the recently listened to songs and like/dislike songs either of one
#singular user or the users a user is following
@app.route("/getfeed")
def getfeed():
    user_id = request.args.get('user_id')
    user_only = request.args.get('user_only')
    session_key = request.args.get('session_key')

    # Check what the client has assigned to user only and assign the appropriate boolean value
    if('true' in user_only):
        user_only = True
    else:
        user_only = False

    return get_feed(user_id, user_only) 
                     
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

# likesong calls the method dislike() from the db_api file
# likesong will Like or unlike a song, returning either Success or an error message.
# parameters: user_id, song_id
@app.route("/like")
def likesong():
    user_id = request.args.get('user_id')
    song_id = request.args.get('song_id')
    session_key = request.args.get('session_key')
    session_bytes = session_key.encode()
    session_string = f.decrypt(session_bytes).decode()
    session_key = session_string.split("__")[0]
    print('User_id: ' + user_id + ' Song_ID: ' + song_id + ' Session_key: ' + session_key)

    # Session key shows WHO WE ARE TALKING TO, so use session key to find user in database
    user = db.session.query(User).filter_by(username=session_key).first()
    print('The user_id when we query the database using the session key: ' + str(user.user_id))
    output = {'output': like(user.user_id, song_id), 'session_key': session_key}
    return json.dumps(output)

# dislikesong calls the method dislike() from the db_api file
# dislikesong will dislike or undislikes a song, returning either Success or an error message.
# parameters: user_id, song_id
@app.route("/dislike")
def dislikesong():
    user_id = request.args.get('user_id')
    song_id = request.args.get('song_id')
    session_key = request.args.get('session_key')
    session_bytes = session_key.encode()
    session_string = f.decrypt(session_bytes).decode()
    session_key = session_string.split("__")[0]
    print('User ID: ' + user_id + ' Song ID: ' + song_id + ' Session Key: ' + session_key)
    # Session key shows WHO WE ARE TALKING TO, so use session key to find user in database
    user = db.session.query(User).filter_by(username=session_key).first()
    print('The user_id when we query the database using the session key: ' + str(user.user_id
))
    print(str(user.user_id) + ' disliked song_id ' + song_id)
    output = {'output': dislike(user.user_id, song_id), 'session_key':session_key}
    return json.dumps(output)


# recommendSong will recommend a user a song using make_recommendations()
# parameter: user_id
@app.route("/recommend")
def recommendsong():
    user_id = request.args.get('user_id')
    session_key = request.args.get('session_key')
    return make_recommendations(user_id)

#endpoint for recommending potential user to follow for a user
@app.route("/recommendusers")
def recommenduser():
    user_id = request.args.get('user_id')
    session_key = request.args.get('session_key')
    return db_recommendusers(user_id)