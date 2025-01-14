import Foundation
import Hummingbird
import HummingbirdAuth
import Logging
import NIOCore

// MARK: Figure out what this is doing

struct AppRequestContext: AuthRequestContext, SessionRequestContext, RequestContext {
    var coreContext: CoreRequestContextStorage
    var identity: User?
    var sessions: SessionContext<UUID>

    init(source: Source) {
        coreContext = .init(source: source)
        identity = nil
        sessions = .init()
    }

    var requestDecoder: TodosAuthRequestDecoder {
        TodosAuthRequestDecoder()
    }
}
