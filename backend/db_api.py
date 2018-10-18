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


class Album(db.Model):
    __tablename__ = 'album'
    album_id = db.Column('album_id', db.Integer, primary_key=True)
    album_name = db.Column('album_name', db.Unicode)
    album_art = db.Column('album_art', db.Unicode)
    featuring = db.relationship('Artist', secondary=album_featuring,
                                backref=db.backref('featured_on', lazy='dynamic'))

    def __init__(self, album_name, album_art=None):
        self.album_name = album_name
        self.album_art = album_art


class Artist(db.Model):
    __tablename__ = 'artist'
    artist_id = db.Column('artist_id', db.Integer, primary_key=True)
    artist_name = db.Column('artist_name', db.Unicode)

    def __init__(self, artist_name):
        self.artist_name = artist_name


class Song(db.Model):
    __tablename__ = 'song'
    song_id = db.Column('song_id', db.Integer, primary_key=True)
    song_title = db.Column('song_title', db.Unicode)
    spotify_id = db.Column('spotify_id', db.Integer)
    song_by = db.relationship('Artist', secondary=song_by, backref=db.backref('performs', lazy='dynamic'))
    song_on = db.relationship('Album', secondary=song_on, backref=db.backref('contains', lazy='dynamic'))

    def __init__(self, song_title, spotify_id=None):
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


# TODO: Recommendation Table.
# If possible, fix lack of foreign key implementation through sqlalchemy


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


def add_lastfm_user(fm_username):
    user = User(fm_username)
    db.session.add(user)
    try:
        db.session.commit()
        return User.user_id
    except sqlalchemy.exc.IntegrityError:
        db.session.rollback()
        return "ERROR: Could not add user: " + fm_username

