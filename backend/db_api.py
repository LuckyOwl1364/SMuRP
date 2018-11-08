from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import sqlalchemy.exc
import datetime
import json

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

follows = db.Table('follows,',
                   db.Column('follower_id', db.Integer, db.ForeignKey('user.user_id')),
                   db.Column('followed_id', db.Integer, db.ForeignKey('user.user_id')))


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


class Artist(db.Model):
    __tablename__ = 'artist'
    artist_id = db.Column('artist_id', db.Integer, primary_key=True)
    artist_name = db.Column('artist_name', db.Unicode)
    lastfm_url = db.Column('lastfm_url', db.Unicode)

    def __init__(self, artist_name, lastfm_url):
        self.artist_name = artist_name
        self.lastfm_url = lastfm_url


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


class User(db.Model):
    __tablename__ = 'user'
    user_id = db.Column('user_id', db.Integer, primary_key=True)
    username = db.Column('username', db.Unicode)
    lastfm_name = db.Column('lastfm_name', db.Unicode)
    join_date = db.Column('join_date', db.DateTime)
    password = db.Column('password', db.Unicode)
    email = db.Column('email', db.Unicode)
    follows = db.relationship('User', secondary=follows, backref=db.backref('followed', lazy='dynamic'))

    def __init__(self, lastfm_name, username=None, password=None, email=None):
        self.lastfm_name = lastfm_name
        self.username = username
        self.password = password
        self.email = email
        if username:
            self.join_date = datetime.datetime.now()


class ListenedTo(db.Model):
    __tablename__ = 'listened_to'
    user_id = db.Column('user_id', db.Integer, db.ForeignKey('user.user_id'), primary_key=True)
    song_id = db.Column('song_id', db.Integer, db.ForeignKey('song.song_id'), primary_key=True)
    num_listens = db.Column('num_listens', db.Integer)
    last_listen = db.Column('last_listen', db.DateTime)

    user = db.relationship('User', backref=db.backref('listened', lazy='dynamic'))
    song = db.relationship('Song', backref=db.backref('listened', lazy='dynamic'))

    def __init__(self, user_id, song_id):
        self.user_id = user_id
        self.song_id = song_id
        self.num_listens = 1
        self.last_listen = datetime.datetime.now()


class Rated(db.Model):
    __tablename__ = 'rated'
    user_id = db.Column('user_id', db.Integer, db.ForeignKey('user.user_id'), primary_key=True)
    song_id = db.Column('song_id', db.Integer, db.ForeignKey('song.song_id'), primary_key=True)
    rated = db.Column('rated', db.Integer)

    user = db.relationship('User', backref=db.backref('rated', lazy='dynamic'))
    song = db.relationship('Song', backref=db.backref('rated', lazy='dynamic'))

    def __init__(self, user_id, song_id, rated):
        self.user_id = user_id
        self.song_id = song_id
        self.rated = rated


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


def get_album_by_id(album_id):
    album = db.session.query(Album).get(album_id)
    album_dict = {
        "album_id": album.album_id,
        "album_name": album.album_name,
        "album_art": album.album_art,
        "lastfm_url": album.lastfm_url
    }
    return json.dumps(album_dict)


def get_artist_by_id(artist_id):
    artist = db.session.query(Artist).get(artist_id)
    artist_dict = {
        "artist_id": artist.artist_id,
        "artist_name": artist.artist_name,
        "lastfm_url": artist.lastfm_url
    }
    return json.dumps(artist_dict)


def get_song_by_id(song_id):
    song = db.session.query(Song).get(song_id)
    song_dict = {
        "song_id": song.song_id,
        "song_title": song.song_title,
        "spotify_id": song.spotify_id,
        "lastfm_url": song.lastfm_url
    }
    return json.dumps(song_dict)


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


def get_listened_songs(user_id):
    user = db.session.query(User).get(user_id)
    songs = []
    for listened in user.listened:
        song = db.session.query(Song).get(listened.song_id)
        song_dict = {
            "song_id": song.song_id,
            "song_title": song.song_title,
            "spotify_id": song.spotify_id,
            "lastfm_url": song.lastfm_url
        }
        songs.append(song_dict)
    return json.dumps(songs)


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


def add_listened_to(user_id, song_id):
    listen = db.session.query(ListenedTo).filter_by(
        user_id = user_id,
        song_id = song_id
    ).first()

    if listen:
        listen.num_listens += 1
        listen.last_listen = datetime.datetime.now()
        try:
            db.session.commit()
            return "Successfully updated"
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not update listen"
    else:
        listen = ListenedTo(user_id, song_id)
        db.session.add(listen)
        try:
            db.session.commit()
            return "Successfully added"
        except sqlalchemy.exc.IntegrityError:
            db.session.rollback()
            return "ERROR: Could not add listen"

# add_follows method creates relationship between two users where user_id1 follows user_id2.
def add_follows(user_id1, user_id2):
    existing_user1 = db.session.query(User).filter_by(user_id=user_id1).first()
    existing_user2 = db.session.query(User).filter_by(user_id=user_id2).first()

    # checks if the users exist
    if existing_user1 is not None and existing_user2 is not None:
        # query if the relationship already exists        
        user = db.session.query(User).get(user_id)
        followedlist = []
        for followed in user.followed:
            user_temp = db.session.query(User).get(followed.followed_id)
            user_dict = {
               "user_id": user_temp.user_id
            }

            followedlist.append(user_dict)

        
        if followedlist is None:  
            # followedlist is empty and therefore no follow relationship exists
            user1 = db.session.query(User).get(user_id1)
            user2 = db.session.query(User).get(user_id2)
            user1.follows.append(user2)
            try:
                db.session.commit()
                return "Success"
            except sqlalchemy.exc.IntegrityError:
                db.session.rollback()
                return "ERROR: Could not create relationship."
        else:
            # followedlist is not empty and therefore the relationship exists
            return "ERROR: Relationship already exists."
    else:
        return "ERROR: Users do not exist."