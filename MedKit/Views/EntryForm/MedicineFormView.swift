//
//  MedicineFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import PDFKit
import SwiftUI

struct MedicineFormView: View {
    let medicine: Medicine

    @Environment(NavigationRouter.self) private var router
    @State private var medicineEditorViewModel: MedicineEditorViewModel
    @State private var showShareSheet: Bool = false
    @State private var showAlert: Bool = false
    
    private var isNewMedicine: Bool {
        medicine.name.trimmedIsEmpty
    }
    
    private var navigationTitle: Text {
        isNewMedicine ? Text("New Medicine") : Text(medicine.name)
    }
        
    init(medicine: Medicine) {
        self.medicine = medicine
        self._medicineEditorViewModel = State(initialValue: .init(medicine: medicine))
    }
    
    var body: some View {
        Form {
            NameSectionView(name: $medicineEditorViewModel.medicine.name)
            
            StrengthSectionView(
                amount: $medicineEditorViewModel.medicine.strengthAmount,
                unit: $medicineEditorViewModel.medicine.strengthUnit
            )
            
            DatesSectionView(
                manufacturedDate: $medicineEditorViewModel.medicine.manufacturedDate,
                expiryDate: $medicineEditorViewModel.medicine.expiryDate
            )

            CompositionSectionView()
            
            StockSectionView()
            
            DosageSectionView(dosage: $medicineEditorViewModel.medicine.dosage)

            TagsSectionView()
            
            CustomFieldsSectionView()
        }
        .environment(medicineEditorViewModel)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if (!isNewMedicine) {
                    Menu {
                        shareSheet
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                
                Button("Save") {
                    do {
                        try medicineEditorViewModel.saveMedicine()
                        router.popToRoot()
                    } catch {
                        showAlert.toggle()
                        print(error)
                    }
                }
            }
        }
        .alert(
            isNewMedicine ? Text("Failed to save medicine") : Text("Failed to save \(medicine.name)"),
            isPresented: $showAlert
        ) {
            Button("Dismiss", role: .cancel) { showAlert = false }
        } message: {
            if let errorMessage = medicineEditorViewModel.errorMessage {
                Text(errorMessage)
            } else {
                Text("Something went wrong.")
            }
        }
        .sheet(isPresented: $showShareSheet) {
            shareSheet
                .presentationDetents([.fraction(0.25)])
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(navigationTitle)
    }
    
    private var shareSheet: some View {
        VStack {
            ShareLink(
                item: MedicinePDFExporter(medicine: medicine),
                preview: SharePreview("\(medicine.name)", image: Image(systemName: "doc.richtext"))
            ) {
                Label("Export as PDF", systemImage: "document.badge.arrow.up.fill")
            }
            
            ShareLink(item: medicine, preview: SharePreview("\(medicine.name)", image: Image(systemName: "person.crop.circle.badge.plus"))) {
                Label("Share", systemImage: "person.crop.circle.badge.plus")
            }
        }
    }
}

#Preview {
    NavigationStack {
        MedicineFormView(medicine: .init())
    }
    .environment(GlobalDataViewModel())
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
