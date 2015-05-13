//
//  QuestionViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 07/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "QuestionViewController.h"
#import "QuestionAnswersCollectionViewCell.h"
#import "ClassifyViewControllerDelegate.h"
#import "AppDelegate.h"
#import "DecisionTree.h"
#import "DecisionTreeQuestionAnswer.h"
#import "ZooniverseModel/ZooniverseClassification.h"
#import "ZooniverseModel/ZooniverseClassificationAnswer.h"
#import "ZooniverseModel/ZooniverseSubject.h"

#import "Singleton.h"


#import <RestKit/RestKit.h>

const NSInteger MAX_BUTTONS_PER_ROW = 4;

@interface QuestionViewController () {
    ZooniverseClassification *_classificationInProgress;
    __weak IBOutlet UISwitch *switchFavorite;
}

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewAnswers;

@end

@implementation QuestionViewController

- (void)initClassificationInProgress {
    //NSManagedObjects don't work (property setters don't work, for instance)
    //if they are just created with init:
    //  _classificationInProgress = [[ZooniverseClassification alloc] init];
    // and when we generate the classes, we don't have an init anyway.
    //
    //Note: This will be saved to the model, so we should remove it later if necessary:
    _classificationInProgress =
    (ZooniverseClassification *)[NSEntityDescription insertNewObjectForEntityForName:@"ZooniverseClassification"
                                                              inManagedObjectContext:[self managedObjectContext]];
}

- (void)clearFavorite {
    //Clear the favorite switch:
    [switchFavorite setOn:NO
                 animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UINib *cellNib = [UINib nibWithNibName:@"AnswerCellView" bundle:nil];
    [self.collectionViewAnswers registerNib:cellNib forCellWithReuseIdentifier:@"answerCell"];
    self.collectionViewAnswers.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self clearFavorite];

    [self initClassificationInProgress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    self.labelTitle.text = _question.title;
    self.labelText.text = _question.text;
    self.collectionViewAnswers.dataSource = self;
    [self.collectionViewAnswers reloadData];
}

- (void)setQuestion:(DecisionTreeQuestion *)question {
    _question = question;

    [self updateUI];
}

- (DecisionTree *)getDecisionTree {
    Singleton *singleton = [Singleton sharedSingleton];
    return [singleton getDecisionTree:self.subject.groupId];
}

- (void)showNextQuestion:(NSString *)questionId answerId:(NSString *)answerId {


    DecisionTree *decisionTree = [self getDecisionTree];
    _question =[decisionTree getNextQuestion:questionId
                                   forAnswer:answerId];
    if (_question == nil) {
        [self saveClassification];
        _question = [decisionTree getQuestion:decisionTree.firstQuestionId];

        [self clearFavorite];
    }

    [self updateUI];
}

- (void)saveClassification {
    self.subject.classification = _classificationInProgress;
    self.subject.favorite = switchFavorite.on;
    self.subject.done = YES;

    //Save the ZooniverseClassification and the Subject to disk:
    //TODO: This doesn't seem to work: We still get the same subject next time, though we have marked this one as done.
    NSError *error = nil;
    [[self managedObjectContext] save:&error];  //saves the context to disk


    //Tell the parent ViewController to start another subject:
    UIViewController <ClassifyViewControllerDelegate> *parent = (UIViewController <ClassifyViewControllerDelegate> *)self.parentViewController;
    [parent onClassificationFinished];

    [self initClassificationInProgress];
}

- (NSManagedObjectContext*)managedObjectContext {
    return [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectModel;
}

-(void)onAnswerButtonClick:(UIView*)clickedButton
{
    NSInteger i = clickedButton.tag;

    DecisionTreeQuestionAnswer *answer = [_question.answers objectAtIndex:i];
    NSLog(@"Answer clicked:%@", answer.text);

    ZooniverseClassificationAnswer *classificationAnswer = (ZooniverseClassificationAnswer *)[NSEntityDescription insertNewObjectForEntityForName:@"ZooniverseClassificationAnswer"
                 inManagedObjectContext:[self managedObjectContext]];
    classificationAnswer.questionId = _question.questionId;
    classificationAnswer.answerId = answer.answerId;

    //TODO: Checkboxes.

    // This results in an exception:
    // "'NSInvalidArgumentException', reason: '*** -[NSSet intersectsSet:]: set argument is not an NSSet'"
    // apparently because NSOrderedSet is not derived from NSSet.
    // This seems to be a well-known problem with ordered to-many relationships in Core Data.
    // See http://stackoverflow.com/questions/15993619/coredata-to-many-add-error
    // and http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    //[_classificationInProgress addAnswersObject:classificationAnswer];
    //This is the simple workaround:
    classificationAnswer.classification = _classificationInProgress;

    [self showNextQuestion:_question.questionId
                  answerId:answer.answerId];
}

#pragma mark - UICollectionView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfSectionsInCollectionView:(NSInteger)section {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _question.answers.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"answerCell";

    UICollectionViewCell *cellBase = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cellBase.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    QuestionAnswersCollectionViewCell *cell = (QuestionAnswersCollectionViewCell *)cellBase;

    UIButton *button = cell.button;

    NSInteger i = [indexPath indexAtPosition:0] * MAX_BUTTONS_PER_ROW + [indexPath indexAtPosition:1];
    DecisionTreeQuestionAnswer *answer = [_question.answers objectAtIndex:i];
    [button setTitle:answer.text
     forState:UIControlStateNormal];

    //TODO: Move the adding of the icon_ prefix into a reusable method.
    NSString *filenameIcon = [NSString stringWithFormat:@"icon_%@", answer.icon, nil];
    UIImage *image = [UIImage imageNamed:filenameIcon];
    //[button setImage:image
    //        forState:UIControlStateNormal];
    [button setBackgroundImage:image
            forState:UIControlStateNormal];

    //Respond to button touches:
    button.tag = i; //So we know which button was clicked.
    [button addTarget:self
               action:@selector(onAnswerButtonClick:)
     forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
