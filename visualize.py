import os
import altair as alt
import pandas as pd
import geopandas as gpd
import json
import shapely.wkt
import pickle
colors = 9
cmap = 'Blues'
figsize = (16, 10)

def visualize(cloropleth, column, directory='data/pickles', pickle_name='maryland.pkl'):
    df = pickle.load(open(os.path.join(directory, pickle_name), 'rb'))
    gdf = df.merge(cloropleth, on='key', how='inner')
    gdf = gpd.GeoDataFrame(gdf, crs={'init' :'epsg:4326'}, geometry='geometry')
    gdf.drop(columns='category')
    json_gdf = gdf.to_json()
    json_features = json.loads(json_gdf)
    data = alt.Data(values=json_features['features'])
    multi = alt.selection_multi()
    return alt.Chart(data).mark_geoshape(
                fill='lightgray',
                stroke='white'
            ).properties(
                projection={'type': 'mercator'},
                selection=multi
            ).encode(
                #set column to be value to color over
                color=alt.condition(multi, 'votes:Q', alt.value('lightgray')),
                tooltip=('key','stat:Q', 'votes:Q')
            )

def plot_map(cloropleth, directory='data/pickles', pickle_name='maryland.pkl'):
    df = pickle.load(open(os.path.join(directory, pickle_name), 'rb'))
    gdf = df.merge(cloropleth, on='key', how='inner')
    gdf['normalized'] = gdf.apply(lambda x: (x.stat-np.mean(gdf.stat))/np.std(gdf.stat), axis=1)
    gdf = gpd.GeoDataFrame(gdf, crs={'init' :'epsg:4326'}, geometry='geometry')
    return gdf.plot(column='stat', cmap=cmap, figsize=figsize, scheme='equal_interval',
             k=colors, categorical=True, legend=True)