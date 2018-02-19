@Tags(const ['aot'])
@TestOn('browser')
import 'dart:async';
import 'dart:html';
import 'package:angular2/angular2.dart';
import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';
import 'package:skawa_components/src/components/rating_star/rating_star.dart';
import 'package:pageloader/html.dart';
import 'package:pageloader/src/annotations.dart';

@AngularEntrypoint()
void main() {
  tearDown(disposeAnyRunningTest);
  group('Rating star |', () {
    test('initializing', () async {
      final bed = await new NgTestBed<RatingStarTestComponent>();
      final fixture = await bed.create();
      final pageObject = await fixture.resolvePageObject(TestPO);
      expect(pageObject.ratingStar, isNotNull);
    });
    test('shows score correctly', () async {
      final bed = await new NgTestBed<RatingStarTestComponent>();
      final fixture = await bed.create(
          beforeChangeDetection: (RatingStarTestComponent testComponent) {
            testComponent.score = 2.6;
            testComponent.editMode = false;
          });
      final pageObject = await fixture.resolvePageObject(TestPO);
      List<PageLoaderElement> starSpans = await pageObject.ratingStar.nonModifiableStarSpans;
      List<PageLoaderElement> starIcons = await pageObject.ratingStar.nonModifiableStarIcons;
      List<String> starTypes = new List<String>();
      for (var i = 0; i < 5; i++) {
        starTypes.add(await starIcons[i].innerText);
      }
      expect(starSpans[0].classes, mayEmit('selected-star-color'));
      expect(starSpans[1].classes, mayEmit('selected-star-color'));
      expect(starSpans[2].classes, mayEmit('selected-star-color'));
      expect(starSpans[3].classes, mayEmit('unselected-star-color'));
      expect(starSpans[4].classes, mayEmit('unselected-star-color'));
      expect(starTypes[0], 'star');
      expect(starTypes[1], 'star');
      expect(starTypes[2], 'star_half');
      expect(starTypes[3], 'star');
      expect(starTypes[4], 'star');
    });
    test('on hover', () async {
      final bed = await new NgTestBed<RatingStarTestComponent>();
      final fixture = await bed.create();
      final pageObject = await fixture.resolvePageObject(TestPO);
      await pageObject.ratingStar.buttons[1].focus();
      expect(pageObject.ratingStar.buttons[0].classes, mayEmit('selected-star-color'));
      expect(pageObject.ratingStar.buttons[1].classes, mayEmit('selected-star-color'));
      expect(pageObject.ratingStar.buttons[2].classes, mayEmit('unselected-star-color'));
      expect(pageObject.ratingStar.buttons[3].classes, mayEmit('unselected-star-color'));
      expect(pageObject.ratingStar.buttons[4].classes, mayEmit('unselected-star-color'));
    });
    test('onChange callback', () async {
      final bed = await new NgTestBed<RatingStarTestComponent>();
      final fixture = await bed.create();
      final pageObject = await fixture.resolvePageObject(TestPO);
      await pageObject.ratingStar.buttons[2].click();
      await fixture.update();
      var msgText = await pageObject.message.innerText;
      expect(msgText, '3');
    });
  });
}

@Component(
  selector: 'test',
  directives: const [RatingStarComponent],
  template: r'''
  <rating-star [editMode]="editMode" [score]="score" (change)="changeText($event)"></rating-star>
  <p #message></p>
  ''',
  changeDetection: ChangeDetectionStrategy.OnPush)
class RatingStarTestComponent {

  @ViewChild('message')
  ElementRef message;

  void changeText(int score) => (message.nativeElement as Element).innerHtml = score.toString();

  bool editMode = true;

  double score = 3.0;
}

@EnsureTag('test')
class TestPO {
  @ByTagName('rating-star')
  RatingStarPO ratingStar;

  @ByTagName('p')
  PageLoaderElement message;
}

class RatingStarPO {
  @root
  PageLoaderElement rootElement;

  @ByCss('span glyph')
  List<PageLoaderElement> nonModifiableStarSpans;

  @ByCss('span glyph i')
  List<PageLoaderElement> nonModifiableStarIcons;

  @ByTagName('material-button')
  List<PageLoaderElement> buttons;

  @optional
  @ByCss('span:only-child')
  PageLoaderElement starContainer;
}