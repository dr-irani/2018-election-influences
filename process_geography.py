import os
import sys
import pandas as pd
import geopandas as gpd
from fiona.crs import from_epsg
from shapely.geometry import Polygon, Point
from shapely.ops import cascaded_union
from geopandas.tools import sjoin
import pickle
import spatial_overlays as sp


def read_file_into_dataframe(desired_geometry, name, cat, crs={'init' :'epsg:4326'}, directory='data'):
    desired_geometry = str(desired_geometry) + '.shp'
    FP = os.path.join(directory, desired_geometry)
    # read filepath into dataframe
    df = gpd.read_file(FP)
    # convert stateplane to lat/long
    df = df.to_crs(crs)
    # select desired columns and convert into geodataframe
    gdf = gpd.GeoDataFrame(df.loc[:, (name, 'geometry')], crs=crs, geometry='geometry')
    gdf.columns = ['key', 'geometry']
    gdf['category'] = cat
    gdf = gdf[['key', 'category', 'geometry']]
    return gdf


def get_reference(pickle_name, shapefile_dir='data/shapefile', pickle_dir='data/pickles/'):
    try:
        fname = os.path.join(pickle_dir, pickle_name)
        gdf = pickle.load(open(fname, 'rb'))
    except:
        if pickle_name == 'maryland.pkl':
            gdf = make_reference(shapefile_dir, pickle_dir, pickle_name)
        elif pickle_name == 'baltimore.pkl':
            gdf = get_baltimore()
    return gdf


def make_reference(shapefile_dir, pickle_dir, pickle_name):
    # shapefile names
    COUNTY_FN = 'Maryland_Physical_Boundaries__County_Boundaries_Generalized'
    ZIPCODE_FN = 'Maryland_Political_Boundaries__ZIP_Codes__5_Digit'
    CONGRESSIONAL_FN = 'Maryland_Archived_Election_Boundaries__2002_US_Congressional_Districts'
    LEGISLATIVE_FN = 'Maryland_Election_Boundaries__Maryland_Legislative_Districts_2012'

    county = read_file_into_dataframe(COUNTY_FN, 'county', 'county', directory=os.path.join(shapefile_dir, COUNTY_FN))
    zipcode = read_file_into_dataframe(ZIPCODE_FN, 'ZIPCODE1', 'zipcode', directory=os.path.join(shapefile_dir, ZIPCODE_FN))
    congressional = read_file_into_dataframe(CONGRESSIONAL_FN, 'ID_1', 'congressional_district', directory=os.path.join(shapefile_dir, CONGRESSIONAL_FN))
    legislative = read_file_into_dataframe(LEGISLATIVE_FN, 'DISTRICT', 'legislative_district', directory=os.path.join(shapefile_dir, LEGISLATIVE_FN))
    maryland = pd.concat([county, zipcode, congressional, legislative], sort=False)
    maryland = maryland.reset_index()
    maryland.drop(columns='index', inplace=True)
    make_pickle(pickle_dir, maryland, pickle_name)
    return maryland


def baltimore_outline(gdf, crs={'init' :'epsg:4326'}):
    polygons = gdf.geometry
    boundary = gpd.GeoSeries(cascaded_union(polygons))
    boundary.crs = from_epsg(4326)
    outline = gpd.GeoDataFrame(boundary, crs=crs)
    outline.columns = ['geometry']
    return outline


def get_baltimore(shapefile_dir='data/shapefile', pickle_dir='data/pickles/', pickle_name='maryland.pkl'):
    NEIGHBORHOOD_FP = 'geo_export_78598ce9-415c-46aa-8676-d6ccfed48544'
    neighborhood = read_file_into_dataframe(NEIGHBORHOOD_FP, 'name', 'neighborhood', directory=os.path.join(shapefile_dir, NEIGHBORHOOD_FP))
    outline = baltimore_outline(neighborhood)
    maryland = get_reference(pickle_name, shapefile_dir, pickle_dir)
    baltimore = sp.spatial_overlays(outline, maryland, how='intersection')
    baltimore = pd.concat([baltimore, neighborhood], sort=False)
    baltimore = baltimore.reset_index()
    baltimore.drop(columns=['index', 'idx1', 'idx2'], inplace=True)
    make_pickle(pickle_dir, baltimore, 'baltimore.pkl')
    return baltimore


def make_pickle(processed_dir, df, pickle_name):
    with open(os.path.join(processed_dir, str(pickle_name)), 'wb') as pickle_file:
        pickle.dump(df, pickle_file)

def write_to_csv(name, pickle_name, processed_dir='data/'):
    fp = os.path.join(processed_dir, name)
    gdf = get_reference(pickle_name)
    gdf.to_csv(fp, index=False)

if __name__ == "__main__":
    write_to_csv('baltimore_geography.csv', 'baltimore.pkl')
    write_to_csv('maryland_geography.csv', 'maryland.pkl')
