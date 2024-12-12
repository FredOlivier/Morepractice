//ImageScoringView.swift
// Morepractice
//
// Created by Fred Olivier on 17/09/2024.
//
// Updated to ensure images fill the screen top-to-bottom and the navigation bar is transparent.

import SwiftUI

struct ImageScoringView: View {
    @ObservedObject var scoreManager: ScoreManager
    @StateObject private var imageManager: ImageManager

    @State private var sliderValue1: Double = 0.5
    @State private var sliderValue2: Double = 0.5

    @State private var currentPhoto1: Photo?
    @State private var currentPhoto2: Photo?

    // Slider color components
    @State private var slider1StartColor: Color = .red
    @State private var slider1EndColor: Color = .blue
    @State private var slider2StartColor: Color = .green
    @State private var slider2EndColor: Color = .yellow

    // View State Enum
    enum ViewState {
        case maximizingFirstImage
        case maximizingSecondImage
        case enlargingImage1
        case enlargingImage2
        case normalLayout
    }

    @State private var viewState: ViewState = .maximizingFirstImage

    init(scoreManager: ScoreManager) {
        self.scoreManager = scoreManager
        _imageManager = StateObject(wrappedValue: ImageManager(scoreManager: scoreManager))
    }

    var body: some View {
        NavigationView {
            ZStack {
                switch viewState {
                case .maximizingFirstImage:
                    displayImage(photo: currentPhoto1, duration: 2, chainToNextState: .maximizingSecondImage) {}
                case .maximizingSecondImage:
                    displayImage(photo: currentPhoto2, duration: 2, chainToNextState: .normalLayout) {}
                case .enlargingImage1:
                    displayImage(photo: currentPhoto1, duration: 2, chainToNextState: .normalLayout) {}
                case .enlargingImage2:
                    displayImage(photo: currentPhoto2, duration: 2, chainToNextState: .normalLayout) {}
                case .normalLayout:
                    normalLayout()
                    nextButtonView()
                }
            }
            .ignoresSafeArea() // Allow images to extend behind navigation bar and safe area
            .navigationTitle("WutYaLike")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: MyHeartView(scoreManager: scoreManager)) {
                        Text("MyHeart")
                            .foregroundColor(.pink)
                    }
                }
            }
            .onAppear {
                loadNextPair()
                makeNavigationBarTransparent() // Make the navigation bar background transparent
            }
        }
    }

    // MARK: - Display Image Method

    private func displayImage(photo: Photo?, duration: Double, chainToNextState: ViewState?, completion: @escaping () -> Void) -> some View {
        VStack {
            if let photo = photo {
                AsyncImage(url: URL(string: photo.url)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .clipped()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                    withAnimation {
                                        if let nextState = chainToNextState {
                                            self.viewState = nextState
                                        }
                                        completion()
                                    }
                                }
                            }
                    } else if phase.error != nil {
                        // Error placeholder
                        Color.red
                    } else {
                        // Placeholder while loading
                        ProgressView()
                    }
                }
            } else {
                // Handle case where photo is nil
                Text("No Image Available")
            }
        }
    }

    // MARK: - Normal Layout

    private func normalLayout() -> some View {
        HStack(spacing: 0) {
            // Left Image with Enlarge Button
            if let photo1 = currentPhoto1 {
                ZStack {
                    // Background Image
                    AsyncImage(url: URL(string: photo1.url)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height)
                                .clipped()
                                .allowsHitTesting(false)
                        } else if phase.error != nil {
                            // Error placeholder
                            Color.red
                        } else {
                            // Placeholder while loading
                            ProgressView()
                        }
                    }

                    // Enlarge Button
                    Button(action: {
                        self.viewState = .enlargingImage1
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .position(x: 30, y: UIScreen.main.bounds.height / 2)
                }
            }

            // Right Image with Enlarge Button
            if let photo2 = currentPhoto2 {
                ZStack {
                    // Background Image
                    AsyncImage(url: URL(string: photo2.url)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height)
                                .clipped()
                                .allowsHitTesting(false)
                        } else if phase.error != nil {
                            Color.red
                        } else {
                            ProgressView()
                        }
                    }

                    // Enlarge Button
                    Button(action: {
                        self.viewState = .enlargingImage2
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .position(x: (UIScreen.main.bounds.width / 2) - 30, y: UIScreen.main.bounds.height / 2)
                }
            }
        }
        .overlay(
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    // First Slider
                    SliderView(
                        sliderValue: $sliderValue1,
                        startColor: slider1StartColor,
                        endColor: slider1EndColor
                    )
                    .frame(width: UIScreen.main.bounds.width / 2)

                    // Second Slider
                    SliderView(
                        sliderValue: $sliderValue2,
                        startColor: slider2StartColor,
                        endColor: slider2EndColor
                    )
                    .frame(width: UIScreen.main.bounds.width / 2)
                }
                .padding()
                Spacer()
            }
        )
    }

    // MARK: - Next Button View

    private func nextButtonView() -> some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 70, height: 70)
                .shadow(radius: 10)

            Text("+")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        .onTapGesture {
            submitScoreAndGetNextPair()
        }
    }

    // MARK: - Action Methods

    private func submitScoreAndGetNextPair() {
        guard let photo1 = currentPhoto1,
              let photo2 = currentPhoto2 else {
            return
        }

        let relationalScore = abs(sliderValue1 - sliderValue2)

        scoreManager.addScore(
            slider1: sliderValue1 * 100,
            slider2: sliderValue2 * 100,
            image1: photo1.id ?? "",
            image2: photo2.id ?? "",
            image1URL: photo1.url,
            image2URL: photo2.url,
            relationalScore: relationalScore
        )

        // Reset sliders
        sliderValue1 = 0.5
        sliderValue2 = 0.5

        // Generate new random colors for sliders
        slider1StartColor = randomColor()
        slider1EndColor = randomColor()
        slider2StartColor = randomColor()
        slider2EndColor = randomColor()

        // Load the next pair of images
        loadNextPair()
    }

    // MARK: - Load Next Pair

    private func loadNextPair() {
        imageManager.getNextPair { nextPair in
            if let pair = nextPair {
                DispatchQueue.main.async {
                    self.currentPhoto1 = pair.0
                    self.currentPhoto2 = pair.1
                    self.viewState = .maximizingFirstImage
                }
            } else {
                print("No image pair available.")
            }
        }
    }

    // MARK: - Helper Functions

    func sliderColor(value: Double, startColor: Color, endColor: Color) -> Color {
        let startComponents = UIColor(startColor).cgColor.components ?? [0, 0, 0, 1]
        let endComponents = UIColor(endColor).cgColor.components ?? [0, 0, 0, 1]

        let red = (1 - value) * startComponents[0] + value * endComponents[0]
        let green = (1 - value) * startComponents[1] + value * endComponents[1]
        let blue = (1 - value) * startComponents[2] + value * endComponents[2]
        let alpha = (1 - value) * startComponents[3] + value * endComponents[3]

        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    func randomColor() -> Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }

    // MARK: - Make Navigation Bar Transparent

    private func makeNavigationBarTransparent() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - SliderView Component

struct SliderView: View {
    @Binding var sliderValue: Double
    let startColor: Color
    let endColor: Color

    var body: some View {
        VerticalSlider(
            value: $sliderValue,
            thumbColor: sliderColor(
                value: sliderValue,
                startColor: startColor,
                endColor: endColor
            ),
            trackColor: .gray,
            thumbOpacity: 0.5,
            hapticFeedback: true
        )
        .frame(width: 40, height: UIScreen.main.bounds.height * 0.9)
        .opacity(0.7)
    }

    func sliderColor(value: Double, startColor: Color, endColor: Color) -> Color {
        let startComponents = UIColor(startColor).cgColor.components ?? [0, 0, 0, 1]
        let endComponents = UIColor(endColor).cgColor.components ?? [0, 0, 0, 1]

        let red = (1 - value) * startComponents[0] + value * endComponents[0]
        let green = (1 - value) * startComponents[1] + value * endComponents[1]
        let blue = (1 - value) * startComponents[2] + value * endComponents[2]
        let alpha = (1 - value) * startComponents[3] + value * endComponents[3]

        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
