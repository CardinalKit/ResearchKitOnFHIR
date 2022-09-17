//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 CardinalKit and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import FHIRQuestionnaires

struct QuestionnaireSection: Hashable {
    var questionnaires: [Questionnaire]
    var header: String
}

/// List of example FHIR questionnaires to be rendered as ResearchKit tasks
struct QuestionnaireListView: View {
    @State private var activeQuestionnaire: Questionnaire?
    @State private var presentQuestionnaire = false
    @State private var presentQuestionnaireJSON = false
    @State private var presentQuestionnaireResponses = false

    private var questionnaireSections: [QuestionnaireSection] = [
        QuestionnaireSection(questionnaires: Questionnaire.exampleQuestionnaires,
                             header: NSLocalizedString("QUESTIONNAIRE_LIST_EXAMPLES_HEADER", comment: "")),
        QuestionnaireSection(questionnaires: Questionnaire.clinicalQuestionnaires,
                             header: NSLocalizedString("QUESTIONNAIRE_LIST_CLINICAL_EXAMPLES_HEADER", comment: ""))
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(questionnaireSections, id: \.self) { section in
                    Section {
                        ForEach(section.questionnaires, id: \.self) { questionnaire in
                            Button(questionnaire.title?.value?.string ?? String(localized: "QUESTIONNAIRE_DEFAULT_TITLE")) {
                                activeQuestionnaire = questionnaire
                                presentQuestionnaire = true
                            }
                            .contextMenu {
                                Button {
                                    activeQuestionnaire = questionnaire
                                    presentQuestionnaireJSON = true
                                } label: {
                                    Label(NSLocalizedString("QUESTIONNAIRES_VIEW_JSON", comment: ""), systemImage: "doc.badge.gearshape")
                                }

                                Button {
                                    activeQuestionnaire = questionnaire
                                    presentQuestionnaireResponses = true
                                } label: {
                                    Label(NSLocalizedString("QUESTIONNAIRES_VIEW_RESPONSES", comment: ""), systemImage: "arrow.right.doc.on.clipboard")
                                }
                            }
                        }
                    } header: {
                        Text(section.header)
                    }
                }
            }
            .navigationTitle("QUESTIONNAIRE_LIST_TITLE")
        }
        .sheet(isPresented: $presentQuestionnaire) {
            QuestionnaireView(questionnaire: $activeQuestionnaire)
                .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $presentQuestionnaireJSON) {
            QuestionnaireJSONView(questionnaire: $activeQuestionnaire)
        }
        .sheet(isPresented: $presentQuestionnaireResponses) {
            QuestionnaireResponsesView(questionnaire: $activeQuestionnaire)
        }
    }
}

struct QuestionnaireListView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireListView()
    }
}
