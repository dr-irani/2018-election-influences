import requests
import lxml.html as lh
from bs4 import BeautifulSoup
from urllib.request import urlopen
import re
import pandas as pd
import os

def parse_table(url, output_file, processed_dir='data'):
    page = requests.get(url)
    doc = lh.fromstring(page.content)
    tr_elements, mode = get_rows(doc)
    df = populate_df(tr_elements, mode)
    write_to_csv(df, output_file, processed_dir)


def extract_data_files(url, processed_dir='data'):
    base_url = '/'.join(url.split('/')[:-1])
    html_page = urlopen(url)
    soup = BeautifulSoup(html_page)
    links = []
    for link in soup.findAll('a', attrs={'href': re.compile(".csv")}):
        csv_url = '/'.join([base_url, link.get('href')])
        with open(os.path.join(processed_dir, link.get('href')), "wb") as file:
            for data in requests.get(csv_url, stream=True).iter_content():
                file.write(data)


def get_rows(doc):
    tr_elements = doc.xpath('//tr')
    mode = max([len(T) for T in tr_elements], key=[len(T) for T in tr_elements].count)
    return tr_elements[[len(T) for T in tr_elements].index(mode):], mode


def populate_df(tr_elements, mode):
    col = get_column_headers(tr_elements)

    for j in range(1, len(tr_elements)):
        if len(tr_elements[j]) != mode:
            break
        
        i = 0
        for t in tr_elements[j].iterchildren():
            data = t.text_content() 
            if i > 0:
                try:
                    data=int(data)
                except:
                    pass
            col[i][1].append(data)
            i += 1
    return pd.DataFrame({title:column for (title, column) in col})


def get_column_headers(tr_elements):
    col = []
    i = 0

    for t in tr_elements[0]:
        i += 1
        name = t.text_content()
        col.append((name,[]))
    return col



def write_to_csv(df, output_file, processed_dir):
    df.to_csv(os.path.join(processed_dir, output_file), index=False)
