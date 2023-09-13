import 'package:favourite_places/providers/user_places.dart';
import 'package:favourite_places/screens/places_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place.dart';

class PlacesList extends ConsumerStatefulWidget {
  const PlacesList({super.key, required this.places});
  final List<Place> places;

  @override
  ConsumerState<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends ConsumerState<PlacesList> {
  @override
  Widget build(BuildContext context) {
    return (widget.places.isEmpty)
        ? Center(
            child: Text(
              'No Places Added!',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onBackground),
            ),
          )
        : ListView.builder(
            itemCount: widget.places.length,
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: FileImage(widget.places[index].image),
              ),
              title: Text(
                widget.places[index].title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              subtitle: Text(
                widget.places[index].location.address,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) =>
                      PlaceDetailScreen(place: widget.places[index]),
                ));
              },
              // Extra feature added apart from what is shown in course
              // Deleting an added place which updates the database and list
              onLongPress: () {
                ref
                    .read(userPlacesProvider.notifier)
                    .removePlace(widget.places[index]);
              },
            ),
          );
  }
}
