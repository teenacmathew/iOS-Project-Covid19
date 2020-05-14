//
//  AssesmentViewController.swift
//  TeenaMathewFinalExam
//
//  Created by Student on 2020-04-20.
//  Copyright © 2020 Teena. All rights reserved.
//

import UIKit

struct Question {
    var Question : String!
    var Answers : [String]!
    //var Answer : Int!
}

class AssesmentViewController: UIViewController {

    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var textQuestion: UITextView!
    
    @IBOutlet var buttonAnswer1: [UIButton]!
    
    var questions = [Question]()
    
    var questionNumber = Int()
    
    var score : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
        setQuestions()
        pickQuestion()
    }
    
    func setQuestions() {
        questions = [Question(Question : "Question : Are you experiencing any severe difficulty breathing (struggling for each breath, can only speak in single words) ?", Answers: ["1","2","3","4","5"]),
                            Question(Question : "Question : Are you experiencing any severe chest pain (constant tightness or crushing sensation) ?", Answers: ["1","2","3","4","5"]),
                            Question(Question : "Question : Are you experiencing any feeling confused(for example, unsure of where you are)", Answers: ["1","2","3","4","5"]),
                            Question(Question : "Question : Are you experiencing any losing consciousness?", Answers: ["1","2","3","4","5"])
               ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pickQuestion(){
        if(questions.count > 0) {
            questionNumber = 0
            textQuestion.text = questions[questionNumber].Question
            for i in 0..<4{
                buttonAnswer1[i].setTitle(questions[questionNumber].Answers[i] , for: UIControl.State.normal)
            }
            questions.remove(at: questionNumber)
        }
        else {

            
            if(score > 10 ) {

            let alert = UIAlertController(title: "COVID-19 self-assessment result", message: "Call 911 or go directly to your nearest emergency department.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "COVID-19 self-assessment result", message: "Please be safe and self-isolate as precaution. You are at safe zone.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            
            loadView()
            setQuestions()
            pickQuestion()
            score = 0
            
        }
        
    }
    
    
    @IBAction func answerOne(_ sender: Any) {
        score = score + 1
         pickQuestion()
    }
    
    @IBAction func answerTwo(_ sender: Any) {
        score = score + 2
         pickQuestion()
    }
    
    @IBAction func answerThree(_ sender: Any) {
        score = score + 3
         pickQuestion()
    }
    
    @IBAction func answerFour(_ sender: Any) {
        score = score + 4
         pickQuestion()
    }
    
    
    @IBAction func answerFive(_ sender: Any) {
        score = score + 5
         pickQuestion()
    }
    
}
