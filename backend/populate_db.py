import requests, array, json
from db_api import get_user_by_id, add_lastfm_user, add_song, add_artist, add_album, add_song_by, add_song_on, add_album_featuring, add_listened_to


def populate():
    arr = ["rj","grinch","eartle","Mooduz","maddiecakesyo","xconzo","lionrevolt","theBlackWhite","UnquietNights"]
    for name in arr:
        user_id= add_lastfm_user(name)
        parameter = {'method': 'user.getlovedtracks', 'user': name, 'api_key': '8ed3258b37f9fb17b765bb7589e06c6f','format':'json' }
        response = requests.get('http://ws.audioscrobbler.com/2.0/?', params=parameter)
        data = response.json()
        for i in range(len(data['lovedtracks']['track'])):
                song_name = data['lovedtracks']['track'][i]['name']
                song_url = data['lovedtracks']['track'][i]['url']
                song_id = add_song(song_name, song_url)
                artist_name = data['lovedtracks']['track'][i]['artist']['name']
                artist_url = data['lovedtracks']['track'][i]['artist']['url']
                artist_id = add_artist(artist_name, artist_url)
                add_song_by(song_id, artist_id)
                add_listened_to(user_id, song_id)
                album_params = {'method': 'track.getInfo', 'api_key': '8ed3258b37f9fb17b765bb7589e06c6f', 'artist': artist_name, 'track': song_name, 'format': 'json' }
                album_response = requests.get('http://ws.audioscrobbler.com/2.0/?', params=album_params)
                album_json = album_response.json()
                if 'album' in album_json['track'].keys():
                        album_name = album_json['track']['album']['title']
                        album_url = album_json['track']['album']['url']
                        album_id = add_album(album_name, album_url)
                        add_song_on(song_id,album_id)
                        add_album_featuring(album_id, artist_id)
