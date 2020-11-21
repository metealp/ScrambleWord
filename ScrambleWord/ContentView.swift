//
//  ContentView.swift
//  ScrambleWord
//
//  Created by Mete Alp Kizilcay on 19.10.2020.
//

//another hacking with swift tutor app
//"www.hackingwithswift.com/books/ios-swiftui/validating-words-with-uitextchecker"

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score: Int = 0
    
    var body: some View {
        NavigationView {
                VStack {
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    List(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibility(label: Text("\(word), \(word.count) letters"))
                    }
                    
                    Text("Score: \(score)")
                }
                .navigationBarTitle(rootWord)
                .onAppear(perform: startGame)
                .alert(isPresented: $showingError) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                .navigationBarItems(leading: Button("Plag again", action: startGame))
            }
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }

        // extra validation to come
        guard isOriginal(word: answer) else {
            self.wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        
        guard isTooShort(word: answer) else {
            self.wordError(title: "Word is too short", message: "Your word's length should be equal or greater than 3!")
            return
        }
        
        
        guard isIdentical(word: answer) else {
            self.wordError(title: "Really?", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            self.wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            self.wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        score += answer.count
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isIdentical(word: String) -> Bool {
        if word == rootWord {
            return false
        }
        return true
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func isTooShort(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
