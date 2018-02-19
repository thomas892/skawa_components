import 'dart:async';
import 'package:angular2/angular2.dart';

import 'package:angular_components/src/components/glyph/glyph.dart';
import 'package:angular_components/src/components/material_button/material_button.dart';

@Component(
    selector: 'rating-star',
    templateUrl: 'rating_star.html',
    styleUrls: const ['rating_star.css'],
    directives: const [GlyphComponent, NgIf, NgFor, MaterialButtonComponent],
    changeDetection: ChangeDetectionStrategy.OnPush,
    preserveWhitespace: false)
class RatingStarComponent implements OnInit, OnDestroy {
  final _changeController = new StreamController<int>.broadcast();

  List<Star> ratingStars = [new Star(), new Star(), new Star(), new Star(), new Star()];

  double _roundingLowerLimit = 0.4;
  double _roundingUpperLimit = 0.7;

  int outScore = 0;

  bool ready = false;

  @Input()
  bool editMode = true;

  @Input()
  double score;

  @Output("change")
  Stream get onChange => _changeController.stream;

  @override
  void ngOnInit() {
    editMode ? null : displayScore(score);
  }

  @override
  void ngOnDestroy() {
    _changeController.close();
  }

  void pushed(Star clickedStar) {
    int index = ratingStars.indexOf(clickedStar) + 1;
    outScore = index;
    setSelected(outScore);
    _changeController.add(outScore);
  }

  void over(Star hoveredStar) {
    setSelected(outScore);
    int index = ratingStars.indexOf(hoveredStar);
    if (index < outScore) {
      ratingStars.skip(index).forEach((star) => star.setHover(true));
      ratingStars.skip(outScore).forEach((star) => star.setSelected(false));
    } else {
      ratingStars.skip(outScore).forEach((star) => star.setHover(true));
      ratingStars..skipWhile((star) => star != hoveredStar).forEach((star) => star.setSelected(false));
      ratingStars.firstWhere((star) => star == hoveredStar).setHover(true);
    }
  }

  void leaveAll() {
    setSelected(outScore);
  }

  void setSelected(int i) {
    ratingStars.take(i).forEach((star) => star.setSelected(true));
    ratingStars.skip(i).forEach((star) => star.setSelected(false));
  }

  void displayScore(double score) {
    score = _transformDouble(score);
    int i = 0;
    while (score > 0) {
      ratingStars[i].setSelected(true);
      if (score < 1) {
        ratingStars[i].setType(false);
        break;
      } else {
        score -= 1;
      }
      i++;
    }
  }

  double _transformDouble(double score) {
    if (score != null) {
      double remainder = score.remainder(score.floor());
      if (remainder < _roundingUpperLimit && remainder > _roundingLowerLimit) return (score.floor() + 0.5);
      return score.roundToDouble();
    }
    return 0.0;
  }
}

class Star {
  static const String FULLSTAR = "star";
  static const String HALFSTAR = "star_half";

  static const String UNSELECTEDCOLOR = "unselected-star-color";
  static const String SELECTEDCOLOR = "selected-star-color";
  static const String HOVERCOLOR = "hover-star-color";

  String starIconType;
  String state;

  Star() {
    starIconType = FULLSTAR;
    state = UNSELECTEDCOLOR;
  }

  void setType(bool isFull) {
    starIconType = isFull ? FULLSTAR : HALFSTAR;
  }

  void setSelected(bool isSelected) {
    state = isSelected ? SELECTEDCOLOR : UNSELECTEDCOLOR;
  }

  void setHover(bool isHovered) {
    state = isHovered ? HOVERCOLOR : UNSELECTEDCOLOR;
  }
}
