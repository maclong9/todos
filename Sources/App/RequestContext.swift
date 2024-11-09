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
    self.coreContext = .init(source: source)
    self.identity = nil
    self.sessions = .init()
  }

  var requestDecoder: TodosAuthRequestDecoder {
    TodosAuthRequestDecoder()
  }
}
