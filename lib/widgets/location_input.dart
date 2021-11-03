import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../helpers/location_helper.dart';
import '../screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;

  LocationInput(this.onSelectPlace);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;

  void _showPreview(double lat, double lng) {
    final staicMapImageUrl = LocationHelper.generateLocationPreviewImage(
      latitude: lat,
      longitude: lng,
    );

    setState(() {
      _previewImageUrl = staicMapImageUrl;
    });
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      final locData =
          await Location().getLocation(); //from the location package
      _showPreview(locData.latitude, locData.longitude);

      //to pass the data to the add_place_screen widget
      widget.onSelectPlace(locData.latitude, locData.longitude);
    } catch (error) {
      return;
    }
    // print(locData.latitude);
    // print(locData.longitude);

    //following code is moved to _showPreview to remove code duplication
    // final staicMapImageUrl = LocationHelper.generateLocationPreviewImage(
    //     latitude: locData.latitude, longitude: locData.longitude);

    // setState(() {
    //   _previewImageUrl = staicMapImageUrl;
    // });
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
    _showPreview(selectedLocation.latitude, selectedLocation.longitude);
    //to pass the data to the add_place_screen widget
    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);

    //check when you select any location on map
    //print(selectedLocation.latitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _previewImageUrl == null
              ? Text(
                  'No Location Chosen',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
                icon: Icon(Icons.location_on),
                label: Text('Current Location'),
                style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                onPressed: _getCurrentUserLocation),
            TextButton.icon(
                icon: Icon(Icons.map),
                label: Text('Select on map'),
                style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                onPressed: _selectOnMap),
          ],
        ),
      ],
    );
  }
}
