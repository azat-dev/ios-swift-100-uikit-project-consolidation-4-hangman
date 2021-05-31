//
//  ViewController.swift
//  Hangman
//
//  Created by Azat Kaiumov on 30.05.2021.
//

import UIKit

class RoundedNumber: UIView {
    var valueLabel: UILabel!
    var value = 0 {
        didSet {
            valueLabel.text = String(value)
        }
    }
    
    private func setupView() {
        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textAlignment = .center
        
        valueLabel.font = UIFont.prefferedFont(for: .title2, weight: .bold)
        valueLabel.adjustsFontForContentSizeCategory = true
        value = 0
        
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2
        layer.borderColor = UIColor(named: "RoundedNumberBorderColor")!.cgColor
        layer.cornerRadius = 21
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),
            widthAnchor.constraint(equalToConstant: 68),
            
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
}

class ViewController: UIViewController {
    
    var currentText: UILabel!
    var wrongTriesLabel: RoundedNumber!
    var roundLabel: RoundedNumber!
    var scoreLabel: RoundedNumber!
    
    var words = [String]()
    var word = ""
    var openedCharacters = [Character]()
    var score = 0 {
        didSet {
            scoreLabel.value = score
        }
    }
    
    var round = 0 {
        didSet {
            roundLabel.value = round
        }
    }
    
    var wrongTries = 0 {
        didSet {
            wrongTriesLabel.value = wrongTries
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
    
    func getRoundedViewTitle(text: String) -> UILabel {
        let roundTitle = UILabel()
        roundTitle.text = text
        roundTitle.font = UIFont.prefferedFont(for: .caption2, weight: .semibold)
        roundTitle.adjustsFontForContentSizeCategory = true
        roundTitle.translatesAutoresizingMaskIntoConstraints = false
        
        return roundTitle
    }
    
    @objc func resetButtonTapped() {
        openedCharacters = []
        wrongTries = 0
        round = 0
        score = 0
        
        startNewRound()
    }
    
    func initCornerViews() {
        let resetButtonTitle = getRoundedViewTitle(text: "RESET")
        view.addSubview(resetButtonTitle)
        
        let resetButton = UIButton(type: .system)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setImage(.init(systemName: "arrow.clockwise"), for: .normal)
        resetButton.layer.borderWidth = 2
        resetButton.layer.borderColor = UIColor(named: "RoundedNumberBorderColor")!.cgColor
        resetButton.layer.cornerRadius = 21
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        view.addSubview(resetButton)
        
        let triesTitle = getRoundedViewTitle(text: "WRONG TRIES")
        view.addSubview(triesTitle)
        
        wrongTriesLabel = RoundedNumber()
        wrongTriesLabel.translatesAutoresizingMaskIntoConstraints = false
        wrongTries = 0
        view.addSubview(wrongTriesLabel)
        
        let roundTitle = getRoundedViewTitle(text: "ROUND")
        view.addSubview(roundTitle)
        
        roundLabel = RoundedNumber()
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundLabel)
        
        let scoreTitle = getRoundedViewTitle(text: "SCORE")
        view.addSubview(scoreTitle)
        
        scoreLabel = RoundedNumber()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        
        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 15),
            resetButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 35),
            
            resetButton.widthAnchor.constraint(equalTo: roundLabel.widthAnchor),
            resetButton.heightAnchor.constraint(equalTo: roundLabel.heightAnchor),
            
            resetButtonTitle.centerXAnchor.constraint(equalTo: resetButton.centerXAnchor),
            resetButtonTitle.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -5),
            
            wrongTriesLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 35),
            wrongTriesLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -15),
            
            triesTitle.bottomAnchor.constraint(equalTo: wrongTriesLabel.topAnchor, constant: -5),
            triesTitle.centerXAnchor.constraint(equalTo: wrongTriesLabel.centerXAnchor),
            
            roundLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -15),
            roundLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -15),
            
            roundTitle.bottomAnchor.constraint(equalTo: roundLabel.topAnchor, constant: -5),
            roundTitle.centerXAnchor.constraint(equalTo: roundLabel.centerXAnchor),
            
            scoreLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -15),
            scoreLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 15),
            
            scoreTitle.bottomAnchor.constraint(equalTo: scoreLabel.topAnchor, constant: -5),
            scoreTitle.centerXAnchor.constraint(equalTo: scoreLabel.centerXAnchor),
        ])
    }
    
    func initCentralViews() {
        let centralGroup = UIStackView()
        centralGroup.axis = .vertical
        centralGroup.alignment = .center
        centralGroup.distribution = .equalSpacing
        centralGroup.spacing = 60
        centralGroup.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centralGroup)
        
        currentText = UILabel()
        currentText.translatesAutoresizingMaskIntoConstraints = false
        currentText.font = UIFont.prefferedFont(for: .largeTitle, weight: .bold)
        currentText.adjustsFontForContentSizeCategory = true
        currentText.text = "??????????"
        currentText.isUserInteractionEnabled = false
        currentText.textAlignment = .center
        centralGroup.addArrangedSubview(currentText)

        let guessButton = UIButton(type: .system)
        guessButton.translatesAutoresizingMaskIntoConstraints = false
        guessButton.titleLabel?.textAlignment = .center
        guessButton.setTitle("Guess the Letter".uppercased(), for: .normal)
        guessButton.addTarget(self, action: #selector(guessButtonTapped), for: .touchUpInside)
        guessButton.backgroundColor = UIColor(named: "GuessButtonColor")
        guessButton.layer.cornerRadius = 21
        guessButton.setTitleColor(.white, for: .normal)
        guessButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        guessButton.titleLabel?.adjustsFontForContentSizeCategory = true
        centralGroup.addArrangedSubview(guessButton)

    
        NSLayoutConstraint.activate([
            guessButton.titleLabel!.leadingAnchor.constraint(equalTo: guessButton.leadingAnchor, constant: 24),
            guessButton.titleLabel!.trailingAnchor.constraint(equalTo: guessButton.trailingAnchor, constant: -24),
            guessButton.titleLabel!.topAnchor.constraint(equalTo: guessButton.topAnchor, constant: 22),
            guessButton.titleLabel!.bottomAnchor.constraint(equalTo: guessButton.bottomAnchor, constant: -22),
            
            centralGroup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centralGroup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func initViews() {
        view = UIView()
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        initCornerViews()
        initCentralViews()
    }
    
    func showErrorAlert(text: String) {
        let alert = UIAlertController(
            title: "Wrong",
            message: text,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Continue", style: .cancel))
        
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
        wrongTries += 1
        
        guard !openedCharacters.contains(character) else {
            score -= 1
            showErrorAlert(text: "The character \"\(character.uppercased())\" was opened before")
            return
        }
        
        guard word.contains(character) else {
            score -= 1
            showErrorAlert(text: "The word doesn't contain the character: \"\(character.uppercased())\"")
            return
        }
        
        if wrongTries == 7 {
            showErrorAlert(text: "You are ded");
            return
        }
        
        score += 1
        openedCharacters.append(character)
        let textWithPlaceholders = getWordWithPlaceholders()
        currentText.text = textWithPlaceholders
        
        let isWordCompleted = !textWithPlaceholders.contains("?")
        
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

