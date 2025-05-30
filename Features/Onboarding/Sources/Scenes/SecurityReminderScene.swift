// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components
import Localization

struct SecurityReminderScene: View {
    @State private var model: SecurityReminderViewModel
    @State private var isPresentingUrl: URL? = nil
    
    init(model: SecurityReminderViewModel) {
        self.model = model
    }
    
    var body: some View {
        VStack(spacing: .medium) {
            List {
                OnboardingHeaderTitle(title: model.message, alignment: .center)
                    .cleanListRow()
                
                ForEach(model.items) { item in
                    Section {
                        ListItemView(
                            title: item.title,
                            titleStyle: .headline,
                            titleExtra: item.subtitle,
                            titleStyleExtra: .bodySecondary,
                            imageStyle: item.image
                        )
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.custom(.medium))
            
            Spacer()
            
            StateButton(
                text: Localized.Common.continue,
                styleState: .normal,
                action: model.onNext
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: SystemImage.info) {
                    isPresentingUrl = model.docsUrl
                }
            }
        }
        .safariSheet(url: $isPresentingUrl)
    }
}

#Preview {
    SecurityReminderScene(
        model: SecurityReminderViewModelDefault(
            title: Localized.Wallet.New.title,
            onNext: {}
        )
    )
}
