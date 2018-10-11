import sqlalchemy
from sqlalchemy import *
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
import datetime

engine = sqlalchemy.create_engine('mysql+pymysql://admin:Talwkatgigasbas2h@ec2-52-91-42-119.compute-1.amazonaws.com:3306/smurp')
Base = automap_base()
Base.prepare(engine, reflect=True)
Album = Base.classes.album
# Album_featuring = Base.classes.album_featuring
Artist = Base.classes.artist
# Listened_To = Base.classes.listened_to
# Rated = Base.classes.rated
# Recommendation = Base.classes.recommendation
Song = Base.classes.song
# Song_By = Base.classes.song_by
# Song_On = Base.classes.song_on
User = Base.classes.user

session = Session(engine)

def create_user(lastfm_name, username="", password="", email=""):
    session.add(User(username=username, lastfm_name=lastfm_name, join_date=datetime.datetime.utcnow(),
                     password=password, email=email))
    session.commit()

def create_artist(artist_name):
    session.add(Artist(artist_name=artist_name))
    session.commit()

# def rate(user_id, song_id, positive):
#     rating = 0
#     if positive:
#         rating += 1
#     session.add(Rated(user_id=user_id, song_id=song_id, rated=rating))
#     session.commit()

# def recommendation(user_id, rec_id, rec_type):
#     session.add(Recommendation(user_id=user_id, rec_id=rec_id, rec_type=rec_type))
#     session.commit()

def create_song(song_title, spotify_id=""):
    session.add(Song(song_title=song_title, spotify_id=spotify_id))
    session.commit()

def create_album(album_name, album_art=""):
    session.add(Album(album_name=album_name, album_art=album_art))
    session.commit()

def get_user_by_id(user_id):
    return session.query(User).get(user_id)