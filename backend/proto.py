import numpy as np
import pandas as pd
from db_api import *
import json

# make_recommendations method
def make_recommendations(user_id):
    #all_lists make a method call to db_api to get a list of lists that include ratings, user, and song tables
    all_lists = get_rec_info()
    rating_list = all_lists[0]
    users_list = all_lists[1]
    songs_list = all_lists[2]

    #labels for the ratings table headers
    rat_labels = ['user_id','song_id','rated','rating_time']

    #labels for the users table headers
    user_labels = ['user_id']

    #labels for the song table headers
    song_labels = ['song_id','song_title']

    #puts lists into pandas dataframe
    ratings = pd.DataFrame.from_records(rating_list, columns=rat_labels)
    users = pd.DataFrame.from_records(users_list, columns=user_labels)
    songs = pd.DataFrame.from_records(songs_list, columns=song_labels)

    #makes list of unique users in the ratings table
    unique_users = ratings['user_id'].unique().tolist()


    #grabs how many users and songs there are
    n_users = ratings.user_id.unique().shape[0]
    n_songs = ratings.song_id.unique().shape[0]


    Ratings = ratings.pivot(index = 'user_id', columns ='song_id', values = 'rated').fillna(0)
    Ratings.head()

    R = Ratings.as_matrix()
    user_ratings_mean = np.mean(R, axis = 1)
    Ratings_demeaned = R - user_ratings_mean.reshape(-1, 1)
	
	sparsity = round(1.0 - len(ratings) / float(n_users * n_songs), 3)

    #imports svds package
    from scipy.sparse.linalg import svds
    U, sigma, Vt = svds(Ratings_demeaned, k = 50)

    sigma = np.diag(sigma)

    #creates all user's predicted ratings
    all_user_predicted_ratings = np.dot(np.dot(U, sigma), Vt) + user_ratings_mean.reshape(-1, 1)
    preds = pd.DataFrame(all_user_predicted_ratings, columns = Ratings.columns)
    #converts user_ids from unicode to int
    user_id = int(user_id)
    already_rated, predictions = recommend_songs(preds, user_id, songs, ratings, 8,unique_users)

    #creates json in format for frontend
    json_pred = predictions.to_json(orient='index')
    loaded_json = json.loads(json_pred)
    pred_list = []
    for i in loaded_json:
        dict = {
            "song_id": loaded_json[i]['song_id'],
            "song_title": loaded_json[i]['song_title'],
            "artists": get_artist(loaded_json[i]['song_id'])
        }
        pred_list.append(dict)
    return json.dumps(pred_list)

#recommend_songs returns the recommendations dataframe
def recommend_songs(predictions, userID, songs, original_ratings, num_recommendations,unique_users):

    # Get and sort the user's predictions
    try:
        #gets index in predictions table
        user_row_number = unique_users.index(userID)
    except ValueError:
        #if a user has not liked any songs, we recommend them the songs liked by the first user, in the hopes they
        #will like or dislike any song to get an idea of what they like.
        user_row_number = 0
	sorted_user_predictions = predictions.iloc[user_row_number].sort_values(ascending=False)        # User ID starts at 1
    # Get the user's data and merge in the song information.
    user_data = original_ratings[original_ratings.user_id == (userID)]
    user_full = (user_data.merge(songs, how = 'left', left_on = 'song_id', right_on = 'song_id').
                     sort_values(['rated'], ascending=False)
                 )


    # Recommend the highest predicted rating movies that the user hasn't seen yet.
    recommendations = (songs[~songs['song_id'].isin(user_full['song_id'])].
    merge(pd.DataFrame(sorted_user_predictions).reset_index(), how = 'left',
           left_on = 'song_id',
           right_on = 'song_id').
    rename(columns = {user_row_number: 'Predictions'}).
    sort_values('Predictions', ascending = False).
                   iloc[:num_recommendations, :-1]
                  )

    return user_full, recommendations
