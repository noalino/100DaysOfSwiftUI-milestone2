//
//  ContentView.swift
//  MultiplicationTables
//
//  Created by Noalino on 15/11/2023.
//

import SwiftUI

enum GameState {
    case inactive, started, ended
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: opacity),
            removal: .move(edge: .top).combined(with: opacity)
        )
    }
}

struct SettingsView: View {
    @Binding var maxTableUnit: Int
    @Binding var questionsAmount: Int

    let questionsAmounts = [5, 10, 20]
    let startGame: () -> Void

    var body: some View {
        VStack {
            Form {
                Section("Multiplication tables") {
                    Stepper("Up to \(maxTableUnit)", value: $maxTableUnit, in: 2...12, step: 1)
                }

                Section("How many questions?") {
                    Picker("Number of questions to answer", selection: $questionsAmount) {
                        ForEach(questionsAmounts, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            Button("Start") {
                startGame()
            }
            .font(.title)
        }
        .navigationTitle("Multiplication Tables")
    }
}

struct GameView: View {
    @FocusState private var answerIsFocused: Bool
    @Binding var answer: Int

    let questions: [(Int, Int)]
    let currentQuestion: Int
    let validateAnswer: () -> Void
    let quitGame: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [.yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 50) {
                Spacer()

                HStack(spacing: 0) {
                    Text("What is ")

                    HStack {
                        Text("\(questions[currentQuestion].0)")
                            .transition(.moveAndFade)
                            .id("\(questions[currentQuestion].0)-\(currentQuestion)")
                    }
                    .clipped()
                    .animation(.easeInOut, value: currentQuestion)

                    Text(" x ")

                    HStack {
                        Text("\(questions[currentQuestion].1)")
                            .transition(.moveAndFade)
                            .id("\(questions[currentQuestion].1)-\(currentQuestion)")
                    }
                    .animation(.easeInOut.delay(0.1), value: currentQuestion)
                    .clipped()

                    Text("?")
                }
                .fontWeight(.semibold)

                TextField("Answer", value: $answer, format: .number)
                    .multilineTextAlignment(.center)
                    .padding()
                    .keyboardType(.numberPad)
                    .focused($answerIsFocused)

                Button("VALIDATE") {
                    answerIsFocused = false
                    validateAnswer()
                }
                .font(.title)
                .padding()
                .foregroundColor(.white)
                .background(.red)
                .clipShape(.rect(cornerRadius: 10))

                Spacer()
                Spacer()
                Spacer()
            }
            .font(.largeTitle)
            .padding()
            .navigationTitle("Question \(currentQuestion + 1)/\(questions.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Quit") {
                    quitGame()
                }
            }
        }
        .onAppear {
            // Could generate questions here
        }
    }
}

struct ScoreView: View {
    let score: Int
    let questions: [(Int, Int)]
    let startGame: () -> Void
    let quitGame: () -> Void

    var body: some View {
        VStack {
            Text("Your score is \(score)/\(questions.count)!")
                .font(.largeTitle)

            HStack {
                Button("Restart") {
                    startGame()
                }

                Button("Quit", role: .destructive) {
                    quitGame()
                }
            }
        }
        .navigationTitle("Final Score")
    }
}

struct ContentView: View {
    @State private var currentState = GameState.inactive
    @State private var maxTableUnit = 2
    @State private var questionsAmount = 5
    @State private var questions = [(Int, Int)]()
    @State private var currentQuestion = 0
    @State private var answer = 0
    @State private var score = 0

    var body: some View {
        NavigationStack {
            switch currentState {
            case .inactive:
                SettingsView(maxTableUnit: $maxTableUnit, questionsAmount: $questionsAmount, startGame: startGame)
            case .started:
                GameView(answer: $answer, questions: questions, currentQuestion: currentQuestion, validateAnswer: validateAnswer, quitGame: quitGame)
            case .ended:
                ScoreView(score: score, questions: questions, startGame: startGame, quitGame: quitGame)
            }
        }
    }

    func generateQuestions() {
        questions = [(Int, Int)]()
        while questions.count < questionsAmount {
            let first = Int.random(in: 2...maxTableUnit)
            let last = Int.random(in: 1...9)
            questions.append((first, last))
        }
    }

    func startGame() {
        score = 0
        currentQuestion = 0
        generateQuestions()
        currentState = .started
    }

    func validateAnswer() {
        let (first, last) = questions[currentQuestion]
        if answer == first * last {
            score += 1
        }

        answer = 0

        if currentQuestion == questions.count - 1 {
            currentState = .ended
        } else {
            currentQuestion += 1
        }
    }

    func quitGame() {
        currentState = .inactive
    }
}

#Preview {
    ContentView()
}

#Preview {
    SettingsView(maxTableUnit: .constant(2), questionsAmount: .constant(5), startGame: {})
}

#Preview {
    GameView(answer: .constant(10), questions: [(2,2)], currentQuestion: 0, validateAnswer: {}, quitGame: {})
}

#Preview {
    ScoreView(score: 1, questions: [(1,1)], startGame: {}, quitGame: {})
}
