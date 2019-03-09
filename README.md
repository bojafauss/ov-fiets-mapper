# ov-fiets-mapper

Get data from the NS nl API and compile them to track the availability of ov-fiets and train traffic.

This repository containes a small personal project.
The aim is to retrieve data from the ns.nl APIs `https://developer.ns.nl/index.html` about the availability of ov-fiets at different stations in Rotterdam, as well as the related train traffic (incoming and leaving).

Results are stored in a sqlite database and furhter used to visualize the outcome in a small shiny app.

Credentials are in a yaml file, which is conveniently added to the `gitignore`

