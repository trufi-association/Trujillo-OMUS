const { osmToGtfs, OSMOverpassDownloader } = require('trufi-gtfs-builder')

osmToGtfs({
    outputFiles: { outputDir: __dirname + '/out', trufiTPData: true, gtfs: true, },
    geojsonOptions: {
        // westlimit=-79.147846; southlimit=-8.235272; eastlimit=-78.858357; northlimit=-7.995994
        osmDataGetter: new OSMOverpassDownloader({
            south: -8.235272,
            west: -79.147846,
            north: -7.995994,
            east: -78.858357,
        }), skipRoute: (route) => {
            return ![].includes(route.id)
        }
    }, gtfsOptions: {
        agencyTimezone: "America/Lima",
        fakeStops: (routeFeature) => [].includes(routeFeature.properties.id),
        vehicleSpeed: (routeFeature) => {
            if (routeFeature?.properties?.distance != null && routeFeature?.properties?.duration != null) {
                let distance = parseFloat(routeFeature.properties.distance);
                let duration = parseFloat(routeFeature.properties.duration) / 60;
                return distance / duration
            } else {
                return 15;
            }
        },
        frequencyHeadway: (routeFeature) => {
            if (routeFeature?.properties?.interval != null) {
                let interval = parseInt(routeFeature.properties.interval) * 60;
                return interval
            } else {
                return 300;
            }

        },
        stopNameBuilder: (stops) => {
            if (!stops || stops.length == 0) {
                stops = ["innominada"]
            }
            return stops.join(" y ")
        },
    }
}).catch(error => console.error(error))
