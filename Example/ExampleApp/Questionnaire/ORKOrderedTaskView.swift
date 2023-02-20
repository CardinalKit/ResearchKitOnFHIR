//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford Biodesign for Digital Health and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ResearchKit
import SwiftUI
import UIKit


struct ORKOrderedTaskView: UIViewControllerRepresentable {
    private let tasks: ORKOrderedTask
    private let tintColor: Color
    // We need to have a non-weak reference here to keep the retain count of the delegate above 0.
    private var delegate: ORKTaskViewControllerDelegate
    private var outputDirectory: URL?
    
    
    /// - Parameters:
    ///   - tasks: The `ORKOrderedTask` that should be displayed by the `ORKTaskViewController`
    ///   - delegate: An `ORKTaskViewControllerDelegate` that handles delegate calls from the `ORKTaskViewController`.
    ///   - tintColor: The default color to be applied to interactive elements within the task.
    ///   - outputDirectory: The URL of a directory where files generated by the `ORKOrderedTask` should be written.
    init(
        tasks: ORKOrderedTask,
        delegate: ORKTaskViewControllerDelegate,
        tintColor: Color = Color(UIColor(named: "AccentColor")  ?? .tintColor),
        outputDirectory: URL? = nil
    ) {
        self.tasks = tasks
        self.tintColor = tintColor
        self.delegate = delegate
        self.outputDirectory = outputDirectory
    }

    func getTaskOutputDirectory() -> URL? {
        do {
            let defaultFileManager = FileManager.default

            // Create a temporary directory to store files created by the task.
            let temporaryDirectory = try defaultFileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            return temporaryDirectory
        } catch let error as NSError {
            print("The output directory could not be created. Error: \(error.localizedDescription)")
        }

        return nil
    }
    
    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {
        uiViewController.view.tintColor = UIColor(tintColor)
    }
    
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        // Create a new instance of the view controller and pass in the assigned delegate.
        let viewController = ORKTaskViewController(task: tasks, taskRun: nil)
        viewController.outputDirectory = outputDirectory ?? getTaskOutputDirectory()
        viewController.view.tintColor = UIColor(tintColor)
        viewController.delegate = delegate
        return viewController
    }
}
