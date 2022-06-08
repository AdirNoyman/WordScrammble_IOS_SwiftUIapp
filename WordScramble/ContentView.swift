//
//  ContentView.swift
//  WordScramble
//
//  Created by אדיר נוימן on 06/06/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
     
    var body: some View {
       
        NavigationView {
            
            List {
                
                Section {
                    
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    
                    ForEach(usedWords, id: \.self) { word in
                        
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                        
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            // When the ContentView has appeared -> start the game!
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                
                Button("OK", role: .cancel) {}
            } message: {
                
                Text(errorMessage)
            }

        }
      
    
        
    }
    
    func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        // Extra validation to come
        guard isOriginalWord(word: answer) else {
            
            wordError(title: "Word used already", message: "Be more original 🤨")
            return
        }
        guard isPossibleWord(word: answer) else {
            
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord) 😩")
            return
        }
        guard isReal(word: answer) else {
            
            wordError(title: "Word not recognized", message: "You can't just make up words 😒")
            return
        }
        
        withAnimation {
            
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        
    }
    
    func startGame() {
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            if let startWords = try? String(contentsOf: startWordsURL) {
                
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        // If file could not be located or corrupt -> kill the app!
        fatalError("Coulde not load start.txt file, from bundle.😫")
        
        
    }
    
    func isOriginalWord(word: String) -> Bool {
        
        !usedWords.contains(word)
    }
    
    func isPossibleWord(word: String) -> Bool {
        
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
    
//    Check if the word the user entered is a real word and not jibrish
    
    func isReal(word: String) -> Bool {
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
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
