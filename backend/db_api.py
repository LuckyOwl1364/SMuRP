from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from passlib.hash import sha256_crypt
import sqlalchemy.exc
import datetime
import json
import random
from Crypto.Random import random
from Crypto.PublicKey import DSA
from Crypto.Hash import SHA

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = \
    'mysql://admin:Talwkatgigasbas2h@ec2-52-91-42-119.compute-1.amazonaws.com:3306/smurp'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

album_featuring = db.Table('album_featuring',
                           db.Column('artist_id', db.Integer, db.ForeignKey('artist.artist_id')),
                           db.Column('album_id', db.Integer, db.ForeignKey('album.album_id'))
                           )

song_by = db.Table('song_by',
                   db.Column('artist_id', db.Integer, db.ForeignKey('artist.artist_id')),
                   db.Column('song_id', db.Integer, db.ForeignKey('song.song_id'))
                   )

song_on = db.Table('song_on',
                   db.Column('album_id', db.Integer, db.ForeignKey('album.album_id')),
                   db.Column('song_id', db.Integer, db.ForeignKey('song.song_id')))


# Defines the Album table in the database
class Album(db.Model):
    __tablename__ = 'album'
    album_id = db.Column('album_id', db.Integer, primary_key=True)
    album_name = db.Column('album_name', db.Unicode)
    album_art = db.Column('album_art', db.Unicode)
    lastfm_url = db.Column('lastfm_url', db.Unicode)
    featuring = db.relationship('Artist', secondary=album_featuring,
                                backref=db.backref('featured_on', lazy='dynamic'))

    def __init__(self, album_name, lastfm_url, album_art=None):
        self.album_name = album_name
        self.lastfm_url = lastfm_url
        self.album_art = album_art


# Defines the Song table in the database
class Song(db.Model):
    __tablename__ = 'song'
    song_id = db.Column('song_id', db.Integer, primary_key=True)
    song_title = db.Column('song_title', db.Unicode)
    spotify_id = db.Column('spotify_id', db.Integer)
    lastfm_url = db.Column('lastfm_url', db.Unicode)
    song_by = db.relationship('Artist', secondary=song_by, backref=db.backref('performs', lazy='dynamic'))
    song_on = db.relationship('Album', secondary=song_on, backref=db.backref('contains', lazy='dynamic'))

    def __init__(self, song_title, lastfm_url, song_id=None, spotify_id=None):
        self.song_id = song_id
        self.lastfm_url = lastfm_url
        self.song_title = song_title
        self.spotify_id = spotify_id


# Defines the User table in the database
class User(db.Model):
    __tablename__ = 'user'
    user_id = db.Column('user_id', db.Integer, primary_key=True)
    username = db.Column('username', db.Unicode)
    lastfm_name = db.Column('lastfm_name', db.Unicode)
    join_date = db.Column('join_date', db.DateTime)
    password = db.Column('password', db.Unicode)
    email = db.Column('email', db.Unicode)

    # follows = db.relationship('User', secondary=follows, backref=db.backref('followed', lazy='dynamic'))

    def __init__(self, lastfm_name, username=None, password=None, email=None):
        self.lastfm_name = lastfm_name
        self.username = username
        self.password = password
        self.email = email
        if username:
            self.join_date = datetime.datetime.now()


# Defines the Artist table in the database
class Artist(db.Model):
    __tablename__ = 'artist'
    artist_id = db.Column('artist_id', db.Integer, primary_key=True)
    artist_name = db.Column('artist_name', db.Unicode)
    lastfm_url = db.Column('lastfm_url', db.Unicode)

    def __init__(self, artist_name, lastfm_url):
        self.artist_name = artist_name
        self.lastfm_url = lastfm_url


# Defines the ListenedTo table in the database
class ListenedTo(db.Model):
    __tablename__ = 'listened_to'
    user_id = db.Column('user_id', db.Integer, db.ForeignKey('user.user_id'), primary_key=True)
    song_id = db.Column('song_id', db.Integer, db.ForeignKey('song.song_id'), primary_key=True)
    num_listens = db.Column('num_listens', db.Integer)
    last_listen = db.Column('last_listen', db.DateTime)

    user = db.relationship('User', backref=db.backref('listened', lazy='dynamic'))
    song = db.relationship('Song', backref=db.backref('listened', lazy='dynamic'))

    def __init__(self, user_id, song_id, last_listen):
        self.user_id = user_id
        self.song_id = song_id
        self.num_listens = 1
        self.last_listen = last_listen


# Defines the Follows table in the database
class Follows(db.Model):
    __tablename__ = 'follows'
    follower_id = db.Column('follower_id', db.Integer, db.ForeignKey(User.user_id), primary_key=True)
    followed_id = db.Column('followed_id', db.Integer, db.ForeignKey(User.user_id), primary_key=True)

    follower = db.relationship('User', foreign_keys=[follower_id], backref=db.backref('follows', lazy='dynamic'))
    followed = db.relationship('User', foreign_keys=[followed_id], backref=db.backref('followed_by', lazy='dynamic'))

    def __init__(self, follower_id, followed_id):
        self.follower_id = follower_id
        self.followed_id = followed_id


# Defines the Rated table in the database
class Rated(db.Model):
    __tablename__ = 'rated'
    user_id = db.Column('user_id', db.Integer, db.ForeignKey('user.user_id'), primary_key=True)
    song_id = db.Column('song_id', db.Integer, db.ForeignKey('song.song_id'), primary_key=True)
    rated = db.Column('rated', db.Integer)
    rating_time = db.Column('rating_time', db.DateTime)

    user = db.relationship('User', backref=db.backref('rated', lazy='dynamic'))
    song = db.relationship('Song', backref=db.backref('rated', lazy='dynamic'))

    def __init__(self, user_id, song_id, rated):
        self.user_id = user_id
        self.song_id = song_id
        self.rated = rated
        self.rating_time = datetime.datetime.now()


# Defines the Recommendation table in the database
class Recommendation(db.Model):
    __tablename__ = 'recommendation'
    user_id = db.Column('user_id', db.Integer, db.ForeignKey('user.user_id'), primary_key=True)
    rec_id = db.Column('rec_id', db.Integer)
    rec_type = db.Column('rec_type', db.Unicode)
    rec_date = db.Column('rec_date', db.DateTime)

    user = db.relationship('User', backref=db.backref('recommended', lazy='dynamic'))

    def __init__(self, user_id, rec_id, rec_type):
        self.user_id = user_id
        self.rec_id = rec_id
        self.rec_type = rec_type
        self.rec_date = datetime.datetime.now()


# Gets album info by id
def get_album_by_id(album_id):
    album = db.session.query(Album).get(album_id)
    album_dict = {
        "album_id": album.album_id,
        "album_name": album.album_name,
        "album_art": album.album_art,
        "lastfm_url": album.lastfm_url
    }
    return json.dumps(album_dict)


# Gets artist info by id
def get_artist_by_id(artist_id):
    artist = db.session.query(Artist).get(artist_id)
    artist_dict = {
        "artist_id": artist.artist_id,
        "artist_name": artist.artist_name,
        "lastfm_url": artist.lastfm_url
    }
    return json.dumps(artist_dict)


# Gets song info by id
def get_song_by_id(song_id):
    song = db.session.query(Song).get(song_id)
    song_dict = {
        "song_id": song.song_id,
        "song_title": song.song_title,
        "spotify_id": song.spotify_id,
        "lastfm_url": song.lastfm_url
    }
    return json.dumps(song_dict)


# Gets song & artist info by song id
def get_song_by_id_full(song_id):
    song = db.session.query(Song).get(song_id)
    artists = []
    album = song.song_on[0]
    for artist in song.song_by:
        artist_dict = {
            "artist_id": artist.artist_id,
            "artist_name": artist.artist_name,
            "lastfm_url": artist.lastfm_url
        }
        artists.append(artist_dict)

    song_dict = {
        "song_id": song.song_id,
        "song_title": song.song_title,
        "spotify_id": song.spotify_id,
        "lastfm_url": song.lastfm_url,
        "artists": artists,
        "album_id": album.album_id,
        "album_name": album.album_name
    }
    return json.dumps(song_dict)


# Gets user info by id
def get_user_by_id(user_id):
    user = db.session.query(User).get(user_id)
    user_dict = {
        "user_id": user.user_id,
        "username": user.username,
        "lastfm_name": user.lastfm_name,
        "join_date": str(user.join_date),
        "email": user.email
    }
    return json.dumps(user_dict)


# Gets all songs a user has listened to.
def get_listened_songs(user_id):
    user = db.session.query(User).get(user_id)
    songs = []
    for listened in user.listened:
        song = db.session.query(Song).get(listened.song_id)
        artists = ""
        rating = -1
        rated = db.session.query(Rated).filter_by(user_id=user.user_id).filter_by(song_id=song.song_id).first()

        if rated is not None:
            rating = rated.rated

        for artist in song.song_by:
            if artists is "":
                artists = artists + artist.artist_name
            else:
                artists = artists + "," + artist.artist_name

        song_dict = {
            "song_id": song.song_id,
            "rating": rating,
            "song_title": song.song_title,
            "spotify_id": song.spotify_id,
            "lastfm_url": song.lastfm_url,
            "artist": artists
        }
        songs.append(song_dict)
    return json.dumps(songs)


# Adds a last fm user who has not made an account to the
def add_lastfm_user(lastfm_name):
    existing_lastfm_user = db.session.query(User).filter_by(lastfm_name=lastfm_name).first()
    if existing_lastfm_user:
        return existing_lastfm_user.user_id
    else:
        user = User(lastfm_name)
        db.session.add(user)
        try:
            db.session.commit()
            return user.user_id
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not add user: " + lastfm_name


# Creates a new app user
def add_user(username, lastfm_name, password, email):
    existing_user = db.session.query(User).filter_by(username=username).first()
    existing_email = db.session.query(User).filter_by(email=email).first()
    if existing_user or existing_email:
        error = "Error: "
        if existing_user:
            error += "User Exists. "
        if existing_email:
            error += "Email Exists."
        return error
    existing_lastfm_user = db.session.query(User).filter_by(lastfm_name=lastfm_name).first()
    if existing_lastfm_user:
        if (existing_lastfm_user.username):
            return "Error: User Exists. "
        else:
            existing_lastfm_user.username = username
            existing_lastfm_user.password = sha256_crypt.encrypt(password)
            existing_lastfm_user.password = sha256_crypt.encrypt(password)
            existing_lastfm_user.join_date = datetime.datetime.now()
            existing_lastfm_user.email = email
            db.session.commit()
    else:
        new_user = User(lastfm_name, username, sha256_crypt.encrypt(password), email)
        db.session.add(new_user)
        try:
            db.session.commit()
            return new_user.user_id
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not create user."


# Generates a logged in session for a user
def login(username, password):
    user = db.session.query(User).filter_by(username=username).first()
    if not user:
        return [False, "User does not exist", None]
    if not sha256_crypt.verify(password, user.password):
        return [False, "Incorrect password", None]
    else:
        user_json = json.dumps(
            {
                "user_id": user.user_id,
                "username": user.username,
                "lastfm_name": user.lastfm_name,
                "join_date": user.join_date.strftime("%B %d, %Y")
            }
        )
        return [True, "Success", user_json]


# Adds song info to database
def add_song(song_title, lastfm_url, spotify_id=None):
    existing_song = db.session.query(Song).filter_by(lastfm_url=lastfm_url).first()
    if existing_song:
        return existing_song.song_id
    else:
        song = Song(song_title, lastfm_url, None, spotify_id)
        db.session.add(song)
        try:
            db.session.commit()
            return song.song_id
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not add song: " + song_title


# Adds artist info to database
def add_artist(artist_name, lastfm_url):
    existing_artist = db.session.query(Artist).filter_by(lastfm_url=lastfm_url).first()
    if existing_artist:
        return existing_artist.artist_id
    else:
        artist = Artist(artist_name, lastfm_url)
        db.session.add(artist)
        try:
            db.session.commit()
            return artist.artist_id
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not add artist: " + artist_name


# Adds album info to database
def add_album(album_name, lastfm_url, album_art=None):
    existing_album = db.session.query(Album).filter_by(lastfm_url=lastfm_url).first()
    if existing_album:
        return existing_album.album_id
    else:
        album = Album(album_name, lastfm_url, album_art)
        db.session.add(album)
        try:
            db.session.commit()
            return album.album_id
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not add album: " + album_name


# Creates a relationship between a song and artist
def add_song_by(song_id, artist_id):
    song = db.session.query(Song).get(song_id)
    artist = db.session.query(Artist).get(artist_id)
    artist.performs.append(song)
    try:
        db.session.commit()
        return "Success"
    except sqlalchemy.exc.IntegrityError:
        db.session.rollback()
        return "ERROR: Could not create relationship."


# Creates a relationship between a song and album
def add_song_on(song_id, album_id):
    song = db.session.query(Song).get(song_id)
    album = db.session.query(Album).get(album_id)
    album.contains.append(song)
    try:
        db.session.commit()
        return "Success"
    except sqlalchemy.exc.IntegrityError:
        db.session.rollback()
        return "ERROR: Could not create relationship."


# Creates a relationship between an album and artist
def add_album_featuring(album_id, artist_id):
    album = db.session.query(Album).get(album_id)
    artist = db.session.query(Artist).get(artist_id)
    artist.featured_on.append(album)
    try:
        db.session.commit()
        return "Success"
    except sqlalchemy.exc.IntegrityError:
        db.session.rollback()

        return "ERROR: Could not create relationship."


# Notes that a user has listened to a specific song
def add_listened_to(user_id, song_id, listen_date):
    listen = db.session.query(ListenedTo).filter_by(
        user_id=user_id,
        song_id=song_id
    ).first()

    if listen:
        listen.num_listens += 1
        listen.last_listen = listen_date
        try:
            db.session.commit()
            return "Successfully updated"
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not update listen"
    else:
        listen = ListenedTo(user_id, song_id, listen_date)
        db.session.add(listen)
        try:
            db.session.commit()
            return "Successfully added"
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()

            return "ERROR: Could not add listen"


# gets followers of a user
def get_followers(user_id):
    user = db.session.query(User).get(user_id)
    followersList = []
    for followers in user.followed_by:
        follower = db.session.query(User).get(followers.follower_id)
        follower_dict = {
            "user_id": follower.user_id,
            "username": follower.username
        }
        followersList.append(follower_dict)
    return json.dumps(followersList)


# gets the following list from a user
def get_following(user_id):
    user = db.session.query(User).get(user_id)
    followingList = []
    for following in user.follows:
        follow = db.session.query(User).get(following.followed_id)
        following_dict = {
            "user_id": follow.user_id,
            "username": follow.username
        }
        followingList.append(following_dict)
    return json.dumps(followingList)


# add_follows method creates relationship between two users where user_id1 follows user_id2.
def add_follows(user_id1, user_id2):
    existing_user1 = db.session.query(User).filter_by(user_id=user_id1).first()
    existing_user2 = db.session.query(User).filter_by(user_id=user_id2).first()

    # checks if the users exist
    if existing_user1 is not None and existing_user2 is not None:
        # both users exist
        # query if the relationship already exists
        relationship_between_u1_u2 = db.session.query(Follows).filter_by(follower_id=user_id1).filter_by(
            followed_id=user_id2).first()

        if relationship_between_u1_u2 is None:
            # query outputted null and therefore no follow relationship exists
            follow_var = Follows(user_id1, user_id2)
            db.session.add(follow_var)
            db.session.commit()
            try:
                db.session.commit()
                return "Success"
            except sqlalchemy.exc.IntegrityError:
                db.session.rollback()
                return "ERROR: Could not create relationship."
        else:
            # query outputted not empty and therefore the relationship exists
            return "ERROR: Relationship already exists."
    else:
        # one or both users do not exist
        return "ERROR: Users do not exist."


# User 1 trying to unfollow User 2
def delete_follows(user_id1, user_id2):
    existing_relationship = db.session.query(Follows).filter_by(follower_id=user_id1).filter_by(
        followed_id=user_id2).first()

    if existing_relationship:
        db.session.delete(existing_relationship)
        db.session.commit()
        try:
            db.session.commit()
            return "unfollow successful"
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not create relationship."
    else:
        return "Error: This relationship does not exist"


# function that creates a like rating for a specific user and specific song
def like(user_id, song_id):
    user = db.session.query(User).get(user_id)
    song = db.session.query(Song).get(song_id)
    relationship = db.session.query(Rated).filter_by(user_id=user_id).filter_by(song_id=song_id).first()
    if user is not None and song is not None:
        if relationship is not None and relationship.rated is 1:
            db.session.delete(relationship)
        else:
            if relationship is not None:
                db.session.delete(relationship)
                db.session.commit()
            rate = Rated(user_id, song_id, 1)
            db.session.add(rate)
        try:
            db.session.commit()
            return """Success"""
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not create relationship."
    else:
        return "Error: could not create relationship because conditions were not met."


# function that creates a dislike rating for a specific user and specific song
def dislike(user_id, song_id):
    user = db.session.query(User).get(user_id)
    song = db.session.query(Song).get(song_id)
    relationship = db.session.query(Rated).filter_by(user_id=user_id).filter_by(song_id=song_id).first()
    if user is not None and song is not None:
        if relationship is not None and relationship.rated is 0:
            db.session.delete(relationship)
        else:
            if relationship is not None:
                db.session.delete(relationship)
                db.session.commit()
            rate = Rated(user_id, song_id, 0)
            db.session.add(rate)
        try:
            db.session.commit()
            return """Success"""
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not create/delete relationship."
    else:
        return "Error: could not create relationship because conditions were not met."


# basic script to create base of ratings for users and songs. Loops through all songs a user has listened to and randomly assigns a rating
def create_ratings():
    listened_to_table = db.session.query(ListenedTo).all()
    for row in listened_to_table:
        user_id = row.user_id
        song_id = row.song_id
        rating = random.randint(0, 1)
        if (rating == 0):
            dislike(user_id, song_id)
        else:
            like(user_id, song_id)


# Gets all the songs a user has disliked
def get_dislikes(user_id):
    user = db.session.query(User).get(user_id)
    rates = db.session.query(Rated).filter_by(user_id=user_id).filter_by(rated=0).order_by(Rated.rating_time.desc())
    dislikes = []
    for rate in rates:
        username = db.session.query(User).get(rate.user_id)
        song = db.session.query(Song).get(rate.song_id)

        # checks if artist is null
        # if null artist, put Brendan
        artistOfsong = song.song_by
        if artistOfsong == []:
            artist = 'Brendan'
        elif artistOfsong is not []:
            artist = song.song_by[0].artist_name

        dislikes_dict = {
            "username": username.username,
            "song_id": song.song_id,
            "song_title": song.song_title,
            "artist": artist,
            "rating": rate.rated
        }
        dislikes.append(dislikes_dict)
    return json.dumps(dislikes)


# Gets all the songs a user has liked
def get_likes(user_id):
    user = db.session.query(User).get(user_id)
    rates = db.session.query(Rated).filter_by(user_id=user_id).filter_by(rated=1).order_by(Rated.rating_time.desc())
    likes = []
    for rate in rates:
        username = db.session.query(User).get(rate.user_id)
        song = db.session.query(Song).get(rate.song_id)

        # checks if artist is null
        # if null artist, put Brendan
        artistOfsong = song.song_by
        if artistOfsong == []:
            artist = 'Brendan'
        elif artistOfsong is not []:
            artist = song.song_by[0].artist_name

        likes_dict = {
            "username": username.username,
            "song_id": song.song_id,
            "song_title": song.song_title,
            "artist": artist,
            "rating": rate.rated
        }
        likes.append(likes_dict)
    return json.dumps(likes)


# returns the 30 most recent listens and likes made by a user and the users they follow.
# If user_only is true, returns only listens and likes from the given user
def get_feed(user_id, user_only):
    user = db.session.query(User).get(user_id)
    feed_users = [user_id]
    if not user_only:
        for friend in user.follows:
            feed_users.append(friend.followed.user_id)
    listens = db.session.query(ListenedTo).filter(ListenedTo.user_id.in_(feed_users)).order_by(
        ListenedTo.last_listen.desc()).limit(30).all()
    rates = db.session.query(Rated).filter(Rated.user_id.in_(feed_users)).order_by(Rated.rating_time.desc()).limit(
        30).all()
    listens_and_rates = []
    for listen in listens:
        try:
            user = db.session.query(User).get(listen.user_id)
            song = db.session.query(Song).get(listen.song_id)
            listens_and_rates.append({
                "username": user.username,
                "lastfm_name": user.lastfm_name,
                "song_id": song.song_id,
                "song_title": song.song_title,
                "artist": song.song_by[0].artist_name,
                "datetime": str(listen.last_listen),
                "is_rating": False,
                "rating": -1
            })
        except IndexError:
            print("could not add listen")
    for rate in rates:
        try:
            username = db.session.query(User).get(rate.user_id)
            song = db.session.query(Song).get(rate.song_id)
            listens_and_rates.append({
                "username": user.username,
                "song_id": song.song_id,
                "song_title": song.song_title,
                "artist": song.song_by[0].artist_name,
                "datetime": str(listen.last_listen),
                "is_rating": True,
                "rating": rate.rated
            })
        except IndexError:
            print("could not add listen")
    sorted_feed = sorted(listens_and_rates, key=lambda k: k["datetime"])
    return json.dumps(sorted_feed[0:30])


# Returns the name of the artist who performed a given song
def get_artist(song_id):
    song = db.session.query(Song).get(song_id)
    artist = song.song_by[0]
    return artist.artist_name


# Returns a list of 3 lists containing rating info, user ids, and song info
def get_rec_info():
    ratings = []
    users = []
    songs = []

    ratings_query = db.session.query(Rated).all()
    users_query = db.session.query(User).all()
    song_query = db.session.query(Song).all()

    for r in ratings_query:
        ratings.append([r.user_id, r.song_id, r.rated, r.rating_time])

    for u in users_query:
        users.append([u.user_id])

    for s in song_query:
        songs.append([s.song_id, s.song_title])

    return [ratings, users, songs]


# Retrieves on-the-fly recommendations for a user
#     Utilizes machine learning algorithm to recommend a number of songs
#     based on songs user_id has liked
# parameter: user_id
def db_recommend(user_id):
    return proto.make_recommendations(user_id)


# recommends 5 users that have a similar listening history as user_id
#     specifically, users that have listened to at least 5 songs in user_id's listened history
#    in the future, change this threshold to be that users have listened to at least 25% of
#        user_id's listening history
# parameter: user_id
def db_recommendusers(user_id):
    loadedjson = json.loads(get_listened_songs(user_id))
    numSongsUser1 = len(loadedjson)
    matchedUsers = []

    # query all the users
    allusers = db.session.query(User).all()
    for user in allusers:
        numOfSameSongs = 0
        # checks if user_id is already following user_id2, if so move onto next user
        tmpuserid = '"user_id": ' + str(user.user_id)
        if tmpuserid not in get_following(user_id):
            # user not already following user2
            print(str(user_id) + ' not following ' + str(user.user_id))
            # load the listened songs of user.user_id
            usersloadedjson = json.loads(get_listened_songs(user.user_id))
            # iterate through of the songs of user.user_id
            for i in range(len(usersloadedjson)):
                thesong = '"song_id": ' + str(usersloadedjson[i]['song_id'])
                print('Searching for: ' + str(thesong))
                if thesong in get_listened_songs(user_id):
                    # user.user_id and user_id have both listened to current song
                    # add one to song counter
                    numOfSameSongs = numOfSameSongs + 1
                    # checks if the number of same songs found for this particular user
                    #    the threshhold - if it does, move onto the next user
                    if numOfSameSongs >= 5:
                        break
            print('User ' + str(user_id) + 'user ' + str(user.user_id) + ' have ' + str(
                numOfSameSongs) + ' of same songs.')
            # print(user.user_id)

        # checks if the number of same songs meets the threshold of 25%
        #     (this criteria would be used in future development of the app)
        # changed criteria to be if they have at least 5 similar songs
        if numOfSameSongs >= 5:
            matcheduser_dict = {
                "user_id": user.user_id,
                "username": user.username
            }
            matchedUsers.append(matcheduser_dict)
        # prints matched users
        print('Matches users: ' + str(matchedUsers))
        if len(matchedUsers) >= 5:
            break
    return json.dumps(matchedUsers)

