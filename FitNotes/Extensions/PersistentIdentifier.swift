
import SwiftUI
import SwiftData
import UniformTypeIdentifiers


extension UTType {
    static var persistentModelID: UTType { UTType(exportedAs: "com.mylesverdon.persistentModelID") }
}

extension PersistentIdentifier: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .persistentModelID)
    }
}

extension PersistentIdentifier {
    public func persistentModel<Model>(from context: ModelContext) -> Model? where Model : PersistentModel {
        return context.model(for: self) as? Model
    }
}
