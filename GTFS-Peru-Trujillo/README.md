## Introduction

Trufi’s GTFS tool allows you to:

- Generate GTFS data from OSM for the city of Trujillo.
- View route data in a Markdown-based map report.
- Send data to platforms like Google Maps, OTP, and OSM.

---

## Setup Guide

### Prerequisites

Make sure you have the following tools installed:

- [Node.js](https://nodejs.org/en)
- [Git](https://github.com/git-guides/install-git)
- A code editor (recommended: [Visual Studio Code](https://code.visualstudio.com/))

---

### Steps to Generate GTFS

#### Step 1: Clone this repository
```bash
git clone https://github.com/trufi-association/Trujillo-OMUS.git
```
#### Step 2: Navigate to the project folder
```bash
cd Trujillo-OMUS
```
#### Step 3: Install dependencies
```bash
npm install
```
#### Step 4: Run the GTFS generation script
```bash
node ./GTFS-Peru-Trujillo
```
After the script runs:

- A `README.md` file will be generated in the output folder.
- Open it in a [Markdown viewer](https://dillinger.io/) to see your transit map and any errors.

#### Step 5: Locate the output folder
#### Step 6: Compress all files to create your GTFS feed (ZIP format)

---

## Optional: Test Sample Routes

The project includes test routes to explore the output format.

```bash
# Run using example data
node ./GTFS-Peru-Trujillo
```

Then:

1. Open the generated `README.md` inside the output folder.
2. Copy and paste the contents into any [Markdown viewer](https://dillinger.io/).
3. Analyze the route structure and review potential errors.

---

## Customization Options

You can tailor the behavior of the GTFS generator using configuration parameters:

- **`agency_timezone`**  
  Customize your transit agency’s name and timezone.

- **`fakestops`**  
  For informal systems without fixed stops, enable fake stop generation (`true`).  
  Default interval: `100 meters`. You can change this interval.

- **`stop names`**  
  Use `"unknown"` for stops with no name to avoid incorrect values.

- **`return.stops.join`**  
  Control how stop coordinates are connected to street segments.

---

## Useful Links

- [OMUS Live Platform](https://omus.tmt.gob.pe)
- [Trufi Association](https://trufi-association.org/)
- [GTFS Documentation](https://gtfs.org/)
- [OpenStreetMap](https://www.openstreetmap.org/)
