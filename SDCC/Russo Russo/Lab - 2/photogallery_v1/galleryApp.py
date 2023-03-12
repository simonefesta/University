from flask import Flask
from flask import render_template
from flask import request

import tempfile
import random
import socket # for the hostname

app = Flask(__name__)

# TODO Images should be listed dynamically...
def get_all_images():
    paths = ["https://www.w3schools.com/w3images/underwater.jpg",\
        "https://www.w3schools.com/w3images/ocean.jpg",\
        "https://www.w3schools.com/w3images/wedding.jpg",\
        "https://www.w3schools.com/w3images/mountainskies.jpg",\
        "https://www.w3schools.com/w3images/rocks.jpg",\
        "https://www.w3schools.com/w3images/underwater.jpg",\
        "https://www.w3schools.com/w3images/wedding.jpg",\
        "https://www.w3schools.com/w3images/rocks.jpg",\
        "https://www.w3schools.com/w3images/falls2.jpg",\
        "https://www.w3schools.com/w3images/paris.jpg",\
        "https://www.w3schools.com/w3images/nature.jpg",\
        "https://www.w3schools.com/w3images/mist.jpg",\
        "https://www.w3schools.com/w3images/paris.jpg"]

    random.shuffle(paths)
    return paths

@app.route('/newpost', methods=['GET', 'POST'])
def upload_image():
    return render_template('newpost.html', msg='Operation not supported yet ({})'.format(socket.gethostname()))

def images_in_columns(images):
    columns = [[], [], []]
    column_index = 0
    for img in images:
        columns[column_index].append(img)
        column_index = (column_index + 1) % 3
    return columns

@app.route('/')
def home():
    # list images to be displayed
    all_images = get_all_images()
    
    columns = images_in_columns(all_images)
    return render_template('home.html', images1=columns[0], images2=columns[1], images3=columns[2])

