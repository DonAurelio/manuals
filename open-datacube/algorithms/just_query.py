import datacube

def query_datacube(product,latitude,longitude,time,measurements):
    """ Perform a query using the OpenDatacube API.
        
        Example:
            product="LS8_OLI_LASRC", 
            longitude=(-73, -72), 
            latitude=(8,9),
            # Time format YYYY-MM-DD
            time=("2019-05-01","2019-05-30"), 
            measurements=['blue','green','red','swir1','swir2']
    """

    dc = datacube.Datacube(app="Query")

    xarr = dc.load(
        product=product, 
        longitude=longitude, 
        latitude=latitude,
        # Time format YYYY-MM-DD
        time=time, 
        measurements=measurements
    )

    return xarr