//
//  ViewController.swift
//  Hangman
//
//  Created by Azat Kaiumov on 30.05.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var currentText: UITextField!
    var triesLabel: UILabel!
    var roundLabel: UILabel!
    
    var words = [String]()
    var word = ""
    var openedCharacters = [Character]()
    
    var round = -1
    
    var tries = 0 {
        didSet {
            triesLabel.text = "Tries: \(tries)"
        }
    }
    
    func startNewRound() {
        guard let randomWord = words.randomElement()?.lowercased() else {
            return
        }
        
        round += 1
        word = randomWord
        currentText.text = getWordWithPlaceholders()
    }
    
    func loadWords() {
        guard let url = Bundle.main.url(forResource: "nouns", withExtension: "json") else {
            return
        }
        
        guard let rawData = try? Data(contentsOf: url) else {
            return
        }
        
        if let nounsData = Nouns(json: rawData) {
            words = nounsData.nouns
        }
        
        DispatchQueue.main.async {
            self.startNewRound()
        }
    }
    
    func initViews() {
        view = UIView()
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        triesLabel = UILabel()
        triesLabel.translatesAutoresizingMaskIntoConstraints = false
        triesLabel.font = .systemFont(ofSize: 20)
        triesLabel.textAlignment = .center
        tries = 0
        view.addSubview(triesLabel)
        
        currentText = UITextField()
        currentText.translatesAutoresizingMaskIntoConstraints = false
        currentText.font = .systemFont(ofSize: 44)
        currentText.placeholder = "??????????"
        currentText.isUserInteractionEnabled = false
        currentText.textAlignment = .center
        view.addSubview(currentText)
        
        let guessButton = UIButton(type: .system)
        guessButton.translatesAutoresizingMaskIntoConstraints = false
        guessButton.titleLabel?.textAlignment = .center
        guessButton.setTitle("Guess the Letter", for: .normal)
        guessButton.addTarget(self, action: #selector(guessButtonTapped), for: .touchUpInside)
        view.addSubview(guessButton)
        
        
        NSLayoutConstraint.activate([
            triesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            triesLabel.bottomAnchor.constraint(equalTo: currentText.topAnchor, constant: -20),
            
            currentText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentText.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            guessButton.topAnchor.constraint(equalTo: currentText.bottomAnchor, constant: 20),
            guessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guessButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func showErrorAlert(text: String) {
        let alert = UIAlertController(
            title: "Wrong",
            message: text,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func getWordWithPlaceholders() -> String {
        var text = ""
        for character in word {
            if openedCharacters.contains(character) {
                text += String(character)
            } else {
                text += "?"
            }
        }
        
        return text.uppercased()
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Keep going!",
            preferredStyle: .alert
        )
        
        let continueButton = UIAlertAction(title: "Continue", style: .default) {
            [weak self] _ in
            self?.startNewRound()
        }
        
        alert.addAction(continueButton)
        present(alert, animated: true)
    }
    
    func submitCharacter(character: Character) {
        tries += 1
        
        guard !openedCharacters.contains(character) else {
            showErrorAlert(text: "The character \"\(character.uppercased())\" was opened before")
            return
        }
        
        guard word.contains(character) else {
            showErrorAlert(text: "The word doesn't contain the character: \"\(character.uppercased())\"")
            return
        }
        
        openedCharacters.append(character)
        currentText.text = getWordWithPlaceholders()
        
        let isWordCompleted = false
        
        if !isWordCompleted {
            return
        }
        
        words.removeAll { $0.lowercased() == word }
        showSuccessAlert()
    }
    
    @objc func guessButtonTapped() {
        let alert = UIAlertController(
            title: "Guess the letter",
            message: "Type one letter",
            preferredStyle: .alert
        )
        
        alert.addTextField()
        alert.textFields?[0].textAlignment = .center
        
        let submitButton = UIAlertAction(title: "Submit", style: .default) { [weak alert, weak self] _ in
            guard let text = alert?.textFields?[0].text else {
                return
            }
            
            if text.count == 0 {
                return
            }
            
            if text.count > 1 {
                return
            }
            
            self?.submitCharacter(character: text.lowercased().first!)
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(submitButton)
        
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Hangman"
        initViews()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadWords()
        }
    }
}

