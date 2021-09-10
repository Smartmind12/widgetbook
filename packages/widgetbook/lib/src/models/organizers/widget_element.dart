import 'package:widgetbook/src/models/organizers/expandable_organizer.dart';
import 'package:widgetbook/src/models/organizers/organizers.dart';
import 'package:widgetbook/src/models/organizers/story.dart';

///
class WidgetElement extends ExpandableOrganizer {
  // TODO Maybe passing a type makes more sense than passing a name
  // that has the benefit that the WidgetElement's name will change when the
  // class name changes
  //
  // This could be avoided alltogether by using annotations
  final List<Story> stories;

  WidgetElement({
    required String name,
    required this.stories,
  }) : super(
          name: name,
        ) {
    for (final Story state in stories) {
      state.parent = this;
    }
  }
}
