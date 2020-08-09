# Virtual Tour App

## Purpose

This app is meant to make college campuses more accessible for people due to covid19, out of state students, or students with disabilities. Through this project I learned about: the dart programming language, Flutter, UI layouts, asynchronous programming, and noSQL databases.

## Overview

The homescreen prompts users to select a school to 'tour'. The options for this list are loaded from the firestore database.

After selecting a campus, users see the campus with markers for the notable locations using the Google Maps API. Users can zoom in and out using gestures or the buttons

Tapping on a marker will bring up a pop-up with an image and the name of the locaiton.

Tapping the pop-up will bring the user to the information page for that location. There they see an image, description, and details about the location. Buttons are also there for the future when 360° images are available.
