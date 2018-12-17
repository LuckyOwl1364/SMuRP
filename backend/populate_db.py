import requests, array, json
from db_api import get_user_by_id, add_lastfm_user, add_song, add_artist, add_album, add_song_by, add_song_on, add_album_featuring, add_listened_to

def populate():
    arr = ["rj","grinch","eartle","Mooduz","maddiecakesyo","xconzo","lionrevolt","theBlackWhite","UnquietNights"]
    for name in arr:
        adding_info(name)
        friend_params = {'method': 'user.getfriends', 'user': name, 'api_key': '8ed3258b37f9fb17b765bb7589e06c6f','format': 'json' }
        friends_response = requests.get('http://ws.audioscrobbler.com/2.0/?', params=friend_params)
        friends = friends_response.json()
        for i in range(len(friends['friends']['user'])):
                adding_info(friends['friends']['user'][i]['name'])


def adding_info(user):
    user_id= add_lastfm_user(user)
    parameter = {'method': 'user.getlovedtracks', 'user': user, 'api_key': '8ed3258b37f9fb17b765bb7589e06c6f','format': 'json' }
    response = requests.get('http://ws.audioscrobbler.com/2.0/?', params=parameter)
    data = response.json()
    for i in range(len(data['lovedtracks']['track'])):
        song_name = data['lovedtracks']['track'][i]['name']
        song_url_raw = data['lovedtracks']['track'][i]['url']
        song_url = song_url_raw[:400] if len(song_url_raw) > 400 else song_url_raw
        song_id = add_song(song_name, song_url)
        artist_name = data['lovedtracks']['track'][i]['artist']['name']
        artist_url = data['lovedtracks']['track'][i]['artist']['url']
        artist_id = add_artist(artist_name, artist_url)
        add_song_by(song_id, artist_id)
        add_listened_to(user_id, song_id)
